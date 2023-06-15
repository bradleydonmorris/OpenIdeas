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
		FROM [_SCHEMANAME_].[ActivityLog]
			INNER JOIN [_SCHEMANAME_].[ActivityLogState]
				ON [ActivityLog].[ActivityLogStateId] = [ActivityLogState].[ActivityLogStateId]
			INNER JOIN [_SCHEMANAME_].[RunContextType]
				ON [ActivityLog].[RunContextTypeId] = [RunContextType].[RunContextTypeId]
			LEFT OUTER JOIN [_SCHEMANAME_].[ActivityLogAsset]
				ON [ActivityLog].[ActivityLogId] = [ActivityLogAsset].[ActivityLogId]
			LEFT OUTER JOIN [_SCHEMANAME_].[Asset]
				ON [ActivityLogAsset].[AssetId] = [Asset].[AssetId]
			LEFT OUTER JOIN [_SCHEMANAME_].[AssetType]
				ON [Asset].[AssetTypeId] = [AssetType].[AssetTypeId]
			LEFT OUTER JOIN [_SCHEMANAME_].[ActivityLogSchedule]
				ON [ActivityLog].[ActivityLogId] = [ActivityLogSchedule].[ActivityLogId]
			LEFT OUTER JOIN [_SCHEMANAME_].[Schedule]
				ON [ActivityLogSchedule].[ScheduleId] = [Schedule].[ScheduleId]
