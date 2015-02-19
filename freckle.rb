#!/usr/bin/env ruby

# Require the gems
require 'sinatra/base'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require './scrapp'

# Configure Poltergeist to not blow up on websites with js errors aka every website with js
# See more options at https://github.com/teampoltergeist/poltergeist#customization

class Web < Sinatra::Base

  get "/:year/:month" do
    from = Date.parse("#{params[:year]}-#{params[:month].rjust(2, "0")}-01")
    to   = from.end_of_month

    [200, {'Content-Type' => 'application/json'}, JSON.dump(MyFreckle.new(from, to).fetch!.projects)]
  end

end

# puts MyFreckle.new.fetch!
