BEGIN
	--For Managers that are Users
	DELETE
		FROM [ActiveDirectory].[GroupManagerUser]
		WHERE [GroupManagerUserId] IN
		(
			SELECT DISTINCT [GroupManagerUser].[GroupManagerUserId]
				FROM [ActiveDirectory].[StagedGroupManager]
					INNER JOIN [ActiveDirectory].[GroupManagerUser]
						ON [StagedGroupManager].[GroupId] = [GroupManagerUser].[GroupId]
					LEFT OUTER JOIN [ActiveDirectory].[User]
						ON [StagedGroupManager].[ManagerDistinguishedName] = [User].[DistinguishedName]
				WHERE
					[StagedGroupManager].[ManagerDistinguishedName] IS NULL
					OR [User].[UserId] IS NULL
		)
	MERGE [ActiveDirectory].[GroupManagerUser] AS [Target]
		USING
		(
			SELECT
				[StagedGroupManager].[GroupId],
				[User].[UserId] AS [ManagerUserId]
				FROM [ActiveDirectory].[StagedGroupManager]
					INNER JOIN [ActiveDirectory].[User]
						ON [StagedGroupManager].[ManagerDistinguishedName] = [User].[DistinguishedName]
		) AS [Source]
			ON [Source].[GroupId] = [Target].[GroupId]
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([GroupId], [ManagerUserId])
				VALUES([Source].[GroupId], [Source].[ManagerUserId])
		WHEN MATCHED THEN UPDATE SET [ManagerUserId] = [Source].[ManagerUserId]
	;

	--For Managers that are Groups
	DELETE
		FROM [ActiveDirectory].[GroupManagerGroup]
		WHERE [GroupManagerGroupId] IN
		(
			SELECT DISTINCT [GroupManagerGroup].[GroupManagerGroupId]
				FROM [ActiveDirectory].[StagedGroupManager]
					INNER JOIN [ActiveDirectory].[GroupManagerGroup]
						ON [StagedGroupManager].[GroupId] = [GroupManagerGroup].[GroupId]
					LEFT OUTER JOIN [ActiveDirectory].[Group]
						ON [StagedGroupManager].[ManagerDistinguishedName] = [Group].[DistinguishedName]
				WHERE
					[StagedGroupManager].[ManagerDistinguishedName] IS NULL
					OR [Group].[GroupId] IS NULL
		)
	MERGE [ActiveDirectory].[GroupManagerGroup] AS [Target]
		USING
		(
			SELECT
				[StagedGroupManager].[GroupId],
				[Group].[GroupId] AS [ManagerGroupId]
				FROM [ActiveDirectory].[StagedGroupManager]
					INNER JOIN [ActiveDirectory].[Group]
						ON [StagedGroupManager].[ManagerDistinguishedName] = [Group].[DistinguishedName]
		) AS [Source]
			ON [Source].[GroupId] = [Target].[GroupId]
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([GroupId], [ManagerGroupId])
				VALUES([Source].[GroupId], [Source].[ManagerGroupId])
		WHEN MATCHED THEN UPDATE SET [ManagerGroupId] = [Source].[ManagerGroupId]
	;
	TRUNCATE TABLE [ActiveDirectory].[StagedGroupManager]
END
