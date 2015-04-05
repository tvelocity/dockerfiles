#!/bin/bash

./seafile.sh start
./seahub.sh start 80

# exit when seafile dies
while pgrep -f "seafile-controller" 2>&1 >/dev/null; do
	sleep 2m;
done
