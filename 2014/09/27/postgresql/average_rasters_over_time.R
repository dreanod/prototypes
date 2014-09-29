# This script is based on the tutorial:
# http://rpubs.com/dgolicher/6373

setwd("/Users/denis/Dropbox/code/repos/prototypes/2014/09/27/RPubs - Working with PostGIS from R/")
rm(list = ls())


# Downloading example data -----------------------------------------------------

system('wget https://dl.dropboxusercontent.com/u/2703650/Courses/geostats/geostats.zip')
system('unzip geostats.zip')

# Loading packages -------------------------------------------------------------

library(RODBC) # Wiki: ODBC (Open Database Connectivity) is a standard 
               # programming language middleware API for accessing database 
               # management systems (DBMS)
library(rgdal)

# Creating a new database ------------------------------------------------------

system('dropdb geostats -U postgres')
system('createdb geostats -U postgres')

# Establishing an ODBC connection ----------------------------------------------

# Here we use the RPostgreSQL instead of RODBC
require(RPostgreSQL)
m <- dbDriver("PostgreSQL")
con <- dbConnect(m, dbname="geostats", user="postgres")

# install PostGIS on the database
# for up-to-date installation instruction, see: http://postgis.net/install/
dbSendQuery(con, "CREATE EXTENSION POSTGIS")
dbSendQuery(con, "CREATE EXTENSION POSTGIS_topology")
dbSendQuery(con, "CREATE EXTENSION fuzzystrmatch")
dbSendQuery(con, "CREATE EXTENSION postgis_tiger_geocoder")

# to check if the installation worked:
rs <- dbSendQuery(con, "SELECT postgis_full_version()")
df <- fetch(rs,n=-1)
print(df$postgis_full_version)

# Loading vector data into PostGIS from R --------------------------------------

states <- readOGR("geostats/shapefiles/", "states") # notice the peculiat signature:
                                                    # dsn: path to the shapefiles
                                                    # layer: name of a layer (not of the file)

plot(states) # state is a SpatialPolygonDataFrame
box()
axis(1)
axis(2)
grid()

# write the shapefile to PostGIS
writeOGR(obj=states, dsn="PG:dbname=geostats user=postgres", 
         layer_options="geometry_name=geom", layer="states", driver="PostgreSQL")

# Visualizing results in QGIS --------------------------------------------------

# We have to install this plugins in QGIS:
# https://plugins.qgis.org/plugins/openlayers_plugin/

# See here for installation:
# http://www.digital-geography.com/qgis-plugins-openlayers/#.VCabSRZAVfM

# In my version in need to go to the menu "Web > OpenLayers Plugin" to use the
# plugin.

# Loading point data -----------------------------------------------------------

towns <- read.csv("geostats/textfiles/MexTowns.csv")
head(towns)
coordinates(towns) <- ~x + y # turns the data frame into a SpatialPointsDataFrame
                             # by indicating where the coordinates columns
proj4string(towns) <- proj4string(states) # set the projection to SRID = 4326

# Load the points data to the database
writeOGR(obj=towns, dsn="PG:dbname=geostats user=postgres",
         layer_options="geometry_name=geom", layer="towns", driver="PostgreSQL")

# Load some more data
oaks <- read.csv("geostats/textfiles/MexOaks.csv")
coordinates(oaks) <- ~ x + y
proj4string(oaks) <- proj4string(states)

# As Duncan Golicher notices, this is a bit slow, so it might be better to use
# shp2pgsql in command line
writeOGR(obj=oaks, dsn="PG:dbname=geostats user=postgres",
         layer_options="geometry_name=geom", layer="oaks", driver="PostgreSQL")

# Using SQL --------------------------------------------------------------------
# We want to extract all the species of Oaks in the state of Chiapas.

# In R:
oaks$state <- over(oaks, states)$admin_name
chisoaks <- subset(oaks, state == "Chiapas")
chis <- subset(states, admin_name == "Chiapas")
plot(chis)
points(chisoaks, pch = 21, bg = 3, cex = 0.4) # pch: symbol to use
                                              # bg: background color
                                              # cex: character expansion
                                              # I have no clue what that means...
