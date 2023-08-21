IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Log'
)
	BEGIN
		CREATE TABLE [Logging].[Log]
		(
			[LogId] [int] IDENTITY(1,1) NOT NULL,
			[InvocationId] [int] NOT NULL,
			[LogGUID] [uniqueidentifier] NOT NULL,
			[OpenLogTime] [datetime2](7) NOT NULL,
			[CloseLogTime] [datetime2](7) NOT NULL,
			CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED ([LogId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [PRIMARY],
			CONSTRAINT [FK_Log_Invocation]
				FOREIGN KEY ([InvocationId])
				REFERENCES [Logging].[Invocation]([InvocationId])
		) ON [PRIMARY]
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
			AND [tables].[name] = N'Log'
			AND [indexes].[name] = N'UX_Log_Key'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Log_Key]
			ON [Logging].[Log]([LogGUID] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [PRIMARY]
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
			AND [tables].[name] = N'Log'
			AND [indexes].[name] = N'IX_Log_InvocationId'
)
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_Log_InvocationId]
			ON [Logging].[Log]([InvocationId] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [PRIMARY]
	END

