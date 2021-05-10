CREATE EXTENSION pgcrypto;

CREATE TABLE parent(
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL
);
CREATE INDEX ON parent(name);


CREATE TABLE child(
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES parent(id),
    name TEXT NOT NULL
);
CREATE INDEX ON child(parent_id);
CREATE INDEX ON child(name);
