#Template Dockerfile for Ruby projects
FROM ubuntu:16.04
RUN apt-get update
RUN useradd -g sudo -d /home/inquirly -c "Sybase ASE DBA account" -p inquirly inquirly
RUN echo 'inquirly ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
## Default Packages
RUN apt-get -y install python-software-properties software-properties-common 
RUN add-apt-repository -y ppa:brightbox/ruby-ng-experimental
RUN apt-get update &&  apt-get install -y vim zlib1g-dev libssl-dev imagemagick build-essential libmagickwand-dev libxslt1-dev openssl libreadline6 libreadline6-dev zlib1g libyaml-dev \ 
     libsqlite3-0 sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison libpq-dev libpq5 libmysqlclient-dev gcc nodejs git curl wget unzip gnupg \
    && apt-get install -y gawk libreadline6-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev \
    && apt-get update && apt-get install -y make build-essential zlib1g-dev libbz2-dev libreadline-dev sqlite3 libsqlite3-dev libssl-dev python2.7 python2.7-dev python-setuptools \
    && easy_install pip && pip install virtualenv && apt-get install -y postgresql-server-dev-all && easy_install supervisor

RUN usermod -aG sudo inquirly 
#USER inquirly
## Ruby
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -L https://get.rvm.io | bash -s stable
#Set env just in case
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.1"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN /bin/bash -l -c "rvm use 2.1.1 --default"
RUN /bin/bash -l -c "rvm use 2.1.1@Rails4.1_inquirly --create"
RUN /bin/bash -l -c "rvm use ruby-2.1.1@Rails4.1_inquirly --default"
RUN mkdir -p /var/www/apps/inquirly/ && mkdir -p /home/inquirly/markethubs_repo
WORKDIR /var/www/apps/inquirly/
ADD markethubs_repo /home/inquirly/markethubs_repo
WORKDIR /home/inquirly/markethubs_repo
RUN ln -s /home/inquirly/markethubs_repo/www_files/current  /var/www/apps/inquirly/
RUN /bin/bash -l -c "gem install pg -v '0.14.1'"
RUN /bin/bash -l -c "gem install rmagick"
RUN /bin/bash -l -c "gem install bundler"
WORKDIR /var/www/apps/inquirly/current/
RUN /bin/bash -l -c "bundle install"
RUN apt-get install redis-server -y
#service redis-server start
RUN  mkdir -p /var/www/apps/inquirly/markethubs_repo/www_files/current/tmp
ADD thin.yml /var/www/apps/inquirly/current/
WORKDIR /var/www/apps/inquirly/current/
RUN mkdir /etc/supervisor && mkdir /etc/supervisor/conf.d && mkdir /var/log/supervisor && chmod 775 /var/log/supervisor
ADD supervisord.conf  /etc/supervisor/
RUN supervisord -c /etc/supervisor/supervisord.conf
# Define mountable directories.
VOLUME ["/etc/supervisor/conf.d"]
# Define working directory.
WORKDIR /etc/supervisor/conf.d
RUN echo "root:root" | chpasswd
RUN mkdir -p /var/log/inquirly_modules && chmod 775 /var/log/inquirly_modules
RUN apt-get clean
# Define default command.
CMD /usr/local/bin/supervisord -n
