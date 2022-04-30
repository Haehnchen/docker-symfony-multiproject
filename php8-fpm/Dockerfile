# See https://github.com/docker-library/php/blob/master/7.1/fpm/Dockerfile
FROM php:8.0-fpm
ARG TIMEZONE

MAINTAINER Daniel Espendiller <daniel@espendiller.net>

# Frontend build stuff
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y \
    openssl \
    git \
    unzip \
	wget \
    libzip-dev \
    zip \
	libxml2-dev \
	libldap2-dev \
	gnupg \
	apt-transport-https \
	nodejs \
	yarn \
    libicu-dev \
    g++ \
    libonig-dev \
    msmtp-mta


# gd lib
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& composer --version

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
&& printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
&& "date"

# Type docker-php-ext-install to see available extensions
RUN pecl install redis apcu

RUN docker-php-ext-configure ldap \
&& docker-php-ext-configure zip \
&& docker-php-ext-install pdo pdo_mysql bcmath zip opcache soap mbstring ldap pcntl \
&& docker-php-ext-enable redis apcu

RUN docker-php-ext-configure intl \
&& docker-php-ext-install intl

RUN echo "xdebug.remote_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

ARG WITH_XDEBUG

RUN if [ $WITH_XDEBUG = "true" ] ; then \
        pecl install xdebug; \
        docker-php-ext-enable xdebug; \
        echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi ;

# cleanup image
RUN rm -r /var/www/
RUN rm -rf /var/lib/apt/lists/*

# configuration last for not rebuild all stuff for a change
RUN echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "opcache.enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&& echo "opcache.enable_cli = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&& echo "opcache.memory_consumption = 376" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&& echo "opcache.max_accelerated_files = 40000" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&& echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini \
&& echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini \
&& echo "post_max_size = 10M" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini \
&& echo "upload_max_filesize = 10M" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini \
&& echo "realpath_cache_size = 4096K" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini \
&& echo "realpath_cache_ttl = 600" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini \
&& echo "max_execution_time = 60" >> /usr/local/etc/php/conf.d/docker-php-ext-core.ini

# WARNING: [pool www] server reached pm.max_children setting (5), consider raising it
# https://serverfault.com/a/947473
RUN sed -i -e 's/pm = .+?/pm = dynamic/' \
 -e 's/pm\.max_children = [0-9]\+/pm\.max_children = 35/' \
 -e 's/pm\.start_servers = [0-9]\+/pm\.start_servers = 10/' \
 -e 's/pm\.min_spare_servers = [0-9]\+/pm\.min_spare_servers = 5/' \
 -e 's/pm\.max_spare_servers = [0-9]\+/pm\.max_spare_servers = 20/' \
 -e 's/pm\.max_requests = [0-9]\+/pm\.max_requests = 500/' \
 -e 's/pm\.process_idle_timeout = .+?/pm\.process_idle_timeout = 10s/' \
 /usr/local/etc/php-fpm.d/www.conf

RUN echo "\
sendmail_path = /usr/bin/msmtp -t \n\
" >> /usr/local/etc/php/conf.d/msmtp.ini

RUN echo "defaults" >> /etc/msmtprc \
&& echo "port 1025"  >> /etc/msmtprc \
&& echo "tls off"  >> /etc/msmtprc \
&& echo "account default"  >> /etc/msmtprc \
&& echo "auth off"  >> /etc/msmtprc \
&& echo "host mailer"  >> /etc/msmtprc \
&& echo "domain php-fpm"  >> /etc/msmtprc \
&& echo "from webserver@php-fpm"  >> /etc/msmtprc \
&& echo "add_missing_date_header on" >> /etc/msmtprc

# ssh related stuff
RUN mkdir -p ~/.ssh

# Docker secret feature to inject the local ssh file
RUN ln -s /run/secrets/id_rsa ~/.ssh/id_rsa

WORKDIR /var/www

