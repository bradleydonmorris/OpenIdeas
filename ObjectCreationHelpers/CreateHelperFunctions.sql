PRINT 'Creating Helper Objects'
PRINT CONCAT(CHAR(9),N'Function: [dbo].[SchemaExists]')
GO
CREATE OR ALTER FUNCTION [dbo].[SchemaExists]
(
	@Schema [sys].[sysname]
)
RETURNS [bit]
AS
BEGIN
	DECLARE @ReturnValue [bit] = 0
	IF EXISTS
	(
		SELECT *
			FROM [sys].[schemas]
			WHERE
				[schemas].[schema_id] = SCHEMA_ID(@Schema)
				AND [schemas].[name] = @Schema
	)
		SET @ReturnValue = 1
	RETURN @ReturnValue
END
GO
PRINT CONCAT(CHAR(9),N'Function: [dbo].[TableExists]')
GO
CREATE OR ALTER FUNCTION [dbo].[TableExists]
(
	@Schema [sys].[sysname],
	@Table [sys].[sysname]
)
RETURNS [bit]
AS
BEGIN
	DECLARE @ReturnValue [bit] = 0
	IF EXISTS
	(
		SELECT 1
			FROM [sys].[objects]
				INNER JOIN [sys].[schemas]
					ON [objects].[schema_id] = [schemas].[schema_id]
			WHERE
				[schemas].[schema_id] = SCHEMA_ID(@Schema)
				AND [schemas].[name] = @Schema
				AND [objects].[object_id] = OBJECT_ID(CONCAT(N'[', @Schema, N'].[', @Table, N']'))
				AND [objects].[name] = @Table
	)
		SET @ReturnValue = 1
	RETURN @ReturnValue
END
GO
PRINT CONCAT(CHAR(9),N'Function: [dbo].[IndexExists]')
GO
CREATE OR ALTER FUNCTION [dbo].[IndexExists]
(
	@Schema [sys].[sysname],
	@Table [sys].[sysname],
	@Index [sys].[sysname]
)
RETURNS [bit]
AS
BEGIN
	DECLARE @ReturnValue [bit] = 0
	IF EXISTS
	(
		SELECT 1
			FROM [sys].[indexes]
				INNER JOIN [sys].[objects]
					ON [indexes].[object_id] = [objects].[object_id]
				INNER JOIN [sys].[schemas]
					ON [objects].[schema_id] = [schemas].[schema_id]
			WHERE
				[schemas].[schema_id] = SCHEMA_ID(@Schema)
				AND [schemas].[name] = @Schema
				AND [objects].[object_id] = OBJECT_ID(CONCAT(N'[', @Schema, N'].[', @Table, N']'))
				AND [objects].[name] = @Table
				AND [indexes].[name] = @Index
	)
		SET @ReturnValue = 1
	RETURN @ReturnValue
END
GO
PRINT CONCAT(CHAR(9),N'Function: [dbo].[GetIndexCreateStatement]')
GO
CREATE OR ALTER FUNCTION [dbo].[GetIndexCreateStatement]
(
	@IndexFileGroup [sys].[sysname],
	@IsUnique [bit],
	@Schema [sys].[sysname],
	@Table [sys].[sysname],
	@Index [sys].[sysname],
	@ColumnsCSV [nvarchar](MAX)
)
RETURNS [nvarchar](400)
AS
BEGIN
	RETURN CONCAT(
		N'CREATE',
		CASE
			WHEN @IsUnique = 1
				THEN ' UNIQUE'
			ELSE N''
		END,
		N' NONCLUSTERED INDEX [', @Index, N']', CHAR(13), CHAR(10),
		CHAR(9), N'ON [', @Schema, N'].[', @Table, N'](', 
		(
			SELECT 
				CASE
					WHEN CHARINDEX(N'|', [Columns].[List]) > 0
						THEN REPLACE(LEFT([Columns].[List], LEN([Columns].[List]) - 1), N'|', N', ')
					ELSE [Columns].[List]
				END
				FROM
				(
					SELECT
					(
						SELECT
							CONCAT(N'[', [Column].[value], N'] ASC|')
							FROM
							(
								SELECT CONCAT(N'[ "', REPLACE(@ColumnsCSV, N',', N'", "'), N'" ]') AS [JSON]
							) AS [JSON]
								CROSS APPLY OPENJSON([JSON].[JSON]) AS [Column]
							WHERE NULLIF([Column].[value], N'') IS NOT NULL
							ORDER BY [Column].[key] ASC
							FOR XML PATH('')
					) AS [List]
				) AS [Columns]
		),
		N')', CHAR(13), CHAR(10),
		CHAR(9), CHAR(9), N'WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)', CHAR(13), CHAR(10),
		CHAR(9), CHAR(9), N'ON [', @IndexFileGroup, N']', CHAR(13), CHAR(10)
	)
