CREATE OR ALTER PROCEDURE [AppleHealth].[GetYearlyStatistics]
(
	@Year [int]
)
AS
BEGIN
	SELECT
		CONVERT(
			[nvarchar](MAX),
			(
				SELECT
					JSON_QUERY(([AppleHealth].[GetWeightYearlyStatistics](@Year))) AS [Weight],
					JSON_QUERY(([AppleHealth].[GetBloodPressureYearlyStatistics](@Year))) AS [BloodPressure],
					JSON_QUERY(([AppleHealth].[GetRestingHeartRateYearlyStatistics](@Year))) AS [RestingHeartRate],
					JSON_QUERY(([AppleHealth].[GetEnergyBurnedYearlyStatistics](@Year))) AS [EnergyBurned]
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			),
			0
		) AS [JSON]
END
