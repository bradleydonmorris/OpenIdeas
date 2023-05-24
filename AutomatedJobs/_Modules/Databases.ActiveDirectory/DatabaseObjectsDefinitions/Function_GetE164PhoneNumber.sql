BEGIN
	DECLARE @ReturnValue [nvarchar](400) =
	CASE
		WHEN LEN(@NormalizedNumber) = 10
			THEN CONCAT(N'+1', @NormalizedNumber)
		WHEN LEN(@NormalizedNumber) > 10
			THEN CONCAT(N'+1', LEFT(@NormalizedNumber, 10))
		ELSE NULL
	END
    RETURN @ReturnValue
END
