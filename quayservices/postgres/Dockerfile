FROM flexberry/alt.p8-postgresql

RUN \
  /etc/init.d/postgresql start; \
  sleep 5; \
  until echo  "\l" |  psql -U postgres; do sleep 5; done ; \
  echo "CREATE DATABASE quaydb;" | psql -U postgres ; \
  echo "CREATE EXTENSION  pg_trgm;" | psql -U postgres  -d quaydb ; \ 
  echo "CREATE USER quayuser WITH SUPERUSER;" | psql -U postgres ; \
  echo "CREATE DATABASE clairtest WITH OWNER = postgres ENCODING = 'UTF8';"| psql -U postgres  ; \
  echo "ALTER ROLE postgres WITH PASSWORD 'password';"| psql -U postgres ; \
  echo "SELECT * FROM pg_extension;" | psql -U postgres ; \
  echo "SELECT * FROM pg_user;" | psql -U postgres ; \
  /etc/init.d/postgresql stop; \
  sleep 5; \
  while [ -f /var/lib/pgsql/data/postmaster.pid ]; do sleep 5; done; \
  killall postgres; \
  while [ -f /tmp/.s.PGSQL.5432.lock ]; do sleep 5; done;

