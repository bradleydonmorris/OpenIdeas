PRINT 'CREATE SCHEMA [TSDView]'

SELECT
	CONCAT
	(
		N'CREATE OR ALTER VIEW [TSDView].',
		QUOTENAME([tables].[name]),
		N' AS SELECT * FROM ',
		QUOTENAME([schemas].[name]),
		N'.',
		QUOTENAME([tables].[name]),
		N' WITH (NOLOCK)', CHAR(13), CHAR(10), N'GO'
	)
	FROM [sys].[schemas]
		INNER JOIN [sys].[tables]
			ON [schemas].[schema_id] = [tables].[schema_id]