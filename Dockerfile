FROM php:7.4-apache

# UID and GID can be passed as argument
# It should match the user running the application
ENV UID=1000
ENV GID=1000

## Configure Apache

RUN a2enmod proxy_fcgi ssl rewrite proxy proxy_balancer proxy_http proxy_ajp

## Configure PHP

RUN apt-get update && apt-get install -y \
    vim \
    curl \
    debconf \
    apt-transport-https \
    apt-utils \
    build-essential \
    locales \
    acl \
    mailutils \
    wget \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    zlib1g-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxpm-dev \
    libwebp-dev \
    && rm -r /var/lib/apt/lists/*

COPY php.ini /etc/php/7.4/php.ini

#RUN
#RUN docker-php-ext-configure intl

# Add all php librairies
#Keep GD first: https://github.com/docker-library/php/issues/926#issuecomment-567230723
RUN docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype && \
    docker-php-ext-configure intl && \
    docker-php-ext-install -j$(nproc) opcache pdo_mysql exif zip intl sysvsem bcmath gd xsl bcmath && \
    && pecl install apcu-$APCU_VERSION \
    && docker-php-ext-enable apcu
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && date \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer

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