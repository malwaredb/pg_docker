FROM rust:slim-trixie@sha256:6f14b2b4b278ec0d50aa1d69541c304ce0f95e0f6268487aa9924af1c2e9aebe AS builder
ENV DEBIAN_FRONTEND=noninteractive

# Install things we need for compilation
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y postgresql-17 postgresql-server-dev-17 build-essential git clang llvm libclang-dev flex bison \
    libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc ccache pkg-config libicu-dev libreadline-dev zlib1g-dev

# Download the components
WORKDIR /malwaredb_pg
RUN git clone https://github.com/malwaredb/malwaredb-pg.git
RUN cargo install cargo-pgrx --version 0.20.0 --locked
RUN cargo pgrx init --pg17=`which pg_config`

# Build the extension
RUN cd malwaredb-pg && git checkout v0.0.1 && cargo pgrx package --features=pg17

FROM postgres:17-trixie@sha256:223efeb196329b55b3b9a13db144956411dbc18e727e59f681c3e0aede6475cf
LABEL MAINTAINER="Richard Zak <richard@malwaredb.net>"
LABEL org.opencontainers.image.authors="richard@malwaredb.net"
LABEL SOURCE="https://github.com/malwaredb/docker/"
LABEL org.opencontainers.image.source="https://github.com/malwaredb/docker/"
LABEL org.opencontainers.image.description="Postgres 17 on Debian Trixie with similarity extensions installed intended for use with MalwareDB"
LABEL org.opencontainers.image.licenses=Apache-2.0
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /malwaredb_pg
COPY --from=builder /malwaredb_pg/malwaredb-pg/target/release/malwaredb_pg-pg17/postgresql-17-malwaredb-pg_0.0.1*.deb /malwaredb_pg
RUN dpkg -i postgresql-17-malwaredb-pg_0.0.1*.deb

VOLUME /var/lib/postgresql/17/data/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# For fast shutdown mode for Postgres
# https://github.com/docker-library/postgres/blob/dd68d91377a3631b36a23f2e4795f6189db4ba12/15/bullseye/Dockerfile#L188
STOPSIGNAL SIGINT
EXPOSE 5432/tcp

CMD ["postgres"]
