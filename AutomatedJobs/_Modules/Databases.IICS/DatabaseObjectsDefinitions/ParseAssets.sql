BEGIN
	MERGE [_SCHEMANAME_].[Asset] AS [Target]
		USING
		(
			SELECT
				[AssetType].[AssetTypeId],
				[Source].[FederatedId],
				[Source].[AssetGuid],
				[Source].[Name],
				[Source].[Type],
				[Source].[Path],
				0 AS [IsRemoved]
				FROM
				(
					SELECT
						[StagedAsset].[FederatedId],
						[StagedAsset].[AssetGuid],
						[StagedAsset].[Name],
						[StagedAsset].[Type],
						[StagedAsset].[Path]
						FROM [_SCHEMANAME_].[StagedAsset]
						WHERE
							[StagedAsset].[Type] NOT IN
							(
								'Connection',
								'Schedule',
								'ExportMetadata'
							)
							OR [StagedAsset].[AssetGuid] IS NOT NULL
					UNION ALL SELECT
						[Content].[FederatedId] AS [FederatedId],
						NULL AS [AssetGuid],
						[Content].[Name] AS [Name],
						'Schedule' AS [Type],
						'/System/Schedules' AS [Path]
						FROM [_SCHEMANAME_].[StagedAsset]
							INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
								ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
							CROSS APPLY OPENJSON([StagedAssetFile].[Content], N'$.schedules')
								WITH
								(
									[FederatedId] [varchar](50) N'$.scheduleFederatedId',
									[Name] [nvarchar](400) N'$.name'
								) AS [Content]
						WHERE [StagedAsset].[FederatedId] = 'System.Schedule'
					UNION ALL SELECT
						[Content].[FederatedId] AS [FederatedId],
						NULL AS [AssetGuid],
						[Content].[Name] AS [Name],
						'Connection' AS [Type],
						'/System/Connections' AS [Path]
						FROM [_SCHEMANAME_].[StagedAsset]
							INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
								ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
							CROSS APPLY OPENJSON([StagedAssetFile].[Content])
								WITH
								(
									[FederatedId] [varchar](50) N'$.federatedId',
									[Name] [nvarchar](400) N'$.name'
								) AS [Content]
						WHERE [StagedAsset].[FederatedId] = 'System.Connection'
				) AS [Source]
					INNER JOIN [_SCHEMANAME_].[AssetType]
						ON [Source].[Type] = [AssetType].[Code]
		) AS [Source]
			ON [Target].[FederatedId] = [Source].[FederatedId]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([AssetTypeId], [FederatedId], [AssetGuid], [Name], [Type], [Path], [IsRemoved])
				VALUES ([Source].[AssetTypeId], [Source].[FederatedId], [Source].[AssetGuid], [Source].[Name], [Source].[Type], [Source].[Path], [Source].[IsRemoved])
		WHEN MATCHED THEN UPDATE SET
			[AssetTypeId] = [Source].[AssetTypeId],
			[AssetGuid] = [Source].[AssetGuid],
			[Name] = [Source].[Name],
			[Type] = [Source].[Type],
			[Path] = [Source].[Path],
			[IsRemoved] = [Source].[IsRemoved]
		WHEN NOT MATCHED BY SOURCE THEN UPDATE SET [IsRemoved] = 1
	;
END
