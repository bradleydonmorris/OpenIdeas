IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'WorkoutStatistic'
)
	BEGIN
		CREATE TABLE [AppleHealth].[WorkoutStatistic]
		(
			[WorkoutStatisticId] [int] IDENTITY(1, 1) NOT NULL,
			[WorkoutId] [int] NOT NULL,
			[UnitOfMeasureId] [int] NOT NULL,
			[TypeId] [int] NOT NULL,
			[AggregateId] [int] NOT NULL,
			[WorkoutStatisticGUID] [uniqueidentifier] NOT NULL
				CONSTRAINT [DF_WorkoutStatistic_WorkoutStatisticGUID] DEFAULT (NEWSEQUENTIALID()),
			[Key] [varbinary](100) NOT NULL,
			[StartDate] [datetime2](7) NOT NULL,
			[EndDate] [datetime2](7) NOT NULL,
			[Value] [decimal](32, 18) NULL,
			[EntryDate] [int] NOT NULL,
			[EntryTime] [int] NOT NULL,
			CONSTRAINT [PK_WorkoutStatistic] PRIMARY KEY ([WorkoutStatisticId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
			CONSTRAINT [FK_WorkoutStatistic_Workout] FOREIGN KEY([WorkoutId]) REFERENCES [AppleHealth].[Workout]([WorkoutId]),
			CONSTRAINT [FK_WorkoutStatistic_UnitOfMeasure] FOREIGN KEY([UnitOfMeasureId]) REFERENCES [AppleHealth].[UnitOfMeasure]([UnitOfMeasureId]),
			CONSTRAINT [FK_WorkoutStatistic_Type] FOREIGN KEY([TypeId]) REFERENCES [AppleHealth].[Type]([TypeId]),
			CONSTRAINT [FK_WorkoutStatistic_Aggregate] FOREIGN KEY([AggregateId]) REFERENCES [AppleHealth].[Aggregate]([AggregateId])
		)
		CREATE UNIQUE INDEX [UX_WorkoutStatistic_WorkoutStatisticId] ON [AppleHealth].[WorkoutStatistic]([WorkoutStatisticId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_WorkoutStatistic_WorkoutStatisticGUID] ON [AppleHealth].[WorkoutStatistic]([WorkoutStatisticGUID] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_WorkoutStatistic_Key] ON [AppleHealth].[WorkoutStatistic]([Key] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_WorkoutStatistic_WorkoutId] ON [AppleHealth].[WorkoutStatistic]([WorkoutId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_WorkoutStatistic_UnitOfMeasureId] ON [AppleHealth].[WorkoutStatistic]([UnitOfMeasureId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_WorkoutStatistic_TypeId] ON [AppleHealth].[WorkoutStatistic]([TypeId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_WorkoutStatistic_AggregateId] ON [AppleHealth].[WorkoutStatistic]([AggregateId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_WorkoutStatistic_EntryDateEntryTime] ON [AppleHealth].[WorkoutStatistic]([EntryDate] ASC, [EntryTime] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_WorkoutStatistic_StartDate] ON [AppleHealth].[WorkoutStatistic]([StartDate] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	END