axis(1)
axis(2)
grid()
box()

# Using PostGIS
query <- "select genus, species, st_x(o.geom) x, st_y(o.geom) y
          from oaks o, states s 
          where st_intersects(o.geom, s.geom) 
          and admin_name like 'Chiapas'"
rs <- dbSendQuery(con, query)
chisoaks <- fetch(rs, n=-1)
coordinates(chisoaks) <- ~x + y
plot(chis)
points(chisoaks, pch = 21, bg = 3, cex = 0.4)
grid()
box()
axis(1)
axis(2)

# Buffering --------------------------------------------------------------------

# http://www.postgis.org/docs/ST_Buffer.html
# "Returns a geometry that represents all points whose distance from this 
# Geometry is less than or equal to distance."

query <- "select gid, placename, st_buffer(geom, 0.2) from towns"
rs <- dbSendQuery(con, query)
buffer <- fetch(rs, n=-1)
head(buffer) # R doesn't understand st_buffer geometry

# used the GDAL driver instead
query <- "create view temp_view as select gid, placename, st_buffer(geom, 0.2) from towns"
dbSendQuery(con, query)
buffer <- readOGR("PG:dbname=geostats user=postgres", "temp_view")
query <- "drop view temp_view"
dbSendQuery(con, query)

plot(states)
plot(buffer, add=T)
grid()
box()
axis(1)
axis(2)


# convenience function to use the a temporary view in order to do a query:
getquery <- function(query) {
  query <- paste("create view temp_view as", query)
  dbSendQuery(con, query)
  result <- readOGR("PG:dbname=geostats user=postgres", "temp_view")
  dbSendQuery(con, "drop view temp_view")
  return(result)
}

