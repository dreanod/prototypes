CREATE OR REPLACE FUNCTION chap5.modis_evi(value double precision[][][], my_position int[][], VARIADIC userargs text[])
RETURNS double precision
AS $$
DECLARE 
	L double precision;
	C1 double precision;
	C2 double precision;
	G double precision;
	_value double precision[3];
	_n double precision;
	_d double precision;
BEGIN
	-- userargs provides coefficients
	L := userargs[1]::double precision;
	C1 := userargs[2]::double precision;
	C2 := userargs[3]:: double precision;
	G := userargs[4]:: double precision;
	-- rescale values, optional
	_value[1] := value[1][1][1] * 0.0001;
	_value[2] := value[2][1][1] * 0.0001;
	_value[3] := value[3][1][1] * 0.0001;
	-- value can't be NULL
	IF
		_value[1] IS NULL OR
		_value[2] IS NULL OR
		_value[3] IS NULL
	THEN 
		RETURN NULL;
	END IF;
	-- compute numerator and denominator 
	_n := (_value[3] - _value[1]);
	_d := (_value[3] + (C1 * _value[1]) - (C2 * _value[2]) + L);
	-- prevent divition by zero
	IF _d::numeric(16, 10) = 0.::numeric(16, 10) THEN RETURN NULL;
	END IF;
	RETURN G * (_n / _d);
END;
$$ LANGUAGE plpgsql IMMUTABLE;
