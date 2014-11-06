#!/bin/bash
set -e

if [ -z "$MYSQL_PORT_3306_TCP_ADDR" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi
SEAFILE_DB_PASSWORD="${MYSQL_ENV_MYSQL_ROOT_PASSWORD}"
SEAFILE_DB_HOST="${MYSQL_PORT_3306_TCP_ADDR}"

: ${SEAFILE_DB_CCNET:=ccnet-db}
: ${SEAFILE_DB_SEAFILE:=seafile-db}
: ${SEAFILE_DB_SEAHUB:=seahub-db}

: ${SEAFILE_NAME:=Seafile}
: ${SEAFILE_VHOST:=localhost}

if [ ! -d seafile-server-${SEAFILE_VERSION} ]; then
	tar xzf ../seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz
fi

cd seafile-server-${SEAFILE_VERSION}

if [ ! -f ../ccnet/ccnet.conf ]; then

	: ${SEAFILE_ADMIN_EMAIL:=admin@example.com}
	: ${SEAFILE_ADMIN_PASSWORD:=admin}

	# check first databases are available
	if mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$SEAFILE_DB_HOST \
	   -e "use \`${SEAFILE_DB_CCNET}\`" 2> /dev/null; then
		echo >&2 'error: mysql database already exists'
		exit 1
	fi
	if mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$SEAFILE_DB_HOST \
	   -e "use \`${SEAFILE_DB_SEAFILE}\`" 2> /dev/null; then
		echo >&2 'error: mysql database already exists'
		exit 1
	fi
	if mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$SEAFILE_DB_HOST \
	   -e "use \`${SEAFILE_DB_SEAHUB}\`" 2> /dev/null; then
		echo >&2 'error: mysql database already exists'
		exit 1
	fi

	expect <<- EOF
	spawn ./setup-seafile-mysql.sh
	set  send_slow  {1  .01}
	set  timeout  60
	while (1) { expect {
		timeout {exit -1}
		"Press ENTER to continue"
		{ send "\r" }
		"What is the name of the server? It will be displayed on the client."
		{ send "${SEAFILE_NAME}\r" }
		"What is the ip or domain of the server?"
		{ send "${SEAFILE_VHOST}\r" }
		"Which port do you want to use for the ccnet server?"
		{ send "10001\r" }
		"Where do you want to put your seafile data?"
		{ send "/opt/seafile/seafile-data\r" }
		"Which port do you want to use for the seafile server?"
		{ send "12001\r" }
		"Which port do you want to use for the seafile fileserver?"
		{ send "8082\r" }
		"Please choose a way to initialize seafile databases:"
		{ send "1\r" }
		"What is the host of mysql server?"
		{ send "${SEAFILE_DB_HOST}\r" }
		"What is the port of mysql server?"
		{ send "\r" }
		"What is the password of the mysql root user?"
		{
			send -s "${MYSQL_ENV_MYSQL_ROOT_PASSWORD}\r"
			exp_continue -continue_timer
		}
		"Enter the name for mysql user of seafile. It would be created if not exists."
		{ send "root\r" }
		"Enter the database name for ccnet-server:"
		{ send "${SEAFILE_DB_CCNET}\r" }
		"Enter the database name for seafile-server:"
		{ send "${SEAFILE_DB_SEAFILE}\r" }
		"Enter the database name for seahub:"
		{ send "${SEAFILE_DB_SEAHUB}\r" }
		"Press ENTER to continue, or Ctrl-C to abort"
		{ send "\r" }
		eof break
	} }
	wait
	EOF

	# point to port 80 for http
	sed -i -e "s/.*SERVICE_URL.*=.*/SERVICE_URL = http:\/\/${SEAFILE_VHOST}/g" \
		/opt/seafile/ccnet/ccnet.conf

	./seafile.sh start
	
	expect <<- EOF
	spawn ./seahub.sh start 80
	set  send_slow  {1  .01}
	set  timeout  30
	while (1) {
		expect {
			timeout {exit -1}
			"admin email" { send "${SEAFILE_ADMIN_EMAIL}\r" }
			"admin password" {
				send -s "${SEAFILE_ADMIN_PASSWORD}\r"
				exp_continue -continue_timer
			} 
			eof break
		}
	}
	wait
	EOF

fi

exec "$@"
