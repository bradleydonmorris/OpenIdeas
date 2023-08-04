CREATE OR ALTER PROCEDURE [DatesAndTimes].[LoadTimes]
AS
BEGIN
	DECLARE @TimeMidnight [time](0) = '00:00:00'
	;WITH
		[Hour]
		(
			[HourNumber]
		)
		AS
		(
			SELECT 0 AS [HourNumber]
			UNION ALL
			SELECT ([Hour].[HourNumber] + 1) AS [Hour]
				FROM [Hour]
				WHERE ([Hour].[HourNumber] + 1) <= 23
		),
		[Minute]
		(
			[MinuteNumber]
		)
		AS
		(
			SELECT 0 AS [MinuteNumber]
			UNION ALL
			SELECT ([Minute].[MinuteNumber] + 1) AS [MinuteNumber]
				FROM [Minute]
				WHERE ([Minute].[MinuteNumber] + 1) <= 59
		),
		[Second]
		(
			[SecondNumber]
		)
		AS
		(
			SELECT 0 AS [SecondNumber]
			UNION ALL
			SELECT ([Second].[SecondNumber] + 1) AS [SecondNumber]
				FROM [Second]
				WHERE ([Second].[SecondNumber] + 1) <= 59
		),
		[Time]
		(
			[Time],

			[HourNumber],
			[HalfHourNumber],
			[QuarterHourNumber],
			[MinuteNumber],
			[SecondNumber],
			[TimeOfDayNumber],
			[SubTimeOfDayNumber],
			[SecondOfDay],
			[FractionOfDay]
		)
		AS
		(
			SELECT
				TIMEFROMPARTS([Hour].[HourNumber], [Minute].[MinuteNumber], [Second].[SecondNumber], 0, 0) AS [Time],
				[Hour].[HourNumber],
				CASE
					WHEN [Minute].[MinuteNumber] BETWEEN 0 AND 29
						THEN 0
					WHEN [Minute].[MinuteNumber] BETWEEN 30 AND 59
						THEN 30
				END AS [HalfHourNumber],
				CASE
					WHEN [Minute].[MinuteNumber] BETWEEN 0 AND 14
						THEN 0
					WHEN [Minute].[MinuteNumber] BETWEEN 15 AND 29
						THEN 15
					WHEN [Minute].[MinuteNumber] BETWEEN 30 AND 44
						THEN 30
					WHEN [Minute].[MinuteNumber] BETWEEN 45 AND 59
						THEN 45
				END AS [QuarterHourNumber],
				[Minute].[MinuteNumber],
				[Second].[SecondNumber],
				CASE
					WHEN [Hour].[HourNumber] BETWEEN 0 AND 4
						THEN 0
					WHEN [Hour].[HourNumber] BETWEEN 5 AND 11
						THEN 5
					WHEN [Hour].[HourNumber] BETWEEN 12 AND 17
						THEN 12
					WHEN [Hour].[HourNumber] BETWEEN 18 AND 23
						THEN 18
				END AS [TimeOfDayNumber],
				CASE
					WHEN [Hour].[HourNumber] BETWEEN 0 AND 4
						THEN 0
					WHEN [Hour].[HourNumber] BETWEEN 5 AND 9
						THEN 5
					WHEN [Hour].[HourNumber] BETWEEN 10 AND 11
						THEN 10
					WHEN [Hour].[HourNumber] BETWEEN 12 AND 14
						THEN 12
					WHEN [Hour].[HourNumber] BETWEEN 15 AND 17
						THEN 15
					WHEN [Hour].[HourNumber] BETWEEN 18 AND 19
						THEN 18
					WHEN [Hour].[HourNumber] BETWEEN 20 AND 23
						THEN 20
				END AS [SubTimeOfDayKeyNumber],
				DATEDIFF
				(
					[SECOND],
					@TimeMidnight,
					TIMEFROMPARTS([Hour].[HourNumber], [Minute].[MinuteNumber], [Second].[SecondNumber], 0, 0)
				) AS [SecondOfDay],
				TRY_CAST
				(
					(
						TRY_CAST(DATEDIFF([SECOND], @TimeMidnight, TIMEFROMPARTS([Hour].[HourNumber], [Minute].[MinuteNumber], [Second].[SecondNumber], 0, 0)) AS [float])
						/ TRY_CAST(86400 AS [float])
					) AS [decimal](32, 25)
				) AS [FractionOfDay] -- [decimal](32, 25) NOT NULL,


				FROM [Hour]
					CROSS JOIN [Minute]
					CROSS JOIN [Second]
		),
		[TimeNumerics]
		(
			[Time],
			[Hour],
			[HalfHour],
			[QuarterHour],
			[Minute],
			[TimeOfDay],
			[SubTimeOfDay],

			[HourNumber],
			[HalfHourNumber],
			[QuarterHourNumber],
			[MinuteNumber],
			[SecondNumber],
			[TimeOfDayNumber],
			[SubTimeOfDayNumber],
			[SecondOfDay],
			[FractionOfDay]
		)
		AS
		(
			SELECT
				[Time].[Time],

				TIMEFROMPARTS([Time].[HourNumber], 0, 0, 0, 0) AS [Hour],
				TIMEFROMPARTS([Time].[HourNumber], [Time].[HalfHourNumber], 0, 0, 0) AS [HalfHour],
				TIMEFROMPARTS([Time].[HourNumber], [Time].[QuarterHourNumber], 0, 0, 0) AS [QuarterHour],
				TIMEFROMPARTS([Time].[HourNumber], [Time].[MinuteNumber], 0, 0, 0) AS [Minute],
				TIMEFROMPARTS([Time].[TimeOfDayNumber], 0, 0, 0, 0) AS [TimeOfDay],
				TIMEFROMPARTS([Time].[SubTimeOfDayNumber], 0, 0, 0, 0) AS [SubTimeOfDay],

				[Time].[HourNumber],
				[Time].[HalfHourNumber],
				[Time].[QuarterHourNumber],
				[Time].[MinuteNumber],
				[Time].[SecondNumber],
				[Time].[TimeOfDayNumber],
				[Time].[SubTimeOfDayNumber],
				[Time].[SecondOfDay],
				[Time].[FractionOfDay]

				FROM [Time]

		),
		[TimeLabels]
		(
			[TimeKey],
			[HourKey],
			[HalfHourKey],
			[QuarterHourKey],
			[MinuteKey],
			[TimeOfDayKey],
			[SubTimeOfDayKey],

			[Time],
			[Hour],
			[HalfHour],
			[QuarterHour],
			[Minute],
			[TimeOfDay],
			[SubTimeOfDay],

			[HourNumber],
			[HalfHourNumber],
			[QuarterHourNumber],
			[MinuteNumber],
			[SecondNumber],
			[TimeOfDayNumber],
			[SubTimeOfDayNumber],
			[SecondOfDay],
			[FractionOfDay],

			[HourName],
			[HalfHourName],
			[QuarterHourName],
			[MinuteName],
			[SecondName],
			[TimeOfDayName],
			[SubTimeOfDayName]
		)
		AS
		(
			SELECT
				CONVERT([int], FORMAT([TimeNumerics].[Time], 'hhmmss'), 0) AS [TimeKey],
				CONVERT([int], FORMAT([TimeNumerics].[Hour], 'hhmmss'), 0) AS [HourKey],
				CONVERT([int], FORMAT([TimeNumerics].[HalfHour], 'hhmmss'), 0) AS [HalfHourKey],
				CONVERT([int], FORMAT([TimeNumerics].[QuarterHour], 'hhmmss'), 0) AS [QuarterHourKey],
				CONVERT([int], FORMAT([TimeNumerics].[Minute], 'hhmmss'), 0) AS [MinuteKey],
				CONVERT([int], FORMAT([TimeNumerics].[TimeOfDay], 'hhmmss'), 0) AS [TimeOfDayKey],
				CONVERT([int], FORMAT([TimeNumerics].[SubTimeOfDay], 'hhmmss'), 0) AS [SubTimeOfDayKey],

				[TimeNumerics].[Time],
				[TimeNumerics].[Hour],
				[TimeNumerics].[HalfHour],
				[TimeNumerics].[QuarterHour],
				[TimeNumerics].[Minute],
				[TimeNumerics].[TimeOfDay],
				[TimeNumerics].[SubTimeOfDay],

				[TimeNumerics].[HourNumber],
				[TimeNumerics].[HalfHourNumber],
				[TimeNumerics].[QuarterHourNumber],
				[TimeNumerics].[MinuteNumber],
				[TimeNumerics].[SecondNumber],
				[TimeNumerics].[TimeOfDayNumber],
				[TimeNumerics].[SubTimeOfDayNumber],
				[TimeNumerics].[SecondOfDay],
				[TimeNumerics].[FractionOfDay],

				CONVERT([char](2), FORMAT([TimeNumerics].[Hour], 'hh\:mm\:ss'), 0) AS [HourName],
				CONVERT([char](2), FORMAT([TimeNumerics].[HalfHour], 'hh\:mm\:ss'), 0) AS [HalfHourName],
				CONVERT([char](2), FORMAT([TimeNumerics].[QuarterHour], 'hh\:mm\:ss'), 0) AS [QuarterHourName],
				CONVERT([char](2), FORMAT([TimeNumerics].[Minute], 'hh\:mm\:ss'), 0) AS [MinuteName],
				CONVERT([char](2), FORMAT([TimeNumerics].[Time], 'hh\:mm\:ss'), 0) AS [SecondName],
				CONVERT
				(
					[varchar](9),
					CASE
						WHEN [TimeNumerics].[TimeOfDayNumber] = 0
							THEN 'Night'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 5
							THEN 'Morning'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 12
							THEN 'Afternoon'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 18
							THEN 'Evening'
					END,
					0
				) AS [TimeOfDayName],
				CONVERT
				(
					[varchar](15),
					CASE
						WHEN [TimeNumerics].[TimeOfDayNumber] = 0
							THEN 'Night'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 5
							THEN 'Early Morning'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 10
							THEN 'Late Morning'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 12
							THEN 'Early Afternoon'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 15
							THEN 'Late Afternoon'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 18
							THEN 'Early Evening'
						WHEN [TimeNumerics].[TimeOfDayNumber] = 20
							THEN 'Late Evening'
					END,
					0
				) AS [SubTimeOfDayName]
			FROM [TimeNumerics]
		)
	INSERT INTO [DatesAndTimes].[Time]
	(
		[TimeKey], [HourKey], [HalfHourKey], [QuarterHourKey], [MinuteKey], [TimeOfDayKey], [SubTimeOfDayKey],
		[Time], [Hour], [HalfHour], [QuarterHour], [Minute], [TimeOfDay], [SubTimeOfDay],
		[HourNumber], [HalfHourNumber], [QuarterHourNumber], [MinuteNumber], [SecondNumber], [TimeOfDayNumber], [SubTimeOfDayNumber], [SecondOfDay], [FractionOfDay],
		[HourName], [HalfHourName], [QuarterHourName], [MinuteName], [SecondName], [TimeOfDayName], [SubTimeOfDayName]
	)
		SELECT
			[TimeLabels].[TimeKey], [TimeLabels].[HourKey], [TimeLabels].[HalfHourKey], [TimeLabels].[QuarterHourKey], [TimeLabels].[MinuteKey], [TimeLabels].[TimeOfDayKey], [TimeLabels].[SubTimeOfDayKey],
			[TimeLabels].[Time], [TimeLabels].[Hour], [TimeLabels].[HalfHour], [TimeLabels].[QuarterHour], [TimeLabels].[Minute], [TimeLabels].[TimeOfDay], [TimeLabels].[SubTimeOfDay],
			[TimeLabels].[HourNumber], [TimeLabels].[HalfHourNumber], [TimeLabels].[QuarterHourNumber], [TimeLabels].[MinuteNumber], [TimeLabels].[SecondNumber], [TimeLabels].[TimeOfDayNumber], [TimeLabels].[SubTimeOfDayNumber], [TimeLabels].[SecondOfDay], [TimeLabels].[FractionOfDay],
			[TimeLabels].[HourName], [TimeLabels].[HalfHourName], [TimeLabels].[QuarterHourName], [TimeLabels].[MinuteName], [TimeLabels].[SecondName], [TimeLabels].[TimeOfDayName], [TimeLabels].[SubTimeOfDayName]
			FROM [TimeLabels]
				LEFT OUTER JOIN [DatesAndTimes].[Time]
					ON [TimeLabels].[TimeKey] = [Time].[TimeKey]
			WHERE [Time].[TimeKey] IS NULL
			ORDER BY [TimeLabels].[TimeKey]
			OPTION (MAXRECURSION 32767);
	ALTER INDEX ALL ON [DatesAndTimes].[Time] REBUILD
END
