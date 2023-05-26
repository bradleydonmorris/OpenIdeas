BEGIN
	INSERT INTO [_SCHEMANAME_].[Mapping]
		SELECT [Asset].[AssetId]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId]
					FROM [_SCHEMANAME_].[StagedAsset]
					WHERE [StagedAsset].[Type] = 'DTEMPLATE'
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
	INSERT INTO [_SCHEMANAME_].[MappingTransformationProperty]
		SELECT
			[Mapping].[MappingId],
			[Source].[TransformationName],
			[Source].[PropertyName],
			[Source].[Value]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[transformations].[Name] AS [TransformationName],
					[advancedProperties].[Name] AS [PropertyName],
					NULLIF([advancedProperties].[Value], N'') AS [Value]
					FROM [_SCHEMANAME_].[StagedAsset]
						LEFT OUTER JOIN [_SCHEMANAME_].[StagedAssetFile] AS [StagedAssetFile_MappingBIN]
							ON
								[StagedAsset].[FederatedId] = [StagedAssetFile_MappingBIN].[FederatedId]
								AND 'bin' = [StagedAssetFile_MappingBIN].[FileType]
								AND 1 = ISJSON([StagedAssetFile_MappingBIN].[Content])
						OUTER APPLY OPENJSON([StagedAssetFile_MappingBIN].[Content], N'$.content')
							WITH
							(
								[transformationsJSON] [nvarchar](MAX) N'$.transformations' AS JSON
							) AS [Content_MappingBIN]
						OUTER APPLY OPENJSON([Content_MappingBIN].[transformationsJSON])
							WITH
							(
								[Name] [nvarchar](100) N'$.name',
								[advancedPropertiesJSON] [nvarchar](MAX) N'$.advancedProperties' AS JSON
							) AS [transformations]
						OUTER APPLY OPENJSON([transformations].[advancedPropertiesJSON])
							WITH
							(
								[Name] [nvarchar](100) N'$.name',
								[Value] [nvarchar](MAX) N'$.value'
							) AS [advancedProperties]
					WHERE
						[StagedAsset].[Type] = 'DTEMPLATE'
						AND NULLIF([transformations].[Name], N'') IS NOT NULL
						AND NULLIF([advancedProperties].[Name], N'') IS NOT NULL
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Mapping]
					ON [Asset].[AssetId] = [Mapping].[AssetId]
END
