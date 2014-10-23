# reproducible example
library(rgeos)
library(maptools)

shpct.tf <- tempfile() ; td <- tempdir()

download.file( 
  "ftp://ftp2.census.gov/geo/pvs/tiger2010st/09_Connecticut/09/tl_2010_09_state10.zip" ,
  shpct.tf ,
  mode = 'wb'
)

shpct.uz <- unzip( shpct.tf , exdir = td )

# read in connecticut
ct.shp <- readShapePoly( shpct.uz[ grep( 'shp$' , shpct.uz ) ] )

# box outside of connecticut
# ct.shp.env <- gEnvelope( ct.shp )

# Create a bounding box 10% bigger than the bounding box of connecticut
x_excess = (ct.shp@bbox['x','max'] - ct.shp@bbox['x','min'])*0.1
y_excess = (ct.shp@bbox['y','max'] - ct.shp@bbox['y','min'])*0.1
x_min = ct.shp@bbox['x','min'] - x_excess
x_max = ct.shp@bbox['x','max'] + x_excess
y_min = ct.shp@bbox['y','min'] - y_excess
y_max = ct.shp@bbox['y','max'] + y_excess
bbox = matrix(c(x_min,x_max,x_max,x_min,x_min,
                y_min,y_min,y_max,y_max,y_min),
              nrow = 5, ncol =2)
bbox = Polygon(bbox, hole=FALSE)
bbox = Polygons(list(bbox), "bbox")
ct.shp.out = SpatialPolygons(Srl=list(bbox), pO=1:1, proj4string=ct.shp@proj4string)


# difference between connecticut and its box
# ct.shp.diff <- gDifference( ct.shp.env , ct.shp )
ct.shp.diff <- gDifference( ct.shp.out , ct.shp )


library(ggplot2)


# prepare both shapes for ggplot2
f.ct.shp <- fortify( ct.shp )
outside <- fortify( ct.shp.diff )


# create all layers + projections
plot <- ggplot(data = f.ct.shp, aes(x = long, y = lat))  #start with the base-plot 


layer1 <- geom_polygon(data=f.ct.shp, aes(x=long,y=lat), fill='black')

layer2 <- geom_polygon(data=outside, aes(x=long,y=lat,group=id), fill='white')

co <- coord_map( project = "albers" , lat0 = 40.9836 , lat1 = 42.05014 )

# this works
plot + layer1 

# this works
plot + layer2

# this works
plot + layer1 + layer2

# this does not
plot + layer2 + co

# this also does not
plot + layer1 + layer2 + co

# this looks okay in this example but
# does not work for what i'm trying to do-
# cover up points outside of the state
plot + layer2 + layer1 + co
