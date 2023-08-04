IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'Aggregate'
)
	BEGIN
		CREATE TABLE [AppleHealth].[Aggregate]
		(
			[AggregateId] [int] IDENTITY(1, 1) NOT NULL,
			[Name] [varchar](100) NOT NULL,
			CONSTRAINT [PK_Aggregate] PRIMARY KEY ([AggregateId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		)
		CREATE UNIQUE INDEX [UX_Aggregate_AggregateId] ON [AppleHealth].[Aggregate]([AggregateId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_Aggregate_Name] ON [AppleHealth].[Aggregate]([Name] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		INSERT INTO [AppleHealth].[Aggregate]([Name])
			VALUES
				('Average'),
				('Summation'),
				('Minimum'),
				('Maximum')
	END
