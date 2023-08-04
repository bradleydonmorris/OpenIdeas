CREATE OR ALTER VIEW [AppleHealth].[EnergyBurned]
AS
	SELECT
		[Date].[Date],
		TRY_CAST([BasalEnergyBurned].[BasalEnergyBurned] AS [decimal](18, 2)) AS [BasalEnergyBurned],
		TRY_CAST([ActiveEnergyBurned].[ActiveEnergyBurned] AS [decimal](18, 2)) AS [ActiveEnergyBurned],
		(
			(
				[BasalEnergyBurned].[BasalEnergyBurned]
				+ [ActiveEnergyBurned].[ActiveEnergyBurned]
			)
			* [ActiveEnergyBurned].[ActiveEnergyBurned]
		) AS [ValueBasedKey]
		FROM
		(
			SELECT DISTINCT
				TRY_CAST([Reading].[StartDate] AS [date]) AS [Date]
				FROM [AppleHealth].[Reading]
					INNER JOIN [AppleHealth].[Type]
						ON [Reading].[TypeId] = [Type].[TypeId]
				WHERE
					[Type].[Name] = 'HKQuantityTypeIdentifierBasalEnergyBurned'
					OR [Type].[Name] = 'HKQuantityTypeIdentifierActiveEnergyBurned'
		) AS [Date]
			LEFT OUTER JOIN
			(
				SELECT
					[BasalEnergyBurned].[Date],
					SUM([BasalEnergyBurned].[BasalEnergyBurned]) AS [BasalEnergyBurned]
					FROM
					(
						SELECT
							TRY_CAST([Reading].[StartDate] AS [date]) AS [Date],
							[Reading].[Value] AS [BasalEnergyBurned]
							FROM [AppleHealth].[Reading]
								INNER JOIN [AppleHealth].[Type]
									ON [Reading].[TypeId] = [Type].[TypeId]
							WHERE [Type].[Name] = 'HKQuantityTypeIdentifierBasalEnergyBurned'
					) AS [BasalEnergyBurned]
						GROUP BY [BasalEnergyBurned].[Date]
			) AS [BasalEnergyBurned]
				ON [Date].[Date] = [BasalEnergyBurned].[Date]
			LEFT OUTER JOIN
			(
				SELECT
					[ActiveEnergyBurned].[Date],
					SUM([ActiveEnergyBurned].[ActiveEnergyBurned]) AS [ActiveEnergyBurned]
					FROM
					(
						SELECT
							TRY_CAST([Reading].[StartDate] AS [date]) AS [Date],
							[Reading].[Value] AS [ActiveEnergyBurned]
							FROM [AppleHealth].[Reading]
								INNER JOIN [AppleHealth].[Type]
									ON [Reading].[TypeId] = [Type].[TypeId]
							WHERE [Type].[Name] = 'HKQuantityTypeIdentifierActiveEnergyBurned'
					) AS [ActiveEnergyBurned]
						GROUP BY [ActiveEnergyBurned].[Date]
			) AS [ActiveEnergyBurned]
				ON [Date].[Date] = [ActiveEnergyBurned].[Date]
