#!/bin/bash
/etc/init.d/php7.0-fpm start
service nginx start
ping localhost
