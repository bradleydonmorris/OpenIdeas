BEGIN
	SET NOCOUNT ON
	DECLARE @GroupId [int]
	DECLARE @GroupObjectGUID [uniqueidentifier] = JSON_VALUE(@GroupJSON, N'$.objectGuid')
	INSERT INTO [ActiveDirectory].[ObjectCategory]([Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				SELECT [Source].[objectCategory] AS [Name]
					FROM OPENJSON(@GroupJSON)
						WITH
						(
							[objectCategory] [nvarchar](400) N'$.objectCategory'
						) AS [Source]
			) AS [Source]
				LEFT OUTER JOIN [ActiveDirectory].[ObjectCategory] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[ObjectCategoryId] IS NULL
	INSERT INTO [ActiveDirectory].[ObjectClass]([Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				SELECT [Source].[value] AS [Name]
					FROM OPENJSON(@GroupJSON, N'$.objectClass') AS [Source]
			) AS [Source]
				LEFT OUTER JOIN [ActiveDirectory].[ObjectClass] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[ObjectClassId] IS NULL
	INSERT INTO [ActiveDirectory].[OrganizationalUnit]([LDIFPath], [NaturalPath])
		SELECT DISTINCT
			[Source].[LDIFPath],
			[ActiveDirectory].[GetNaturalPathFromLDIFPath]([Source].[LDIFPath]) AS [NaturalPath]
			FROM
			(
				SELECT [Source].[parentDistinguishedName] AS [LDIFPath]
					FROM OPENJSON(@GroupJSON)
						WITH
						(
							[parentDistinguishedName] [nvarchar](400) N'$.parentDistinguishedName'
						) AS [Source]
						LEFT OUTER JOIN [ActiveDirectory].[OrganizationalUnit] AS [Target]
							ON [Source].[parentDistinguishedName] = [Target].[LDIFPath]
					WHERE [Target].[OrganizationalUnitId] IS NULL
			) AS [Source]

	--Group
	MERGE [ActiveDirectory].[Group] AS [Target]
		USING
		(
			SELECT
				[OrganizationalUnit_Parent].[OrganizationalUnitId] AS [ParentOrganizationalUnitId],
				[ObjectCategory].[ObjectCategoryId],
				[GroupType].[GroupTypeId],
				[Source].[ObjectGUID], [Source].[ObjectSID], [Source].[USNCreated], [Source].[USNChanged],
				[Source].[WhenCreatedTime], [Source].[WhenChangedTime],
				[Source].[DistinguishedName], [Source].[CommonName], [Source].[SAMAccountName], [Source].[EmailAddress],
				[Source].[DisplayName], [Source].[Name],
				[Source].[Description], [Source].[Info]
				FROM OPENJSON(@GroupJSON)
					WITH
					(
						[ObjectGUID] [uniqueidentifier] N'$.objectGuid',
						[ObjectSID] [nvarchar](400) N'$.objectSid',
						[USNCreated] [bigint] N'$.usnCreated',
						[USNChanged] [bigint] N'$.uSNChanged',
						[WhenCreatedTime] [datetime2](7) N'$.whenCreated',
						[WhenChangedTime] [datetime2](7) N'$.whenChanged',
						[ObjectCategory] [nvarchar](400) N'$.objectCategory',
						[GroupType] [int] N'$.GroupType',

						[DistinguishedName] [nvarchar](400) N'$.distinguishedName',
						[CommonName] [nvarchar](400) N'$.cn',
						[SAMAccountName] [nvarchar](400) N'$.sAMAccountName',
						[EmailAddress] [nvarchar](400) N'$.mail',

						[ParentDistinguishedName] [nvarchar](400) N'$.parentDistinguishedName',

						[DisplayName] [nvarchar](400) N'$.displayName',
						[Name] [nvarchar](400) N'$.name',

						[Description] [nvarchar](400) N'$.description',
						[Info] [nvarchar](400) N'$.info'
					) AS [Source]
						INNER JOIN [ActiveDirectory].[ObjectCategory]
							ON [Source].[objectCategory] = [ObjectCategory].[Name]
						INNER JOIN [ActiveDirectory].[OrganizationalUnit] AS [OrganizationalUnit_Parent]
							ON [Source].[parentDistinguishedName] = [OrganizationalUnit_Parent].[LDIFPath]
						INNER JOIN [ActiveDirectory].[GroupType]
							ON ISNULL([Source].[GroupType], 0) = [GroupType].[GroupTypeId]
		) AS [Source]
			ON [Source].[ObjectGUID] = [Target].[ObjectGUID]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				[ParentOrganizationalUnitId], [ObjectCategoryId], [GroupTypeId],
				[ObjectGUID], [ObjectSID], [USNCreated], [USNChanged],
				[WhenCreatedTime], [WhenChangedTime],
				[DistinguishedName], [CommonName], [SAMAccountName], [EmailAddress],
				[DisplayName], [Name],
				[Description], [Info]
			)
				VALUES
				(
					[Source].[ParentOrganizationalUnitId], [Source].[ObjectCategoryId], [Source].[GroupTypeId],
					[Source].[ObjectGUID], [Source].[ObjectSID], [Source].[USNCreated], [Source].[USNChanged],
					[Source].[WhenCreatedTime], [Source].[WhenChangedTime],
					[Source].[DistinguishedName], [Source].[CommonName], [Source].[SAMAccountName], [Source].[EmailAddress],
					[Source].[DisplayName], [Source].[Name],
					[Source].[Description], [Source].[Info]
				)
		WHEN MATCHED THEN UPDATE SET
			[ParentOrganizationalUnitId] = [Source].[ParentOrganizationalUnitId], [ObjectCategoryId] = [Source].[ObjectCategoryId], [GroupTypeId] = [Source].[GroupTypeId],
			[ObjectGUID] = [Source].[ObjectGUID], [ObjectSID] = [Source].[ObjectSID], [USNCreated] = [Source].[USNCreated], [USNChanged] = [Source].[USNChanged],
			[WhenCreatedTime] = [Source].[WhenCreatedTime], [WhenChangedTime] = [Source].[WhenChangedTime],
			[DistinguishedName] = [Source].[DistinguishedName], [CommonName] = [Source].[CommonName], [SAMAccountName] = [Source].[SAMAccountName], [EmailAddress] = [Source].[EmailAddress],
			[DisplayName] = [Source].[DisplayName], [Name] = [Source].[Name],
			[Description] = [Source].[Description], [Info] = [Source].[Info]
	;

	SELECT @GroupId = [Group].[GroupId]
		FROM [ActiveDirectory].[Group]
		WHERE [Group].[ObjectGUID] = @GroupObjectGUID

	--GroupObjectClass
	DELETE
		FROM [ActiveDirectory].[GroupObjectClass]
		WHERE
			[GroupId] = @GroupId
			AND [ObjectClassId] NOT IN
			(
				SELECT [ObjectClass].[ObjectClassId]
					FROM OPENJSON(@GroupJSON)
						WITH ( [objectClass] [nvarchar](MAX) N'$.objectClass' AS JSON ) AS [Source]
							CROSS APPLY OPENJSON([Source].[objectClass]) AS [SourceObjectClass]
							INNER JOIN [ActiveDirectory].[ObjectClass]
								ON [SourceObjectClass].[value] = [ObjectClass].[Name]
			)
	INSERT INTO [ActiveDirectory].[GroupObjectClass]([GroupId], [ObjectClassId])
		SELECT
			[Source].[GroupId],
			[Source].[ObjectClassId]
			FROM
			(
				SELECT
					[Group].[GroupId],
					[ObjectClass].[ObjectClassId]
					FROM OPENJSON(@GroupJSON)
						WITH
						(
							[objectGuid] [uniqueidentifier] N'$.objectGuid',
							[objectClass] [nvarchar](MAX) N'$.objectClass' AS JSON
						) AS [Source]
							CROSS APPLY OPENJSON([Source].[objectClass]) AS [SourceObjectClass]
							INNER JOIN [ActiveDirectory].[ObjectClass]
								ON [SourceObjectClass].[value] = [ObjectClass].[Name]
							INNER JOIN [ActiveDirectory].[Group]
								ON [Source].[objectGuid] = [Group].[objectGuid]
			) AS [Source]
				LEFT OUTER JOIN [ActiveDirectory].[GroupObjectClass] AS [Target]
					ON
						[Source].[GroupId] = [Target].[GroupId]
						AND [Source].[ObjectClassId] = [Target].[ObjectClassId]
			WHERE [Target].[GroupObjectClassId] IS NULL

	--StagedGroupMembership
	INSERT INTO [ActiveDirectory].[StagedGroupMembership]([InsertTimestamp], [GroupId], [ObjectGUID], [MemberDistinguishedName])
		SELECT
			SYSUTCDATETIME() AS [InsertTimestamp],
			@GroupId AS [GroupId],
			[Source].[ObjectGUID],
			[SourceMember].[value] AS [MemberDistinguishedName]
			FROM OPENJSON(@GroupJSON)
				WITH
				(
					[ObjectGUID] [uniqueidentifier] N'$.objectGuid',
					[Members] [nvarchar](MAX) N'$.members' AS JSON
				) AS [Source]
				CROSS APPLY OPENJSON([Source].[Members]) AS [SourceMember]

	--StagedGroupManager
	INSERT INTO [ActiveDirectory].[StagedGroupManager]([GroupId], [ObjectGUID], [ManagerDistinguishedName])
		SELECT
			@GroupId AS [GroupId],
			[Source].[ObjectGUID],
			[Source].[ManagerDistinguishedName]
			FROM OPENJSON(@GroupJSON)
				WITH
				(
					[ObjectGUID] [uniqueidentifier] N'$.objectGuid',
					[ManagerDistinguishedName] [nvarchar](400) N'$.managedBy'
				) AS [Source]
END
