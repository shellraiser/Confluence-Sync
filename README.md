# Confluence_Backup
Two scripts--one for prod and one for dev/staging.

## Dependencies

Do not run under root account.

## Description

These two scripts are placed on corresponding prod and dev/staging servers. The production one shuts down the Confluence service, does a mySQL dump, and then rsyncs over the dump and main directories to a backup directory and then turns the service back on. The directories and dump are then scp-d over to dev/staging. The staging script shuts down the Confluence service, then copies the directories from prod to the corresponding locations. SQL entries are modified to account for staging variables, then the service is turned back on.

## Usage

Run jobs via cronjob. Make sure the prod finishes before you have the dev/staging set to run
