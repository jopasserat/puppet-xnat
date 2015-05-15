#!/bin/bash

basedir=$1

mkdir -p ${basedir}/files/etc/ssl/{certs,private}
openssl genrsa -out ${basedir}/ssl/private/xnat.key 1024
openssl req -new -key ${basedir}/ssl/private/xnat.key -out /tmp/xnat.csr -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"
openssl x509 -req -days 3650 -in /tmp/xnat.csr -signkey ${basedir}/ssl/private/xnat.key -out ${basedir}/ssl/certs/xnat.crt
rm /tmp/xnat.csr

