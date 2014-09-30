library(RPostgreSQL)

m <- dbDriver("PostgreSQL")
con <- dbConnect(m, dbname="test", user="postgres")

query = "DROP VIEW IF EXISTS my_windspd_view;"
dbSendQuery(con, query)

query = "CREATE VIEW my_windspd_view AS
         SELECT wind_u.rid rid, 
         ST_MapAlgebra(wind_u.rast, wind_v.rast, 'sqrt([rast1]*[rast1] + [rast2]*[rast2])') rast
         FROM wind_u, wind_v 
         WHERE wind_v.date = wind_u.date;"
dbSendQuery(con, query)

query = "CREATE OR REPLACE VIEW my_windspd_view_mean AS
         SELECT 1 rid,
                ST_Union(rast, 'MEAN') rast
         FROM my_windspd_view"
dbSendQuery(con, query)

# Read the view
library(rgdal)
dsn <- "PG:dbname=test user=postgres table=my_windspd_view_mean"
windspd <- readGDAL(dsn)

