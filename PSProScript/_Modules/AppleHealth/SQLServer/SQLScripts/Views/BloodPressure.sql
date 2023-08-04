CREATE OR ALTER VIEW [AppleHealth].[BloodPressure]
AS
	SELECT
		[Correlation].[CorrelationGUID] AS [EntryGUID],
		[Correlation].[EntryDate],
		[Correlation].[EntryTime],
		[Correlation].[Key],
		[DataProvider_Correlation].[Name] AS [DataProvider],
		[Type_Correlation].[Name] AS [Type],
		[Correlation].[CreationDate],
		[Correlation].[StartDate],
		[Correlation].[EndDate],
		[Systolic].[UnitOfMeasure],
		TRY_CAST([Systolic].[Value] AS [int]) AS [Systolic],
		TRY_CAST([Diastolic].[Value] AS [int])  AS [Diastolic],
		((([Systolic].[Value] - [Diastolic].[Value]) / 3.0) + [Diastolic].[Value]) AS [MeanArterialPressure],
		([Systolic].[Value] * ((([Systolic].[Value] - [Diastolic].[Value]) / 3.0) + [Diastolic].[Value])) AS [ValuesBasedKey]
		FROM [AppleHealth].[Correlation]
			INNER JOIN [AppleHealth].[DataProvider] AS [DataProvider_Correlation]
				ON [Correlation].[DataProviderId] = [DataProvider_Correlation].[DataProviderId]
			INNER JOIN [AppleHealth].[Type] AS [Type_Correlation]
				ON [Correlation].[TypeId] = [Type_Correlation].[TypeId]
			INNER JOIN
			(
				SELECT
					[CorrelationReading].[CorrelationId],
					[UnitOfMeasure].[Name] AS [UnitOfMeasure],
					[Reading].[Value]
					FROM [AppleHealth].[CorrelationReading]
						INNER JOIN [AppleHealth].[Reading]
							ON [CorrelationReading].[ReadingId] = [Reading].[ReadingId]
						INNER JOIN [AppleHealth].[UnitOfMeasure]
							ON [Reading].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
						INNER JOIN [AppleHealth].[Type]
							ON [Reading].[TypeId] = [Type].[TypeId]
					WHERE [Type].[Name] = 'HKQuantityTypeIdentifierBloodPressureSystolic'
			) AS [Systolic]
				ON [Correlation].[CorrelationId] = [Systolic].[CorrelationId]
			INNER JOIN
			(
				SELECT
					[CorrelationReading].[CorrelationId],
					[Reading].[Value]
					FROM [AppleHealth].[CorrelationReading]
						INNER JOIN [AppleHealth].[Reading]
							ON [CorrelationReading].[ReadingId] = [Reading].[ReadingId]
						INNER JOIN [AppleHealth].[Type]
							ON [Reading].[TypeId] = [Type].[TypeId]
					WHERE [Type].[Name] = 'HKQuantityTypeIdentifierBloodPressureDiastolic'
			) AS [Diastolic]
				ON [Correlation].[CorrelationId] = [Diastolic].[CorrelationId]
		WHERE [Type_Correlation].[Name] = 'HKCorrelationTypeIdentifierBloodPressure'
