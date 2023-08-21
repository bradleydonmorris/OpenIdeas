IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Project'
)
	BEGIN
		CREATE TABLE [Logging].[Project]
		(
			[ProjectId] [int] IDENTITY(1,1) NOT NULL,
			[Name] [nvarchar](50) NOT NULL,
			CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [PRIMARY]
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
			AND [tables].[name] = N'Project'
			AND [indexes].[name] = N'UX_Project_Key'
)
	BEGIN
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Project_Key]
			ON [Logging].[Project]([Name] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [PRIMARY]
	END