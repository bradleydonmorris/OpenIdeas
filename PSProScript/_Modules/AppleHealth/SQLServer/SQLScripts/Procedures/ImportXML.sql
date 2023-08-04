CREATE OR ALTER PROCEDURE [AppleHealth].[ImportXML]
(
	@XMLHealthData [xml]
)
AS
BEGIN
	BEGIN --[AppleHealth].[Type]
	INSERT INTO [AppleHealth].[Type]([Name])
		SELECT DISTINCT ISNULL([Source].[Name], N'Unknown')
			FROM
			(
				SELECT N'Unknown' AS [Name]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[RecordXML].[Attributes].value(N'@type', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Record') AS [RecordXML]([Attributes])
					) AS [Record]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[CorrelationXML].[Attributes].value(N'@type', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Correlation') AS [CorrelationXML]([Attributes])
					) AS [Correlation]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[WorkoutXML].[Attributes].value(N'@workoutActivityType', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Workout') AS [WorkoutXML]([Attributes])
					) AS [Workout]
				UNION SELECT DISTINCT [WorkoutWorkoutStatistics].[Type]
					FROM
					(
						SELECT
							[WorkoutWorkoutStatisticsXML].[Attributes].value(N'@type', N'[sys].[sysname]') AS [Type]
							FROM @XMLHealthData.nodes(N'/HealthData/Workout/WorkoutStatistics') AS [WorkoutWorkoutStatisticsXML]([Attributes])
					) AS [WorkoutWorkoutStatistics]
			) AS [Source]
				LEFT OUTER JOIN [AppleHealth].[Type] AS [Target]
					ON ISNULL([Source].[Name], N'Unknown') = [Target].[Name]
			WHERE [Target].[TypeId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[Type] REBUILD PARTITION = ALL
	--SELECT * FROM [AppleHealth].[Type]
	END --[AppleHealth].[Type]

	BEGIN --[AppleHealth].[UnitOfMeasure]
	INSERT INTO [AppleHealth].[UnitOfMeasure]([Name])
		SELECT DISTINCT ISNULL([Source].[Name], N'Unknown')
			FROM
			(
				SELECT N'Unknown' AS [Name]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[RecordXML].[Attributes].value(N'@unit', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Record') AS [RecordXML]([Attributes])
					) AS [Record]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[WorkoutXML].[Attributes].value(N'@durationUnit', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Workout') AS [WorkoutXML]([Attributes])
					) AS [Workout]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[WorkoutWorkoutStatisticsXML].[Attributes].value(N'@unit', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Workout/WorkoutStatistics') AS [WorkoutWorkoutStatisticsXML]([Attributes])
					) AS [WorkoutWorkoutStatistics]
			) AS [Source]
				LEFT OUTER JOIN [AppleHealth].[UnitOfMeasure] AS [Target]
					ON ISNULL([Source].[Name], N'Unknown') = [Target].[Name]
			WHERE [Target].[UnitOfMeasureId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[UnitOfMeasure] REBUILD PARTITION = ALL
	--SELECT * FROM [AppleHealth].[UnitOfMeasure]
	END --[AppleHealth].[UnitOfMeasure]

	BEGIN --[AppleHealth].[DataProvider]
	INSERT INTO [AppleHealth].[DataProvider]([Name])
		SELECT DISTINCT ISNULL([Source].[Name], N'Unknown')
			FROM
			(
				SELECT N'Unknown' AS [Name]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[RecordXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Record') AS [RecordXML]([Attributes])
					) AS [Record]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[CorrelationXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Correlation') AS [CorrelationXML]([Attributes])
					) AS [Correlation]
				UNION SELECT DISTINCT [Name]
					FROM
					(
						SELECT
							[WorkoutXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]') AS [Name]
							FROM @XMLHealthData.nodes(N'/HealthData/Workout') AS [WorkoutXML]([Attributes])
					) AS [Workout]
			) AS [Source]
				LEFT OUTER JOIN [AppleHealth].[DataProvider] AS [Target]
					ON ISNULL([Source].[Name], N'Unknown') = [Target].[Name]
			WHERE [Target].[DataProviderId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[DataProvider] REBUILD PARTITION = ALL
	--SELECT * FROM [AppleHealth].[DataProvider]
	END --[AppleHealth].[DataProvider]

	BEGIN --[AppleHealth].[Reading]
	INSERT INTO [AppleHealth].[Reading]([DataProviderId], [UnitOfMeasureId], [TypeId], [Key], [CreationDate], [StartDate], [EndDate], [Value], [EntryDate], [EntryTime])
		SELECT DISTINCT
			[DataProvider].[DataProviderId],
			[UnitOfMeasure].[UnitOfMeasureId],
			[Type].[TypeId],
			[Source].[Key],
			[Source].[CreationDate],
			[Source].[StartDate],
			[Source].[EndDate],
			[Source].[Value],
			[Source].[EntryDate],
			[Source].[EntryTime]
			FROM
			(
				SELECT
					TRY_CAST
					(
						HASHBYTES
						(
							N'SHA2_256',
							CONCAT
							(
								[DataProvider],
								[UnitOfMeasure],
								[Type],
								[CreationDate],
								[StartDate],
								[EndDate],
								[Value]
							)
						)
						AS [varbinary](100)
					) AS [Key],
					[DataProvider],
					[UnitOfMeasure],
					[Type],
					[CreationDate],
					[StartDate],
					[EndDate],
					CASE
						WHEN ISNUMERIC([Value]) = 1 THEN TRY_CAST([Value] AS [decimal](32, 18))
						WHEN [Value] = N'HKCategoryValueAppleStandHourIdle' THEN 1
						WHEN [Value] = N'HKCategoryValueAppleStandHourStood' THEN 0
						WHEN [Value] = N'HKCategoryValueLowCardioFitnessEventLowFitness' THEN 1
						WHEN [Value] = N'HKCategoryValueSleepAnalysisAsleepCore' THEN 3
						WHEN [Value] = N'HKCategoryValueSleepAnalysisAsleepDeep' THEN 4
						WHEN [Value] = N'HKCategoryValueSleepAnalysisAsleepREM' THEN 5
						WHEN [Value] = N'HKCategoryValueSleepAnalysisAsleepUnspecified' THEN 1
						WHEN [Value] = N'HKCategoryValueSleepAnalysisAwake' THEN 2
						WHEN [Value] = N'HKCategoryValueSleepAnalysisInBed' THEN 0
					END AS [Value],
					TRY_CAST(FORMAT([StartDate], N'yyyyMMdd') AS [int]) AS [EntryDate],
					TRY_CAST(FORMAT([StartDate], N'HHmmss') AS [int]) AS [EntryTime]
					FROM
					(
						SELECT
							ISNULL([RecordXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]'), N'Unknown') AS [DataProvider],
							ISNULL([RecordXML].[Attributes].value(N'@unit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
							ISNULL([RecordXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([RecordXML].[Attributes].value(N'@creationDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [CreationDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([RecordXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([RecordXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
							[RecordXML].[Attributes].value(N'@value', N'[nvarchar](100)') AS [Value]
							FROM @XMLHealthData.nodes(N'/HealthData/Record') AS [RecordXML]([Attributes])
					) AS [Record]
			) AS [Source]
				INNER JOIN [AppleHealth].[DataProvider]
					ON [Source].[DataProvider] = [DataProvider].[Name]
				INNER JOIN [AppleHealth].[UnitOfMeasure]
					ON [Source].[UnitOfMeasure] = [UnitOfMeasure].[Name]
				INNER JOIN [AppleHealth].[Type]
					ON [Source].[Type] = [Type].[Name]
				LEFT OUTER JOIN [AppleHealth].[Reading] AS [Target]
					ON [Source].[Key] = [Target].[Key]
			WHERE [Target].[ReadingId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[Reading] REBUILD PARTITION = ALL
	END --[AppleHealth].[Reading]

	BEGIN --[AppleHealth].[Correlation]
	INSERT INTO [AppleHealth].[Correlation]([DataProviderId], [TypeId], [Key], [CreationDate], [StartDate], [EndDate], [EntryDate], [EntryTime])
		SELECT DISTINCT
			[DataProvider].[DataProviderId],
			[Type].[TypeId],
			[Source].[Key],
			[Source].[CreationDate],
			[Source].[StartDate],
			[Source].[EndDate],
			[Source].[EntryDate],
			[Source].[EntryTime]
			FROM
			(
				SELECT
					TRY_CAST
					(
						HASHBYTES
						(
							N'SHA2_256',
							CONCAT
							(
								[DataProvider],
								[Type],
								[CreationDate],
								[StartDate],
								[EndDate]
							)
						)
						AS [varbinary](100)
					) AS [Key],
					[DataProvider],
					[Type],
					[CreationDate],
					[StartDate],
					[EndDate],
					TRY_CAST(FORMAT([StartDate], N'yyyyMMdd') AS [int]) AS [EntryDate],
					TRY_CAST(FORMAT([StartDate], N'HHmmss') AS [int]) AS [EntryTime]
					FROM
					(
						SELECT
							ISNULL([CorrelationXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]'), N'Unknown') AS [DataProvider],
							ISNULL([CorrelationXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([CorrelationXML].[Attributes].value(N'@creationDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [CreationDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([CorrelationXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([CorrelationXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate]
							FROM @XMLHealthData.nodes(N'/HealthData/Correlation') AS [CorrelationXML]([Attributes])
					) AS [Correlation]
			) AS [Source]
				INNER JOIN [AppleHealth].[DataProvider]
					ON [Source].[DataProvider] = [DataProvider].[Name]
				INNER JOIN [AppleHealth].[Type]
					ON [Source].[Type] = [Type].[Name]
				LEFT OUTER JOIN [AppleHealth].[Correlation] AS [Target]
					ON [Source].[Key] = [Target].[Key]
			WHERE [Target].[CorrelationId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[Correlation] REBUILD PARTITION = ALL
	END --[AppleHealth].[Correlation]

	BEGIN --[AppleHealth].[CorrelationReading]
	INSERT INTO [AppleHealth].[CorrelationReading]([CorrelationId], [ReadingId])
		SELECT DISTINCT
			[Correlation].[CorrelationId],
			[Reading].[ReadingId]
			FROM
			(
				SELECT
					TRY_CAST
					(
						HASHBYTES
						(
							N'SHA2_256',
							CONCAT
							(
								[Correlation].[DataProvider],
								[Correlation].[Type],
								[Correlation].[CreationDate],
								[Correlation].[StartDate],
								[Correlation].[EndDate]
							)
						)
						AS [varbinary](100)
					) AS [CorrelationKey],
					TRY_CAST
					(
						HASHBYTES
						(
							N'SHA2_256',
							CONCAT
							(
								[Reading].[DataProvider],
								[Reading].[UnitOfMeasure],
								[Reading].[Type],
								[Reading].[CreationDate],
								[Reading].[StartDate],
								[Reading].[EndDate],
								[Reading].[Value]
							)
						)
						AS [varbinary](100)
					) AS [ReadingKey]
					FROM
					(
						SELECT
							ISNULL([CorrelationXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]'), N'Unknown') AS [DataProvider],
							ISNULL([CorrelationXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([CorrelationXML].[Attributes].value(N'@creationDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [CreationDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([CorrelationXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([CorrelationXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
							[CorrelationXML].[Attributes].query('Record') AS [Records]
							FROM @XMLHealthData.nodes(N'/HealthData/Correlation') AS [CorrelationXML]([Attributes])
					) AS [Correlation]
						CROSS APPLY
						(
							SELECT
								ISNULL([RecordXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]'), N'Unknown') AS [DataProvider],
								ISNULL([RecordXML].[Attributes].value(N'@unit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
								ISNULL([RecordXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
								CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([RecordXML].[Attributes].value(N'@creationDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [CreationDate],
								CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([RecordXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
								CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([RecordXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
								[RecordXML].[Attributes].value(N'@value', N'[nvarchar](100)') AS [Value]
								FROM [Correlation].[Records].nodes(N'Record') AS [RecordXML]([Attributes])
						) AS [Reading]
			) AS [Source]
				INNER JOIN [AppleHealth].[Correlation]
					ON [Source].[CorrelationKey] = [Correlation].[Key]
				INNER JOIN [AppleHealth].[Reading]
					ON [Source].[ReadingKey] = [Reading].[Key]
				LEFT OUTER JOIN [AppleHealth].[CorrelationReading] AS [Target]
					ON
						[Correlation].[CorrelationId] = [Target].[CorrelationId]
						AND [Reading].[ReadingId] = [Target].[ReadingId]
			WHERE [Target].[CorrelationReadingId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[CorrelationReading] REBUILD PARTITION = ALL
	END --[AppleHealth].[CorrelationReading]

	BEGIN --[AppleHealth].[Workout]
	INSERT INTO [AppleHealth].[Workout]([DataProviderId], [UnitOfMeasureId], [TypeId], [Key], [CreationDate], [StartDate], [EndDate], [Duration], [EntryDate], [EntryTime])
		SELECT DISTINCT
			[DataProvider].[DataProviderId],
			[UnitOfMeasure].[UnitOfMeasureId],
			[Type].[TypeId],
			[Source].[Key],
			[Source].[CreationDate],
			[Source].[StartDate],
			[Source].[EndDate],
			[Source].[Duration],
			[Source].[EntryDate],
			[Source].[EntryTime]
			FROM
			(
				SELECT
					TRY_CAST
					(
						HASHBYTES
						(
							N'SHA2_256',
							CONCAT
							(
								[DataProvider],
								[UnitOfMeasure],
								[Type],
								[CreationDate],
								[StartDate],
								[EndDate],
								[Duration]
							)
						)
						AS [varbinary](100)
					) AS [Key],
					[DataProvider],
					[UnitOfMeasure],
					[Type],
					[CreationDate],
					[StartDate],
					[EndDate],
					CASE
						WHEN ISNUMERIC([Duration]) = 1 THEN TRY_CAST([Duration] AS [decimal](32, 18))
						WHEN [Duration] = N'HKCategoryValueAppleStandHourIdle' THEN 1
						WHEN [Duration] = N'HKCategoryValueAppleStandHourStood' THEN 0
						WHEN [Duration] = N'HKCategoryValueLowCardioFitnessEventLowFitness' THEN 1
						WHEN [Duration] = N'HKCategoryValueSleepAnalysisAsleepCore' THEN 3
						WHEN [Duration] = N'HKCategoryValueSleepAnalysisAsleepDeep' THEN 4
						WHEN [Duration] = N'HKCategoryValueSleepAnalysisAsleepREM' THEN 5
						WHEN [Duration] = N'HKCategoryValueSleepAnalysisAsleepUnspecified' THEN 1
						WHEN [Duration] = N'HKCategoryValueSleepAnalysisAwake' THEN 2
						WHEN [Duration] = N'HKCategoryValueSleepAnalysisInBed' THEN 0
					END AS [Duration],
					TRY_CAST(FORMAT([StartDate], N'yyyyMMdd') AS [int]) AS [EntryDate],
					TRY_CAST(FORMAT([StartDate], N'HHmmss') AS [int]) AS [EntryTime]
					FROM
					(
						SELECT
							ISNULL([WorkoutXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]'), N'Unknown') AS [DataProvider],
							ISNULL([WorkoutXML].[Attributes].value(N'@durationUnit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
							ISNULL([WorkoutXML].[Attributes].value(N'@workoutActivityType', N'[sys].[sysname]'), N'Unknown') AS [Type],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutXML].[Attributes].value(N'@creationDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [CreationDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
							CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
							[WorkoutXML].[Attributes].value(N'@duration', N'[nvarchar](100)') AS [Duration]
							FROM @XMLHealthData.nodes(N'/HealthData/Workout') AS [WorkoutXML]([Attributes])
					) AS [Workout]
			) AS [Source]
				INNER JOIN [AppleHealth].[DataProvider]
					ON [Source].[DataProvider] = [DataProvider].[Name]
				INNER JOIN [AppleHealth].[UnitOfMeasure]
					ON [Source].[UnitOfMeasure] = [UnitOfMeasure].[Name]
				INNER JOIN [AppleHealth].[Type]
					ON [Source].[Type] = [Type].[Name]
				LEFT OUTER JOIN [AppleHealth].[Workout] AS [Target]
					ON [Source].[Key] = [Target].[Key]
			WHERE [Target].[WorkoutId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[Workout] REBUILD PARTITION = ALL
	END --[AppleHealth].[Workout]

	BEGIN --[AppleHealth].[WorkoutStatistic]
	INSERT INTO [AppleHealth].[WorkoutStatistic]([WorkoutId], [UnitOfMeasureId], [TypeId], [AggregateId], [Key], [StartDate], [EndDate], [Value], [EntryDate], [EntryTime])
		SELECT DISTINCT
			[Source].[WorkoutId],
			[UnitOfMeasure].[UnitOfMeasureId],
			[Type].[TypeId],
			[Aggregate].[AggregateId],
			[Source].[Key],
			[Source].[StartDate],
			[Source].[EndDate],
			[Source].[Value],
			[Source].[EntryDate],
			[Source].[EntryTime]
			FROM
			(
				SELECT DISTINCT
					[Workout].[WorkoutId],
					TRY_CAST
					(
						HASHBYTES
						(
							N'SHA2_256',
							CONCAT
							(
								REPLACE(CAST([Workout].[WorkoutGUID] AS [nvarchar](100)), N'-', N''),
								[WorkoutStatistic].[UnitOfMeasure],
								[WorkoutStatistic].[Aggregate],
								[WorkoutStatistic].[Type],
								[WorkoutStatistic].[StartDate],
								[WorkoutStatistic].[EndDate],
								[WorkoutStatistic].[Value]
							)
						)
						AS [varbinary](100)
					) AS [Key],
					[WorkoutStatistic].[UnitOfMeasure],
					[WorkoutStatistic].[Type],
					[WorkoutStatistic].[Aggregate],
					[WorkoutStatistic].[StartDate],
					[WorkoutStatistic].[EndDate],
					TRY_CAST([WorkoutStatistic].[Value] AS [decimal](32, 18)) AS [Value],
					TRY_CAST(FORMAT([WorkoutStatistic].[StartDate], N'yyyyMMdd') AS [int]) AS [EntryDate],
					TRY_CAST(FORMAT([WorkoutStatistic].[StartDate], N'HHmmss') AS [int]) AS [EntryTime]
					FROM
					(
						SELECT
							TRY_CAST
							(
								HASHBYTES
								(
									N'SHA2_256',
									CONCAT
									(
										[Workout].[DataProvider],
										[Workout].[UnitOfMeasure],
										[Workout].[Type],
										[Workout].[CreationDate],
										[Workout].[StartDate],
										[Workout].[EndDate],
										[Workout].[Duration]
									)
								)
								AS [varbinary](100)
							) AS [WorkoutKey],
							[WorkoutStatistics].[UnitOfMeasure],
							[WorkoutStatistics].[Type],
							[WorkoutStatistics].[Aggregate],
							[WorkoutStatistics].[StartDate],
							[WorkoutStatistics].[EndDate],
							[WorkoutStatistics].[Value]
							FROM
							(
								SELECT
									ISNULL([WorkoutXML].[Attributes].value(N'@sourceName', N'[sys].[sysname]'), N'Unknown') AS [DataProvider],
									ISNULL([WorkoutXML].[Attributes].value(N'@durationUnit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
									ISNULL([WorkoutXML].[Attributes].value(N'@workoutActivityType', N'[sys].[sysname]'), N'Unknown') AS [Type],
									CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutXML].[Attributes].value(N'@creationDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [CreationDate],
									CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
									CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
									[WorkoutXML].[Attributes].value(N'@duration', N'[nvarchar](100)') AS [Duration],
									[WorkoutXML].[Attributes].query('WorkoutStatistics') AS [WorkoutStatistics]
									FROM @XMLHealthData.nodes(N'/HealthData/Workout') AS [WorkoutXML]([Attributes])
							) AS [Workout]
								CROSS APPLY
								(
									SELECT
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@unit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
										'Summation' AS [Aggregate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
										[WorkoutStatisticsXML].[Attributes].value(N'@sum', N'[nvarchar](100)') AS [Value]
										FROM [Workout].[WorkoutStatistics].nodes(N'WorkoutStatistics') AS [WorkoutStatisticsXML]([Attributes])
									UNION ALL SELECT
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@unit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
										'Average' AS [Aggregate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
										[WorkoutStatisticsXML].[Attributes].value(N'@average', N'[nvarchar](100)') AS [Value]
										FROM [Workout].[WorkoutStatistics].nodes(N'WorkoutStatistics') AS [WorkoutStatisticsXML]([Attributes])
									UNION ALL SELECT
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@unit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
										'Minimum' AS [Aggregate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
										[WorkoutStatisticsXML].[Attributes].value(N'@minimum', N'[nvarchar](100)') AS [Value]
										FROM [Workout].[WorkoutStatistics].nodes(N'WorkoutStatistics') AS [WorkoutStatisticsXML]([Attributes])
									UNION ALL SELECT
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@unit', N'[sys].[sysname]'), N'Unknown') AS [UnitOfMeasure],
										ISNULL([WorkoutStatisticsXML].[Attributes].value(N'@type', N'[sys].[sysname]'), N'Unknown') AS [Type],
										'Maximum' AS [Aggregate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@startDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [StartDate],
										CAST(SWITCHOFFSET(TRY_CONVERT([datetimeoffset](7), STUFF([WorkoutStatisticsXML].[Attributes].value(N'@endDate', N'[nvarchar](25)'), 24, 0, N':'), 0), N'+00:00') AS [datetime2](7)) AS [EndDate],
										[WorkoutStatisticsXML].[Attributes].value(N'@maximum', N'[nvarchar](100)') AS [Value]
										FROM [Workout].[WorkoutStatistics].nodes(N'WorkoutStatistics') AS [WorkoutStatisticsXML]([Attributes])
								) AS [WorkoutStatistics]
							WHERE NULLIF([WorkoutStatistics].[Value], N'') IS NOT NULL
					) AS [WorkoutStatistic]
						INNER JOIN [AppleHealth].[Workout]
							ON [WorkoutStatistic].[WorkoutKey] = [Workout].[Key]
			) AS [Source]
				INNER JOIN [AppleHealth].[UnitOfMeasure]
					ON [Source].[UnitOfMeasure] = [UnitOfMeasure].[Name]
				INNER JOIN [AppleHealth].[Type]
					ON [Source].[Type] = [Type].[Name]
				INNER JOIN [AppleHealth].[Aggregate]
					ON [Source].[Aggregate] = [Aggregate].[Name]
				LEFT OUTER JOIN [AppleHealth].[WorkoutStatistic] AS [Target]
					ON [Source].[Key] = [Target].[Key]
			WHERE [Target].[WorkoutId] IS NULL
	ALTER INDEX ALL ON [AppleHealth].[WorkoutStatistic] REBUILD PARTITION = ALL
	END --[AppleHealth].[WorkoutStatistic]
END
