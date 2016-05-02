#!/bin/bash

echo "Waiting for mysql to come up";
sleep 15;

echo "Starting ebot-server inside screen";
EBOT_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
sed -i "s/127.0.0.1/${EBOT_IP}/g" ${EBOT_HOME}/ebot-csgo/config/config.ini
screen -L -S ebot -dm sh -c 'php ${EBOT_HOME}/ebot-csgo/bootstrap.php';

echo "Waiting for eBot-Server to come up";
sleep 5;

echo "Starting eBot-Server-Web";
cd ${EBOT_HOME_WEB}/ebot-csgo-web;
php symfony configure:database 'mysql:host=ebotmysql_1;dbname=ebotv3' ebotv3 ebotv3;
php symfony doctrine:insert-sql;
php symfony guard:create-user --is-super-admin admin@ebot admin password ;
php symfony cc ;
rm -rf ${EBOT_HOME_WEB}/ebot-csgo-web/web/installation ;
screen -L -S ebot-web -dm sh -c 'apachectl -d /etc/apache2 -f /etc/apache2/apache2.conf -e debug -DFOREGROUND;';

echo "Starting CS:GO-Server";
cd ${CSGO_HOME};
./steamcmd.sh +login anonymous +force_install_dir /home/csgo/strike/ +app_update 740 validate +quit

cd ${CSGO_HOME}/strike/
./srcds_run -game csgo -console -usercon -ip 0.0.0.0 -tickrate 128


