#!/bin/bash
set -e

sh /etc/postgresql/init-script/creating_replica_usr.sh
sh /etc/postgresql/init-script/master_backup.sh
sh /etc/postgresql/init-script/init-slave.sh
