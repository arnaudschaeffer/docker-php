#!/bin/bash
# Apache VirtualHost Template with variable replacement

serverName=${SERVER_NAME:-symfony.local}
serverAlias=${SERVER_ALIAS:-www.symfony.local}

set -x

cp /etc/apache2/sites-enabled/symfony.conf /symfony.conf
sed -i -e "s/{SERVER_NAME}/$serverName/g" -e "s/{SERVER_ALIAS}/$serverAlias/g" /symfony.conf
cp -f /symfony.conf /etc/apache2/sites-enabled/symfony.conf