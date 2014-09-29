
COPY (
	SELECT ST_AsPNG(ST_Clip(rast, ST_GeomFromText('POLYGON((
		38.35686 23.33625,
		38.35686 24.62099,
		36.88545 23.33625,
		36.88545 24.62099,
		38.35686 23.33625
		))')))
	FROM myraster 
	WHERE rid = 1
) TO 'mypng.png';
