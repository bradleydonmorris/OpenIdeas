	SELECT
		[Asset].[Name] AS [Asset],
		[Asset].[Path] AS [AssetPath],
		[AssetType].[Name] AS [AssetType],
		[TextSearch].[Attribute],
		[TextSearch].[Schema],
		[TextSearch].[Table],
		[TextSearch].[Column],
		[TextSearch].[Text]
		FROM
		(
			SELECT
				[CustomSource].[AssetId],
				N'Query' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'CustomSource' AS [Table],
				N'Query' AS [Column],
				[CustomSource].[Query] AS [Text]
				FROM [_SCHEMANAME_].[CustomSource]
			UNION ALL SELECT
				[MappingTask].[AssetId],
				N'CustomQuery' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTaskSourceParameter' AS [Table],
				N'CustomQuery' AS [Column],
				[MappingTaskSourceParameter].[CustomQuery] AS [Text]
				FROM [_SCHEMANAME_].[MappingTaskSourceParameter]
					INNER JOIN [_SCHEMANAME_].[MappingTask]
						ON [MappingTaskSourceParameter].[MappingTaskId] = [MappingTask].[MappingTaskId]
			UNION ALL SELECT
				[MappingTask].[AssetId],
				N'ObjectName' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTaskExtendedSourceParameter' AS [Table],
				N'ObjectName' AS [Column],
				[MappingTaskExtendedSourceParameter].[ObjectName] AS [Text]
				FROM [_SCHEMANAME_].[MappingTaskExtendedSourceParameter]
					INNER JOIN [_SCHEMANAME_].[MappingTask]
						ON [MappingTaskExtendedSourceParameter].[MappingTaskId] = [MappingTask].[MappingTaskId]
			UNION ALL SELECT
				[MappingTask].[AssetId],
				N'ObjectLabel' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTaskExtendedSourceParameter' AS [Table],
				N'ObjectLabel' AS [Column],
				[MappingTaskExtendedSourceParameter].[ObjectLabel] AS [Text]
				FROM [_SCHEMANAME_].[MappingTaskExtendedSourceParameter]
					INNER JOIN [_SCHEMANAME_].[MappingTask]
						ON [MappingTaskExtendedSourceParameter].[MappingTaskId] = [MappingTask].[MappingTaskId]
			UNION ALL SELECT
				[MappingTask].[AssetId],
				N'ObjectName' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTaskTargetParameter' AS [Table],
				N'ObjectName' AS [Column],
				[MappingTaskTargetParameter].[ObjectName] AS [Text]
				FROM [_SCHEMANAME_].[MappingTaskTargetParameter]
					INNER JOIN [_SCHEMANAME_].[MappingTask]
						ON [MappingTaskTargetParameter].[MappingTaskId] = [MappingTask].[MappingTaskId]
			UNION ALL SELECT
				[MappingTask].[AssetId],
				N'ObjectLabel' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTaskTargetParameter' AS [Table],
				N'ObjectLabel' AS [Column],
				[MappingTaskTargetParameter].[ObjectLabel] AS [Text]
				FROM [_SCHEMANAME_].[MappingTaskTargetParameter]
					INNER JOIN [_SCHEMANAME_].[MappingTask]
						ON [MappingTaskTargetParameter].[MappingTaskId] = [MappingTask].[MappingTaskId]
			UNION ALL SELECT
				[Mapping].[AssetId],
				N'TransformationName' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTransformationProperty' AS [Table],
				N'TransformationName' AS [Column],
				[MappingTransformationProperty].[TransformationName] AS [Text]
				FROM [_SCHEMANAME_].[MappingTransformationProperty]
					INNER JOIN [_SCHEMANAME_].[Mapping]
						ON [MappingTransformationProperty].[MappingId] = [Mapping].[MappingId]
			UNION ALL SELECT
				[Mapping].[AssetId],
				N'PropertyName' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTransformationProperty' AS [Table],
				N'PropertyName' AS [Column],
				[MappingTransformationProperty].[PropertyName] AS [Text]
				FROM [_SCHEMANAME_].[MappingTransformationProperty]
					INNER JOIN [_SCHEMANAME_].[Mapping]
						ON [MappingTransformationProperty].[MappingId] = [Mapping].[MappingId]
			UNION ALL SELECT
				[Mapping].[AssetId],
				[MappingTransformationProperty].[PropertyName] AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'MappingTransformationProperty' AS [Table],
				N'Value' AS [Column],
				[MappingTransformationProperty].[Value] AS [Text]
				FROM [_SCHEMANAME_].[MappingTransformationProperty]
					INNER JOIN [_SCHEMANAME_].[Mapping]
						ON [MappingTransformationProperty].[MappingId] = [Mapping].[MappingId]



			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'PreProcessingCmd' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'Synchronization' AS [Table],
				N'PreProcessingCmd' AS [Column],
				[Synchronization].[PreProcessingCmd] AS [Text]
				FROM [_SCHEMANAME_].[Synchronization]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'PreProcessingCmd' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'Synchronization' AS [Table],
				N'PostProcessingCmd' AS [Column],
				[Synchronization].[PostProcessingCmd] AS [Text]
				FROM [_SCHEMANAME_].[Synchronization]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'TargetObject' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'Synchronization' AS [Table],
				N'TargetObject' AS [Column],
				[Synchronization].[TargetObject] AS [Text]
				FROM [_SCHEMANAME_].[Synchronization]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'ObjectName' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'ObjectName' AS [Column],
				[SynchronizationFilter].[ObjectName] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'ObjectLabel' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'ObjectLabel' AS [Column],
				[SynchronizationFilter].[ObjectLabel] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'Field' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'Field' AS [Column],
				[SynchronizationFilter].[Field] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'FieldLabel' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'FieldLabel' AS [Column],
				[SynchronizationFilter].[FieldLabel] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'Type' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'Type' AS [Column],
				[SynchronizationFilter].[Type] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				NULL AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'Operator' AS [Column],
				[SynchronizationFilter].[Operator] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'Value' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationFilter' AS [Table],
				N'Value' AS [Column],
				[SynchronizationFilter].[Value] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationFilter]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationFilter].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'Name' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationSource' AS [Table],
				N'Name' AS [Column],
				[SynchronizationSource].[Name] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationSource]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationSource].[SynchronizationId] = [Synchronization].[SynchronizationId]
			UNION ALL SELECT
				[Synchronization].[AssetId],
				N'Label' AS [Attribute],
				N'_SCHEMANAME_' AS [Schema],
				N'SynchronizationSource' AS [Table],
				N'Label' AS [Column],
				[SynchronizationSource].[Label] AS [Text]
				FROM [_SCHEMANAME_].[SynchronizationSource]
					INNER JOIN [_SCHEMANAME_].[Synchronization]
						ON [SynchronizationSource].[SynchronizationId] = [Synchronization].[SynchronizationId]
		) AS [TextSearch]
		INNER JOIN [_SCHEMANAME_].[Asset]
			ON [TextSearch].[AssetId] = [Asset].[AssetId]
		INNER JOIN [_SCHEMANAME_].[AssetType]
			ON [Asset].[AssetTypeId] = [AssetType].[AssetTypeId]
