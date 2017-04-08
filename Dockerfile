FROM hub.c.163.com/library/debian:8.6

MAINTAINER Simon Wood <wq@wuqian.me>

COPY debian/sources.list /etc/apt/sources.list
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["entrypoint.sh"]