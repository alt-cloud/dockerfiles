FROM  quay.io/altlinux/alt:p10

RUN \
  apt-get update; \
  rm -f /var/cache/apt/*.bin; \
  apt-get install -y postgresql11-server postgresql11-contrib su less; \
  apt-get clean;

# RUN \
#    chown -R postgres:postgres  /var/lib/pgsql/; \
#    chmod 777 /var/lib/pgsql/data;

ENV PGDATA=/var/lib/pgsql/data

COPY /root /


ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "postgres" ]

EXPOSE 5432/tcp

VOLUME [ "/var/lib/pgsql/data" ]

