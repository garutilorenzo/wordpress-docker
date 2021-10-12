#!/bin/bash

unset WORDPRESS_UID
unset WORDPRESS_GID
unset WORDPRESS_USER
unset WORDPRESS_GROUP
unset WORDPRESS_VERSION

env_str=$(cat .env | grep ENV)
env_value=${env_str#*=}

uid_str=$(cat .env | grep WORDPRESS_UID)
uid_value=${uid_str#*=}

gid_str=$(cat .env | grep WORDPRESS_GID)
gid_value=${gid_str#*=}

user_str=$(cat .env | grep WORDPRESS_USER)
user_value=${user_str#*=}

group_str=$(cat .env | grep WORDPRESS_GROUP)
group_value=${group_str#*=}

wordpress_version=$(cat .env | grep WORDPRESS_${env_value}_VERSION)
wordpress_value=${wordpress_version#*=}

echo $uid_value
echo $gid_value
echo $user_value
echo $user_value
echo $wordpress_value

export WORDPRESS_VERSION=$wordpress_value
export WORDPRESS_UID=$uid_value
export WORDPRESS_GID=$gid_value
export WORDPRESS_USER=$user_value
export WORDPRESS_GROUP=$user_value

docker-compose -f docker-compose-build.yml build