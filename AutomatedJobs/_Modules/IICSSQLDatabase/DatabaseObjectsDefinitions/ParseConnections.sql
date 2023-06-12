BEGIN
	INSERT INTO [_SCHEMANAME_].[Connection]
		SELECT
			[Asset].[AssetId],
			[Content].[Type] AS [Type],
			[Content].[Name] AS [Name],
			[Content].[InstanceDisplayName] AS [InstanceDisplayName],
			[Content].[CreateTime] AS [CreateTime],
			[Content].[UpdateTime] AS [UpdateTime],
			[Content].[CreatedBy] AS [CreatedBy],
			[Content].[UpdatedBy] AS [UpdatedBy]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Name] [nvarchar](400) N'$.name',
						[InstanceDisplayName] [nvarchar](400) N'$.instanceDisplayName',
						[CreateTime] [datetime2](7) N'$.createTime',
						[UpdateTime] [datetime2](7) N'$.updateTime',
						[CreatedBy] [varchar](320) N'$.createdBy',
						[UpdatedBy] [varchar](320) N'$.updatedBy'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
			WHERE [StagedAsset].[FederatedId] = 'System.Connection'
	INSERT INTO [_SCHEMANAME_].[SQLServerConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[Host] AS [Host],
			[Content].[Port] AS [Port],
			[Content].[Database] AS [Database],
			[Content].[AuthenticationType] AS [AuthenticationType],
			[Content].[Schema] AS [Schema],
			[Content].[UserName] AS [UserName]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Host] [nvarchar](400) N'$.host',
						[Port] [int] N'$.port',
						[Database] [nvarchar](400) N'$.database',
						[AuthenticationType] [nvarchar](400) N'$.authenticationType',
						[Schema] [nvarchar](400) N'$.schema',
						[UserName] [nvarchar](400) N'$.username'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] LIKE N'SqlServer%'
	INSERT INTO [_SCHEMANAME_].[CSVFileConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[Database] AS [Database],
			[Content].[DateFormat] AS [DateFormat]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Database] [nvarchar](400) N'$.database',
						[DateFormat] [nvarchar](400) N'$.dateFormat'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'CSVFile'
	INSERT INTO [_SCHEMANAME_].[SalesforceConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[ServiceUrl] AS [ServiceUrl],
			[Content].[UserName] AS [UserName]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[ServiceUrl] [nvarchar](400) N'$.serviceUrl',
						[UserName] [varchar](320) N'$.username'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'Salesforce'
	INSERT INTO [_SCHEMANAME_].[ODBCConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[Database] AS [Database],
			[Content].[UserName] AS [UserName]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Database] [nvarchar](400) N'$.database',
						[UserName] [varchar](320) N'$.username'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'ODBC'
	INSERT INTO [_SCHEMANAME_].[ToolkitConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[InstanceName] AS [InstanceName]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[InstanceName] [varchar](320) N'$.instanceName'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'TOOLKIT'
	INSERT INTO [_SCHEMANAME_].[ToolkitCCIConnection]
		SELECT
			[Connection].[ConnectionId],
			[Content].[InstanceName] AS [InstanceName]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[InstanceName] [varchar](320) N'$.instanceName'
					) AS [Content]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [Content].[Type] = N'TOOLKIT_CCI'
	INSERT INTO [_SCHEMANAME_].[ConnectionProperty]
		SELECT
			[Connection].[ConnectionId],
			CONVERT([nvarchar](100), [PropertyPivot].[Name], 0) AS [Name],
			CONVERT([nvarchar](400), [PropertyPivot].[Value], 0) AS [Value]
			FROM [_SCHEMANAME_].[StagedAsset]
				INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
					ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
				CROSS APPLY OPENJSON([StagedAssetFile].[Content])
					WITH
					(
						[FederatedId] [varchar](50) N'$.federatedId',
						[Type] [nvarchar](50) N'$.type',
						[Name] [nvarchar](400) N'$.name',
						[Description] [nvarchar](400) N'$.description',
						[InstanceDisplayName] [nvarchar](400) N'$.instanceDisplayName',
						[Host] [nvarchar](400) N'$.host',
						[Port] [int] N'$.port',
						[Database] [nvarchar](400) N'$.database',
						[AuthenticationType] [nvarchar](400) N'$.authenticationType',
						[Schema] [nvarchar](400) N'$.schema',
						[UserName] [nvarchar](400) N'$.username',
						[DateFormat] [nvarchar](400) N'$.dateFormat',
						[ServiceUrl] [nvarchar](400) N'$.serviceUrl',
						[InstanceName] [nvarchar](400) N'$.instanceName'
					) AS [Content]
				CROSS APPLY
				(
					SELECT N'Type' AS [Name], [Content].[Type] AS [Value]
					UNION ALL SELECT N'Name' AS [Name], [Content].[Name] AS [Value]
					UNION ALL SELECT N'Description' AS [Name], [Content].[Description] AS [Value]
					UNION ALL SELECT N'InstanceDisplayName' AS [Name], [Content].[InstanceDisplayName] AS [Value]
					UNION ALL SELECT N'Database' AS [Name], [Content].[Database] AS [Value]
					UNION ALL SELECT N'Host' AS [Name], [Content].[Host] AS [Value]
					UNION ALL SELECT N'Port' AS [Name], FORMAT([Content].[Port], N'0') AS [Value]
					UNION ALL SELECT N'AuthenticationType' AS [Name], [Content].[AuthenticationType] AS [Value]
					UNION ALL SELECT N'Schema' AS [Name], [Content].[Schema] AS [Value]
					UNION ALL SELECT N'UserName' AS [Name], [Content].[UserName] AS [Value]
					UNION ALL SELECT N'DateFormat' AS [Name], [Content].[DateFormat] AS [Value]
					UNION ALL SELECT N'ServiceUrl' AS [Name], [Content].[ServiceUrl] AS [Value]
					UNION ALL SELECT N'InstanceName' AS [Name], [Content].[InstanceName] AS [Value]
				) AS [PropertyPivot]
				INNER JOIN [_SCHEMANAME_].[Asset]
					ON [Content].[FederatedId] = [Asset].[FederatedId]
				INNER JOIN [_SCHEMANAME_].[Connection]
					ON [Asset].[AssetId] = [Connection].[AssetId]
			WHERE
				[StagedAsset].[FederatedId] = 'System.Connection'
				AND [PropertyPivot].[Value] IS NOT NULL
END
