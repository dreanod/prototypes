library(ncdf)

filename <- '~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc'
nc.file <- open.ncdf(filename)

T <- nc.file$dim$time$len - 1
time.origin <- strsplit(nc.file$dim$time$units, " ")[[1]][4]
date.origin <- strsplit(nc.file$dim$time$units, " ")[[1]][3]
datetime.origin <- paste(date.origin, time.origin)

system('psql -d test -U postgres -c "DROP TABLE IF EXISTS myraster"')
system('/opt/local/lib/postgresql93/bin/raster2pgsql -p -I -C -F -s 4326 -b 1 ~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc myraster | psql -d test -U postgres')
system('psql -d test -U postgres -c "ALTER TABLE myraster ADD COLUMN date TIMESTAMP WITH TIME ZONE"')

for (t in 1:T) {
  command <- paste('/opt/local/lib/postgresql93/bin/raster2pgsql -a -C -F -s 4326 -b', t, '~/Dropbox/data/Wind2000-2013/MIT-01JAN01-01JAN02_u10.nc myraster | psql -d test -U postgres')
  system(command)
  
  command <- paste('psql -d test -U postgres -c "UPDATE myraster SET date=\'01/01/2001\':: TIMESTAMP WITH TIME ZONE + interval ', 180 * t, 'minutes" rid=', t, '"')
  print(command)
  system(command)
}