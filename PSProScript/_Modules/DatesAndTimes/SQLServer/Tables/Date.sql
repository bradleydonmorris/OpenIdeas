CREATE TABLE [DatesAndTimes].[Date]
(
	[DateKey] [int] NOT NULL,
	[YearKey] [int] NOT NULL,
	[SemesterKey] [int] NOT NULL,
	[QuarterKey] [int] NOT NULL,
	[MonthKey] [int] NOT NULL,
	[WeekKey] [int] NOT NULL,

	[Date] [date] NOT NULL,
	[Year] [date] NOT NULL,
	[Semester] [date] NOT NULL,
	[Quarter] [date] NOT NULL,
	[Month] [date] NOT NULL,
	[Week] [date] NOT NULL,

	[YearNumber] [int] NOT NULL,
	[SemesterNumber] [int] NOT NULL,
	[QuarterNumber] [int] NOT NULL,
	[MonthNumber] [int] NOT NULL,
	[WeekNumber] [int] NOT NULL,
	[ISOWeekNumber] [int] NOT NULL,
	[DayOfWeekNumber] [int] NOT NULL,
	[DayOfMonthNumber] [int] NOT NULL,
	[DayOfYearNumber] [int] NOT NULL,

	[YearName] [char](6) NOT NULL,
	[SemesterName] [char](2) NOT NULL,
	[QuarterName] [char](2) NOT NULL,
	[MonthName] [nvarchar](30) NOT NULL,
	[WeekName] [char](4) NOT NULL,
	[ISOWeekName] [char](7) NOT NULL,
	[DayOfWeekName] [varchar](9) NOT NULL,
	[DayOfMonthName] [char](2) NOT NULL,
	[DayOfYearName] [char](3) NOT NULL,
	[QualifiedSemesterName] [char](9) NOT NULL,
	[QualifiedQuarterName] [char](9) NOT NULL,
	[QualifiedMonthName] [char](13) NOT NULL,
	[QualifiedWeekName] [char](11) NOT NULL,
	[QualifiedISOWeekName] [char](14) NOT NULL,

	CONSTRAINT [PK_Date]
		PRIMARY KEY
		CLUSTERED
		(
			[DateKey] ASC
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
	ON [DatesAndTimes]
) ON [DatesAndTimes]
CREATE UNIQUE NONCLUSTERED INDEX [UX_Date_DateKey]
	ON [DatesAndTimes].[Date]
	(
		[DateKey] ASC
	)
	WITH
	(
		PAD_INDEX = OFF,
		STATISTICS_NORECOMPUTE = OFF,
		SORT_IN_TEMPDB = OFF,
		IGNORE_DUP_KEY = OFF,
		DROP_EXISTING = OFF,
		ONLINE = OFF,
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON,
        FILLFACTOR = 100
	) ON [DatesAndTimes]
CREATE UNIQUE NONCLUSTERED INDEX [UX_Date_Date]
	ON [DatesAndTimes].[Date]
	(
		[Date] ASC
	)
	WITH
	(
		PAD_INDEX = OFF,
		STATISTICS_NORECOMPUTE = OFF,
		SORT_IN_TEMPDB = OFF,
		IGNORE_DUP_KEY = OFF,
		DROP_EXISTING = OFF,
		ONLINE = OFF,
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON,
        FILLFACTOR = 100
	) ON [DatesAndTimes]
