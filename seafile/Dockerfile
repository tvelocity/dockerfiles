FROM buildpack-deps:jessie
MAINTAINER Tony Motakis <tvelocity@gmail.com>

ENV SEAFILE_VERSION 4.1.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl expect mysql-client python2.7 python-setuptools python-simplejson \
    python-imaging python-mysqldb && \
    rm -r /var/lib/apt/lists/*

WORKDIR /opt

RUN curl -L -O https://bitbucket.org/haiwen/seafile/downloads/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

COPY entrypoint.sh /entrypoint.sh
COPY start.sh /start.sh

VOLUME /opt/seafile
WORKDIR /opt/seafile

EXPOSE 10001
EXPOSE 12001
EXPOSE 8082
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash", "/start.sh"]
