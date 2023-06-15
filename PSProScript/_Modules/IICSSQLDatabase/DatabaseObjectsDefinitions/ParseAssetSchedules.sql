BEGIN
	INSERT INTO [_SCHEMANAME_].[AssetSchedule]
		SELECT DISTINCT
			[Asset].[AssetId],
			[Schedule].[ScheduleId]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[scheduleJSON].[name] AS [ScheduleName]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_mtTask]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_mtTask].[FederatedId]
								AND 'mtTask.json' = [StagedAssetFile_mtTask].[FileName]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_schedule]
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
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_workflow]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_workflow].[FederatedId]
								AND 'workflow.json' = [StagedAssetFile_workflow].[FileName]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_schedule]
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
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Schedule]
					ON [Source].[ScheduleName] = [Schedule].[Name]
END
