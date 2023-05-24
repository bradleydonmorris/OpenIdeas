--#region Date Table
CREATE TABLE [StaticDimensions].[Date]
(
	[DateId] [int] IDENTITY(1,1) NOT NULL,
	[DateKey] [date] NOT NULL,
	[YearKey] [date] NOT NULL,
	[SemesterKey] [date] NOT NULL,
	[QuarterKey] [date] NOT NULL,
	[MonthKey] [date] NOT NULL,
	[WeekKey] [date] NOT NULL,
	[YearName] [char](6) NOT NULL,
	[SemesterName] [char](2) NOT NULL,
	[QuarterName] [char](2) NOT NULL,
	[MonthName] [nvarchar](30) NOT NULL,
	[YearNumber] [int] NOT NULL,
	[SemesterNumber] [int] NOT NULL,
	[QuarterNumber] [int] NOT NULL,
	[MonthNumber] [int] NOT NULL,
	[WeekOfYearNumber] [int] NOT NULL,
	[ISOWeekOfYearNumber] [int] NOT NULL,
	[DayOfMonthNumber] [int] NOT NULL,
	[DayOfYearNumber] [int] NOT NULL,
	[WeekDayName] [nvarchar](30) NOT NULL,
	[QualifiedSemesterName] [nvarchar](33) NOT NULL,
	[QualifiedQuarterName] [nvarchar](62) NOT NULL,
	[QualifiedMonthName] [nvarchar](20) NOT NULL,
	CONSTRAINT [PK_Date]
		PRIMARY KEY CLUSTERED ([DateId] ASC)
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
)
CREATE UNIQUE NONCLUSTERED INDEX [UX_Date_DateKey]
	ON [StaticDimensions].[Date]([DateKey] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_YearKey]
	ON [StaticDimensions].[Date]([YearKey] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_SemesterKey]
	ON [StaticDimensions].[Date]([SemesterKey] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_QuarterKey]
	ON [StaticDimensions].[Date]([QuarterKey] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_MonthKey]
	ON [StaticDimensions].[Date]([MonthKey] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_WeekKey]
	ON [StaticDimensions].[Date]([WeekKey] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_YearNumber]
	ON [StaticDimensions].[Date]([YearNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_SemesterNumber]
	ON [StaticDimensions].[Date]([SemesterNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_QuarterNumber]
	ON [StaticDimensions].[Date]([QuarterNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_MonthNumber]
	ON [StaticDimensions].[Date]([MonthNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_WeekOfYearNumber]
	ON [StaticDimensions].[Date]([WeekOfYearNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_ISOWeekOfYearNumber]
	ON [StaticDimensions].[Date]([ISOWeekOfYearNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_DayOfMonthNumber]
	ON [StaticDimensions].[Date]([DayOfMonthNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Date_DayOfYearNumber]
	ON [StaticDimensions].[Date]([DayOfYearNumber] ASC)
	INCLUDE ([DateKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
--#endregion Date Table

--#region Time Table
CREATE TABLE [StaticDimensions].[Time]
(
	[TimeId] [int] NOT NULL IDENTITY (1, 1),
	[TimeKey] [time](0) NOT NULL,
	[HourKey] [time](0) NOT NULL,
	[TimeOfDayKey] [time](0) NOT NULL,
	[SubTimeOfDayKey] [time](0) NOT NULL,
	[HalfHourKey] [time](0) NOT NULL,
	[QuarterHourKey] [time](0) NOT NULL,
	[HourName] [varchar](2) NOT NULL,
	[MinuteName] [varchar](2) NOT NULL,
	[SecondName] [varchar](2) NOT NULL,
	[TimeOfDayName] [varchar](9) NOT NULL,
	[SubTimeOfDayName] [varchar](15) NOT NULL,
	[HalfHourName] [varchar](11) NOT NULL,
	[QuarterHourName] [varchar](14) NOT NULL,
	[HourNumber] [int] NOT NULL,
	[HalHourNumber] [int] NOT NULL,
	[QuarterHourNumber] [int] NOT NULL,
	[MinuteNumber] [int] NOT NULL,
	[SecondNumber] [int] NOT NULL,
	CONSTRAINT [PK_Time]
		PRIMARY KEY
		CLUSTERED
		(
			[TimeId] ASC
		)
		WITH
		(
			PAD_INDEX = OFF,
			STATISTICS_NORECOMPUTE = OFF,
			IGNORE_DUP_KEY = OFF,
			ALLOW_ROW_LOCKS = ON,
			ALLOW_PAGE_LOCKS = ON,
			FILLFACTOR = 100
		)
)
CREATE UNIQUE NONCLUSTERED INDEX [UX_Time_TimeKey]
	ON [StaticDimensions].[Time]([TimeKey] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_HourKey]
	ON [StaticDimensions].[Time]([HourKey] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_TimeOfDayKey]
	ON [StaticDimensions].[Time]([TimeOfDayKey] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_SubTimeOfDayKey]
	ON [StaticDimensions].[Time]([SubTimeOfDayKey] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_HalfHourKey]
	ON [StaticDimensions].[Time]([HalfHourKey] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_QuarterHourKey]
	ON [StaticDimensions].[Time]([QuarterHourKey] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_HourNumber]
	ON [StaticDimensions].[Time]([HourNumber] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_HalHourNumber]
	ON [StaticDimensions].[Time]([HalHourNumber] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_QuarterHourNumber]
	ON [StaticDimensions].[Time]([QuarterHourNumber] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_MinuteNumber]
	ON [StaticDimensions].[Time]([MinuteNumber] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
CREATE NONCLUSTERED INDEX [IX_Time_SecondNumber]
	ON [StaticDimensions].[Time]([SecondNumber] ASC)
	INCLUDE ([TimeKey])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
--#endregion Time Table

--#region LoadDate
GO
CREATE OR ALTER PROCEDURE [StaticDimensions].[LoadDate]
(
	@Year [smallint]
)
AS
BEGIN
	SET DATEFIRST 7
	DECLARE @BeginDate [date]
	DECLARE @EndDate [date]
	SET @BeginDate = DATEFROMPARTS(@Year, 1, 1)
	SET @EndDate = DATEADD([day], (-1), DATEADD([year], 1, @BeginDate))
	;WITH
		[Date]
		(
			[DateKey]
		)
		AS
		(
			SELECT @BeginDate AS [DateKey]
			UNION ALL
			SELECT DATEADD([DAY], 1, [Date].[DateKey]) AS [DateKey]
				FROM [Date]
				WHERE DATEADD([DAY], 1, [Date].[DateKey]) <= @EndDate
		),
		[DateExtended]
		(
			[DateKey],
			[YearKey],
			[SemesterKey],
			[QuarterKey],
			[MonthKey],
			[WeekKey],
			[YearName],
			[SemesterName],
			[QuarterName],
			[MonthName],
			[YearNumber],
			[SemesterNumber],
			[QuarterNumber],
			[MonthNumber],
			[WeekOfYearNumber],
			[ISOWeekOfYearNumber],
			[DayOfMonthNumber],
			[DayOfYearNumber],
			[WeekDayName],
			[QualifiedSemesterName],
			[QualifiedQuarterName],
			[QualifiedMonthName]
		)
		AS
		(
			SELECT
				[Date].[DateKey],
				CONVERT([date], DATEADD([YEAR], DATEDIFF([YEAR], 0, [Date].[DateKey]), 0), 0) AS [YearKey],
				DATEFROMPARTS
				(
					DATEPART([YEAR], [Date].[DateKey]),
					CASE
						WHEN
						(
							DATEPART([QUARTER], [Date].[DateKey]) = 1
							OR DATEPART([QUARTER], [Date].[DateKey]) = 2
						)
							THEN 1
						WHEN
						(
							DATEPART([QUARTER], [Date].[DateKey]) = 3
							OR DATEPART([QUARTER], [Date].[DateKey]) = 4
						)
							THEN 7
					END
					,
					1
				) AS [SemesterKey],
				DATEFROMPARTS
				(
					DATEPART([YEAR], [Date].[DateKey]),
					CASE
						WHEN DATEPART([QUARTER], [Date].[DateKey]) = 1
							THEN 1
						WHEN DATEPART([QUARTER], [Date].[DateKey]) = 2
							THEN 4
						WHEN DATEPART([QUARTER], [Date].[DateKey]) = 3
							THEN 7
						WHEN DATEPART([QUARTER], [Date].[DateKey]) = 4
							THEN 10
					END
					,
					1
				) AS [QuarterKey],
				CONVERT([date], DATEADD([MONTH], DATEDIFF([MONTH], 0, [Date].[DateKey]), 0), 0) AS [MonthKey],
				DATEADD([DAY], (-1) * ((6 + DATEPART([WEEKDAY], [Date].[DateKey]) + @@DATEFIRST) % 7), [Date].[DateKey]) AS [WeekKey],
				CONVERT
				(
					[char](6),
					(
						'CY'
						+ DATENAME([YEAR], [Date].[DateKey])
					),
					0
				) AS [YearName],
				CONVERT
				(
					[char](2),
					(
						'S'
						+
						CASE
							WHEN
							(
								DATEPART([QUARTER], [Date].[DateKey]) = 1
								OR DATEPART([QUARTER], [Date].[DateKey]) = 2
							)
								THEN '1'
							WHEN
							(
								DATEPART([QUARTER], [Date].[DateKey]) = 3
								OR DATEPART([QUARTER], [Date].[DateKey]) = 4
							)
								THEN '2'
						END
					),
					0
				) AS [SemesterName],
				CONVERT
				(
					[char](2),
					(
						'Q'
						+ DATENAME([QUARTER], [Date].[DateKey])
					),
					0
				) AS [QuarterName],
				DATENAME([MONTH], [Date].[DateKey]) AS [MonthName],
				DATEPART([YEAR], [Date].[DateKey]) AS [YearNumber],
				CASE
					WHEN
					(
						DATEPART([QUARTER], [Date].[DateKey]) = 1
						OR DATEPART([QUARTER], [Date].[DateKey]) = 2
					)
						THEN 1
					WHEN
					(
						DATEPART([QUARTER], [Date].[DateKey]) = 3
						OR DATEPART([QUARTER], [Date].[DateKey]) = 4
					)
						THEN 2
				END AS [SemesterNumber],
				DATEPART([QUARTER], [Date].[DateKey]) AS [QuarterNumber],
				DATEPART([MONTH], [Date].[DateKey]) AS [MonthNumber],
				DATEPART([WEEK], [Date].[DateKey]) AS [WeekOfYearNumber],
				DATEPART([ISO_WEEK], [Date].[DateKey]) AS [ISOWeekOfYearNumber],
				DATEPART([DAY], [Date].[DateKey]) AS [DayOfMonthNumber],
				DATEPART([DAYOFYEAR], [Date].[DateKey]) AS [DayOfYearNumber],
				DATENAME([WEEKDAY], [Date].[DateKey]) AS [WeekDayName],
				(
					DATENAME([YEAR], [Date].[DateKey])
					+ '-S'
					+
					CASE
						WHEN
						(
							DATEPART([QUARTER], [Date].[DateKey]) = 1
							OR DATEPART([QUARTER], [Date].[DateKey]) = 2
						)
							THEN '1'
						WHEN
						(
							DATEPART([QUARTER], [Date].[DateKey]) = 3
							OR DATEPART([QUARTER], [Date].[DateKey]) = 4
						)
							THEN '2'
					END
				) AS [QualifiedSemesterName],
				(
					DATENAME([YEAR], [Date].[DateKey])
					+ '-Q'
					+ DATENAME([QUARTER], [Date].[DateKey])
				) AS [QualifiedQuarterName],
				FORMAT([Date].[DateKey], 'yyyy-MM (MMMM)') AS [QualifiedMonthName]
				FROM [Date]
		)
		INSERT
			INTO [StaticDimensions].[Date]
			(
				[DateKey],
				[YearKey],
				[SemesterKey],
				[QuarterKey],
				[MonthKey],
				[WeekKey],
				[YearName],
				[SemesterName],
				[QuarterName],
				[MonthName],
				[YearNumber],
				[SemesterNumber],
				[QuarterNumber],
				[MonthNumber],
				[WeekOfYearNumber],
				[ISOWeekOfYearNumber],
				[DayOfMonthNumber],
				[DayOfYearNumber],
				[WeekDayName],
				[QualifiedSemesterName],
				[QualifiedQuarterName],
				[QualifiedMonthName]
			)
			SELECT
				[DateExtended].[DateKey],
				[DateExtended].[YearKey],
				[DateExtended].[SemesterKey],
				[DateExtended].[QuarterKey],
				[DateExtended].[MonthKey],
				[DateExtended].[WeekKey],
				[DateExtended].[YearName],
				[DateExtended].[SemesterName],
				[DateExtended].[QuarterName],
				[DateExtended].[MonthName],
				[DateExtended].[YearNumber],
				[DateExtended].[SemesterNumber],
				[DateExtended].[QuarterNumber],
				[DateExtended].[MonthNumber],
				[DateExtended].[WeekOfYearNumber],
				[DateExtended].[ISOWeekOfYearNumber],
				[DateExtended].[DayOfMonthNumber],
				[DateExtended].[DayOfYearNumber],
				[DateExtended].[WeekDayName],
				[DateExtended].[QualifiedSemesterName],
				[DateExtended].[QualifiedQuarterName],
				[DateExtended].[QualifiedMonthName]
				FROM [DateExtended]
					LEFT OUTER JOIN [StaticDimensions].[Date]
						ON [DateExtended].[DateKey] = [Date].[DateKey]
				WHERE [Date].[DateId] IS NULL
				ORDER BY [DateKey]
				OPTION (MAXRECURSION 366);
	ALTER INDEX ALL ON [StaticDimensions].[Date] REBUILD
END
GO
--#endregion LoadDate

--#region LoadYearRange
GO
CREATE OR ALTER PROCEDURE [StaticDimensions].[LoadYearRange]
(
	@BeginYear [int],
	@EndYear [int]
)
AS
BEGIN
	DECLARE @Year [int]
	DECLARE _Year CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
		WITH
			[Year]([Number])
			AS
			(
				SELECT @BeginYear AS [Number]
				UNION ALL SELECT
					([Year].[Number] + 1) AS [Number]
					FROM [Year]
					WHERE ([Year].[Number] + 1) <= @EndYear
			)
			SELECT [Year].[Number] AS [Year]
				FROM [Year]
				OPTION (MAXRECURSION 32767)
	OPEN _Year
	FETCH NEXT FROM _Year INTO @Year
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [StaticDimensions].[LoadDate] @Year = @Year
			FETCH NEXT FROM _Year INTO @Year
		END
	CLOSE _Year
	DEALLOCATE _Year
END
GO
--#endregion LoadYearRange

--#region LoadTime
GO
CREATE OR ALTER PROCEDURE [StaticDimensions].[LoadTime]
AS
BEGIN
	;WITH
		[Hour]
		(
			[Hour]
		)
		AS
		(
			SELECT 0 AS [Hour]
			UNION ALL
			SELECT ([Hour].[Hour] + 1) AS [Hour]
				FROM [Hour]
				WHERE ([Hour].[Hour] + 1) <= 23
		),
		[HourExtended]
		(
			[HourKey],
			[Hour],
			[TimeOfDayKey],
			[SubTimeOfDayKey],
			[TimeOfDayName],
			[SubTimeOfDayName]
		)
		AS
		(
			SELECT
				TIMEFROMPARTS([Hour].[Hour], 0, 0, 0, 0) AS [HourKey],
				[Hour].[Hour],
				CASE
					WHEN [Hour].[Hour]
						BETWEEN 0
						AND 4
							THEN TIMEFROMPARTS(0, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 5
						AND 11
							THEN TIMEFROMPARTS(5, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 12
						AND 17
							THEN TIMEFROMPARTS(12, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 18
						AND 23
							THEN TIMEFROMPARTS(17, 0, 0, 0, 0)
				END AS [TimeOfDayKey],
				CASE
					WHEN [Hour].[Hour]
						BETWEEN 0
						AND 4
							THEN TIMEFROMPARTS(0, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 5
						AND 9
							THEN TIMEFROMPARTS(5, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 10
						AND 11
							THEN TIMEFROMPARTS(10, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 12
						AND 14
							THEN TIMEFROMPARTS(12, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 15
						AND 17
							THEN TIMEFROMPARTS(15, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 18
						AND 19
							THEN TIMEFROMPARTS(18, 0, 0, 0, 0)
					WHEN [Hour].[Hour]
						BETWEEN 20
						AND 23
							THEN TIMEFROMPARTS(20, 0, 0, 0, 0)
				END AS [SubTimeOfDayKey],
				CASE
					WHEN [Hour].[Hour]
						BETWEEN 0
						AND 4
							THEN 'Night'
					WHEN [Hour].[Hour]
						BETWEEN 5
						AND 11
							THEN 'Morning'
					WHEN [Hour].[Hour]
						BETWEEN 12
						AND 17
							THEN 'Afternoon'
					WHEN [Hour].[Hour]
						BETWEEN 18
						AND 23
							THEN 'Evening'
				END AS [TimeOfDayName],
				CASE
					WHEN [Hour].[Hour]
						BETWEEN 0
						AND 4
							THEN 'Night'
					WHEN [Hour].[Hour]
						BETWEEN 5
						AND 9
							THEN 'Early Morning'
					WHEN [Hour].[Hour]
						BETWEEN 10
						AND 11
							THEN 'Late Morning'
					WHEN [Hour].[Hour]
						BETWEEN 12
						AND 14
							THEN 'Early Afternoon'
					WHEN [Hour].[Hour]
						BETWEEN 15
						AND 17
							THEN 'Late Afternoon'
					WHEN [Hour].[Hour]
						BETWEEN 18
						AND 19
							THEN 'Early Evening'
					WHEN [Hour].[Hour]
						BETWEEN 20
						AND 23
							THEN 'Late Evening'
				END AS [SubTimeOfDayName]
				FROM [Hour]
				--WHERE ([Hour].[Hour] + 1) <= 23
		),
		[Minute]
		(
			[Minute]
		)
		AS
		(
			SELECT 0 AS [Minute]
			UNION ALL
			SELECT ([Minute].[Minute] + 1) AS [Minute]
				FROM [Minute]
				WHERE ([Minute].[Minute] + 1) <= 59
		),
		[Second]
		(
			[Second]
		)
		AS
		(
			SELECT 0 AS [Second]
			UNION ALL
			SELECT ([Second].[Second] + 1) AS [Second]
				FROM [Second]
				WHERE ([Second].[Second] + 1) <= 59
		),
		[Time]
		(
			[TimeKey],
			[HourKey],
			[TimeOfDayKey],
			[SubTimeOfDayKey],
			[HalfHourKey],
			[QuarterHourKey],
			[HourName],
			[MinuteName],
			[SecondName],
			[TimeOfDayName],
			[SubTimeOfDayName],
			[HalfHourName],
			[QuarterHourName],
			[HourNumber],
			[HalHourNumber],
			[QuarterHourNumber],
			[MinuteNumber],
			[SecondNumber]
		)
		AS
		(
			SELECT
				TIMEFROMPARTS([HourExtended].[Hour], [Minute].[Minute], [Second].[Second], 0, 0) AS [TimeKey],
				[HourExtended].[HourKey],
				[HourExtended].[TimeOfDayKey],
				[HourExtended].[SubTimeOfDayKey],
				CASE
					WHEN [Minute].[Minute]
						BETWEEN 0
						AND 29
						THEN TIMEFROMPARTS([HourExtended].[Hour], 0, 0, 0, 0)
					WHEN [Minute].[Minute]
						BETWEEN 30
						AND 59
						THEN TIMEFROMPARTS([HourExtended].[Hour], 30, 0, 0, 0)
				END AS [HalfHourKey],
				CASE
					WHEN [Minute].[Minute]
						BETWEEN 0
						AND 14
						THEN TIMEFROMPARTS([HourExtended].[Hour], 0, 0, 0, 0)
					WHEN [Minute].[Minute]
						BETWEEN 15
						AND 29
						THEN TIMEFROMPARTS([HourExtended].[Hour], 15, 0, 0, 0)
					WHEN [Minute].[Minute]
						BETWEEN 30
						AND 44
						THEN TIMEFROMPARTS([HourExtended].[Hour], 30, 0, 0, 0)
					WHEN [Minute].[Minute]
						BETWEEN 45
						AND 59
						THEN TIMEFROMPARTS([HourExtended].[Hour], 45, 0, 0, 0)
				END AS [QuarterHourKey],
				RIGHT('00' + CONVERT([varchar](2), [HourExtended].[Hour], 0), 2) AS [HourName],
				RIGHT('00' + CONVERT([varchar](2), [Minute].[Minute], 0), 2) AS [MinuteName],
				RIGHT('00' + CONVERT([varchar](2), [Second].[Second], 0), 2) AS [SecondName],
				[HourExtended].[TimeOfDayName],
				[HourExtended].[SubTimeOfDayName],
				CASE
					WHEN [Minute].[Minute]
						BETWEEN 0
						AND 29
						THEN 'First Half'
					WHEN [Minute].[Minute]
						BETWEEN 30
						AND 59
						THEN 'Second Half'
				END AS [HalfHourName],
				CASE
					WHEN [Minute].[Minute]
						BETWEEN 0
						AND 14
						THEN 'First Quarter'
					WHEN [Minute].[Minute]
						BETWEEN 15
						AND 29
						THEN 'Second Quarter'
					WHEN [Minute].[Minute]
						BETWEEN 30
						AND 44
						THEN 'Third Quarter'
					WHEN [Minute].[Minute]
						BETWEEN 45
						AND 59
						THEN 'Fourth Quarter'
				END AS [QuarterHourName],
				[HourExtended].[Hour] AS [HourNumber],
				CASE
					WHEN [Minute].[Minute]
						BETWEEN 0
						AND 29
						THEN 1
					WHEN [Minute].[Minute]
						BETWEEN 30
						AND 59
						THEN 2
				END AS [HalHourNumber],
				CASE
					WHEN [Minute].[Minute]
						BETWEEN 0
						AND 14
						THEN 1
					WHEN [Minute].[Minute]
						BETWEEN 15
						AND 29
						THEN 2
					WHEN [Minute].[Minute]
						BETWEEN 30
						AND 44
						THEN 3
					WHEN [Minute].[Minute]
						BETWEEN 45
						AND 59
						THEN 4
				END AS [QuarterHourNumber],
				[Minute].[Minute] AS [MinuteNumber],
				[Second].[Second] AS [SecondNumber]

				FROM [HourExtended]
					CROSS JOIN [Minute]
					CROSS JOIN [Second]
		)
		INSERT
			INTO [StaticDimensions].[Time]
			(
				[TimeKey],
				[HourKey],
				[TimeOfDayKey],
				[SubTimeOfDayKey],
				[HalfHourKey],
				[QuarterHourKey],
				[HourName],
				[MinuteName],
				[SecondName],
				[TimeOfDayName],
				[SubTimeOfDayName],
				[HalfHourName],
				[QuarterHourName],
				[HourNumber],
				[HalHourNumber],
				[QuarterHourNumber],
				[MinuteNumber],
				[SecondNumber]
			)
			SELECT
				[Time_Import].[TimeKey],
				[Time_Import].[HourKey],
				[Time_Import].[TimeOfDayKey],
				[Time_Import].[SubTimeOfDayKey],
				[Time_Import].[HalfHourKey],
				[Time_Import].[QuarterHourKey],
				[Time_Import].[HourName],
				[Time_Import].[MinuteName],
				[Time_Import].[SecondName],
				[Time_Import].[TimeOfDayName],
				[Time_Import].[SubTimeOfDayName],
				[Time_Import].[HalfHourName],
				[Time_Import].[QuarterHourName],
				[Time_Import].[HourNumber],
				[Time_Import].[HalHourNumber],
				[Time_Import].[QuarterHourNumber],
				[Time_Import].[MinuteNumber],
				[Time_Import].[SecondNumber]
				FROM [Time] AS [Time_Import]
					LEFT OUTER JOIN [StaticDimensions].[Time]
						ON [Time_Import].[TimeKey] = [Time].[TimeKey]
				WHERE [Time].[TimeId] IS NULL
				ORDER BY [Time_Import].[TimeKey]
	ALTER INDEX ALL ON [StaticDimensions].[Time] REBUILD
END
GO
--#endregion LoadTime
