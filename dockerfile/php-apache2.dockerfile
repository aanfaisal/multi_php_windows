FROM ubuntu:22.04

ARG php_version
ARG app_name

ENV php_version ${php_version:-8.1}
ENV app_name ${app_name}

# Set non-interactive mode to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y tzdata

RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

RUN apt-get install -y -f software-properties-common

RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN add-apt-repository ppa:ondrej/php && apt-get update

RUN apt-get install -y \
    apt-transport-https curl wget nano git unzip apache2 php$php_version \
    php$php_version-imagick \
    php$php_version-curl \
    php$php_version-gd \
    php$php_version-mbstring \
    php$php_version-mysql \
    php$php_version-pgsql \
    php$php_version-bcmath \
    php$php_version-bz2 \
    php$php_version-xml \
    php$php_version-dom

# Install php-json only for versions that need it (PHP < 8.0)
RUN if [ "$php_version" = "5.6" ] || [ "$php_version" = "7.0" ] || [ "$php_version" = "7.1" ] || [ "$php_version" = "7.2" ] || [ "$php_version" = "7.3" ] || [ "$php_version" = "7.4" ]; then \
        apt-get install -y php$php_version-json; \
    fi

# Install memcache extension (handle different availability across versions)
RUN apt-get install -y php$php_version-memcache || echo "memcache extension not available for PHP $php_version"

RUN apt-get purge -y software-properties-common

WORKDIR ~

RUN curl -s https://getcomposer.org/installer | php

RUN mv composer.phar /usr/local/bin/composer

RUN update-alternatives --set php /usr/bin/php$php_version

RUN a2enmod ssl && service apache2 start && a2enmod rewrite && service apache2 reload

ENTRYPOINT /usr/sbin/apachectl -DFOREGROUND

RUN rm -r /var/www/html && \
    rm /etc/php/$php_version/cli/php.ini && \
    rm -r /etc/apache2/sites-available && \
    rm -r /var/log/apache2

RUN apt-get autoremove -y

EXPOSE 80
