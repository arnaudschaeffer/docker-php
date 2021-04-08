FROM php:7.3-apache-stretch

# UID and GID can be passed as argument
# It should match the user running the application
ENV UID=1000
ENV GID=1000

## Configure Apache

RUN a2enmod proxy_fcgi ssl rewrite proxy proxy_balancer proxy_http proxy_ajp

## Configure PHP

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    apt-transport-https \
    apt-utils \
    debconf \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libwebp-dev \
    curl \
    vim \
    unzip \
    libzip-dev \
    zip \
    locales \
    acl \
    mailutils \
    wget \
    libxslt-dev \
    libonig-dev\
    procps \
    gnupg gnupg1 gnupg2 \
    && rm -rf /var/lib/apt/lists/*

COPY php.ini /etc/php/7.4/php.ini

#RUN
#RUN docker-php-ext-configure intl

# Add all php librairies
#Keep GD first: https://github.com/docker-library/php/issues/926#issuecomment-567230723
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure intl && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install  -j "$(nproc)" \
        gd \
        sysvsem \
        xsl  \
        intl \
        bcmath \
        zip \
        opcache && \
    rm -rf /var/lib/apt/lists/*

#RUN pecl install imagick
#RUN docker-php-ext-enable imagick

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

RUN php -r 'var_dump(gd_info());'

CMD ["/docker-entrypoint.sh", "-f"]