BEGIN
	--Group Member Users to Delete
	DELETE
		FROM [Google].[GroupMembershipUser]
		WHERE [GroupMembershipUserId] IN
		(
			SELECT [GroupMembershipUser].[GroupMembershipUserId]
				FROM [Google].[GroupMembershipUser]
					INNER JOIN
					(
						SELECT DISTINCT [StagedGroupMembership].[GroupId]
							FROM [Google].[StagedGroupMembership]
					) AS [ChangedGroup]
						ON [GroupMembershipUser].[GroupId] = [ChangedGroup].[GroupId]
					LEFT OUTER JOIN
					(
						SELECT DISTINCT
							[StagedGroupMembership].[GroupId],
							[UserEmail].[UserId] AS [MemberUserId]
							FROM [Google].[StagedGroupMembership]
								INNER JOIN [Google].[UserEmail]
									ON [StagedGroupMembership].[EmailAddress] = [UserEmail].[EmailAddress]
							WHERE [StagedGroupMembership].[Type] = 'USER'
					) AS [MemberUser]
						ON
							[GroupMembershipUser].[GroupId] = [MemberUser].[GroupId]
							AND [GroupMembershipUser].[MemberUserId] = [MemberUser].[MemberUserId]
				WHERE [MemberUser].[MemberUserId] IS NULL
		)
	--Group Member Users to Add
	INSERT INTO [Google].[GroupMembershipUser]([GroupId], [MemberUserId], [GroupMemberRoleId])
		SELECT DISTINCT
			[StagedGroupMembership].[GroupId],
			[StagedGroupMembership].[MemberUserId],
			[StagedGroupMembership].[GroupMemberRoleId]
			FROM
			(
				SELECT DISTINCT
					[StagedGroupMembership].[GroupId],
					[UserEmail].[UserId] AS [MemberUserId],
					[GroupMemberRole].[GroupMemberRoleId]
					FROM [Google].[StagedGroupMembership]
						INNER JOIN [Google].[UserEmail]
							ON [StagedGroupMembership].[EmailAddress] = [UserEmail].[EmailAddress]
						INNER JOIN [Google].[GroupMemberRole]
							ON [StagedGroupMembership].[Role] = [GroupMemberRole].[Name]
					WHERE [StagedGroupMembership].[Type] = 'USER'
			) AS [StagedGroupMembership]
				LEFT OUTER JOIN [Google].[GroupMembershipUser]
					ON
						[StagedGroupMembership].[GroupId] = [GroupMembershipUser].[GroupId]
						AND [StagedGroupMembership].[MemberUserId] = [GroupMembershipUser].[MemberUserId]
			WHERE [GroupMembershipUser].[GroupMembershipUserId] IS NULL



	--Group Member Groups to Delete
	DELETE
		FROM [Google].[GroupMembershipGroup]
		WHERE [GroupMembershipGroupId] IN
		(
			SELECT [GroupMembershipGroup].[GroupMembershipGroupId]
				FROM [Google].[GroupMembershipGroup]
					INNER JOIN
					(
						SELECT DISTINCT [StagedGroupMembership].[GroupId]
							FROM [Google].[StagedGroupMembership]
					) AS [ChangedGroup]
						ON [GroupMembershipGroup].[GroupId] = [ChangedGroup].[GroupId]
					LEFT OUTER JOIN
					(
						SELECT DISTINCT
							[StagedGroupMembership].[GroupId],
							[GroupEmail].[GroupId] AS [MemberGroupId]
							FROM [Google].[StagedGroupMembership]
								INNER JOIN [Google].[GroupEmail]
									ON [StagedGroupMembership].[EmailAddress] = [GroupEmail].[EmailAddress]
							WHERE [StagedGroupMembership].[Type] = 'GROUP'
					) AS [MemberGroup]
						ON
							[GroupMembershipGroup].[GroupId] = [MemberGroup].[GroupId]
							AND [GroupMembershipGroup].[MemberGroupId] = [MemberGroup].[MemberGroupId]
				WHERE [MemberGroup].[MemberGroupId] IS NULL
		)
	--Group Member Groups to Add
	INSERT INTO [Google].[GroupMembershipGroup]([GroupId], [MemberGroupId], [GroupMemberRoleId])
		SELECT DISTINCT
			[StagedGroupMembership].[GroupId],
			[StagedGroupMembership].[MemberGroupId],
			[StagedGroupMembership].[GroupMemberRoleId]
			FROM
			(
				SELECT DISTINCT
					[StagedGroupMembership].[GroupId],
					[GroupEmail].[GroupId] AS [MemberGroupId],
					[GroupMemberRole].[GroupMemberRoleId]
					FROM [Google].[StagedGroupMembership]
						INNER JOIN [Google].[GroupEmail]
							ON [StagedGroupMembership].[EmailAddress] = [GroupEmail].[EmailAddress]
						INNER JOIN [Google].[GroupMemberRole]
							ON [StagedGroupMembership].[Role] = [GroupMemberRole].[Name]
					WHERE [StagedGroupMembership].[Type] = 'GROUP'
			) AS [StagedGroupMembership]
				LEFT OUTER JOIN [Google].[GroupMembershipGroup]
					ON
						[StagedGroupMembership].[GroupId] = [GroupMembershipGroup].[GroupId]
						AND [StagedGroupMembership].[MemberGroupId] = [GroupMembershipGroup].[MemberGroupId]
			WHERE [GroupMembershipGroup].[GroupMembershipGroupId] IS NULL
	TRUNCATE TABLE [Google].[StagedGroupMembership]
END
