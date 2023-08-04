IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[tables]
				ON [schemas].[schema_id] = [tables].[schema_id]
		WHERE
			[schemas].[name] = N'AppleHealth'
			AND [tables].[name] = N'Workout'
)
	BEGIN
		CREATE TABLE [AppleHealth].[Workout]
		(
			[WorkoutId] [int] IDENTITY(1, 1) NOT NULL,
			[DataProviderId] [int] NOT NULL,
			[UnitOfMeasureId] [int] NOT NULL,
			[TypeId] [int] NOT NULL,
			[WorkoutGUID] [uniqueidentifier] NOT NULL
				CONSTRAINT [DF_Workout_WorkoutGUID] DEFAULT (NEWSEQUENTIALID()),
			[Key] [varbinary](100) NOT NULL,
			[CreationDate] [datetime2](7) NOT NULL,
			[StartDate] [datetime2](7) NOT NULL,
			[EndDate] [datetime2](7) NOT NULL,
			[Duration] [decimal](32, 18) NULL,
			[EntryDate] [int] NOT NULL,
			[EntryTime] [int] NOT NULL,
			CONSTRAINT [PK_Workout] PRIMARY KEY ([WorkoutId])
				WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
			CONSTRAINT [FK_Workout_DataProvider] FOREIGN KEY([DataProviderId]) REFERENCES [AppleHealth].[DataProvider]([DataProviderId]),
			CONSTRAINT [FK_Workout_UnitOfMeasure] FOREIGN KEY([UnitOfMeasureId]) REFERENCES [AppleHealth].[UnitOfMeasure]([UnitOfMeasureId]),
			CONSTRAINT [FK_Workout_Type] FOREIGN KEY([TypeId]) REFERENCES [AppleHealth].[Type]([TypeId])
		)
		CREATE UNIQUE INDEX [UX_Workout_WorkoutId] ON [AppleHealth].[Workout]([WorkoutId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_Workout_WorkoutGUID] ON [AppleHealth].[Workout]([WorkoutGUID] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE UNIQUE INDEX [UX_Workout_Key] ON [AppleHealth].[Workout]([Key] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Workout_DataProviderId] ON [AppleHealth].[Workout]([DataProviderId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Workout_UnitOfMeasureId] ON [AppleHealth].[Workout]([UnitOfMeasureId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Workout_TypeId] ON [AppleHealth].[Workout]([TypeId] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Workout_EntryDateEntryTime] ON [AppleHealth].[Workout]([EntryDate] ASC, [EntryTime] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		CREATE INDEX [IX_Workout_StartDate] ON [AppleHealth].[Workout]([StartDate] ASC)
			WITH (STATISTICS_NORECOMPUTE = OFF, FILLFACTOR = 100, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	END
