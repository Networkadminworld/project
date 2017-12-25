FROM ubuntu:14.04
RUN apt-get update && apt-get install -y make build-essential zlib1g-dev libbz2-dev libreadline-dev sqlite3 libsqlite3-dev libssl-dev python2.7 python2.7-dev python-setuptools \
    && easy_install pip && pip install virtualenv && apt-get install -y postgresql-server-dev-all && easy_install supervisor
RUN mkdir /etc/supervisor && mkdir /etc/supervisor/conf.d && mkdir /var/log/supervisor && chmod 775 /var/log/supervisor
ADD supervisord.conf  /etc/supervisor/
RUN supervisord -c /etc/supervisor/supervisord.conf
# Define mountable directories.
VOLUME ["/etc/supervisor/conf.d"]

# Define working directory.
WORKDIR /etc/supervisor/conf.d

RUN echo "root:root" | chpasswd

EXPOSE 22

# Define default command.
CMD /usr/local/bin/supervisord -n
