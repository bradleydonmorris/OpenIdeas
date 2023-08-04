USE [master]
DECLARE @Object TABLE
(
	[Database] [sys].[sysname],
	[Schema] [sys].[sysname],
	[Object] [sys].[sysname],
	[Type] [sys].[sysname],
	[Definition] [nvarchar](MAX)
)
DECLARE @Query [nvarchar](MAX)
DECLARE @QueryTemplate [nvarchar](MAX) =
N'
SELECT
	N''{@DatabaseName}'' AS [Database],
	[schemas].[name] AS [Schema],
	[objects].[name] AS [Object],
	[objects].[type_desc] AS [Type],
	[sql_modules].[definition] AS [Definition]
	FROM [{@DatabaseName}].[sys].[sql_modules]
		INNER JOIN [{@DatabaseName}].[sys].[objects]
			ON [sql_modules].[object_id] = [objects].[object_id] 
		INNER JOIN [{@DatabaseName}].[sys].[schemas]
			ON [objects].[schema_id] = [schemas].[schema_id]
	WHERE
		[sql_modules].[definition] LIKE N''%substatus%''
		--OR [sql_modules].[definition] LIKE N''%t_process_request_response%''
'
DECLARE @DatabaseName [sysname]

DECLARE _Database CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
	SELECT [name] FROM [master].[sys].[databases]
	WHERE [name] IN (N'42080', N'Reports_Library')
OPEN _Database
FETCH NEXT FROM _Database INTO @DatabaseName
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Query = REPLACE(@QueryTemplate, N'{@DatabaseName}', @DatabaseName)
		INSERT INTO @Object ([Database], [Schema], [Object], [Type], [Definition])
			EXECUTE(@Query)
		FETCH NEXT FROM _Database INTO @DatabaseName
	END
CLOSE _Database
DEALLOCATE _Database
SELECT [Database], [Schema], [Object], [Type], [Definition]
	FROM @Object