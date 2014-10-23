
CREATE OR REPLACE FUNCTION wind.windspeed(value double precision[][][], positions int[][], VARIADIC userargs text[])
RETURNS double precision
AS $$
BEGIN
  RETURN sqrt(value[1][1][1]^2 + value[2][1][1]^2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;


EXPLAIN ANALYZE
SELECT st_mapalgebra(u.rast, 1,
                     v.rast, 2,
                     'wind.windspeed(double precision[], int[], text[])'::regprocedure)
FROM wind.u10 u, wind.v10 v
WHERE u.date = v.date
  AND extract(month from u.date) = 1
  AND extract(year from v.date)  = 2001;