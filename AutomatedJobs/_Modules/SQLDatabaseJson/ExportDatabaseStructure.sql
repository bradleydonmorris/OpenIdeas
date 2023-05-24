DECLARE @SchemaName [sys].[sysname] = N'$(SchemaName)'

DECLARE @True [bit] = 1
DECLARE @False [bit] = 0
DECLARE @HeapFileGroupName [sys].[sysname]
DECLARE @IndexFileGroupName [sys].[sysname]
DECLARE @LobFileGroupName [sys].[sysname]
DECLARE @ObjectDependency TABLE
(
	[Id] [int] IDENTITY(1, 1) NOT NULL,
	[Type] [nvarchar](10) NOT NULL,
	[object_id] [int] NOT NULL,
	[Qualified] [nvarchar](261) NOT NULL,
	[Level] [int] NOT NULL,
	[CreateOrder] [int] NULL,
	[DropOrder] [int] NULL
)
;WITH
[TableRecursion]
AS
(
	SELECT
		[tables].[object_id],
		0 AS [Level],
		CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([tables].[name])) AS [Qualified]
		FROM [sys].[tables]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
			LEFT OUTER JOIN [sys].[foreign_keys]
				ON [tables].[object_id] = [foreign_keys].[parent_object_id]
		WHERE
			[foreign_keys].[object_id] IS NULL
			AND [schemas].[name] = @SchemaName
	UNION ALL SELECT
		[tables].[object_id],
		([TableRecursion].[Level] + 1) AS [Level],
		CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([tables].[name])) AS [Qualified]
		FROM [sys].[tables]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
			INNER JOIN [sys].[foreign_keys]
				ON [tables].[object_id] = [foreign_keys].[parent_object_id]
			INNER JOIN [TableRecursion]
				ON [foreign_keys].[referenced_object_id] = [TableRecursion].[object_id]
)
INSERT INTO @ObjectDependency([Type], [object_id], [Qualified], [Level])
SELECT
	CASE
		WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
		WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
		WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
	END AS [Type],
	[objects].[object_id],
	CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [Qualified],
	[Recursion].[Level]
	FROM
	(
		SELECT
			[TableRecursion].[object_id],
			MAX([TableRecursion].[Level]) AS [Level]
			FROM [TableRecursion]
			GROUP BY [TableRecursion].[object_id]
	) AS [Recursion]
		INNER JOIN [sys].[objects]
			ON [Recursion].[object_id] = [objects].[object_id]
		INNER JOIN [sys].[schemas]
			ON [objects].[schema_id] = [schemas].[schema_id]
	ORDER BY [Recursion].[Level]
;WITH
[NonTableRecursion]
AS
(
	SELECT
		[objects].[object_id],
		0 AS [Level],
		CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [Qualified]
		FROM [sys].[objects]
			INNER JOIN [sys].[schemas]
				ON [objects].[schema_id] = [schemas].[schema_id]
			LEFT OUTER JOIN
			(
				SELECT
					[sql_dependencies].[object_id],
					COUNT(*) AS [Count]
					FROM [sys].[sql_dependencies]
						LEFT OUTER JOIN [sys].[objects]
							ON [sql_dependencies].[referenced_major_id] = [objects].[object_id]
					WHERE [objects].[type_desc] != N'USER_TABLE'
					GROUP BY
						[sql_dependencies].[object_id]
			) AS [sql_dependencies]
				ON [objects].[object_id] = [sql_dependencies].[object_id]
		WHERE
			[schemas].[name] = @SchemaName
			AND ISNULL([sql_dependencies].[Count], 0) = 0
			AND [objects].[type_desc] IN
			(
				N'SQL_STORED_PROCEDURE',
				N'VIEW',
				N'SQL_INLINE_TABLE_VALUED_FUNCTION',
				N'SQL_TABLE_VALUED_FUNCTION',
				N'SQL_SCALAR_FUNCTION'
			)
	UNION ALL SELECT
		[objects].[object_id],
		([NonTableRecursion].[Level] + 1) AS [Level],
		CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [Qualified]
		FROM [sys].[objects]
			INNER JOIN [sys].[schemas]
				ON [objects].[schema_id] = [schemas].[schema_id]
			INNER JOIN [sys].[sql_dependencies]
				ON [sql_dependencies].[object_id] = [objects].[object_id]
			INNER JOIN [NonTableRecursion]
				ON [sql_dependencies].[referenced_major_id] = [NonTableRecursion].[object_id]
)
INSERT INTO @ObjectDependency([Type], [object_id], [Qualified], [Level])
SELECT
	CASE
		WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
		WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
		WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
		WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
	END AS [Type],
	[objects].[object_id],
	CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [Qualified],
	[Recursion].[Level]
	FROM [sys].[objects]
		INNER JOIN [sys].[schemas]
			ON [objects].[schema_id] = [schemas].[schema_id]
		INNER JOIN
		(
			SELECT
				[NonTableRecursion].[object_id],
				MAX([NonTableRecursion].[Level]) AS [Level]
				FROM [NonTableRecursion]
				GROUP BY [NonTableRecursion].[object_id]
		) AS [Recursion]
			ON [Recursion].[object_id] = [objects].[object_id]
	WHERE
		[schemas].[name] = @SchemaName
		AND [objects].[type_desc] IN
		(
			N'SQL_STORED_PROCEDURE',
			N'VIEW',
			N'SQL_INLINE_TABLE_VALUED_FUNCTION',
			N'SQL_TABLE_VALUED_FUNCTION',
			N'SQL_SCALAR_FUNCTION'
		)
	ORDER BY [Recursion].[Level]
