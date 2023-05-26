BEGIN
	INSERT INTO [_SCHEMANAME_].[MappingTask]
		SELECT
			[Asset].[AssetId],
			[Mapping].[MappingId]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Content].[MappingFederatedId], 1) = '@'
							THEN RIGHT([Content].[MappingFederatedId], (LEN([Content].[MappingFederatedId]) - 1))
						ELSE [Content].[MappingFederatedId]
					END AS [MappingFederatedId],
					[StagedAssetFile].[Content]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[MappingFederatedId] [varchar](50) N'$.mappingId'
							) AS [Content]
					WHERE [StagedAsset].[Type] = 'MTT'
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_Mapping]
					ON [Source].[MappingFederatedId] = [Asset_Mapping].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Mapping]
					ON [Asset_Mapping].[AssetId] = [Mapping].[AssetId]
	INSERT INTO [_SCHEMANAME_].[MappingTaskExtendedSourceParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Connection].[ConnectionId],
			[Source].[Name],
			[Source].[Label],
			[Source].[ObjectName],
			[Source].[ObjectLabel]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Label] AS [Label],
					CASE
						WHEN LEFT([Paramter].[SourceFederatedConnectionId], 1) = '@'
							THEN RIGHT([Paramter].[SourceFederatedConnectionId], (LEN([Paramter].[SourceFederatedConnectionId]) - 1))
						ELSE [Paramter].[SourceFederatedConnectionId]
					END AS [SourceFederatedConnectionId],
					[Paramter].[ObjectName] AS [ObjectName],
					[Paramter].[ObjectLabel] AS [ObjectLabel]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Label] [varchar](100) N'$.label',
								[SourceFederatedConnectionId] [varchar](50) N'$.sourceConnectionId',
								[ObjectName] [nvarchar](400) N'$.extendedObject.object.name',
								[ObjectLabel] [nvarchar](400) N'$.extendedObject.object.label'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'EXTENDED_SOURCE'
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_SourceConnection]
					ON [Source].[SourceFederatedConnectionId] = [Asset_SourceConnection].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset_SourceConnection].[AssetId] = [Connection].[AssetId]
	INSERT INTO [_SCHEMANAME_].[MappingTaskSourceParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Connection].[ConnectionId],
			[Source].[Name],
			[Source].[Label],
			[Source].[CustomQuery]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Label] AS [Label],
					CASE
						WHEN LEFT([Paramter].[SourceFederatedConnectionId], 1) = '@'
							THEN RIGHT([Paramter].[SourceFederatedConnectionId], (LEN([Paramter].[SourceFederatedConnectionId]) - 1))
						ELSE [Paramter].[SourceFederatedConnectionId]
					END AS [SourceFederatedConnectionId],
					[Paramter].[CustomQuery] AS [CustomQuery]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Label] [varchar](100) N'$.label',
								[SourceFederatedConnectionId] [varchar](50) N'$.sourceConnectionId',
								[CustomQuery] [nvarchar](MAX) N'$.customQuery'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'SOURCE'
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_SourceConnection]
					ON [Source].[SourceFederatedConnectionId] = [Asset_SourceConnection].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset_SourceConnection].[AssetId] = [Connection].[AssetId]
	INSERT INTO [_SCHEMANAME_].[MappingTaskStringParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Source].[Name],
			[Source].[Text],
			[Source].[Label],
			[Source].[Description]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Text] AS [Text],
					[Paramter].[Label] AS [Label],
					[Paramter].[Description] AS [Description]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Text] [varchar](100) N'$.text',
								[Label] [varchar](100) N'$.label',
								[Description] [varchar](MAX) N'$.description'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'STRING'
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
	INSERT INTO [_SCHEMANAME_].[MappingTaskTargetParameter]
		SELECT
			[MappingTask].[MappingTaskId],
			[Connection].[ConnectionId],
			[Source].[Name],
			[Source].[Label],
			[Source].[ObjectName],
			[Source].[ObjectLabel],
			[Source].[TruncateTarget]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Paramter].[Name] AS [Name],
					[Paramter].[Label] AS [Label],
					CASE
						WHEN LEFT([Paramter].[TargetFederatedConnectionId], 1) = '@'
							THEN RIGHT([Paramter].[TargetFederatedConnectionId], (LEN([Paramter].[TargetFederatedConnectionId]) - 1))
						ELSE [Paramter].[TargetFederatedConnectionId]
					END AS [TargetFederatedConnectionId],
					[Paramter].[ObjectName] AS [ObjectName],
					[Paramter].[ObjectLabel] AS [ObjectLabel],
					[Paramter].[TruncateTarget] AS [TruncateTarget]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[Paramters] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Content]
						CROSS APPLY OPENJSON([Content].[Paramters])
							WITH
							(
								[Name] [varchar](100) N'$.name',
								[Type] [varchar](100) N'$.type',
								[Label] [varchar](100) N'$.label',
								[TargetFederatedConnectionId] [varchar](50) N'$.targetConnectionId',
								[ObjectName] [nvarchar](400) N'$.objectName',
								[ObjectLabel] [nvarchar](400) N'$.objectLabel',
								[TruncateTarget] [bit] N'$.truncateTarget'
							) AS [Paramter]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [Paramter].[Type] = 'TARGET'
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[MappingTask]
					ON [Asset].[AssetId] = [MappingTask].[AssetId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_TargetConnection]
					ON [Source].[TargetFederatedConnectionId] = [Asset_TargetConnection].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset_TargetConnection].[AssetId] = [Connection].[AssetId]
END
