#!/bin/bash
#

psql -d test -U postgres -c "DROP TABLE IF EXISTS myraster2"

raster2pgsql -c -I -C -F -s 4326 -b 1 ~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc myraster2 | psql -d test -U postgres

raster2pgsql -a -C -F -s 4326 -b 2 ~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc myraster2 | psql -d test -U postgres

psql -d test -U postgres -c "insert into myraster2(rast) select st_union(rast) from myraster2"

psql -d test -U postgres -c "select rid, st_numbands(rast) from myraster2"

## doesn't work
