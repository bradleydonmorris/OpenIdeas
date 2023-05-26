DECLARE @ObjectRowCount [int] = 1
DECLARE @LastUsedLevel [int] = 0
DECLARE @ObjectDependency TABLE
(
	[Id] [int] IDENTITY(1, 1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[Type] [nvarchar](60) NOT NULL,
	[Level] [int] NOT NULL
)
INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
	SELECT
		[tables].[object_id] AS [ObjectId],
		[tables].[type_desc] AS [Type],
		0 AS [Level]
		FROM [sys].[tables] WITH (NOLOCK)
			INNER JOIN [sys].[schemas] WITH (NOLOCK)
				ON [tables].[schema_id] = [schemas].[schema_id]
			LEFT OUTER JOIN [sys].[foreign_keys] WITH (NOLOCK)
				ON [tables].[object_id] = [foreign_keys].[parent_object_id]
		WHERE
			[schemas].[name] != N'sys'
			AND [tables].[is_ms_shipped] = 0
			AND [foreign_keys].[object_id] IS NULL
SET @ObjectRowCount = 1
WHILE @ObjectRowCount > 0
	BEGIN
		INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
			SELECT
				[tables].[object_id] AS [ObjectId],
				[tables].[type_desc] AS [Type],
				([@ObjectDependency].[Level] + 1) AS [Level]
				FROM [sys].[tables] WITH (NOLOCK)
					INNER JOIN [sys].[schemas] WITH (NOLOCK)
						ON [tables].[schema_id] = [schemas].[schema_id]
					INNER JOIN [sys].[foreign_keys] WITH (NOLOCK)
						ON [tables].[object_id] = [foreign_keys].[parent_object_id]
					INNER JOIN @ObjectDependency AS [@ObjectDependency]
						ON [foreign_keys].[referenced_object_id] = [@ObjectDependency].[ObjectId]
					LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency_Exists]
						ON [tables].[object_id] = [@ObjectDependency_Exists].[ObjectId]
				WHERE
					[tables].[is_ms_shipped] = 0
					AND [schemas].[name] != N'sys'
					AND [tables].[is_ms_shipped] = 0
					AND [@ObjectDependency_Exists].[ObjectId] IS NULL
		SET @ObjectRowCount = @@ROWCOUNT
		RAISERROR(N'Current Row Count: %i', 1, 1, @ObjectRowCount) WITH NOWAIT
	END
SELECT @LastUsedLevel = MAX([Level])
	FROM @ObjectDependency
INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
	SELECT
		[objects].[object_id] AS [ObjectId],
		[objects].[type_desc] AS [Type],
		(@LastUsedLevel + 1) AS [Level]
		FROM [sys].[objects] WITH (NOLOCK)
			INNER JOIN [sys].[schemas] WITH (NOLOCK)
				ON [objects].[schema_id] = [schemas].[schema_id]
			LEFT OUTER JOIN
			(
				SELECT
					[sql_dependencies].[object_id],
					COUNT(*) AS [Count]
					FROM [sys].[sql_dependencies] WITH (NOLOCK)
						LEFT OUTER JOIN [sys].[objects] WITH (NOLOCK)
							ON [sql_dependencies].[referenced_major_id] = [objects].[object_id]
					WHERE [objects].[type_desc] != N'USER_TABLE'
					GROUP BY
						[sql_dependencies].[object_id]
			) AS [sql_dependencies]
				ON [objects].[object_id] = [sql_dependencies].[object_id]
		WHERE
			ISNULL([sql_dependencies].[Count], 0) = 0
			AND [objects].[type_desc] IN
			(
				N'SQL_STORED_PROCEDURE',
				N'VIEW',
				N'SQL_INLINE_TABLE_VALUED_FUNCTION',
				N'SQL_TABLE_VALUED_FUNCTION',
				N'SQL_SCALAR_FUNCTION'
			)
