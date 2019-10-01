FROM php:7-apache
MAINTAINER codyrigg

RUN apt-get update && \
    apt-get install -y vim \
    curl \
    unzip \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libicu-dev \
    g++ \
	libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* 
	
RUN docker-php-ext-configure intl \
    && docker-php-ext-install intl

RUN docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd && \
	docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap
    
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir /var/www/sso && chown www-data: /var/www/sso -R && \
    chmod 0755 /var/www/sso -R
	
COPY ./config/sso.conf /etc/apache2/sites-available/sso.conf
RUN mkdir -p /var/www/parking/current

RUN a2ensite sso.conf && a2dissite 000-default.conf && a2enmod rewrite

WORKDIR /var/www/sso

EXPOSE 80

CMD ["apache2-foreground"]