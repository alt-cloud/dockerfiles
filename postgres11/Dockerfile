ARG PLATFORM=p10

FROM  quay.io/altlinux/alt:${PLATFORM}

ARG VERSION=11

RUN \
  apt-get update; \
  apt-get install -y postgresql${VERSION}-server postgresql${VERSION}-contrib su less; \
  apt-get remove -y systemd systemd-boot-efi systemd-utils systemd-sysctl-common; \
  rm -f /var/cache/apt/archives/*.rpm \
        /var/cache/apt/*.bin \
        /var/lib/apt/lists/*.*

ENV PGDATA=/var/lib/pgsql/data

COPY /root /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "postgres" ]

EXPOSE 5432/tcp

VOLUME [ "/var/lib/pgsql/data" ]
