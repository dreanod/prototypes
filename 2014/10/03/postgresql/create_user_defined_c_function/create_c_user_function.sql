CREATE OR REPLACE FUNCTION add_one(integer) RETURNS integer
as '/opt/local/var/db/postgresql93/funcs.so', 'add_one'
LANGUAGE C STRICT;
