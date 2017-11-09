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

chown -R mysql:mysql /var/run/mysqld 
DIR="/var/lib/mysql"
if [ "$(ls -A $DIR)" ]; then
    echo "$DIR is not Empty - skipping database initialization"
    chown -R mysql:mysql /var/lib/mysql
else
    echo "$DIR is Empty - initializing mariadb"
    chown -R mysql:mysql /var/lib/mysql
    /usr/bin/mysql_install_db --user=mysql
    cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'
    /usr/sbin/dpkg-reconfigure mythtv-database
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
    /usr/bin/mysqladmin shutdown
fi

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf 1>/dev/null

