BEGIN
	INSERT INTO [_SCHEMANAME_].[WorkflowTask]
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
							FROM [_SCHEMANAME_].[StagedAsset] AS [StagedAsset_workflow]
								INNER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_workflow]
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
						LEFT OUTER JOIN [_SCHEMANAME_].[StagedAsset] AS [StagedAsset_Task]
							ON
								CASE
									WHEN LEFT([StagedAsset_workflow].[taskId], 1) = '@'
										THEN RIGHT([StagedAsset_workflow].[taskId], (LEN([StagedAsset_workflow].[taskId]) - 1))
									ELSE [StagedAsset_workflow].[taskId]
								END = [StagedAsset_Task].[FederatedId]
					WHERE [StagedAsset_Task].[FederatedId] IS NOT NULL
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_Workflow]
					ON [Source].[WorkflowFederatedId] = [Asset_Workflow].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_Task]
					ON [Source].[TaskFederatedId] = [Asset_Task].[FederatedId]
END
