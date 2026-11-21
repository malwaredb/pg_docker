## Dockerfile for Postgres for MalwareDB

This Docker file builds extensions for Postgres on Debian for use with MalwareDB. Please see [Docker Postgres](https://hub.docker.com/_/postgres/) for more information.

### Postgres Extensions
Postgres is installed with the similarity extensions from <https://github.com/malwaredb/malwaredb-pg>.

To use the extensions, run `CREATE EXTENSION malwaredb_pg;` for each schema where you wish to use them.

Be sure to set the admin password for Postgres via the `POSTGRES_PASSWORD` environment variable, shown below.

```
$ git clone https://github.com/malwaredb/pg_docker.git
$ docker build -t postgres-similarity/latest .
$ mkdir pg_data
$ docker run -v `pwd`/pg_data:/var/lib/postgresql/17/data -p 5432:5432 -e POSTGRES_PASSWORD=yoursecurepassword postgres-similarity/latest
```
