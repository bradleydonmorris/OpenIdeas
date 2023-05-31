BEGIN
	INSERT INTO [_SCHEMANAME_].[AssetConnection]
		SELECT DISTINCT
			[Asset].[AssetId],
			[Connection].[ConnectionId],
			[Source].[Use]
			FROM
			(
				SELECT
					[StagedAsset].[FederatedId],
					[Connection].[ConnectionFederatedId],
					[Connection].[Use]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						CROSS APPLY
						(
							SELECT
								'Source' AS [Use],
								CASE
									WHEN LEFT([Content].[FederatedId], 1) = '@'
										THEN RIGHT([Content].[FederatedId], (LEN([Content].[FederatedId]) - 1))
									ELSE [Content].[FederatedId]
								END AS [ConnectionFederatedId]
								FROM OPENJSON([StagedAssetFile].[Content])
									WITH([FederatedId] [varchar](50) N'$.sourceConnectionId') AS [Content]
							UNION
							SELECT
								'Target' AS [Use],
								CASE
									WHEN LEFT([Content].[FederatedId], 1) = '@'
										THEN RIGHT([Content].[FederatedId], (LEN([Content].[FederatedId]) - 1))
									ELSE [Content].[FederatedId]
								END AS [ConnectionFederatedId]
								FROM OPENJSON([StagedAssetFile].[Content])
									WITH([FederatedId] [varchar](50) N'$.targetConnectionId') AS [Content]
						) AS [Connection]
						WHERE
							[StagedAsset].[Type] = 'DSS'
							AND [StagedAssetFile].[FileName] = N'dssTask.json'
							AND [Connection].[ConnectionFederatedId] IS NOT NULL
				UNION ALL SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Connection].[ConnectionFederatedId], 1) = '@'
							THEN RIGHT([Connection].[ConnectionFederatedId], (LEN([Connection].[ConnectionFederatedId]) - 1))
						ELSE [Connection].[ConnectionFederatedId]
					END AS [ConnectionFederatedId],
					[Connection].[Use]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						OUTER APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[JSON] [nvarchar](MAX) N'$.parameters' AS JSON
							) AS [Parameters]
						OUTER APPLY OPENJSON([Parameters].[JSON])
							WITH
							(
								[SourceFederatedId] [varchar](50) N'$.sourceConnectionId',
								[TargetFederatedId] [varchar](50) N'$.targetConnectionId'
							) AS [Connections]
						OUTER APPLY
						(
							SELECT 'Source' AS [Use], [Connections].[SourceFederatedId] AS [ConnectionFederatedId]
							UNION ALL SELECT 'Target' AS [Use], [Connections].[TargetFederatedId] AS [ConnectionFederatedId]
						) AS [Connection]
					WHERE
						[StagedAsset].[Type] = 'MTT'
						AND [StagedAssetFile].[FileName] = N'mtTask.json'
						AND [Connection].[ConnectionFederatedId] IS NOT NULL
				UNION ALL SELECT
					[StagedAsset].[FederatedId],
					CASE
						WHEN LEFT([Connection].[ConnectionFederatedId], 1) = '@'
							THEN RIGHT([Connection].[ConnectionFederatedId], (LEN([Connection].[ConnectionFederatedId]) - 1))
						ELSE [Connection].[ConnectionFederatedId]
					END AS [ConnectionFederatedId],
					'Reference' AS [Use]
					FROM [_SCHEMANAME_].[StagedAsset]
						INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
							ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
						OUTER APPLY OPENJSON([StagedAssetFile].[Content])
							WITH
							(
								[JSON] [nvarchar](MAX) N'$.references' AS JSON
							) AS [References]
						OUTER APPLY OPENJSON([References].[JSON])
							WITH
							(
								[Type] [varchar](50) N'$.refType',
								[ConnectionFederatedId] [varchar](50) N'$.refObjectId'
							) AS [Connection]
					WHERE
						[StagedAsset].[Type] = 'DTEMPLATE'
						AND [StagedAssetFile].[FileName] = N'mappingTemplate.json'
						AND [Connection].[ConnectionFederatedId] IS NOT NULL
			) AS [Source]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Source].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Asset] AS [Asset_Connection]
					ON [Source].[ConnectionFederatedId] = [Asset_Connection].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset_Connection].[AssetId] = [Connection].[AssetId]
END
