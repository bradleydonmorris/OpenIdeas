IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'Logging'
			AND [tables].[name] = N'Level'
)
	BEGIN
		CREATE TABLE [Logging].[Level]
		(
			[LevelId] [tinyint] IDENTITY(1,1) NOT NULL,
			[Name] [nvarchar](30) NOT NULL,
			CONSTRAINT [PK_Level] PRIMARY KEY CLUSTERED ([LevelId] ASC)
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
				ON [PRIMARY]
		) ON [PRIMARY]
		CREATE UNIQUE NONCLUSTERED INDEX [UX_Level_Key]
			ON [Logging].[Level]([Name] ASC)
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
			ON [PRIMARY]
		INSERT INTO [Logging].[Level]([Name])
			SELECT [Source].[Name]
				FROM
				(
					VALUES
						(N'Information'),
						(N'Warning'),
						(N'Error'),
						(N'Debug'),
						(N'Fatal')
				) [Source]([Name])
					LEFT OUTER JOIN [Logging].[Level] AS [Target] 
						ON [Source].[Name] = [Target].[Name]
				WHERE [Target].[LevelId] IS NULL
	END