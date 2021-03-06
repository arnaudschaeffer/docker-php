FROM php:7.4-apache

# UID and GID can be passed as argument
# It should match the user running the application
ENV UID=1000
ENV GID=1000

## Configure Apache

RUN a2enmod proxy_fcgi ssl rewrite proxy proxy_balancer proxy_http proxy_ajp

## Configure PHP

RUN apt-get update \
    && apt-get install -y --no-install-recommends vim curl debconf subversion git apt-transport-https apt-utils \
    build-essential locales acl mailutils wget zip unzip libxslt-dev libzip-dev libonig-dev\
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    procps \
    gnupg gnupg1 gnupg2

COPY php.ini /etc/php/7.4/php.ini

#RUN
#RUN docker-php-ext-configure intl

# Add all php librairies
RUN docker-php-ext-configure intl && \
    docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install gd && \
    docker-php-ext-install sysvsem && \
    docker-php-ext-install xsl && \
    docker-php-ext-install intl && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install zip

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer

RUN rm -rf /var/lib/apt/lists/*
RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

COPY rootfs /
RUN chmod +x /*.sh

RUN groupadd php -g $UID
RUN useradd php -g php -u $GID -d /home/php -m

COPY rootfs/root/.bashrc /home/php/

COPY vhosts /etc/apache2/sites-enabled/

WORKDIR /var/www/html

CMD ["/docker-entrypoint.sh", "-f"]