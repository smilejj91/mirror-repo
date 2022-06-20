#!/bin/bash

apt-get install -y cifs-utils smbclient default-jdk

mkdir -p /osqa_smb

cat >>/etc/fstab<<EOF
//192.168.105.119/osqa /osqa_smb/ cifs user=rnd,password=osqa1234,iocharset=utf8 0 0
EOF

mount -a
