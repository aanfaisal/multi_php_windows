#!/bash/bin
set -x # Aktifkan debug mode

# Menyesuaikan path untuk Windows
PWD=$(cygpath -w "$PWD")

docker network create --driver bridge route

docker build -t route:latest -f ./dockerfile/route.dockerfile .

if [[ $(docker inspect --format='{{.State.Running}}' route) == "true" ]];
then
    docker stop route
fi

if [[ $(docker inspect --format='{{.State.Running}}' route) == "false" ]];
then
    docker rm route
fi

docker run -dit \
    -v "$PWD"/log/route:/var/log/nginx:Z \
    -v "$PWD"/config/route:/etc/nginx/conf.d:Z \
    --restart=always \
    --network=route \
    --name route \
    -p 80:80 \
    route:latest \
    nginx -g 'daemon off;'

docker exec -ti route service nginx restart

docker exec -ti route service php7.4-fpm restart
