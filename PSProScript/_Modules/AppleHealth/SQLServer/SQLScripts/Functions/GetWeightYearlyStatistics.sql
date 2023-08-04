CREATE OR ALTER FUNCTION [AppleHealth].[GetWeightYearlyStatistics]
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
						TRY_CAST([Aggregate].[Weight] AS [decimal](18, 2)) AS [Weight]
						FROM
						(
							SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[Weight]
								FROM
								(
									SELECT
										MIN([Weight].[Weight]) AS [LowestWeight],
										MAX([Weight].[Weight]) AS [HighestWeight]
										FROM [AppleHealth].[Weight]
										WHERE YEAR([Weight].[StartDate]) = @Year
								) AS [Weight_Aggregates]
									CROSS APPLY
									(
										SELECT
											'Lowest' AS [Aggregation],
											[Weight].[StartDate] AS [Date],
											[Weight].[Weight]
											FROM
											(
												SELECT
													[Weight].[Weight],
													MAX([Weight].[StartDate]) AS [StartDate]
													FROM [AppleHealth].[Weight]
													WHERE [Weight].[Weight] = [Weight_Aggregates].[LowestWeight]
													GROUP BY [Weight].[Weight]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[Weight]
													ON
														[LastOccurence].[Weight] = [Weight].[Weight]
														AND [LastOccurence].[StartDate] = [Weight].[StartDate]
										UNION ALL SELECT
											'Highest' AS [Aggregation],
											[Weight].[StartDate] AS [Date],
											[Weight].[Weight]
											FROM
											(
												SELECT
													[Weight].[Weight],
													MAX([Weight].[StartDate]) AS [StartDate]
													FROM [AppleHealth].[Weight]
													WHERE [Weight].[Weight] = [Weight_Aggregates].[HighestWeight]
													GROUP BY [Weight].[Weight]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[Weight]
													ON
														[LastOccurence].[Weight] = [Weight].[Weight]
														AND [LastOccurence].[StartDate] = [Weight].[StartDate]
									) AS [Pivot]
							UNION ALL SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[Weight]
								FROM
								(
									SELECT
										MIN([Weight].[StartDate]) AS [FirstStartDate],
										MAX([Weight].[StartDate]) AS [LastStartDate]
										FROM [AppleHealth].[Weight]
										WHERE YEAR([Weight].[StartDate]) = @Year
								) AS [Weight_Dates]
									CROSS APPLY
									(
										SELECT
											'First' AS [Aggregation],
											[Weight].[StartDate] AS [Date],
											[Weight].[Weight]
											FROM [AppleHealth].[Weight]
											WHERE [Weight].[StartDate] = [Weight_Dates].[FirstStartDate]
										UNION ALL SELECT
											'Last' AS [Aggregation],
											[Weight].[StartDate] AS [Date],
											[Weight].[Weight]
											FROM [AppleHealth].[Weight]
											WHERE [Weight].[StartDate] = [Weight_Dates].[LastStartDate]
									) AS [Pivot]
						) AS [Aggregate]
							FOR JSON PATH
				)) AS [Aggregates],
				JSON_QUERY((
					SELECT
						FORMAT([WeightFirstOfTheDay].[StartDate], N'yyyy-MM-dd') AS [Date],
						TRY_CAST([WeightFirstOfTheDay].[Weight] AS [decimal](18, 2)) AS [Weight]
						FROM [AppleHealth].[WeightFirstOfTheDay]
						WHERE YEAR([WeightFirstOfTheDay].[StartDate]) = @Year
						ORDER BY [WeightFirstOfTheDay].[StartDate]
						FOR JSON PATH
				)) AS [Values]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	)
END
