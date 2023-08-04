IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'Reading'
)
	BEGIN
		CREATE TABLE [AppleHealth].[Reading]
		(
			[ReadingId] [int] IDENTITY(1, 1) NOT NULL,
			[DataProviderId] [int] NOT NULL,
			[UnitOfMeasureId] [int] NOT NULL,
			[TypeId] [int] NOT NULL,
			[ReadingGUID] [uniqueidentifier] NOT NULL
				CONSTRAINT [DF_Asset_IsRemoved] DEFAULT (NEWSEQUENTIALID()),
			[Key] [varbinary](100) NOT NULL,
			[CreationDate] [datetime2](7) NOT NULL,
			[StartDate] [datetime2](7) NOT NULL,
			[EndDate] [datetime2](7) NOT NULL,
			[Value] [decimal](32, 18) NULL,
			[EntryDate] [int] NOT NULL,
			[EntryTime] [int] NOT NULL,
			CONSTRAINT [PK_Reading] PRIMARY KEY ([ReadingId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
			CONSTRAINT [FK_Reading_DataProvider] FOREIGN KEY([DataProviderId]) REFERENCES [AppleHealth].[DataProvider]([DataProviderId]),
			CONSTRAINT [FK_Reading_UnitOfMeasure] FOREIGN KEY([UnitOfMeasureId]) REFERENCES [AppleHealth].[UnitOfMeasure]([UnitOfMeasureId]),
			CONSTRAINT [FK_Reading_Type] FOREIGN KEY([TypeId]) REFERENCES [AppleHealth].[Type]([TypeId])
		)
		CREATE UNIQUE INDEX [UX_Reading_ReadingId] ON [AppleHealth].[Reading]([ReadingId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_Reading_ReadingGUID] ON [AppleHealth].[Reading]([ReadingGUID] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_Reading_Key] ON [AppleHealth].[Reading]([Key] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Reading_DataProviderId] ON [AppleHealth].[Reading]([DataProviderId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Reading_UnitOfMeasureId] ON [AppleHealth].[Reading]([UnitOfMeasureId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Reading_TypeId] ON [AppleHealth].[Reading]([TypeId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Reading_EntryDateEntryTime] ON [AppleHealth].[Reading]([EntryDate] ASC, [EntryTime] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Reading_StartDate] ON [AppleHealth].[Reading]([StartDate] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	END
