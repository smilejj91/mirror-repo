# b2b-repository setting guide

1. modify Dockerfile

- modify COMPANY_NAME="company"
  ex) ARG COMPANY_NAME="mois"

- modify BASE_DISTRIBUTION="tmax-unstable"
  ex) ARG BASE_DISTRIBUTION="gorani"

2. add ima key

- ima/{company}_privkey_evm.pem
  ex) ima/mois_prvikey_evm.pem

3. add repo key and add gpg file

- gpg/{company}_repo_private.key
  ex) gpg/mois_repo_private.key

- apt/tmax-archive-{base_distrubtion}-release.gpg
  ex) apt/tmax-archive-gorani-release.gpg

4. change docker-compose.yml if you needed

- ex) port

5. exec docker-compose

- $ docker-compose up -d

5. Access jenkins and Setting

- http://{IP Address}:{port}/
  ex) http://localhost:8080/

- insert jenkins/secrets/initialAdminPassword
- install recommend plugin
- make admin account 
-- id / pw : root / tmax123
-- name / email : root / os_infra@tmax.co.kr

- add new node
-- jenkins management -> node management
-- new node (node name : repo)
--- Remote root directory : /root
--- Labels : repo
--- Usage : Use this node as much as possible
--- Launch method : Launch agents via SSH
---- Host : b2b-repository
---- Credentials add
----- Username with password
----- Username : root
----- Password : tmax123
----- ID : root
----- Description : ssh-key
---- Host Key Verification Strategy : Non verifying Verification Strategy
---- apply credentials in drop-down list
--- save
-- relaunch repo node if the node disconnected state

- change master node setting
-- Usage : Only build jobs with label expressions matching this node

6. Setup repository

- if you need to apply IMA sign
-- Init : 0 -> 1 -> 2
-- Update : 1 -> 3

- if you don't need to apply IMA sign, but only mirror
-- Init : 6 -> 7
-- Update : 6

7. Contact Us

- os1_2@tmax.co.kr
