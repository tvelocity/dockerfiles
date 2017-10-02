# Etherpad Lite image for docker

This is a docker image for [Etherpad Lite](http://etherpad.org/) collaborative
text editor. The Dockerfile for this image has been inspired by the
[official Wordpress](https://registry.hub.docker.com/_/wordpress/) Dockerfile and
[johbo's etherpad-lite](https://registry.hub.docker.com/u/johbo/etherpad-lite/)
image.

This image uses a database (mysql or postgres) container for the backend for
the pads. It is based on debian jessie instead of the official node docker
image, since the latest stable version of etherpad-lite does not support npm 2.

## About Etherpad Lite

> *From the official website:*

Etherpad allows you to edit documents collaboratively in real-time, much like a live multi-player editor that runs in your browser. Write articles, press releases, to-do lists, etc. together with your friends, fellow students or colleagues, all working on the same document at the same time.

![alt text](http://i.imgur.com/zYrGkg3.gif "Etherpad in action on PrimaryPad")

All instances provide access to all data through a well-documented API and supports import/export to many major data exchange formats. And if the built-in feature set isn't enough for you, there's tons of plugins that allow you to customize your instance to suit your needs.

You don't need to set up a server and install Etherpad in order to use it. Just pick one of publicly available instances that friendly people from everywhere around the world have set up. Alternatively, you can set up your own instance by following our installation guide

## Quickstart

First you need a running mysql container, for example:

```bash
$ docker network create ep_network
$ docker run -d --network ep_network -e MYSQL_ROOT_PASSWORD=password --name ep_mysql mysql
```

Finally you can start an instance of Etherpad Lite:

```bash
$ docker run -d \
    --network ep_network \
    -e ETHERPAD_DB_HOST=ep_mysql \
    -e ETHERPAD_DB_PASSWORD=password \
    -p 9001:9001 \
    tvelocity/etherpad-lite
```

Etherpad will automatically create an `etherpad` database in the specified mysql
server if it does not already exist.
You can now access Etherpad Lite from http://localhost:9001/

## Environment variables

This image supports the following environment variables:

* `ETHERPAD_TITLE`: Title of the Etherpad Lite instance. Defaults to "Etherpad".
* `ETHERPAD_PORT`: Port of the Etherpad Lite instance. Defaults to 9001.

* `ETHERPAD_ADMIN_PASSWORD`: If set, an admin account is enabled for Etherpad,
and the /admin/ interface is accessible via it.
* `ETHERPAD_ADMIN_USER`: If the admin password is set, this defaults to "admin".
Otherwise the user can set it to another username.

* `ETHERPAD_DB_TYPE`: Type of databse to use. Defaults to `mysql`.
* `ETHERPAD_DB_HOST`: Hostname of the database to use. Defaults to `mysql`.
* `ETHERPAD_DB_USER`: By default Etherpad Lite will attempt to connect as root
to the database container.
* `ETHERPAD_DB_PASSWORD`: Password to use, mandatory. If legacy links
are used and `ETHERPAD_DB_USER` is root, then `MYSQL_ENV_MYSQL_ROOT_PASSWORD` is
automatically used.
* `ETHERPAD_DB_PASSWORD_FILE`: MySQL password to use, replace `ETHERPAD_DB_PASSWORD`
when using [Docker secrets](https://docs.docker.com/engine/swarm/secrets/).
* `ETHERPAD_DB_NAME`: The database to use. Defaults to *etherpad*. If the
database is not available, it will be created when the container is launched
(only if the database type is either `mysql` or `postgres`, and the user need to
have the right to create the database).
* `ETHERPAD_DB_CHARSET`: The charset to use. Defaults to *utf8mb4*.
* `ETHERPAD_API_KEY`: if file `APIKEY.txt` is missing, the variable value is used to provision it

The generated settings.json file will be available as a volume under
*/opt/etherpad-lite/var/*.
