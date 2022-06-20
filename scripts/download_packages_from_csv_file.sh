#!/bin/bash

# .csv format : package-name,A-version,A-maintainer,B-version,B-maintainer

BUSINESSNAME=$1

BEFORE="before"
AFTER="after"

cat >/etc/apt/sources.list.d/temp.list<<EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://update.gooroom.kr/gooroom gooroom-3.0 main
deb http://tos-repo.tmaxos.com/tmax tmaxgooroom-3.0-stable main
deb http://tos-repo.tmaxos.com/tmax tmaxgooroom-3.0-updates main
deb http://b2b-repo.tmaxos.net/tmax tmaxgooroom-${BUSINESSNAME}-stable main
EOF

cat >/etc/apt/preference.d/temp.pref<<EOF
Package: *
Pin: release a=tmaxgooroom-${BUSINESSNAME}-stable
Pin-Priority: 1002

Package: *
Pin: release a=tmaxgooroom-3.0-updates
Pin-Priority: 1001

Package: *
Pin: release a=tmaxgooroom-3.0-stable
Pin-Priority: 1001

Package: *
Pin: release o=Gooroom
Pin-Priority: 900

Package: *
Pin: release o=Debian
Pin-Priority: 500

Package: linux-image*
Pin: release o=Debian
Pin-Priority: -1

Package: linux-image*
Pin: release o=Gooroom
Pin-Priority: -1
EOF

apt-get update

while read line || [ -n "$line" ]; do
  PACKAGE_NAME=`echo "$line" | cut -d ',' -f 1`
  A_VERSION=`echo "$line" | cut -d ',' -f 2`
  B_VERSION=`echo "$line" | cut -d ',' -f 4`

  if [ ! -z ${A_VERSION} ]; then
    echo "${PACKAGE_NAME}=${A_VERSION}" >> ${BEFORE}.txt
  fi
  
  if [ ! -z ${B_VERSION} ]; then
    DISTRIBUTION=`apt show "${PACKAGE_NAME}=${B_VERSION}" | grep APT-Sources | awk '{print $3}'`
    if [ ! -z ${DISTRIBUTION} ]; then
      echo "${PACKAGE_NAME}=${B_VERSION}" >> ${AFTER}.txt
      
      mkdir -p ${DISTRIBUTION}
      apt-get -qq download ${PACKAGE_NAME}=${B_VERSION}
      rename 's/%3a/:/g' *
      mv *.deb ${DISTRIBUTION}
    else
      echo "#${PACKAGE_NAME}=${B_VERSION} # cannot find package" >> ${AFTER}.txt
    fi     
  fi 
done < diff.csv

rm /etc/apt/sources.list.d/temp.list
rm /etc/apt/preference.d/temp.pref
apt-get update
