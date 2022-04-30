A template for a common Docker Symfony stack, allowing multiple projects (`xxx.local => www/xxx/public/index.php`) and provides all common php extensions.

# TEMPLATE Docker Stack

Provides a local development environment for the TEMPLATE and its required projects.

Based on: <https://github.com/maxpou/docker-symfony>

Each project provides its own Docker container

## Technology Stack

 - PHP X.X
 - XDebug (activate via "WITH_XDEBUG=true" inside dotenv)
 - MariaDB X.X
 - nodejs / gulp / yarn / webpack
 - Mailcatcher for local mailing
 - local SSH Key injecting
 
## Mountpoints
 
 - `.data` For general storage eg: database
 - `www/<project-name>` Webserver root for projects (you can just add more by adding container in same Symfony structure) 
 - `install.sh` and `update.sh` for all projects inside container to build and update maintenance 

## Exposed Ports
 
 You can access container application directly via localhost
 
 - Webserver: 80 (http only)
 - MySql / MariaDB: 3306 (User: "root"; Password: "admin")
 - Mailcatcher: 1080 (<http://127.0.0.1:1080>)
 
## Mac User

For Mac users it's important to not use the Docker provided by the Homebrew package installer. If you do so, you will probably run into problems with "WARNING: Connection pool is full, discarding connection" warnings. Using the "original" Docker install package from [docker.com](https://www.docker.com) will solve problems like that.

## Manual Installation

1. Create a `.env` from the `.env.dist` file. Adapt it according to your symfony application

    ```bash
    cp .env.dist .env
    ```
    
    * For Windows you must also provide a PWD variable with the project dir in `.env` see documentation inside file, if you are not taking the nfs mount stuff opt of "Optimizations" section

2. Update your system host file

    ```bash
    127.0.0.1 TEMPLATE.local
    ```

3. Inject SSH storage

    If you need access to ssh key related stuff have valid ssh key inside local folder: `~/.ssh/id_rsa`
    
    Docker secret features is taken: https://docs.docker.com/compose/compose-file/#secrets
   
4. Build/run containers

    ```bash
   docker-compose build
    
   # Run visible; eh good for first run to see output
   docker-compose up
    
   # Run in background
   # docker-compose up -d
    ```

5. Prepare Projects
    1. Install projects via build container

        ```bash
        docker-compose run --rm php-cli bash -c "/var/install.sh"
       
        # or via make
        make install
        ```
 
    2. Create the databases
    
        Boot up the stack if not already done
    
        ```
        docker-compose up -d
        ```
       
        Create database
        
        ```
        docker-compose exec db bash -c "mysql -u root -padmin -e 'create database TEMPLATE'"
        ```
       
    3. Check project
        
        The `www` contains all projects and nginx just you any subfolder you provide as subdomain `TEMPLATE` => `TEMPLATE.local`.
    
6. Enjoy
  
    Open browser with: <http://TEMPLATE.local>


# Project Tasks

`make` is used for several regular scripts task.

## Updating

Update includes

 - checkout develop branch
 - composer install
 - build frontend

```
make update
```
        
## Optimizations

### Mounting NFS filesystem to speed up file access

For speeding up the file access for non Linux user you can use for example an NFS server mount via provided scripts.
Depending on your OS change `NFS_MOUNT_WWW` the variable inside `.env` for the project `www` folder

#### MacOS 

`NFS_MOUNT_WWW` must be absolute and inside the Users folder structure. Execute the bash file to configure the nfs server
    
    ```bash
    ./nfs_macos.sh
    ```
   
#### Windows 

 - Set `NFS_MOUNT_WWW` to /www
 - <https://github.com/winnfsd/winnfsd/releases> download latest version and put this into the folder `winnfsd`.
 - Force the `winnfsd.exe` to execute as admin user via the Windows Configuration tab. (right click the file and go to Security)
 - Run the follong script inside a cmd window
 
    ```bash
    nfs_windows.bat
    ```
    
#### Run with NFS mount 

Run docker-compose up using the nfs configuration file

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.nfs.yml up -d
    ```    

To make this persisted you can also just copy `docker-compose.nfs.yml` to `docker-compose.override.yml`

## FAQ

* Permission problem? (docker: Got permission denied while trying to connect to the Docker daemon socket at)

```
sudo groupadd docker
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker $USER
# restart / relogin 
```

else:

 - https://docs.docker.com/engine/install/linux-postinstall/ 
 - See [this doc (Setting up Permission)](http://symfony.com/doc/current/book/installation.html#checking-symfony-application-configuration-and-setup)

* How to config Xdebug?

Xdebug is configured out of the box!
Just config your IDE to connect port  `9001` and id key `PHPSTORM`

-------------

# Origin README

See also some main project: <https://github.com/maxpou/docker-symfony>