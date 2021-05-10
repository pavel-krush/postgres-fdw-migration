-- Drop foreign tables
DROP FOREIGN TABLE parent_remote;
DROP FOREIGN TABLE child_remote;

-- Drop user mapping
DROP USER MAPPING FOR "mega-user" SERVER pg_old;

-- Drop foreign server
DROP SERVER pg_old;

-- Drop postgres_fdw extension
DROP EXTENSION postgres_fdw;
