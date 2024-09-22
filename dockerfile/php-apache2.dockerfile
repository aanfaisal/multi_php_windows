FROM ubuntu:20.04

ARG php_version
ARG app_name

ENV php_version ${php_version:-5.6}
ENV app_name ${php_version}

RUN apt-get update

RUN apt-get install -y tzdata

RUN export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

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
    php$php_version-memcache \
    php$php_version-xml \
    php$php_version-dom

RUN if [ $php_version != 8.0 ] ; then apt-get install -y php$php_version-json ; fi

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
