#!/bin/bash

docker_registry=''

env_str=$(cat .env | grep ENV)
env_value=${env_str#*=}

wordpress_image_name=$(cat .env | grep CUSTOM_WORDPRESS_IMAGE)
wordpress_image_name_value=${wordpress_image_name#*=}

wordpress_image_version=$(cat .env | grep WORDPRESS_${env_value}_VERSION)
wordpress_image_value=${wordpress_image_version#*=}

if [ -z "$docker_registry" ]; then
    # Docker hub
    DOCKER_REGISTRY_PATH="${wordpress_image_name_value}:${wordpress_image_value}"
else
    DOCKER_REGISTRY_PATH="${docker_registry}/${wordpress_image_name_value}:${wordpress_image_value}"
fi

echo $DOCKER_REGISTRY_PATH
docker push $DOCKER_REGISTRY_PATH