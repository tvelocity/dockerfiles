FROM debian:jessie
MAINTAINER Tony Motakis <tvelocity@gmail.com>

RUN apt-get update && apt-get install -y deluge-web
RUN apt-get install -y deluged

VOLUME /deluge-web
WORKDIR /deluge-web

EXPOSE 8112

CMD ["deluge-web", "-c", "/deluge-web/"]
