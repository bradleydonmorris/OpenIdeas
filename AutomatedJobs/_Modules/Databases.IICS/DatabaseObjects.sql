--IICS

--#region Schema
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
		WHERE [schemas].[name] = N'IICS'
)
	EXECUTE(N'CREATE SCHEMA [IICS]')
GO
--#endregion Schema

--#region AssetType
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[AssetType]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'AssetType'
)
	CREATE TABLE [IICS].[AssetType]
	(
		[AssetTypeId] [tinyint] IDENTITY(1, 1) NOT NULL,
		[Code] [varchar](50) NOT NULL,
		[Name] [varchar](50) NOT NULL,
		CONSTRAINT [PK_AssetType]
			PRIMARY KEY CLUSTERED ([AssetTypeId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_AssetType_Key1'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[AssetType]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_AssetType_Key1]
		ON [IICS].[AssetType]([Code])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_AssetType_Key2'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[AssetType]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_AssetType_Key2]
		ON [IICS].[AssetType]([Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
INSERT INTO [IICS].[AssetType]([Code], [Name])
	SELECT DISTINCT
		[Source].[Code],
		[Source].[Name]
		FROM
		(
			VALUES
				('Folder', 'Folder'),
				('Project', 'Project'),
				('Connection', 'Connection'),
				('Schedule', 'Schedule'),
				('DTEMPLATE', 'Mapping'),
				('MTT', 'Mapping task'),
				('DSS', 'Synchronization task'),
				('DMASK', 'Masking task'),
				('DRS', 'Replication task'),
				('DMAPPLET', 'Mapplet created in Data Integration'),
				('MAPPLET', 'PowerCenter mapplet'),
				('BSERVICE', 'Business service definition'),
				('HSCHEMA', 'Hierarchical schema'),
				('PCS', 'PowerCenter task'),
				('FWCONFIG', 'Fixed width configuration'),
				('CUSTOMSOURCE', 'Saved query'),
				('MI_TASK', 'Mass ingestion task'),
				('WORKFLOW', 'Linear taskflow'),
				('VISIOTEMPLATE', 'Visio Template'),
				('TASKFLOW', 'Taskflow')
		) AS [Source]([Code], [Name])
			LEFT OUTER JOIN [IICS].[AssetType] AS [Target]
				ON [Source].[Code] = [Target].[Code]
		WHERE [Target].[AssetTypeId] IS NULL
GO
--#endregion AssetType

--#region ScheduleInterval
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ScheduleInterval]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ScheduleInterval'
)
	CREATE TABLE [IICS].[ScheduleInterval]
	(
		[ScheduleIntervalId] [tinyint] IDENTITY(1, 1) NOT NULL,
		[Name] [varchar](50) NOT NULL,
		[Description] [varchar](100) NOT NULL,
		CONSTRAINT [PK_ScheduleInterval]
			PRIMARY KEY CLUSTERED ([ScheduleIntervalId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ScheduleInterval_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ScheduleInterval]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ScheduleInterval_Key]
		ON [IICS].[ScheduleInterval]([Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
INSERT INTO [IICS].[ScheduleInterval]([Name], [Description])
	SELECT DISTINCT
		[Source].[Name],
		[Source].[Description]
		FROM
		(
			VALUES
				('None', 'The schedule does not repeat'),
				('Minutely', 'Tasks run on an interval based on the specified number of minutes, days, and time range'),
				('Hourly', 'Tasks run on an hourly interval based on the start time of the schedule'),
				('Daily', 'Tasks run on a daily interval based on the start time of the schedule'),
				('Weekly', 'Tasks run on a weekly interval based on the start time of the schedule'),
				('Biweekly', 'Tasks run every two weeks based on the start time of the schedule'),
				('Monthly', 'Tasks run on a monthly interval based on the start time of the schedule')
		) AS [Source]([Name], [Description])
			LEFT OUTER JOIN [IICS].[ScheduleInterval] AS [Target]
				ON [Source].[Name] = [Target].[Name]
		WHERE [Target].[ScheduleIntervalId] IS NULL
GO
--#endregion ScheduleInterval

--#region ActivityLogState
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogState]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ActivityLogState'
)
	CREATE TABLE [IICS].[ActivityLogState]
	(
		[ActivityLogStateId] [tinyint] IDENTITY(1, 1) NOT NULL,
		[Code] [tinyint] NOT NULL,
		[Name] [varchar](50) NOT NULL,
		CONSTRAINT [PK_ActivityLogState]
			PRIMARY KEY CLUSTERED ([ActivityLogStateId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ActivityLogState_Key1'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogState]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ActivityLogState_Key1]
		ON [IICS].[ActivityLogState]([Code])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ActivityLogState_Key2'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogState]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ActivityLogState_Key2]
		ON [IICS].[ActivityLogState]([Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
INSERT INTO [IICS].[ActivityLogState]([Code], [Name])
	SELECT DISTINCT
		[Source].[Code],
		[Source].[Name]
		FROM
		(
			VALUES
				(1, 'Completed Successfully'),
				(2, 'Completed with Errors'),
				(3, 'Failed to Comnplete')
		) AS [Source]([Code], [Name])
			LEFT OUTER JOIN [IICS].[ActivityLogState] AS [Target]
				ON [Source].[Code] = [Target].[Code]
		WHERE [Target].[ActivityLogStateId] IS NULL
GO
--#endregion ActivityLogState

--#region RunContextType
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[RunContextType]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'RunContextType'
)
	CREATE TABLE [IICS].[RunContextType]
	(
		[RunContextTypeId] [tinyint] IDENTITY(1, 1) NOT NULL,
		[Code] [varchar](50) NOT NULL,
		[Name] [varchar](50) NOT NULL,
		CONSTRAINT [PK_RunContextType]
			PRIMARY KEY CLUSTERED ([RunContextTypeId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_RunContextType_Key1'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[RunContextType]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_RunContextType_Key1]
		ON [IICS].[RunContextType]([Code])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_RunContextType_Key2'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[RunContextType]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_RunContextType_Key2]
		ON [IICS].[RunContextType]([Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
INSERT INTO [IICS].[RunContextType]([Code], [Name])
	SELECT DISTINCT
		[Source].[Code],
		[Source].[Name]
		FROM
		(
			VALUES
				('OUTBOUND MESSAGE', 'Initiated Through Outbound Message'),
				('REST-API', 'Initiated Through Rest API'),
				('SCHEDULER', 'Initiated Through Task Scheduler'),
				('UI', 'Initiated Through User Interface')
		) AS [Source]([Code], [Name])
			LEFT OUTER JOIN [IICS].[RunContextType] AS [Target]
				ON [Source].[Code] = [Target].[Code]
		WHERE [Target].[RunContextTypeId] IS NULL
GO
--#endregion RunContextType

--#region Operation
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[Operation]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'Operation'
)
	CREATE TABLE [IICS].[Operation]
	(
		[OperationId] [tinyint] IDENTITY(1, 1) NOT NULL,
		[Name] [varchar](50) NOT NULL,
		CONSTRAINT [PK_Operation]
			PRIMARY KEY CLUSTERED ([OperationId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_Operation_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Operation]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_Operation_Key]
		ON [IICS].[Operation]([Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion Operation

--#region CustomSourceType
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[CustomSourceType]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'CustomSourceType'
)
	CREATE TABLE [IICS].[CustomSourceType]
	(
		[CustomSourceTypeId] [tinyint] IDENTITY(1, 1) NOT NULL,
		[Name] [varchar](50) NOT NULL,
		CONSTRAINT [PK_CustomSourceType]
			PRIMARY KEY CLUSTERED ([CustomSourceTypeId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_CustomSourceType_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[CustomSourceType]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_CustomSourceType_Key]
		ON [IICS].[CustomSourceType]([Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion CustomSourceType

--#region Asset
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[Asset]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'Asset'
)
	CREATE TABLE [IICS].[Asset]
	(
		[AssetId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetTypeId] [tinyint] NOT NULL,
		[FederatedId] [varchar](50) NOT NULL,
		[AssetGuid] [varchar](50) NULL,
		[Name] [nvarchar](400) NOT NULL,
		[Type] [varchar](20) NOT NULL,
		[Path] [nvarchar](400) NOT NULL,
		[IsRemoved] [bit] NOT NULL
			CONSTRAINT [DF_Asset_IsRemoved]
			DEFAULT (0),
		CONSTRAINT [PK_Asset]
			PRIMARY KEY CLUSTERED ([AssetId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_Asset_AssetType]
			FOREIGN KEY ([AssetTypeId])
			REFERENCES [IICS].[AssetType]([AssetTypeId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_Asset_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Asset]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [UX_Asset_Key]
		ON [IICS].[Asset]([FederatedId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_Asset_AssetTypeId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Asset]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_Asset_AssetTypeId]
		ON [IICS].[Asset]([AssetTypeId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion Asset

--#region Schedule
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[Schedule]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'Schedule'
)
	CREATE TABLE [IICS].[Schedule]
	(
		[ScheduleId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[ScheduleIntervalId] [tinyint] NOT NULL,
		[Id] [varchar](50) NOT NULL,
		[Name] [nvarchar](400) NULL,
		[Description] [nvarchar](400) NULL,
		[Status] [varchar](20) NULL,
		[RangeStartTime] [datetime2](7) NULL,
		[RangeEndTime] [datetime2](7) NULL,
		[StartTime] [datetime2](7) NULL,
		[EndTime] [datetime2](7) NULL,
		[Frequency] [int] NULL,
		[Monday] [bit] NULL,
		[Tuesday] [bit] NULL,
		[Wednesday] [bit] NULL,
		[Thursday] [bit] NULL,
		[Friday] [bit] NULL,
		[Saturday] [bit] NULL,
		[Sunday] [bit] NULL,
		[Weekday] [bit] NULL,
		[DayOfMonth] [int] NULL,
		[WeekOfMonth] [varchar](20) NULL,
		[DayOfWeek] [varchar](20) NULL,
		[CreateTime] [datetime2](7) NULL,
		[UpdateTime] [datetime2](7) NULL,
		[CreatedBy] [varchar](320) NULL,
		[UpdatedBy] [varchar](320) NULL,
		[ScheduleText] [varchar](100) NULL,
		[IsRemoved] [bit] NOT NULL
			CONSTRAINT [DF_Schedule_IsRemoved]
			DEFAULT (0),
		CONSTRAINT [PK_Schedule]
			PRIMARY KEY CLUSTERED ([ScheduleId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_Schedule_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_Schedule_ScheduleInterval]
			FOREIGN KEY ([ScheduleIntervalId])
			REFERENCES [IICS].[ScheduleInterval]([ScheduleIntervalId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_Schedule_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Schedule]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_Schedule_Key]
		ON [IICS].[Schedule]([AssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_Schedule_ScheduleIntervalId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Schedule]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_Schedule_ScheduleIntervalId]
		ON [IICS].[Schedule]([ScheduleIntervalId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion Schedule

--#region ActivityLog
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ActivityLog]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ActivityLog'
)
	CREATE TABLE [IICS].[ActivityLog]
	(
		[ActivityLogId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ActivityLogStateId] [tinyint] NOT NULL,
		[RunContextTypeId] [tinyint] NOT NULL,
		[RunId] [bigint] NOT NULL,
		[FederatedId] [varchar](50) NOT NULL,
		[StartTime] [datetime2](7) NOT NULL,
		[EndTime] [datetime2](7) NULL,
		[FailedSourceRows] [bigint] NULL,
		[SuccessSourceRows] [bigint] NULL,
		[FailedTargetRows] [bigint] NULL,
		[SuccessTargetRows] [bigint] NULL,
		[TotalSuccessRows] [bigint] NULL,
		[TotalFailedRows] [bigint] NULL,
		[StopOnError] [bit] NULL,
		[HasStopOnErrorRecord] [bit] NULL,
		[ErrorMessage] [nvarchar](MAX) NULL,
		[Entries] [nvarchar](MAX) NULL,
		CONSTRAINT [PK_ActivityLog]
			PRIMARY KEY CLUSTERED ([ActivityLogId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ActivityLog_ActivityLogState]
			FOREIGN KEY ([ActivityLogStateId])
			REFERENCES [IICS].[ActivityLogState]([ActivityLogStateId]),
		CONSTRAINT [FK_ActivityLog_RunContextType]
			FOREIGN KEY ([RunContextTypeId])
			REFERENCES [IICS].[RunContextType]([RunContextTypeId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_ActivityLog_ActivityLogStateId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLog]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_ActivityLog_ActivityLogStateId]
		ON [IICS].[ActivityLog]([ActivityLogStateId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_ActivityLog_RunContextTypeId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLog]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_ActivityLog_RunContextTypeId]
		ON [IICS].[ActivityLog]([RunContextTypeId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ActivityLog

--#region ActivityLogAsset
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogAsset]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ActivityLogAsset'
)
	CREATE TABLE [IICS].[ActivityLogAsset]
	(
		[ActivityLogAssetId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ActivityLogId] [bigint] NOT NULL,
		[AssetId] [bigint] NOT NULL,
		CONSTRAINT [PK_ActivityLogAsset]
			PRIMARY KEY CLUSTERED ([ActivityLogAssetId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ActivityLogAsset_ActivityLog]
			FOREIGN KEY ([ActivityLogId])
			REFERENCES [IICS].[ActivityLog]([ActivityLogId]),
		CONSTRAINT [FK_ActivityLogAsset_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId])
	)
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_ActivityLogAsset_ActivityLogId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogAsset]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_ActivityLogAsset_ActivityLogId]
		ON [IICS].[ActivityLogAsset]([ActivityLogId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ActivityLogAsset_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogAsset]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ActivityLogAsset_Key]
		ON [IICS].[ActivityLogAsset]([ActivityLogId], [AssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ActivityLogAsset

--#region ActivityLogSchedule
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogSchedule]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ActivityLogSchedule'
)
	CREATE TABLE [IICS].[ActivityLogSchedule]
	(
		[ActivityLogScheduleId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ActivityLogId] [bigint] NOT NULL,
		[ScheduleId] [bigint] NOT NULL,
		CONSTRAINT [PK_ActivityLogSchedule]
			PRIMARY KEY CLUSTERED ([ActivityLogScheduleId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ActivityLogSchedule_ActivityLog]
			FOREIGN KEY ([ActivityLogId])
			REFERENCES [IICS].[ActivityLog]([ActivityLogId]),
		CONSTRAINT [FK_ActivityLogSchedule_Schedule]
			FOREIGN KEY ([ScheduleId])
			REFERENCES [IICS].[Schedule]([ScheduleId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ActivityLogSchedule_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ActivityLogSchedule]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ActivityLogSchedule_Key]
		ON [IICS].[ActivityLogSchedule]([ActivityLogId], [ScheduleId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ActivityLogSchedule

--#region Connection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[Connection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'Connection'
)
	CREATE TABLE [IICS].[Connection]
	(
		[ConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[Type] [nvarchar](50) NULL,
		[Name] [nvarchar](400) NULL,
		[InstanceDisplayName] [nvarchar](400) NULL,
		[CreateTime] [datetime2](7) NULL,
		[UpdateTime] [datetime2](7) NULL,
		[CreatedBy] [varchar](320) NULL,
		[UpdatedBy] [varchar](320) NULL,
		CONSTRAINT [PK_Connection]
			PRIMARY KEY CLUSTERED ([ConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_Connection_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_Connection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Connection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_Connection_Key]
		ON [IICS].[Connection]([AssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion Connection

--#region ConnectionProperty
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ConnectionProperty]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ConnectionProperty'
)
	CREATE TABLE [IICS].[ConnectionProperty]
	(
		[ConnectionPropertyId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Value] [nvarchar](400) NOT NULL,
		CONSTRAINT [PK_ConnectionProperty]
			PRIMARY KEY CLUSTERED ([ConnectionPropertyId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ConnectionProperty_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ConnectionProperty_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ConnectionProperty]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ConnectionProperty_Key]
		ON [IICS].[ConnectionProperty]([ConnectionId], [Name])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ConnectionProperty

--#region CSVFileConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[CSVFileConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'CSVFileConnection'
)
	CREATE TABLE [IICS].[CSVFileConnection]
	(
		[CSVFileConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Database] [nvarchar](400) NULL,
		[DateFormat] [nvarchar](400) NULL,
		CONSTRAINT [PK_CSVFileConnection]
			PRIMARY KEY CLUSTERED ([CSVFileConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_CSVFileConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_CSVFileConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[CSVFileConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_CSVFileConnection_Key]
		ON [IICS].[CSVFileConnection]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion CSVFileConnection

--#region ODBCConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ODBCConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ODBCConnection'
)
	CREATE TABLE [IICS].[ODBCConnection]
	(
		[ODBCConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Database] [nvarchar](400) NULL,
		[UserName] [nvarchar](400) NULL,
		CONSTRAINT [PK_ODBCFileConnection]
			PRIMARY KEY CLUSTERED ([ODBCConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ODBCConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ODBCConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ODBCConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ODBCConnection_Key]
		ON [IICS].[ODBCConnection]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ODBCConnection

--#region SalesforceConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[SalesforceConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'SalesforceConnection'
)
	CREATE TABLE [IICS].[SalesforceConnection]
	(
		[SalesforceConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[ServiceUrl] [nvarchar](400) NULL,
		[UserName] [varchar](320) NULL,
		CONSTRAINT [PK_SalesforceConnection]
			PRIMARY KEY CLUSTERED ([SalesforceConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_SalesforceConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_SalesforceConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[SalesforceConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_SalesforceConnection_Key]
		ON [IICS].[SalesforceConnection]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion SalesforceConnection

--#region SQLServerConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[SQLServerConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'SQLServerConnection'
)
	CREATE TABLE [IICS].[SQLServerConnection]
	(
		[SQLServerConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Host] [nvarchar](400) NULL,
		[Port] [int] NULL,
		[Database] [nvarchar](400) NULL,
		[AuthenticationType] [nvarchar](400) NULL,
		[Schema] [nvarchar](400) NULL,
		[UserName] [nvarchar](400) NULL,
		CONSTRAINT [PK_SQLServerConnection]
			PRIMARY KEY CLUSTERED ([SQLServerConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_SQLServerConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_SQLServerConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[SQLServerConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_SQLServerConnection_Key]
		ON [IICS].[SQLServerConnection]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion SQLServerConnection

--#region ToolkitCCIConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ToolkitCCIConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ToolkitCCIConnection'
)
	CREATE TABLE [IICS].[ToolkitCCIConnection]
	(
		[ToolkitCCIConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[InstanceName] [nvarchar](400) NULL,
		CONSTRAINT [PK_ToolkitCCIConnection]
			PRIMARY KEY CLUSTERED ([ToolkitCCIConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ToolkitCCIConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ToolkitCCIConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ToolkitCCIConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ToolkitCCIConnection_Key]
		ON [IICS].[ToolkitCCIConnection]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ToolkitCCIConnection

--#region ToolkitConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[ToolkitConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'ToolkitConnection'
)
	CREATE TABLE [IICS].[ToolkitConnection]
	(
		[ToolkitConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[InstanceName] [nvarchar](400) NULL,
		CONSTRAINT [PK_ToolkitConnection]
			PRIMARY KEY CLUSTERED ([ToolkitConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_ToolkitConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_ToolkitConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[ToolkitConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_ToolkitConnection_Key]
		ON [IICS].[ToolkitConnection]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion ToolkitConnection

--#region AssetConnection
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[AssetConnection]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'AssetConnection'
)
	CREATE TABLE [IICS].[AssetConnection]
	(
		[AssetConnectionId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Use] [varchar](20) NOT NULL,
		CONSTRAINT [PK_AssetConnection]
			PRIMARY KEY CLUSTERED ([AssetConnectionId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_AssetConnection_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_AssetConnection_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_AssetConnection_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[AssetConnection]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_AssetConnection_Key]
		ON [IICS].[AssetConnection]([AssetId], [ConnectionId], [Use])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion AssetConnection

--#region AssetSchedule
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[AssetSchedule]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'AssetSchedule'
)
	CREATE TABLE [IICS].[AssetSchedule]
	(
		[AssetScheduleId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[ScheduleId] [bigint] NOT NULL,
		CONSTRAINT [PK_AssetSchedule]
			PRIMARY KEY CLUSTERED ([AssetScheduleId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_AssetSchedule_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_AssetSchedule_Schedule]
			FOREIGN KEY ([ScheduleId])
			REFERENCES [IICS].[Schedule]([ScheduleId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_AssetSchedule_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[AssetSchedule]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_AssetSchedule_Key]
		ON [IICS].[AssetSchedule]([AssetId], [ScheduleId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion AssetSchedule

--#region WorkflowTask
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[WorkflowTask]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'WorkflowTask'
)
	CREATE TABLE [IICS].[WorkflowTask]
	(
		[WorkflowTaskId] [bigint] IDENTITY(1, 1) NOT NULL,
		[WorkflowAssetId] [bigint] NOT NULL,
		[TaskAssetId] [bigint] NOT NULL,
		[Sequence] [int] NOT NULL,
		CONSTRAINT [PK_WorkflowTask]
			PRIMARY KEY CLUSTERED ([WorkflowTaskId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_WorkflowTask_WorkflowAsset_Workflow]
			FOREIGN KEY ([WorkflowAssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_WorkflowTask_WorkflowAsset_Task]
			FOREIGN KEY ([TaskAssetId])
			REFERENCES [IICS].[Asset]([AssetId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_WorkflowTask_WorkflowAssetId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[WorkflowTask]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_WorkflowTask_WorkflowAssetId]
		ON [IICS].[WorkflowTask]([WorkflowAssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_WorkflowTask_TaskAssetId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[WorkflowTask]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_WorkflowTask_TaskAssetId]
		ON [IICS].[WorkflowTask]([TaskAssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion WorkflowTask

--#region Synchronization
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[Synchronization]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'Synchronization'
)
	CREATE TABLE [IICS].[Synchronization]
	(
		[SynchronizationId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[TargetConnectionId] [bigint] NOT NULL,
		[OperationId] [tinyint] NOT NULL,
		[PreProcessingCmd] [nvarchar](MAX) NULL,
		[PostProcessingCmd] [nvarchar](MAX) NULL,
		[TargetObject] [nvarchar](400) NULL,
		[TruncateTarget] [bit] NULL,
		CONSTRAINT [PK_Synchronization]
			PRIMARY KEY CLUSTERED ([SynchronizationId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_Synchronization_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_Synchronization_Connection_Target]
			FOREIGN KEY ([TargetConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId]),
		CONSTRAINT [FK_Synchronization_Operation]
			FOREIGN KEY ([OperationId])
			REFERENCES [IICS].[Operation]([OperationId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_Synchronization_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Synchronization]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_Synchronization_Key]
		ON [IICS].[Synchronization]([AssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion Synchronization

--#region SynchronizationSource
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[SynchronizationSource]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'SynchronizationSource'
)
	CREATE TABLE [IICS].[SynchronizationSource]
	(
		[SynchronizationSourceId] [bigint] IDENTITY(1, 1) NOT NULL,
		[SynchronizationId] [bigint] NOT NULL,
		[SourceConnectionId] [bigint] NOT NULL,
		[Name] [nvarchar](400) NULL,
		[Label] [nvarchar](400) NULL,
		CONSTRAINT [PK_SynchronizationSource]
			PRIMARY KEY CLUSTERED ([SynchronizationSourceId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_SynchronizationSource_Synchronization]
			FOREIGN KEY ([SynchronizationId])
			REFERENCES [IICS].[Synchronization]([SynchronizationId]),
		CONSTRAINT [FK_Synchronization_Connection_Source]
			FOREIGN KEY ([SourceConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_SynchronizationSource_SynchronizationId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[SynchronizationSource]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_SynchronizationSource_SynchronizationId]
		ON [IICS].[SynchronizationSource]([SynchronizationId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_SynchronizationSource_SourceConnectionId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[SynchronizationSource]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_SynchronizationSource_SourceConnectionId]
		ON [IICS].[SynchronizationSource]([SourceConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion SynchronizationSource

--#region SynchronizationFilter
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[SynchronizationFilter]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'SynchronizationFilter'
)
	CREATE TABLE [IICS].[SynchronizationFilter]
	(
		[SynchronizationFilterId] [bigint] IDENTITY(1, 1) NOT NULL,
		[SynchronizationId] [bigint] NOT NULL,
		[ObjectName] [nvarchar](400) NULL,
		[ObjectLabel] [nvarchar](400) NULL,
		[Field] [nvarchar](400) NULL,
		[FieldLabel] [nvarchar](400) NULL,
		[Type] [nvarchar](400) NULL,
		[Operator] [nvarchar](400) NULL,
		[Value] [nvarchar](400) NULL,
		CONSTRAINT [PK_SynchronizationFilter]
			PRIMARY KEY CLUSTERED ([SynchronizationFilterId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_SynchronizationFilter_Synchronization]
			FOREIGN KEY ([SynchronizationId])
			REFERENCES [IICS].[Synchronization]([SynchronizationId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_SynchronizationFilter_SynchronizationId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[SynchronizationFilter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_SynchronizationFilter_SynchronizationId]
		ON [IICS].[SynchronizationFilter]([SynchronizationId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion SynchronizationFilter

--#region Mapping
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[Mapping]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'Mapping'
)
	CREATE TABLE [IICS].[Mapping]
	(
		[MappingId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		CONSTRAINT [PK_Mapping]
			PRIMARY KEY CLUSTERED ([MappingId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_Mapping_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_Mapping_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[Mapping]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_Mapping_Key]
		ON [IICS].[Mapping]([AssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion Mapping

--#region MappingTask
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[MappingTask]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'MappingTask'
)
	CREATE TABLE [IICS].[MappingTask]
	(
		[MappingTaskId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[MappingId] [bigint] NOT NULL,
		CONSTRAINT [PK_MappingTask]
			PRIMARY KEY CLUSTERED ([MappingTaskId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_MappingTask_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_MappingTask_Mapping]
			FOREIGN KEY ([MappingId])
			REFERENCES [IICS].[Mapping]([MappingId]),
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_MappingTask_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTask]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [UX_MappingTask_Key]
		ON [IICS].[MappingTask]([AssetId], [MappingId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion MappingTask

--#region MappingTaskExtendedSourceParameter
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskExtendedSourceParameter]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'MappingTaskExtendedSourceParameter'
)
	CREATE TABLE [IICS].[MappingTaskExtendedSourceParameter]
	(
		[MappingTaskExtendedSourceParameterId] [bigint] IDENTITY(1, 1) NOT NULL,
		[MappingTaskId] [bigint] NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Name] [varchar](100) NULL,
		[Label] [varchar](100) NULL,
		[ObjectName] [nvarchar](400) NULL,
		[ObjectLabel] [nvarchar](400) NULL
		CONSTRAINT [PK_MappingTaskExtendedSourceParameter]
			PRIMARY KEY CLUSTERED ([MappingTaskExtendedSourceParameterId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_MappingTaskExtendedSourceParameter_MappingTask]
			FOREIGN KEY ([MappingTaskId])
			REFERENCES [IICS].[MappingTask]([MappingTaskId]),
		CONSTRAINT [FK_MappingTaskExtendedSourceParameter_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskExtendedSourceParameter_MappingTaskId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskExtendedSourceParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskExtendedSourceParameter_MappingTaskId]
		ON [IICS].[MappingTaskExtendedSourceParameter]([MappingTaskId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskExtendedSourceParameter_ConnectionId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskExtendedSourceParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskExtendedSourceParameter_ConnectionId]
		ON [IICS].[MappingTaskExtendedSourceParameter]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion MappingTaskExtendedSourceParameter

--#region MappingTaskSourceParameter
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskSourceParameter]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'MappingTaskSourceParameter'
)
	CREATE TABLE [IICS].[MappingTaskSourceParameter]
	(
		[MappingTaskSourceParameterId] [bigint] IDENTITY(1, 1) NOT NULL,
		[MappingTaskId] [bigint] NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Name] [varchar](100) NULL,
		[Label] [varchar](100) NULL,
		[CustomQuery] [nvarchar](MAX) NULL
		CONSTRAINT [PK_MappingTaskSourceParameter]
			PRIMARY KEY CLUSTERED ([MappingTaskSourceParameterId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_MappingTaskSourceParameter_MappingTask]
			FOREIGN KEY ([MappingTaskId])
			REFERENCES [IICS].[MappingTask]([MappingTaskId]),
		CONSTRAINT [FK_MappingTaskSourceParameter_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskSourceParameter_MappingTaskId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskSourceParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskSourceParameter_MappingTaskId]
		ON [IICS].[MappingTaskSourceParameter]([MappingTaskId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskSourceParameter_ConnectionId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskSourceParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskSourceParameter_ConnectionId]
		ON [IICS].[MappingTaskSourceParameter]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion MappingTaskSourceParameter

--#region MappingTaskStringParameter
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskStringParameter]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'MappingTaskStringParameter'
)
	CREATE TABLE [IICS].[MappingTaskStringParameter]
	(
		[MappingTaskStringParameterId] [bigint] IDENTITY(1, 1) NOT NULL,
		[MappingTaskId] [bigint] NOT NULL,
		[Name] [varchar](100) NULL,
		[Text] [varchar](100) NULL,
		[Label] [varchar](100) NULL,
		[Description] [varchar](MAX) NULL
		CONSTRAINT [PK_MappingTaskStringParameter]
			PRIMARY KEY CLUSTERED ([MappingTaskStringParameterId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_MappingTaskStringParameter_MappingTask]
			FOREIGN KEY ([MappingTaskId])
			REFERENCES [IICS].[MappingTask]([MappingTaskId]),
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskStringParameter_MappingTaskId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskStringParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskStringParameter_MappingTaskId]
		ON [IICS].[MappingTaskStringParameter]([MappingTaskId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion MappingTaskStringParameter

--#region MappingTaskTargetParameter
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskTargetParameter]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'MappingTaskTargetParameter'
)
	CREATE TABLE [IICS].[MappingTaskTargetParameter]
	(
		[MappingTaskTargetParameterId] [bigint] IDENTITY(1, 1) NOT NULL,
		[MappingTaskId] [bigint] NOT NULL,
		[ConnectionId] [bigint] NOT NULL,
		[Name] [varchar](100) NULL,
		[Label] [varchar](100) NULL,
		[ObjectName] [nvarchar](400) NULL,
		[ObjectLabel] [nvarchar](400) NULL,
		[TruncateTarget] [bit] NULL
		CONSTRAINT [PK_MappingTaskTargetParameter]
			PRIMARY KEY CLUSTERED ([MappingTaskTargetParameterId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_MappingTaskTargetParameter_MappingTask]
			FOREIGN KEY ([MappingTaskId])
			REFERENCES [IICS].[MappingTask]([MappingTaskId]),
		CONSTRAINT [FK_MappingTaskTargetParameter_Connection]
			FOREIGN KEY ([ConnectionId])
			REFERENCES [IICS].[Connection]([ConnectionId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskTargetParameter_MappingTaskId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskTargetParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskTargetParameter_MappingTaskId]
		ON [IICS].[MappingTaskTargetParameter]([MappingTaskId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTaskTargetParameter_ConnectionId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTaskTargetParameter]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTaskTargetParameter_ConnectionId]
		ON [IICS].[MappingTaskTargetParameter]([ConnectionId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion MappingTaskTargetParameter

--#region MappingTransformationProperty
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[MappingTransformationProperty]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'MappingTransformationProperty'
)
	CREATE TABLE [IICS].[MappingTransformationProperty]
	(
		[MappingTransformationPropertyId] [bigint] IDENTITY(1, 1) NOT NULL,
		[MappingId] [bigint] NOT NULL,
		[TransformationName] [nvarchar](100) NOT NULL,
		[PropertyName] [nvarchar](100) NOT NULL,
		[Value] [nvarchar](MAX) NULL,
		CONSTRAINT [PK_MappingTransformationProperty]
			PRIMARY KEY CLUSTERED ([MappingTransformationPropertyId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_MappingTransformationProperty_Mapping]
			FOREIGN KEY ([MappingId])
			REFERENCES [IICS].[Mapping]([MappingId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'IX_MappingTransformationProperty_MappingId'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[MappingTransformationProperty]')
			AND [schemas].[name] = N'IICS'
)
	CREATE NONCLUSTERED INDEX [IX_MappingTransformationProperty_MappingId]
		ON [IICS].[MappingTransformationProperty]([MappingId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion MappingTransformationProperty

--#region CustomSource
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[CustomSource]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'CustomSource'
)
	CREATE TABLE [IICS].[CustomSource]
	(
		[CustomSourceId] [bigint] IDENTITY(1, 1) NOT NULL,
		[AssetId] [bigint] NOT NULL,
		[CustomSourceTypeId] [tinyint] NOT NULL,
		[Query] [nvarchar](MAX) NULL
		CONSTRAINT [PK_CustomSource]
			PRIMARY KEY CLUSTERED ([CustomSourceId])
			WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		CONSTRAINT [FK_CustomSource_Asset]
			FOREIGN KEY ([AssetId])
			REFERENCES [IICS].[Asset]([AssetId]),
		CONSTRAINT [FK_CustomSource_CustomSourceType]
			FOREIGN KEY ([CustomSourceTypeId])
			REFERENCES [IICS].[CustomSourceType]([CustomSourceTypeId])
	)
GO
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[indexes]
			INNER JOIN [sys].[tables]
				ON [indexes].[object_id] = [tables].[object_id]
			INNER JOIN [sys].[schemas]
				ON [tables].[schema_id] = [schemas].[schema_id]
		WHERE
			[indexes].[name] = N'UX_CustomSource_Key'
			AND [tables].[object_id] = OBJECT_ID(N'[IICS].[CustomSource]')
			AND [schemas].[name] = N'IICS'
)
	CREATE UNIQUE NONCLUSTERED INDEX [UX_CustomSource_Key]
		ON [IICS].[CustomSource]([AssetId])
		WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--#endregion CustomSource

--#region StagedAsset
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[StagedAsset]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'StagedAsset'
)
	CREATE TABLE [IICS].[StagedAsset]
	(
		[FederatedId] [varchar](50) NOT NULL,
		[AssetGuid] [varchar](50) NULL,
		[Name] [nvarchar](400) NOT NULL,
		[Type] [varchar](20) NOT NULL,
		[Path] [nvarchar](400) NOT NULL
	)
GO
--#endregion StagedAsset

--#region StagedAssetFile
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[StagedAssetFile]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'StagedAssetFile'
)
	CREATE TABLE [IICS].[StagedAssetFile]
	(
		[FederatedId] [varchar](50) NOT NULL,
		[FileName] [nvarchar](400) NOT NULL,
		[FileType] [varchar](10),
		[Content] [varchar](MAX) NOT NULL
	)
GO
--#endregion StagedAssetFile

--#region StagedActivityLog
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[schemas]
			INNER JOIN [sys].[objects]
				ON [schemas].[schema_id] = [objects].[schema_id]
		WHERE
			[objects].[object_id] = OBJECT_ID(N'[IICS].[StagedActivityLog]')
			AND [schemas].[name] = N'IICS'
			AND [objects].[name] = N'StagedActivityLog'
)
	CREATE TABLE [IICS].[StagedActivityLog]
	(
		[RunId] [bigint] NULL,
		[FederatedId] [varchar](50) NULL,
		[ActivityStateCode] [int] NULL,
		[RunContextTypeCode] [varchar](50) NULL,
		[ObjectId] [varchar](50) NULL,
		[ObjectName] [nvarchar](400) NULL,
		[Type] [varchar](50) NULL,
		[ScheduleName] [nvarchar](400) NULL,
		[StartTime] [datetime2](7) NULL,
		[EndTime] [datetime2](7) NULL,
		[FailedSourceRows] [bigint] NULL,
		[SuccessSourceRows] [bigint] NULL,
		[FailedTargetRows] [bigint] NULL,
		[SuccessTargetRows] [bigint] NULL,
		[TotalSuccessRows] [bigint] NULL,
		[TotalFailedRows] [bigint] NULL,
		[StopOnError] [bit] NULL,
		[HasStopOnErrorRecord] [bit] NULL,
		[ErrorMessage] [nvarchar](MAX) NULL,
		[Entries] [nvarchar](MAX) NULL
	)
GO
--#endregion StagedActivityLog

--#region GetScheduleTexturalStatement
GO
CREATE OR ALTER FUNCTION [IICS].[GetScheduleTexturalStatement]
(
	@Interval [varchar](50),
	@Weekday [int],
	@DayOfMonth [int],
	@WeekOfMonth [varchar](50),
	@DayOfWeek [varchar](50),
	@Frequency [int],
	@Monday [bit],
	@Tuesday [bit],
	@Wednesday [bit],
	@Thursday [bit],
	@Friday [bit],
	@Saturday [bit],
	@Sunday [bit],
	@StartTime [datetime2](7),
	@EndTime [datetime2](7),
	@RangeStartTime [datetime2](7),
	@RangeEndTime [datetime2](7)
)
RETURNS [varchar](100)
AS
BEGIN
	DECLARE @ReturnValue [varchar](100)
	DECLARE @DaysText [varchar](100)
	SET @DaysText =
		CASE
			WHEN
			(
				@Monday = 1
				AND @Tuesday = 1
				AND @Wednesday = 1
				AND @Thursday = 1
				AND @Friday = 1
				AND @Saturday = 1
				AND @Sunday = 1
			)
				THEN 'Everyday'
			WHEN
			(
				@Monday = 1
				AND @Tuesday = 1
				AND @Wednesday = 1
				AND @Thursday = 1
				AND @Friday = 1
				AND @Saturday = 0
				AND @Sunday = 0
			)
				THEN 'Weekdays'
			WHEN
			(
				@Monday = 0
				AND @Tuesday = 0
				AND @Wednesday = 0
				AND @Thursday = 0
				AND @Friday = 0
				AND @Saturday = 1
				AND @Sunday = 1
			)
				THEN 'Weekends'
			WHEN
			(
				@Monday = 1
				OR @Tuesday = 1
				OR @Wednesday = 1
				OR @Thursday = 1
				OR @Friday = 1
				OR @Saturday = 1
				OR @Sunday = 1
			)
				THEN CONCAT
				(
					IIF(@Monday = 1, 'Mon, ', ''),
					IIF(@Tuesday = 1, 'Tue, ', ''),
					IIF(@Wednesday = 1, 'Wed, ', ''),
					IIF(@Thursday = 1, 'Thu, ', ''),
					IIF(@Friday = 1, 'Fri, ', ''),
					IIF(@Saturday = 1, 'Sat, ', ''),
					IIF(@Sunday = 1, 'Sun, ', '')
				)
			ELSE ''
		END
	SET @DaysText = LTRIM(RTRIM(@DaysText))
	SET @DaysText =IIF(RIGHT(@DaysText, 1) = ',', LEFT(@DaysText, (LEN(@DaysText) - 1)), @DaysText)
	DECLARE @RangeText [varchar](100)
	SET @RangeText =
		CASE
			WHEN
			(
				@RangeStartTime IS NOT NULL
				AND @RangeEndTime IS NOT NULL
			)
				THEN CONCAT
				(
					'between ',
					FORMAT
					(
						(
							(@RangeStartTime AT TIME ZONE 'UTC')
							AT TIME ZONE 'Central Standard Time'
						),
						'HH:mm'
					),
					' and ' ,
					FORMAT
					(
						(
							(@RangeEndTime AT TIME ZONE 'UTC')
							AT TIME ZONE 'Central Standard Time'
						),
						'HH:mm'
					),
					' Central Time'
				)
			ELSE NULL
		END
	SET @ReturnValue =
		CONCAT
		(
			CASE
				WHEN @Interval = 'None'
					THEN 'Does not repeat'
				WHEN @Interval = 'Daily'
					THEN CONCAT
					(
						CASE
							WHEN @Weekday = 1
								THEN 'Every weekday'
							WHEN @Weekday = 0
								THEN 'Everyday'
						END,
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
				WHEN @Interval = 'Minutely'
					THEN CONCAT
					(
						'On ',
						@DaysText,
						', every ',
						@Frequency,
						' minutes',
						IIF(@RangeText IS NOT NULL, CONCAT(', ', @RangeText), '')
					)
				WHEN @Interval = 'Hourly'
					THEN CONCAT
					(
						'On ',
						@DaysText,
						', every ',
						CASE
							WHEN @Frequency = 1
								THEN 'hour'
							ELSE CONCAT(@Frequency, ' hours')
						END,
						IIF(@RangeText IS NOT NULL, CONCAT(', ', @RangeText), '')
					)
				WHEN @Interval = 'Weekly'
					THEN CONCAT
					(
						'On ',
						@DaysText,
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
				WHEN @Interval = 'Biweekly'
					THEN CONCAT
					(
						'Every 2 weeks, on ',
						@DaysText,
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
				WHEN @Interval = 'Monthly'
					THEN CONCAT
					(
						'On the ',
						IIF(@DayOfMonth > 0,
							CASE
								WHEN @DayOfMonth IN (1, 21, 31)
									THEN CONCAT(@DayOfMonth, 'st')
								WHEN @DayOfMonth IN (2, 22)
									THEN CONCAT(@DayOfMonth, 'nd')
								WHEN @DayOfMonth IN (3, 23)
									THEN CONCAT(@DayOfMonth, 'rd')
								ELSE CONCAT(@DayOfMonth, 'th')
							END,
							LOWER(@WeekOfMonth)
						),
						' ',
						IIF(@DayOfWeek = 'Day', 'day', @DayOfWeek),
						' of the month',
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
			END,
			'.',
			IIF(@EndTime IS NOT NULL,
				CONCAT
				(
					' Runs till ',
					FORMAT
					(
						(
							(@EndTime AT TIME ZONE 'UTC')
							AT TIME ZONE 'Central Standard Time'
						),
						'yyyy-MM-dd HH:mm'
					),
					' Central'
				),
				' Runs indefinately'
			)
		)
	RETURN @ReturnValue
END
GO
--#endregion GetScheduleTexturalStatement

--#region ClearStaged
GO
CREATE OR ALTER PROCEDURE [IICS].[ClearStaged]
(
	@ClearAsset [bit] = 0,
	@ClearAssetFile [bit] = 0,
	@ClearActivityLog [bit] = 0
)
AS
BEGIN
	IF (@ClearAssetFile = 1)
		TRUNCATE TABLE [IICS].[StagedAssetFile]
	IF (@ClearAsset = 1)
		TRUNCATE TABLE [IICS].[StagedAsset]
	IF (@ClearActivityLog = 1)
		TRUNCATE TABLE [IICS].[StagedActivityLog]
END
GO
--#endregion ClearStaged

--#region GetActivityLogLastStartTime
GO
CREATE OR ALTER PROCEDURE [IICS].[GetActivityLogLastStartTime]
AS
BEGIN
	SELECT MAX([LastStartTime]) AS [LastStartTime]
		FROM
		(
			SELECT CAST('1900-01-01' AS [datetime2](7)) AS [LastStartTime]
			UNION ALL SELECT MAX([StartTime]) AS [LastStartTime]
				FROM [IICS].[ActivityLog]
		) AS [ActivityLog]
END
GO
--#endregion GetActivityLogLastStartTime

--#region PostStagedActivityLogs
GO
CREATE OR ALTER PROCEDURE [IICS].[PostStagedActivityLogs]
(
	@JSON [nvarchar](MAX)
)
AS
BEGIN
	INSERT INTO [IICS].[StagedActivityLog]
	(
		[RunId], [FederatedId],
		[ActivityStateCode], [RunContextTypeCode],
		[ObjectId], [ObjectName], [Type],
		[ScheduleName], [StartTime], [EndTime],
		[FailedSourceRows], [SuccessSourceRows], [FailedTargetRows], [SuccessTargetRows],
		[TotalSuccessRows], [TotalFailedRows],
		[StopOnError], [HasStopOnErrorRecord],
		[ErrorMessage], [Entries]
	)
		SELECT
			[RunId], [FederatedId],
			[ActivityStateCode], [RunContextTypeCode],
			[ObjectId], [ObjectName], [Type],
			[ScheduleName], [StartTime], [EndTime],
			[FailedSourceRows], [SuccessSourceRows], [FailedTargetRows], [SuccessTargetRows],
			[TotalSuccessRows], [TotalFailedRows],
			[StopOnError], [HasStopOnErrorRecord],
			[ErrorMessage], [Entries]
			FROM OPENJSON(@JSON)
				WITH
				(
					[RunId] [bigint] N'$.runId',
					[FederatedId] [varchar](50) N'$.id',

					[ActivityStateCode] [int] N'$.state',
					[RunContextTypeCode] [varchar](50) N'$.runContextType',

					[ObjectId] [varchar](50) N'$.objectId',
					[ObjectName] [Nvarchar](400) N'$.objectName',
					[Type] [varchar](50) N'$.type',
					[ScheduleName] [nvarchar](400) N'$.scheduleName',

					[StartTime] [datetime2](7) N'$.startTimeUtc',
					[EndTime] [datetime2](7) N'$.endTimeUtc',
					[FailedSourceRows] [bigint] N'$.failedSourceRows',
					[SuccessSourceRows] [bigint] N'$.successSourceRows',
					[FailedTargetRows] [bigint] N'$.failedTargetRows',
					[SuccessTargetRows] [bigint] N'$.successTargetRows',

					[TotalSuccessRows] [bigint] N'$.totalSuccessRows',
					[TotalFailedRows] [bigint] N'$.totalFailedRows',
					[StopOnError] [bit] N'$.stopOnError',
					[HasStopOnErrorRecord] [bit] N'$.hasStopOnErrorRecord',
					[ErrorMessage] [nvarchar](2048) N'$.errorMsg',
					[Entries] [nvarchar](MAX) N'$.entries' AS JSON
				) AS [ActivityLog]
END
GO
--#endregion PostStagedActivityLogs

--#region PostStagedAssets
GO
CREATE OR ALTER PROCEDURE [IICS].[PostStagedAssets]
(
	@JSON [nvarchar](MAX)
)
AS
BEGIN
	INSERT INTO [IICS].[StagedAsset]([FederatedId], [Name], [Type], [Path])
		SELECT DISTINCT
			[Source].[FederatedId],
			[Source].[Name],
			[Source].[Type],
			[Source].[Path]
			FROM OPENJSON(@JSON)
				WITH
				(
					[FederatedId] [varchar](50) N'$.FederatedId',
					[Name] [nvarchar](400) N'$.Name',
					[Type] [varchar](20) N'$.Type',
					[Path] [nvarchar](400) N'$.Path'
				) AS [Source]
	UPDATE [IICS].[StagedAsset]
		SET [AssetGUID] = [Source].[AssetGUID]
		FROM [IICS].[StagedAsset]
			INNER JOIN
			(
				SELECT
					[Target].[FederatedId],
					[exportedObjectsJSON].[AssetGUID] AS [AssetGUID]
					FROM [IICS].[StagedAsset] AS [StagedAsset_ExportMetadata]
						INNER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_ExportMetadata]
							ON [StagedAsset_ExportMetadata].[FederatedId] = [StagedAssetFile_ExportMetadata].[FederatedId]
						OUTER APPLY OPENJSON([StagedAssetFile_ExportMetadata].[Content], N'$.exportedObjects')
							WITH
							(
								[AssetGuid] [varchar](50) N'$.objectGuid',
								[Name] [nvarchar](400) N'$.objectName',
								[Type] [varchar](20) N'$.objectType',
								[Path] [nvarchar](400) N'$.path'
							) AS [exportedObjectsJSON]
						LEFT OUTER JOIN [IICS].[StagedAsset] AS [Target]
							ON
								[exportedObjectsJSON].[Name] = [Target].[Name]
								AND [exportedObjectsJSON].[Type] = [Target].[Type]
								AND [exportedObjectsJSON].[Path] = [Target].[Path]
					WHERE
						[StagedAsset_ExportMetadata].[Name] = 'ExportMetadata'
						AND [StagedAsset_ExportMetadata].[Type] = 'ExportMetadata'
						AND [StagedAsset_ExportMetadata].[Path] = 'System'
			) AS [Source]
				ON [StagedAsset].[FederatedId] = [Source].[FederatedId]
END
GO
--#endregion PostStagedAssets

--#region PostStagedAssetFile
GO
CREATE OR ALTER PROCEDURE [IICS].[PostStagedAssetFile]
(
	@FederatedId [varchar](50),
	@FileName [nvarchar](400),
	@FileType [varchar](10),
	@Content [nvarchar](MAX)
)
AS
BEGIN
	INSERT INTO [IICS].[StagedAssetFile]([FederatedId], [FileName], [FileType], [Content])
		VALUES(@FederatedId, @FileName, @FileType, @Content)
END
GO
--#endregion PostStagedAssetFile

--#region ClearAssetChildTables
GO
CREATE OR ALTER PROCEDURE [IICS].[ClearAssetChildTables]
AS
BEGIN
	TRUNCATE TABLE [IICS].[CustomSource]
	TRUNCATE TABLE [IICS].[WorkflowTask]

	TRUNCATE TABLE [IICS].[SynchronizationFilter]
	TRUNCATE TABLE [IICS].[SynchronizationSource]
	DELETE FROM [IICS].[Synchronization]
	DBCC CHECKIDENT (N'[IICS].[Synchronization]', RESEED, 0);

	TRUNCATE TABLE [IICS].[MappingTaskExtendedSourceParameter]
	TRUNCATE TABLE [IICS].[MappingTaskSourceParameter]
	TRUNCATE TABLE [IICS].[MappingTaskStringParameter]
	TRUNCATE TABLE [IICS].[MappingTaskTargetParameter]
	DELETE FROM [IICS].[MappingTask]
	DBCC CHECKIDENT (N'[IICS].[MappingTask]', RESEED, 0);

	TRUNCATE TABLE [IICS].[MappingTransformationProperty]
	DELETE FROM [IICS].[Mapping]
	DBCC CHECKIDENT (N'[IICS].[Mapping]', RESEED, 0);

	TRUNCATE TABLE [IICS].[AssetConnection]
	TRUNCATE TABLE [IICS].[SQLServerConnection]
	TRUNCATE TABLE [IICS].[CSVFileConnection]
	TRUNCATE TABLE [IICS].[SalesforceConnection]
	TRUNCATE TABLE [IICS].[ODBCConnection]
	TRUNCATE TABLE [IICS].[ToolkitConnection]
	TRUNCATE TABLE [IICS].[ToolkitCCIConnection]
	TRUNCATE TABLE [IICS].[ConnectionProperty]
	DELETE FROM [IICS].[Connection]
	DBCC CHECKIDENT (N'[IICS].[Connection]', RESEED, 0);

	TRUNCATE TABLE [IICS].[AssetSchedule]

	--TRUNCATE TABLE [IICS].[ActivityLogSchedule]
	--DELETE FROM [IICS].[Schedule]
	--DBCC CHECKIDENT (N'[IICS].[Schedule]', RESEED, 0);
	
	--TRUNCATE TABLE [IICS].[ActivityLogAsset]
	--DELETE FROM [IICS].[Asset]
	--DBCC CHECKIDENT (N'[IICS].[Asset]', RESEED, 0);
	
	--DELETE FROM [IICS].[ActivityLog]
	--DBCC CHECKIDENT (N'[IICS].[Asset]', RESEED, 0);
END
GO
--#endregion ClearAssetChildTables

--#region ParseAssets
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseAssets]
AS
BEGIN
	MERGE [IICS].[Asset] AS [Target]
		USING
		(
			SELECT
				[AssetType].[AssetTypeId],
				[Source].[FederatedId],
				[Source].[AssetGuid],
				[Source].[Name],
				[Source].[Type],
				[Source].[Path],
				0 AS [IsRemoved]
				FROM
				(
					SELECT
						[StagedAsset].[FederatedId],
						[StagedAsset].[AssetGuid],
						[StagedAsset].[Name],
						[StagedAsset].[Type],
						[StagedAsset].[Path]
						FROM [IICS].[StagedAsset]
						WHERE
							[StagedAsset].[Type] NOT IN
							(
								'Connection',
								'Schedule',
								'ExportMetadata'
							)
							OR [StagedAsset].[AssetGuid] IS NOT NULL
					UNION ALL SELECT
						[Content].[FederatedId] AS [FederatedId],
						NULL AS [AssetGuid],
						[Content].[Name] AS [Name],
						'Schedule' AS [Type],
						'/System/Schedules' AS [Path]
						FROM [IICS].[StagedAsset]
							INNER JOIN [IICS].[StagedAssetFile]
								ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
							CROSS APPLY OPENJSON([StagedAssetFile].[Content], N'$.schedules')
								WITH
								(
									[FederatedId] [varchar](50) N'$.scheduleFederatedId',
									[Name] [nvarchar](400) N'$.name'
								) AS [Content]
						WHERE [StagedAsset].[FederatedId] = 'System.Schedule'
					UNION ALL SELECT
						[Content].[FederatedId] AS [FederatedId],
						NULL AS [AssetGuid],
						[Content].[Name] AS [Name],
						'Connection' AS [Type],
						'/System/Connections' AS [Path]
						FROM [IICS].[StagedAsset]
							INNER JOIN [IICS].[StagedAssetFile]
								ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
							CROSS APPLY OPENJSON([StagedAssetFile].[Content])
								WITH
								(
									[FederatedId] [varchar](50) N'$.federatedId',
									[Name] [nvarchar](400) N'$.name'
								) AS [Content]
						WHERE [StagedAsset].[FederatedId] = 'System.Connection'
				) AS [Source]
					INNER JOIN [IICS].[AssetType]
						ON [Source].[Type] = [AssetType].[Code]
		) AS [Source]
			ON [Target].[FederatedId] = [Source].[FederatedId]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([AssetTypeId], [FederatedId], [AssetGuid], [Name], [Type], [Path], [IsRemoved])
				VALUES ([Source].[AssetTypeId], [Source].[FederatedId], [Source].[AssetGuid], [Source].[Name], [Source].[Type], [Source].[Path], [Source].[IsRemoved])
		WHEN MATCHED THEN UPDATE SET
			[AssetTypeId] = [Source].[AssetTypeId],
			[AssetGuid] = [Source].[AssetGuid],
			[Name] = [Source].[Name],
			[Type] = [Source].[Type],
			[Path] = [Source].[Path],
			[IsRemoved] = [Source].[IsRemoved]
		WHEN NOT MATCHED BY SOURCE THEN UPDATE SET [IsRemoved] = 1
	;
END
GO
--#endregion ParseAssets

--#region ParseConnections
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseConnections]
AS
BEGIN
	INSERT INTO [IICS].[Connection]
		SELECT
			[Asset].[AssetId],
			[Content].[Type] AS [Type],
			[Content].[Name] AS [Name],
			[Content].[InstanceDisplayName] AS [InstanceDisplayName],
			[Content].[CreateTime] AS [CreateTime],
			[Content].[UpdateTime] AS [UpdateTime],
			[Content].[CreatedBy] AS [CreatedBy],
			[Content].[UpdatedBy] AS [UpdatedBy]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Name] [nvarchar](400) N'$.name',
						[InstanceDisplayName] [nvarchar](400) N'$.instanceDisplayName',
						[CreateTime] [datetime2](7) N'$.createTime',
						[UpdateTime] [datetime2](7) N'$.updateTime',
						[CreatedBy] [varchar](320) N'$.createdBy',
						[UpdatedBy] [varchar](320) N'$.updatedBy'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
			WHERE [StagedAsset].[FederatedId] = 'System.Connection'
	INSERT INTO [IICS].[SQLServerConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[Host] AS [Host],
			[Content].[Port] AS [Port],
			[Content].[Database] AS [Database],
			[Content].[AuthenticationType] AS [AuthenticationType],
			[Content].[Schema] AS [Schema],
			[Content].[UserName] AS [UserName]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Host] [nvarchar](400) N'$.host',
						[Port] [int] N'$.port',
						[Database] [nvarchar](400) N'$.database',
						[AuthenticationType] [nvarchar](400) N'$.authenticationType',
						[Schema] [nvarchar](400) N'$.schema',
						[UserName] [nvarchar](400) N'$.username'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] LIKE N'SqlServer%'
	INSERT INTO [IICS].[CSVFileConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[Database] AS [Database],
			[Content].[DateFormat] AS [DateFormat]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Database] [nvarchar](400) N'$.database',
						[DateFormat] [nvarchar](400) N'$.dateFormat'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'CSVFile'
	INSERT INTO [IICS].[SalesforceConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[ServiceUrl] AS [ServiceUrl],
			[Content].[UserName] AS [UserName]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[ServiceUrl] [nvarchar](400) N'$.serviceUrl',
						[UserName] [varchar](320) N'$.username'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'Salesforce'
	INSERT INTO [IICS].[ODBCConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[Database] AS [Database],
			[Content].[UserName] AS [UserName]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Database] [nvarchar](400) N'$.database',
						[UserName] [varchar](320) N'$.username'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'ODBC'
	INSERT INTO [IICS].[ToolkitConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[InstanceName] AS [InstanceName]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[InstanceName] [varchar](320) N'$.instanceName'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'TOOLKIT'
	INSERT INTO [IICS].[ToolkitCCIConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[InstanceName] AS [InstanceName]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[InstanceName] [varchar](320) N'$.instanceName'
					) AS [Content]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'TOOLKIT_CCI'
	INSERT INTO [IICS].[ConnectionProperty]
		SELECT
			[Connection].[ConnectionId],
			CONVERT([nvarchar](100), [PropertyPivot].[Name], 0) AS [Name],
			CONVERT([nvarchar](400), [PropertyPivot].[Value], 0) AS [Value]
			FROM [IICS].[StagedAsset]
				INNER JOIN [IICS].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Name] [nvarchar](400) N'$.name',
						[Description] [nvarchar](400) N'$.description',
						[InstanceDisplayName] [nvarchar](400) N'$.instanceDisplayName',
						[Host] [nvarchar](400) N'$.host',
						[Port] [int] N'$.port',
						[Database] [nvarchar](400) N'$.database',
						[AuthenticationType] [nvarchar](400) N'$.authenticationType',
						[Schema] [nvarchar](400) N'$.schema',
						[UserName] [nvarchar](400) N'$.username',
						[DateFormat] [nvarchar](400) N'$.dateFormat',
						[ServiceUrl] [nvarchar](400) N'$.serviceUrl',
						[InstanceName] [nvarchar](400) N'$.instanceName'
					) AS [Content]
				CROSS APPLY
				(
					SELECT N'Type' AS [Name], [Content].[Type] AS [Value]
					UNION ALL SELECT N'Name' AS [Name], [Content].[Name] AS [Value]
					UNION ALL SELECT N'Description' AS [Name], [Content].[Description] AS [Value]
					UNION ALL SELECT N'InstanceDisplayName' AS [Name], [Content].[InstanceDisplayName] AS [Value]
					UNION ALL SELECT N'Database' AS [Name], [Content].[Database] AS [Value]
					UNION ALL SELECT N'Host' AS [Name], [Content].[Host] AS [Value]
					UNION ALL SELECT N'Port' AS [Name], FORMAT([Content].[Port], N'0') AS [Value]
					UNION ALL SELECT N'AuthenticationType' AS [Name], [Content].[AuthenticationType] AS [Value]
					UNION ALL SELECT N'Schema' AS [Name], [Content].[Schema] AS [Value]
					UNION ALL SELECT N'UserName' AS [Name], [Content].[UserName] AS [Value]
					UNION ALL SELECT N'DateFormat' AS [Name], [Content].[DateFormat] AS [Value]
					UNION ALL SELECT N'ServiceUrl' AS [Name], [Content].[ServiceUrl] AS [Value]
					UNION ALL SELECT N'InstanceName' AS [Name], [Content].[InstanceName] AS [Value]
				) AS [PropertyPivot]
				INNER JOIN [IICS].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [PropertyPivot].[Value] IS NOT NULL
END
GO
--#endregion ParseConnections

--#region ParseSchedules
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseSchedules]
AS
BEGIN
	MERGE [IICS].[Schedule] AS [Target]
		USING
		(
			SELECT
				[Asset].[AssetId] AS [AssetId],
				[ScheduleInterval].[ScheduleIntervalId],
				[Content].[Id] AS [Id],
				[Content].[Name] AS [Name],
				[Content].[Description] AS [Description],
				[Content].[Status] AS [Status],
				[Content].[RangeStartTime] AS [RangeStartTime],
				[Content].[RangeEndTime] AS [RangeEndTime],
				[Content].[StartTime] AS [StartTime],
				[Content].[EndTime] AS [EndTime],
				[Content].[Frequency] AS [Frequency],
				[Content].[Monday] AS [Monday],
				[Content].[Tuesday] AS [Tuesday],
				[Content].[Wednesday] AS [Wednesday],
				[Content].[Thursday] AS [Thursday],
				[Content].[Friday] AS [Friday],
				[Content].[Saturday] AS [Saturday],
				[Content].[Sunday] AS [Sunday],
				[Content].[Weekday] AS [Weekday],
				[Content].[DayOfMonth] AS [DayOfMonth],
				[Content].[WeekOfMonth] AS [WeekOfMonth],
				[Content].[DayOfWeek] AS [DayOfWeek],
				[Content].[CreateTime] AS [CreateTime],
				[Content].[UpdateTime] AS [UpdateTime],
				[Content].[CreatedBy] AS [CreatedBy],
				[Content].[UpdatedBy] AS [UpdatedBy],
				0 AS [IsRemoved]
				FROM [IICS].[StagedAsset]
					INNER JOIN [IICS].[StagedAssetFile]
						ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
					CROSS APPLY OPENJSON([StagedAssetFile].[Content], N'$.schedules')
						WITH
						(
							[FederatedId] [varchar](50) N'$.scheduleFederatedId',
							[Id] [varchar](50) N'$.id',
							[Name] [nvarchar](400) N'$.name',
							[Description] [nvarchar](400) N'$.description',
							[Status] [varchar](20) N'$.status',
							[RangeStartTime] [datetime2](7) N'$.rangeStartTime',
							[RangeEndTime] [datetime2](7) N'$.rangeEndTime',
							[StartTime] [datetime2](7) N'$.startTime',
							[EndTime] [datetime2](7) N'$.endTime',
							[Interval] [varchar](20) N'$.interval',
							[Frequency] [int] N'$.frequency',
							[Monday] [bit] N'$.mon',
							[Tuesday] [bit] N'$.tue',
							[Wednesday] [bit] N'$.wed',
							[Thursday] [bit] N'$.thu',
							[Friday] [bit] N'$.fri',
							[Saturday] [bit] N'$.sat',
							[Sunday] [bit] N'$.sun',
							[Weekday] [bit] N'$.weekDay',
							[DayOfMonth] [int] N'$.dayOfMonth',
							[WeekOfMonth] [varchar](20) N'$.weekOfMonth',
							[DayOfWeek] [varchar](20) N'$.dayOfWeek',
							[CreateTime] [datetime2](7) N'$.createTime',
							[UpdateTime] [datetime2](7) N'$.updateTime',
							[CreatedBy] [varchar](320) N'$.createdBy',
							[UpdatedBy] [varchar](320) N'$.updatedBy'
						) AS [Content]
					INNER JOIN [IICS].[Asset]
						ON [Content].[FederatedId] = [Asset].[FederatedId]
					INNER JOIN [IICS].[ScheduleInterval]
						ON [Content].[Interval] = [ScheduleInterval].[Name]
				WHERE [StagedAsset].[FederatedId] = 'System.Schedule'
		) AS [Source]
			ON [Source].[AssetId] = [Target].[AssetId]
		WHEN MATCHED THEN UPDATE SET
			[ScheduleIntervalId] = [Source].[ScheduleIntervalId],
			[Id] = [Source].[Id], [Name] = [Source].[Name], [Description] = [Source].[Description], [Status] = [Source].[Status],
			[RangeStartTime] = [Source].[RangeStartTime], [RangeEndTime] = [Source].[RangeEndTime], [StartTime] = [Source].[StartTime], [EndTime] = [Source].[EndTime],
			[Frequency] = [Source].[Frequency],
			[Monday] = [Source].[Monday], [Tuesday] = [Source].[Tuesday], [Wednesday] = [Source].[Wednesday], [Thursday] = [Source].[Thursday], [Friday] = [Source].[Friday], [Saturday] = [Source].[Saturday], [Sunday] = [Source].[Sunday],
			[Weekday] = [Source].[Weekday], [DayOfMonth] = [Source].[DayOfMonth], [WeekOfMonth] = [Source].[WeekOfMonth], [DayOfWeek] = [Source].[DayOfWeek],
			[CreateTime] = [Source].[CreateTime], [UpdateTime] = [Source].[UpdateTime], [CreatedBy] = [Source].[CreatedBy], [UpdatedBy] = [Source].[UpdatedBy], [IsRemoved] = [Source].[IsRemoved]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				[AssetId], [ScheduleIntervalId], [Id], [Name], [Description], [Status],
				[RangeStartTime], [RangeEndTime], [StartTime], [EndTime],
				[Frequency],
				[Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday],
				[Weekday], [DayOfMonth], [WeekOfMonth], [DayOfWeek],
				[CreateTime], [UpdateTime], [CreatedBy], [UpdatedBy], [IsRemoved]
			)
				VALUES
				(
					[Source].[AssetId], [Source].[ScheduleIntervalId], [Source].[Id], [Source].[Name], [Source].[Description], [Source].[Status],
					[Source].[RangeStartTime], [Source].[RangeEndTime], [Source].[StartTime], [Source].[EndTime],
					[Source].[Frequency],
					[Source].[Monday], [Source].[Tuesday], [Source].[Wednesday], [Source].[Thursday], [Source].[Friday], [Source].[Saturday], [Source].[Sunday],
					[Source].[Weekday], [Source].[DayOfMonth], [Source].[WeekOfMonth], [Source].[DayOfWeek],
					[Source].[CreateTime], [Source].[UpdateTime], [Source].[CreatedBy], [Source].[UpdatedBy], [Source].[IsRemoved]
				)
		WHEN NOT MATCHED BY SOURCE THEN UPDATE SET [IsRemoved] = 1
	;
	UPDATE [IICS].[Schedule]
		SET [ScheduleText] = [IICS].[GetScheduleTexturalStatement]
			(
				[ScheduleInterval].[Name],
				[Schedule].[Weekday],
				[Schedule].[DayOfMonth],
				[Schedule].[WeekOfMonth],
				[Schedule].[DayOfWeek],
				[Schedule].[Frequency],
				[Schedule].[Monday],
				[Schedule].[Tuesday],
				[Schedule].[Wednesday],
				[Schedule].[Thursday],
				[Schedule].[Friday],
				[Schedule].[Saturday],
				[Schedule].[Sunday],
				[Schedule].[StartTime],
				[Schedule].[EndTime],
				[Schedule].[RangeStartTime],
				[Schedule].[RangeEndTime]
			)
		FROM [IICS].[Schedule]
			INNER JOIN [IICS].[ScheduleInterval]
				ON [Schedule].[ScheduleIntervalId] = [ScheduleInterval].[ScheduleIntervalId]
END
GO
--#endregion ParseSchedules

--#region ParseAssetConnections
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseAssetConnections]
AS
BEGIN
	INSERT INTO [IICS].[AssetConnection]
		SELECT DISTINCT
			[Asset].[AssetId],
			[Connection].[ConnectionId],
			[Source].[Use]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Connection].[ConnectionFederatedId],
					[Connection].[Use]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY
						(
							SELECT
								'Source' AS [Use],
								CASE
									WHEN LEFT([Content].[FederatedId], 1) = '@'
										THEN RIGHT([Content].[FederatedId], (LEN([Content].[FederatedId]) - 1))
									ELSE [Content].[FederatedId]
								END AS [ConnectionFederatedId]
								FROM OPENJSON([StagedAssetFile].[Content])
									WITH([FederatedId] [varchar](50) N'$.sourceConnectionId') AS [Content]
							UNION
							SELECT
								'Target' AS [Use],
								CASE
									WHEN LEFT([Content].[FederatedId], 1) = '@'
										THEN RIGHT([Content].[FederatedId], (LEN([Content].[FederatedId]) - 1))
									ELSE [Content].[FederatedId]
								END AS [ConnectionFederatedId]
								FROM OPENJSON([StagedAssetFile].[Content])
									WITH([FederatedId] [varchar](50) N'$.targetConnectionId') AS [Content]
						) AS [Connection]
						WHERE
							[StagedAsset].[Type] = 'DSS'
							AND [StagedAssetFile].[FileName] = N'dssTask.json'
							AND [Connection].[ConnectionFederatedId] IS NOT NULL
				UNION ALL SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Connection].[ConnectionFederatedId], 1) = '@'
							THEN RIGHT([Connection].[ConnectionFederatedId], (LEN([Connection].[ConnectionFederatedId]) - 1))
						ELSE [Connection].[ConnectionFederatedId]
					END AS [ConnectionFederatedId],
					[Connection].[Use]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						OUTER APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[JSON] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Parameters]
						OUTER APPLY OPENJSON([Parameters].[JSON])
							WITH
							(
								[SourceFederatedId] [varchar](50) N'$.sourceConnectionId',
								[TargetFederatedId] [varchar](50) N'$.targetConnectionId'
							) AS [Connections]
						OUTER APPLY
						(
							SELECT 'Source' AS [Use], [Connections].[SourceFederatedId] AS [ConnectionFederatedId]
							UNION ALL SELECT 'Target' AS [Use], [Connections].[TargetFederatedId] AS [ConnectionFederatedId]
						) AS [Connection]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [StagedAssetFile].[FileName] = N'mtTask.json'
						AND [Connection].[ConnectionFederatedId] IS NOT NULL
				UNION ALL SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Connection].[ConnectionFederatedId], 1) = '@'
							THEN RIGHT([Connection].[ConnectionFederatedId], (LEN([Connection].[ConnectionFederatedId]) - 1))
						ELSE [Connection].[ConnectionFederatedId]
					END AS [ConnectionFederatedId],
					'Reference' AS [Use]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						OUTER APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[JSON] [nvarchar](MAX) N'$.references' AS JSON
							) AS [References]
						OUTER APPLY OPENJSON([References].[JSON])
							WITH
							(
								[Type] [varchar](50) N'$.refType',
								[ConnectionFederatedId] [varchar](50) N'$.refObjectId'
							) AS [Connection]
					WHERE
						[StagedAsset].[Type] = 'DTEMPLATE'
						AND [StagedAssetFile].[FileName] = N'mappingTemplate.json'
						AND [Connection].[ConnectionFederatedId] IS NOT NULL
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Asset] AS [Asset_Connection]
					ON [Source].[ConnectionFederatedId] = [Asset_Connection].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset_Connection].[AssetId] = [Connection].[AssetId]
END
GO
--#endregion ParseAssetConnections

--#region ParseAssetSchedules
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseAssetSchedules]
AS
BEGIN
	INSERT INTO [IICS].[AssetSchedule]
		SELECT DISTINCT
			[Asset].[AssetId],
			[Schedule].[ScheduleId]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[scheduleJSON].[name] AS [ScheduleName]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_mtTask]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_mtTask].[FederatedId]
								AND 'mtTask.json' = [StagedAssetFile_mtTask].[FileName]
						INNER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_schedule]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_schedule].[FederatedId]
								AND 'schedule.json' = [StagedAssetFile_schedule].[FileName]
						CROSS APPLY OPENJSON([StagedAssetFile_mtTask].[Content])
							WITH
							(
								[scheduleId] [varchar](100) N'$.scheduleId'
							) AS [mtTaskJSON]
						CROSS APPLY OPENJSON([StagedAssetFile_schedule].[Content])
							WITH
							(
								[scheduleId] [varchar](100) N'$.id',
								[name] [nvarchar](400) N'$.name'
							) AS [scheduleJSON]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [mtTaskJSON].[scheduleId] = [scheduleJSON].[scheduleId]
				UNION ALL SELECT
					[StagedAsset].[FederatedId],
					[scheduleJSON].[name] AS [ScheduleName]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_workflow]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_workflow].[FederatedId]
								AND 'workflow.json' = [StagedAssetFile_workflow].[FileName]
						INNER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_schedule]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_schedule].[FederatedId]
								AND 'schedule.json' = [StagedAssetFile_schedule].[FileName]
						CROSS APPLY OPENJSON([StagedAssetFile_workflow].[Content])
							WITH
							(
								[scheduleId] [varchar](100) N'$.scheduleId'
							) AS [workflowJSON]
						CROSS APPLY OPENJSON([StagedAssetFile_schedule].[Content])
							WITH
							(
								[scheduleId] [varchar](100) N'$.id',
								[name] [nvarchar](400) N'$.name'
							) AS [scheduleJSON]
					WHERE
						[StagedAsset].[Type] = 'WORKFLOW'
						AND [workflowJSON].[scheduleId] = [scheduleJSON].[scheduleId]
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Schedule]
					ON [Source].[ScheduleName] = [Schedule].[Name]
END
GO
--#endregion ParseAssetSchedules

--#region ParseWorkflowTasks
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseWorkflowTasks]
AS
BEGIN
	INSERT INTO [IICS].[WorkflowTask]
		SELECT
			[Asset_Workflow].[AssetId] AS [WorkflowAssetId],
			[Asset_Task].[AssetId] AS [TaskAssetId],
			[Source].[Sequence]
			FROM
			(
				SELECT
					[StagedAsset_workflow].[WorkflowFederatedId],
					[StagedAsset_Task].[FederatedId] AS [TaskFederatedId],
					[StagedAsset_workflow].[Sequence]
					FROM
					(
						SELECT
							[StagedAsset_workflow].[FederatedId] AS [WorkflowFederatedId],
							[tasksJSON].[key] AS [Sequence],
							JSON_VALUE([tasksJSON].[value], N'$.taskId') AS [taskId]
							FROM [IICS].[StagedAsset] AS [StagedAsset_workflow]
								INNER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_workflow]
									ON
										[StagedAsset_workflow].[FederatedId] = [StagedAssetFile_workflow].[FederatedId]
										AND 'workflow.json' = [StagedAssetFile_workflow].[FileName]
								OUTER APPLY OPENJSON([StagedAssetFile_workflow].[Content])
									WITH
									(
										[tasksJSON] [nvarchar](MAX) N'$.tasks' AS JSON
									) AS [workflowJSON]
								OUTER APPLY OPENJSON([workflowJSON].[tasksJSON]) AS [tasksJSON]
							WHERE [StagedAsset_workflow].[Type] = 'WORKFLOW'
					) AS [StagedAsset_workflow]
						LEFT OUTER JOIN [IICS].[StagedAsset] AS [StagedAsset_Task]
							ON
								CASE
									WHEN LEFT([StagedAsset_workflow].[taskId], 1) = '@'
										THEN RIGHT([StagedAsset_workflow].[taskId], (LEN([StagedAsset_workflow].[taskId]) - 1))
									ELSE [StagedAsset_workflow].[taskId]
								END = [StagedAsset_Task].[FederatedId]
					WHERE [StagedAsset_Task].[FederatedId] IS NOT NULL
			) AS [Source]
				INNER JOIN [IICS].[Asset] AS [Asset_Workflow]
					ON [Source].[WorkflowFederatedId] = [Asset_Workflow].[FederatedId]
				INNER JOIN [IICS].[Asset] AS [Asset_Task]
					ON [Source].[TaskFederatedId] = [Asset_Task].[FederatedId]
END
GO
--#endregion ParseWorkflowTasks

--#region ParseSynchronizationAssets
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseSynchronizationAssets]
AS
BEGIN
	DROP TABLE IF EXISTS [#Operation]
	SELECT DISTINCT [Content].[Operation] AS [Name]
		INTO [#Operation]
		FROM [IICS].[StagedAsset]
			INNER JOIN [IICS].[StagedAssetFile]
				ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
			CROSS APPLY OPENJSON([StagedAssetFile].[Content])
				WITH
				(
					[Operation] [varchar](50) N'$.operation'
				) AS [Content]
		WHERE [StagedAsset].[Type] = 'DSS'
	INSERT INTO [IICS].[Operation]([Name])
		SELECT CAST([Source].[Name] AS [varchar](50)) AS [Name]
			FROM [#Operation] AS [Source]
				LEFT OUTER JOIN [IICS].[Operation] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[OperationId] IS NULL
	DROP TABLE IF EXISTS [#Operation]
	INSERT INTO [IICS].[Synchronization]
		SELECT
			[Asset].[AssetId],
			[Connection_Target].[ConnectionId] AS [TargetConnectionId],
			[Operation].[OperationId],
			[Source].[PreProcessingCmd],
			[Source].[PostProcessingCmd],
			[Source].[TargetObject],
			[Source].[TruncateTarget]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Content].[targetConnectionId], 1) = '@'
							THEN RIGHT([Content].[targetConnectionId], (LEN([Content].[targetConnectionId]) - 1))
						ELSE [Content].[targetConnectionId]
					END AS [TargetConnectionFederatedId],
					[Content].[Operation] AS [Operation],
					[Content].[PreProcessingCmd] AS [PreProcessingCmd],
					[Content].[PostProcessingCmd] AS [PostProcessingCmd],
					[Content].[TargetObject] AS [TargetObject],
					[Content].[TruncateTarget] AS [TruncateTarget]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Operation] [varchar](50) N'$.operation',
								[PreProcessingCmd] [nvarchar](MAX) N'$.preProcessingCmd',
								[PostProcessingCmd] [nvarchar](MAX) N'$.postProcessingCmd',
								[TargetObject] [nvarchar](400) N'$.targetObject',
								[TruncateTarget] [bit] N'$.truncateTarget',
								[targetConnectionId] [varchar](50) N'$.targetConnectionId'
							) AS [Content]
					WHERE [StagedAsset].[Type] = 'DSS'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Asset] AS [Asset_TargetConnection]
					ON [Source].[TargetConnectionFederatedId] = [Asset_TargetConnection].[FederatedId]
				INNER JOIN [IICS].[Connection] AS [Connection_Target]
					ON [Asset_TargetConnection].[AssetId] = [Connection_Target].[AssetId]
				INNER JOIN [IICS].[Operation]
					ON [Source].[Operation] = [Operation].[Name]
	INSERT INTO [IICS].[SynchronizationSource]
		SELECT
			[Synchronization].[SynchronizationId],
			[Connection_Source].[ConnectionId] AS [SourceConnectionId],
			[Source].[Name],
			[Source].[Label]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Content].[sourceConnectionId], 1) = '@'
							THEN RIGHT([Content].[sourceConnectionId], (LEN([Content].[sourceConnectionId]) - 1))
						ELSE [Content].[sourceConnectionId]
					END AS [SourceConnectionFederatedId],
					[sourceObjects].[Name] AS [Name],
					[sourceObjects].[Label] AS [Label]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[sourceConnectionId] [varchar](50) N'$.sourceConnectionId',
								[sourceObjectsJSON] [nvarchar](MAX) N'$.sourceObjects' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[sourceObjectsJSON])
							WITH
							(
								[Name] [nvarchar](400) N'$.name',
								[Label] [nvarchar](400) N'$.label'
							) AS [sourceObjects]
					WHERE [StagedAsset].[Type] = 'DSS'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Synchronization]
					ON [Asset].[AssetId] = [Synchronization].[AssetId]
				INNER JOIN [IICS].[Asset] AS [Asset_SourceConnection]
					ON [Source].[SourceConnectionFederatedId] = [Asset_SourceConnection].[FederatedId]
				INNER JOIN [IICS].[Connection] AS [Connection_Source]
					ON [Asset_SourceConnection].[AssetId] = [Connection_Source].[AssetId]
	INSERT INTO [IICS].[SynchronizationFilter]
		SELECT
			[Synchronization].[SynchronizationId],
			[Source].[ObjectName],
			[Source].[ObjectLabel],
			[Source].[Field],
			[Source].[FieldLabel],
			[Source].[Type],
			[Source].[Operator],
			[Source].[Value]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[filters].[ObjectName] AS [ObjectName],
					[filters].[ObjectLabel] AS [ObjectLabel],
					[filters].[Field] AS [Field],
					[filters].[FieldLabel] AS [FieldLabel],
					[filters].[Type] AS [Type],
					[filters].[Operator] AS [Operator],
					[filters].[Value] AS [Value]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[filtersJSON] [nvarchar](MAX) N'$.filters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[filtersJSON])
							WITH
							(
								[ObjectName] [nvarchar](400) N'$.objectName',
								[ObjectLabel] [nvarchar](400) N'$.objectLabel',
								[Field] [nvarchar](400) N'$.field',
								[FieldLabel] [nvarchar](400) N'$.fieldLabel',
								[Type] [nvarchar](400) N'$.type',
								[Operator] [nvarchar](400) N'$.operator',
								[Value] [nvarchar](400) N'$.value'
							) AS [filters]
					WHERE [StagedAsset].[Type] = 'DSS'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Synchronization]
					ON [Asset].[AssetId] = [Synchronization].[AssetId]
END
GO
--#endregion ParseSynchronizationAssets

--#region ParseCustomSourceAssets
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseCustomSourceAssets]
AS
BEGIN
	DROP TABLE IF EXISTS [#Operation]
	SELECT DISTINCT [Content].[Type] AS [Name]
		INTO [#CustomSourceType]
		FROM [IICS].[StagedAsset]
			INNER JOIN [IICS].[StagedAssetFile]
				ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
			CROSS APPLY OPENJSON([StagedAssetFile].[Content])
				WITH
				(
					[type] [nvarchar](25) N'$.type',
					[Query] [nvarchar](MAX) N'$.query'
				) AS [Content]
		WHERE [StagedAsset].[Type] = 'CustomSource'
	INSERT INTO [IICS].[CustomSourceType]([Name])
		SELECT CAST([Source].[Name] AS [varchar](50)) AS [Name]
			FROM [#CustomSourceType] AS [Source]
				LEFT OUTER JOIN [IICS].[CustomSourceType] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[CustomSourceTypeId] IS NULL
	DROP TABLE IF EXISTS [#CustomSourceType]

	DROP TABLE IF EXISTS [#CustomSource]
	SELECT
		[StagedAsset].[FederatedId],
		[Content].[Type] AS [Type],
		[Content].[Query] AS [Query]
		INTO [#CustomSource]
		FROM [IICS].[StagedAsset]
			INNER JOIN [IICS].[StagedAssetFile]
				ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
			CROSS APPLY OPENJSON([StagedAssetFile].[Content])
				WITH
				(
					[type] [nvarchar](25) N'$.type',
					[Query] [nvarchar](MAX) N'$.query'
				) AS [Content]
		WHERE [StagedAsset].[Type] = 'CustomSource'
	INSERT INTO [IICS].[CustomSource]
		SELECT
			[Asset].[AssetId],
			[CustomSourceType].[CustomSourceTypeId],
			[Source].[Query]
			FROM [#CustomSource] AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[CustomSourceType]
					ON [Source].[Type] = [CustomSourceType].[Name]
	DROP TABLE IF EXISTS [#CustomSource]
END
GO
--#endregion ParseCustomSourceAssets

--#region ParseMappingAssets
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseMappingAssets]
AS
BEGIN
	INSERT INTO [IICS].[Mapping]
		SELECT [Asset].[AssetId]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId]
					FROM [IICS].[StagedAsset]
					WHERE [StagedAsset].[Type] = 'DTEMPLATE'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
	INSERT INTO [IICS].[MappingTransformationProperty]
		SELECT
			[Mapping].[MappingId],
			[Source].[TransformationName],
			[Source].[PropertyName],
			[Source].[Value]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[transformations].[Name] AS [TransformationName],
					[advancedProperties].[Name] AS [PropertyName],
					NULLIF([advancedProperties].[Value], N'') AS [Value]
					FROM [IICS].[StagedAsset]
						LEFT OUTER JOIN [IICS].[StagedAssetFile] AS [StagedAssetFile_MappingBIN]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_MappingBIN].[FederatedId]
								AND 'bin' = [StagedAssetFile_MappingBIN].[FileType]
								AND 1 = ISJSON([StagedAssetFile_MappingBIN].[Content])
						OUTER APPLY OPENJSON([StagedAssetFile_MappingBIN].[Content], N'$.content')
							WITH
							(
								[transformationsJSON] [nvarchar](MAX) N'$.transformations' AS JSON
							) AS [Content_MappingBIN]
						OUTER APPLY OPENJSON([Content_MappingBIN].[transformationsJSON])
							WITH
							(
								[Name] [nvarchar](100) N'$.name',
								[advancedPropertiesJSON] [nvarchar](MAX) N'$.advancedProperties' AS JSON
							) AS [transformations]
						OUTER APPLY OPENJSON([transformations].[advancedPropertiesJSON])
							WITH
							(
								[Name] [nvarchar](100) N'$.name',
								[Value] [nvarchar](MAX) N'$.value'
							) AS [advancedProperties]
					WHERE
						[StagedAsset].[Type] = 'DTEMPLATE'
						AND NULLIF([transformations].[Name], N'') IS NOT NULL
						AND NULLIF([advancedProperties].[Name], N'') IS NOT NULL
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Mapping]
					ON [Asset].[AssetId] = [Mapping].[AssetId]
END
GO
--#endregion ParseMappingAssets

--#region ParseMappingTaskAssets
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseMappingTaskAssets]
AS
BEGIN
	INSERT INTO [IICS].[MappingTask]
		SELECT
			[Asset].[AssetId],
			[Mapping].[MappingId]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Content].[MappingFederatedId], 1) = '@'
							THEN RIGHT([Content].[MappingFederatedId], (LEN([Content].[MappingFederatedId]) - 1))
						ELSE [Content].[MappingFederatedId]
					END AS [MappingFederatedId],
					[StagedAssetFile].[Content]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[MappingFederatedId] [varchar](50) N'$.mappingId'
							) AS [Content]
					WHERE [StagedAsset].[Type] = 'MTT'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[Asset] AS [Asset_Mapping]
					ON [Source].[MappingFederatedId] = [Asset_Mapping].[FederatedId]
				INNER JOIN [IICS].[Mapping]
					ON [Asset_Mapping].[AssetId] = [Mapping].[AssetId]
	INSERT INTO [IICS].[MappingTaskExtendedSourceParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Connection].[ConnectionId],
			[Source].[Name],
			[Source].[Label],
			[Source].[ObjectName],
			[Source].[ObjectLabel]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Label] AS [Label],
					CASE
						WHEN LEFT([Paramter].[SourceFederatedConnectionId], 1) = '@'
							THEN RIGHT([Paramter].[SourceFederatedConnectionId], (LEN([Paramter].[SourceFederatedConnectionId]) - 1))
						ELSE [Paramter].[SourceFederatedConnectionId]
					END AS [SourceFederatedConnectionId],
					[Paramter].[ObjectName] AS [ObjectName],
					[Paramter].[ObjectLabel] AS [ObjectLabel]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Label] [varchar](100) N'$.label',
								[SourceFederatedConnectionId] [varchar](50) N'$.sourceConnectionId',
								[ObjectName] [nvarchar](400) N'$.extendedObject.object.name',
								[ObjectLabel] [nvarchar](400) N'$.extendedObject.object.label'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'EXTENDED_SOURCE'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
				INNER JOIN [IICS].[Asset] AS [Asset_SourceConnection]
					ON [Source].[SourceFederatedConnectionId] = [Asset_SourceConnection].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset_SourceConnection].[AssetId] = [Connection].[AssetId]
	INSERT INTO [IICS].[MappingTaskSourceParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Connection].[ConnectionId],
			[Source].[Name],
			[Source].[Label],
			[Source].[CustomQuery]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Label] AS [Label],
					CASE
						WHEN LEFT([Paramter].[SourceFederatedConnectionId], 1) = '@'
							THEN RIGHT([Paramter].[SourceFederatedConnectionId], (LEN([Paramter].[SourceFederatedConnectionId]) - 1))
						ELSE [Paramter].[SourceFederatedConnectionId]
					END AS [SourceFederatedConnectionId],
					[Paramter].[CustomQuery] AS [CustomQuery]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Label] [varchar](100) N'$.label',
								[SourceFederatedConnectionId] [varchar](50) N'$.sourceConnectionId',
								[CustomQuery] [nvarchar](MAX) N'$.customQuery'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'SOURCE'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
				INNER JOIN [IICS].[Asset] AS [Asset_SourceConnection]
					ON [Source].[SourceFederatedConnectionId] = [Asset_SourceConnection].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset_SourceConnection].[AssetId] = [Connection].[AssetId]
	INSERT INTO [IICS].[MappingTaskStringParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Source].[Name],
			[Source].[Text],
			[Source].[Label],
			[Source].[Description]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Text] AS [Text],
					[Paramter].[Label] AS [Label],
					[Paramter].[Description] AS [Description]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Text] [varchar](100) N'$.text',
								[Label] [varchar](100) N'$.label',
								[Description] [varchar](MAX) N'$.description'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'STRING'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
	INSERT INTO [IICS].[MappingTaskTargetParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Connection].[ConnectionId],
			[Source].[Name],
			[Source].[Label],
			[Source].[ObjectName],
			[Source].[ObjectLabel],
			[Source].[TruncateTarget]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Label] AS [Label],
					CASE
						WHEN LEFT([Paramter].[TargetFederatedConnectionId], 1) = '@'
							THEN RIGHT([Paramter].[TargetFederatedConnectionId], (LEN([Paramter].[TargetFederatedConnectionId]) - 1))
						ELSE [Paramter].[TargetFederatedConnectionId]
					END AS [TargetFederatedConnectionId],
					[Paramter].[ObjectName] AS [ObjectName],
					[Paramter].[ObjectLabel] AS [ObjectLabel],
					[Paramter].[TruncateTarget] AS [TruncateTarget]
					FROM [IICS].[StagedAsset]
						INNER JOIN [IICS].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Label] [varchar](100) N'$.label',
								[TargetFederatedConnectionId] [varchar](50) N'$.targetConnectionId',
								[ObjectName] [nvarchar](400) N'$.objectName',
								[ObjectLabel] [nvarchar](400) N'$.objectLabel',
								[TruncateTarget] [bit] N'$.truncateTarget'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'TARGET'
			) AS [Source]
				INNER JOIN [IICS].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [IICS].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
				INNER JOIN [IICS].[Asset] AS [Asset_TargetConnection]
					ON [Source].[TargetFederatedConnectionId] = [Asset_TargetConnection].[FederatedId]
				INNER JOIN [IICS].[Connection]
					ON [Asset_TargetConnection].[AssetId] = [Connection].[AssetId]
END
GO
--#endregion ParseMappingTaskAssets

--#region Parse
GO
CREATE OR ALTER PROCEDURE [IICS].[Parse]
AS
BEGIN
	EXEC [IICS].[ClearAssetChildTables]
	EXEC [IICS].[ParseAssets]
	EXEC [IICS].[ParseConnections]
	EXEC [IICS].[ParseSchedules]
	EXEC [IICS].[ParseAssetConnections]
	EXEC [IICS].[ParseAssetSchedules]
	EXEC [IICS].[ParseWorkflowTasks]
	EXEC [IICS].[ParseSynchronizationAssets]
	EXEC [IICS].[ParseMappingAssets]
	EXEC [IICS].[ParseMappingTaskAssets]
	EXEC [IICS].[ParseCustomSourceAssets]
END
GO
--#endregion Parse

--#region ParseActivityLogs
GO
CREATE OR ALTER PROCEDURE [IICS].[ParseActivityLogs]
AS
BEGIN
	INSERT INTO [IICS].[ActivityLog]
	(
		[ActivityLogStateId], [RunContextTypeId],
		[RunId], [FederatedId],
		[StartTime], [EndTime],
		[FailedSourceRows], [SuccessSourceRows],
		[FailedTargetRows], [SuccessTargetRows],
		[TotalSuccessRows], [TotalFailedRows],
		[StopOnError], [HasStopOnErrorRecord],
		[ErrorMessage], [Entries]
	)
		SELECT
			[ActivityLogState].[ActivityLogStateId],
			[RunContextType].[RunContextTypeId],
			[StagedActivityLog].[RunId], [StagedActivityLog].[FederatedId],
			[StagedActivityLog].[StartTime], [StagedActivityLog].[EndTime],
			[StagedActivityLog].[FailedSourceRows], [StagedActivityLog].[SuccessSourceRows],
			[StagedActivityLog].[FailedTargetRows], [StagedActivityLog].[SuccessTargetRows],
			[StagedActivityLog].[TotalSuccessRows], [StagedActivityLog].[TotalFailedRows],
			[StagedActivityLog].[StopOnError], [StagedActivityLog].[HasStopOnErrorRecord],
			[StagedActivityLog].[ErrorMessage], [StagedActivityLog].[Entries]
			FROM [IICS].[StagedActivityLog]
				INNER JOIN [IICS].[RunContextType]
					ON [StagedActivityLog].[RunContextTypeCode] = [RunContextType].[Code]
				INNER JOIN [IICS].[ActivityLogState]
					ON [StagedActivityLog].[ActivityStateCode] = [ActivityLogState].[Code]
				LEFT OUTER JOIN [IICS].[ActivityLog] AS [Target]
					ON [StagedActivityLog].[FederatedId] = [Target].[FederatedId]
			WHERE [Target].[ActivityLogId] IS NULL
	INSERT INTO [IICS].[ActivityLogAsset]([ActivityLogId], [AssetId])
		SELECT
			[ActivityLog].[ActivityLogId],
			[AssetSchedule].[AssetId]
			FROM [IICS].[ActivityLog]
				INNER JOIN [IICS].[StagedActivityLog]
					ON [ActivityLog].[FederatedId] = [StagedActivityLog].[FederatedId]
				LEFT OUTER JOIN
				(
					SELECT
						[AssetSchedule].[AssetId],
						[AssetSchedule].[ScheduleId],
						[Asset].[Name] AS [AssetName],
						[Asset_Schedule].[Name] AS [ScheduleName]
						FROM [IICS].[AssetSchedule]
							INNER JOIN [IICS].[Asset]
								ON [AssetSchedule].[AssetId] = [Asset].[AssetId]
							INNER JOIN [IICS].[Schedule]
								ON [AssetSchedule].[ScheduleId] = [Schedule].[ScheduleId]
							INNER JOIN [IICS].[Asset] AS [Asset_Schedule]
								ON [Schedule].[AssetId] = [Asset_Schedule].[AssetId]
				) AS [AssetSchedule]
					ON
						[StagedActivityLog].[ObjectName] = [AssetSchedule].[AssetName]
						AND [StagedActivityLog].[ScheduleName] = [AssetSchedule].[ScheduleName]
				LEFT OUTER JOIN [IICS].[ActivityLogAsset] AS [Target]
					ON [ActivityLog].[ActivityLogId] = [Target].[ActivityLogId]
			WHERE
				[Target].[ActivityLogAssetId] IS NULL
				AND [AssetSchedule].[AssetId] IS NOT NULL
	INSERT INTO [IICS].[ActivityLogSchedule]([ActivityLogId], [ScheduleId])
		SELECT
			[ActivityLog].[ActivityLogId],
			[AssetSchedule].[ScheduleId]
			FROM [IICS].[ActivityLog]
				INNER JOIN [IICS].[StagedActivityLog]
					ON [ActivityLog].[FederatedId] = [StagedActivityLog].[FederatedId]
				LEFT OUTER JOIN
				(
					SELECT
						[AssetSchedule].[AssetId],
						[AssetSchedule].[ScheduleId],
						[Asset].[Name] AS [AssetName],
						[Asset_Schedule].[Name] AS [ScheduleName]
						FROM [IICS].[AssetSchedule]
							INNER JOIN [IICS].[Asset]
								ON [AssetSchedule].[AssetId] = [Asset].[AssetId]
							INNER JOIN [IICS].[Schedule]
								ON [AssetSchedule].[ScheduleId] = [Schedule].[ScheduleId]
							INNER JOIN [IICS].[Asset] AS [Asset_Schedule]
								ON [Schedule].[AssetId] = [Asset_Schedule].[AssetId]
				) AS [AssetSchedule]
					ON
						[StagedActivityLog].[ObjectName] = [AssetSchedule].[AssetName]
						AND [StagedActivityLog].[ScheduleName] = [AssetSchedule].[ScheduleName]
				LEFT OUTER JOIN [IICS].[ActivityLogSchedule] AS [Target]
					ON [ActivityLog].[ActivityLogId] = [Target].[ActivityLogId]
			WHERE
				[Target].[ActivityLogScheduleId] IS NULL
				AND [AssetSchedule].[ScheduleId] IS NOT NULL
END
GO
--#endregion ParseActivityLogs

--#region RemoveOldActivityLogs
GO
CREATE OR ALTER PROCEDURE [IICS].[RemoveOldActivityLogs]
(
	@KeepLogsForDays [int] = 0
)
AS
BEGIN
	IF @KeepLogsForDays > 0
		BEGIN
			DECLARE @OlderThan [datetime2](7) = DATEADD([DAY], (-1)*@KeepLogsForDays, SYSUTCDATETIME())
			DECLARE @IdsToDelete TABLE ([ActivityLogId] [bigint])
			INSERT INTO @IdsToDelete ([ActivityLogId])
				SELECT [ActivityLog].[ActivityLogId]
				  FROM [IICS].[ActivityLog]
				  WHERE [ActivityLog].[StartTime] < @OlderThan
			DELETE
				FROM [IICS].[ActivityLogAsset]
				WHERE [ActivityLogId] IN (SELECT [ActivityLogId] FROM @IdsToDelete)
			DELETE
				FROM [IICS].[ActivityLogSchedule]
				WHERE [ActivityLogId] IN (SELECT [ActivityLogId] FROM @IdsToDelete)
			DELETE
				FROM [IICS].[ActivityLog]
				WHERE [ActivityLogId] IN (SELECT [ActivityLogId] FROM @IdsToDelete)
		END
END
GO
--#endregion RemoveOldActivityLogs

--#region ConnectionExpanded
GO
CREATE OR ALTER VIEW [IICS].[ConnectionExpanded]
AS
	SELECT
		[Asset].[FederatedId],
		[Connection].[Name],
		[Connection].[InstanceDisplayName],
		[Connection].[Type],
		[TypedConnection].[Database],
		NULL AS [Host],
		NULL AS [InstanceName],
		NULL AS [Port],
		NULL AS [ServiceUrl],
		NULL AS [Schema],
		[TypedConnection].[DateFormat],
		NULL AS [AuthenticationType],
		NULL AS [UserName],
		[Connection].[CreateTime],
		[Connection].[UpdateTime],
		[Connection].[CreatedBy],
		[Connection].[UpdatedBy]
		FROM [IICS].[Connection]
			INNER JOIN [IICS].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [IICS].[CSVFileConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
	UNION ALL SELECT
		[Asset].[FederatedId],
		[Connection].[Name],
		[Connection].[InstanceDisplayName],
		[Connection].[Type],
		[TypedConnection].[Database],
		NULL AS [Host],
		NULL AS [InstanceName],
		NULL AS [Port],
		NULL AS [ServiceUrl],
		NULL AS [Schema],
		NULL AS [DateFormat],
		NULL AS [AuthenticationType],
		[TypedConnection].[UserName],
		[Connection].[CreateTime],
		[Connection].[UpdateTime],
		[Connection].[CreatedBy],
		[Connection].[UpdatedBy]
		FROM [IICS].[Connection]
			INNER JOIN [IICS].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [IICS].[ODBCConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
	UNION ALL SELECT
		[Asset].[FederatedId],
		[Connection].[Name],
		[Connection].[InstanceDisplayName],
		[Connection].[Type],
		NULL AS [Database],
		NULL AS [Host],
		NULL AS [InstanceName],
		NULL AS [Port],
		[TypedConnection].[ServiceUrl],
		NULL AS [Schema],
		NULL AS [DateFormat],
		NULL AS [AuthenticationType],
		[TypedConnection].[UserName],
		[Connection].[CreateTime],
		[Connection].[UpdateTime],
		[Connection].[CreatedBy],
		[Connection].[UpdatedBy]
		FROM [IICS].[Connection]
			INNER JOIN [IICS].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [IICS].[SalesforceConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
	UNION ALL SELECT
		[Asset].[FederatedId],
		[Connection].[Name],
		[Connection].[InstanceDisplayName],
		[Connection].[Type],
		[TypedConnection].[Database],
		[TypedConnection].[Host],
		NULL AS [InstanceName],
		[TypedConnection].[Port],
		NULL AS [ServiceUrl],
		[TypedConnection].[Schema],
		NULL AS [DateFormat],
		[TypedConnection].[AuthenticationType],
		[TypedConnection].[UserName],
		[Connection].[CreateTime],
		[Connection].[UpdateTime],
		[Connection].[CreatedBy],
		[Connection].[UpdatedBy]
		FROM [IICS].[Connection]
			INNER JOIN [IICS].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [IICS].[SQLServerConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
	UNION ALL SELECT
		[Asset].[FederatedId],
		[Connection].[Name],
		[Connection].[InstanceDisplayName],
		[Connection].[Type],
		NULL AS [Database],
		NULL AS [Host],
		[TypedConnection].[InstanceName],
		NULL AS [Port],
		NULL AS [ServiceUrl],
		NULL AS [Schema],
		NULL AS [DateFormat],
		NULL AS [AuthenticationType],
		NULL AS [UserName],
		[Connection].[CreateTime],
		[Connection].[UpdateTime],
		[Connection].[CreatedBy],
		[Connection].[UpdatedBy]
		FROM [IICS].[Connection]
			INNER JOIN [IICS].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [IICS].[ToolkitCCIConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
	UNION ALL SELECT
		[Asset].[FederatedId],
		[Connection].[Name],
		[Connection].[InstanceDisplayName],
		[Connection].[Type],
		NULL AS [Database],
		NULL AS [Host],
		[TypedConnection].[InstanceName],
		NULL AS [Port],
		NULL AS [ServiceUrl],
		NULL AS [Schema],
		NULL AS [DateFormat],
		NULL AS [AuthenticationType],
		NULL AS [UserName],
		[Connection].[CreateTime],
		[Connection].[UpdateTime],
		[Connection].[CreatedBy],
		[Connection].[UpdatedBy]
		FROM [IICS].[Connection]
			INNER JOIN [IICS].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [IICS].[ToolkitConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
GO
--#endregion ConnectionExpanded

--#region ActivityLogExpanded
GO
CREATE OR ALTER VIEW [IICS].[ActivityLogExpanded]
AS
	SELECT
		[ActivityLog].[FederatedId],
		[ActivityLog].[RunId],

		[ActivityLogState].[Name] AS [ActivityLogState],
		[RunContextType].[Name] AS [RunContextType],

		[Asset].[Name] AS [Asset],
		[Asset].[Path] AS [AssetPath],
		[AssetType].[Name] AS [AssetType],
		[Schedule].[Name] AS [Schedule],

		[ActivityLog].[StartTime],
		[ActivityLog].[EndTime],
		[ActivityLog].[FailedSourceRows],
		[ActivityLog].[SuccessSourceRows],
		[ActivityLog].[FailedTargetRows],
		[ActivityLog].[SuccessTargetRows],
		[ActivityLog].[TotalSuccessRows],
		[ActivityLog].[TotalFailedRows],
		[ActivityLog].[StopOnError],
		[ActivityLog].[HasStopOnErrorRecord],
		[ActivityLog].[ErrorMessage],
		[ActivityLog].[Entries]
		FROM [IICS].[ActivityLog]
			INNER JOIN [IICS].[ActivityLogState]
				ON [ActivityLog].[ActivityLogStateId] = [ActivityLogState].[ActivityLogStateId]
			INNER JOIN [IICS].[RunContextType]
				ON [ActivityLog].[RunContextTypeId] = [RunContextType].[RunContextTypeId]
			LEFT OUTER JOIN [IICS].[ActivityLogAsset]
				ON [ActivityLog].[ActivityLogId] = [ActivityLogAsset].[ActivityLogId]
			LEFT OUTER JOIN [IICS].[Asset]
				ON [ActivityLogAsset].[AssetId] = [Asset].[AssetId]
			LEFT OUTER JOIN [IICS].[AssetType]
				ON [Asset].[AssetTypeId] = [AssetType].[AssetTypeId]
			LEFT OUTER JOIN [IICS].[ActivityLogSchedule]
				ON [ActivityLog].[ActivityLogId] = [ActivityLogSchedule].[ActivityLogId]
			LEFT OUTER JOIN [IICS].[Schedule]
				ON [ActivityLogSchedule].[ScheduleId] = [Schedule].[ScheduleId]
GO
--#endregion ActivityLogExpanded
