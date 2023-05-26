SELECT
	CONVERT
	(
		[nvarchar](MAX),
		(
			SELECT
				[schemas].[name] AS [Schema],
				[objects].[name] AS [Name],
				JSON_QUERY((
					SELECT
						COLUMNPROPERTY([columns].[object_id], [columns].[name], 'ordinal') AS [Ordinal],
						IIF
						(
							[columns].[is_identity] = 1,
								CONCAT([objects].[name], N'Id'),
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
											WHEN CONVERT([int], COLUMNPROPERTY([objects].[object_id], [columns].[name], 'CharMaxLen'), 0) = (-1)
												THEN '(MAX)'
											ELSE
											(
												'('
												+ CONVERT([varchar](11), CONVERT([int], COLUMNPROPERTY([objects].[object_id], [columns].[name], 'CharMaxLen'), 0), 0)
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
									[computed_columns].[object_id] = [objects].[object_id]
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
						WHERE [columns].[object_id] = [objects].[object_id]
						ORDER BY [Ordinal] ASC
						FOR JSON PATH
				)) AS [Columns],
				[sql_modules].[definition] AS [CreateScript],
                CONCAT
				(
					N'DROP VIEW IF EXISTS ',
					QUOTENAME([schemas].[name]),
					N'.',
					QUOTENAME([objects].[name])
				) AS [DropScript]
				FROM [sys].[objects]
					INNER JOIN [sys].[schemas] WITH (NOLOCK)
						ON [objects].[schema_id] = [schemas].[schema_id]
					INNER JOIN [sys].[sql_modules]
						ON [objects].[object_id] = [sql_modules].[object_id]
				WHERE [objects].[object_id] = OBJECT_ID(CONCAT(QUOTENAME(@Schema), N'.', QUOTENAME(@Name)))
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	) AS [JSON]
