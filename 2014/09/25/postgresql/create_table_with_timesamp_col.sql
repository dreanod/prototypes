DROP TABLE mydate;

CREATE TABLE mydate
(
 	thedate TIMESTAMP WITH TIME ZONE
);

SET datestyle = "ISO, DMY";

INSERT INTO mydate
VALUES ('24-09-2014 13:24+0' :: TIMESTAMP WITH TIME ZONE);

SELECT * FROM mydate;


-- Add 60 minutes to the date and display

SELECT thedate + interval '60 minutes'
FROM mydate;

-- Update the column by adding 60 minutes to the date

UPDATE mydate SET thedate = thedate + interval '180 minutes';

SELECT * FROM mydate;