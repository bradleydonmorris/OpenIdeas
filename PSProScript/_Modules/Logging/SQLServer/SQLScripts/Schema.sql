IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
		WHERE [name] = N'Logging'
)
	EXECUTE(N'CREATE SCHEMA [Logging]')
