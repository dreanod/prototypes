CREATE OR REPLACE FUNCTION average_rasters(value double precision [][][], my_position integer [][], VARIADIC userargs text[])
	RETURNS double precision 
	AS $$ '
	mean(value)
'
$$ LANGUAGE 'plr' STRICT;

CREATE TABLE my_raster_average AS
SELECT ST_MapAlgebra(
		ARRAY[ROW(rast, 1)]::rastbandarg[],
		'average_rasters(double precision[], int[], text[])'::regprocedure
		)
FROM myraster GROUP BY filename;