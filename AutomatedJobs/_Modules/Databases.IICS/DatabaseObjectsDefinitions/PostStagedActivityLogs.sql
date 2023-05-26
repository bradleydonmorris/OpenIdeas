BEGIN
	INSERT INTO [_SCHEMANAME_].[StagedActivityLog]
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
