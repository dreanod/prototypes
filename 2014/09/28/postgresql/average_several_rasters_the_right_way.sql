DROP TABLE IF EXISTS my_raster_average;

CREATE TABLE my_raster_average (
	rid int NOT NULL,
	rast raster 
);

INSERT INTO my_raster_average(rid, rast)
SELECT 1, ST_Union(rast, 'MEAN')
FROM myraster;

CREATE INDEX my_raster_average_rast_st_convexhull_idx ON my_raster_average USING gist( ST_ConvexHull(rast));

SELECT AddRasterConstraints('my_raster_average'::name, 'rast'::name);

