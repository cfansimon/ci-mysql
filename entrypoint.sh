#!/bin/bash

#set -eo pipefail

sed -i "s/;*datadir\s*=.*/datadir = \/dev\/shm/g" /etc/mysql/my.cnf

mysql_install_db

mysqld

