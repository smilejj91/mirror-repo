#!/bin/bash

DISTRIBUTION=$1
PACKAGE_NAME=$2
COMPONENT="main"

cat >/etc/apt/sources.list.d/temp.list<<EOF
deb-src http://b2b-repo.tmaxos.net/tmax ${DISTRIBUTION} ${COMPONENT}
EOF

apt-get update
apt-get source -t=${DISTRIBUTION} ${PACKAGE_NAME}
