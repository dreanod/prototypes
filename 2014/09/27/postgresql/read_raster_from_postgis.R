require(rgdal)
require(raster)
dsn="PG:dbname=test port=5432 user=postgres schema='public' table=myraster mode=2"
GDALinfo(dsn)
myraster_sp = readGDAL(dsn)
myraster_r <- raster(myraster_sp)
