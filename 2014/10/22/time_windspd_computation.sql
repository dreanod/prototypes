EXPLAIN ANALYZE
SELECT ST_MapAlgebra(u.rast, v.rast, 'sqrt([rast1]*[rast1] + [rast2]*[rast2])') rast
FROM wind.u10 u, wind.v10 v
WHERE u.date = v.date
	AND extract(year from u.date) = 2001
	AND extract(month from u.date) = 1;