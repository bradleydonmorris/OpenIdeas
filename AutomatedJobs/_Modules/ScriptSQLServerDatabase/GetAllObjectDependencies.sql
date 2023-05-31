DECLARE @ReleventObject TABLE
(
	[object_id] [int] NOT NULL,
	[Schema] [sys].[sysname] NOT NULL,
	[Object] [sys].[sysname] NULL,
	[Type] [sys].[sysname] NOT NULL,
	[SimpleType] [sys].[sysname] NOT NULL
)
DECLARE @ObjectLevel TABLE
(
	[object_id] [int] NOT NULL,
	[needs_object_id] [int] NULL,
	[Level] [int] NOT NULL
)
DECLARE @RowCount [int] = 1
DECLARE @Level [int] = 1


INSERT INTO @ReleventObject ([object_id], [Schema], [Object], [Type], [SimpleType])
SELECT DISTINCT
	0 AS [object_id],
	[schemas].[name] AS [Schema],
	NULL AS [Object],
	N'SCHEMA' AS [Type],
	N'Schema' AS [SimpleType]
	FROM [sys].[schemas]
		INNER JOIN [sys].[objects]
			ON [schemas].[schema_id] = [objects].[schema_id]
	WHERE [schemas].[name] NOT IN (N'sys', N'dbo')

INSERT INTO @ReleventObject ([object_id], [Schema], [Object], [Type], [SimpleType])
SELECT
	[objects].[object_id],
	[schemas].[name] AS [Schema],
	[objects].[name] AS [Object],
	[objects].[type_desc] AS [Type],
	CASE
		WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
		WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
		WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
		ELSE CONCAT(N'OTHER: ', [objects].[type_desc])
	END AS [SimpleType]
	FROM [sys].[objects] WITH (NOLOCK)
		INNER JOIN [sys].[schemas] WITH (NOLOCK)
			ON [objects].[schema_id] = [schemas].[schema_id]
	WHERE
		[schemas].[name] != N'sys'
		AND [objects].[is_ms_shipped] = 0
		AND [objects].[type_desc] IN
		(
			N'USER_TABLE',
			N'SQL_STORED_PROCEDURE',
			N'VIEW',
			N'SQL_INLINE_TABLE_VALUED_FUNCTION',
			N'SQL_TABLE_VALUED_FUNCTION',
			N'SQL_SCALAR_FUNCTION'
		)

--Schema
INSERT INTO @ObjectLevel([Level], [object_id], [needs_object_id])
	VALUES(0, 0, NULL)

--Tables that aren't referencing other tables
INSERT INTO @ObjectLevel([Level], [object_id], [needs_object_id])
	SELECT
		@Level AS [Level],
		[@ReleventObject].[object_id],
		NULL AS [needs_object_id]
		FROM @ReleventObject AS [@ReleventObject]
			LEFT OUTER JOIN [sys].[foreign_keys]
				ON [foreign_keys].[parent_object_id] = [@ReleventObject].[object_id]
		WHERE
			[foreign_keys].[object_id] IS NULL
			AND [@ReleventObject].[Type] = N'USER_TABLE'
WHILE @RowCount > 0
	BEGIN
		INSERT INTO @ObjectLevel([Level], [object_id], [needs_object_id])
			SELECT
				(@Level + 1) AS [Level],
				[@ReleventObject].[object_id],
				[@ObjectLevel].[object_id] AS [needs_object_id]
				FROM @ReleventObject AS [@ReleventObject]
					INNER JOIN [sys].[foreign_keys]
						ON [foreign_keys].[parent_object_id] = [@ReleventObject].[object_id]
					INNER JOIN @ObjectLevel AS [@ObjectLevel]
						ON [foreign_keys].[referenced_object_id] = [@ObjectLevel].[object_id]
				WHERE
					[@ObjectLevel].[Level] = @Level
					AND [@ReleventObject].[Type] = N'USER_TABLE'
		SET @RowCount = @@ROWCOUNT
		SET @Level += 1
	END
INSERT INTO @ObjectLevel([Level], [object_id], [needs_object_id])
	SELECT
		(@Level + 1) AS [Level],
		[@ReleventObject].[object_id],
		[@ObjectLevel].[object_id] AS [needs_object_id]
		FROM [sys].[sql_expression_dependencies] WITH (NOLOCK)
			INNER JOIN @ReleventObject AS [@ReleventObject]
				ON
					[sql_expression_dependencies].[referencing_id] = [@ReleventObject].[object_id]
					AND [sql_expression_dependencies].[referencing_minor_id] = 0
			INNER JOIN @ObjectLevel AS [@ObjectLevel]
				ON
					[sql_expression_dependencies].[referenced_id] = [@ObjectLevel].[object_id]
					AND [sql_expression_dependencies].[referenced_minor_id] = 0
