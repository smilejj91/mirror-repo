#!/bin/bash

SOURCE_DISTRO=$1
SOURCE_PACKAGES=$2
COMPONENT="main"

cat >/etc/apt/sources.list.d/temp.list<<EOF
deb http://b2b-repo.tmaxos.net/tmax ${SOURCE_DISTRO} ${COMPONENT}
EOF

apt-get update

SOURCE_PACKAGES=`echo ${SOURCE_PACKAGES} | sed 's/,/\n/g'`

mkdir -p ${SOURCE_DISTRO}-${COMPONENT}
cd ${SOURCE_DISTRO}-${COMPONENT}

echo ${SOURCE_PACKAGES} > package-list.txt

while read line || [ -n "$line" ]; do
  apt-get download -t=${SOURCE_DISTRO} $line
done < package-list.txt

rename 's/%3a/:/g' *

rm /etc/apt/sources.list.d/temp.list
apt-get update
