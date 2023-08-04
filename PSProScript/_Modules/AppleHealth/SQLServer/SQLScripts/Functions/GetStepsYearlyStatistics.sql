CREATE OR ALTER FUNCTION [AppleHealth].[GetStepsYearlyStatistics]
(
	@Year [int] = 2023
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
						TRY_CAST([Aggregate].[Steps] AS [decimal](18, 2)) AS [Steps]
						FROM
						(
							SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[Steps]
								FROM
								(
									SELECT
										MIN([Steps].[Steps]) AS [LowestSteps],
										MAX([Steps].[Steps]) AS [HighestSteps]
										FROM [AppleHealth].[Steps]
										WHERE YEAR([Steps].[Date]) = @Year
								) AS [Steps_Aggregates]
									CROSS APPLY
									(
										SELECT
											'Lowest' AS [Aggregation],
											[Steps].[Date],
											[Steps].[Steps]
											FROM
											(
												SELECT
													[Steps].[Steps],
													MAX([Steps].[Date]) AS [StartDate]
													FROM [AppleHealth].[Steps]
													WHERE [Steps].[Steps] = [Steps_Aggregates].[LowestSteps]
													GROUP BY [Steps].[Steps]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[Steps]
													ON
														[LastOccurence].[Steps] = [Steps].[Steps]
														AND [LastOccurence].[StartDate] = [Steps].[Date]
										UNION ALL SELECT
											'Highest' AS [Aggregation],
											[Steps].[Date],
											[Steps].[Steps]
											FROM
											(
												SELECT
													[Steps].[Steps],
													MAX([Steps].[Date]) AS [StartDate]
													FROM [AppleHealth].[Steps]
													WHERE [Steps].[Steps] = [Steps_Aggregates].[HighestSteps]
													GROUP BY [Steps].[Steps]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[Steps]
													ON
														[LastOccurence].[Steps] = [Steps].[Steps]
														AND [LastOccurence].[StartDate] = [Steps].[Date]
									) AS [Pivot]
							UNION ALL SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[Steps]
								FROM
								(
									SELECT
										MIN([Steps].[Date]) AS [FirstStartDate],
										MAX([Steps].[Date]) AS [LastStartDate]
										FROM [AppleHealth].[Steps]
										WHERE YEAR([Steps].[Date]) = @Year
								) AS [Steps_Dates]
									CROSS APPLY
									(
										SELECT
											'First' AS [Aggregation],
											[Steps].[Date],
											[Steps].[Steps]
											FROM [AppleHealth].[Steps]
											WHERE [Steps].[Date] = [Steps_Dates].[FirstStartDate]
										UNION ALL SELECT
											'Last' AS [Aggregation],
											[Steps].[Date],
											[Steps].[Steps]
											FROM [AppleHealth].[Steps]
											WHERE [Steps].[Date] = [Steps_Dates].[LastStartDate]
									) AS [Pivot]
						) AS [Aggregate]
							FOR JSON PATH
				)) AS [Aggregates],
				JSON_QUERY((
					SELECT
						[Steps].[Date],
						[Steps].[Steps]
						FROM [AppleHealth].[Steps]
						WHERE YEAR([Steps].[Date]) = @Year
						ORDER BY [Steps].[Date]
						FOR JSON PATH
				)) AS [Values]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	)
END
