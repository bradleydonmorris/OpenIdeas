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
		FROM [_SCHEMANAME_].[Connection]
			INNER JOIN [_SCHEMANAME_].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [_SCHEMANAME_].[CSVFileConnection] AS [TypedConnection]
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
		FROM [_SCHEMANAME_].[Connection]
			INNER JOIN [_SCHEMANAME_].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [_SCHEMANAME_].[ODBCConnection] AS [TypedConnection]
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
		FROM [_SCHEMANAME_].[Connection]
			INNER JOIN [_SCHEMANAME_].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [_SCHEMANAME_].[SalesforceConnection] AS [TypedConnection]
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
		FROM [_SCHEMANAME_].[Connection]
			INNER JOIN [_SCHEMANAME_].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [_SCHEMANAME_].[SQLServerConnection] AS [TypedConnection]
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
		FROM [_SCHEMANAME_].[Connection]
			INNER JOIN [_SCHEMANAME_].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [_SCHEMANAME_].[ToolkitCCIConnection] AS [TypedConnection]
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
		FROM [_SCHEMANAME_].[Connection]
			INNER JOIN [_SCHEMANAME_].[Asset]
				ON [Connection].[AssetId] = [Asset].[AssetId]
			INNER JOIN [_SCHEMANAME_].[ToolkitConnection] AS [TypedConnection]
				ON [Connection].[ConnectionId] = [TypedConnection].[ConnectionId]
