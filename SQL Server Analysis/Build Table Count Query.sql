SELECT
CONCAT
(N'UNION ALL SELECT
	N''', DB_NAME(), N''' AS [Database],
	N''', [schemas].[name], N''' AS [Schema],
	N''', [tables].[name], N''' AS [Table],
	COUNT(*) AS [Count],
	N''SELECT * FROM ', QUOTENAME(DB_NAME()), N'.',
	QUOTENAME([schemas].[name]), N'.',
	QUOTENAME([tables].[name]), N''' AS [Select]
	FROM ', QUOTENAME(DB_NAME()), N'.',
	QUOTENAME([schemas].[name]), N'.',
	QUOTENAME([tables].[name])
)
	FROM [sys].[tables]
		INNER JOIN [sys].[schemas]
			ON [tables].[schema_id] = [schemas].[schema_id]