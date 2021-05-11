PG_USER=mega-user
PG_DATABASE=super-service

.PHONY: all
all:

# Make psql connection to the `old` instance
.PHONY: psql-old
psql-old:
	@docker exec -it pg-old psql -U $(PG_USER) $(PG_DATABASE)

# Make psql connection to the `new` instance
.PHONY: psql-new
psql-new:
	@docker exec -it pg-new psql -U $(PG_USER) $(PG_DATABASE)

# Initialize `old` instance. see 00-schema.sql
.PHONY: schema-old
schema-old:
	@docker exec -i pg-old psql -U $(PG_USER) $(PG_DATABASE) < 00-schema.sql

# Initialize `new` instance. see 00-schema.sql
.PHONY: schema-new
schema-new:
	@docker exec -i pg-new psql -U $(PG_USER) $(PG_DATABASE) < 00-schema.sql

# Run worker on `old` instance
.PHONY: worker-old
worker-old:
	@python3 worker.py old

# Run worker on `new` instance
.PHONY: worker-new
worker-new:
	@python3 worker.py new

# Configure `new` instance. See 01-init-new.sql
.PHONY: init-new
init-new:
	@docker exec -i pg-new psql -U $(PG_USER) $(PG_DATABASE) < 01-init-new.sql

# Create inheritance from foreign tables to local ones. See 02-inheritance.sql
.PHONY: inheritance
inheritance:
	@docker exec -i pg-new psql -U $(PG_USER) $(PG_DATABASE) < 02-inheritance.sql

# Disable foreign key checks
.PHONY: disable-fk
disable-fk:
	@docker exec -i pg-new psql -U $(PG_USER) $(PG_DATABASE) < 03-disable-fk.sql

# Enable foreign key checks
.PHONY: enable-fk
enable-fk:
	@docker exec -i pg-new psql -U $(PG_USER) $(PG_DATABASE) < 04-enable-fk.sql

# Migrate data from foreign tables to local
.PHONY: migrate
migrate:
	@python3 migrator.py child 10
	@python3 migrator.py parent 10

# Cleanup new instance
.PHONY: cleanup-new
cleanup-new:
	@docker exec -i pg-new psql -U $(PG_USER) $(PG_DATABASE) < 05-cleanup-new.sql
