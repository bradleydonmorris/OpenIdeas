IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'DataProvider'
)
	BEGIN
		CREATE TABLE [AppleHealth].[DataProvider]
		(
			[DataProviderId] [int] IDENTITY(1, 1) NOT NULL,
			[Name] [varchar](100) NOT NULL,
			CONSTRAINT [PK_DataProvider] PRIMARY KEY ([DataProviderId])
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		)
		CREATE UNIQUE INDEX [UX_DataProvider_DataProviderId] ON [AppleHealth].[DataProvider]([DataProviderId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_DataProvider_Name] ON [AppleHealth].[DataProvider]([Name] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	END
