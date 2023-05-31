BEGIN
	SET NOCOUNT ON
	MERGE [Google].[OrganizationalUnit] AS [Target]
		USING
		(
			SELECT
				[Source].[Id],
				[Source].[ParentId],
				[Source].[ETag],
				[Source].[Name],
				NULLIF([Source].[Description], N'') AS [Description],
				[Source].[Path],
				[Source].[ParentPath],
				ISNULL([Source].[BlockInheritance], 0) AS [BlockInheritance],
				SYSUTCDATETIME() AS [ImportTime]
				FROM OPENJSON(@OrgUnitJSON)
					WITH
					(
						[Id] [nvarchar](50) N'$.orgUnitId',
						[ParentId] [nvarchar](50) N'$.parentOrgUnitId',
						[ETag] [nvarchar](100) N'$.etag',
						[Name] [nvarchar](100) N'$.name',
						[Description] [nvarchar](100) N'$.description',
						[Path] [nvarchar](400) N'$.orgUnitPath',
						[ParentPath] [nvarchar](400) N'$.parentOrgUnitPath',
						[BlockInheritance] [bit] N'$.blockInheritance'
					) AS [Source]
					LEFT OUTER JOIN [Google].[OrganizationalUnit]
						ON [Source].[Id] = [OrganizationalUnit].[Id]
				WHERE
					[OrganizationalUnit].[ETag] IS NULL
					OR [Source].[ETag] != [OrganizationalUnit].[ETag]
		) AS [Source]
			ON [Target].[Id] = [Source].[Id]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([Id], [ParentId], [ETag], [Name], [Description], [Path], [ParentPath], [BlockInheritance], [ImportTime])
			VALUES ([Source].[Id], [Source].[ParentId], [Source].[ETag], [Source].[Name], [Source].[Description], [Source].[Path], [Source].[ParentPath], [Source].[BlockInheritance], [Source].[ImportTime])
		WHEN MATCHED THEN UPDATE SET
			[Id] = [Source].[Id],
			[ParentId] = [Source].[ParentId],
			[ETag] = [Source].[ETag],
			[Name] = [Source].[Name],
			[Description] = [Source].[Description],
			[Path] = [Source].[Path],
			[ParentPath] = [Source].[ParentPath],
			[BlockInheritance] = [Source].[BlockInheritance],
			[ImportTime] = [Source].[ImportTime]
	;
END
