#!/bin/bash

#Clean previous logs
sudo truncate -s 0 /opt/confluence-sync/LOG/confluence-sync.log

#Parameters for directories
conf_install=/opt/atlassian
conf_home=/var/atlassian/application-data
conf_install_update=$(ls -td /opt/confluence-sync/UPDATE/conf_install/* | head -1)
conf_home_update=$(ls -td /opt/confluence-sync/UPDATE/conf_home/* | head -1)
conf_sql_update=$(ls -td /opt/confluence-sync/UPDATE/conf_sql/* | head -1)

#Stop Confluence service
sudo /opt/atlassian/confluence/bin/stop-confluence.sh

#Copy data from UPDATE folder to conf_install and conf_home
sudo cp -rf $conf_install_update/confluence $conf_install
sudo cp -rf $conf_home_update/confluence $conf_home

#Copy configs to conf_home and conf_install
sudo rsync /opt/confluence-sync/confluence.cfg.xml $conf_home/confluence
sudo rsync /opt/confluence-sync/server.xml $conf_install/confluence/conf/

#Fix permissions
sudo chmod -R 755 $conf_install
sudo chmod -R 755 $conf_home
sudo chown -R confluence:confluence $conf_install
sudo chown -R confluence:confluence $conf_home

#Perform mySQL upload from dump
mysql confluence < $conf_sql_update/confluence.sql

#Delete update directories
sudo rm -rf $conf_install_update
sudo rm -rf $conf_home_update
sudo rm -rf $conf_sql_update

###
#This configures the site URL and title. You can configure mysql to not ask for pw in a script---just google it.
#You will need to add lines to edit the database to input the dev licenses so it's not using any 
#prod licenses. I also suggest you edit the database to alter the color scheme for your dev/staging server so it's easy 
#to identify that you are looking at a non-production Confluence site.


#Change the base URL and Site Title (replace URL and Title values to match your own environment):
mysql confluence -e "update BANDANA SET BANDANAVALUE = REPLACE(BANDANAVALUE, 'https://confluence.pawsch.net', 'https://confluence-dev.pawsch.net') where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';"
mysql confluence -e "update BANDANA SET BANDANAVALUE = REPLACE(BANDANAVALUE, 'Confluence', 'Confluence - Dev') where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';"

###

#Reload MySQL service
sudo /etc/init.d/mysql reload

#Start Confluence service
sudo /opt/atlassian/confluence/bin/start-confluence.sh

#Wait for site to come up before reindexing
sleep 2m

#Reindex. Enter in the Confluence site admin username and password below
curl -u username:'password' -X POST -H "X-Atlassian-Token: nocheck" http://localhost:8899/rest/prototype/1/index/reindex
