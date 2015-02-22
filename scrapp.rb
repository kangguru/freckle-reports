require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
   Capybara::Poltergeist::Driver.new(app,
    :phantomjs_options => ['--debug=no', '--load-images=yes', '--ignore-ssl-errors=yes', '--ssl-protocol=any'], :debug => false)
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.app_host = "https://#{ENV['SUBDOMAIN']}.letsfreckle.com"

class MyFreckle
  include Capybara::DSL

  def initialize(from = nil, to = nil)
    @from = from
    @to   = to
  end

    def fetch!
    if !File.exists?("reports-#{@from}.html") || File.mtime("reports-#{@from}.html") < Time.now - 60*60
      visit('/signin')

      unless current_path =~ /time\/dashboard/
        fill_in 'email', :with => ENV["EMAIL"]
        fill_in 'password', :with => ENV["PASSWORD"]

        find(:xpath, '//*[@id="submit_arrow"]/div[2]').click
      end

      visit("/time/report/from/#{@from}/to/#{@to}/group_by/month,billable/")

      File.write("reports-#{@from}.html", page.body)
    end

    self
  end

  def projects
    doc = Nokogiri::HTML(File.open("reports-#{@from}.html"))

    p = []
    doc.xpath('//*[@id="billable_table"]/tbody[contains(@id, "entries-body")]/tr').each do |project|
      next if project.at_xpath(".//span[@class='project-name']").nil?

      name  = project.at_xpath(".//span[@class='project-name']").text.to_s.downcase
      user  = project.at_xpath(".//td[@class='user wide']/a/span").text.to_s.downcase
      firstname = user.to_s.split(' ').first
      minutes  = project.at_xpath(".//td[@class='minutes time']/span[@class='raw-format hidden']").text
      hours = (minutes.to_f / 60.0 * 100.0).round / 100.0
      days = (hours / 8.0 * 100.0).round / 100.0

      p << {project: name, user: user, firstname: firstname, minutes: minutes, hours: hours, days: days}
    end

    response = {}
    p.group_by {|b| b[:firstname]}.each do |name, details|
      response[name] = details.group_by {|d| d[:project] }
    end
    response
  end
end
