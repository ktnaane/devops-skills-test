#!/bin/bash

yum install -y yum-utils

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install docker-ce docker-ce-cli containerd.io -y 

systemctl start docker

docker build -t batman:1 . 

if [[ $(docker ps -a --filter "name=^/ALFRED$" --format '{{.Names}}') == ALFRED ]]; then
  docker rm ALFRED; docker run -d -v /var/lib/mysql:/var/lib/mysql -v $(pwd)/BATCAVE:/BATCAVE -p 3307:3307 \
  -e MYSQL_DATABASE=wayneindustries -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --name ALFRED batman:1
else
  docker run -d -v /var/lib/mysql:/var/lib/mysql -v $(pwd)/BATCAVE:/BATCAVE -p 3307:3307 \
  -e MYSQL_DATABASE=wayneindustries -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --name ALFRED batman:1
fi

cat << EOF > init.sql
CREATE TABLE IF NOT EXIST 'fox' (
'ID' int(11) unsigned NOT NULL AUTO_INCREMENT,
 'Name' character varying(255),
 PRIMARY KEY ('id')
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

INSERT INTO fox (ID, Name)
VALUES (50,'BATMOBILE');
EOF

echo 'thisisadatabasepassword123456789!' | base64 > secret

mysqlpw=$(cat secret | base64 -d)
if [[ $(docker ps -a --filter "name=^/ALFRED$" --format '{{.Names}}') == ALFRED ]]; then
  docker rm ALFRED; docker run -d -v /var/lib/mysql:/var/lib/mysql -v $(pwd)/BATCAVE:/BATCAVE -p 3307:3307 \
  -e MYSQL_DATABASE=wayneindustries -e MYSQL_ROOT_PASSWORD=$mysqlpw --name ALFRED batman:1
else
  docker run -d -v /var/lib/mysql:/var/lib/mysql -v $(pwd)/BATCAVE:/BATCAVE -p 3307:3307 \
  -e MYSQL_DATABASE=wayneindustries -e MYSQL_ROOT_PASSWORD=$mysqlpw --name ALFRED batman:1
fi

docker exec -i ALFRED sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < init.sql