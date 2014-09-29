SELECT rid, date 
FROM myraster
WHERE date_part('hour', date) = 0;