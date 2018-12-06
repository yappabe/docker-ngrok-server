#!/bin/bash
set -e

mkdir -p certificate

openssl genrsa -out certificate/rootCA.key 2048
openssl req -x509 -new -nodes -key certificate/rootCA.key -subj "/CN=$DOMAIN" -days 5000 -out certificate/rootCA.pem
openssl genrsa -out certificate/device.key 2048
openssl req -new -key certificate/device.key -subj "/CN=$DOMAIN" -out certificate/device.csr
openssl x509 -req -in certificate/device.csr -CA certificate/rootCA.pem -CAkey certificate/rootCA.key -CAcreateserial -out certificate/device.crt -days 5000
