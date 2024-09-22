#!/usr/bin/env bash
set -x # Aktifkan debug mode

# Menyesuaikan path untuk Windows
PWD=$(cygpath -w "$PWD")

# Parsing argumen command-line
while getopts "n:v:d:" arg; do
    case $arg in
        n) Name=$OPTARG;;
        v) Ver=$OPTARG;;
        d) Dir=$OPTARG;;
    esac
done

# Validasi argumen
if [ -z "$Name" ]; then
    echo "ERROR: Please provide application name with -n"
    exit 1
fi

if [ -z "$Ver" ]; then
    echo "ERROR: Please provide php version with -v"
    exit 1
fi

# Membuat file konfigurasi Apache jika belum ada
if [ ! -f "./config/apache2/$Name.conf" ]; then
    echo "<VirtualHost *:80>
    ServerAdmin name@domain.ltd
    ServerName $Name
    ServerAlias $Name
    DocumentRoot /var/www/html$Dir

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory \"/var/www/html$Dir\">
        AllowOverride All
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Order allow,deny
        Allow from all
        AddType application/x-httpd-php .php .html .htm
    </Directory>
</VirtualHost>" > ./config/apache2/$Name.conf
    echo "Apache conf created"
fi

if [ ! -d ./log/"$Name" ];
then
    mkdir ./log/"$Name"
    touch ./log/"$Name"/access.log
    touch ./log/"$Name"/error.log
    touch ./log/"$Name"/other_vhosts_access.log
    echo "Log folder created"
fi

if [ ! -d ./dockerfile/"$Name" ];
then
    mkdir  ./dockerfile/"$Name"
    echo "Dockerfile dir created"
fi

if [ ! -d ./app/"$Name" ];
then
    mkdir  ./app/"$Name"
    echo "App dir created"
fi

docker build -t "$Name":latest --build-arg php_version="$Ver" --build-arg app_name="$Name"  -f ./dockerfile/php-apache2.dockerfile ./dockerfile
echo "Image created"

if [[ $(docker inspect --format='{{.State.Running}}' "$Name") == "true" ]];
then
    docker stop "$Name"
fi

if [[ $(docker inspect --format='{{.State.Running}}' "$Name") == "false" ]];
then
    docker rm "$Name"
fi

docker run -dit \
    -v "$PWD"/app/"$Name":/var/www/html:Z \
    -v "$PWD"/config/php"$Ver"/php.ini:/etc/php/"$Ver"/cli/php.ini:Z \
    -v "$PWD"/config/apache2/"$Name".conf:/etc/apache2/sites-available/000-default.conf:Z \
    -v "$PWD"/log/"$Name":/var/log/apache2:Z \
    --restart=always \
    --network=route \
    --name="$Name" \
    "$Name":latest /bin/bash

if [ ! -f ./config/route/"$Name".conf ];
then
    echo "server {
    listen 80;
    server_name "$Name".local;
    proxy_connect_timeout           180;
    proxy_send_timeout              180;
    proxy_read_timeout              180;
    send_timeout                    180;

    location / {
        proxy_pass http://$Name:80;
        proxy_buffering         off;
        proxy_redirect          off;
        proxy_set_header        Host            \$host;
        proxy_set_header        X-Real-IP       \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header        Referer         \$http_referer;
    }
}" >> ./config/route/"$Name".conf
    echo "Nginx route conf created"
fi

docker restart route
