# This file is a template, and might need editing before it works on your project.
FROM php:7.2-apache

# Customize any core extensions here
#RUN apt-get update && apt-get install -y \
#        libfreetype6-dev \
#        libjpeg62-turbo-dev \
#        libmcrypt-dev \
#        libpng12-dev \
#    && docker-php-ext-install -j$(nproc) iconv mcrypt \
#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#    && docker-php-ext-install -j$(nproc) gd


# Microsoft SQL Server Prerequisite
ENV ACCEPT_EULA=Y
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gnupg curl \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        unixodbc-dev \
        msodbcsql17 \
    && apt-get -y --no-install-recommends install \
        python3 \
    && apt-get -y --no-install-recommends install \
        cron

RUN docker-php-ext-install mbstring pdo pdo_mysql \
    && pecl install sqlsrv pdo_sqlsrv xdebug \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv xdebug

# Enable TLS1.1 for openssl
RUN sed -i -E 's/(CipherString\s*=\s*DEFAULT@SECLEVEL=)2/\11/' /etc/ssl/openssl.cnf

COPY cron/tsv_crontab /etc/cron.d/tsv_crontab

COPY startup.sh /startup.sh

RUN chmod 0644 /etc/cron.d/tsv_crontab \
    && chmod 755 /startup.sh

RUN touch /var/log/schedule.log

RUN chmod 0777 /var/log/schedule.log

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY . /var/www/html/

CMD /startup.sh