# now extracting a 10km buffer
buffer <- getquery("select gid, placename, 
                   st_buffer(geom::geography, 10000)::geometry geom 
                   from towns")
plot(states)
plot(buffer, add=T)
grid()
box()
axis(1)
axis(2)

# find all oaks collection within a 10km radius from a city,
# the R way:
d <- over(oaks, buffer)$gid
d <- oaks[!is.na(d),]

# the PostGIS way: (from the blog)
query <- "select o.gid, genus, species, placename, 
                 st_distance(o.geom::geography, t.geom::geography)/1000 distkm
          from towns t, oaks o
          where st_dwithin(t.geom, o.geom, 0.1)"
rs <- dbSendQuery(con, query)
d <- fetch(rs, n=-1)

# the PostGIS way, (with a strict 10km radius, slower though)
query <- "select o.gid, genus, species, placename, 
                 st_distance(o.geom::geography, t.geom::geography)/1000 distkm
          from towns t, oaks o
          where st_dwithin(t.geom::geography, o.geom::geography, 10000)"
rs <- dbSendQuery(con, query)
d <- fetch(rs, n=-1)

# N.B.: It's always a good idea to test a query in the psql console rather than 
# with R. A bad query can kill crash R.

# Create a table with the shortest line

query <- "create table oakstotowns as
          select o.gid, genus, species, placename, 
                 st_distance(o.geom::geography, t.geom::geography)/1000 distkm,
                 st_shortestline(o.geom, t.geom) geom
          from towns t, oaks o
          where st_dwithin(o.geom, t.geom, 0.1)"
dbSendQuery(con, query)


## Raster data in PostGIS ------------------------------------------------------

# Loading raster layers --------------------------------------------------------

# Save it in DB now to avoid some headaches enabling out of db storage
command <- "/opt/local/lib/postgresql93/bin/raster2pgsql -M -F -t 100x100 -d -s 4326 '/Users/denis/Desktop/elevation.tif' elevation | psql -d geostats -U postgres"
system(command) 

# Simple Point Overlay ---------------------------------------------------------

# Using PostGIS
query <- "select o.gid, genus, species, st_value(rast, geom)
          from elevation, oaks o
          where st_intersects(geom, rast)"
rs <- dbSendQuery(con, query)
d <- fetch(rs, n=-1)

# Plotting in R
library(raster)
library(lattice)
elev <- raster('geostats/elevation.tif')
trellis.par.set(regions = list(col = terrain.colors(100)))
pts <- list("sp.points", oaks, pch=4, col='black', cex=0.2)
spplot(elev, sp.layout = list(pts))

oaks$elevation <- extract(elev, oaks)
head(oaks@data)

query <- "create or replace function range_elev (float[]) returns float as'
          x <- arg1
          x <- as.numeric(as.character(x))
          x <- na.omit(x)
          max(x) - min(x)'
          LANGUAGE 'plr' STRICT;"
dbSendQuery(con, query)

query <- "select gid, genus, species,
                 range_elev((st_dumpvalues(st_union(st_clip(rast, geom)))).valarray)
          from (
            select gid, genus, species, st_buffer(geom::geography, 2000)::geometry geom
            from oaks limit 1400) o, elevation
          where st_intersects(rast, geom) group by gid, genus, species;"
rs <- dbSendQuery(con, query)
d <- fetch(rs, n=-1)

histogram(~range_elev | species, data = d, col = 'grey')


# Space-time raster processing -------------------------------------------------

query <- "create schema modis"
dbSendQuery(con, query)

query <- "drop table modis.ndvi cascade"
dbSendQuery(con, query)

query <- "create table modis.ndvi (\nid serial not null primary key, \nrid int not null, \nfdate date not null, \nrast raster\n)"
dbSendQuery(con, query)

path <- 'geostats/modis/'
fls <- dir(path)
yrs <- substring(fls, 1, 4)
for (i in unique(yrs)) {
  query <- paste("create table modis.ndvi_", i, "(CHECK (fdate >= DATE '", 
                 i, "-01-01' AND fdate <= DATE '", i, "-12-31' )) inherits (modis.ndvi);", 
                 sep = "")
  print(query)
  dbSendQuery(con, query)
  subfls <- fls[grep(i, fls)]
  for (f in subfls) {
    if (!grepl('xml', f)) {
      f <- paste(path, f, sep = "")
      command <- paste("/opt/local/lib/postgresql93/bin/raster2pgsql -s 4326 -d  -M ", f, " -F -t 100x100 temp|psql -d geostats -U postgres", 
                       sep = "")
      print(command)
      system(command)
      query <- "alter table temp add column fdate date; update temp set fdate = substring(filename,1, 10)::date;"
      print(query)
      dbSendQuery(con, query)
      query <- paste("insert into modis.ndvi_", i, " (rid,fdate,rast) select rid,fdate,rast from temp;", 
                     sep = "")
      print(query)
      dbSendQuery(con, query)
    }
  }
  query <- paste("CREATE INDEX modis_ndvi_", i, "_spindex ON modis.ndvi_", 
                 i, " using gist(st_convexhull(rast));", sep = "")
  print(query)
  dbSendQuery(con, query)
}

query <- " CREATE OR REPLACE FUNCTION ndvi_mean (float[]) RETURNS float AS '\nx<-arg1\nx<-x[x>1000]\nx<-na.omit(x)\nmean(x)'\nLANGUAGE 'plr' STRICT;"
dbSendQuery(con, query)

query <- "select gid, extract(month from fdate) mon,extract(year from fdate) yr, ndvi_mean((st_dumpvalues(st_union(ST_Clip(rast,geom, true)))).valarray) from modis.ndvi, (select gid,st_buffer(geom::geography,10000)::geometry geom from oaks where species like 'sego%' limit 100) a where st_intersects(geom,rast) group by gid,fdate;"
rs <- dbSendQuery(con, query)
d <- fetch(rs, n=-1)
d$mon <- as.factor(d$mon)
d$yr <- as.factor(d$yr)
boxplot(ndvi_mean ~ mon, data = d, col = "grey")

library(nlme)
mod1 <- lme(ndvi_mean ~ yr + mon, random = ~1 | gid, data = d, method = "ML")
mod2 <- lme(ndvi_mean ~ mon, random = ~1 | gid, data = d, method = "ML")
anova(mod1, mod2)

intervals(mod1)$fixed

