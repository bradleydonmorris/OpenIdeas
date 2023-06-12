BEGIN
	--Older versions of SQL Server do not support the new TRANSLATE function
	--REPLACE(TRANSLATE([SourcePhone].[Number], N' !"#$%&''()*+,-./:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~', REPLICATE(N' ', 85)), N' ', N'')
	DECLARE @ReturnValue [nvarchar](400) = @Text
	WHILE PATINDEX('%[^0-9]%', @ReturnValue) > 0
		BEGIN
			SET @ReturnValue = STUFF(@ReturnValue, PATINDEX('%[^0-9]%', @ReturnValue), 1, '')
    END
    RETURN @ReturnValue
END
