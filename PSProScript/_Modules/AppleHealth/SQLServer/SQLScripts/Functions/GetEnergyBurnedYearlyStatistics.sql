CREATE OR ALTER FUNCTION [AppleHealth].[GetEnergyBurnedYearlyStatistics]
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
						TRY_CAST([Aggregate].[BasalEnergyBurned] AS [decimal](18, 2)) AS [BasalEnergyBurned],
						TRY_CAST([Aggregate].[ActiveEnergyBurned] AS [decimal](18, 2)) AS [ActiveEnergyBurned]
						FROM
						(
							SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[BasalEnergyBurned],
								[Pivot].[ActiveEnergyBurned]
								FROM
								(
									SELECT
										MIN([EnergyBurned].[ValueBasedKey]) AS [LowestValueBasedKey],
										MAX([EnergyBurned].[ValueBasedKey]) AS [HighestValueBasedKey]
										FROM [AppleHealth].[EnergyBurned]
										WHERE YEAR([EnergyBurned].[Date]) = @Year
								) AS [EnergyBurned_Aggregates]
									CROSS APPLY
									(
										SELECT
											'Lowest' AS [Aggregation],
											[EnergyBurned].[Date],
											[EnergyBurned].[BasalEnergyBurned],
											[EnergyBurned].[ActiveEnergyBurned]
											FROM
											(
												SELECT
													[EnergyBurned].[ValueBasedKey],
													MAX([EnergyBurned].[Date]) AS [Date]
													FROM [AppleHealth].[EnergyBurned]
													WHERE [EnergyBurned].[ValueBasedKey] = [EnergyBurned_Aggregates].[LowestValueBasedKey]
													GROUP BY [EnergyBurned].[ValueBasedKey]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[EnergyBurned]
													ON
														[LastOccurence].[ValueBasedKey] = [EnergyBurned].[ValueBasedKey]
														AND [LastOccurence].[Date] = [EnergyBurned].[Date]
										UNION ALL SELECT
											'Highest' AS [Aggregation],
											[EnergyBurned].[Date],
											[EnergyBurned].[BasalEnergyBurned],
											[EnergyBurned].[ActiveEnergyBurned]
											FROM
											(
												SELECT
													[EnergyBurned].[ValueBasedKey],
													MAX([EnergyBurned].[Date]) AS [Date]
													FROM [AppleHealth].[EnergyBurned]
													WHERE [EnergyBurned].[ValueBasedKey] = [EnergyBurned_Aggregates].[HighestValueBasedKey]
													GROUP BY [EnergyBurned].[ValueBasedKey]
											) AS [LastOccurence]
												INNER JOIN [AppleHealth].[EnergyBurned]
													ON
														[LastOccurence].[ValueBasedKey] = [EnergyBurned].[ValueBasedKey]
														AND [LastOccurence].[Date] = [EnergyBurned].[Date]
									) AS [Pivot]
							UNION ALL SELECT
								[Pivot].[Aggregation],
								[Pivot].[Date],
								[Pivot].[BasalEnergyBurned],
								[Pivot].[ActiveEnergyBurned]
								FROM
								(
									SELECT
										MIN([EnergyBurned].[Date]) AS [FirstDate],
										MAX([EnergyBurned].[Date]) AS [LastDate]
										FROM [AppleHealth].[EnergyBurned]
										WHERE YEAR([EnergyBurned].[Date]) = @Year
								) AS [EnergyBurned_Dates]
									CROSS APPLY
									(
										SELECT
											'First' AS [Aggregation],
											[EnergyBurned].[Date],
											[EnergyBurned].[BasalEnergyBurned],
											[EnergyBurned].[ActiveEnergyBurned]
											FROM [AppleHealth].[EnergyBurned]
											WHERE [EnergyBurned].[Date] = [EnergyBurned_Dates].[FirstDate]
										UNION ALL SELECT
											'Last' AS [Aggregation],
											[EnergyBurned].[Date],
											[EnergyBurned].[BasalEnergyBurned],
											[EnergyBurned].[ActiveEnergyBurned]
											FROM [AppleHealth].[EnergyBurned]
											WHERE [EnergyBurned].[Date] = [EnergyBurned_Dates].[LastDate]
									) AS [Pivot]
						) AS [Aggregate]
							FOR JSON PATH
				)) AS [Aggregates],
				JSON_QUERY((
					SELECT
						FORMAT([EnergyBurned].[Date], N'yyyy-MM-dd') AS [Date],
						TRY_CAST([EnergyBurned].[BasalEnergyBurned] AS [decimal](18, 2)) AS [BasalEnergyBurned],
						TRY_CAST([EnergyBurned].[ActiveEnergyBurned] AS [decimal](18, 2)) AS [ActiveEnergyBurned]
						FROM [AppleHealth].[EnergyBurned]
						WHERE YEAR([EnergyBurned].[Date]) = @Year
						ORDER BY [EnergyBurned].[Date]
						FOR JSON PATH
				)) AS [Values]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		),
		0
	)
END
