CREATE OR ALTER PROCEDURE [Logging].[ImportLog]
(
	@LogJSON [nvarchar](MAX)
)
AS
BEGIN
	DECLARE @LogGUID [uniqueidentifier]
	DECLARE @OpenLogTime [datetime2](7)
	DECLARE @CloseLogTime [datetime2](7)
	DECLARE @Project [nvarchar](50)
	DECLARE @Script [nvarchar](50)
	DECLARE @Host [nvarchar](50)
	DECLARE @ScriptFilePath [nvarchar](400)

	DECLARE @ProjectId [int]
	DECLARE @ScriptId [int]
	DECLARE @InvocationId [int]
	DECLARE @LogId [int]

	SELECT
		@LogGUID = [Entry].[LogGUID],
		@OpenLogTime = [Entry].[OpenLogTime],
		@CloseLogTime = [Entry].[CloseLogTime],
		@Project = [Entry].[Project],
		@Script = [Entry].[Script],
		@Host = [Entry].[Host],
		@ScriptFilePath = [Entry].[ScriptFilePath]
		FROM OPENJSON(@LogJSON, N'$.Log')
			WITH
			(
				[LogGUID] [uniqueidentifier] N'$.LogGUID',
				[OpenLogTime] [datetime2](7) N'$.OpenLogTime',
				[CloseLogTime] [datetime2](7) N'$.CloseLogTime',
				[Project] [nvarchar](50) N'$.Project',
				[Script] [nvarchar](50) N'$.Script',
				[Host] [nvarchar](50) N'$.Host',
				[ScriptFilePath] [nvarchar](400) N'$.ScriptFilePath'
			) AS [Entry]
	SELECT @ProjectId = [Project].[ProjectId]
		FROM [Logging].[Project]
		WHERE [Project].[Name] = @Project
	IF @ProjectId IS NULL
		BEGIN
			INSERT INTO [Logging].[Project]([Name])
				VALUES(@Project)
			SET @ProjectId = SCOPE_IDENTITY()
		END
	SELECT @ScriptId = [Script].[ScriptId]
		FROM [Logging].[Script]
		WHERE
			[Script].[ProjectId] = @ProjectId
			AND [Script].[Name] = @Script
	IF @ScriptId IS NULL
		BEGIN
			INSERT INTO [Logging].[Script]([ProjectId], [Name])
				VALUES(@ProjectId, @Script)
			SET @ScriptId = SCOPE_IDENTITY()
		END
	SELECT @InvocationId = [Invocation].[InvocationId]
		FROM [Logging].[Invocation]
		WHERE
			[Invocation].[ScriptId] = @ScriptId
			AND [Invocation].[Host] = @Host
			AND [Invocation].[ScriptFilePath] = @ScriptFilePath
	IF @InvocationId IS NULL
		BEGIN
			INSERT INTO [Logging].[Invocation]([ScriptId], [Host], [ScriptFilePath])
				VALUES(@ScriptId, @Host, @ScriptFilePath)
			SET @InvocationId = SCOPE_IDENTITY()
		END
	SELECT @LogId = [Log].[LogId]
		FROM [Logging].[Log]
		WHERE
			[Log].[InvocationId] = @InvocationId
			AND [Log].[LogGUID] = @LogGUID
	IF @LogId IS NULL
		BEGIN
			INSERT INTO [Logging].[Log]([InvocationId], [LogGUID], [OpenLogTime], [CloseLogTime])
				VALUES(@InvocationId, @LogGUID, @OpenLogTime, @CloseLogTime)
			SET @LogId = SCOPE_IDENTITY()
		END
	INSERT INTO [Logging].[Level]([Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				SELECT [Level].[Name]
					FROM OPENJSON(@LogJSON, N'$.Entries')
						WITH
						(
							[Name] [nvarchar](30) N'$.Level'
						) AS [Level]
			) [Source]([Name])
				LEFT OUTER JOIN [Logging].[Level] AS [Target] 
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[LevelId] IS NULL
	INSERT INTO [Logging].[Entry]([LogId], [LevelId], [Number], [EntryTime], [Text])
		SELECT
			@LogId AS [LogId],
			[Level].[LevelId],
			[Source].[Number],
			[Source].[EntryTime],
			[Source].[Text]
			FROM OPENJSON(@LogJSON, N'$.Entries')
				WITH
				(
					[Level] [nvarchar](30) N'$.Level',
					[Number] [int] N'$.Number',
					[EntryTime] [datetime2](7) N'$.EntryTime',
					[Text] [nvarchar](MAX) N'$.Text'
				) AS [Source]
				INNER JOIN [Logging].[Level]
					ON [Source].[Level] = [Level].[Name]
				LEFT OUTER JOIN [Logging].[Entry] AS [Target]
					ON
						@LogId = [Target].[LogId]
						AND [Source].[Number] = [Target].[Number]
			WHERE [Target].[EntryId] IS NULL
	INSERT INTO [Logging].[Variable]([LogId], [Name], [Value])
		SELECT
			@LogId AS [LogId],
			[Source].[key] AS [Name],
			[Source].[value] AS [Value]
			FROM OPENJSON(@LogJSON, N'$.Variables') AS [Source]
				LEFT OUTER JOIN [Logging].[Variable] AS [Target]
					ON
						@LogId = [Target].[LogId]
						AND [Source].[key] COLLATE SQL_Latin1_General_CP1_CI_AS = [Target].[Name] COLLATE SQL_Latin1_General_CP1_CI_AS
			WHERE [Target].[VariableId] IS NULL
	INSERT INTO [Logging].[Timer]([LogId], [Sequence], [Name], [BeginTime], [EndTime], [ElapsedSeconds])
		SELECT
			@LogId AS [LogId],
			[Source].[Sequence],
			[Source].[Name],
			[Source].[BeginTime],
			[Source].[EndTime],
			[Source].[ElapsedSeconds]
			FROM OPENJSON(@LogJSON, N'$.Timers')
				WITH
				(
					[Sequence] [int] N'$.Sequence',
					[Name] [nvarchar](100) N'$.Name',
					[BeginTime] [datetime2](7) N'$.BeginTime',
					[EndTime] [datetime2](7) N'$.EndTime',
					[ElapsedSeconds] [float] N'$.ElapsedSeconds'
				) AS [Source]
				LEFT OUTER JOIN [Logging].[Timer] AS [Target]
					ON
						@LogId = [Target].[LogId]
						AND [Source].[Sequence] = [Target].[Sequence]
			WHERE [Target].[TimerId] IS NULL
END
