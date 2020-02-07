FROM php:7.4-apache

# Base Install
RUN apt-get -y update
RUN apt-get upgrade -y

# Install important libraries
RUN apt-get -y install --fix-missing apt-utils build-essential git curl libcurl4-openssl-dev zip openssl libssl-dev cron

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Other PHP7 Extensions

RUN apt-get -y install libsqlite3-dev libsqlite3-0 mariadb-client libxml2-dev libonig-dev
RUN docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install curl && \
    docker-php-ext-install tokenizer && \
    docker-php-ext-install json && \
    docker-php-ext-install soap && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install gettext

RUN apt-get -y install zlib1g-dev zlib1g-dev libzip-dev && \
    docker-php-ext-install zip

RUN apt-get -y install libicu-dev && \
    docker-php-ext-install -j$(nproc) intl


RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    docker-php-ext-configure gd && \
    docker-php-ext-install -j$(nproc) gd

RUN \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Install redis
RUN pecl install redis && \
    docker-php-ext-enable redis

# Enable apache modules
RUN a2enmod rewrite headers ssl

# Wordpress WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# For cache
RUN mkdir -p /var/www/.composer && \
    chmod 777 /var/www/.composer && \
    mkdir -p /var/www/.ssh && \
    chmod 777 /var/www/.ssh

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]