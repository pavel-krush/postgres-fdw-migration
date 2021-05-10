# Postgres-to-Postgres online migration

This repo is an example showing how to do online migration from one postgres
instance to another.

WARNING: This is not ready-to-use solution. It's only a proof of concept that
shows how postgres_fdw may be used.

# Limitations

0. **!!! Database can become inconsistent because foreign key
   checks are disabled while migration is in progress !!!**\
   It's strongly recommended to check consistency after migration manually.
1. Sequences must be migrated manually. It's possible to automate
   it using `dblink` extension;
2. Each `SELECT` query executed twice while inheritance
   is enabled: on the local database and on the remote. This takes additional time;
3. Data must be migrated in order which will not violate
   foreign key checks on the `old` instance;
4. Be careful with triggers! Actually be always careful with triggers;
5. Read about [transaction management](https://www.postgresql.org/docs/13/postgres-fdw.html#id-1.11.7.42.12).

# Overview

The main idea is to use Postgres foreign data wrapper feature, and
it’s postgres_fdw implementation for Postgres<->Postgres interconnection.

1. On a `new` database create postgres_fdw extension;
2. Configure remote server;
3. Declare all foreign tables with suffix `_remote`;
5. Make foreign tables inherit local tables;
6. Switch software to use `new` instance;
7. Migrate data from foreign tables to local tables;
8. Drop foreign tables;
9. Drop foreign server;
10. Drop postgres_fdw extension.

# Requirements

- docker;
- docker-compose;
- python3;
- python's `psycopg2` and `coolname` libraries installed: `pip3 install psycopg2 coolname`;

# Example

You can always connect to any instance by issuing `make pg-old` or `make pg-new` command.

1. Create `old` and `new` database instances using [docker-compose](docker-compose.yml):\
   `$ docker-compose up -d`

2. Initialize `old` database:\
   `$ make schema-old`\
   See the [SQL](00-schema.sql) schema;
   
3. Start worker on `old` instance:\
   `$ make worker-old`
   This will simulate production load, and also will create
   some data for migration while we are doing preparation steps;
   
4. Configure the `new` instance:\
   `$ make init-new`\
   Big part of magic happens here.\
   See [SQL](01-init-new.sql) for details.\
   After this step we will have two foreign tables on `new` instance: `parent_remote` and
   `child_remote` which redirect all queries to the remote server;
   
5. Copy schema to the `new` instance:\
   `$ make schema-new`\
   We use the same [schema](00-schema.sql) like it was used for `old` instance;
   
6. Create inheritance from foreign tables to local ones.
   `$ make inheritance`\
   See [02-inheritance.sql](02-inheritance.sql).

7. Disable foreign key checks. This needs to be done because database
   will be inconsistent during migration. We should allow migrated data to refer
   to non-migrated data. But not vice versa, as we don't disable foreign key checks on
   the remote side.\
   `$ make disable-fk`

7. Stop worker on `old` instance using CTRL+C and start it on `new`:\
   `$ make worker-new`\
   From now `old` instance should not be used directly.

8. Migrate the data:\
   `$ make migrate`\
   See [migrator.py](migrator.py);

9. Enable foreign key checks:\
   `$ make enable-fk`

9. Cleanup `new` instance:\
   `$ make cleanup-new`
   
10. Stop docker project:\
   `$ docker-compose down`

11. Relax and have a beer 🍺.
