FROM  quay.io/altlinux/alt:p10

RUN \
  apt-get update && apt-get -y dist-upgrade && \
  apt-get install -y postgresql11-server postgresql11-contrib su less; \
  apt-get clean

ENV PGDATA=/var/lib/pgsql/data

COPY /root /

USER postgres

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "postgres" ]
