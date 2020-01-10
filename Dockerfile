FROM php:7.3-fpm

# UID and GID can be passed as argument
# It should match the user running the application
ENV UID=1000
ENV GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends vim curl debconf subversion git apt-transport-https apt-utils \
    build-essential locales acl mailutils wget zip unzip libxslt-dev libzip-dev \
    procps \
    gnupg gnupg1 gnupg2

COPY php.ini /etc/php/7.2.3/php.ini
COPY php-fpm-pool.conf /etc/php/7.2.3/pool.d/www.conf

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-configure intl

# Add all php librairies
RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install sysvsem && \
    docker-php-ext-install xsl && \
    docker-php-ext-install intl && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install zip

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer

RUN groupadd php -g $UID
RUN useradd php -g php -u $GID -d /home/php -m

RUN rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

COPY rootfs /
COPY rootfs/root/.bashrc /home/php/

WORKDIR /var/www/html

EXPOSE 9000
CMD ["php-fpm"]