UPDATE @ObjectDependency
	SET
		[CreateOrder] = [Order].[CreateOrder],
		[DropOrder] = [Order].[DropOrder]
	FROM @ObjectDependency AS [@ObjectDependency]
		INNER JOIN
		(
			SELECT
				[Id],
				ROW_NUMBER() OVER (
					ORDER BY 
						CASE
							WHEN [Type] = 'Table' THEN 0
							ELSE 1
						END ASC,
						[@ObjectDependency].[Level] ASC,
						CASE
							WHEN [Type] = N'Procedure' THEN 3
							WHEN [Type] = N'View' THEN 2
							WHEN [Type] = N'Function' THEN 1
							WHEN [Type] = N'Table' THEN 0
						END ASC,
						[@ObjectDependency].[Qualified] ASC
				) AS [CreateOrder],
				ROW_NUMBER() OVER (
					ORDER BY 
						CASE
							WHEN [Type] = 'Table' THEN 0
							ELSE 1
						END DESC,
						[@ObjectDependency].[Level] DESC,
						CASE
							WHEN [Type] = N'Procedure' THEN 3
							WHEN [Type] = N'View' THEN 2
							WHEN [Type] = N'Function' THEN 1
							WHEN [Type] = N'Table' THEN 0
						END DESC,
						[@ObjectDependency].[Qualified] DESC
				) AS [DropOrder]
				FROM @ObjectDependency AS [@ObjectDependency]
		) AS [Order]
			ON [@ObjectDependency].[Id] = [Order].[Id]
SELECT @HeapFileGroupName = [ByCount].[name]
	FROM
	(
		SELECT
			[filegroups].[name],
			COUNT(*) AS [Count]
			FROM [sys].[tables]
				INNER JOIN [sys].[schemas]
					ON [tables].[schema_id] = [schemas].[schema_id]
				INNER JOIN [sys].[indexes]
					ON
						[tables].[object_id] = [indexes].[object_id]
						AND [indexes].[index_id] IN (0, 1)
				INNER JOIN [sys].[filegroups]
					ON [indexes].[data_space_id] = [filegroups].[data_space_id]
			WHERE
				[schemas].[name] = @SchemaName
				AND [indexes].[type_desc] = N'HEAP'
			GROUP BY [filegroups].[name]
	) AS [ByCount]
	ORDER BY 
		[ByCount].[Count] DESC,
		[ByCount].[name] ASC
SELECT @IndexFileGroupName = [ByCount].[name]
	FROM
	(
		SELECT
			[filegroups].[name],
			COUNT(*) AS [Count]
			FROM [sys].[tables]
				INNER JOIN [sys].[schemas]
					ON [tables].[schema_id] = [schemas].[schema_id]
				INNER JOIN [sys].[indexes]
					ON
						[tables].[object_id] = [indexes].[object_id]
						AND [indexes].[index_id] IN (0, 1)
				INNER JOIN [sys].[filegroups]
					ON [indexes].[data_space_id] = [filegroups].[data_space_id]
			WHERE
				[schemas].[name] = @SchemaName
				AND [indexes].[type_desc] != N'HEAP'
			GROUP BY [filegroups].[name]
	) AS [ByCount]
	ORDER BY 
		[ByCount].[Count] DESC,
		[ByCount].[name] ASC
SELECT @LobFileGroupName = [ByCount].[name]
	FROM
	(
		SELECT
			[filegroups_LOB].[name],
			COUNT(*) AS [Count]
			FROM [sys].[tables]
				INNER JOIN [sys].[schemas]
					ON [tables].[schema_id] = [schemas].[schema_id]
				LEFT JOIN [sys].[filegroups] AS [filegroups_LOB]
					ON [tables].[lob_data_space_id] = [filegroups_LOB].[data_space_id]
			WHERE [schemas].[name] = @SchemaName
			GROUP BY [filegroups_LOB].[name]
	) AS [ByCount]
	ORDER BY 
		[ByCount].[Count] DESC,
		[ByCount].[name] ASC
