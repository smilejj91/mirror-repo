#!/bin/bash

cp gpg/*.gpg /etc/apt/trusted.gpg.d/

cat >/etc/nginx/conf.d/repo.conf<<EOF
server {
  listen 80;
  server_name mirror-repo;
  root /var/spool/apt-mirror/public;

  location / {
    autoindex on;
  }
}
EOF
rm /etc/nginx/sites-enabled/*
service nginx start

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh start

while true
do
  sleep 30
done
