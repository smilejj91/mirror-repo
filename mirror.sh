#!/bin/bash

#set -e
set -x

DISTRIBUTION=$1

mkdir -p /var/spool/apt-mirror/public

if [ ${DISTRIBUTION} == "bullseye" ] || [ ${DISTRIBUTION} == "bullseye-updates" ]; then
  wget -qq http://ftp.debian.org/debian/dists/${DISTRIBUTION}/Release
  DATE=`stat Release | grep ^Modify | awk '{print $2}'`
  
  ls /var/spool/apt-mirror/mirror/deb.debian.org/debian/dists | grep ${DISTRIBUTION}-${DATE}
  
  REV=$?
  
  if [ $REV -ne 0 ]; then
cat >/etc/apt/mirror.list<<EOF
  set nthreads 20
  set _tilde 0
  deb-i386 http://deb.debian.org/debian ${DISTRIBUTION} main contrib non-free
  deb-amd64 http://deb.debian.org/debian ${DISTRIBUTION} main contrib non-free
EOF
    
    apt-mirror
    cp -apr /var/spool/apt-mirror/mirror/deb.debian.org/debian/dists/${DISTRIBUTION} /var/spool/apt-mirror/mirror/deb.debian.org/debian/dists/${DISTRIBUTION}-${DATE}
    ln -s /var/spool/apt-mirror/mirror/deb.debian.org/debian  /var/spool/apt-mirror/public/debian
  fi
fi

if [ ${DISTRIBUTION} == "bullseye-security" ]; then
  wget -qq http://security.debian.org/debian-security/dists/${DISTRIBUTION}/Release
  DATE=`stat Release | grep ^Modify | awk '{print $2}'`
  
  ls /var/spool/apt-mirror/mirror/security.debian.org/debian-security/dists | grep ${DISTRIBUTION}-${DATE}
  
  REV=$?
  
  if [ $REV -ne 0 ]; then
cat >/etc/apt/mirror.list<<EOF
  set nthreads 20
  set _tilde 0
  deb-i386 http://security.debian.org/debian-security ${DISTRIBUTION} main contrib non-free
  deb-amd64 http://security.debian.org/debian-security ${DISTRIBUTION} main contrib non-free
EOF
    
    apt-mirror
    cp -apr /var/spool/apt-mirror/mirror/security.debian.org/debian-security/dists/${DISTRIBUTION} /var/spool/apt-mirror/mirror/security.debian.org/debian-security/dists/${DISTRIBUTION}-${DATE}
    ln -s /var/spool/apt-mirror/mirror/security.debian.org/debian-security  /var/spool/apt-mirror/public/debian-security
  fi
fi

if [ ${DISTRIBUTION} == "gooroom-3.0" ]; then
  wget -qq http://update.gooroom.kr/gooroom/dists/${DISTRIBUTION}/Release
  DATE=`stat Release | grep ^Modify | awk '{print $2}'`
  
  ls /var/spool/apt-mirror/mirror/update.gooroom.kr/gooroom/dists | grep "${DISTRIBUTION}-${DATE}"
  
  REV=$?
  
  if [ $REV -ne 0 ]; then
cat >/etc/apt/mirror.list<<EOF
  set nthreads 20
  set _tilde 0
  deb-amd64 http://update.gooroom.kr/gooroom ${DISTRIBUTION} main     
EOF
    
    apt-mirror
    cp -apr /var/spool/apt-mirror/mirror/update.gooroom.kr/gooroom/dists/${DISTRIBUTION} /var/spool/apt-mirror/mirror/update.gooroom.kr/gooroom/dists/${DISTRIBUTION}-${DATE}
    ln -s /var/spool/apt-mirror/mirror/update.gooroom.kr/gooroom  /var/spool/apt-mirror/public/gooroom
  fi
fi

if [ ${DISTRIBUTION} == "tmaxgooroom-3.0-stable" ]; then
  wget -qq http://tos-repo.tmaxos.com/tmax/dists/${DISTRIBUTION}/Release
  DATE=`stat Release | grep ^Modify | awk '{print $2}'`
  
  ls /var/spool/apt-mirror/mirror/tos-repo.tmaxos.com/tmax/dists | grep "${DISTRIBUTION}-${DATE}"
  
  REV=$?
  
  if [ $REV -ne 0 ]; then
cat >/etc/apt/mirror.list<<EOF
  set nthreads 20
  set _tilde 0
  deb-amd64 http://tos-repo.tmaxos.com/tmax ${DISTRIBUTION} main   
EOF
    
    apt-mirror
    cp -apr /var/spool/apt-mirror/mirror/tos-repo.tmaxos.com/tmax/dists/${DISTRIBUTION} /var/spool/apt-mirror/mirror/tos-repo.tmaxos.com/tmax/dists/${DISTRIBUTION}-${DATE}
    ln -s /var/spool/apt-mirror/mirror/tos-repo.tmaxos.com/tmax  /var/spool/apt-mirror/public/tmax
  fi
fi
