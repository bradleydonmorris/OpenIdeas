CREATE OR ALTER VIEW [AppleHealth].[RestingHeartRate]
AS
	SELECT
		[Reading].[ReadingGUID] AS [EntryGUID],
		[Reading].[EntryDate],
		[Reading].[EntryTime],
		[Reading].[Key],
		[DataProvider].[Name] AS [DataProvider],
		[Type].[Name] AS [Type],
		[Reading].[CreationDate],
		[Reading].[StartDate],
		[Reading].[EndDate],
		[UnitOfMeasure].[Name] AS [UnitOfMeasure],
		TRY_CAST([Reading].[Value] AS [decimal](18, 2)) AS [RestingHeartRate]
		FROM [AppleHealth].[Reading]
			INNER JOIN [AppleHealth].[DataProvider]
				ON [Reading].[DataProviderId] = [DataProvider].[DataProviderId]
			INNER JOIN [AppleHealth].[UnitOfMeasure]
				ON [Reading].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
			INNER JOIN [AppleHealth].[Type]
				ON [Reading].[TypeId] = [Type].[TypeId]
		WHERE [Type].[Name] = 'HKQuantityTypeIdentifierRestingHeartRate'
