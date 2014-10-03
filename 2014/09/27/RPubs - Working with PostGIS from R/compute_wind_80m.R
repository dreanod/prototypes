library(RPostgreSQL)

m <- dbDriver('PostgreSQL')
con <- dbConnect(m, user='postgres', dbname='test')

query <- "CREATE OR REPLACE VIEW windspd_10m AS
          SELECT wind_u.rid, ST_MapAlgebra(wind_u.rast, wind_v.rast,
                                    'sqrt([rast1]^2 + [rast2]^2)') rast
          FROM wind_u, wind_v
          WHERE wind_u.date = wind_v.date"
dbSendQuery(con, query)

# Extrapolating wind -----------------------------------------------------------
query <- "CREATE OR REPLACE VIEW windspd_80m AS
          SELECT rid, ST_MapAlgebra(rast, 1, NULL, '[rast] * (80/10)^0.11') rast
          FROM windspd_10m"
dbSendQuery(con, query)

query <- "CREATE OR REPLACE VIEW windspd_80m_mean AS
          SELECT 1 rid, ST_Union(rast, 'MEAN') rast
          FROM windspd_80m"
dbSendQuery(con, query)

library(rasterVis)
dsn = "PG:dbname=test user=postgres table=windspd_80m_mean"
wspd80_sp <- readGDAL(dsn)
wspd80_r <- raster(wspd80_sp)
levelplot(wspd80_r)
