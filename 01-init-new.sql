-- Install postgres_fdw extension
CREATE EXTENSION postgres_fdw;

-- Create a foreign server using postgres_fdw wrapper
-- See https://www.postgresql.org/docs/13/sql-createserver.html
CREATE SERVER pg_old FOREIGN DATA WRAPPER postgres_fdw OPTIONS
    (HOST 'pg-old', dbname 'super-service', port '5432');

-- Create user mapping between local and remote users
-- See https://www.postgresql.org/docs/13/sql-createusermapping.html
CREATE USER MAPPING FOR "mega-user" SERVER pg_old OPTIONS
    (USER 'mega-user', PASSWORD 'secret-password');

-- Declare foreign tables.
-- It can be done manually using CREATE FOREIGN TABLE statements
--    See https://www.postgresql.org/docs/13/sql-createforeigntable.html
-- Or automatically using IMPORT FOREIGN SCHEMA
--    See https://www.postgresql.org/docs/13/sql-importforeignschema.html
--    The list of tables can be limited to a specified subset, or specific tables can be excluded.
-- We will use second way and will not limit tables list.
--    Also it's mandatory to clearly understand OPTIONS.
--      See https://www.postgresql.org/docs/13/postgres-fdw.html#id-1.11.7.42.10
--      Especially "Importing Options" section
IMPORT FOREIGN SCHEMA public FROM SERVER pg_old INTO PUBLIC OPTIONS
    (import_default 'true', import_not_null 'true');

-- Add `_remote` suffix to foreign tables
ALTER FOREIGN TABLE parent RENAME TO parent_remote;
ALTER FOREIGN TABLE child RENAME TO child_remote;
