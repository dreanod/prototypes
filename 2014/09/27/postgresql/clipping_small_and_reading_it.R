require(RPostgreSQL)

m <- dbDriver("PostgreSQL")
con <- dbConnect(m, dbname="test", user="postgres")
q <- "
DROP TABLE IF EXISTS yanbu;
CREATE TABLE yanbu(rid SERIAL primary key, rast raster);
INSERT INTO yanbu(rast)
      SELECT ST_Clip(rast, ST_GeomFromText('POLYGON((
        	36.88545 23.33625,
          38.35686 23.33625,
          38.35686 24.62099,
          36.88545 24.62099,
          36.88545 23.33625
))', 4326))
      	FROM myraster 
WHERE rid = 1;
SELECT AddRasterConstraints('yanbu'::name, 'rast'::name);"
rs <- dbSendQuery(con,q)
df <- fetch(rs,n=-1)


require(rgdal)
require(raster)
dsn="PG:dbname=test port=5432 user=postgres schema='public' table=yanbu mode=2"
GDALinfo(dsn)
myraster_sp = readGDAL(dsn)
myraster_r <- raster(myraster_sp)

require(rasterVis)
levelplot(myraster_r)
