DROP VIEW IF EXISTS wind.windspd;


CREATE VIEW wind.windspd AS
SELECT wind_u.rid, ST_MapAlgebra(wind_u.rast, wind_v.rast, 'sqrt([rast1]*[rast1] + [rast2]*[rast2])') rast
FROM wind_u, wind_v 
WHERE wind_v.date = wind_u.date;