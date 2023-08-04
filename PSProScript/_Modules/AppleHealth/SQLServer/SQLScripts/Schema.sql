IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
		WHERE [name] = N'AppleHealth'
)
	EXECUTE(N'CREATE SCHEMA [AppleHealth]')
