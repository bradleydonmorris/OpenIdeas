BEGIN
	EXEC [_SCHEMANAME_].[ClearAssetChildTables]
	EXEC [_SCHEMANAME_].[ParseAssets]
	EXEC [_SCHEMANAME_].[ParseConnections]
	EXEC [_SCHEMANAME_].[ParseSchedules]
	EXEC [_SCHEMANAME_].[ParseAssetConnections]
	EXEC [_SCHEMANAME_].[ParseAssetSchedules]
	EXEC [_SCHEMANAME_].[ParseWorkflowTasks]
	EXEC [_SCHEMANAME_].[ParseSynchronizationAssets]
	EXEC [_SCHEMANAME_].[ParseMappingAssets]
	EXEC [_SCHEMANAME_].[ParseMappingTaskAssets]
	EXEC [_SCHEMANAME_].[ParseCustomSourceAssets]
END
