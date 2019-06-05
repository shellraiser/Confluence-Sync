#!/bin/bash

#Create necessary directories if they don't exist
mkdir -p /opt/confluence_tasks/BACKUP/conf_install/
mkdir -p /opt/confluence_tasks/BACKUP/conf_home/
mkdir -p /opt/confluence_tasks/BACKUP/conf_sql/

#Parameters for directories
conf_install=/opt/atlassian/confluence
conf_home=/var/atlassian/application-data/confluence
conf_install_backup=/opt/confluence_tasks/BACKUP/conf_install/`date +%Y%m%d-%H%M%S`
conf_home_backup=/opt/confluence_tasks/BACKUP/conf_home/`date +%Y%m%d-%H%M%S`
conf_sql_backup=/opt/confluence_tasks/BACKUP/conf_sql/`date +%Y%m%d-%H%M%S`

#Create the dated subdirectories
mkdir $conf_install_backup
mkdir $conf_home_backup
mkdir $conf_sql_backup

#Delete older directories
sudo find /opt/confluence_tasks/BACKUP/conf_install/ -type d -ctime +1 -exec rm -rf {} \;
sudo find /opt/confluence_tasks/BACKUP/conf_home/ -type d -ctime +1 -exec rm -rf {} \;
sudo find /opt/confluence_tasks/BACKUP/conf_sql/ -type d -ctime +1 -exec rm -rf {} \;

#Point backup directories to new folders
conf_install_backup=$(ls -td /opt/confluence_tasks/BACKUP/conf_install/* | head -1)
conf_home_backup=$(ls -td /opt/confluence_tasks/BACKUP/conf_home/* | head -1)
conf_sql_backup=$(ls -td /opt/confluence_tasks/BACKUP/conf_sql/* | head -1)

#Stop Confluence service
sudo /opt/atlassian/confluence/bin/stop-confluence.sh

#Perform mySQL dump to backup location. Enter mySQL pw here
mysqldump --user=confluenceuser --password=password --lock-tables --databases confluence > $conf_sql_backup/confluence.sql

#Copy data from install and home directories to backup locations
sudo rsync -av --exclude=backups $conf_home $conf_home_backup
sudo rsync -av --exclude=backups $conf_install $conf_install_backup

#Start Confluence service
sudo /opt/atlassian/confluence/bin/start-confluence.sh

#Copy data from PROD to DEV/STAGING. Enter in your own environment values here. Make sure the folders already exist on your staging/dev server. Setup an SSL key to do this, so no password is needed.
sudo rsync -av $conf_home_backup user@confluence-dev.pawsch.net:/opt/confluence_tasks/UPDATE/conf_home/
sudo rsync -av $conf_install_backup user@confluence-dev.pawsch.net:/opt/confluence_tasks/UPDATE/conf_install/
sudo rsync -av $conf_sql_backup user@confluence-dev.pawsch.net:/opt/confluence_tasks/UPDATE/conf_sql/
