DROP TABLE IF EXISTS my_windspd;

CREATE TABLE my_windspd (
	rid int NOT NULL,
	rast raster 
);

INSERT INTO my_windspd(rid, rast)
SELECT wind_u.rid, ST_MapAlgebra(wind_u.rast, wind_v.rast, 'sqrt([rast1]*[rast1] + [rast2]*[rast2])')
FROM wind_u, wind_v 
WHERE wind_v.date = wind_u.date;

-- CREATE INDEX my_windspd_rast_st_convexhull_idx ON my_windspd USING gist( ST_ConvexHull(rast));

-- SELECT AddRasterConstraints('my_windspd'::name, 'rast'::name);
