IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Script'
)
	BEGIN
		CREATE TABLE [Logging].[Script]
		(
			[ScriptId] [int] IDENTITY(1,1) NOT NULL,
			[ProjectId] [int] NOT NULL,
			[Name] [nvarchar](50) NOT NULL,
			CONSTRAINT [PK_Script] PRIMARY KEY CLUSTERED ([ScriptId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [PRIMARY],
			CONSTRAINT [FK_Script_Project]
				FOREIGN KEY ([ProjectId])
				REFERENCES [Logging].[Project]([ProjectId])
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
			AND [tables].[name] = N'Script'
			AND [indexes].[name] = N'UX_Script_Key'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Script_Key]
			ON [Logging].[Script]([ProjectId] ASC, [Name] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [PRIMARY]
	END
