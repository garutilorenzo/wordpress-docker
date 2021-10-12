#!/bin/bash
if [ /etc/alpine-release ]; then
    addgroup --gid ${WORDPRESS_GID} ${WORDPRESS_GROUP} && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home /var/www/html \
    --ingroup ${WORDPRESS_GROUP} \
    --no-create-home \
    --uid ${WORDPRESS_UID} \
    ${WORDPRESS_USER} && \
    addgroup ${WORDPRESS_USER} www-data
else
    groupadd -g ${WORDPRESS_GID} ${WORDPRESS_GROUP} && useradd -u ${WORDPRESS_UID} -g ${WORDPRESS_GID} -m -d /var/www/html -s /bin/bash ${WORDPRESS_USER} && usermod -a -G www-data ${WORDPRESS_USER}
fi