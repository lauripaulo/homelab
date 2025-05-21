#!/bin/sh
#
# check if docker is running
if ! (docker ps >/dev/null 2>&1)
then
	echo "docker daemon not running, will exit here!"
	exit
fi
echo "Preparing folder init and creating /DATA/guacamole/init/initdb.sql"
mkdir /DATA/guacamole/init >/dev/null 2>&1
mkdir -p /DATA/guacamole/nginx/ssl >/dev/null 2>&1
chmod -R +x /DATA/guacamole/init
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > /DATA/guacamole/init/initdb.sql
echo "done"
echo "Preparing folder record and set permissions"
mkdir /DATA/guacamole/record >/dev/null 2>&1
chmod -R 777 /DATA/guacamole/record
mkdir /DATA/guacamole/data >/dev/null 2>&1
mkdir /DATA/guacamole/drive >/dev/null 2>&1
echo "done"
echo "Creating SSL certificates"
openssl req -nodes -newkey rsa:2048 -new -x509 -keyout nginx/ssl/self-ssl.key -out nginx/ssl/self.cert -subj '/C=DE/ST=BY/L=Hintertupfing/O=Dorfwirt/OU=Theke/CN=www.createyourown.domain/emailAddress=docker@createyourown.domain'
echo "You can use your own certificates by placing the private key in nginx/ssl/self-ssl.key and the cert in nginx/ssl/self.cert"
echo "done"
