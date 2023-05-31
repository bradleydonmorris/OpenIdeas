SELECT
	CONVERT
	(
		[nvarchar](MAX),
		(
			SELECT
				[schemas].[name] AS [Schema],
				[objects].[name] AS [Name],
				'Procedure' AS [SimpleType],
				[objects].[type_desc] AS [Type],
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
						FOR JSON PATH
				)) AS [Parameters],
				[sql_modules].[definition] AS [CreateScript]
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
