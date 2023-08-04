IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'CorrelationReading'
)
	BEGIN
		CREATE TABLE [AppleHealth].[CorrelationReading]
		(
			[CorrelationReadingId] [int] IDENTITY(1, 1) NOT NULL,
			[CorrelationId] [int] NOT NULL,
			[ReadingId] [int] NOT NULL,
			CONSTRAINT [PK_CorrelationReading] PRIMARY KEY ([CorrelationReadingId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
			CONSTRAINT [FK_CorrelationReading_Correlation] FOREIGN KEY([CorrelationId]) REFERENCES [AppleHealth].[Correlation]([CorrelationId]),
			CONSTRAINT [FK_CorrelationReading_Reading] FOREIGN KEY([ReadingId]) REFERENCES [AppleHealth].[Reading]([ReadingId])
		)
		CREATE UNIQUE INDEX [UX_CorrelationReading_CorrelationReadingId] ON [AppleHealth].[CorrelationReading]([CorrelationReadingId] ASC)
		CREATE INDEX [IX_CorrelationReading_CorrelationId] ON [AppleHealth].[CorrelationReading]([CorrelationId] ASC)
		CREATE INDEX [IX_CorrelationReading_ReadingId] ON [AppleHealth].[CorrelationReading]([ReadingId] ASC)
	END
