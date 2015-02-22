FROM ruby:2.2.0-onbuild

RUN cd /tmp
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
RUN tar xfv phantomjs-1.9.7-linux-x86_64.tar.bz2
RUN cp phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

EXPOSE 9292

CMD ["/usr/local/bundle/bin/bundle", "exec", "rackup -o 0.0.0.0 -p 9292"]
