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
