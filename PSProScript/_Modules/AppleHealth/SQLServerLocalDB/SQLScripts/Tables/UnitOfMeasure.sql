IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'UnitOfMeasure'
)
	BEGIN
		CREATE TABLE [AppleHealth].[UnitOfMeasure]
		(
			[UnitOfMeasureId] [int] IDENTITY(1, 1) NOT NULL,
			[Name] [varchar](100) NOT NULL,
			CONSTRAINT [PK_UnitOfMeasure] PRIMARY KEY ([UnitOfMeasureId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		)
		CREATE UNIQUE INDEX [UX_UnitOfMeasure_UnitOfMeasureId] ON [AppleHealth].[UnitOfMeasure]([UnitOfMeasureId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_UnitOfMeasure_Name] ON [AppleHealth].[UnitOfMeasure]([Name] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	END
