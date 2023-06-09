SELECT
	CASE
		WHEN
		(
			([Column].[TableName] + N'GUID') = [Column].[ColumnName]
			AND [Column].[SystemDataTypeName] != N'uniqueidentifier'
		)
			THEN 'Entity GUID Data Type'
		WHEN
		(
			[Column].[OrdinalPosition] = 1
			AND ([Column].[TableName] + N'Id') != [Column].[ColumnName]
		)
			THEN N'Identity Column Name'
	END AS [ValidationIssue],
	[Column].[SchemaName],
	[Column].[TableName],
	[Column].[ColumnName],
	[Column].[OrdinalPosition],
	[Column].[SystemDataTypeName],
	[Column].[UserDataTypeSchemaName],
	[Column].[UserDataTypeName],
	[Column].[CondensedDataType],
	[Column].[IsNulable],
	[Column].[CharacterMaximumLength],
	[Column].[CharacterOctetLength],
	[Column].[NumericPrecision],
	[Column].[NumericPrecisionRadix],
	[Column].[NumericScale],
	[Column].[DateTimePrecision],
	[Column].[CollationName],
	[Column].[IsNulable],
	[Column].[IsIdentity],
	[Column].[IsComputed],
	[Column].[DefaultConstraintName],
	[Column].[DefaultConstraintDefinition],
	[Column].[ComputedColumnDefinition]
	FROM
	(
		SELECT
			[schemas_Object].[name] AS [SchemaName],
			[tables].[name] AS [TableName],
			[columns].[name] AS [ColumnName],
			COLUMNPROPERTY([columns].[object_id], [columns].[name], 'Ordinal') AS [OrdinalPosition],
			[types_System].[name] AS [SystemDataTypeName],
			[schemas_UserType].[name] AS [UserDataTypeSchemaName],
			[types_User].[name] AS [UserDataTypeName],
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
			) AS [CondensedDataType],
			COLUMNPROPERTY([columns].[object_id], [columns].[name], 'CharMaxLen') AS [CharacterMaximumLength],
			COLUMNPROPERTY([columns].[object_id], [columns].[name], 'OctetMaxLen') AS [CharacterOctetLength],
			CONVERT
			(
				[tinyint],
				CASE -- int/decimal/numeric/real/float/money
					WHEN [columns].[system_type_id] IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127)
						THEN [columns].[precision]
				END,
				0
			) AS [NumericPrecision],
			CONVERT
			(
				[smallint],
				CASE	-- int/money/decimal/numeric
					WHEN [columns].[system_type_id] IN (48, 52, 56, 60, 106, 108, 122, 127)
						THEN 10
					WHEN [columns].[system_type_id] IN (59, 62)
						THEN 2
				END,
				0
			) AS [NumericPrecisionRadix], -- real/float
			CONVERT
			(
				[int],
				CASE	-- datetime/smalldatetime
					WHEN [columns].[system_type_id] IN (40, 41, 42, 43, 58, 61)
						THEN NULL
					ELSE ODBCSCALE([columns].[system_type_id], [columns].[scale])
				END,
				0
			) AS [NumericScale],
			CONVERT
			(
				[smallint],
				CASE -- datetime/smalldatetime
					WHEN [columns].[system_type_id] IN (40, 41, 42, 43, 58, 61)
						THEN ODBCSCALE([columns].[system_type_id], [columns].[scale])
				END,
				0
			) AS [DateTimePrecision],
			[columns].[collation_name] AS [CollationName],
			[columns].[is_nullable] AS [IsNulable],
			[columns].[is_identity] AS [IsIdentity],
			[columns].[is_computed] AS [IsComputed],
			[default_constraints].[name] AS [DefaultConstraintName],
			[default_constraints].[definition] AS [DefaultConstraintDefinition],
			[computed_columns].[definition] AS [ComputedColumnDefinition]
			FROM [sys].[tables]
				INNER JOIN [sys].[schemas] AS [schemas_Object]
					ON [tables].[schema_id] = [schemas_Object].[schema_id]
				INNER JOIN [sys].[columns]
					ON [tables].[object_id] = [columns].[object_id]
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
				LEFT OUTER JOIN [sys].[default_constraints]
					ON [columns].[default_object_id] = [default_constraints].[object_id]
				LEFT OUTER JOIN [sys].[computed_columns]
					ON
						[tables].[object_id] = [computed_columns].[object_id]
						AND [columns].[column_id] = [computed_columns].[column_id]
			WHERE [schemas_Object].[name] != N'sys'
	) AS [Column]
	ORDER BY
		[Column].[SchemaName],
		[Column].[TableName],
		[Column].[OrdinalPosition]
