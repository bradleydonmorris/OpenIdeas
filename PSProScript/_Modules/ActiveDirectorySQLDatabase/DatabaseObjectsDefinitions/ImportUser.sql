BEGIN
	SET NOCOUNT ON
	DECLARE @UserId [int]
	DECLARE @UserObjectGUID [uniqueidentifier] = JSON_VALUE(@UserJSON, N'$.objectGuid')
	DECLARE @UserAccountControl [int] = JSON_VALUE(@UserJSON, N'$.userAccountControl')
	SET @UserAccountControl = ISNULL(@UserAccountControl, 0)
	INSERT INTO [ActiveDirectory].[ObjectCategory]([Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				SELECT [Source].[objectCategory] AS [Name]
					FROM OPENJSON(@UserJSON)
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
					FROM OPENJSON(@UserJSON, N'$.objectClass') AS [Source]
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
					FROM OPENJSON(@UserJSON)
						WITH
						(
							[parentDistinguishedName] [nvarchar](400) N'$.parentDistinguishedName'
						) AS [Source]
						LEFT OUTER JOIN [ActiveDirectory].[OrganizationalUnit] AS [Target]
							ON [Source].[parentDistinguishedName] = [Target].[LDIFPath]
					WHERE [Target].[OrganizationalUnitId] IS NULL
			) AS [Source]
	EXEC [ActiveDirectory].[AddUserAccountControl]
		@UserAccountControl = @UserAccountControl
	INSERT INTO [ActiveDirectory].[StagedManagerialHierarchy]([InsertTimestamp], [objectGuid], [distinguishedName], [managerDistinguishedName])
		SELECT
			SYSUTCDATETIME() AS [InsertTimestamp],
			[objectGuid],
			[distinguishedName],
			[managerDistinguishedName]
			FROM OPENJSON(@UserJSON)
				WITH
				(
					[objectGuid] [uniqueidentifier] N'$.objectGuid',
					[distinguishedName] [nvarchar](400) N'$.distinguishedName',
					[managerDistinguishedName] [nvarchar](400) N'$.manager'
				) AS [Source]

	--User
	MERGE [ActiveDirectory].[User] AS [Target]
		USING
		(
			SELECT
				[OrganizationalUnit_Parent].[OrganizationalUnitId] AS [ParentOrganizationalUnitId],
				[ObjectCategory].[ObjectCategoryId],
				[UserAccountControl].[UserAccountControlId],

				[Source].[ObjectGUID], [Source].[ObjectSID], [Source].[USNCreated], [Source].[USNChanged],
				[Source].[LastLogoffTime], [Source].[LastLogonTime], [Source].[LastLogonTimestamp], [Source].[PasswordLastSetTime], [Source].[AccountExpiresTime], [Source].[WhenCreatedTime], [Source].[WhenChangedTime],
				[Source].[UserPrincipalName], [Source].[DistinguishedName], [Source].[CommonName], [Source].[SAMAccountName], [Source].[EmailAddress],
				[Source].[DisplayName], [Source].[Name], [Source].[GivenName], [Source].[MiddleName], [Source].[Surname], [Source].[Initials],
				[Source].[EmployeeNumber], [Source].[EmployeeID], [Source].[Title], [Source].[Department], [Source].[Company],
				[Source].[ExtensionAttribute1], [Source].[ExtensionAttribute2], [Source].[ExtensionAttribute3],
				[Source].[PhysicalDeliveryOfficeName], [Source].[PostalCode], [Source].[StreetAddress], [Source].[PostOfficeBox], [Source].[City], [Source].[State], [Source].[ISOAlpha2CountryCode], [Source].[ISONumericCountryCode], [Source].[CountryName],
				[Source].[HomeDrive], [Source].[HomeDirectory], [Source].[ProfilePath], [Source].[ScriptPath],
				[Source].[URL], [Source].[HomePage],
				[Source].[Description], [Source].[Info]
				FROM OPENJSON(@UserJSON)
					WITH
					(
						[ObjectGUID] [uniqueidentifier] N'$.objectGuid',
						[ObjectSID] [nvarchar](400) N'$.objectSid',

						[USNCreated] [bigint] N'$.usnCreated',
						[USNChanged] [bigint] N'$.uSNChanged',

						[LastLogoffTime] [datetime2](7) N'$.lastLogoff',
						[LastLogonTime] [datetime2](7) N'$.lastLogon',
						[LastLogonTimestamp] [datetime2](7) N'$.lastLogonTimestamp',
						[PasswordLastSetTime] [datetime2](7) N'$.pwdLastSet',
						[AccountExpiresTime] [datetime2](7) N'$.accountExpires',
						[WhenCreatedTime] [datetime2](7) N'$.whenCreated',
						[WhenChangedTime] [datetime2](7) N'$.whenChanged',

						[ObjectCategory] [nvarchar](400) N'$.objectCategory',

						[UserPrincipalName] [nvarchar](400) N'$.userPrincipalName',
						[DistinguishedName] [nvarchar](400) N'$.distinguishedName',
						[CommonName] [nvarchar](400) N'$.cn',
						[SAMAccountName] [nvarchar](400) N'$.sAMAccountName',

						[EmailAddress] [nvarchar](400) N'$.mail',

						[ParentDistinguishedName] [nvarchar](400) N'$.parentDistinguishedName',

						[DisplayName] [nvarchar](400) N'$.displayName',
						[Name] [nvarchar](400) N'$.name',
						[GivenName] [nvarchar](400) N'$.givenName',
						[MiddleName] [nvarchar](400) N'$.middleName',
						[Surname] [nvarchar](400) N'$.sn',
						[Initials] [nvarchar](400) N'$.initials',

						[EmployeeNumber] [nvarchar](400) N'$.employeeNumber',
						[EmployeeID] [nvarchar](400) N'$.employeeID',
						[Title] [nvarchar](400) N'$.title',
						[Department] [nvarchar](400) N'$.department',
						[Company] [nvarchar](400) N'$.company',

						[ExtensionAttribute1] [nvarchar](400) N'$.extensionAttribute1',
						[ExtensionAttribute2] [nvarchar](400) N'$.extensionAttribute2',
						[ExtensionAttribute3] [nvarchar](400) N'$.extensionAttribute3',

						[PhysicalDeliveryOfficeName] [nvarchar](400) N'$.physicalDeliveryOfficeName',
						[PostalCode] [nvarchar](400) N'$.postalCode',
						[StreetAddress] [nvarchar](400) N'$.streetAddress',
						[PostOfficeBox] [nvarchar](400) N'$.postOfficeBox',
						[City] [nvarchar](400) N'$.l',
						[State] [nvarchar](400) N'$.st',
						[ISOAlpha2CountryCode] [nvarchar](400) N'$.c',
						[ISONumericCountryCode] [nvarchar](400) N'$.countryCode',
						[CountryName] [nvarchar](400) N'$.co',

						[HomeDrive] [nvarchar](400) N'$.homeDrive',
						[HomeDirectory] [nvarchar](400) N'$.homeDirectory',
						[ProfilePath] [nvarchar](400) N'$.profilePath',
						[ScriptPath] [nvarchar](400) N'$.scriptPath',

						[UserAccountControl] [int] N'$.userAccountControl',

						[URL] [nvarchar](400) N'$.url',
						[HomePage] [nvarchar](400) N'$.wWWHomePage',

						[Description] [nvarchar](400) N'$.description',
						[Info] [nvarchar](400) N'$.info'
					) AS [Source]
						INNER JOIN [ActiveDirectory].[ObjectCategory]
							ON [Source].[objectCategory] = [ObjectCategory].[Name]
						INNER JOIN [ActiveDirectory].[OrganizationalUnit] AS [OrganizationalUnit_Parent]
							ON [Source].[parentDistinguishedName] = [OrganizationalUnit_Parent].[LDIFPath]
						INNER JOIN [ActiveDirectory].[UserAccountControl]
								ON [Source].[userAccountControl] = [UserAccountControl].[UserAccountControlId]
		) AS [Source]
			ON [Source].[ObjectGUID] = [Target].[ObjectGUID]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				[ParentOrganizationalUnitId], [ObjectCategoryId], [UserAccountControlId],
				[ObjectGUID], [ObjectSID], [USNCreated], [USNChanged],
				[LastLogoffTime], [LastLogonTime], [LastLogonTimestamp], [PasswordLastSetTime], [AccountExpiresTime], [WhenCreatedTime], [WhenChangedTime],
				[UserPrincipalName], [DistinguishedName], [CommonName], [SAMAccountName], [EmailAddress],
				[DisplayName], [Name], [GivenName], [MiddleName], [Surname], [Initials],
				[EmployeeNumber], [EmployeeID], [Title], [Department], [Company],
				[ExtensionAttribute1], [ExtensionAttribute2], [ExtensionAttribute3],
				[PhysicalDeliveryOfficeName], [PostalCode], [StreetAddress], [PostOfficeBox], [City], [State], [ISOAlpha2CountryCode], [ISONumericCountryCode], [CountryName],
				[HomeDrive], [HomeDirectory], [ProfilePath], [ScriptPath],
				[URL], [HomePage],
				[Description], [Info]
			)
				VALUES
				(
					[Source].[ParentOrganizationalUnitId], [Source].[ObjectCategoryId], [Source].[UserAccountControlId],
					[Source].[ObjectGUID], [Source].[ObjectSID], [Source].[USNCreated], [Source].[USNChanged],
					[Source].[LastLogoffTime], [Source].[LastLogonTime], [Source].[LastLogonTimestamp], [Source].[PasswordLastSetTime], [Source].[AccountExpiresTime], [Source].[WhenCreatedTime], [Source].[WhenChangedTime],
					[Source].[UserPrincipalName], [Source].[DistinguishedName], [Source].[CommonName], [Source].[SAMAccountName], [Source].[EmailAddress],
					[Source].[DisplayName], [Source].[Name], [Source].[GivenName], [Source].[MiddleName], [Source].[Surname], [Source].[Initials],
					[Source].[EmployeeNumber], [Source].[EmployeeID], [Source].[Title], [Source].[Department], [Source].[Company],
					[Source].[ExtensionAttribute1], [Source].[ExtensionAttribute2], [Source].[ExtensionAttribute3],
					[Source].[PhysicalDeliveryOfficeName], [Source].[PostalCode], [Source].[StreetAddress], [Source].[PostOfficeBox], [Source].[City], [Source].[State], [Source].[ISOAlpha2CountryCode], [Source].[ISONumericCountryCode], [Source].[CountryName],
					[Source].[HomeDrive], [Source].[HomeDirectory], [Source].[ProfilePath], [Source].[ScriptPath],
					[Source].[URL], [Source].[HomePage],
					[Source].[Description], [Source].[Info]
				)
		WHEN MATCHED THEN UPDATE SET
			[ParentOrganizationalUnitId] = [Source].[ParentOrganizationalUnitId], [ObjectCategoryId] = [Source].[ObjectCategoryId], [UserAccountControlId] = [Source].[UserAccountControlId],
			[ObjectGUID] = [Source].[ObjectGUID], [ObjectSID] = [Source].[ObjectSID], [USNCreated] = [Source].[USNCreated], [USNChanged] = [Source].[USNChanged],
			[LastLogoffTime] = [Source].[LastLogoffTime], [LastLogonTime] = [Source].[LastLogonTime], [LastLogonTimestamp] = [Source].[LastLogonTimestamp], [PasswordLastSetTime] = [Source].[PasswordLastSetTime], [AccountExpiresTime] = [Source].[AccountExpiresTime], [WhenCreatedTime] = [Source].[WhenCreatedTime], [WhenChangedTime] = [Source].[WhenChangedTime],
			[UserPrincipalName] = [Source].[UserPrincipalName], [DistinguishedName] = [Source].[DistinguishedName], [CommonName] = [Source].[CommonName], [SAMAccountName] = [Source].[SAMAccountName], [EmailAddress] = [Source].[EmailAddress],
			[DisplayName] = [Source].[DisplayName], [Name] = [Source].[Name], [GivenName] = [Source].[GivenName], [MiddleName] = [Source].[MiddleName], [Surname] = [Source].[Surname], [Initials] = [Source].[Initials],
			[EmployeeNumber] = [Source].[EmployeeNumber], [EmployeeID] = [Source].[EmployeeID], [Title] = [Source].[Title], [Department] = [Source].[Department], [Company] = [Source].[Company],
			[ExtensionAttribute1] = [Source].[ExtensionAttribute1], [ExtensionAttribute2] = [Source].[ExtensionAttribute2], [ExtensionAttribute3] = [Source].[ExtensionAttribute3],
			[PhysicalDeliveryOfficeName] = [Source].[PhysicalDeliveryOfficeName], [PostalCode] = [Source].[PostalCode], [StreetAddress] = [Source].[StreetAddress], [PostOfficeBox] = [Source].[PostOfficeBox], [City] = [Source].[City], [State] = [Source].[State], [ISOAlpha2CountryCode] = [Source].[ISOAlpha2CountryCode], [ISONumericCountryCode] = [Source].[ISONumericCountryCode], [CountryName] = [Source].[CountryName],
			[HomeDrive] = [Source].[HomeDrive], [HomeDirectory] = [Source].[HomeDirectory], [ProfilePath] = [Source].[ProfilePath], [ScriptPath] = [Source].[ScriptPath],
			[URL] = [Source].[URL], [HomePage] = [Source].[HomePage],
			[Description] = [Source].[Description], [Info] = [Source].[Info]
	;

	SELECT @UserId = [User].[UserId]
		FROM [ActiveDirectory].[User]
		WHERE [User].[ObjectGUID] = @UserObjectGUID

	--UserObjectClass
	DELETE
		FROM [ActiveDirectory].[UserObjectClass]
		WHERE
			[UserId] = @UserId
			AND [ObjectClassId] NOT IN
			(
				SELECT [ObjectClass].[ObjectClassId]
					FROM OPENJSON(@UserJSON)
						WITH ( [objectClass] [nvarchar](MAX) N'$.objectClass' AS JSON ) AS [Source]
							CROSS APPLY OPENJSON([Source].[objectClass]) AS [SourceObjectClass]
							INNER JOIN [ActiveDirectory].[ObjectClass]
								ON [SourceObjectClass].[value] = [ObjectClass].[Name]
			)
	INSERT INTO [ActiveDirectory].[UserObjectClass]([UserId], [ObjectClassId])
		SELECT
			[Source].[UserId],
			[Source].[ObjectClassId]
			FROM
			(
				SELECT
					[User].[UserId],
					[ObjectClass].[ObjectClassId]
					FROM OPENJSON(@UserJSON)
						WITH
						(
							[objectGuid] [uniqueidentifier] N'$.objectGuid',
							[objectClass] [nvarchar](MAX) N'$.objectClass' AS JSON
						) AS [Source]
							CROSS APPLY OPENJSON([Source].[objectClass]) AS [SourceObjectClass]
							INNER JOIN [ActiveDirectory].[ObjectClass]
								ON [SourceObjectClass].[value] = [ObjectClass].[Name]
							INNER JOIN [ActiveDirectory].[User]
								ON [Source].[objectGuid] = [User].[objectGuid]
			) AS [Source]
				LEFT OUTER JOIN [ActiveDirectory].[UserObjectClass] AS [Target]
					ON
						[Source].[UserId] = [Target].[UserId]
						AND [Source].[ObjectClassId] = [Target].[ObjectClassId]
			WHERE [Target].[UserObjectClassId] IS NULL

	--UserPhone
	DECLARE @UserPhone TABLE
	(
		[UserId] [int],
		[PhoneTypeId] [tinyint],
		[Number] [nvarchar](400),
		[NormailizedNumber] [nvarchar](400),
		[E164Format] [nvarchar](20) NULL,
		[Extension] [nvarchar](10) NULL
	)
	INSERT INTO @UserPhone([UserId], [PhoneTypeId], [Number], [NormailizedNumber], [E164Format], [Extension])
		SELECT
			[User].[UserId],
			[PhoneType].[PhoneTypeId],
			[Source].[Number],
			[Source].[NormailizedNumber],
			[ActiveDirectory].[GetE164PhoneNumber]([Source].[NormailizedNumber]) AS [E164Format],
			CASE
				WHEN CHARINDEX(N'x', [Source].[Number]) > 0
					THEN [ActiveDirectory].[GetDigitsOnly](RIGHT([Source].[Number],	LEN([Source].[Number]) - CHARINDEX(N'x', [Source].[Number])))
				ELSE NULL
			END AS [Extension]
			FROM
			(
				SELECT
					[ObjectGUID],
					[SourcePhone].[Type],
					[SourcePhone].[Number],
					CASE
						WHEN [SourcePhone].[Type] NOT IN ('IPPhone', 'OtherIPPhone')
							THEN [ActiveDirectory].[GetDigitsOnly]([SourcePhone].[Number])
						ELSE [SourcePhone].[Number]
					END AS [NormailizedNumber]
					FROM OPENJSON(@UserJSON)
						WITH
						(
							[ObjectGUID] [uniqueidentifier] N'$.objectGuid',

							[Telephone] [nvarchar](400) N'$.telephoneNumber',
							[OtherTelephone] [nvarchar](400) N'$.otherTelephone',

							[MobilePhone] [nvarchar](400) N'$.mobile',
							[OtherMobilePhone] [nvarchar](400) N'$.otherMobile',

							[Pager] [nvarchar](400) N'$.pager',
							[OtherPager] [nvarchar](400) N'$.otherPager',

							[Fax] [nvarchar](400) N'$.facsimileTelephoneNumber',
							[OtherFax] [nvarchar](400) N'$.otherFacsimileTelephoneNumber',

							[HomePhone] [nvarchar](400) N'$.homePhone',
							[OtherHomePhone] [nvarchar](400) N'$.otherHomePhone',

							[IPPhone] [nvarchar](400) N'$.ipPhone',
							[OtherIPPhone] [nvarchar](400) N'$.otherIpPhone'
						) AS [Source]
						UNPIVOT
						(
							[Number] FOR [Type] IN
							(
								[Telephone],      [MobilePhone],      [Pager],      [Fax],      [HomePhone],      [IPPhone],
								[OtherTelephone], [OtherMobilePhone], [OtherPager], [OtherFax], [OtherHomePhone], [OtherIPPhone]
							)
						) AS [SourcePhone]
			) AS [Source]
				INNER JOIN [ActiveDirectory].[User]
					ON [Source].[ObjectGUID] = [User].[ObjectGUID]
				INNER JOIN [ActiveDirectory].[PhoneType]
					ON [Source].[Type] = [PhoneType].[Name]
	DELETE
		FROM [ActiveDirectory].[UserPhone]
		WHERE
			[UserId] = @UserId
			AND [PhoneTypeId] NOT IN
			(
				SELECT DISTINCT [PhoneTypeId]
					FROM @UserPhone
			)
	MERGE [ActiveDirectory].[UserPhone] AS [Target]
		USING @UserPhone AS [Source]
			ON
				[Target].[UserId] = [Source].[UserId]
				AND [Target].[PhoneTypeId] = [Source].[PhoneTypeId]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT([UserId], [PhoneTypeId], [Number], [NormailizedNumber], [E164Format], [Extension])
				VALUES([Source].[UserId], [Source].[PhoneTypeId], [Source].[Number], [Source].[NormailizedNumber], [Source].[E164Format], [Source].[Extension])
		WHEN MATCHED THEN UPDATE SET
			[Number] = [Source].[Number],
			[NormailizedNumber] = [Source].[NormailizedNumber],
			[E164Format] = [Source].[E164Format],
			[Extension] = [Source].[Extension]
	;
END
