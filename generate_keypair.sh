#!/bin/bash

mkdir -p files/etc/ssl/{certs,private}
openssl genrsa -out files/etc/ssl/private/xnat.key 1024
openssl req -new -key files/etc/ssl/private/xnat.key -out /tmp/xnat.csr -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"
openssl x509 -req -days 3650 -in /tmp/xnat.csr -signkey files/etc/ssl/private/xnat.key -out files/etc/ssl/certs/xnat.crt
#rm /tmp/xnat.csr

