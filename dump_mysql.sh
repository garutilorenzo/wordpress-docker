#!/bin/bash

db_host_string=$(cat .env | grep WORDPRESS_DB_HOST)
db_host=${db_host_string#*=}

db_root_string=$(cat .env | grep MYSQL_ROOT_PASSWORD)
root_pw=${db_root_string#*=}

db_name_string=$(cat .env | grep WORDPRESS_DB_NAME)
db_name=${db_name_string#*=}

mysql_path_string=$(cat .env | grep MYSQL_DUMP_DIR)
mysql_path=${mysql_path_string#*=}

dump_name=${mysql_path}/${db_name}.`date +%Y%m%d%H%M%S`.gz
docker-compose exec ${db_host}  /usr/bin/mysqldump --single-transaction --no-tablespaces --skip-lock-tables -u root -p${root_pw} ${db_name}  | gzip -9 > ${dump_name}
