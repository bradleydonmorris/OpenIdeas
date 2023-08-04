IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Variable'
)
	BEGIN
		CREATE TABLE [Logging].[Variable]
		(
			[VariableId] [bigint] IDENTITY(1,1) NOT NULL,
			[LogId] [int] NOT NULL,
			[Name] [nvarchar](100) NOT NULL,
			[Value] [nvarchar](MAX) NOT NULL,
			CONSTRAINT [PK_Variable] PRIMARY KEY CLUSTERED ([VariableId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [Logging],
			CONSTRAINT [FK_Variable_Log]
				FOREIGN KEY ([LogId])
				REFERENCES [Logging].[Log]([LogId])
		) ON [Logging]
	END
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
			INNER JOIN [sys].[indexes]
				ON [tables].[object_id] = [indexes].[object_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Variable'
			AND [indexes].[name] = N'UX_Variable_Key'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Variable_Key]
			ON [Logging].[Variable]([LogId] ASC, [Name] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [Logging]
	END
