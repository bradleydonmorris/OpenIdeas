IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Invocation'
)
	BEGIN
		CREATE TABLE [Logging].[Invocation]
		(
			[InvocationId] [int] IDENTITY(1,1) NOT NULL,
			[ScriptId] [int] NOT NULL,
			[Host] [nvarchar](50) NOT NULL,
			[ScriptFilePath] [nvarchar](400) NOT NULL,
			CONSTRAINT [PK_Invocation] PRIMARY KEY CLUSTERED ([InvocationId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [PRIMARY],
			CONSTRAINT [FK_Invocation_Script]
				FOREIGN KEY ([ScriptId])
				REFERENCES [Logging].[Script]([ScriptId])
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
			AND [tables].[name] = N'Invocation'
			AND [indexes].[name] = N'UX_Invocation_Key'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Invocation_Key]
			ON [Logging].[Invocation]([ScriptId] ASC, [Host] ASC, [ScriptFilePath] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [PRIMARY]
	END
