SELECT
	CONVERT
	(
		[nvarchar](MAX),
		(
			SELECT
				[filegroups].[name] AS [HeapFileGroupName],
				[filegroups_LOB].[name] AS [LobFileGroupName],
				[schemas].[name] AS [Schema],
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
						JSON_QUERY((
							SELECT
								[default_constraints].[definition] AS [Definition]
								FROM [sys].[default_constraints] WITH (NOLOCK)
								WHERE [default_constraints].[object_id] = [columns].[default_object_id]
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
						)) AS [Default],
						JSON_QUERY((
							SELECT
								[computed_columns].[definition] AS [Definition]
								FROM [sys].[computed_columns] WITH (NOLOCK)
								WHERE
									[computed_columns].[object_id] = [tables].[object_id]
									AND [computed_columns].[column_id] = [columns].[column_id]
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
						)) AS [Computation]
						FROM [sys].[columns] WITH (NOLOCK)
							INNER JOIN [sys].[types] AS [types_System] WITH (NOLOCK)
								ON
									[columns].[system_type_id] = [types_System].[user_type_id]
									AND [types_System].[system_type_id] = [types_System].[user_type_id]
							LEFT OUTER JOIN [sys].[types] AS [types_User] WITH (NOLOCK)
								ON
									[columns].[user_type_id] = [types_User].[user_type_id]
									AND [types_User].[system_type_id] != [types_User].[user_type_id]
							LEFT OUTER JOIN [sys].[schemas] AS [schemas_UserType] WITH (NOLOCK)
								ON [types_User].[schema_id] = [schemas_UserType].[schema_id]
						WHERE [columns].[object_id] = [tables].[object_id]
						ORDER BY [Ordinal] ASC
						FOR JSON PATH
				)) AS [Columns],
				JSON_QUERY((
					SELECT
						[key_constraints].[name] AS [Name],
						[filegroups].[name] AS [FileGroup],
						IIF([indexes].[type_desc] = N'CLUSTERED', CAST(1 AS [bit]), CAST(0 AS [bit])) AS [IsClustered],
						[indexes].[is_unique] AS [IsUnique],
						[indexes].[ignore_dup_key] AS [IgnoreDuplicateKey],
						[indexes].[allow_row_locks] AS [AllowRowLocks],
						[indexes].[allow_page_locks] AS [AllowPageLocks],
						[indexes].[is_padded] AS [IsPadded],
						[indexes].[fill_factor] AS [FillFactor],
						JSON_QUERY((
							SELECT
								[index_columns].[key_ordinal] AS [Ordinal],
								[columns].[name] AS [Name],
								CASE
									WHEN [index_columns].[is_descending_key] = 1
										THEN N'Descending'
									ELSE N'Ascending'
								END AS [SortDirection]
								FROM [sys].[index_columns] WITH (NOLOCK)
									INNER JOIN [sys].[columns] WITH (NOLOCK)
										ON
											[index_columns].[object_id] = [columns].[object_id]
											AND [index_columns].[column_id] = [columns].[column_id]
								WHERE
									[index_columns].[object_id] = [indexes].[object_id]
									AND [index_columns].[index_id] = [indexes].[index_id]
									AND [index_columns].[is_included_column] = 0
								ORDER BY [Ordinal] ASC
								FOR JSON PATH
						)) AS [Columns]
						FROM [sys].[key_constraints] WITH (NOLOCK)
							INNER JOIN [sys].[indexes] WITH (NOLOCK)
								ON
									[key_constraints].[parent_object_id] = [indexes].[object_id]
									AND [key_constraints].[unique_index_id] = [indexes].[index_id]
							INNER JOIN [sys].[filegroups] WITH (NOLOCK)
								ON [indexes].[data_space_id] = [filegroups].[data_space_id]
						WHERE [key_constraints].[parent_object_id] = [tables].[object_id]
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)) AS [PrimaryKey],
				JSON_QUERY((
					SELECT
						[schemas_Referenced].[name] AS [Schema],
						[schemas].[name] AS [KeySchema],
						[foreign_keys].[name] AS [KeyName],
						[schemas_Foreign].[name] AS [ForeignSchema],
						[objects_Foreign].[name] AS [ForiengTable],
						[schemas_Referenced].[name] AS [ReferencedSchema],
						[objects_Referenced].[name] AS [ReferencedTable],
						JSON_QUERY((
							SELECT
								ROW_NUMBER() OVER (ORDER BY [foreign_key_columns].[constraint_column_id]) AS [Ordinal],
								[columns_Referenced].[name] AS [ForeignColumn],
								[columns_Referenced].[name] AS [ReferencedColumn]
								FROM [sys].[foreign_key_columns] WITH (NOLOCK)
									INNER JOIN [sys].[columns] AS [columns_Foreign] WITH (NOLOCK)
										ON
											[foreign_key_columns].[parent_object_id] = [columns_Foreign].[object_id]
											AND [foreign_key_columns].[parent_column_id] = [columns_Foreign].[column_id]
									INNER JOIN [sys].[columns] AS [columns_Referenced] WITH (NOLOCK)
										ON
											[foreign_key_columns].[referenced_object_id] = [columns_Referenced].[object_id]
											AND [foreign_key_columns].[referenced_column_id] = [columns_Referenced].[column_id]
								WHERE [foreign_key_columns].[constraint_object_id] = [foreign_keys].[object_id]
								ORDER BY [Ordinal] ASC
								FOR JSON PATH
						)) AS [Columns]
						FROM [sys].[foreign_keys] WITH (NOLOCK)
							INNER JOIN [sys].[schemas] WITH (NOLOCK)
								ON [foreign_keys].[schema_id] = [schemas].[schema_id]
							INNER JOIN [sys].[objects] AS [objects_Foreign] WITH (NOLOCK)
								ON [foreign_keys].[parent_object_id] = [objects_Foreign].[object_id]
							INNER JOIN [sys].[schemas] AS [schemas_Foreign] WITH (NOLOCK)
								ON [objects_Foreign].[schema_id] = [schemas_Foreign].[schema_id]
							INNER JOIN [sys].[objects] AS [objects_Referenced] WITH (NOLOCK)
								ON [foreign_keys].[referenced_object_id] = [objects_Referenced].[object_id]
							INNER JOIN [sys].[schemas] AS [schemas_Referenced] WITH (NOLOCK)
								ON [objects_Referenced].[schema_id] = [schemas_Referenced].[schema_id]
						WHERE [foreign_keys].[parent_object_id] = [tables].[object_id]
						FOR JSON PATH
				)) AS [ForeignKeys],
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
						[filegroups].[name] AS [FileGroup],
						[indexes].[ignore_dup_key] AS [IgnoreDuplicateKey],
						[indexes].[allow_row_locks] AS [AllowRowLocks],
						[indexes].[allow_page_locks] AS [AllowPageLocks],
						[indexes].[is_padded] AS [IsPadded],
						[indexes].[fill_factor] AS [FillFactor],
						JSON_QUERY((
							SELECT
								[columns].[name] AS [Name],
								CASE
									WHEN [index_columns].[is_descending_key] = 1
										THEN N'Descending'
									ELSE N'Ascending'
								END AS [SortDirection]
								FROM [sys].[index_columns] WITH (NOLOCK)
									INNER JOIN [sys].[columns] WITH (NOLOCK)
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
								FROM [sys].[index_columns] WITH (NOLOCK)
									INNER JOIN [sys].[columns] WITH (NOLOCK)
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
						FROM [sys].[indexes] WITH (NOLOCK)
							INNER JOIN [sys].[filegroups] WITH (NOLOCK)
								ON [indexes].[data_space_id] = [filegroups].[data_space_id]
							LEFT OUTER JOIN
							(
								SELECT
									[indexes].[object_id],
									[indexes].[index_id],
									(
										SELECT
											CONCAT([columns].[name], N'')
											FROM [sys].[index_columns] WITH (NOLOCK)
												INNER JOIN [sys].[columns] WITH (NOLOCK)
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
									FROM [sys].[indexes] WITH (NOLOCK)
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
									FROM [sys].[indexes] AS [indexes_Uqinues] WITH (NOLOCK)
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
				)) AS [Indexes],
                N'GENERATE IN POWERSHELL' AS [CreateScript],
                CONCAT
				(
					N'DROP TABLE IF EXISTS ',
					QUOTENAME([schemas].[name]),
					N'.',
					QUOTENAME([tables].[name])
				) AS [DropScript]
				FROM [sys].[tables] WITH (NOLOCK)
					INNER JOIN [sys].[schemas] WITH (NOLOCK)
						ON [tables].[schema_id] = [schemas].[schema_id]
					INNER JOIN [sys].[indexes] WITH (NOLOCK)
						ON
							[tables].[object_id] = [indexes].[object_id]
							AND [indexes].[index_id] IN (0, 1)
					INNER JOIN [sys].[filegroups] WITH (NOLOCK)
						ON [indexes].[data_space_id] = [filegroups].[data_space_id]
					LEFT JOIN [sys].[filegroups] AS [filegroups_LOB] WITH (NOLOCK)
						ON [tables].[lob_data_space_id] = [filegroups_LOB].[data_space_id]
				WHERE [tables].[object_id] = OBJECT_ID(CONCAT(QUOTENAME(@Schema), N'.', QUOTENAME(@Name)))
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	) AS [JSON]