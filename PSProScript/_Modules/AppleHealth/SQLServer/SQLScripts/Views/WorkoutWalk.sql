CREATE OR ALTER VIEW [AppleHealth].[WorkoutWalk]
AS
	SELECT
		[Workout].[WorkoutGUID] AS [EntryGUID],
		[Workout].[EntryDate],
		[Workout].[EntryTime],
		[Workout].[Key],
		[DataProvider].[Name] AS [DataProvider],
		[Type].[Name] AS [Type],
		[Workout].[CreationDate],
		[Workout].[StartDate],
		[Workout].[EndDate],
		[Distance].[DistanceUnitOfMeasure],
		[Distance].[Distance],
		[BasalEnergyBurned].[BasalEnergyBurnedUnitOfMeasure],
		[BasalEnergyBurned].[BasalEnergyBurned],
		[ActiveEnergyBurned].[ActiveEnergyBurnedUnitOfMeasure],
		[ActiveEnergyBurned].[ActiveEnergyBurned],
		[HeartRateMaximum].[HeartRateMaximumUnitOfMeasure],
		[HeartRateMaximum].[HeartRateMaximum],
		[HeartRateMinimum].[HeartRateMinimumUnitOfMeasure],
		[HeartRateMinimum].[HeartRateMinimum]
		FROM [AppleHealth].[Workout]
			INNER JOIN [AppleHealth].[DataProvider]
				ON [Workout].[DataProviderId] = [DataProvider].[DataProviderId]
			INNER JOIN [AppleHealth].[Type]
				ON [Workout].[TypeId] = [Type].[TypeId]
			LEFT OUTER JOIN
			(
				SELECT
					[WorkoutStatistic].[WorkoutId],
					[UnitOfMeasure].[Name] AS [DistanceUnitOfMeasure],
					[WorkoutStatistic].[Value] AS [Distance]
					FROM [AppleHealth].[WorkoutStatistic]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [WorkoutStatistic].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [WorkoutStatistic].[TypeId] = [Type].[TypeId]
						INNER JOIN [AppleHealth].[Aggregate]
							ON [WorkoutStatistic].[AggregateId] = [Aggregate].[AggregateId]
					WHERE
						[Type].[Name] = 'HKQuantityTypeIdentifierDistanceWalkingRunning'
						AND [Aggregate].[Name] = 'Summation'
			) AS [Distance]
				ON [Workout].[WorkoutId] = [Distance].[WorkoutId]
			LEFT OUTER JOIN
			(
				SELECT
					[WorkoutStatistic].[WorkoutId],
					[UnitOfMeasure].[Name] AS [BasalEnergyBurnedUnitOfMeasure],
					[WorkoutStatistic].[Value] AS [BasalEnergyBurned]
					FROM [AppleHealth].[WorkoutStatistic]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [WorkoutStatistic].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [WorkoutStatistic].[TypeId] = [Type].[TypeId]
						INNER JOIN [AppleHealth].[Aggregate]
							ON [WorkoutStatistic].[AggregateId] = [Aggregate].[AggregateId]
					WHERE
						[Type].[Name] = 'HKQuantityTypeIdentifierBasalEnergyBurned'
						AND [Aggregate].[Name] = 'Summation'
			) AS [BasalEnergyBurned]
				ON [Workout].[WorkoutId] = [BasalEnergyBurned].[WorkoutId]
			LEFT OUTER JOIN
			(
				SELECT
					[WorkoutStatistic].[WorkoutId],
					[UnitOfMeasure].[Name] AS [ActiveEnergyBurnedUnitOfMeasure],
					[WorkoutStatistic].[Value] AS [ActiveEnergyBurned]
					FROM [AppleHealth].[WorkoutStatistic]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [WorkoutStatistic].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [WorkoutStatistic].[TypeId] = [Type].[TypeId]
						INNER JOIN [AppleHealth].[Aggregate]
							ON [WorkoutStatistic].[AggregateId] = [Aggregate].[AggregateId]
					WHERE
						[Type].[Name] = 'HKQuantityTypeIdentifierActiveEnergyBurned'
						AND [Aggregate].[Name] = 'Summation'
			) AS [ActiveEnergyBurned]
				ON [Workout].[WorkoutId] = [ActiveEnergyBurned].[WorkoutId]
			LEFT OUTER JOIN
			(
				SELECT
					[WorkoutStatistic].[WorkoutId],
					[UnitOfMeasure].[Name] AS [HeartRateAverageUnitOfMeasure],
					[WorkoutStatistic].[Value] AS [HeartRateAverage]
					FROM [AppleHealth].[WorkoutStatistic]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [WorkoutStatistic].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [WorkoutStatistic].[TypeId] = [Type].[TypeId]
						INNER JOIN [AppleHealth].[Aggregate]
							ON [WorkoutStatistic].[AggregateId] = [Aggregate].[AggregateId]
					WHERE
						[Type].[Name] = 'HKQuantityTypeIdentifierHeartRate'
						AND [Aggregate].[Name] = 'Average'
			) AS [HeartRateAverage]
				ON [Workout].[WorkoutId] = [HeartRateAverage].[WorkoutId]
			LEFT OUTER JOIN
			(
				SELECT
					[WorkoutStatistic].[WorkoutId],
					[UnitOfMeasure].[Name] AS [HeartRateMaximumUnitOfMeasure],
					[WorkoutStatistic].[Value] AS [HeartRateMaximum]
					FROM [WorkoutStatistic]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [WorkoutStatistic].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [WorkoutStatistic].[TypeId] = [Type].[TypeId]
						INNER JOIN [AppleHealth].[Aggregate]
							ON [WorkoutStatistic].[AggregateId] = [Aggregate].[AggregateId]
					WHERE
						[Type].[Name] = 'HKQuantityTypeIdentifierHeartRate'
						AND [Aggregate].[Name] = 'Maximum'
			) AS [HeartRateMaximum]
				ON [Workout].[WorkoutId] = [HeartRateMaximum].[WorkoutId]
			LEFT OUTER JOIN
			(
				SELECT
					[WorkoutStatistic].[WorkoutId],
					[UnitOfMeasure].[Name] AS [HeartRateMinimumUnitOfMeasure],
					[WorkoutStatistic].[Value] AS [HeartRateMinimum]
					FROM [AppleHealth].[WorkoutStatistic]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [WorkoutStatistic].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [WorkoutStatistic].[TypeId] = [Type].[TypeId]
						INNER JOIN [AppleHealth].[Aggregate]
							ON [WorkoutStatistic].[AggregateId] = [Aggregate].[AggregateId]
					WHERE
						[Type].[Name] = 'HKQuantityTypeIdentifierHeartRate'
						AND [Aggregate].[Name] = 'Minimum'
			) AS [HeartRateMinimum]
				ON [Workout].[WorkoutId] = [HeartRateMinimum].[WorkoutId]
		WHERE [Type].[Name] = 'HKWorkoutActivityTypeWalking'
