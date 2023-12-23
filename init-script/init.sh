#!/bin/bash
set -e

sh /etc/postgresql/init-script/replica_creating.sh
sh /etc/postgresql/init-script/master_backup.sh
sh /etc/postgresql/init-script/init-slave.sh

