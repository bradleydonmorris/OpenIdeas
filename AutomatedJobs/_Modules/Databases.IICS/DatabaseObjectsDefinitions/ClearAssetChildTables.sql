BEGIN
	TRUNCATE TABLE [_SCHEMANAME_].[CustomSource]
	TRUNCATE TABLE [_SCHEMANAME_].[WorkflowTask]

	TRUNCATE TABLE [_SCHEMANAME_].[SynchronizationFilter]
	TRUNCATE TABLE [_SCHEMANAME_].[SynchronizationSource]
	DELETE FROM [_SCHEMANAME_].[Synchronization]
	DBCC CHECKIDENT (N'[_SCHEMANAME_].[Synchronization]', RESEED, 0);

	TRUNCATE TABLE [_SCHEMANAME_].[MappingTaskExtendedSourceParameter]
	TRUNCATE TABLE [_SCHEMANAME_].[MappingTaskSourceParameter]
	TRUNCATE TABLE [_SCHEMANAME_].[MappingTaskStringParameter]
	TRUNCATE TABLE [_SCHEMANAME_].[MappingTaskTargetParameter]
	DELETE FROM [_SCHEMANAME_].[MappingTask]
	DBCC CHECKIDENT (N'[_SCHEMANAME_].[MappingTask]', RESEED, 0);

	TRUNCATE TABLE [_SCHEMANAME_].[MappingTransformationProperty]
	DELETE FROM [_SCHEMANAME_].[Mapping]
	DBCC CHECKIDENT (N'[_SCHEMANAME_].[Mapping]', RESEED, 0);

	TRUNCATE TABLE [_SCHEMANAME_].[AssetConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[SQLServerConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[CSVFileConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[SalesforceConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[ODBCConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[ToolkitConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[ToolkitCCIConnection]
	TRUNCATE TABLE [_SCHEMANAME_].[ConnectionProperty]
	DELETE FROM [_SCHEMANAME_].[Connection]
	DBCC CHECKIDENT (N'[_SCHEMANAME_].[Connection]', RESEED, 0);

	TRUNCATE TABLE [_SCHEMANAME_].[AssetSchedule]

	--TRUNCATE TABLE [_SCHEMANAME_].[ActivityLogSchedule]
	--DELETE FROM [_SCHEMANAME_].[Schedule]
	--DBCC CHECKIDENT (N'[_SCHEMANAME_].[Schedule]', RESEED, 0);
	
	--TRUNCATE TABLE [_SCHEMANAME_].[ActivityLogAsset]
	--DELETE FROM [_SCHEMANAME_].[Asset]
	--DBCC CHECKIDENT (N'[_SCHEMANAME_].[Asset]', RESEED, 0);
	
	--DELETE FROM [_SCHEMANAME_].[ActivityLog]
	--DBCC CHECKIDENT (N'[_SCHEMANAME_].[Asset]', RESEED, 0);
END
