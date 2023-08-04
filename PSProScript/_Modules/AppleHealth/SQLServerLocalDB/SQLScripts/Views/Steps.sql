CREATE OR ALTER VIEW [AppleHealth].[Steps]
AS
	SELECT
		[Reading].[Date],
		[UnitOfMeasure].[Name] AS [UnitOfMeasure],
		TRY_CAST([Reading].[Value] AS [int]) AS [Steps]
		FROM
		(
			SELECT
				TRY_CAST([Reading].[StartDate] AS [date]) AS [Date],
				[Reading].[UnitOfMeasureId],
				SUM([Reading].[Value]) AS [Value]
				FROM [AppleHealth].[Reading]
					INNER JOIN [AppleHealth].[UnitOfMeasure]
						ON [Reading].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
					INNER JOIN [AppleHealth].[Type]
						ON [Reading].[TypeId] = [Type].[TypeId]
				WHERE [Type].[Name] = 'HKQuantityTypeIdentifierStepCount'
				GROUP BY
					TRY_CAST([Reading].[StartDate] AS [date]),
					[Reading].[UnitOfMeasureId]
		) AS [Reading]
			INNER JOIN [AppleHealth].[UnitOfMeasure]
				ON [Reading].[UnitOfMeasureId] = [UnitOfMeasure].[UnitOfMeasureId]
