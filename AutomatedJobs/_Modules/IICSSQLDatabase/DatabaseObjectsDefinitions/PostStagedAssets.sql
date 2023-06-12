BEGIN
	INSERT INTO [_SCHEMANAME_].[StagedAsset]([FederatedId], [Name], [Type], [Path])
		SELECT DISTINCT
			[Source].[FederatedId],
			[Source].[Name],
			[Source].[Type],
			[Source].[Path]
			FROM OPENJSON(@JSON)
				WITH
				(
					[FederatedId] [varchar](50) N'$.FederatedId',
					[Name] [nvarchar](400) N'$.Name',
					[Type] [varchar](20) N'$.Type',
					[Path] [nvarchar](400) N'$.Path'
				) AS [Source]
	UPDATE [_SCHEMANAME_].[StagedAsset]
		SET [AssetGUID] = [Source].[AssetGUID]
		FROM [_SCHEMANAME_].[StagedAsset]
			INNER JOIN
			(
				SELECT
					[Target].[FederatedId],
					[exportedObjectsJSON].[AssetGUID] AS [AssetGUID]
					FROM [_SCHEMANAME_].[StagedAsset] AS [StagedAsset_ExportMetadata]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_ExportMetadata]
							ON [StagedAsset_ExportMetadata].[FederatedId] = [StagedAssetFile_ExportMetadata].[FederatedId]
						OUTER APPLY OPENJSON([StagedAssetFile_ExportMetadata].[Content], N'$.exportedObjects')
							WITH
							(
								[AssetGuid] [varchar](50) N'$.objectGuid',
								[Name] [nvarchar](400) N'$.objectName',
								[Type] [varchar](20) N'$.objectType',
								[Path] [nvarchar](400) N'$.path'
							) AS [exportedObjectsJSON]
						LEFT OUTER JOIN [_SCHEMANAME_].[StagedAsset] AS [Target]
							ON
								[exportedObjectsJSON].[Name] = [Target].[Name]
								AND [exportedObjectsJSON].[Type] = [Target].[Type]
								AND [exportedObjectsJSON].[Path] = [Target].[Path]
					WHERE
						[StagedAsset_ExportMetadata].[Name] = 'ExportMetadata'
						AND [StagedAsset_ExportMetadata].[Type] = 'ExportMetadata'
						AND [StagedAsset_ExportMetadata].[Path] = 'System'
			) AS [Source]
				ON [StagedAsset].[FederatedId] = [Source].[FederatedId]
END
