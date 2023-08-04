IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Timer'
)
	BEGIN
		CREATE TABLE [Logging].[Timer]
		(
			[TimerId] [bigint] IDENTITY(1,1) NOT NULL,
			[LogId] [int] NOT NULL,
			[Sequence] [int] NOT NULL,
			[Name] [nvarchar](100) NOT NULL,
			[BeginTime] [datetime2](7) NOT NULL,
			[EndTime] [datetime2](7) NOT NULL,
			[ElapsedSeconds] [decimal](32, 10) NOT NULL,
			CONSTRAINT [PK_Timer] PRIMARY KEY CLUSTERED ([TimerId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [Logging],
			CONSTRAINT [FK_Timer_Log]
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
			AND [tables].[name] = N'Timer'
			AND [indexes].[name] = N'UX_Timer_Key1'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Timer_Key1]
			ON [Logging].[Timer]([LogId] ASC, [Sequence] ASC)
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
			AND [tables].[name] = N'Timer'
			AND [indexes].[name] = N'UX_Timer_Key2'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Timer_Key2]
			ON [Logging].[Timer]([LogId] ASC, [Name] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [Logging]
	END
