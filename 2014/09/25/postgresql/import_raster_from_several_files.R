library(ncdf)

data.dir <- "~/Dropbox/data/Wind2000-2013"
raster2pgsql.dir <- "/opt/local/lib/postgresql93/bin/raster2pgsql"
psql.cmd <- "psql -d test -U postgres"

fl.u <-list.files(data.dir, full.names = T, glob2rx("*u10.nc"))
fl.v <-list.files(data.dir, full.names = T, glob2rx("*v10.nc"))
nyear <- length(fl.u)

##### Prepare tables wind_u10 and wind_v10 #####

system('psql -d test -U postgres -c "DROP TABLE IF EXISTS wind_u10"')
command <- paste(raster2pgsql.dir, '-p -I -C -F -s 4326 -b 1', fl.u[1], 'wind_u10 |', psql.cmd)
system(command)
system('psql -d test -U postgres -c "ALTER TABLE wind_u10 ADD COLUMN date TIMESTAMP WITH TIME ZONE"')

system('psql -d test -U postgres -c "DROP TABLE IF EXISTS wind_v10"')
command <- paste(raster2pgsql.dir, '-p -I -C -F -s 4326 -b 1', fl.v[1], 'wind_v10 |', psql.cmd)
system(command)
system('psql -d test -U postgres -c "ALTER TABLE wind_v10 ADD COLUMN date TIMESTAMP WITH TIME ZONE"')

rid = 0
for (i in 1:nyear) {
    
  nc.file <- open.ncdf(fl.u[i])
  T <- nc.file$dim$time$len - 1
  time.origin <- strsplit(nc.file$dim$time$units, " ")[[1]][4]
  date.origin <- strsplit(nc.file$dim$time$units, " ")[[1]][3]
  datetime.origin <- paste(date.origin, time.origin)
  
  T<-10 # TODO
  for (t in 1:T) {
    rid <- rid + 1
    command <- paste(raster2pgsql.dir, '-a -F -s 4326 -b', t, fl.u[i], 'wind_u10 |',  psql.cmd)
    system(command)
    command <- paste('psql -d test -U postgres -c "UPDATE wind_u10 SET date=\'', datetime.origin, '+0\':: TIMESTAMP WITH TIME ZONE + interval \'', 180 * (t-1), 'minutes\' WHERE rid=', rid, '"')
    system(command)
    
    command <- paste(raster2pgsql.dir, '-a -F -s 4326 -b', t, fl.v[i], 'wind_v10 |',  psql.cmd)
    system(command)
    command <- paste('psql -d test -U postgres -c "UPDATE wind_v10 SET date=\'', datetime.origin, '+0\':: TIMESTAMP WITH TIME ZONE + interval \'', 180 * (t-1), 'minutes\' WHERE rid=', rid, '"')
    system(command)
  }
}