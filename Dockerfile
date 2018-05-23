################################
#                              #
#   Ubuntu - PHP 7.1 CLI+FPM   #
#                              #
################################

FROM ubuntu:xenial

MAINTAINER Roman Samarsky <rosamarsky@gmail.com>

LABEL Vendor="rosamarsky"
LABEL Description="PHP-FPM v7.1"
LABEL Version="1.0.0"

ENV TIME_ZONE UTC

#RUN apt-get install -y python-software-properties

RUN apt-get update -yqq \
    && apt-get install -yqq \
        ca-certificates \
        git \
        nano \
        gcc \
        make \
        wget \
        mc \
        curl \
        sendmail

RUN DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-software-properties
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php


## Install php7.1 extension
RUN apt-get update -yqq \
    && apt-get install -yqq \
        php7.1-pgsql \
        php7.1-mysql \
        php7.1-opcache \
        php7.1-common \
        php7.1-mbstring \
        php7.1-mcrypt \
        php7.1-soap \
        php7.1-cli \
        php7.1-intl \
        php7.1-json \
        php7.1-xsl \
        php7.1-imap \
        php7.1-ldap \
        php7.1-curl \
        php7.1-gd \
        php7.1-dev \
        php7.1-fpm \
    	php7.1-bcmath \
    	php7.1-zip \
        librabbitmq-dev \
        libssh-dev \
    && apt-get install pkg-config \
    && pecl install mongodb \
    && pecl install amqp \
    && echo "extension=mongodb.so" > /etc/php/7.1/cli/conf.d/ext-mongodb.ini \
    && echo "extension=mongodb.so" > /etc/php/7.1/fpm/conf.d/ext-mongodb.ini \
    && echo "extension=amqp.so" > /etc/php/7.1/cli/conf.d/ext-amqp.ini \
    && apt-get install -y -q --no-install-recommends \
       ssmtp

# Add default timezone
RUN echo $TIME_ZONE > /etc/timezone
RUN echo "date.timezone=$TIME_ZONE" > /etc/php/7.1/cli/conf.d/timezone.ini

## Install composer globally
RUN echo "Install composer globally"
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

## Add AMQP
RUN apt-get update && apt-get install -y \
    librabbitmq-dev \
    libssh-dev

# Copy our config files for php7.1 fpm and php7.1 cli
COPY php-conf/php.ini /etc/php/7.1/cli/php.ini
COPY php-conf/php-fpm.ini /etc/php/7.1/fpm/php.ini
COPY php-conf/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
COPY php-conf/www.conf /etc/php/7.1/fpm/pool.d/www.conf

RUN usermod -aG www-data www-data
# Reconfigure system time
RUN  dpkg-reconfigure -f noninteractive tzdata

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]

WORKDIR /var/www/rosamarsky

EXPOSE 9000
