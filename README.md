# wordpress-docker

[![Wordpress CI](https://github.com/garutilorenzo/wordpress-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/garutilorenzo/wordpress-docker/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/garutilorenzo/wordpress-docker)](https://github.com/garutilorenzo/wordpress-docker/issues)
![GitHub](https://img.shields.io/github/license/garutilorenzo/wordpress-docker)
[![GitHub forks](https://img.shields.io/github/forks/garutilorenzo/wordpress-docker)](https://github.com/garutilorenzo/wordpress-docker/network)
[![GitHub stars](https://img.shields.io/github/stars/garutilorenzo/wordpress-docker)](https://github.com/garutilorenzo/wordpress-docker/stargazers)

# Table of Contents

* [Requirements](#requirements)
* [Environment setup](#environment-setup)
* [Use the environment](#use-the-environment)
* [Import an existing WP site](#import-an-existing-wp-site)
* [WP Cli](#wp-cli)
* [Fix permission problem](#fix-permission-problem)
* [Nginx](#nginx)
* [SSL](#ssl)
  * [Certbot/Let's encrypt](#certbotlets-encrypt)
  * [Owned SSL certificates](#owned-ssl-certificates)
* [PhpMyAdmin](#phpmyadmin)
* [MySQL dump](#mysql-dump)

### Requirements

To use this environment you need [Docker](https://docs.docker.com/get-docker/) an [Docker compose](https://docs.docker.com/compose/install/) installed.

### Environment setup

You can find all the settings in the *.env* file in the root folder of this repository. The default settings are:

| Label   | Required | Default | Description |
| ------- | -------- | ------- | ----------- |
| `ENV` | `yes` | `PROD`      | Valid values are: PROD or DEV. Changing this varialbe the environment will use a different WP image. In DEV environment is used the docker image with embadded Apache, in prod env is used the php-fpm docker image  |
| `WORDPRESS_IMAGE` | `yes`  | `wordpress`    | The [default](https://hub.docker.com/_/wordpress) docker image to use. |
| `WORDPRESS_PROD_VERSION` | `yes`  | `php7.4-fpm`     | Production docker image version (php-fpm)|
| `WORDPRESS_DEV_VERSION` | `yes`  | `php7.4`     | Development docker image version (embadded apache) |
| `WORDPRESS_CLI_VERSION` | `yes`  | `cli-php7.4`     | WP client docker image version |
| `WORDPRESS_DB_NAME` | `no`  | `wordpress`     | WP database name |
| `WORDPRESS_TABLE_PREFIX` | `no`  | `wp_`     | WP mysql table prefix |
| `WORDPRESS_DB_HOST` | `no`  | `myslq`     | MySQL container name |
| `WORDPRESS_DB_USER` | `no`  | `wordpress`     | MySQL WP user  |
| `WORDPRESS_DB_PASSWORD` | `no`  | `password`     | MySQL WP user |
| `MARIADB_VERSION` | `no`  | `latest`     | MariaDB container version |
| `MYSQL_ROOT_PASSWORD` | `no`  | `s3cretPassW0rd`     | Development docker image version (embadded apache) |
| `MYSQL_DATA_DIR` | `no`  | `./wordpress-sql`     | Local path for MySQL backup/restore |
| `MYSQL_DUMP_DIR` | `no`  | `./mysql-dumps`     | Local where dump_mysql.sh store the MySQL dumps |
| `NGINX_VERSION` | `no`  | `latest`     | Nginx  container version |
| `SERVER_NAME` | `yes` | `example.com`      | Second level domain name (Example: example.com)  |
| `SERVER_ALT_NAME` | `yes`  | `www.example.com`    | Third level domain name (Example: www.example.com) |
| `WP_CONTAINER_NAME` | `yes`  | `wordpress`     | WP container name (defined in docker-compose.yml) |
| `SECURE_SUBNET` | `no`  | `192.168.0.0/16`     | Secure subnet to allow traffic to wp-admin, wp-login.php and xmlrpc.php  |
| `NGINX_CONF_DIR` | `no`  | `./config/nginx/cfg/`     | Nginx custom configuration path |
| `NGINX_TEMPLATE_DIR` | `no`  | `./config/nginx/tpl/`     | Nginx template configuration path |
| `WORDPRESS_UID` | `no`  | `1000`     | UID of the user running docker |
| `WORDPRESS_GID` | `no`  | `1000`     | GID of the user running docker |
| `WORDPRESS_USER` | `no`  | `app`     | Username used inside the WP docer container |
| `WORDPRESS_GROUP` | `no`  | `app`     | Group assigned to WORDPRESS_USER |
| `CUSTOM_WORDPRESS_IMAGE` | `no`  | `my-wordpress`     | WP custom docker image name |

### Use the environment

#### Development

If you would like to use this environment for local test or if you are developing a new plugin or theme you have to use the develompment version. To use this version create a symlink from docker-compose-dev.yml to docker-compose.yml

```
ln -s docker-compose-dev.yml docker-compose.yml
```

and change in the .env file the ENV value to DEV:

```
ENV=DEV
```

you can now start the environment with:

```
docker compose up -d
```

you can check the logs with:

```
docker compose logs -f
```

Now you have:

* wordpress listening on port 80 (with embadded Apache). Access your wordpress on http://localhost
* PhpMyAdmin listening on port 8080. Access PMA on http://localhost:8080 (see PhpMyAdmin section)
* MySQL running but is not listening on any interface
* Wordpress CLI container available (see WP Cli section)

If you are developing a new theme or plugin is possible that you're facing a permission problem, if you check the files permission under wordpress-src you see that the files are owned by www-data:

```
drwxr-xr-x  5 www-data www-data  4096 Oct 12 15:34 wordpress-src
```

To fix this issue see the "Fix permission problem" section

#### Production

If you are ready to spin up a production environment simply create a symlink from docker-compose-prod.yml to docker-compose.yml:

```
ln -s docker-compose-prod.yml docker-compose.yml
```

and check in the .env file that the ENV variable is set to PROD:

```
ENV=PROD
```

On production environment you have to configure also nginx. To do so, check the environment variables attached to the nginx container.

The environment variables are:

* SERVER_NAME: Second level domain name (Example: example.com)
* SERVER_ALT_NAME: Third level domain name (Example: www.example.com)
* WP_CONTAINER_NAME: WP container name (defined in docker-compose.yml)
* SECURE_SUBNET: Secure subnet to allow traffic to wp-admin, wp-login.php and xmlrpc.php (Default 192.168.0.0/16)

you can now start the environment with:

```
docker compose up -d
```

you can check the logs with:

```
docker compose logs -f
```

Now you have:

* nginx listening on ports 80 and 443 (optional). (see nignx section)
* wordpress running with php-fpm container
* PhpMyAdmin running, traffic to PhpMyAdmin is filtered by nginx (see PhpMyAdmin section)
* MySQL running but is not listening on any interface
* Wordpress CLI container available (see WP Cli section)

### Import an existing WP site

If you have a running WP site and you want to use this environment you have to extract your existing sources in *wordpress-src* directory and the MySQL dump in *wordpress-sql* directory.

**NOTE** before spin up the environment, check wordpress-src directory permission. If you have build a [custom image](#fix-permission-problem) remember to:

```
chown -R uid:gid wordpress-src/
```

if you use the standard wordpress image all files and directory must be owned by user and group (www-data). Your system might be have a different uid and git for the www-data user and group (or you might don't have this user and group), so to fix the permission problem use the uid and gid directly:

```
chown -R 33:33 wordpress-src/
```

**MySQL NOTE** dump can be in plain text or gzipped. The extension must be *.sql or *.gz

**MySQL NOTE2** dump will be restored only on the first startup. If you want to restore a new dump you have to:

* stop mysql container (docker-compose stop mysql)
* remove the mysql volume (docker volume rm wordpress-docker_mysql). **Tip** you can find the volume name with: *docker volume ls.*
* place the new dump in wordpress-sql
* start the container (docker-compose up -d)

### WP Cli

Check the Wordpress Client referenche [here](https://developer.wordpress.org/cli/commands/)

To use the wordpress CLI use for example:

```
docker-compose run --rm wordpress-cli wp core install --url=http://localhost --title=test --admin_user=admin --admin_email=test@example.com
Creating wordpress-docker_wordpress-cli_run ... done
Admin password: &kWu5@BldBHixvvaim
Warning: Unable to create directory wp-content/uploads/2021/10. Is its parent directory writable by the server?
Success: WordPress installed successfully.
```

### Fix permission problem

To fix the permission problem the solution is to build a custom image. This image will then run all the processes inside the container with a user with a user with the same uid and gid of your local computer's user.

First we need to check our uid and gid (use the *id* command):

```
id

uid=1000(your-local-user) gid=1000(your-local-group) groups=1000(your-local-group),4(adm),24(cdrom),27(sudo)
```

then in the .env file adjust the variables:

* WORDPRESS_UID
* WORDPRESS_GID

with your uid and gid. Now we can build our custom image:

```
bash build.sh
```

this will produce two new images, one for wordpress (my-wordpress:php7.4) and one for the wordpress cli (my-wordpress:cli-php7.4). A sample output will be:

```
Step 4/10 : ARG WORDPRESS_UID
 ---> Using cache
 ---> 7eb312bf432b
Step 5/10 : ARG WORDPRESS_GID
 ---> Using cache
 ---> 917ace616147
Step 6/10 : ARG WORDPRESS_USER
 ---> Using cache
 ---> aad8c3c33e3a
Step 7/10 : ARG WORDPRESS_GROUP
 ---> Using cache
 ---> 14248a4f8db9
Step 8/10 : COPY ./adduser.sh /
 ---> Using cache
 ---> 255a4a665ac6
Step 9/10 : RUN /adduser.sh && rm -rf /adduser.sh
 ---> Using cache
 ---> 8e84c8cce8b2
Step 10/10 : USER ${WORDPRESS_USER}
 ---> Using cache
 ---> d36fbaf33c9e
Successfully built d36fbaf33c9e
Successfully tagged my-wordpress:cli-php7.4
```

Now to use this new image you have to change the WORDPRESS_IMAGE in the .env file:

```
WORDPRESS_IMAGE=my-wordpress
```

Now stop the environment, fix wordpress-src directory permission and bring up the environment with the new image:

```
docker-compose down
sudo chown -R your-local-user:your-local-group wordpress-src
[sudo] password for your-local-user:

docker-compose up -d
```

**NOTE** you can change the custom image name by editing the .env file and change the CUSTOM_WORDPRESS_IMAGE variable.

### Nginx

By default Nginx will expose only the http port (port 80). The default configuration is config/nginx/tpl/nginx-http.conf.template. This template will be rendered on every nginx startup. For more information the nignx documentation is available [here](https://hub.docker.com/_/nginx)

By default this template use many security enhancements, removing access to many WP paths and files. You can find the configurations under: config/nginx/cfg/

To disable this security enhancements edit the config/nginx/tpl/nginx-http.conf.template and comment or delete the lines:

```
# Security
include /etc/nginx/custom.conf.d/nginx-custom-configs.conf;
include /etc/nginx/custom.conf.d/nginx-wp-hardening.conf;
```

In the default template the following locations are protected:

* /pma/ (PhpMyAdmin)
* /xmlrpc.php
* /wp-admin/
* wp-login.php

The traffic to this location is filtered by the SECURE_SUBNET environment variable (Default 192.168.0.0/16). Only the client in this subnet will be able to access this locations.

To disable this filter edit the config/nginx/tpl/nginx-http.conf.template file and comment or delete this lines:

```
allow ${SECURE_SUBNET};
allow 127.0.0.1; 
deny all;
```

### SSL

A configuration example is placed on config/nginx/tpl/nginx-https.conf.example to enable SSL rename this file with the .template extension.

**Note** remember to delete or rename the nginx-http.conf.template

#### Certbot/Let's encrypt

Uncomment certbot service in docker-compose.yml

If you have to create a new SSL certificate, modify init_letsencrypt.sh with your domain(s) name(s) and change the email variable.
Require the new certificate with:

```console
bash init_letsencrypt.sh
```

for nginx auto reload, uncomment the *command* on the nginx service. This is necessary for auto reload nginx when certot renew the ssl certificates.

Now restart nginx and certbot:

```console
docker-compose up -d
```

#### Owned SSL certificates

If you have your own SSL certificate modifiy config/nginx/tpl/nginx-https.conf.example and adjust the nginx volumes in docker-compose.yml.

**Note** remember to rename config/nginx/tpl/nginx-http.conf.example file with the .template extension.

You can now start the services with:

```console
docker-compose up -d
```

### PhpMyAdmin

The default username is root, and the password is the value of MYSQL_ROOT_PASSWORD in the .env file

#### Development

You can access phpMyAdmin at http://127.0.0.1:8080 

#### Production

You can access phpMyAdmin at http://example.com/pma (access filtered by ip)


### MySQL dump

To dump the current MySQL state you can use the dump.sh file. The dump will be saved in mysql-dumps directory (you can customize the dump directory in the .env file)

```
bash dump_mysql.sh 
ls -la mysql-dumps/

-rw-rw-r--  1 lorenzo lorenzo    473 Oct 18 12:21 wordpress.20211018122109.gz
-rw-rw-r--  1 lorenzo lorenzo 299673 Oct 18 12:22 wordpress.20211018122247.gz
```
