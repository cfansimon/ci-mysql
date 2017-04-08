#!/bin/bash

#set -eo pipefail
#
sed -i "s/;*datadir\s*=.*/datadir = \/dev\/shm/g" /etc/mysql/my.cnf
sed -i "s/#*bind-address/#bind-address/g" /etc/mysql/my.cnf

_get_config() {
	local conf="$1"; shift
	mysqld --verbose --help 2>/dev/null | awk '$1 == "'"$conf"'" { print $2; exit }'
}

echo 'Initializing database'
mysql_install_db
echo 'Database initialized'

SOCKET="$(_get_config 'socket')"

mysqld --skip-networking --socket="${SOCKET}" &
pid="$!"

echo "pid: ${pid}"

mysql=( mysql --protocol=socket -uroot -hlocalhost --socket="${SOCKET}" )

for i in {30..0}; do
	if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
		break
	fi
	echo 'MySQL init process in progress...'
	sleep 1
done
if [ "$i" = 0 ]; then
	echo >&2 'MySQL init process failed.'
	exit 1
fi

if [ "$MYSQL_DATABASE" ]; then
	echo "Database ${MYSQL_DATABASE} creating..."
	echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
fi

"${mysql[@]}" <<-EOSQL
	CREATE USER 'root'@'%';
	GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
	FLUSH PRIVILEGES ;
EOSQL

if ! kill -s TERM "$pid" || ! wait "$pid"; then
	echo >&2 'MySQL init process failed.'
	exit 1
fi

echo
echo 'MySQL init process done. Ready for start up.'
echo

exec "$@"