SET @ObjectRowCount = 1
WHILE @ObjectRowCount > 0
	BEGIN
		INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
			SELECT
				[objects].[object_id] AS [ObjectId],
				[objects].[type_desc] AS [Type],
				([@ObjectDependency].[Level] + 1) AS [Level]
				FROM [sys].[objects] WITH (NOLOCK)
					INNER JOIN [sys].[schemas] WITH (NOLOCK)
						ON [objects].[schema_id] = [schemas].[schema_id]
					INNER JOIN [sys].[sql_dependencies] WITH (NOLOCK)
						ON [sql_dependencies].[object_id] = [objects].[object_id]
					INNER JOIN @ObjectDependency AS [@ObjectDependency]
						ON [sql_dependencies].[referenced_major_id] = [@ObjectDependency].[ObjectId]
					LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency_Exists]
						ON [objects].[object_id] = [@ObjectDependency_Exists].[ObjectId]
				WHERE
					[objects].[is_ms_shipped] = 0
					AND [@ObjectDependency_Exists].[ObjectId] IS NULL
		SET @ObjectRowCount = @@ROWCOUNT
		RAISERROR(N'Current Row Count: %i', 1, 1, @ObjectRowCount) WITH NOWAIT
	END
INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
	SELECT
		[objects].[object_id] AS [ObjectId],
		[objects].[type_desc] AS [Type],
		CASE
			WHEN [objects].[type_desc] = N'USER_TABLE'
				THEN 0
			ELSE (@LastUsedLevel + 1)
		END AS [Level]
		FROM [sys].[objects] WITH (NOLOCK)
			INNER JOIN [sys].[schemas] WITH (NOLOCK)
				ON [objects].[schema_id] = [schemas].[schema_id]
			LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency]
				ON [objects].[object_id] = [@ObjectDependency].[ObjectId]
		WHERE
			[@ObjectDependency].[ObjectId] IS NULL
			AND [objects].[is_ms_shipped] = 0
			AND [objects].[type_desc] IN
			(
				N'SQL_INLINE_TABLE_VALUED_FUNCTION',
				N'SQL_SCALAR_FUNCTION',
				N'SQL_STORED_PROCEDURE',
				N'SQL_TABLE_VALUED_FUNCTION',
				N'USER_TABLE',
				N'VIEW'
			)
SELECT
	ROW_NUMBER() OVER (
		ORDER BY 
			CASE
				WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
				ELSE 1
			END ASC,
			[@ObjectDependency].[Level] ASC,
			CASE
				WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN 3
				WHEN [objects].[type_desc] = N'VIEW' THEN 2
				WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN 1
				WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
				ELSE (-1)
			END ASC,
			[schemas].[name] ASC,
			[objects].[name] ASC
	) AS [CreateOrder],
	ROW_NUMBER() OVER (
		ORDER BY 
			CASE
				WHEN [Type] = 'Table' THEN 0
				ELSE 1
			END DESC,
			[@ObjectDependency].[Level] DESC,
			CASE
				WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN 3
				WHEN [objects].[type_desc] = N'VIEW' THEN 2
				WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
				WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN 1
				WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
				ELSE (-1)
			END DESC,
			[schemas].[name] DESC,
			[objects].[name] DESC
	) AS [DropOrder],
	[objects].[object_id] AS [ObjectId],
	[schemas].[name] AS [Schema],
	[objects].[name] AS [Name],
	CASE
		WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
		WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
		WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
		ELSE CONCAT(N'OTHER: ', [objects].[type_desc])
	END AS [SimpleType],
	[objects].[type_desc] AS [Type],
	CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [QualifiedName]
	FROM
	(
		SELECT
			[@ObjectDependency].[ObjectId],
			MAX([@ObjectDependency].[Level]) AS [Level]
			FROM @ObjectDependency AS [@ObjectDependency]
			GROUP BY [@ObjectDependency].[ObjectId]
	) AS [@ObjectDependency]
		INNER JOIN [sys].[objects] WITH (NOLOCK)
			ON [@ObjectDependency].[ObjectId] = [objects].[object_id]
		INNER JOIN [sys].[schemas] WITH (NOLOCK)
			ON [objects].[schema_id] = [schemas].[schema_id]