SET @Level += 1
SET @RowCount = 1
WHILE @RowCount > 0
	BEGIN
		INSERT INTO @ObjectLevel([Level], [object_id], [needs_object_id])
			SELECT
				(@Level + 1) AS [Level],
				[@ReleventObject].[object_id],
				[@ObjectLevel].[object_id] AS [needs_object_id]
				FROM [sys].[sql_expression_dependencies] WITH (NOLOCK)
					INNER JOIN @ReleventObject AS [@ReleventObject]
						ON
							[sql_expression_dependencies].[referencing_id] = [@ReleventObject].[object_id]
							AND [sql_expression_dependencies].[referencing_minor_id] = 0
					INNER JOIN @ObjectLevel AS [@ObjectLevel]
						ON
							[sql_expression_dependencies].[referenced_id] = [@ObjectLevel].[object_id]
							AND [sql_expression_dependencies].[referenced_minor_id] = 0
				WHERE [@ObjectLevel].[Level] = @Level
		SET @RowCount = @@ROWCOUNT
		SET @Level += 1
	END
INSERT INTO @ObjectLevel([Level], [object_id], [needs_object_id])
	SELECT
		(@Level + 1) AS [Level],
		[@ReleventObject].[object_id],
		NULL AS [needs_object_id]
		FROM @ReleventObject AS [@ReleventObject]
			LEFT OUTER JOIN @ObjectLevel AS [@ObjectLevel]
				ON [@ReleventObject].[object_id] = [@ObjectLevel].[object_id]
		WHERE [@ObjectLevel].[object_id] IS NULL
SELECT
	[@ReleventObject].[object_id],
	[@ReleventObject].[Schema],
	[@ReleventObject].[Object] AS [Name],
	[@ReleventObject].[Type],
	[@ReleventObject].[SimpleType],
	[@ObjectLevel_MaximumLevel].[Level],
	ROW_NUMBER() OVER (
		ORDER BY 
			CASE
				WHEN [@ReleventObject].[Type] = N'SCHEMA' THEN 0
				WHEN [@ReleventObject].[Type] = N'USER_TABLE' THEN 1
				ELSE 2
			END ASC,
			[@ObjectLevel_MaximumLevel].[Level] ASC,
			CASE
				WHEN [@ReleventObject].[Type] = N'SQL_STORED_PROCEDURE' THEN 3
				WHEN [@ReleventObject].[Type] = N'VIEW' THEN 2
				WHEN [@ReleventObject].[Type] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [@ReleventObject].[Type] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [@ReleventObject].[Type] = N'SQL_SCALAR_FUNCTION' THEN 1
				WHEN [@ReleventObject].[Type] = N'USER_TABLE' THEN 0
				ELSE (-1)
			END ASC,
			[@ReleventObject].[Schema] ASC,
			[@ReleventObject].[Object] ASC
	) AS [CreateOrder],
	ROW_NUMBER() OVER (
		ORDER BY 
			CASE
				WHEN [@ReleventObject].[Type] = N'SCHEMA' THEN 0
				WHEN [@ReleventObject].[Type] = N'USER_TABLE' THEN 1
				ELSE 2
			END DESC,
			[@ObjectLevel_MaximumLevel].[Level] DESC,
			CASE
				WHEN [@ReleventObject].[Type] = N'SQL_STORED_PROCEDURE' THEN 3
				WHEN [@ReleventObject].[Type] = N'VIEW' THEN 2
				WHEN [@ReleventObject].[Type] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [@ReleventObject].[Type] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [@ReleventObject].[Type] = N'SQL_SCALAR_FUNCTION' THEN 1
				WHEN [@ReleventObject].[Type] = N'USER_TABLE' THEN 0
				ELSE (-1)
			END DESC,
			[@ReleventObject].[Schema] DESC,
			[@ReleventObject].[Object] DESC
	) AS [DropOrder]
	FROM
	(
		SELECT DISTINCT
			[@ObjectLevel].[object_id],
			MAX([@ObjectLevel].[Level]) AS [Level]
			FROM @ObjectLevel AS [@ObjectLevel]
			GROUP BY [@ObjectLevel].[object_id]
	) AS [@ObjectLevel_MaximumLevel]
		INNER JOIN @ReleventObject AS [@ReleventObject]
			ON [@ObjectLevel_MaximumLevel].[object_id] = [@ReleventObject].[object_id]
	ORDER BY [@ObjectLevel_MaximumLevel].[Level]
