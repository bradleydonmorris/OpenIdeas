BEGIN
	--Group Member Users to Delete
	DELETE
		FROM [ActiveDirectory].[GroupMembershipUser]
		WHERE [GroupMembershipUserId] IN
		(
			SELECT [GroupMembershipUser].[GroupMembershipUserId]
				FROM [ActiveDirectory].[GroupMembershipUser]
					INNER JOIN
					(
						SELECT DISTINCT [StagedGroupMembership].[GroupId]
							FROM [ActiveDirectory].[StagedGroupMembership]
					) AS [ChangedGroup]
						ON [GroupMembershipUser].[GroupId] = [ChangedGroup].[GroupId]
					LEFT OUTER JOIN
					(
						SELECT DISTINCT
							[StagedGroupMembership].[GroupId],
							[User].[UserId] AS [MemberUserId]
							FROM [ActiveDirectory].[StagedGroupMembership]
								INNER JOIN [ActiveDirectory].[User]
									ON [StagedGroupMembership].[MemberDistinguishedName] = [User].[DistinguishedName]
					) AS [MemberUser]
						ON
							[GroupMembershipUser].[GroupId] = [MemberUser].[GroupId]
							AND [GroupMembershipUser].[MemberUserId] = [MemberUser].[MemberUserId]
				WHERE [MemberUser].[MemberUserId] IS NULL
		)

	--Group Member Users to Add
	INSERT INTO [ActiveDirectory].[GroupMembershipUser]([GroupId], [MemberUserId])
		SELECT DISTINCT
			[StagedGroupMembership].[GroupId],
			[User].[UserId]
			FROM [ActiveDirectory].[StagedGroupMembership]
				INNER JOIN [ActiveDirectory].[User]
					ON [StagedGroupMembership].[MemberDistinguishedName] = [User].[DistinguishedName]
				LEFT OUTER JOIN [ActiveDirectory].[GroupMembershipUser]
					ON
						[StagedGroupMembership].[GroupId] = [GroupMembershipUser].[GroupId]
						AND [User].[UserId] = [GroupMembershipUser].[MemberUserId]
			WHERE [GroupMembershipUser].[GroupMembershipUserId] IS NULL

	--Group Member Groups to Delete
	DELETE
		FROM [ActiveDirectory].[GroupMembershipGroup]
		WHERE [GroupMembershipGroupId] IN
		(
			SELECT [GroupMembershipGroup].[GroupMembershipGroupId]
				FROM [ActiveDirectory].[GroupMembershipGroup]
					INNER JOIN
					(
						SELECT DISTINCT [StagedGroupMembership].[GroupId]
							FROM [ActiveDirectory].[StagedGroupMembership]
					) AS [ChangedGroup]
						ON [GroupMembershipGroup].[GroupId] = [ChangedGroup].[GroupId]
					LEFT OUTER JOIN
					(
						SELECT DISTINCT
							[StagedGroupMembership].[GroupId],
							[Group].[GroupId] AS [MemberGroupId]
							FROM [ActiveDirectory].[StagedGroupMembership]
								INNER JOIN [ActiveDirectory].[Group]
									ON [StagedGroupMembership].[MemberDistinguishedName] = [Group].[DistinguishedName]
					) AS [MemberGroup]
						ON
							[GroupMembershipGroup].[GroupId] = [MemberGroup].[GroupId]
							AND [GroupMembershipGroup].[MemberGroupId] = [MemberGroup].[MemberGroupId]
				WHERE [MemberGroup].[MemberGroupId] IS NULL
		)

	--Group Member Groups to Add
	INSERT INTO [ActiveDirectory].[GroupMembershipGroup]([GroupId], [MemberGroupId])
		SELECT DISTINCT
			[StagedGroupMembership].[GroupId],
			[Group].[GroupId]
			FROM [ActiveDirectory].[StagedGroupMembership]
				INNER JOIN [ActiveDirectory].[Group]
					ON [StagedGroupMembership].[MemberDistinguishedName] = [Group].[DistinguishedName]
				LEFT OUTER JOIN [ActiveDirectory].[GroupMembershipGroup]
					ON
						[StagedGroupMembership].[GroupId] = [GroupMembershipGroup].[GroupId]
						AND [Group].[GroupId] = [GroupMembershipGroup].[MemberGroupId]
			WHERE [GroupMembershipGroup].[GroupMembershipGroupId] IS NULL
	TRUNCATE TABLE [ActiveDirectory].[StagedGroupMembership]
END
