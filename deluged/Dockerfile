FROM debian:jessie
MAINTAINER Tony Motakis <tvelocity@gmail.com>

RUN apt-get update && apt-get install -y deluged

COPY entrypoint.sh /entrypoint.sh

VOLUME /deluge
WORKDIR /deluge

EXPOSE 53160
EXPOSE 53160/udp
EXPOSE 58846

ENTRYPOINT ["/entrypoint.sh"]
CMD ["deluged", "-dc", "/deluge/"]
