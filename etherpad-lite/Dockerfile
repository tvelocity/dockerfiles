# Stable version of etherpad doesn't support npm 2
FROM buildpack-deps:jessie
MAINTAINER Tony Motakis <tvelocity@gmail.com>

ENV ETHERPAD_VERSION 1.4.1

RUN apt-get update && \
    apt-get install -y curl unzip nodejs-legacy npm mysql-client abiword && \
    rm -r /var/lib/apt/lists/*

WORKDIR /opt/

RUN curl -SL \
    https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
    > etherpad.zip && unzip etherpad && rm etherpad.zip && \
    mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite

WORKDIR etherpad-lite

RUN bin/installDeps.sh && rm settings.json
COPY entrypoint.sh /entrypoint.sh

VOLUME /opt/etherpad-lite/var
RUN ln -s var/settings.json settings.json

EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bin/run.sh", "--root"]
