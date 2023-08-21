IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Entry'
)
	BEGIN
		CREATE TABLE [Logging].[Entry]
		(
			[EntryId] [bigint] IDENTITY(1,1) NOT NULL,
			[LogId] [int] NOT NULL,
			[LevelId] [tinyint] NOT NULL,
			[Number] [int] NOT NULL,
			[EntryTime] [datetime2](7) NOT NULL,
			[Text] [nvarchar](MAX) NOT NULL,
			CONSTRAINT [PK_Entry] PRIMARY KEY CLUSTERED ([EntryId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [Logging],
			CONSTRAINT [FK_Entry_Log]
				FOREIGN KEY ([LogId])
				REFERENCES [Logging].[Log]([LogId]),
			CONSTRAINT [FK_Entry_Level]
				FOREIGN KEY ([LevelId])
				REFERENCES [Logging].[Level]([LevelId])
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
			AND [tables].[name] = N'Entry'
			AND [indexes].[name] = N'UX_Entry_Key'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Entry_Key]
			ON [Logging].[Entry]([LogId] ASC, [Number] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [Logging]
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
			AND [tables].[name] = N'Entry'
			AND [indexes].[name] = N'IX_Entry_LevelId'
)
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_Entry_LevelId]
			ON [Logging].[Entry]([LevelId] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [Logging]
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
			AND [tables].[name] = N'Entry'
			AND [indexes].[name] = N'IX_Entry_EntryTime'
)
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_Entry_EntryTime]
			ON [Logging].[Entry]([EntryTime] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [Logging]
	END
