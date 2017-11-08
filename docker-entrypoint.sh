#!/bin/bash
if [ ! -f /.root_pw_set ]; then
	/set_root_pw.sh
fi

if [ ! -z "${MYSQL_HOST}" ]; then
  sed -i "s#<Host>.*#<Host>${MYSQL_HOST}</Host>#" /etc/mythtv/config.xml
fi

if [ ! -z "${MYSQL_USER}" ]; then
  sed -i "s#<UserName>.*#<UserName>${MYSQL_USER}</UserName>#" /etc/mythtv/config.xml
fi

if [ ! -z "${MYSQL_PASS}" ]; then
  sed -i "s#<Password>.*#<Password>${MYSQL_PASS}</Password>#" /etc/mythtv/config.xml
fi

if [ ! -z "${MYSQL_DATABASE}" ]; then
  sed -i "s#<DatabaseName>.*#<DatabaseName>${MYSQL_DATABASE}</DatabaseName>#" /etc/mythtv/config.xml
fi

if [ ! -z "${MYSQL_PORT}" ]; then
  sed -i "s#<Port>.*#<Port>${MYSQL_PORT}</Port>#" /etc/mythtv/config.xml
fi

DIR="/var/lib/mysql"
if [ "$(ls -A $DIR)" ]; then
     echo "$DIR is not Empty - skipping database initialization"
else
    echo "$DIR is Empty - initializing mariadb"
    chown -R mysql:mysql /var/lib/mysql
    /usr/sbin/mysqld --initalize
    /usr/bin/mysqld_safe -d
    /usr/sbin/dpkg-reconfigure mythtv-database
    /usr/bin/mysqladmin shutdown
fi

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf 1>/dev/null

