BEGIN
	DROP TABLE IF EXISTS [#Operation]
	SELECT DISTINCT [Content].[Type] AS [Name]
		INTO [#CustomSourceType]
		FROM [_SCHEMANAME_].[StagedAsset]
			INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
				ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
			CROSS APPLY OPENJSON([StagedAssetFile].[Content])
				WITH
				(
					[type] [nvarchar](25) N'$.type',
					[Query] [nvarchar](MAX) N'$.query'
				) AS [Content]
		WHERE [StagedAsset].[Type] = 'CustomSource'
	INSERT INTO [_SCHEMANAME_].[CustomSourceType]([Name])
		SELECT CAST([Source].[Name] AS [varchar](50)) AS [Name]
			FROM [#CustomSourceType] AS [Source]
				LEFT OUTER JOIN [_SCHEMANAME_].[CustomSourceType] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[CustomSourceTypeId] IS NULL
	DROP TABLE IF EXISTS [#CustomSourceType]

	DROP TABLE IF EXISTS [#CustomSource]
	SELECT
		[StagedAsset].[FederatedId],
		[Content].[Type] AS [Type],
		[Content].[Query] AS [Query]
		INTO [#CustomSource]
		FROM [_SCHEMANAME_].[StagedAsset]
			INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
				ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
			CROSS APPLY OPENJSON([StagedAssetFile].[Content])
				WITH
				(
					[type] [nvarchar](25) N'$.type',
					[Query] [nvarchar](MAX) N'$.query'
				) AS [Content]
		WHERE [StagedAsset].[Type] = 'CustomSource'
	INSERT INTO [_SCHEMANAME_].[CustomSource]
		SELECT
			[Asset].[AssetId],
			[CustomSourceType].[CustomSourceTypeId],
			[Source].[Query]
			FROM [#CustomSource] AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[CustomSourceType]
					ON [Source].[Type] = [CustomSourceType].[Name]
	DROP TABLE IF EXISTS [#CustomSource]
END
