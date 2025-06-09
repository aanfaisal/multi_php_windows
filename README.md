1. Buat folder project didalam folder app
2. Jalankan command build route
    
    ```bash
    bash route.sh
    ```
    
3. Jalankan command build container
    
    ```bash
    bash build.sh -n {$APP_NAME} -v {$PHP_VERSION} -d {$DIR} 
    ```
    
    - jalankan build.sh
    - -n = app name
    - -v = php version
    - -d = directory root ( /public )
4. Edit file host, dan tambah domail app.local
    
    ```bash
    code C:\Windows\System32\drivers\etc\hosts
    ```
    
    ```bash
    127.0.0.1 localhost app.local
    ```
    
5. restart container route 
    
    ```bash
    docker restart route
    ```
    
6. Start container app
    
    ```bash
    docker start app
    ```

7. Install MySQL and Postgres
    ```bash
    docker run --name mysql -t -e MYSQL_DATABASE="docker_db" -e MYSQL_USER="admin" -e MYSQL_PASSWORD="YOURPASSWORD" -e MYSQL_ROOT_PASSWORD="YOURPASSWORD" -p 3306:3306 -d mariadb --character-set-server=utf8 --collation-server=utf8_bin --default-authentication-plugin=mysql_native_password
    ```
    ```bash
    docker run -d --name mypostgres -p 5432:5432 -e POSTGRES_PASSWORD=YOURPASSWORD postgres
    ```

8. Make network and connect it

    ```bash
    docker network create --driver bridge db

    docker network connect db mysql
    
    docker network connect db route

    docker network connect db app1
    ```