SET @HeapFileGroupName = ISNULL(@HeapFileGroupName, @IndexFileGroupName)
SET @LobFileGroupName = ISNULL(@LobFileGroupName, @HeapFileGroupName)
SELECT CONVERT([nvarchar](MAX),
(
SELECT
	JSON_QUERY((
		SELECT DISTINCT
			@HeapFileGroupName AS [HeapFileGroupName],
			@IndexFileGroupName AS [IndexFileGroupName],
			@LobFileGroupName AS [LobFileGroupName]
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)) AS [Storage],
	JSON_QUERY((
		SELECT
			[Objects].[Sequence],
			[Objects].[Type],
			[Objects].[Name]
			FROM
			(
				SELECT
					ROW_NUMBER() OVER ( ORDER BY [@ObjectDependency].[DropOrder] ASC) AS [Sequence],
					CASE
						WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
						WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
						WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
						WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
						WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
						WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
					END AS [Type],
					[objects].[name] AS [Name]
					FROM [sys].[objects]
						INNER JOIN [sys].[schemas]
							ON [objects].[schema_id] = [schemas].[schema_id]
						LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency]
							ON [objects].[object_id] = [@ObjectDependency].[object_id]
					WHERE
						[schemas].[name] = @SchemaName
						AND [objects].[type_desc] IN
						(
							N'SQL_SCALAR_FUNCTION',
							N'SQL_STORED_PROCEDURE',
							N'SQL_TABLE_VALUED_FUNCTION',
							N'SQL_INLINE_TABLE_VALUED_FUNCTION',
							N'USER_TABLE',
							N'VIEW'
						)
			) AS [Objects]
			ORDER BY [Objects].[Sequence] ASC
			FOR JSON PATH
	)) AS [DropSequence],
	JSON_QUERY((
		SELECT
			ROW_NUMBER() OVER (ORDER BY [@ObjectDependency].[CreateOrder] ASC) AS [Sequence],
			NULLIF([filegroups].[name], @HeapFileGroupName) AS [HeapFileGroupName],
			NULLIF([filegroups_LOB].[name], @LobFileGroupName) AS [LobFileGroupName],
			[tables].[name] AS [Name],
			JSON_QUERY((
				SELECT
					COLUMNPROPERTY([columns].[object_id], [columns].[name], 'ordinal') AS [Ordinal],
					IIF
					(
						[columns].[is_identity] = 1,
							CONCAT([tables].[name], N'Id'),
							[columns].[name]
					) AS [Name],
					(
						CASE
							WHEN [types_User].[name] IS NOT NULL
								THEN
								(
									N'['
									+ [schemas_UserType].[name]
									+ N'].['
									+ [types_User].[name]
									+ N']'
								)
							ELSE
							(
								N'['
								+ [types_System].[name]
								+ N']'
							)
						END
						+
						CASE
							WHEN
							(
								[types_System].[name] = N'image'
								OR [types_System].[name] = N'text'
								OR [types_System].[name] = N'uniqueidentifier'
								OR [types_System].[name] = N'date'
								OR [types_System].[name] = N'tinyint'
								OR [types_System].[name] = N'smallint'
								OR [types_System].[name] = N'int'
								OR [types_System].[name] = N'smalldatetime'
								OR [types_System].[name] = N'datetime'
								OR [types_System].[name] = N'money'
								OR [types_System].[name] = N'smallmoney'
								OR [types_System].[name] = N'real'
								OR [types_System].[name] = N'float'
								OR [types_System].[name] = N'sql_variant'
								OR [types_System].[name] = N'text'
								OR [types_System].[name] = N'bit'
								OR [types_System].[name] = N'bigint'
								OR [types_System].[name] = N'hierarchyid'
								OR [types_System].[name] = N'geometry'
								OR [types_System].[name] = N'geography'
								OR [types_System].[name] = N'timestamp'
								OR [types_System].[name] = N'xml'
								OR
								(
									[types_System].[name] = N'nvarchar'
									AND [types_User].[name] = N'sysname'
									AND [schemas_UserType].[name] = N'sys'
								)
							)
								THEN ''
							WHEN
							(
								[types_System].[name] = N'varbinary'
								OR [types_System].[name] = N'varchar'
								OR [types_System].[name] = N'binary'
								OR [types_System].[name] = N'char'
								OR [types_System].[name] = N'nvarchar'
								OR [types_System].[name] = N'nchar'
							)
								THEN
								(
									CASE
										WHEN CONVERT([int], COLUMNPROPERTY([tables].[object_id], [columns].[name], 'CharMaxLen'), 0) = (-1)
											THEN '(MAX)'
										ELSE
										(
											'('
											+ CONVERT([varchar](11), CONVERT([int], COLUMNPROPERTY([tables].[object_id], [columns].[name], 'CharMaxLen'), 0), 0)
											+ ')'
										)
									END
								)
							WHEN
							(
								[types_System].[name] = N'time'
								OR [types_System].[name] = N'datetime2'
								OR [types_System].[name] = N'datetimeoffset'
							)
								THEN
								(
									'('
									+ CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [columns].[scale]))
									+ ')'
								)
							WHEN
							(
								[types_System].[name] = N'decimal'
								OR [types_System].[name] = N'numeric'
							)
								THEN
								(
									'('
									+ CONVERT([varchar](11), [columns].[precision], 0)
									+ ', '
									+ CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [columns].[scale]), 0)
									+ ')'
								)
						END
					) AS [CondensedType],
					CASE
						WHEN [types_User].[name] IS NOT NULL
							THEN CONCAT
							(
								[schemas_UserType].[name],
								+ N'.'
								+ [types_User].[name]
							)
						ELSE [types_System].[name]
					END AS [Type],
					CASE
						WHEN
						(
							[schemas_UserType].[name] = N'sys'
							AND [types_User].[name] = N'sysname'
						)
							THEN NULL
						WHEN
						(
							[types_System].[name] = N'varbinary'
							OR [types_System].[name] = N'varchar'
							OR [types_System].[name] = N'binary'
							OR [types_System].[name] = N'char'
							OR [types_System].[name] = N'nvarchar'
							OR [types_System].[name] = N'nchar'
						)
							THEN CONVERT([int], COLUMNPROPERTY([columns].[object_id], [columns].[name], 'CharMaxLen'), 0)
						WHEN
						(
							[types_System].[name] = N'time'
							OR [types_System].[name] = N'datetime2'
							OR [types_System].[name] = N'datetimeoffset'
						)
							THEN ODBCSCALE([types_System].[system_type_id], [columns].[scale])
					END AS [TypeLength],
					CASE
						WHEN
						(
							[types_System].[name] = N'decimal'
							OR [types_System].[name] = N'numeric'
						)
							THEN [columns].[precision]
						ELSE NULL
					END AS [TypePrecision],
					CASE
						WHEN
						(
							[types_System].[name] = N'decimal'
							OR [types_System].[name] = N'numeric'
						)
							THEN ODBCSCALE([types_System].[system_type_id], [columns].[scale])
						ELSE NULL
					END AS [TypeScale],
					[columns].[is_nullable] AS [IsNullable],
					[columns].[is_identity] AS [IsIdentity],
					[columns].[is_rowguidcol] AS [IsRowGUID],
					ISNULL([PrimaryKey].[IsPrimaryKey], @False) AS [IsPrimaryKey],
					JSON_QUERY((
						SELECT
							[default_constraints].[definition] AS [Definition]
							FROM [sys].[default_constraints]
							WHERE [default_constraints].[object_id] = [columns].[default_object_id]
							FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS [Default],
					JSON_QUERY((
						SELECT
							[computed_columns].[definition] AS [Definition]
							FROM [sys].[computed_columns]
							WHERE
								[computed_columns].[object_id] = [tables].[object_id]
								AND [computed_columns].[column_id] = [columns].[column_id]
							FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS [Computation],
					JSON_QUERY((
						SELECT
							[schemas_Referenced].[name] AS [Schema],
							[objects_Referenced].[name] AS [Table],
							[columns_Referenced].[name] AS [Column],
							IIF
							(
								[columns_Foreign].[name] != [columns_Referenced].[name],
									REPLACE([columns_Foreign].[name], [columns_Referenced].[name], N''),
									NULL
							) AS [Suffix]
							FROM [sys].[foreign_keys]
								INNER JOIN [sys].[foreign_key_columns]
									ON [foreign_keys].[object_id] = [foreign_key_columns].[constraint_object_id]
								INNER JOIN [sys].[columns] AS [columns_Foreign]
									ON
										[foreign_key_columns].[parent_object_id] = [columns_Foreign].[object_id]
										AND [foreign_key_columns].[parent_column_id] = [columns_Foreign].[column_id]
								INNER JOIN [sys].[objects] AS [objects_Referenced]
									ON [foreign_keys].[referenced_object_id] = [objects_Referenced].[object_id]
								INNER JOIN [sys].[schemas] AS [schemas_Referenced]
									ON [objects_Referenced].[schema_id] = [schemas_Referenced].[schema_id]
								INNER JOIN [sys].[columns] AS [columns_Referenced]
									ON
										[objects_Referenced].[object_id] = [columns_Referenced].[object_id]
										AND [foreign_key_columns].[referenced_column_id] = [columns_Referenced].[column_id]
							WHERE
								[foreign_keys].[parent_object_id] = [columns].[object_id]
								AND [foreign_key_columns].[parent_column_id] = [columns].[column_id]
							FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS [ForeignKey]
					FROM [sys].[columns]
						INNER JOIN [sys].[types] AS [types_System]
							ON
								[columns].[system_type_id] = [types_System].[user_type_id]
								AND [types_System].[system_type_id] = [types_System].[user_type_id]
						LEFT OUTER JOIN [sys].[types] AS [types_User]
							ON
								[columns].[user_type_id] = [types_User].[user_type_id]
								AND [types_User].[system_type_id] != [types_User].[user_type_id]
						LEFT OUTER JOIN [sys].[schemas] AS [schemas_UserType]
							ON [types_User].[schema_id] = [schemas_UserType].[schema_id]
						LEFT OUTER JOIN
						(
							SELECT
								[key_constraints].[parent_object_id] AS [object_id],
								[index_columns].[column_id],
								@True AS [IsPrimaryKey]
								FROM [sys].[key_constraints]
									INNER JOIN [sys].[indexes]
										ON
											[key_constraints].[parent_object_id] = [indexes].[object_id]
											AND [key_constraints].[unique_index_id] = [indexes].[index_id]
									INNER JOIN [sys].[index_columns]
										ON
											[indexes].[object_id] = [index_columns].[object_id]
											AND [indexes].[index_id] = [index_columns].[index_id]
						) AS [PrimaryKey]
							ON
								[columns].[object_id] = [PrimaryKey].[object_id]
								AND [columns].[column_id] = [PrimaryKey].[column_id]
					WHERE [columns].[object_id] = [tables].[object_id]
					ORDER BY [Ordinal] ASC
					FOR JSON PATH
			)) AS [Columns],
			JSON_QUERY((
				SELECT
					CONCAT
					(
						IIF
						(
							[indexes].[is_unique] = 1,
								N'UX_',
								N'IX_'
						),
						[tables].[name],
						N'_',
						CASE
							WHEN [indexes].[is_unique] = 0
								THEN [Columns].[List]
							WHEN
							(
								[indexes].[is_unique] = 1
								AND [Uniques].[Count] = 1
							)
								THEN N'Key'
							WHEN
							(
								[indexes].[is_unique] = 1
								AND [Uniques].[Count] > 1
							)
								THEN CONCAT(N'Key', [UniqueSequence].[Sequence])
						END
					) AS [Name],
					[indexes].[is_unique] AS [IsUnique],
					CASE
						WHEN [filegroups].[name] = @IndexFileGroupName
							THEN N'DEFAULT_INDEX_FILE_GROUP'
						WHEN [filegroups].[name] = @HeapFileGroupName
							THEN N'DEFAULT_HEAP_FILE_GROUP'
						WHEN [filegroups].[name] = @LobFileGroupName
							THEN N'DEFAULT_LOB_FILE_GROUP'
						ELSE [filegroups].[name]
					END [FileGroup],
					JSON_QUERY((
						SELECT
							[columns].[name] AS [Name],
							CASE
								WHEN [index_columns].[is_descending_key] = 1
									THEN N'Descending'
								ELSE N'Ascending'
							END AS [SortDirection]
							FROM [sys].[index_columns]
								INNER JOIN [sys].[columns]
									ON
										[index_columns].[object_id] = [columns].[object_id]
										AND [index_columns].[column_id] = [columns].[column_id]
							WHERE
								[index_columns].[object_id] = [indexes].[object_id]
								AND [index_columns].[index_id] = [indexes].[index_id]
								AND [index_columns].[is_included_column] = 0
							ORDER BY [index_columns].[key_ordinal] ASC
							FOR JSON PATH
					)) AS [Columns],
					JSON_QUERY((
						SELECT
							[columns].[name] AS [Name]
							FROM [sys].[index_columns]
								INNER JOIN [sys].[columns]
									ON
										[index_columns].[object_id] = [columns].[object_id]
										AND [index_columns].[column_id] = [columns].[column_id]
							WHERE
								[index_columns].[object_id] = [indexes].[object_id]
								AND [index_columns].[index_id] = [indexes].[index_id]
								AND [index_columns].[is_included_column] = 1
							ORDER BY [index_columns].[key_ordinal] ASC
							FOR JSON PATH
					)) AS [IncludeColumns]
					FROM [sys].[indexes]
						INNER JOIN [sys].[filegroups]
							ON [indexes].[data_space_id] = [filegroups].[data_space_id]
						LEFT OUTER JOIN
						(
							SELECT
								[indexes].[object_id],
								[indexes].[index_id],
								(
									SELECT
										CONCAT([columns].[name], N'')
										FROM [sys].[index_columns]
											INNER JOIN [sys].[columns]
												ON
													[index_columns].[object_id] = [columns].[object_id]
													AND [index_columns].[column_id] = [columns].[column_id]
										WHERE
											[index_columns].[object_id] = [indexes].[object_id]
											AND [index_columns].[index_id] = [indexes].[index_id]
											AND [index_columns].[is_included_column] = 0
										ORDER BY [index_columns].[key_ordinal] ASC
										FOR XML PATH('')
								) AS [List]
								FROM [sys].[indexes]
						) AS [Columns]
							ON
								[indexes].[object_id] = [Columns].[object_id]
								AND [indexes].[index_id] = [Columns].[index_id]
						LEFT OUTER JOIN
						(
							SELECT
								[indexes].[object_id],
								COUNT(*) AS [Count]
								FROM [sys].[indexes]
								WHERE
									[indexes].[is_unique] = 1
									AND [indexes].[is_primary_key] = 0
								GROUP BY [indexes].[object_id]
						) AS [Uniques]
							ON [indexes].[object_id] = [Uniques].[object_id]
						LEFT OUTER JOIN
						(
							SELECT
								[indexes_Uqinues].[object_id],
								[indexes_Uqinues].[index_id],
								ROW_NUMBER() OVER
								(
									PARTITION BY [indexes_Uqinues].[object_id]
									ORDER BY
										[indexes_Uqinues].[object_id] ASC,
										[indexes_Uqinues].[index_id] ASC
								) AS [Sequence]
								FROM [sys].[indexes] AS [indexes_Uqinues]
								WHERE
									[indexes_Uqinues].[is_unique] = 1
									AND [indexes_Uqinues].[is_primary_key] = 0
						) AS [UniqueSequence]
							ON
								[indexes].[object_id] = [UniqueSequence].[object_id]
								AND [indexes].[index_id] = [UniqueSequence].[index_id]
					WHERE
						[indexes].[object_id] = [tables].[object_id]
						AND [indexes].[is_primary_key] = 0
						AND [indexes].[type_desc] != N'HEAP'
					ORDER BY [indexes].[index_id] ASC
					FOR JSON PATH
			)) AS [Indexes]
			FROM [sys].[tables]
				INNER JOIN [sys].[schemas]
					ON [tables].[schema_id] = [schemas].[schema_id]
				LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency]
					ON [tables].[object_id] = [@ObjectDependency].[object_id]
				INNER JOIN [sys].[indexes]
					ON
						[tables].[object_id] = [indexes].[object_id]
						AND [indexes].[index_id] IN (0, 1)
				INNER JOIN [sys].[filegroups]
					ON [indexes].[data_space_id] = [filegroups].[data_space_id]
				LEFT JOIN [sys].[filegroups] AS [filegroups_LOB]
					ON [tables].[lob_data_space_id] = [filegroups_LOB].[data_space_id]
			WHERE [schemas].[name] = @SchemaName
			ORDER BY [@ObjectDependency].[CreateOrder] ASC
			FOR JSON PATH
	)) AS [Tables],
	JSON_QUERY((
		SELECT
			[Objects].[Sequence],
			[Objects].[Type],
			[Objects].[Name],
			CONCAT
			(
				[Objects].[Type],
				N'_',
				[Objects].[Name],
				N'.sql'
			) AS [ContentFileReference],
			JSON_QUERY((
				SELECT
					(
						CASE
							WHEN [types_User].[name] IS NOT NULL
								THEN
								(
									N'['
									+ [schemas_UserType].[name]
									+ N'].['
									+ [types_User].[name]
									+ N']'
								)
							ELSE
							(
								N'['
								+ [types_System].[name]
								+ N']'
							)
						END
						+
						CASE
							WHEN
							(
								[types_System].[name] = N'image'
								OR [types_System].[name] = N'text'
								OR [types_System].[name] = N'uniqueidentifier'
								OR [types_System].[name] = N'date'
								OR [types_System].[name] = N'tinyint'
								OR [types_System].[name] = N'smallint'
								OR [types_System].[name] = N'int'
								OR [types_System].[name] = N'smalldatetime'
								OR [types_System].[name] = N'datetime'
								OR [types_System].[name] = N'money'
								OR [types_System].[name] = N'smallmoney'
								OR [types_System].[name] = N'real'
								OR [types_System].[name] = N'float'
								OR [types_System].[name] = N'sql_variant'
								OR [types_System].[name] = N'text'
								OR [types_System].[name] = N'bit'
								OR [types_System].[name] = N'bigint'
								OR [types_System].[name] = N'hierarchyid'
								OR [types_System].[name] = N'geometry'
								OR [types_System].[name] = N'geography'
								OR [types_System].[name] = N'timestamp'
								OR [types_System].[name] = N'xml'
								OR
								(
									[types_System].[name] = N'nvarchar'
									AND [types_User].[name] = N'sysname'
									AND [schemas_UserType].[name] = N'sys'
								)
							)
								THEN ''
							WHEN
							(
								[types_System].[name] = N'varbinary'
								OR [types_System].[name] = N'varchar'
								OR [types_System].[name] = N'binary'
								OR [types_System].[name] = N'char'
								OR [types_System].[name] = N'nvarchar'
								OR [types_System].[name] = N'nchar'
							)
								THEN
								(
									CASE
										WHEN CONVERT([int], COLUMNPROPERTY([parameters].[object_id], [parameters].[name], 'CharMaxLen'), 0) = (-1)
											THEN '(MAX)'
										ELSE
										(
											'('
											+ CONVERT([varchar](11), CONVERT([int], COLUMNPROPERTY([parameters].[object_id], [parameters].[name], 'CharMaxLen'), 0), 0)
											+ ')'
										)
									END
								)
							WHEN
							(
								[types_System].[name] = N'time'
								OR [types_System].[name] = N'datetime2'
								OR [types_System].[name] = N'datetimeoffset'
							)
								THEN
								(
									'('
									+ CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [parameters].[scale]))
									+ ')'
								)
							WHEN
							(
								[types_System].[name] = N'decimal'
								OR [types_System].[name] = N'numeric'
							)
								THEN
								(
									'('
									+ CONVERT([varchar](11), [parameters].[precision], 0)
									+ ', '
									+ CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [parameters].[scale]), 0)
									+ ')'
								)
						END
					) AS [CondensedType],
					CASE
						WHEN [types_User].[name] IS NOT NULL
							THEN CONCAT
							(
								[schemas_UserType].[name],
								+ N'.'
								+ [types_User].[name]
							)
						ELSE [types_System].[name]
					END AS [Type],
					CASE
						WHEN
						(
							[schemas_UserType].[name] = N'sys'
							AND [types_User].[name] = N'sysname'
						)
							THEN NULL
						WHEN
						(
							[types_System].[name] = N'varbinary'
							OR [types_System].[name] = N'varchar'
							OR [types_System].[name] = N'binary'
							OR [types_System].[name] = N'char'
							OR [types_System].[name] = N'nvarchar'
							OR [types_System].[name] = N'nchar'
						)
							THEN CONVERT([int], COLUMNPROPERTY([parameters].[object_id], [parameters].[name], 'CharMaxLen'), 0)
						WHEN
						(
							[types_System].[name] = N'time'
							OR [types_System].[name] = N'datetime2'
							OR [types_System].[name] = N'datetimeoffset'
						)
							THEN ODBCSCALE([types_System].[system_type_id], [parameters].[scale])
					END AS [TypeLength],
					CASE
						WHEN
						(
							[types_System].[name] = N'decimal'
							OR [types_System].[name] = N'numeric'
						)
							THEN [parameters].[precision]
						ELSE NULL
					END AS [TypePrecision],
					CASE
						WHEN
						(
							[types_System].[name] = N'decimal'
							OR [types_System].[name] = N'numeric'
						)
							THEN ODBCSCALE([types_System].[system_type_id], [parameters].[scale])
						ELSE NULL
					END AS [TypeScale]
					FROM [sys].[parameters]
						INNER JOIN [sys].[types] AS [types_System]
							ON
								[parameters].[system_type_id] = [types_System].[user_type_id]
								AND [types_System].[system_type_id] = [types_System].[user_type_id]
						LEFT OUTER JOIN [sys].[types] AS [types_User]
							ON
								[parameters].[user_type_id] = [types_User].[user_type_id]
								AND [types_User].[system_type_id] != [types_User].[user_type_id]
						LEFT OUTER JOIN [sys].[schemas] AS [schemas_UserType]
							ON [types_User].[schema_id] = [schemas_UserType].[schema_id]
					WHERE
						[parameters].[parameter_id] = 0
						AND [parameters].[object_id] = [Objects].[object_id]
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)) AS [Returns],
			JSON_QUERY((
				SELECT
					ROW_NUMBER() OVER (ORDER BY [parameters].[parameter_id]) AS [Sequence],
					[parameters].[name] AS [Name],
					(
						CASE
							WHEN [types_User].[name] IS NOT NULL
								THEN
								(
									N'['
									+ [schemas_UserType].[name]
									+ N'].['
									+ [types_User].[name]
									+ N']'
								)
							ELSE
							(
								N'['
								+ [types_System].[name]
								+ N']'
							)
						END
						+
						CASE
							WHEN
							(
								[types_System].[name] = N'image'
								OR [types_System].[name] = N'text'
								OR [types_System].[name] = N'uniqueidentifier'
								OR [types_System].[name] = N'date'
								OR [types_System].[name] = N'tinyint'
								OR [types_System].[name] = N'smallint'
								OR [types_System].[name] = N'int'
								OR [types_System].[name] = N'smalldatetime'
								OR [types_System].[name] = N'datetime'
								OR [types_System].[name] = N'money'
								OR [types_System].[name] = N'smallmoney'
								OR [types_System].[name] = N'real'
								OR [types_System].[name] = N'float'
								OR [types_System].[name] = N'sql_variant'
								OR [types_System].[name] = N'text'
								OR [types_System].[name] = N'bit'
								OR [types_System].[name] = N'bigint'
								OR [types_System].[name] = N'hierarchyid'
								OR [types_System].[name] = N'geometry'
								OR [types_System].[name] = N'geography'
								OR [types_System].[name] = N'timestamp'
								OR [types_System].[name] = N'xml'
								OR
								(
									[types_System].[name] = N'nvarchar'
									AND [types_User].[name] = N'sysname'
									AND [schemas_UserType].[name] = N'sys'
								)
							)
								THEN ''
							WHEN
							(
								[types_System].[name] = N'varbinary'
								OR [types_System].[name] = N'varchar'
								OR [types_System].[name] = N'binary'
								OR [types_System].[name] = N'char'
								OR [types_System].[name] = N'nvarchar'
								OR [types_System].[name] = N'nchar'
							)
								THEN
								(
									CASE
										WHEN CONVERT([int], COLUMNPROPERTY([parameters].[object_id], [parameters].[name], 'CharMaxLen'), 0) = (-1)
											THEN '(MAX)'
										ELSE
										(
											'('
											+ CONVERT([varchar](11), CONVERT([int], COLUMNPROPERTY([parameters].[object_id], [parameters].[name], 'CharMaxLen'), 0), 0)
											+ ')'
										)
									END
								)
							WHEN
							(
								[types_System].[name] = N'time'
								OR [types_System].[name] = N'datetime2'
								OR [types_System].[name] = N'datetimeoffset'
							)
								THEN
								(
									'('
									+ CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [parameters].[scale]))
									+ ')'
								)
							WHEN
							(
								[types_System].[name] = N'decimal'
								OR [types_System].[name] = N'numeric'
							)
								THEN
								(
									'('
									+ CONVERT([varchar](11), [parameters].[precision], 0)
									+ ', '
									+ CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [parameters].[scale]), 0)
									+ ')'
								)
						END
					) AS [CondensedType],
					CASE
						WHEN [types_User].[name] IS NOT NULL
							THEN CONCAT
							(
								[schemas_UserType].[name],
								+ N'.'
								+ [types_User].[name]
							)
						ELSE [types_System].[name]
					END AS [Type],
					CASE
						WHEN
						(
							[schemas_UserType].[name] = N'sys'
							AND [types_User].[name] = N'sysname'
						)
							THEN NULL
						WHEN
						(
							[types_System].[name] = N'varbinary'
							OR [types_System].[name] = N'varchar'
							OR [types_System].[name] = N'binary'
							OR [types_System].[name] = N'char'
							OR [types_System].[name] = N'nvarchar'
							OR [types_System].[name] = N'nchar'
						)
							THEN CONVERT([int], COLUMNPROPERTY([parameters].[object_id], [parameters].[name], 'CharMaxLen'), 0)
						WHEN
						(
							[types_System].[name] = N'time'
							OR [types_System].[name] = N'datetime2'
							OR [types_System].[name] = N'datetimeoffset'
						)
							THEN ODBCSCALE([types_System].[system_type_id], [parameters].[scale])
					END AS [Length],
					CASE
						WHEN
						(
							[types_System].[name] = N'decimal'
							OR [types_System].[name] = N'numeric'
						)
							THEN [parameters].[precision]
						ELSE NULL
					END AS [Precision],
					CASE
						WHEN
						(
							[types_System].[name] = N'decimal'
							OR [types_System].[name] = N'numeric'
						)
							THEN ODBCSCALE([types_System].[system_type_id], [parameters].[scale])
						ELSE NULL
					END AS [Scale],
					[parameters].[is_output] AS [IsOutput]
					FROM [sys].[parameters]
						INNER JOIN [sys].[types] AS [types_System]
							ON
								[parameters].[system_type_id] = [types_System].[user_type_id]
								AND [types_System].[system_type_id] = [types_System].[user_type_id]
						LEFT OUTER JOIN [sys].[types] AS [types_User]
							ON
								[parameters].[user_type_id] = [types_User].[user_type_id]
								AND [types_User].[system_type_id] != [types_User].[user_type_id]
						LEFT OUTER JOIN [sys].[schemas] AS [schemas_UserType]
							ON [types_User].[schema_id] = [schemas_UserType].[schema_id]
					WHERE
						[parameters].[parameter_id] != 0
						AND [parameters].[object_id] = [Objects].[object_id]
					ORDER BY [parameters].[parameter_id]
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)) AS [Parameters],
			RIGHT
			(
				[sql_modules].[definition],
				(
					LEN([sql_modules].[definition])
					-
					(
						PATINDEX
						(
							CONCAT
							(
								N'%[', CHAR(13), N']',
								N'[', CHAR(10), N']',
								N'AS',
								N'[', CHAR(13), N']',
								N'[', CHAR(10), N']%'
							),
							[sql_modules].[definition]
						)
						+ 5
					)
				)
			) AS [Content]
			FROM
			(
				SELECT
					[objects].[object_id],
					ROW_NUMBER() OVER (ORDER BY [@ObjectDependency].[CreateOrder] ASC) AS [Sequence],
					CASE
						WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
						WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
						WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
						WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
						WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
					END AS [Type],
					[objects].[name] AS [Name]
					FROM [sys].[objects]
						INNER JOIN [sys].[schemas]
							ON [objects].[schema_id] = [schemas].[schema_id]
						LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency]
							ON [objects].[object_id] = [@ObjectDependency].[object_id]
					WHERE
						[schemas].[name] = @SchemaName
						AND [objects].[type_desc] IN
						(
							N'SQL_SCALAR_FUNCTION',
							N'SQL_STORED_PROCEDURE',
							N'SQL_TABLE_VALUED_FUNCTION',
							N'SQL_INLINE_TABLE_VALUED_FUNCTION',
							N'VIEW'
						)
			) AS [Objects]
				LEFT OUTER JOIN [sys].[sql_modules]
					ON [Objects].[object_id] = [sql_modules].[object_id]
			ORDER BY [Objects].[Sequence] ASC
			FOR JSON PATH
	)) AS [Modules]
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
), 0)
