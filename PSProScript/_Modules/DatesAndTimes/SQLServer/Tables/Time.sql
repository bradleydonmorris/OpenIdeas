DROP TABLE [DatesAndTimes].[Time]
CREATE TABLE [DatesAndTimes].[Time]
(
	[TimeKey] [int] NOT NULL,
	[HourKey] [int] NOT NULL,
	[HalfHourKey] [int] NOT NULL,
	[QuarterHourKey] [int] NOT NULL,
	[MinuteKey] [int] NOT NULL,
	[TimeOfDayKey] [int] NOT NULL,
	[SubTimeOfDayKey] [int] NOT NULL,

	[Time] [time](0) NOT NULL,
	[Hour] [time](0) NOT NULL,
	[HalfHour] [time](0) NOT NULL,
	[QuarterHour] [time](0) NOT NULL,
	[Minute] [time](0) NOT NULL,
	[TimeOfDay] [time](0) NOT NULL,
	[SubTimeOfDay] [time](0) NOT NULL,

	[HourNumber] [int] NOT NULL,
	[HalfHourNumber] [int] NOT NULL,
	[QuarterHourNumber] [int] NOT NULL,
	[MinuteNumber] [int] NOT NULL,
	[SecondNumber] [int] NOT NULL,
	[TimeOfDayNumber] [int] NOT NULL,
	[SubTimeOfDayNumber] [int] NOT NULL,
	[SecondOfDay] [int] NOT NULL,
	[FractionOfDay] [decimal](32, 25) NOT NULL,

	[HourName] [char](8) NOT NULL,
	[HalfHourName] [char](8) NOT NULL,
	[QuarterHourName] [char](8) NOT NULL,
	[MinuteName] [char](8) NOT NULL,
	[SecondName] [char](8) NOT NULL,
	[TimeOfDayName] [varchar](9) NOT NULL,
	[SubTimeOfDayName] [varchar](15) NOT NULL,

	CONSTRAINT [PK_Time]
		PRIMARY KEY
		CLUSTERED
		(
			[TimeKey] ASC
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
CREATE UNIQUE NONCLUSTERED INDEX [UX_Time_TimeKey]
	ON [DatesAndTimes].[Time]
	(
		[TimeKey] ASC
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
CREATE UNIQUE NONCLUSTERED INDEX [UX_Time_Time]
	ON [DatesAndTimes].[Time]
	(
		[Time] ASC
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
