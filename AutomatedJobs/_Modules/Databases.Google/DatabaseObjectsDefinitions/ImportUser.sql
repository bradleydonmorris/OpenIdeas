BEGIN
	DECLARE @True [bit] = CONVERT([bit], 1, 0)
	DECLARE @False [bit] = CONVERT([bit], 0, 0)
	DECLARE @UserId [int]
	DECLARE @Id [nvarchar](50) = JSON_VALUE(@UserJSON, N'$.id')
	DECLARE @ETag [nvarchar](100) = JSON_VALUE(@UserJSON, N'$.etag')
	--If there is NOT a record with a matching Id,
	--	Or the record has a different ETag,
	--	Then import the user
	IF NOT EXISTS
	(
		SELECT 1
			FROM [Google].[User]
			WHERE
				[User].[Id] = @Id
				AND [User].[ETag] = @ETag
	)
		BEGIN
			--[Google].[User]
			MERGE INTO [Google].[User] AS [Target]
				USING
				(
					SELECT
						[OrganizationalUnit].[OrganizationalUnitId],
						[Source].[Id],
						[Source].[ETag],
						NULLIF([Source].[FirstName], N'') AS [FirstName],
						NULLIF([Source].[LastName], N'') AS [LastName],
						NULLIF([Source].[FullName], N'') AS [FullName],
						NULLIF([Source].[CustomerId], N'') AS [CustomerId],
						NULLIF([Source].[OrgUnitPath], N'') AS [OrgUnitPath],
						[Source].[LastLoginTime],
						[Source].[CreationTime],
						ISNULL([Source].[IsAdmin], @False) AS [IsAdmin],
						ISNULL([Source].[IsDelegatedAdmin], @False) AS [IsDelegatedAdmin],
						ISNULL([Source].[AgreedToTerms], @False) AS [AgreedToTerms],
						ISNULL([Source].[Suspended], @False) AS [Suspended],
						ISNULL([Source].[Archived], @False) AS [Archived],
						ISNULL([Source].[ChangePasswordAtNextLogin], @False) AS [ChangePasswordAtNextLogin],
						ISNULL([Source].[IPWhitelisted], @False) AS [IPWhitelisted],
						ISNULL([Source].[IsMailboxSetup], @False) AS [IsMailboxSetup],
						ISNULL([Source].[IsEnrolledIn2Sv], @False) AS [IsEnrolledIn2Sv],
						ISNULL([Source].[IsEnforcedIn2Sv], @False) AS [IsEnforcedIn2Sv],
						ISNULL([Source].[IncludeInGlobalAddressList], @False) AS [IncludeInGlobalAddressList]
						FROM OPENJSON(@UserJSON)
							WITH
							(
								[Id] [nvarchar](50) N'$.id',
								[ETag] [nvarchar](100) N'$.etag',
								[FirstName] [nvarchar](100) N'$.name.givenName',
								[LastName] [nvarchar](100) N'$.name.familyName',
								[FullName] [nvarchar](100) N'$.name.fullName',
								[CustomerId] [nvarchar](100) N'$.customerId',
								[OrgUnitPath] [nvarchar](400) N'$.orgUnitPath',
								[LastLoginTime] [datetime2](7) N'$.lastLoginTime',
								[CreationTime] [datetime2](7) N'$.creationTime',
								[IsAdmin] [bit] N'$.isAdmin',
								[IsDelegatedAdmin] [bit] N'$.isDelegatedAdmin',
								[AgreedToTerms] [bit] N'$.agreedToTerms',
								[Suspended] [bit] N'$.suspended',
								[Archived] [bit] N'$.archived',
								[ChangePasswordAtNextLogin] [bit] N'$.changePasswordAtNextLogin',
								[IPWhitelisted] [bit] N'$.ipWhitelisted',
								[IsMailboxSetup] [bit] N'$.isMailboxSetup',
								[IsEnrolledIn2Sv] [bit] N'$.isEnrolledIn2Sv',
								[IsEnforcedIn2Sv] [bit] N'$.isEnforcedIn2Sv',
								[IncludeInGlobalAddressList] [bit] N'$.includeInGlobalAddressList'
							) AS [Source]
							INNER JOIN [Google].[OrganizationalUnit]
								ON [Source].[OrgUnitPath] = [OrganizationalUnit].[Path]
				) AS [Source]
						ON [Target].[Id] = [Source].[Id]
					WHEN NOT MATCHED BY TARGET THEN
						INSERT ([OrganizationalUnitId], [Id], [ETag], [FirstName], [LastName], [FullName], [CustomerId], [OrgUnitPath], [LastLoginTime], [CreationTime], [IsAdmin], [IsDelegatedAdmin], [AgreedToTerms], [Suspended], [Archived], [ChangePasswordAtNextLogin], [IPWhitelisted], [IsMailboxSetup], [IsEnrolledIn2Sv], [IsEnforcedIn2Sv], [IncludeInGlobalAddressList], [ImportTime])
						VALUES ([Source].[OrganizationalUnitId], [Source].[Id], [Source].[ETag], [Source].[FirstName], [Source].[LastName], [Source].[FullName], [Source].[CustomerId], [Source].[OrgUnitPath], [Source].[LastLoginTime], [Source].[CreationTime], [Source].[IsAdmin], [Source].[IsDelegatedAdmin], [Source].[AgreedToTerms], [Source].[Suspended], [Source].[Archived], [Source].[ChangePasswordAtNextLogin], [Source].[IPWhitelisted], [Source].[IsMailboxSetup], [Source].[IsEnrolledIn2Sv], [Source].[IsEnforcedIn2Sv], [Source].[IncludeInGlobalAddressList], SYSUTCDATETIME())
					WHEN MATCHED THEN UPDATE SET
						[OrganizationalUnitId] = [Source].[OrganizationalUnitId],
						[ETag] = [Source].[ETag],
						[FirstName] = [Source].[FirstName],
						[LastName] = [Source].[LastName],
						[FullName] = [Source].[FullName],
						[CustomerId] = [Source].[CustomerId],
						[OrgUnitPath] = [Source].[OrgUnitPath],
						[LastLoginTime] = [Source].[LastLoginTime],
						[CreationTime] = [Source].[CreationTime],
						[IsAdmin] = [Source].[IsAdmin],
						[IsDelegatedAdmin] = [Source].[IsDelegatedAdmin],
						[AgreedToTerms] = [Source].[AgreedToTerms],
						[Suspended] = [Source].[Suspended],
						[Archived] = [Source].[Archived],
						[ChangePasswordAtNextLogin] = [Source].[ChangePasswordAtNextLogin],
						[IPWhitelisted] = [Source].[IPWhitelisted],
						[IsMailboxSetup] = [Source].[IsMailboxSetup],
						[IsEnrolledIn2Sv] = [Source].[IsEnrolledIn2Sv],
						[IsEnforcedIn2Sv] = [Source].[IsEnforcedIn2Sv],
						[IncludeInGlobalAddressList] = [Source].[IncludeInGlobalAddressList],
						[ImportTime] = SYSUTCDATETIME()
			;
			SELECT @UserId = [User].[UserId]
				FROM [Google].[User]
				WHERE [User].[Id] = @Id

			--Insert [Google].[EmailType]
			INSERT INTO [Google].[EmailType]
				SELECT [Source].[Name]
					FROM
					(
						SELECT DISTINCT COALESCE(NULLIF([SourceEmail].[Type], N'custom'), NULLIF([SourceEmail].[CustomType], N''), N'Unknown') AS [Name]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[emails] [nvarchar](MAX) N'$.emails' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[emails])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType'
									) AS [SourceEmail]
					) AS [Source]
						LEFT OUTER JOIN [Google].[EmailType] AS [Target]
							ON [Source].[Name] = [Target].[Name]
					WHERE [Target].[EmailTypeId] IS NULL

			--Populate @UserEmail
			DECLARE @UserEmail TABLE
			(
				[UserId] [int] NOT NULL,
				[EmailTypeId] [tinyint] NOT NULL,
				[EmailAddress] [nvarchar](max) NOT NULL,
				[IsPrimary] [bit] NOT NULL
			)
			INSERT INTO @UserEmail([UserId], [EmailTypeId], [EmailAddress], [IsPrimary])
				SELECT DISTINCT
					[User].[UserId],
					[EmailType].[EmailTypeId],
					[SourceEmailAddress].[EmailAddress],
					[SourceEmailAddress].[IsPrimary]
					FROM
					(
						SELECT
							[Source].[Id],
							[Source].[EmailAddress],
							N'Primary' AS [Type],
							@True AS [IsPrimary]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[EmailAddress] [nvarchar](320) N'$.primaryEmail'
								) AS [Source]
						UNION
						SELECT
							[Source].[Id],
							[Source].[EmailAddress],
							N'RecoveryEmail' AS [Type],
							@False AS [IsPrimary]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[EmailAddress] [nvarchar](320) N'$.recoveryEmail'
								) AS [Source]
						UNION
						SELECT
							[Source].[Id],
							[SourceEmail].[EmailAddress],
							COALESCE(NULLIF([SourceEmail].[Type], N'custom'), NULLIF([SourceEmail].[CustomType], N''), N'Unknown') AS [Type],
							ISNULL([SourceEmail].[IsPrimary], @False) AS [IsPrimary]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[emails] [nvarchar](MAX) N'$.emails' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[emails])
									WITH
									(
										[EmailAddress] [nvarchar](320) N'$.address',
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType',
										[IsPrimary] [bit] N'$.primary'
									) AS [SourceEmail]
						UNION
						SELECT
							[Source].[Id],
							[Alias].[value] AS [EmailAddress],
							N'Alias' AS [Type],
							@False AS [IsPrimary]
							FROM OPENJSON(@UserJSON)
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
							N'NonEditableAlias' AS [Type],
							@False AS [IsPrimary]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[nonEditableAliases] [nvarchar](MAX) N'$.nonEditableAliases' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[nonEditableAliases]) AS [NonEditableAlias]
					) AS [SourceEmailAddress]
						INNER JOIN [Google].[User]
							ON [SourceEmailAddress].[Id] = [User].[Id]
						INNER JOIN [Google].[EmailType]
							ON [SourceEmailAddress].[Type] = [EmailType].[Name]
					WHERE [SourceEmailAddress].[EmailAddress] IS NOT NULL
			--Delete [Google].[UserEmail]
			DELETE
				FROM [Google].[UserEmail]
				WHERE
					[UserId] = @UserId
					AND [UserEmailId] IN
					(
						SELECT [Target].[UserEmailId]
							FROM [Google].[UserEmail] AS [Target]
								LEFT OUTER JOIN @UserEmail AS [Source]
									ON
										[Target].[UserId] = [Source].[UserId]
										AND [Target].[EmailTypeId] = [Source].[EmailTypeId]
										AND [Target].[EmailAddress] = [Source].[EmailAddress]
							WHERE
								[Target].[UserId] = @UserId
								AND [Source].[EmailAddress] IS NULL
					)
			--Merge [Google].[UserEmail]
			MERGE [Google].[UserEmail] AS [Target]
				USING @UserEmail AS [Source]
					ON
						[Target].[UserId] = [Source].[UserId]
						AND [Target].[EmailTypeId] = [Source].[EmailTypeId]
						AND [Target].[EmailAddress] = [Source].[EmailAddress]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([UserId], [EmailTypeId], [EmailAddress], [IsPrimary])
					VALUES ([Source].[UserId], [Source].[EmailTypeId], [Source].[EmailAddress], [Source].[IsPrimary])
				WHEN MATCHED THEN UPDATE SET [IsPrimary] = [Source].[IsPrimary]
			;

			--Insert [Google].[PhoneType]
			INSERT INTO [Google].[PhoneType]
				SELECT [Source].[Name]
					FROM
					(
						SELECT DISTINCT COALESCE(NULLIF([SourcePhone].[Type], N'custom'), NULLIF([SourcePhone].[CustomType], N''), N'Unknown') AS [Name]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[phones] [nvarchar](MAX) N'$.phones' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[phones])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType'
									) AS [SourcePhone]
					) AS [Source]
						LEFT OUTER JOIN [Google].[PhoneType] AS [Target]
							ON [Source].[Name] = [Target].[Name]
					WHERE [Target].[PhoneTypeId] IS NULL

			--Populate @UserPhone
			DECLARE @UserPhone TABLE
			(
				[UserId] [int] NOT NULL,
				[PhoneTypeId] [tinyint] NOT NULL,
				[Number] [nvarchar](400) NOT NULL,
				[NormailizedNumber] [nvarchar](400) NOT NULL,
				[E164Format] [nvarchar](20) NULL,
				[Extension] [nvarchar](10) NULL
			)
			INSERT INTO @UserPhone([UserId], [PhoneTypeId], [Number], [NormailizedNumber], [E164Format], [Extension])
				SELECT
					[User].[UserId],
					[PhoneType].[PhoneTypeId],
					[SourcePhone].[Number],
					[SourcePhone].[NormailizedNumber],
					[Google].[GetE164PhoneNumber]([SourcePhone].[NormailizedNumber]) AS [E164Format],
					CASE
						WHEN CHARINDEX(N'x', [SourcePhone].[Number]) > 0
							THEN [Google].[GetDigitsOnly](RIGHT([SourcePhone].[Number],	LEN([SourcePhone].[Number]) - CHARINDEX(N'x', [SourcePhone].[Number])))
						ELSE NULL
					END AS [Extension]
					FROM
					(
						SELECT
							[Source].[Id],
							N'RecoveryPhone' AS [Type],
							[Source].[RecoveryPhone] AS [Number],
							[Google].[GetDigitsOnly]([Source].[RecoveryPhone]) AS [NormailizedNumber]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[RecoveryPhone] [nvarchar](100) N'$.recoveryPhone'
								) AS [Source]
						UNION
						SELECT
							[Source].[Id],
							COALESCE(NULLIF([SourcePhone].[Type], N'custom'), NULLIF([SourcePhone].[CustomType], N''), N'Unknown') AS [Type],
							[SourcePhone].[Number],
							[Google].[GetDigitsOnly]([SourcePhone].[Number]) AS [NormailizedNumber]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[phones] [nvarchar](MAX) N'$.phones' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[phones])
									WITH
									(
										[Number] [nvarchar](100) N'$.value',
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType'
									) AS [SourcePhone]
					) AS [SourcePhone]
						INNER JOIN [Google].[User]
							ON [SourcePhone].[Id] = [User].[Id]
						INNER JOIN [Google].[PhoneType]
							ON [SourcePhone].[Type] = [PhoneType].[Name]
					WHERE [SourcePhone].[Number] IS NOT NULL
			--Delete [Google].[UserPhone]
			DELETE
				FROM [Google].[UserPhone]
				WHERE
					[UserId] = @UserId
					AND [UserPhoneId] IN
					(
						SELECT [Target].[UserPhoneId]
							FROM [Google].[UserPhone] AS [Target]
								LEFT OUTER JOIN @UserPhone AS [Source]
									ON
										[Target].[UserId] = [Source].[UserId]
										AND [Target].[PhoneTypeId] = [Source].[PhoneTypeId]
										AND [Target].[Number] = [Source].[Number]
							WHERE
								[Target].[UserId] = @UserId
								AND [Source].[Number] IS NULL
					)
			--Merge [Google].[UserPhone]
			MERGE [Google].[UserPhone] AS [Target]
				USING @UserPhone AS [Source]
					ON
						[Target].[UserId] = [Source].[UserId]
						AND [Target].[PhoneTypeId] = [Source].[PhoneTypeId]
						AND [Target].[Number] = [Source].[Number]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([UserId], [PhoneTypeId], [Number], [NormailizedNumber], [E164Format], [Extension])
					VALUES ([Source].[UserId], [Source].[PhoneTypeId], [Source].[Number], [Source].[NormailizedNumber], [Source].[E164Format], [Source].[Extension])
				WHEN MATCHED THEN UPDATE SET
					[NormailizedNumber] = [Source].[NormailizedNumber],
					[E164Format] = [Source].[E164Format],
					[Extension] = [Source].[Extension]
			;

			--Insert [Google].[AddressType]
			INSERT INTO [Google].[AddressType]
				SELECT [Source].[Name]
					FROM
					(
						SELECT DISTINCT COALESCE(NULLIF([SourceAddress].[Type], N'custom'), NULLIF([SourceAddress].[CustomType], N''), N'Unknown') AS [Name]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[addresses] [nvarchar](MAX) N'$.addresses' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[addresses])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType'
									) AS [SourceAddress]
					) AS [Source]
						LEFT OUTER JOIN [Google].[AddressType] AS [Target]
							ON [Source].[Name] = [Target].[Name]
					WHERE [Target].[AddressTypeId] IS NULL

			--Populate @UserAddress
			DECLARE @UserAddress TABLE
			(
				[UserId] [int] NOT NULL,
				[AddressTypeId] [tinyint] NOT NULL,
				[HashKey] [varbinary](32),
				[StreetAddress] [nvarchar](50) NULL,
				[POBox] [nvarchar](50) NULL,
				[Locality] [nvarchar](50) NULL,
				[Region] [nvarchar](50) NULL,
				[PostalCode] [nvarchar](50) NULL,
				[CountryCode] [nvarchar](50) NULL,
				[Country] [nvarchar](50) NULL,
				[ExtendedAddress] [nvarchar](400) NULL,
				[Formatted] [nvarchar](400) NULL,
				[IsPrimary] [bit] NULL,
				[SourceIsStructured] [bit] NULL
			)
			INSERT INTO @UserAddress([UserId], [AddressTypeId], [HashKey], [StreetAddress], [POBox], [Locality], [Region], [PostalCode], [CountryCode], [Country], [ExtendedAddress], [Formatted], [IsPrimary], [SourceIsStructured])
				SELECT
					[User].[UserId],
					[AddressType].[AddressTypeId],
					CONVERT([varbinary](32), HASHBYTES('SHA_256', CONCAT(
						[Source].[StreetAddress],
						[Source].[POBox],
						[Source].[Locality],
						[Source].[Region],
						[Source].[PostalCode],
						[Source].[CountryCode],
						[Source].[Country],
						[Source].[ExtendedAddress],
						[Source].[Formatted],
						[Source].[IsPrimary],
						[Source].[SourceIsStructured]
					)), 0) AS [HashKey],
					[Source].[StreetAddress],
					[Source].[POBox],
					[Source].[Locality],
					[Source].[Region],
					[Source].[PostalCode],
					[Source].[CountryCode],
					[Source].[Country],
					[Source].[ExtendedAddress],
					[Source].[Formatted],
					[Source].[IsPrimary],
					[Source].[SourceIsStructured]
					FROM
					(
						SELECT
							[Source].[Id],
							COALESCE(NULLIF([SourceAddress].[Type], N'custom'), NULLIF([SourceAddress].[CustomType], N''), N'Unknown') AS [Type],
							NULLIF([SourceAddress].[StreetAddress], N'') AS [StreetAddress],
							NULLIF([SourceAddress].[POBox], N'') AS [POBox],
							NULLIF([SourceAddress].[Locality], N'') AS [Locality],
							NULLIF([SourceAddress].[Region], N'') AS [Region],
							NULLIF([SourceAddress].[PostalCode], N'') AS [PostalCode],
							NULLIF([SourceAddress].[CountryCode], N'') AS [CountryCode],
							NULLIF([SourceAddress].[Country], N'') AS [Country],
							NULLIF([SourceAddress].[ExtendedAddress], N'') AS [ExtendedAddress],
							NULLIF([SourceAddress].[Formatted], N'') AS [Formatted],
							ISNULL([SourceAddress].[IsPrimary], @False) AS [IsPrimary],
							NULLIF([SourceAddress].[SourceIsStructured], N'') AS [SourceIsStructured]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[addresses] [nvarchar](MAX) N'$.addresses' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[addresses])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType',
										[StreetAddress] [nvarchar](50) N'$.streetAddress',
										[POBox] [nvarchar](50) N'$.poBox',
										[Locality] [nvarchar](50) N'$.locality',
										[Region] [nvarchar](50) N'$.region',
										[PostalCode] [nvarchar](50) N'$.postalCode',
										[CountryCode] [nvarchar](50) N'$.countryCode',
										[Country] [nvarchar](50) N'$.country',
										[ExtendedAddress] [nvarchar](400) N'$.extendedAddress',
										[Formatted] [nvarchar](400) N'$.formatted',
										[IsPrimary] [bit] N'$.primary',
										[SourceIsStructured] [bit] N'$.sourceIsStructured'
									) AS [SourceAddress]
					) AS [Source]
						INNER JOIN [Google].[User]
							ON [Source].[Id] = [User].[Id]
						INNER JOIN [Google].[AddressType]
							ON [Source].[Type] = [AddressType].[Name]
			--Merge [Google].[UserAddress]
			DELETE
				FROM [Google].[UserAddress]
				WHERE
					[UserId] = @UserId
					AND [UserAddressId] IN
					(
						SELECT [Target].[UserAddressId]
							FROM [Google].[UserAddress] AS [Target]
								LEFT OUTER JOIN @UserAddress AS [Source]
									ON
										[Target].[UserId] = [Source].[UserId]
										AND [Target].[AddressTypeId] = [Source].[AddressTypeId]
										AND [Target].[HashKey] = [Source].[HashKey]
							WHERE
								[Target].[UserId] = @UserId
								AND [Source].[HashKey] IS NULL
					)
			--Merge [Google].[UserAddress]
			MERGE [Google].[UserAddress] AS [Target]
				USING @UserAddress AS [Source]
					ON
						[Target].[UserId] = [Source].[UserId]
						AND [Target].[AddressTypeId] = [Source].[AddressTypeId]
						AND [Target].[HashKey] = [Source].[HashKey]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([UserId], [AddressTypeId], [HashKey], [StreetAddress], [POBox], [Locality], [Region], [PostalCode], [CountryCode], [Country], [ExtendedAddress], [Formatted], [IsPrimary], [SourceIsStructured])
					VALUES ([Source].[UserId], [Source].[AddressTypeId], [Source].[HashKey], [Source].[StreetAddress], [Source].[POBox], [Source].[Locality], [Source].[Region], [Source].[PostalCode], [Source].[CountryCode], [Source].[Country], [Source].[ExtendedAddress], [Source].[Formatted], [Source].[IsPrimary], [Source].[SourceIsStructured])
				WHEN MATCHED THEN UPDATE SET
					[StreetAddress] = [Source].[StreetAddress],
					[POBox] = [Source].[POBox],
					[Locality] = [Source].[Locality],
					[Region] = [Source].[Region],
					[PostalCode] = [Source].[PostalCode],
					[CountryCode] = [Source].[CountryCode],
					[Country] = [Source].[Country],
					[ExtendedAddress] = [Source].[ExtendedAddress],
					[Formatted] = [Source].[Formatted],
					[IsPrimary] = [Source].[IsPrimary],
					[SourceIsStructured] = [Source].[SourceIsStructured]
			;

			--Insert [Google].[OrganizationType]
			INSERT INTO [Google].[OrganizationType]
				SELECT [Source].[Name]
					FROM
					(
						SELECT N'Unknown' AS [Name]
						UNION SELECT DISTINCT COALESCE(NULLIF([SourceOrganization].[Type], N'custom'), NULLIF([SourceOrganization].[CustomType], N''), N'Unknown') AS [Name]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[organizationes] [nvarchar](MAX) N'$.organizationes' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[organizationes])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType'
									) AS [SourceOrganization]
					) AS [Source]
						LEFT OUTER JOIN [Google].[OrganizationType] AS [Target]
							ON [Source].[Name] = [Target].[Name]
					WHERE [Target].[OrganizationTypeId] IS NULL

			--Populate @UserOrganization
			DECLARE @UserOrganization TABLE
			(
				[UserOrganizationId] [int] IDENTITY(1, 1) NOT NULL,
				[UserId] [int] NOT NULL,
				[OrganizationTypeId] [tinyint] NOT NULL,
				[HashKey] [varbinary](32) NULL,
				[Title] [nvarchar](100) NULL,
				[Name] [nvarchar](100) NULL,
				[Description] [nvarchar](100) NULL,
				[Department] [nvarchar](100) NULL,
				[Domain] [nvarchar](100) NULL,
				[IsPrimary] [bit] NULL,
				[CostCenter] [nvarchar](100) NULL,
				[Symbol] [nvarchar](50) NULL,
				[Location] [nvarchar](100) NULL,
				[FullTimeEquivalent] [int] NULL
			)
			INSERT INTO @UserOrganization([UserId], [OrganizationTypeId], [HashKey], [Title], [Name], [Description], [Department], [Domain], [IsPrimary], [CostCenter], [Symbol], [Location], [FullTimeEquivalent])
				SELECT
					[User].[UserId],
					[OrganizationType].[OrganizationTypeId],
					CONVERT([varbinary](32), HASHBYTES('SHA2_256', CONCAT(
						[Source].[Title],
						[Source].[Name],
						[Source].[Description],
						[Source].[Department],
						[Source].[Domain],
						[Source].[IsPrimary],
						[Source].[CostCenter],
						[Source].[Symbol],
						[Source].[Location],
						[Source].[FullTimeEquivalent]
					)), 0) AS [HashKey],
					[Source].[Title],
					[Source].[Name],
					[Source].[Description],
					[Source].[Department],
					[Source].[Domain],
					[Source].[IsPrimary],
					[Source].[CostCenter],
					[Source].[Symbol],
					[Source].[Location],
					[Source].[FullTimeEquivalent]
					FROM
					(
						SELECT
							[Source].[Id],
							COALESCE(NULLIF([SourceOrganization].[Type], N'custom'), NULLIF([SourceOrganization].[CustomType], N''), N'Unknown') AS [Type],
							NULLIF([SourceOrganization].[Title], N'') AS [Title],
							NULLIF([SourceOrganization].[Name], N'') AS [Name],
							NULLIF([SourceOrganization].[Description], N'') AS [Description],
							NULLIF([SourceOrganization].[Department], N'') AS [Department],
							NULLIF([SourceOrganization].[Domain], N'') AS [Domain],
							NULLIF([SourceOrganization].[IsPrimary], @False) AS [IsPrimary],
							NULLIF([SourceOrganization].[CostCenter], N'') AS [CostCenter],
							NULLIF([SourceOrganization].[Symbol], N'') AS [Symbol],
							NULLIF([SourceOrganization].[Location], N'') AS [Location],
							NULLIF([SourceOrganization].[FullTimeEquivalent], N'') AS [FullTimeEquivalent]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[organizations] [nvarchar](MAX) N'$.organizations' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[organizations])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType',
										[Title] [nvarchar](100) N'$.title',
										[Name] [nvarchar](100) N'$.name',
										[Description] [nvarchar](100) N'$.description',
										[Department] [nvarchar](100) N'$.department',
										[Domain] [nvarchar](100) N'$.domain',
										[IsPrimary] [bit] N'$.primary',
										[CostCenter] [nvarchar](100) N'$.costCenter',
										[Symbol] [nvarchar](50) N'$.symbol',
										[Location] [nvarchar](100) N'$.location',
										[FullTimeEquivalent] [int] N'$.fullTimeEquivalent'
									) AS [SourceOrganization]
					) AS [Source]
					INNER JOIN [Google].[User]
						ON [Source].[Id] = [User].[Id]
					INNER JOIN [Google].[OrganizationType]
						ON [Source].[Type] = [OrganizationType].[Name]
			--Merge [Google].[UserOrganization]
			DELETE
				FROM [Google].[UserOrganization]
				WHERE
					[UserId] = @UserId
					AND [UserOrganizationId] IN
					(
						SELECT [Target].[UserOrganizationId]
							FROM [Google].[UserOrganization] AS [Target]
								LEFT OUTER JOIN @UserOrganization AS [Source]
									ON
										[Target].[UserId] = [Source].[UserId]
										AND [Target].[OrganizationTypeId] = [Source].[OrganizationTypeId]
										AND [Target].[HashKey] = [Source].[HashKey]
							WHERE
								[Target].[UserId] = @UserId
								AND [Source].[HashKey] IS NULL
					)
			--Merge [Google].[UserOrganization]
			MERGE [Google].[UserOrganization] AS [Target]
				USING @UserOrganization AS [Source]
					ON
						[Target].[UserId] = [Source].[UserId]
						AND [Target].[OrganizationTypeId] = [Source].[OrganizationTypeId]
						AND [Target].[HashKey] = [Source].[HashKey]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([UserId], [OrganizationTypeId], [HashKey], [Title], [Name], [Description], [Department], [Domain], [IsPrimary], [CostCenter], [Symbol], [Location], [FullTimeEquivalent])
					VALUES ([Source].[UserId], [Source].[OrganizationTypeId], [Source].[HashKey], [Source].[Title], [Source].[Name], [Source].[Description], [Source].[Department], [Source].[Domain], [Source].[IsPrimary], [Source].[CostCenter], [Source].[Symbol], [Source].[Location], [Source].[FullTimeEquivalent])
				WHEN MATCHED THEN UPDATE SET
					[Title] = [Source].[Title],
					[Name] = [Source].[Name],
					[Description] = [Source].[Description],
					[Department] = [Source].[Department],
					[Domain] = [Source].[Domain],
					[IsPrimary] = [Source].[IsPrimary],
					[CostCenter] = [Source].[CostCenter],
					[Symbol] = [Source].[Symbol],
					[Location] = [Source].[Location],
					[FullTimeEquivalent] = [Source].[FullTimeEquivalent]
			;

			--Populate @UserLanguage
			DECLARE @UserLanguage TABLE
			(
				[UserId] [int] NOT NULL,
				[LanguageId] [int] NOT NULL,
				[HashKey] [varbinary](32) NULL,
				[CustomLanguage] [nvarchar](100) NULL,
				[Preference] [nvarchar](100) NULL
			)
			INSERT INTO @UserLanguage([UserId], [LanguageId], [HashKey], [CustomLanguage], [Preference])
				SELECT
					[User].[UserId],
					[Language].[LanguageId],
					CONVERT([varbinary](32), HASHBYTES('SHA_256', CONCAT(
						[Source].[CustomLanguage],
						[Source].[Preference]
					)), 0) AS [HashKey],
					[Source].[CustomLanguage],
					[Source].[Preference]
					FROM
					(
						SELECT
							[Source].[Id],
							ISNULL(NULLIF([SourceLanguage].[LanguageCode], N''), N'UNKNOWN') AS [Type],
							[SourceLanguage].[LanguageCode],
							NULLIF([SourceLanguage].[CustomLanguage], N'') AS [CustomLanguage],
							NULLIF([SourceLanguage].[Preference], N'') AS [Preference]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[languages] [nvarchar](MAX) N'$.languages' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[languages])
									WITH
									(
										[CustomLanguage] [nvarchar](100) N'$.customLanguage',
										[LanguageCode] [nvarchar](100) N'$.languageCode',
										[Preference] [nvarchar](100) N'$.preference'
									) AS [SourceLanguage]
					) AS [Source]
						INNER JOIN [Google].[User]
							ON [Source].[Id] = [User].[Id]
						INNER JOIN [Google].[Language]
							ON [Source].[LanguageCode] = [Language].[Code]
			--Merge [Google].[UserLanguage]
			DELETE
				FROM [Google].[UserLanguage]
				WHERE
					[UserId] = @UserId
					AND [UserLanguageId] IN
					(
						SELECT [Target].[UserLanguageId]
							FROM [Google].[UserLanguage] AS [Target]
								LEFT OUTER JOIN @UserLanguage AS [Source]
									ON
										[Target].[UserId] = [Source].[UserId]
										AND [Target].[LanguageId] = [Source].[LanguageId]
										AND [Target].[HashKey] = [Source].[HashKey]
							WHERE
								[Target].[UserId] = @UserId
								AND [Source].[HashKey] IS NULL
					)
			--Merge [Google].[UserLanguage]
			MERGE [Google].[UserLanguage] AS [Target]
				USING @UserLanguage AS [Source]
					ON
						[Target].[UserId] = [Source].[UserId]
						AND [Target].[LanguageId] = [Source].[LanguageId]
						AND [Target].[HashKey] = [Source].[HashKey]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([UserId], [LanguageId], [HashKey], [CustomLanguage], [Preference])
					VALUES ([Source].[UserId], [Source].[LanguageId], [Source].[HashKey], [Source].[CustomLanguage], [Source].[Preference])
				WHEN MATCHED THEN UPDATE SET
					[CustomLanguage] = [Source].[CustomLanguage],
					[Preference] = [Source].[Preference]
			;

			--Insert [Google].[ExternalIdentifierType]
			INSERT INTO [Google].[ExternalIdentifierType]
				SELECT [Source].[Name]
					FROM
					(
						SELECT DISTINCT COALESCE(NULLIF([SourceExternalIdentifier].[Type], N'custom'), NULLIF([SourceExternalIdentifier].[CustomType], N''), N'Unknown') AS [Name]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[externalIds] [nvarchar](MAX) N'$.externalIds' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[externalIds])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType'
									) AS [SourceExternalIdentifier]
					) AS [Source]
						LEFT OUTER JOIN [Google].[ExternalIdentifierType] AS [Target]
							ON [Source].[Name] = [Target].[Name]
					WHERE [Target].[ExternalIdentifierTypeId] IS NULL

			--Populate @UserExternalIdentifier
			DECLARE @UserExternalIdentifier TABLE
			(
				[UserId] [int] NOT NULL,
				[ExternalIdentifierTypeId] [tinyint] NOT NULL,
				[Value] [nvarchar](100) NULL
			)
			INSERT INTO @UserExternalIdentifier([UserId], [ExternalIdentifierTypeId], [Value])
				SELECT
					[User].[UserId],
					[ExternalIdentifierType].[ExternalIdentifierTypeId],
					[Value]
					FROM
					(
						SELECT
							[Source].[Id],
							COALESCE(NULLIF([SourceExternalId].[Type], N'custom'), NULLIF([SourceExternalId].[CustomType], N''), N'Unknown') AS [Type],
							NULLIF([SourceExternalId].[Value], N'') AS [Value]
							FROM OPENJSON(@UserJSON)
								WITH
								(
									[Id] [nvarchar](50) N'$.id',
									[externalIds] [nvarchar](MAX) N'$.externalIds' AS JSON
								) AS [Source]
								CROSS APPLY OPENJSON([Source].[externalIds])
									WITH
									(
										[Type] [nvarchar](50) N'$.type',
										[CustomType] [nvarchar](50) N'$.customType',
										[Value] [nvarchar](100) N'$.value'
									) AS [SourceExternalId]
					) AS [Source]
						INNER JOIN [Google].[User]
							ON [User].[Id] = [Source].[Id]
						INNER JOIN [Google].[ExternalIdentifierType]
							ON [Source].[Type] = [ExternalIdentifierType].[Name]
					WHERE [Source].[Value] IS NOT NULL
			--Delete [Google].[UserExternalIdentifier]
			DELETE
				FROM [Google].[UserExternalIdentifier]
				WHERE
					[UserId] = @UserId
					AND [UserExternalIdentifierId] IN
					(
						SELECT [Target].[UserExternalIdentifierId]
							FROM [Google].[UserExternalIdentifier] AS [Target]
								LEFT OUTER JOIN @UserExternalIdentifier AS [Source]
									ON
										[Target].[UserId] = [Source].[UserId]
										AND [Target].[ExternalIdentifierTypeId] = [Source].[ExternalIdentifierTypeId]
										AND [Target].[Value] = [Source].[Value]
							WHERE
								[Target].[UserId] = @UserId
								AND [Source].[Value] IS NULL
					)
			--Merge [Google].[UserExternalIdentifier]
			MERGE [Google].[UserExternalIdentifier] AS [Target]
				USING @UserExternalIdentifier AS [Source]
					ON
						[Target].[UserId] = [Source].[UserId]
						AND [Target].[ExternalIdentifierTypeId] = [Source].[ExternalIdentifierTypeId]
						AND [Target].[Value] = [Source].[Value]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([UserId], [ExternalIdentifierTypeId], [Value])
					VALUES ([Source].[UserId], [Source].[ExternalIdentifierTypeId], [Source].[Value])
				WHEN MATCHED THEN UPDATE SET
					[Value] = [Source].[Value]
			;
		END
END
