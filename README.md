# Confluence-Sync
Two scripts--one for prod and one for dev/staging.

## Dependencies

Do not run under root account.

## Description

These two scripts are placed on corresponding prod and dev/staging servers. The production one shuts down the Confluence service, does a mySQL dump, and then rsyncs over the dump and main directories to a backup directory and then turns the service back on. The directories and dump are then scp-d over to dev/staging. The staging script shuts down the Confluence service, then copies the directories from prod to the corresponding locations. SQL entries are modified to account for staging variables, then the service is turned back on.

## Usage

Run jobs via cronjob. Make sure the prod finishes before you have the dev/staging set to run

For example, this is what my crontab looks like for prod:
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

0 1 * * * /opt/confluence_tasks/confluence-prod.sh >> /opt/confluence-sync/LOG/confluence_tasks.log 2>&1


And this is what I run on the staging/dev server:
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

0 4 * * * /opt/confluence_tasks/confluence-staging.sh >> /opt/confluence-sync/LOG/confluence_tasks.log 2>&1
