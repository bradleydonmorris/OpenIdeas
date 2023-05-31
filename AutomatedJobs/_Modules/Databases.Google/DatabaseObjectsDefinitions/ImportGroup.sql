BEGIN
	DECLARE @True [bit] = CONVERT([bit], 1, 0)
	DECLARE @False [bit] = CONVERT([bit], 0, 0)
	DECLARE @GroupId [int]
		DECLARE @Id [nvarchar](50) = JSON_VALUE(@GroupJSON, N'$.id')
		DECLARE @ETag [nvarchar](100) = JSON_VALUE(@GroupJSON, N'$.etag')
		--If there is NOT a record with a matching Id,
		--	Or the record has a different ETag,
		--	Then import the group
		IF NOT EXISTS
		(
			SELECT 1
				FROM [Google].[Group]
				WHERE
					[Group].[Id] = @Id
					AND [Group].[ETag] = @ETag
		)
			BEGIN
				--[Google].[Group]
				MERGE INTO [Google].[Group] AS [Target]
					USING
					(
						SELECT
							[Source].[Id],
							[Source].[ETag],
							[Source].[Name],
							NULLIF([Source].[Description], N'') AS [Description],
							ISNULL([Source].[IsAdminCreated], @False) AS [IsAdminCreated]
							FROM OPENJSON(@GroupJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[ETag] [nvarchar](100) N'$.etag',
									[Name] [nvarchar](100) N'$.name',
									[Description] [nvarchar](MAX) N'$.description',
									[IsAdminCreated] [bit] N'$.adminCreated'
								) AS [Source]
					) AS [Source]
							ON [Target].[Id] = [Source].[Id]
						WHEN NOT MATCHED BY TARGET THEN
							INSERT ([Id], [ETag], [Name], [Description], [IsAdminCreated], [ImportTime])
							VALUES ([Source].[Id], [Source].[ETag], [Source].[Name], [Source].[Description], [Source].[IsAdminCreated], SYSUTCDATETIME())
						WHEN MATCHED THEN UPDATE SET
							[ETag] = [Source].[ETag],
							[Name] = [Source].[Name],
							[Description] = [Source].[Description],
							[IsAdminCreated] = [Source].[IsAdminCreated],
							[ImportTime] = SYSUTCDATETIME()
				;
				SELECT @GroupId = [Group].[GroupId]
					FROM [Google].[Group]
					WHERE [Group].[Id] = @Id

				--Populate @GroupEmail
				DECLARE @GroupEmail TABLE
				(
					[GroupId] [int] NOT NULL,
					[EmailTypeId] [tinyint] NOT NULL,
					[EmailAddress] [nvarchar](320) NOT NULL
				)
				INSERT INTO @GroupEmail([GroupId], [EmailTypeId], [EmailAddress])
					SELECT
						[Group].[GroupId],
						[EmailType].[EmailTypeId],
						[Source].[EmailAddress]
						FROM
						(
							SELECT
								[Source].[Id],
								[Source].[EmailAddress],
								N'Primary' AS [Type]
								FROM OPENJSON(@GroupJSON)
									WITH
									(
										[Id] [nvarchar](50) N'$.id',
										[EmailAddress] [nvarchar](320) N'$.email'
									) AS [Source]
							UNION
							SELECT
								[Source].[Id],
								[Alias].[value] AS [EmailAddress],
								N'Alias' AS [Type]
								FROM OPENJSON(@GroupJSON)
									WITH
									(
										[Id] [nvarchar](50) N'$.id',
										[Aliases] [nvarchar](MAX) N'$.aliases' AS JSON
									) AS [Source]
									CROSS APPLY OPENJSON([Source].[Aliases]) AS [Alias]
							UNION
							SELECT
								[Source].[Id],
								[NonEditableAlias].[value] AS [EmailAddress],
								N'NonEditableAlias' AS [Type]
								FROM OPENJSON(@GroupJSON)
									WITH
									(
										[Id] [nvarchar](50) N'$.id',
										[nonEditableAliases] [nvarchar](MAX) N'$.nonEditableAliases' AS JSON
									) AS [Source]
									CROSS APPLY OPENJSON([Source].[nonEditableAliases]) AS [NonEditableAlias]
						) AS [Source]
							INNER JOIN [Google].[Group]
								ON [Source].[Id] = [Group].[Id]
							INNER JOIN [Google].[EmailType]
								ON [Source].[Type] = [EmailType].[Name]
				--Delete [Google].[GroupEmail]
				DELETE
					FROM [Google].[GroupEmail]
					WHERE
						[GroupId] = @GroupId
						AND [GroupEmailId] IN
						(
							SELECT [Target].[GroupEmailId]
								FROM [Google].[GroupEmail] AS [Target]
									LEFT OUTER JOIN @GroupEmail AS [Source]
										ON
											[Target].[GroupId] = [Source].[GroupId]
											AND [Target].[EmailTypeId] = [Source].[EmailTypeId]
											AND [Target].[EmailAddress] = [Source].[EmailAddress]
								WHERE
									[Target].[GroupId] = @GroupId
									AND [Source].[EmailAddress] IS NULL
						)
				--Merge [Google].[GroupEmail]
				MERGE [Google].[GroupEmail] AS [Target]
					USING @GroupEmail AS [Source]
						ON
							[Target].[GroupId] = [Source].[GroupId]
							AND [Target].[EmailTypeId] = [Source].[EmailTypeId]
							AND [Target].[EmailAddress] = [Source].[EmailAddress]
					WHEN NOT MATCHED BY TARGET THEN
						INSERT ([GroupId], [EmailTypeId], [EmailAddress])
						VALUES ([Source].[GroupId], [Source].[EmailTypeId], [Source].[EmailAddress])
					WHEN MATCHED THEN UPDATE SET [EmailAddress] = [Source].[EmailAddress]
				;

				INSERT
					INTO [Google].[StagedGroupMembership]
					(
						[GroupId],
						[GroupMemberRoleId],
						[MemberId],
						[MemberETag],
						[EmailAddress],
						[Role],
						[Type],
						[Status]
					)
					SELECT
						[Group].[GroupId],
						[GroupMemberRole].[GroupMemberRoleId],
						[Source].[MemberId], --DOES NOT MAP TO USER OR GROUP
						[Source].[MemberETag], --DOES NOT MAP TO USER OR GROUP
						[Source].[EmailAddress],
						[Source].[Role],
						[Source].[Type],
						[Source].[Status]
						FROM
						(
							SELECT
								[Source].[Id] AS [Group_Id],
								[SourceMember].[Id] AS [MemberId],
								[SourceMember].[ETag] AS [MemberETag],
								[SourceMember].[EmailAddress],
								[SourceMember].[Role],
								[SourceMember].[Type],
								[SourceMember].[Status]
								FROM OPENJSON(@GroupJSON)
									WITH
									(
										[Id] [nvarchar](50) N'$.id',
										[Members] [nvarchar](MAX) N'$.Members' AS JSON
									) AS [Source]
									CROSS APPLY OPENJSON([Source].[Members])
										WITH
										(
											[Id] [nvarchar](50) N'$.id',
											[ETag] [nvarchar](100) N'$.etag',
											[EmailAddress] [nvarchar](320) N'$.email',
											[Role] [nvarchar](20) N'$.role',
											[Type] [nvarchar](20) N'$.type',
											[Status] [nvarchar](20) N'$.status'
										) AS [SourceMember]
						) AS [Source]
							INNER JOIN [Google].[Group]
								ON [Source].[Group_Id] = [Group].[Id]
							INNER JOIN [Google].[GroupMemberRole]
								ON [Source].[Role] = [GroupMemberRole].[Name]
			END
END
