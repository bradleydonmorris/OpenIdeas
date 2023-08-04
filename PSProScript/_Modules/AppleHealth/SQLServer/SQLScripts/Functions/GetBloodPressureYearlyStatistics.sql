CREATE OR ALTER FUNCTION [AppleHealth].[GetBloodPressureYearlyStatistics]
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
						TRY_CAST([Aggregate].[Systolic] AS [int]) AS [Systolic],
						TRY_CAST([Aggregate].[Diastolic] AS [int]) AS [Diastolic],
						TRY_CAST([Aggregate].[MeanArterialPressure] AS [int]) AS [MeanArterialPressure]
						FROM
						(
							SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[Systolic],
								[Pivot].[Diastolic],
								[Pivot].[MeanArterialPressure]
								FROM
								(
									SELECT
										MIN([BloodPressure].[ValuesBasedKey]) AS [LowestValuesBasedKey],
										MAX([BloodPressure].[ValuesBasedKey]) AS [HighestValuesBasedKey]
										FROM [AppleHealth].[BloodPressure]
										WHERE YEAR([BloodPressure].[StartDate]) = @Year
								) AS [BloodPressure_Aggregates]
									CROSS APPLY
									(
										SELECT
											'Lowest' AS [Aggregation],
											[BloodPressure].[StartDate] AS [Date],
											[BloodPressure].[Systolic],
											[BloodPressure].[Diastolic],
											[BloodPressure].[MeanArterialPressure]
											FROM
											(
												SELECT
													[BloodPressure].[ValuesBasedKey],
													MAX([BloodPressure].[StartDate]) AS [StartDate]
													FROM [AppleHealth].[BloodPressure]
													WHERE [BloodPressure].[ValuesBasedKey] = [BloodPressure_Aggregates].[LowestValuesBasedKey]
													GROUP BY [BloodPressure].[ValuesBasedKey]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[BloodPressure]
													ON
														[LastOccurence].[ValuesBasedKey] = [BloodPressure].[ValuesBasedKey]
														AND [LastOccurence].[StartDate] = [BloodPressure].[StartDate]
										UNION ALL SELECT
											'Highest' AS [Aggregation],
											[BloodPressure].[StartDate] AS [Date],
											[BloodPressure].[Systolic],
											[BloodPressure].[Diastolic],
											[BloodPressure].[MeanArterialPressure]
											FROM
											(
												SELECT
													[BloodPressure].[ValuesBasedKey],
													MAX([BloodPressure].[StartDate]) AS [StartDate]
													FROM [AppleHealth].[BloodPressure]
													WHERE [BloodPressure].[ValuesBasedKey] = [BloodPressure_Aggregates].[HighestValuesBasedKey]
													GROUP BY [BloodPressure].[ValuesBasedKey]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[BloodPressure]
													ON
														[LastOccurence].[ValuesBasedKey] = [BloodPressure].[ValuesBasedKey]
														AND [LastOccurence].[StartDate] = [BloodPressure].[StartDate]
									) AS [Pivot]
							UNION ALL SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[Systolic],
								[Pivot].[Diastolic],
								[Pivot].[MeanArterialPressure]
								FROM
								(
									SELECT
										MIN([BloodPressure].[StartDate]) AS [FirstStartDate],
										MAX([BloodPressure].[StartDate]) AS [LastStartDate]
										FROM [AppleHealth].[BloodPressure]
										WHERE YEAR([BloodPressure].[StartDate]) = @Year
								) AS [BloodPressure_Dates]
									CROSS APPLY
									(
										SELECT
											'First' AS [Aggregation],
											[BloodPressure].[StartDate] AS [Date],
											[BloodPressure].[Systolic],
											[BloodPressure].[Diastolic],
											[BloodPressure].[MeanArterialPressure]
											FROM [AppleHealth].[BloodPressure]
											WHERE [BloodPressure].[StartDate] = [BloodPressure_Dates].[FirstStartDate]
										UNION ALL SELECT
											'Last' AS [Aggregation],
											[BloodPressure].[StartDate] AS [Date],
											[BloodPressure].[Systolic],
											[BloodPressure].[Diastolic],
											[BloodPressure].[MeanArterialPressure]
											FROM [AppleHealth].[BloodPressure]
											WHERE [BloodPressure].[StartDate] = [BloodPressure_Dates].[LastStartDate]
									) AS [Pivot]
						) AS [Aggregate]
						FOR JSON PATH
				)) AS [Aggregates],
				JSON_QUERY((
					SELECT
						FORMAT([BloodPressureFirstOfTheDay].[StartDate], N'yyyy-MM-dd') AS [Date],
						TRY_CAST([BloodPressureFirstOfTheDay].[Systolic] AS [int]) AS [Systolic],
						TRY_CAST([BloodPressureFirstOfTheDay].[Diastolic] AS [int]) AS [Diastolic],
						TRY_CAST([BloodPressureFirstOfTheDay].[MeanArterialPressure] AS [decimal](18, 2)) AS [MeanArterialPressure]
						FROM [AppleHealth].[BloodPressureFirstOfTheDay]
						WHERE YEAR([BloodPressureFirstOfTheDay].[StartDate]) = @Year
						ORDER BY [BloodPressureFirstOfTheDay].[StartDate]
						FOR JSON PATH
				)) AS [Values]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	)
END
