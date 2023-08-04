CREATE OR ALTER FUNCTION [AppleHealth].[GetRestingHeartRateYearlyStatistics]
(
	@Year [int]
)
RETURNS [nvarchar](MAX)
AS
BEGIN
	RETURN CONVERT(
		[nvarchar](MAX),
		(
			SELECT
				JSON_QUERY((
					SELECT
						[Aggregate].[Aggregation],
						FORMAT([Aggregate].[Date], N'yyyy-MM-dd') AS [Date],
						TRY_CAST([Aggregate].[RestingHeartRate] AS [decimal](18, 2)) AS [RestingHeartRate]
						FROM
						(
							SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[RestingHeartRate]
								FROM
								(
									SELECT
										MIN([RestingHeartRate].[RestingHeartRate]) AS [LowestRestingHeartRate],
										MAX([RestingHeartRate].[RestingHeartRate]) AS [HighestRestingHeartRate]
										FROM [AppleHealth].[RestingHeartRate]
										WHERE YEAR([RestingHeartRate].[StartDate]) = @Year
								) AS [RestingHeartRate_Aggregates]
									CROSS APPLY
									(
										SELECT
											'Lowest' AS [Aggregation],
											[RestingHeartRate].[StartDate] AS [Date],
											[RestingHeartRate].[RestingHeartRate]
											FROM
											(
												SELECT
													[RestingHeartRate].[RestingHeartRate],
													MAX([RestingHeartRate].[StartDate]) AS [StartDate]
													FROM [AppleHealth].[RestingHeartRate]
													WHERE [RestingHeartRate].[RestingHeartRate] = [RestingHeartRate_Aggregates].[LowestRestingHeartRate]
													GROUP BY [RestingHeartRate].[RestingHeartRate]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[RestingHeartRate]
													ON
														[LastOccurence].[RestingHeartRate] = [RestingHeartRate].[RestingHeartRate]
														AND [LastOccurence].[StartDate] = [RestingHeartRate].[StartDate]
										UNION ALL SELECT
											'Highest' AS [Aggregation],
											[RestingHeartRate].[StartDate] AS [Date],
											[RestingHeartRate].[RestingHeartRate]
											FROM
											(
												SELECT
													[RestingHeartRate].[RestingHeartRate],
													MAX([RestingHeartRate].[StartDate]) AS [StartDate]
													FROM [AppleHealth].[RestingHeartRate]
													WHERE [RestingHeartRate].[RestingHeartRate] = [RestingHeartRate_Aggregates].[HighestRestingHeartRate]
													GROUP BY [RestingHeartRate].[RestingHeartRate]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[RestingHeartRate]
													ON
														[LastOccurence].[RestingHeartRate] = [RestingHeartRate].[RestingHeartRate]
														AND [LastOccurence].[StartDate] = [RestingHeartRate].[StartDate]
									) AS [Pivot]
							UNION ALL SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[RestingHeartRate]
								FROM
								(
									SELECT
										MIN([RestingHeartRate].[StartDate]) AS [FirstStartDate],
										MAX([RestingHeartRate].[StartDate]) AS [LastStartDate]
										FROM [AppleHealth].[RestingHeartRate]
										WHERE YEAR([RestingHeartRate].[StartDate]) = @Year
								) AS [RestingHeartRate_Dates]
									CROSS APPLY
									(
										SELECT
											'First' AS [Aggregation],
											[RestingHeartRate].[StartDate] AS [Date],
											[RestingHeartRate].[RestingHeartRate]
											FROM [AppleHealth].[RestingHeartRate]
											WHERE [RestingHeartRate].[StartDate] = [RestingHeartRate_Dates].[FirstStartDate]
										UNION ALL SELECT
											'Last' AS [Aggregation],
											[RestingHeartRate].[StartDate] AS [Date],
											[RestingHeartRate].[RestingHeartRate]
											FROM [AppleHealth].[RestingHeartRate]
											WHERE [RestingHeartRate].[StartDate] = [RestingHeartRate_Dates].[LastStartDate]
									) AS [Pivot]
						) AS [Aggregate]
							FOR JSON PATH
				)) AS [Aggregates],
				JSON_QUERY((
					SELECT
						FORMAT([RestingHeartRateFirstOfTheDay].[StartDate], N'yyyy-MM-dd') AS [Date],
						TRY_CAST([RestingHeartRateFirstOfTheDay].[RestingHeartRate] AS [decimal](18, 2)) AS [RestingHeartRate]
						FROM [AppleHealth].[RestingHeartRateFirstOfTheDay]
						WHERE YEAR([RestingHeartRateFirstOfTheDay].[StartDate]) = @Year
						ORDER BY [RestingHeartRateFirstOfTheDay].[StartDate]
						FOR JSON PATH
				)) AS [Values]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	)
END
