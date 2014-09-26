#!/bin/bash
#

psql -d test -U postgres -c "DROP TABLE IF EXISTS myraster"

raster2pgsql -p -I -C -F -s 4326 -b 1 ~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc myraster | psql -d test -U postgres

psql -d test -U postgres -c "ALTER TABLE myraster ADD COLUMN date TIMESTAMP WITH TIME ZONE"

raster2pgsql -a -C -F -s 4326 -b 1 ~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc myraster | psql -d test -U postgres

psql -d test -U postgres -c "UPDATE myraster SET date='01/01/2001':: TIMESTAMP WITH TIME ZONE"
