library(rasterVis)
library(RPostgreSQL)
library(rgdal)

m <- dbDriver('PostgreSQL')
con <- dbConnect(m, user="postgres", dbname="dd")

query <- "DROP VIEW IF EXISTS temp"
dbSendQuery(con, query)

# Create a view
query <- "CREATE OR REPLACE VIEW temp AS
          SELECT rid, 
            extract(month from date) AS month,
	          extract(year from date) AS year,
	          ST_AsTIFF(rast) rast
      	 FROM wind.wspd_10m
	       WHERE extract(year from date) = 2001
	       AND extract(month from date) = 1"
dbSendQuery(con, query)

# Get the raster from the view using GDAL
dsn <- "PG:dbname=dd user=postgres table=wind_temp"
myrast <- readGDAL(dsn)
GDALinfo(dsn)
