BEGIN
	DROP TABLE IF EXISTS [#Operation]
	SELECT DISTINCT [Content].[Operation] AS [Name]
		INTO [#Operation]
		FROM [_SCHEMANAME_].[StagedAsset]
			INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
				ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
			CROSS APPLY OPENJSON([StagedAssetFile].[Content])
				WITH
				(
					[Operation] [varchar](50) N'$.operation'
				) AS [Content]
		WHERE [StagedAsset].[Type] = 'DSS'
	INSERT INTO [_SCHEMANAME_].[Operation]([Name])
		SELECT CAST([Source].[Name] AS [varchar](50)) AS [Name]
			FROM [#Operation] AS [Source]
				LEFT OUTER JOIN [_SCHEMANAME_].[Operation] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[OperationId] IS NULL
	DROP TABLE IF EXISTS [#Operation]
	INSERT INTO [_SCHEMANAME_].[Synchronization]
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
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
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
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_TargetConnection]
					ON [Source].[TargetConnectionFederatedId] = [Asset_TargetConnection].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection] AS [Connection_Target]
					ON [Asset_TargetConnection].[AssetId] = [Connection_Target].[AssetId]
				INNER JOIN [_SCHEMANAME_].[Operation]
					ON [Source].[Operation] = [Operation].[Name]
	INSERT INTO [_SCHEMANAME_].[SynchronizationSource]
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
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
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
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Synchronization]
					ON [Asset].[AssetId] = [Synchronization].[AssetId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_SourceConnection]
					ON [Source].[SourceConnectionFederatedId] = [Asset_SourceConnection].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection] AS [Connection_Source]
					ON [Asset_SourceConnection].[AssetId] = [Connection_Source].[AssetId]
	INSERT INTO [_SCHEMANAME_].[SynchronizationFilter]
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
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
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
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Synchronization]
					ON [Asset].[AssetId] = [Synchronization].[AssetId]
END
