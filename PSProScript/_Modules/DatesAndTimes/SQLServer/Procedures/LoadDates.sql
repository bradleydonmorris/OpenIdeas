CREATE OR ALTER PROCEDURE [DatesAndTimes].[LoadDates]
(
	@BeginYear [smallint] = 2021,
	@EndYear [smallint] = 2021
)
AS
BEGIN
	SET DATEFIRST 7
	DECLARE @BeginDate [date]
	DECLARE @EndDate [date]
	SET @BeginDate = DATEFROMPARTS(@BeginYear, 1, 1)
	SET @EndDate = DATEFROMPARTS(@EndYear, 12, 31)
	;WITH
		[Date]
		(
			[Date]
		)
		AS
		(
			SELECT
				[Date].[Date]
				FROM
				(
					SELECT @BeginDate AS [Date]
				) AS [Date]

			UNION ALL
			SELECT
				[Date].[Date]
				FROM
				(
					SELECT DATEADD([DAY], 1, [Date].[Date]) AS [Date]
						FROM [Date]
				) AS [Date]
				WHERE [Date].[Date] <= @EndDate
		),
		[DateNumerics]
		(
			[Date],
			[Year],
			[Semester],
			[Quarter],
			[Month],
			[Week],

			[YearNumber],
			[SemesterNumber],
			[QuarterNumber],
			[MonthNumber],
			[WeekNumber],
			[ISOWeekNumber],
			[DayOfWeekNumber],
			[DayOfMonthNumber],
			[DayOfYearNumber]
		)
		AS
		(
			SELECT
				[Date].[Date],
				CONVERT([date], DATEADD([YEAR], DATEDIFF([YEAR], 0, [Date].[Date]), 0), 0) AS [Year],
				DATEFROMPARTS
				(
					DATEPART([YEAR], [Date].[Date]),
					CASE
						WHEN MONTH([Date].[Date]) BETWEEN 1 AND 6
							THEN 1
						WHEN MONTH([Date].[Date]) BETWEEN 7 AND 12
							THEN 7
					END
					,
					1
				) AS [Semester],
				DATEFROMPARTS
				(
					DATEPART([YEAR], [Date].[Date]),
					CASE
						WHEN MONTH([Date].[Date]) BETWEEN 1 AND 3
							THEN 1
						WHEN MONTH([Date].[Date]) BETWEEN 4 AND 6
							THEN 4
						WHEN MONTH([Date].[Date]) BETWEEN 7 AND 9
							THEN 7
						WHEN MONTH([Date].[Date]) BETWEEN 10 AND 12
							THEN 10
					END
					,
					1
				) AS [Quarter],
				CONVERT([date], DATEADD([MONTH], DATEDIFF([MONTH], 0, [Date].[Date]), 0), 0) AS [Month],
				DATEADD([DAY], (-1) * ((6 + DATEPART([WEEKDAY], [Date].[Date]) + @@DATEFIRST) % 7), [Date].[Date]) AS [Week],

				CONVERT([int], DATEPART([YEAR], [Date].[Date]), 0) AS [YearNumber],
				CASE
					WHEN MONTH([Date].[Date]) BETWEEN 1 AND 6
						THEN 1
					WHEN MONTH([Date].[Date]) BETWEEN 7 AND 12
						THEN 7
				END AS  [SemesterNumber],
				CONVERT([int], DATEPART([QUARTER], [Date].[Date]), 0) AS [QuarterNumber],
				CONVERT([int], DATEPART([MONTH], [Date].[Date]), 0) AS [MonthNumber],
				CONVERT([int], DATEPART([WEEK], [Date].[Date]), 0) AS [WeekNumber],
				CONVERT([int], DATEPART([ISO_WEEK], [Date].[Date]), 0) AS [ISOWeekNumber],
				CONVERT([int], DATEPART([WEEKDAY], [Date].[Date]), 0) AS [DayOfWeekNumber],
				CONVERT([int], DATEPART([DAY], [Date].[Date]), 0) AS [DayOfMonthNumber],
				CONVERT([int], DATEPART([DAYOFYEAR], [Date].[Date]), 0) AS [DayOfYearNumber]
				FROM [Date]
		),
		[DateLabels]
		(
			[DateKey],
			[YearKey],
			[SemesterKey],
			[QuarterKey],
			[MonthKey],
			[WeekKey],

			[Date],
			[Year],
			[Semester],
			[Quarter],
			[Month],
			[Week],

			[YearNumber],
			[SemesterNumber],
			[QuarterNumber],
			[MonthNumber],
			[WeekNumber],
			[ISOWeekNumber],
			[DayOfWeekNumber],
			[DayOfMonthNumber],
			[DayOfYearNumber],

			[YearName],
			[SemesterName],
			[QuarterName],
			[MonthName],
			[WeekName],
			[ISOWeekName],
			[DayOfWeekName],
			[DayOfMonthName],
			[DayOfYearName],

			[QualifiedSemesterName],
			[QualifiedQuarterName],
			[QualifiedMonthName],
			[QualifiedWeekName],
			[QualifiedISOWeekName]
		)
		AS
		(
			SELECT
				CONVERT([int], FORMAT([DateNumerics].[Date], 'yyyyMMdd'), 0) AS [DateKey],
				CONVERT([int], FORMAT([DateNumerics].[Year], 'yyyyMMdd'), 0) AS [YearKey],
				CONVERT([int], FORMAT([DateNumerics].[Semester], 'yyyyMMdd'), 0) AS [SemesterKey],
				CONVERT([int], FORMAT([DateNumerics].[Quarter], 'yyyyMMdd'), 0) AS [QuarterKey],
				CONVERT([int], FORMAT([DateNumerics].[Month], 'yyyyMMdd'), 0) AS [MonthKey],
				CONVERT([int], FORMAT([DateNumerics].[Week], 'yyyyMMdd'), 0) AS [WeekKey],

				[DateNumerics].[Date],
				[DateNumerics].[Year],
				[DateNumerics].[Semester],
				[DateNumerics].[Quarter],
				[DateNumerics].[Month],
				[DateNumerics].[Week],

				[DateNumerics].[YearNumber],
				[DateNumerics].[SemesterNumber],
				[DateNumerics].[QuarterNumber],
				[DateNumerics].[MonthNumber],
				[DateNumerics].[WeekNumber],
				[DateNumerics].[ISOWeekNumber],
				[DateNumerics].[DayOfWeekNumber],
				[DateNumerics].[DayOfMonthNumber],
				[DateNumerics].[DayOfYearNumber],

				CONVERT([char](6), CONCAT('CY', FORMAT([DateNumerics].[YearNumber], '0000')), 0) AS [YearName],
				CONVERT([char](2), CONCAT('S', FORMAT([DateNumerics].[SemesterNumber], '0')), 0) AS [SemesterName],
				CONVERT([char](2), CONCAT('Q', FORMAT([DateNumerics].[QuarterNumber], '0')), 0) AS [QuarterName],
				DATENAME([MONTH], [DateNumerics].[Date]) AS [MonthName],
				CONVERT([char](4), FORMAT([DateNumerics].[WeekNumber], 'Wk00'), 0) AS [WeekName],
				CONVERT([char](7), FORMAT([DateNumerics].[ISOWeekNumber], 'ISOWk00'), 0) AS [ISOWeekName],
				CONVERT([varchar](9), FORMAT([DateNumerics].[Date], 'dddd'), 0) AS [DayOfWeekName],
				CONVERT([char](2), FORMAT([DateNumerics].[DayOfMonthNumber], '00'), 0) AS [DayOfMonthName],
				CONVERT([char](3), FORMAT([DateNumerics].[DayOfYearNumber], '000'), 0) AS [DayOfYearName],
				CONVERT([char](9), CONCAT('CY', FORMAT([DateNumerics].[YearNumber], '0000'), '-S', FORMAT([DateNumerics].[SemesterNumber], '0')), 0) AS [QualifiedSemesterName],
				CONVERT([char](9), CONCAT('CY', FORMAT([DateNumerics].[YearNumber], '0000'), '-Q', FORMAT([DateNumerics].[QuarterNumber], '0')), 0) AS [QualifiedQuarterName],
				CONVERT([char](13), FORMAT([DateNumerics].[Date], 'yyyy-MM (MMM)'), 0) AS [QualifiedMonthName],
				CONVERT([char](11), CONCAT('CY', FORMAT([DateNumerics].[YearNumber], '0000'), '-Wk', FORMAT([DateNumerics].[WeekNumber], '00')), 0) AS [QualifiedWeekName],
				CONVERT([char](14), CONCAT('CY', FORMAT([DateNumerics].[YearNumber], '0000'), '-ISOWk', FORMAT([DateNumerics].[ISOWeekNumber], '00')), 0) AS [QualifiedISOWeekName]
				FROM [DateNumerics]
		)
	INSERT INTO [DatesAndTimes].[Date]
	(
		[DateKey], [YearKey], [SemesterKey], [QuarterKey], [MonthKey], [WeekKey],
		[Date], [Year], [Semester], [Quarter], [Month], [Week],
		[YearNumber], [SemesterNumber], [QuarterNumber], [MonthNumber], [WeekNumber], [ISOWeekNumber], [DayOfWeekNumber], [DayOfMonthNumber], [DayOfYearNumber],
		[YearName], [SemesterName], [QuarterName], [MonthName], [WeekName], [ISOWeekName], [DayOfWeekName], [DayOfMonthName],
		[DayOfYearName], [QualifiedSemesterName], [QualifiedQuarterName], [QualifiedMonthName], [QualifiedWeekName], [QualifiedISOWeekName]
	)
		SELECT
			[DateLabels].[DateKey], [DateLabels].[YearKey], [DateLabels].[SemesterKey], [DateLabels].[QuarterKey], [DateLabels].[MonthKey], [DateLabels].[WeekKey],
			[DateLabels].[Date], [DateLabels].[Year], [DateLabels].[Semester], [DateLabels].[Quarter], [DateLabels].[Month], [DateLabels].[Week],
			[DateLabels].[YearNumber], [DateLabels].[SemesterNumber], [DateLabels].[QuarterNumber], [DateLabels].[MonthNumber], [DateLabels].[WeekNumber], [DateLabels].[ISOWeekNumber], [DateLabels].[DayOfWeekNumber], [DateLabels].[DayOfMonthNumber], [DateLabels].[DayOfYearNumber],
			[DateLabels].[YearName], [DateLabels].[SemesterName], [DateLabels].[QuarterName], [DateLabels].[MonthName], [DateLabels].[WeekName], [DateLabels].[ISOWeekName], [DateLabels].[DayOfWeekName], [DateLabels].[DayOfMonthName],
			[DateLabels].[DayOfYearName], [DateLabels].[QualifiedSemesterName], [DateLabels].[QualifiedQuarterName], [DateLabels].[QualifiedMonthName], [DateLabels].[QualifiedWeekName], [DateLabels].[QualifiedISOWeekName]
			FROM [DateLabels]
				LEFT OUTER JOIN [DatesAndTimes].[Date]
					ON [DateLabels].[DateKey] = [Date].[DateKey]
			WHERE [Date].[DateKey] IS NULL
			ORDER BY [DateKey]
			OPTION (MAXRECURSION 32767);
	ALTER INDEX ALL ON [DatesAndTimes].[Date] REBUILD
END
GO