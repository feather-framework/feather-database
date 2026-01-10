FROM ubuntu:noble

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql

WORKDIR /app

COPY docker/migrator/scripts .
COPY docker/migrator/migrations ./migrations

RUN chmod a+x *.sh

ENTRYPOINT ["./entrypoint.sh"]
