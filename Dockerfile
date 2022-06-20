FROM debian:latest

WORKDIR /app

ADD gpg /app/gpg
ADD init.sh /app/init.sh

RUN apt-get update 
RUN apt-get upgrade -y
RUN apt-get install -y gpg nginx vim unzip zip apt-utils sshpass rename lz4 wget apt-mirror xz-utils

RUN apt-get install -y ssh
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

RUN apt-get install -y openjdk-11-jdk
RUN echo "root:tmax123" | chpasswd

EXPOSE 22

CMD ["bash", "init.sh"]
