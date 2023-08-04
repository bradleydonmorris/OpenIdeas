IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
		WHERE [name] = N'DatesAndTimes'
)
	EXECUTE(N'CREATE SCHEMA [DatesAndTimes]')
