FROM ubuntu:16.04
RUN apt-get update && apt-get -y upgrade
RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget build-essential python-software-properties
RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key
RUN apt-get update && apt-get -y install nginx php7.0 php7.0-fpm unzip gzip inetutils-ping php7.0-curl php7.0-gd php7.0-cli php7.0-mysql php-xml php7.0-mbstring php7.0-common php7.0-mysqlnd php7.0-mcrypt  php7.0-bcmath php7.0-soap php7.0-xml php7.0-zip php7.0-json php7.0-imap php-xdebug php-pgsql
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini
RUN sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ 2G/g' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/\;date\.timezone\ =/date\.timezone\ =\ Asia\/Ho_Chi_Minh/g' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 200M/g' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/post_max_size\ =\ 8M/post_max_size\ =\ 200M/g' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/max_execution_time\ =\ 30/max_execution_time\ =\ 3600/g' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/\;error_log\ =\ syslog/error_log\ =\ syslog/g' /etc/php/7.0/fpm/php.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD echo "127.0.0.1   piwik.markethub.com" >> /etc/hosts && service nginx start && service php7.0-fpm start && chmod 777 /run/php/php7.0-fpm.sock && ping localhost
ADD piwik/Piwik.conf /etc/nginx/conf.d/
ADD markethubs.conf /etc/nginx/conf.d/
ADD shortenurl.conf /etc/nginx/conf.d/
# install piwik
WORKDIR /var/www/html
RUN wget https://builds.piwik.org/piwik.zip && \
    unzip piwik.zip && \
    chown www-data:www-data -R piwik && \
    chown -R www-data:www-data /var/www/html/piwik && \
    chmod 0770 /var/www/html/piwik/tmp && \
    chmod 0770 /var/www/html/piwik/config && \
    chmod 0600 /var/www/html/piwik/config/* && \
    rm -f piwik.zip

# Install MaxMind GeoCity Lite database
WORKDIR /var/www//html/piwik/misc
RUN wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && \
    gunzip GeoLiteCity.dat.gz && \
    cp GeoLiteCity.dat GeoIPCity.dat &&\
    chown www-data:www-data GeoIPCity.dat &&\
    chown www-data:www-data GeoLiteCity.dat &&\
    rm -f GeoLiteCity.dat.gz
RUN ln -s /run/php/php7.0-fpm.sock /var/run/
#RUN cp /run/php/php7.0-fpm.sock /var/run
#RUN sed -i "127.0.0.1   piwik.markethub.com" /etc/hosts
EXPOSE 80
