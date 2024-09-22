FROM ubuntu:20.04

RUN apt-get update

RUN apt-get install -y nginx curl nano dialog net-tools iputils-ping tzdata php-fpm

RUN export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN rm -r /var/log/nginx

RUN rm /etc/nginx/sites-available/default

RUN touch /etc/nginx/sites-available/default

RUN apt-get autoremove -y

EXPOSE 80
