library(ncdf)

root.dir <- "~/Dropbox/data/ftp.acri.fr/GLOB_4KM/RAN/CHL1/MERGED/GSM"
raster2pgsql.dir <- "/opt/local/lib/postgresql93/bin/raster2pgsql"
psql.cmd <- "psql -d dd -U postgres"

# Load Monthly data ------------------------------------------------------------

for (year in 1997:2014) {
  data.dir <- paste(root.dir, '/', year, '/MONTHLY')
  fl <- list.files(data.dir, full.names = T)
  for (filename in fl) {
    command <- paste("gzip -d", filename)
    system(command)
    filename
    command <- paste(raster2pgsql.dir, '-a -F -s 4326 -b', t, filename, 'wind.u10 |',  psql.cmd)
    system(command)
  }
}
