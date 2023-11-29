USE [master]
DECLARE @StringsToFindAND TABLE
(
	[Id] [int] IDENTITY(1, 1) NOT NULL,
	[String] [nvarchar](MAX) NOT NULL
)
INSERT INTO @StringsToFindAND([String]) VALUES
	(N'INTO'),
	(N'#')

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
'
SELECT
	@QueryTemplate += CASE
		WHEN [Id] = 1
			THEN CONCAT(CHAR(9), CHAR(9), '[sql_modules].[definition] LIKE N''%', [String], N'%''', CHAR(13), CHAR(10))
		ELSE CONCAT(CHAR(9), CHAR(9), 'AND [sql_modules].[definition] LIKE N''%', [String], N'%''', CHAR(13), CHAR(10))
	END
	FROM @StringsToFindAND

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