END
GO
PRINT CONCAT(CHAR(9),N'Function: [dbo].[GetTableCreateStatement]')
GO
CREATE OR ALTER FUNCTION [dbo].[GetTableCreateStatement]
(
	@TableFileGroup [sys].[sysname],
	@TextFileGroup [sys].[sysname],
	@Schema [sys].[sysname],
	@Table [sys].[sysname],
	@ColumnsJSON [nvarchar](MAX)
)
RETURNS [nvarchar](MAX)
AS
BEGIN
	RETURN CONCAT(
		N'CREATE TABLE [', @Schema, N'].[', @Table, N']', CHAR(13), CHAR(10),
		N'(', CHAR(13), CHAR(10),
		(
			SELECT
				CASE
					WHEN CHARINDEX(N'|', [Columns].[List]) > 0
						THEN CONCAT
						(
							CHAR(9),
							REPLACE
							(
								REPLACE(REPLACE(REPLACE(
									LEFT([Columns].[List], LEN([Columns].[List]) - 1),
									N'\r', CHAR(13)), N'\n', CHAR(10)), N'\t', CHAR(9)
								)
								,
								N'|',
								[Columns].[Delimiter]
							),
							CHAR(13), CHAR(10)
						)
					ELSE N''
				END
				FROM
				(
					SELECT
					(
						SELECT
							CONCAT
							(
								N'[', [Name], N'] ',
								CASE
									WHEN REPLACE(REPLACE([Type], N'[', N''), N']', N'') IN (N'sys.sysname', N'sysname')
										THEN N'[sys].[sysname]'
									WHEN [Length] = (-1)
										THEN CONCAT(N'[', REPLACE(REPLACE([Type], N'[', N''), N']', N''), N'](MAX)')
									WHEN [Length] IS NOT NULL
										THEN CONCAT(N'[', REPLACE(REPLACE([Type], N'[', N''), N']', N''), N'](', [Length], N')')
									WHEN
									(
										[Precision] IS NOT NULL
										AND [Scale] IS NULL
									)
										THEN CONCAT(N'[', REPLACE(REPLACE([Type], N'[', N''), N']', N''), N'](', [Precision], N')')
									WHEN
									(
										[Precision] IS NOT NULL
										AND [Scale] IS NOT NULL
									)
										THEN CONCAT(N'[', REPLACE(REPLACE([Type], N'[', N''), N']', N''), N'](', [Precision], N'', [Scale], N')')
									ELSE CONCAT(N'[', REPLACE(REPLACE([Type], N'[', N''), N']', N''), N']')
								END,
								CASE
									WHEN ISNULL([IsIdentity], 0) = 1
										THEN N' IDENTITY(1, 1)'
									ELSE N''
								END,
								CASE
									WHEN ISNULL([IsRowGUID], 0) = 1
										THEN N' ROWGUIDCOL'
									ELSE N''
								END,
								CASE
									WHEN ISNULL([IsNullable], 0) = 1
										THEN N' NULL'
									ELSE N' NOT NULL'
								END,
								CASE
									WHEN [Default] IS NOT NULL
										THEN CONCAT
										(
											N'\r\n\t\t',
											N'CONSTRAINT [DF_', @Table, N'_', [Name], N'] DEFAULT ',
											[Default]
										)
									ELSE N''
								END,
								N'|'
							)
							FROM OPENJSON(@ColumnsJSON)
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[Type] [nvarchar](261) N'$.Type',
									[Length] [smallint] N'$.Length',
									[Precision] [tinyint] N'$.Precision',
									[Scale] [tinyint] N'$.Scale',
									[IsNullable] [bit] N'$.IsNullable',
									[IsIdentity] [bit] N'$.IsIdentity',
									[IsRowGUID] [bit] N'$.IsRowGUID',
									[Default] [nvarchar](MAX) N'$.Default'
								) AS [Column]
							WHERE NULLIF([Column].[Name], N'') IS NOT NULL
							FOR XML PATH('')
					) AS [List],
					CONCAT(N',', CHAR(13), CHAR(10), CHAR(9)) AS [Delimiter]
				) AS [Columns]
		),
		(
			SELECT
				CASE
					WHEN CHARINDEX(N'|', [Columns].[List]) > 0
						THEN CONCAT
						(
							CHAR(9),
							N'CONSTRAINT [PK_', @Table, N']', CHAR(13), CHAR(10), CHAR(9), CHAR(9),
							N'PRIMARY KEY CLUSTERED (',
							REPLACE(LEFT([Columns].[List], LEN([Columns].[List]) - 1), N'|', [Columns].[Delimiter]),
							N')', CHAR(13), CHAR(10), CHAR(9), CHAR(9), CHAR(9),
							N'WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)', CHAR(13), CHAR(10), CHAR(9), CHAR(9), CHAR(9),
							N'ON [', @TableFileGroup, N']',
							CASE
								WHEN
								(
									SELECT IIF(COUNT(*) > 0, 1, 0)
										FROM OPENJSON(@ColumnsJSON)
											WITH
											(
												[Name] [sys].[sysname] N'$.Name',
												[ForeignKey] [nvarchar](MAX) AS JSON
											) AS [Column]
											CROSS APPLY OPENJSON([Column].[ForeignKey])
												WITH
												(
													[Schema] [sys].[sysname] N'$.Schema',
													[Table] [sys].[sysname] N'$.Table',
													[Column] [sys].[sysname] N'$.Column',
													[Suffix] [sys].[sysname] N'$.Suffix'
												) AS [ForeignKey]
										WHERE NULLIF([Name], N'') IS NOT NULL
								) = 1
									THEN N','
								ELSE N''
							END,
							CHAR(13), CHAR(10)
						)
					ELSE N''
				END
				FROM
				(
					SELECT
					(
						SELECT CONCAT(N'[', [Name], N']|')
							FROM OPENJSON(@ColumnsJSON)
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[IsPrimaryKey] [bit] N'$.IsPrimaryKey'
								) AS [Column]
							WHERE
								NULLIF([Name], N'') IS NOT NULL
								AND ISNULL([IsPrimaryKey], 0) = 1
							FOR XML PATH('')
					) AS [List],
					N', ' AS [Delimiter]
				) AS [Columns]
		),
		(
			SELECT
				CASE
					WHEN CHARINDEX(N'|', [ForeignKeys].[List]) > 0
						THEN CONCAT
						(
							CHAR(9),
							REPLACE
							(
								REPLACE(REPLACE(REPLACE(
									LEFT([ForeignKeys].[List], LEN([ForeignKeys].[List]) - 1),
									N'\r', CHAR(13)), N'\n', CHAR(10)), N'\t', CHAR(9)
								)
								,
								N'|',
								[ForeignKeys].[Delimiter]
							),
							CHAR(13), CHAR(10)
						)
					ELSE N''
				END
				FROM
				(
					SELECT
					(
						SELECT
							CONCAT(
								N'CONSTRAINT [FK_', @Table, N'_', [ForeignKey].[Table],
								CASE
									WHEN [ForeignKey].[Suffix] IS NOT NULL
										THEN IIF(LEFT([ForeignKey].[Suffix], 1) != N'_', CONCAT(N'_', [ForeignKey].[Suffix]), [ForeignKey].[Suffix])
									ELSE N''
								END,
								N']\r\n\t\t\t',
								N'FOREIGN KEY([', [Column].[Name], N'])\r\n\t\t\t',
								N'REFERENCES [', [ForeignKey].[Schema], N'].[', [ForeignKey].[Table], N']([', [ForeignKey].[Column], N'])|'
							)
							FROM OPENJSON(@ColumnsJSON)
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[ForeignKey] [nvarchar](MAX) AS JSON
								) AS [Column]
								CROSS APPLY OPENJSON([Column].[ForeignKey])
									WITH
									(
										[Schema] [sys].[sysname] N'$.Schema',
										[Table] [sys].[sysname] N'$.Table',
										[Column] [sys].[sysname] N'$.Column',
										[Suffix] [sys].[sysname] N'$.Suffix'
									) AS [ForeignKey]
							WHERE NULLIF([Name], N'') IS NOT NULL
							FOR XML PATH('')
					) AS [List],
					CONCAT(N',', CHAR(13), CHAR(10), CHAR(9)) AS [Delimiter]
				) AS [ForeignKeys]
		),
		N') ON [', @TableFileGroup, N']',
		(
			SELECT
				CONCAT(N' TEXTIMAGE_ON [', @TextFileGroup, N']')
				FROM
				(
					SELECT COUNT(*) AS [Count]
						FROM OPENJSON(@ColumnsJSON)
							WITH
							(
								[Length] [smallint] N'$.Length'
							) AS [Column]
						WHERE [Column].[Length] = (-1)
				) AS [HasMax]
				WHERE [Count] > 0
		)
	)
END
GO
