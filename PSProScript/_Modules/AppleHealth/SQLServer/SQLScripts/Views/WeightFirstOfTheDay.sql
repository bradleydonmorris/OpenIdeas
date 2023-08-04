CREATE OR ALTER VIEW [AppleHealth].[WeightFirstOfTheDay]
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
		TRY_CAST([Reading].[Value] AS [decimal](18, 2)) AS [Weight]
		FROM
		(
			SELECT
				[Reading].[ReadingId]
				FROM
				(
					SELECT
						[Reading].[TypeId],
						[Reading].[EntryDate],
						MIN([Reading].[EntryTime]) AS [EntryTime]
						FROM [AppleHealth].[Reading]
						GROUP BY
							[Reading].[TypeId],
							[Reading].[EntryDate]
				) AS [Reading_FirstOfDay]
					INNER JOIN [AppleHealth].[Reading]
						ON
							[Reading_FirstOfDay].[TypeId] = [Reading].[TypeId]
							AND [Reading_FirstOfDay].[EntryDate] = [Reading].[EntryDate]
							AND [Reading_FirstOfDay].[EntryTime] = [Reading].[EntryTime]
		) AS [Reading_FirstOfDay]
			INNER JOIN [AppleHealth].[Reading]
				ON [Reading_FirstOfDay].[ReadingId] = [Reading].[ReadingId]
			INNER JOIN [AppleHealth].[DataProvider]
				ON [Reading].[DataProviderId] = [DataProvider].[DataProviderId]
			INNER JOIN [AppleHealth].[UnitOfMeasure]
				ON [Reading].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
			INNER JOIN [AppleHealth].[Type]
				ON [Reading].[TypeId] = [Type].[TypeId]
		WHERE [Type].[Name] = 'HKQuantityTypeIdentifierBodyMass'
