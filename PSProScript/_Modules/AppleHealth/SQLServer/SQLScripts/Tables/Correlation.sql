IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'Correlation'
)
	BEGIN
		CREATE TABLE [AppleHealth].[Correlation]
		(
			[CorrelationId] [int] IDENTITY(1, 1) NOT NULL,
			[DataProviderId] [int] NOT NULL,
			[TypeId] [int] NOT NULL,
			[CorrelationGUID] [uniqueidentifier] NOT NULL
				CONSTRAINT [DF_Correlation_CorrelationGUID] DEFAULT (NEWSEQUENTIALID()),
			[Key] [varbinary](100) NOT NULL,
			[CreationDate] [datetime2](7) NOT NULL,
			[StartDate] [datetime2](7) NOT NULL,
			[EndDate] [datetime2](7) NOT NULL,
			[EntryDate] [int] NOT NULL,
			[EntryTime] [int] NOT NULL,
			CONSTRAINT [PK_Correlation] PRIMARY KEY ([CorrelationId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
			CONSTRAINT [FK_Correlation_DataProvider] FOREIGN KEY([DataProviderId]) REFERENCES [AppleHealth].[DataProvider]([DataProviderId]),
			CONSTRAINT [FK_Correlation_Type] FOREIGN KEY([TypeId]) REFERENCES [AppleHealth].[Type]([TypeId])
		)
		CREATE UNIQUE INDEX [UX_Correlation_CorrelationId] ON [AppleHealth].[Correlation]([CorrelationId] ASC)
		CREATE UNIQUE INDEX [UX_Correlation_CorrelationGUID] ON [AppleHealth].[Correlation]([CorrelationGUID] ASC)
		CREATE UNIQUE INDEX [UX_Correlation_Key] ON [AppleHealth].[Correlation]([Key] ASC)
		CREATE INDEX [IX_Correlation_DataProviderId] ON [AppleHealth].[Correlation]([DataProviderId] ASC)
		CREATE INDEX [IX_Correlation_TypeId] ON [AppleHealth].[Correlation]([TypeId] ASC)
		CREATE INDEX [IX_Correlation_EntryDateEntryTime] ON [AppleHealth].[Correlation]([EntryDate] ASC, [EntryTime] ASC)
		CREATE INDEX [IX_Correlation_StartDate] ON [AppleHealth].[Correlation]([StartDate] ASC)
	END
