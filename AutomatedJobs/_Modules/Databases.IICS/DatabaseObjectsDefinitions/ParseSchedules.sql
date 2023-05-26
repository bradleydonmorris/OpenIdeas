BEGIN
	MERGE [_SCHEMANAME_].[Schedule] AS [Target]
		USING
		(
			SELECT
				[Asset].[AssetId] AS [AssetId],
				[ScheduleInterval].[ScheduleIntervalId],
				[Content].[Id] AS [Id],
				[Content].[Name] AS [Name],
				[Content].[Description] AS [Description],
				[Content].[Status] AS [Status],
				[Content].[RangeStartTime] AS [RangeStartTime],
				[Content].[RangeEndTime] AS [RangeEndTime],
				[Content].[StartTime] AS [StartTime],
				[Content].[EndTime] AS [EndTime],
				[Content].[Frequency] AS [Frequency],
				[Content].[Monday] AS [Monday],
				[Content].[Tuesday] AS [Tuesday],
				[Content].[Wednesday] AS [Wednesday],
				[Content].[Thursday] AS [Thursday],
				[Content].[Friday] AS [Friday],
				[Content].[Saturday] AS [Saturday],
				[Content].[Sunday] AS [Sunday],
				[Content].[Weekday] AS [Weekday],
				[Content].[DayOfMonth] AS [DayOfMonth],
				[Content].[WeekOfMonth] AS [WeekOfMonth],
				[Content].[DayOfWeek] AS [DayOfWeek],
				[Content].[CreateTime] AS [CreateTime],
				[Content].[UpdateTime] AS [UpdateTime],
				[Content].[CreatedBy] AS [CreatedBy],
				[Content].[UpdatedBy] AS [UpdatedBy],
				0 AS [IsRemoved]
				FROM [_SCHEMANAME_].[StagedAsset]
					INNER JOIN [_SCHEMANAME_].[StagedAssetFile]
						ON [StagedAsset].[FederatedId] = [StagedAssetFile].[FederatedId]
					CROSS APPLY OPENJSON([StagedAssetFile].[Content], N'$.schedules')
						WITH
						(
							[FederatedId] [varchar](50) N'$.scheduleFederatedId',
							[Id] [varchar](50) N'$.id',
							[Name] [nvarchar](400) N'$.name',
							[Description] [nvarchar](400) N'$.description',
							[Status] [varchar](20) N'$.status',
							[RangeStartTime] [datetime2](7) N'$.rangeStartTime',
							[RangeEndTime] [datetime2](7) N'$.rangeEndTime',
							[StartTime] [datetime2](7) N'$.startTime',
							[EndTime] [datetime2](7) N'$.endTime',
							[Interval] [varchar](20) N'$.interval',
							[Frequency] [int] N'$.frequency',
							[Monday] [bit] N'$.mon',
							[Tuesday] [bit] N'$.tue',
							[Wednesday] [bit] N'$.wed',
							[Thursday] [bit] N'$.thu',
							[Friday] [bit] N'$.fri',
							[Saturday] [bit] N'$.sat',
							[Sunday] [bit] N'$.sun',
							[Weekday] [bit] N'$.weekDay',
							[DayOfMonth] [int] N'$.dayOfMonth',
							[WeekOfMonth] [varchar](20) N'$.weekOfMonth',
							[DayOfWeek] [varchar](20) N'$.dayOfWeek',
							[CreateTime] [datetime2](7) N'$.createTime',
							[UpdateTime] [datetime2](7) N'$.updateTime',
							[CreatedBy] [varchar](320) N'$.createdBy',
							[UpdatedBy] [varchar](320) N'$.updatedBy'
						) AS [Content]
					INNER JOIN [_SCHEMANAME_].[Asset]
						ON [Content].[FederatedId] = [Asset].[FederatedId]
					INNER JOIN [_SCHEMANAME_].[ScheduleInterval]
						ON [Content].[Interval] = [ScheduleInterval].[Name]
				WHERE [StagedAsset].[FederatedId] = 'System.Schedule'
		) AS [Source]
			ON [Source].[AssetId] = [Target].[AssetId]
		WHEN MATCHED THEN UPDATE SET
			[ScheduleIntervalId] = [Source].[ScheduleIntervalId],
			[Id] = [Source].[Id], [Name] = [Source].[Name], [Description] = [Source].[Description], [Status] = [Source].[Status],
			[RangeStartTime] = [Source].[RangeStartTime], [RangeEndTime] = [Source].[RangeEndTime], [StartTime] = [Source].[StartTime], [EndTime] = [Source].[EndTime],
			[Frequency] = [Source].[Frequency],
			[Monday] = [Source].[Monday], [Tuesday] = [Source].[Tuesday], [Wednesday] = [Source].[Wednesday], [Thursday] = [Source].[Thursday], [Friday] = [Source].[Friday], [Saturday] = [Source].[Saturday], [Sunday] = [Source].[Sunday],
			[Weekday] = [Source].[Weekday], [DayOfMonth] = [Source].[DayOfMonth], [WeekOfMonth] = [Source].[WeekOfMonth], [DayOfWeek] = [Source].[DayOfWeek],
			[CreateTime] = [Source].[CreateTime], [UpdateTime] = [Source].[UpdateTime], [CreatedBy] = [Source].[CreatedBy], [UpdatedBy] = [Source].[UpdatedBy], [IsRemoved] = [Source].[IsRemoved]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				[AssetId], [ScheduleIntervalId], [Id], [Name], [Description], [Status],
				[RangeStartTime], [RangeEndTime], [StartTime], [EndTime],
				[Frequency],
				[Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday],
				[Weekday], [DayOfMonth], [WeekOfMonth], [DayOfWeek],
				[CreateTime], [UpdateTime], [CreatedBy], [UpdatedBy], [IsRemoved]
			)
				VALUES
				(
					[Source].[AssetId], [Source].[ScheduleIntervalId], [Source].[Id], [Source].[Name], [Source].[Description], [Source].[Status],
					[Source].[RangeStartTime], [Source].[RangeEndTime], [Source].[StartTime], [Source].[EndTime],
					[Source].[Frequency],
					[Source].[Monday], [Source].[Tuesday], [Source].[Wednesday], [Source].[Thursday], [Source].[Friday], [Source].[Saturday], [Source].[Sunday],
					[Source].[Weekday], [Source].[DayOfMonth], [Source].[WeekOfMonth], [Source].[DayOfWeek],
					[Source].[CreateTime], [Source].[UpdateTime], [Source].[CreatedBy], [Source].[UpdatedBy], [Source].[IsRemoved]
				)
		WHEN NOT MATCHED BY SOURCE THEN UPDATE SET [IsRemoved] = 1
	;
	UPDATE [_SCHEMANAME_].[Schedule]
		SET [ScheduleText] = [_SCHEMANAME_].[GetScheduleTexturalStatement]
			(
				[ScheduleInterval].[Name],
				[Schedule].[Weekday],
				[Schedule].[DayOfMonth],
				[Schedule].[WeekOfMonth],
				[Schedule].[DayOfWeek],
				[Schedule].[Frequency],
				[Schedule].[Monday],
				[Schedule].[Tuesday],
				[Schedule].[Wednesday],
				[Schedule].[Thursday],
				[Schedule].[Friday],
				[Schedule].[Saturday],
				[Schedule].[Sunday],
				[Schedule].[StartTime],
				[Schedule].[EndTime],
				[Schedule].[RangeStartTime],
				[Schedule].[RangeEndTime]
			)
		FROM [_SCHEMANAME_].[Schedule]
			INNER JOIN [_SCHEMANAME_].[ScheduleInterval]
				ON [Schedule].[ScheduleIntervalId] = [ScheduleInterval].[ScheduleIntervalId]
END
