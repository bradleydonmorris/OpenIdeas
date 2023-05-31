BEGIN
	INSERT INTO [_SCHEMANAME_].[ActivityLog]
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
			FROM [_SCHEMANAME_].[StagedActivityLog]
				INNER JOIN [_SCHEMANAME_].[RunContextType]
					ON [StagedActivityLog].[RunContextTypeCode] = [RunContextType].[Code]
				INNER JOIN [_SCHEMANAME_].[ActivityLogState]
					ON [StagedActivityLog].[ActivityStateCode] = [ActivityLogState].[Code]
				LEFT OUTER JOIN [_SCHEMANAME_].[ActivityLog] AS [Target]
					ON [StagedActivityLog].[FederatedId] = [Target].[FederatedId]
			WHERE [Target].[ActivityLogId] IS NULL
	INSERT INTO [_SCHEMANAME_].[ActivityLogAsset]([ActivityLogId], [AssetId])
		SELECT
			[ActivityLog].[ActivityLogId],
			[AssetSchedule].[AssetId]
			FROM [_SCHEMANAME_].[ActivityLog]
				INNER JOIN [_SCHEMANAME_].[StagedActivityLog]
					ON [ActivityLog].[FederatedId] = [StagedActivityLog].[FederatedId]
				LEFT OUTER JOIN
				(
					SELECT
						[AssetSchedule].[AssetId],
						[AssetSchedule].[ScheduleId],
						[Asset].[Name] AS [AssetName],
						[Asset_Schedule].[Name] AS [ScheduleName]
						FROM [_SCHEMANAME_].[AssetSchedule]
							INNER JOIN [_SCHEMANAME_].[Asset]
								ON [AssetSchedule].[AssetId] = [Asset].[AssetId]
							INNER JOIN [_SCHEMANAME_].[Schedule]
								ON [AssetSchedule].[ScheduleId] = [Schedule].[ScheduleId]
							INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_Schedule]
								ON [Schedule].[AssetId] = [Asset_Schedule].[AssetId]
				) AS [AssetSchedule]
					ON
						[StagedActivityLog].[ObjectName] = [AssetSchedule].[AssetName]
						AND [StagedActivityLog].[ScheduleName] = [AssetSchedule].[ScheduleName]
				LEFT OUTER JOIN [_SCHEMANAME_].[ActivityLogAsset] AS [Target]
					ON [ActivityLog].[ActivityLogId] = [Target].[ActivityLogId]
			WHERE
				[Target].[ActivityLogAssetId] IS NULL
				AND [AssetSchedule].[AssetId] IS NOT NULL
	INSERT INTO [_SCHEMANAME_].[ActivityLogSchedule]([ActivityLogId], [ScheduleId])
		SELECT
			[ActivityLog].[ActivityLogId],
			[AssetSchedule].[ScheduleId]
			FROM [_SCHEMANAME_].[ActivityLog]
				INNER JOIN [_SCHEMANAME_].[StagedActivityLog]
					ON [ActivityLog].[FederatedId] = [StagedActivityLog].[FederatedId]
				LEFT OUTER JOIN
				(
					SELECT
						[AssetSchedule].[AssetId],
						[AssetSchedule].[ScheduleId],
						[Asset].[Name] AS [AssetName],
						[Asset_Schedule].[Name] AS [ScheduleName]
						FROM [_SCHEMANAME_].[AssetSchedule]
							INNER JOIN [_SCHEMANAME_].[Asset]
								ON [AssetSchedule].[AssetId] = [Asset].[AssetId]
							INNER JOIN [_SCHEMANAME_].[Schedule]
								ON [AssetSchedule].[ScheduleId] = [Schedule].[ScheduleId]
							INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_Schedule]
								ON [Schedule].[AssetId] = [Asset_Schedule].[AssetId]
				) AS [AssetSchedule]
					ON
						[StagedActivityLog].[ObjectName] = [AssetSchedule].[AssetName]
						AND [StagedActivityLog].[ScheduleName] = [AssetSchedule].[ScheduleName]
				LEFT OUTER JOIN [_SCHEMANAME_].[ActivityLogSchedule] AS [Target]
					ON [ActivityLog].[ActivityLogId] = [Target].[ActivityLogId]
			WHERE
				[Target].[ActivityLogScheduleId] IS NULL
				AND [AssetSchedule].[ScheduleId] IS NOT NULL
END
