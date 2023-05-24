/*****************************************************************************************************************************************************
*                                                                                                                                                    *
* Name                 Value                                                                                                                         *
* -------------------- ----------------------------------------------------------------------------------------------------------------------------- *
* Schema               ActiveDirectory                                                                                                               *
* Input Folder Path    C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Modules\Databases.ActiveDirectory                                       *
* Output Script Path   C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Modules\Databases.ActiveDirectory\Output.sql                            *
* Clear Structure      Yes                                                                                                                           *
* Drop Schema          Yes                                                                                                                           *
* Heap File Group      PRIMARY                                                                                                                       *
* Index File Group     PRIMARY                                                                                                                       *
* Lob File Group       PRIMARY                                                                                                                       *
*                                                                                                                                                    *
*****************************************************************************************************************************************************/

GO
--Drop Procedure [ActiveDirectory].[ImportUser]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[ImportUser]
GO
--Drop Procedure [ActiveDirectory].[ImportGroup]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[ImportGroup]
GO
--Drop Procedure [ActiveDirectory].[Temmtp]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[Temmtp]
GO
--Drop Procedure [ActiveDirectory].[RebuildIndexes]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[RebuildIndexes]
GO
--Drop Procedure [ActiveDirectory].[ProcessManagerialChanges]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[ProcessManagerialChanges]
GO
--Drop Procedure [ActiveDirectory].[ProcessGroupMembershipChanges]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[ProcessGroupMembershipChanges]
GO
--Drop Procedure [ActiveDirectory].[ProcessGroupManagerChanges]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[ProcessGroupManagerChanges]
GO
--Drop Procedure [ActiveDirectory].[GetUserLastWhenChangedTime]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[GetUserLastWhenChangedTime]
GO
--Drop Procedure [ActiveDirectory].[GetGroupLastWhenChangedTime]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[GetGroupLastWhenChangedTime]
GO
--Drop Procedure [ActiveDirectory].[AddUserAccountControl]
GO
DROP PROCEDURE IF EXISTS [ActiveDirectory].[AddUserAccountControl]
GO
--Drop Function [ActiveDirectory].[Temsdfasdf]
GO
DROP FUNCTION IF EXISTS [ActiveDirectory].[Temsdfasdf]
GO
--Drop Function [ActiveDirectory].[GetNaturalPathFromLDIFPath]
GO
DROP FUNCTION IF EXISTS [ActiveDirectory].[GetNaturalPathFromLDIFPath]
GO
--Drop Function [ActiveDirectory].[GetE164PhoneNumber]
GO
DROP FUNCTION IF EXISTS [ActiveDirectory].[GetE164PhoneNumber]
GO
--Drop Function [ActiveDirectory].[GetDigitsOnly]
GO
DROP FUNCTION IF EXISTS [ActiveDirectory].[GetDigitsOnly]
GO
--Drop Table [ActiveDirectory].[UserPhone]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[UserPhone]
GO
--Drop Table [ActiveDirectory].[UserObjectClass]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[UserObjectClass]
GO
--Drop Table [ActiveDirectory].[temp]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[temp]
GO
--Drop Table [ActiveDirectory].[ManagerialHierarchy]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[ManagerialHierarchy]
GO
--Drop Table [ActiveDirectory].[GroupObjectClass]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[GroupObjectClass]
GO
--Drop Table [ActiveDirectory].[GroupMembershipUser]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[GroupMembershipUser]
GO
--Drop Table [ActiveDirectory].[GroupMembershipGroup]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[GroupMembershipGroup]
GO
--Drop Table [ActiveDirectory].[GroupManagerUser]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[GroupManagerUser]
GO
--Drop Table [ActiveDirectory].[GroupManagerGroup]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[GroupManagerGroup]
GO
--Drop Table [ActiveDirectory].[User]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[User]
GO
--Drop Table [ActiveDirectory].[Group]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[Group]
GO
--Drop Table [ActiveDirectory].[UserAccountControlFlag]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[UserAccountControlFlag]
GO
--Drop Table [ActiveDirectory].[UserAccountControl]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[UserAccountControl]
GO
--Drop Table [ActiveDirectory].[tempHeap]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[tempHeap]
GO
--Drop Table [ActiveDirectory].[StagedManagerialHierarchy]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[StagedManagerialHierarchy]
GO
--Drop Table [ActiveDirectory].[StagedGroupMembership]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[StagedGroupMembership]
GO
--Drop Table [ActiveDirectory].[StagedGroupManager]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[StagedGroupManager]
GO
--Drop Table [ActiveDirectory].[PhoneType]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[PhoneType]
GO
--Drop Table [ActiveDirectory].[OrganizationalUnit]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[OrganizationalUnit]
GO
--Drop Table [ActiveDirectory].[ObjectClass]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[ObjectClass]
GO
--Drop Table [ActiveDirectory].[ObjectCategory]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[ObjectCategory]
GO
--Drop Table [ActiveDirectory].[GroupType]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[GroupType]
GO
--Drop Table [ActiveDirectory].[Attribute]
GO
DROP TABLE IF EXISTS [ActiveDirectory].[Attribute]
GO
--Drop Schema [ActiveDirectory]
GO
DROP SCHEMA IF EXISTS [ActiveDirectory]
GO
--Drop Schema [ActiveDirectory]
GO
CREATE SCHEMA [ActiveDirectory]
GO
--Create Table [ActiveDirectory].[Attribute]
GO
CREATE TABLE [ActiveDirectory].[Attribute]
(
	[AttributeId] [int] IDENTITY(1, 1) NOT NULL,
	[Group] [tinyint] NOT NULL,
	[Sequence] [tinyint] NOT NULL,
	[ActiveDirectoryName] [sys].[sysname] NOT NULL,
	[Name] [sys].[sysname] NOT NULL,
	[DataType] [sys].[sysname] NOT NULL,
	CONSTRAINT [PK_Attribute]
		PRIMARY KEY CLUSTERED ([AttributeId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[GroupType]
GO
CREATE TABLE [ActiveDirectory].[GroupType]
(
	[GroupTypeId] [int] NOT NULL,
	[Category] [nvarchar](20) NOT NULL,
	[Scope] [nvarchar](20) NOT NULL,
	CONSTRAINT [PK_GroupType]
		PRIMARY KEY CLUSTERED ([GroupTypeId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[ObjectCategory]
GO
CREATE TABLE [ActiveDirectory].[ObjectCategory]
(
	[ObjectCategoryId] [int] IDENTITY(1, 1) NOT NULL,
	[Name] [sys].[sysname] NOT NULL,
	CONSTRAINT [PK_ObjectCategory]
		PRIMARY KEY CLUSTERED ([ObjectCategoryId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[ObjectCategory].[UX_ObjectCategory_Key]
GO
CREATE UNIQUE [UX_ObjectCategory_Key]
	ON [ActiveDirectory].[ObjectCategory]	([Name] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[ObjectClass]
GO
CREATE TABLE [ActiveDirectory].[ObjectClass]
(
	[ObjectClassId] [int] IDENTITY(1, 1) NOT NULL,
	[Name] [sys].[sysname] NOT NULL,
	CONSTRAINT [PK_ObjectClass]
		PRIMARY KEY CLUSTERED ([ObjectClassId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[ObjectClass].[UX_ObjectClass_Key]
GO
CREATE UNIQUE [UX_ObjectClass_Key]
	ON [ActiveDirectory].[ObjectClass]	([Name] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[OrganizationalUnit]
GO
CREATE TABLE [ActiveDirectory].[OrganizationalUnit]
(
	[OrganizationalUnitId] [int] IDENTITY(1, 1) NOT NULL,
	[LDIFPath] [nvarchar](400) NOT NULL,
	[NaturalPath] [nvarchar](400) NOT NULL,
	CONSTRAINT [PK_OrganizationalUnit]
		PRIMARY KEY CLUSTERED ([OrganizationalUnitId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[OrganizationalUnit].[UX_OrganizationalUnit_Key]
GO
CREATE UNIQUE [UX_OrganizationalUnit_Key]
	ON [ActiveDirectory].[OrganizationalUnit]	([LDIFPath] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[PhoneType]
GO
CREATE TABLE [ActiveDirectory].[PhoneType]
(
	[PhoneTypeId] [tinyint] IDENTITY(1, 1) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	CONSTRAINT [PK_PhoneType]
		PRIMARY KEY CLUSTERED ([PhoneTypeId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[PhoneType].[UX_PhoneType_Key]
GO
CREATE UNIQUE [UX_PhoneType_Key]
	ON [ActiveDirectory].[PhoneType]	([Name] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[StagedGroupManager]
GO
CREATE TABLE [ActiveDirectory].[StagedGroupManager]
(
	[StagedGroupManagerId] [int] IDENTITY(1, 1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[ObjectGUID] [uniqueidentifier] NOT NULL,
	[ManagerDistinguishedName] [nvarchar](400) NULL,
	CONSTRAINT [PK_StagedGroupManager]
		PRIMARY KEY CLUSTERED ([StagedGroupManagerId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[StagedGroupMembership]
GO
CREATE TABLE [ActiveDirectory].[StagedGroupMembership]
(
	[StagedGroupMembershipId] [int] IDENTITY(1, 1) NOT NULL,
	[IsProcessed] [bit] NULL
		CONSTRAINT [DF_StagedGroupMembership_IsProcessed] DEFAULT ((0)),
	[InsertTimestamp] [datetime2](7) NOT NULL,
	[GroupId] [int] NOT NULL,
	[ObjectGUID] [uniqueidentifier] NOT NULL,
	[MemberDistinguishedName] [nvarchar](400) NOT NULL,
	CONSTRAINT [PK_StagedGroupMembership]
		PRIMARY KEY CLUSTERED ([StagedGroupMembershipId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[StagedManagerialHierarchy]
GO
CREATE TABLE [ActiveDirectory].[StagedManagerialHierarchy]
(
	[StagedManagerialHierarchyId] [int] IDENTITY(1, 1) NOT NULL,
	[IsProcessed] [bit] NULL
		CONSTRAINT [DF_StagedManagerialHierarchy_IsProcessed] DEFAULT ((0)),
	[InsertTimestamp] [datetime2](7) NOT NULL,
	[objectGuid] [uniqueidentifier] NOT NULL,
	[distinguishedName] [nvarchar](400) NULL,
	[managerDistinguishedName] [nvarchar](400) NULL,
	CONSTRAINT [PK_StagedManagerialHierarchy]
		PRIMARY KEY CLUSTERED ([StagedManagerialHierarchyId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[tempHeap]
GO
CREATE TABLE [ActiveDirectory].[tempHeap]
(
	[tempHeapId] [int] IDENTITY(1, 1) NOT NULL,
	[u] [uniqueidentifier] NOT NULL ROWGUIDCOL,
	[GroupId] [int] NOT NULL,
	[t] [sys].[sysname] NOT NULL
) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[tempHeap].[UX_tempHeap_Key]
GO
CREATE UNIQUE [UX_tempHeap_Key]
	ON [ActiveDirectory].[tempHeap]	([GroupId] DESC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[tempHeap].[IX_tempHeap_GroupIdt]
GO
CREATE [IX_tempHeap_GroupIdt]
	ON [ActiveDirectory].[tempHeap]
	(
		[GroupId] DESC,
		[t] ASC
	)
	INCLUDE ([u])
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[UserAccountControl]
GO
CREATE TABLE [ActiveDirectory].[UserAccountControl]
(
	[UserAccountControlId] [int] NOT NULL,
	[LoginScriptWillRun] [bit] NOT NULL,
	[AccountIsDisabled] [bit] NOT NULL,
	[HomeDirectoryIsRequire] [bit] NOT NULL,
	[AccountIsLockedOut] [bit] NOT NULL,
	[PasswordIsNotRequired] [bit] NOT NULL,
	[UserCannotChangePassword] [bit] NOT NULL,
	[UserCanSendEncryptedPassword] [bit] NOT NULL,
	[AccountFor MatchingAccountInTrustedDomain] [bit] NOT NULL,
	[NormalAccount] [bit] NOT NULL,
	[InternalDomainTrustAccount] [bit] NOT NULL,
	[WorkstationTrustAccount] [bit] NOT NULL,
	[ServerTrustAccount] [bit] NOT NULL,
	[PasswordNeverExpires] [bit] NOT NULL,
	[MajorityNodeSetLogonAccount] [bit] NOT NULL,
	[SmartcardIsRequired] [bit] NOT NULL,
	[AccountIsTrustedForDelegation] [bit] NOT NULL,
	[AccountIsNotDelegated] [bit] NOT NULL,
	[OnlyAllowDataEncryptionStandardKeyTypes] [bit] NOT NULL,
	[DoNotRequireKerberosPerAuthorization] [bit] NOT NULL,
	[PasswordHasExpired] [bit] NOT NULL,
	[AccountIsTrustedForAuthenticationDelegation] [bit] NOT NULL,
	[AccountIsReadOnlyDomainController] [bit] NOT NULL,
	CONSTRAINT [PK_UserAccountControl]
		PRIMARY KEY CLUSTERED ([UserAccountControlId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[UserAccountControlFlag]
GO
CREATE TABLE [ActiveDirectory].[UserAccountControlFlag]
(
	[UserAccountControlFlagId] [int] NOT NULL,
	[Name] [sys].[sysname] NOT NULL,
	[HumanReadableName] [sys].[sysname] NOT NULL,
	[Description] [nvarchar](400) NOT NULL,
	CONSTRAINT [PK_UserAccountControlFlag]
		PRIMARY KEY CLUSTERED ([UserAccountControlFlagId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY]
) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[UserAccountControlFlag].[UX_UserAccountControlFlag_Key]
GO
CREATE UNIQUE [UX_UserAccountControlFlag_Key]
	ON [ActiveDirectory].[UserAccountControlFlag]	([Name] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[Group]
GO
CREATE TABLE [ActiveDirectory].[Group]
(
	[GroupId] [int] IDENTITY(1, 1) NOT NULL,
	[ParentOrganizationalUnitId] [int] NOT NULL,
	[ObjectCategoryId] [int] NOT NULL,
	[GroupTypeId] [int] NOT NULL,
	[ObjectGUID] [uniqueidentifier] NULL,
	[ObjectSID] [nvarchar](400) NULL,
	[USNCreated] [bigint] NULL,
	[USNChanged] [bigint] NULL,
	[WhenCreatedTime] [datetime2](7) NULL,
	[WhenChangedTime] [datetime2](7) NULL,
	[DistinguishedName] [nvarchar](400) NULL,
	[CommonName] [nvarchar](400) NULL,
	[SAMAccountName] [nvarchar](400) NULL,
	[EmailAddress] [nvarchar](400) NULL,
	[DisplayName] [nvarchar](400) NULL,
	[Name] [nvarchar](400) NULL,
	[Description] [nvarchar](400) NULL,
	[Info] [nvarchar](400) NULL,
	CONSTRAINT [PK_Group]
		PRIMARY KEY CLUSTERED ([GroupId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_Group_OrganizationalUnit_Parent]
		FOREIGN KEY ([ParentOrganizationalUnitId])
		REFERENCES [ActiveDirectory].[OrganizationalUnit] ([OrganizationalUnitId])
,
	CONSTRAINT [FK_Group_ObjectCategory]
		FOREIGN KEY ([ObjectCategoryId])
		REFERENCES [ActiveDirectory].[ObjectCategory] ([ObjectCategoryId])
,
	CONSTRAINT [FK_Group_GroupType]
		FOREIGN KEY ([GroupTypeId])
		REFERENCES [ActiveDirectory].[GroupType] ([GroupTypeId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[Group].[UX_Group_Key1]
GO
CREATE UNIQUE [UX_Group_Key1]
	ON [ActiveDirectory].[Group]	([ObjectGUID] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[Group].[UX_Group_Key2]
GO
CREATE UNIQUE [UX_Group_Key2]
	ON [ActiveDirectory].[Group]	([DistinguishedName] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[Group].[IX_Group_ParentOrganizationalUnitId]
GO
CREATE [IX_Group_ParentOrganizationalUnitId]
	ON [ActiveDirectory].[Group]	([ParentOrganizationalUnitId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[Group].[IX_Group_ObjectCategoryId]
GO
CREATE [IX_Group_ObjectCategoryId]
	ON [ActiveDirectory].[Group]	([ObjectCategoryId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[Group].[IX_Group_GroupTypeId]
GO
CREATE [IX_Group_GroupTypeId]
	ON [ActiveDirectory].[Group]	([GroupTypeId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[User]
GO
CREATE TABLE [ActiveDirectory].[User]
(
	[UserId] [int] IDENTITY(1, 1) NOT NULL,
	[ParentOrganizationalUnitId] [int] NOT NULL,
	[ObjectCategoryId] [int] NOT NULL,
	[UserAccountControlId] [int] NOT NULL,
	[ObjectGUID] [uniqueidentifier] NULL,
	[ObjectSID] [nvarchar](400) NULL,
	[USNCreated] [bigint] NULL,
	[USNChanged] [bigint] NULL,
	[LastLogoffTime] [datetime2](7) NULL,
	[LastLogonTime] [datetime2](7) NULL,
	[LastLogonTimestamp] [datetime2](7) NULL,
	[PasswordLastSetTime] [datetime2](7) NULL,
	[AccountExpiresTime] [datetime2](7) NULL,
	[WhenCreatedTime] [datetime2](7) NULL,
	[WhenChangedTime] [datetime2](7) NULL,
	[UserPrincipalName] [nvarchar](400) NULL,
	[DistinguishedName] [nvarchar](400) NULL,
	[CommonName] [nvarchar](400) NULL,
	[SAMAccountName] [nvarchar](400) NULL,
	[EmailAddress] [nvarchar](400) NULL,
	[DisplayName] [nvarchar](400) NULL,
	[Name] [nvarchar](400) NULL,
	[GivenName] [nvarchar](400) NULL,
	[MiddleName] [nvarchar](400) NULL,
	[Surname] [nvarchar](400) NULL,
	[Initials] [nvarchar](400) NULL,
	[EmployeeNumber] [nvarchar](400) NULL,
	[EmployeeID] [nvarchar](400) NULL,
	[Title] [nvarchar](400) NULL,
	[Department] [nvarchar](400) NULL,
	[Company] [nvarchar](400) NULL,
	[ExtensionAttribute1] [nvarchar](400) NULL,
	[ExtensionAttribute2] [nvarchar](400) NULL,
	[ExtensionAttribute3] [nvarchar](400) NULL,
	[PhysicalDeliveryOfficeName] [nvarchar](400) NULL,
	[PostalCode] [nvarchar](400) NULL,
	[StreetAddress] [nvarchar](400) NULL,
	[PostOfficeBox] [nvarchar](400) NULL,
	[City] [nvarchar](400) NULL,
	[State] [nvarchar](400) NULL,
	[ISOAlpha2CountryCode] [nvarchar](400) NULL,
	[ISONumericCountryCode] [nvarchar](400) NULL,
	[CountryName] [nvarchar](400) NULL,
	[HomeDrive] [nvarchar](400) NULL,
	[HomeDirectory] [nvarchar](400) NULL,
	[ProfilePath] [nvarchar](400) NULL,
	[ScriptPath] [nvarchar](400) NULL,
	[URL] [nvarchar](400) NULL,
	[HomePage] [nvarchar](400) NULL,
	[Description] [nvarchar](400) NULL,
	[Info] [nvarchar](400) NULL,
	CONSTRAINT [PK_User]
		PRIMARY KEY CLUSTERED ([UserId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_User_OrganizationalUnit_Parent]
		FOREIGN KEY ([ParentOrganizationalUnitId])
		REFERENCES [ActiveDirectory].[OrganizationalUnit] ([OrganizationalUnitId])
,
	CONSTRAINT [FK_User_ObjectCategory]
		FOREIGN KEY ([ObjectCategoryId])
		REFERENCES [ActiveDirectory].[ObjectCategory] ([ObjectCategoryId])
,
	CONSTRAINT [FK_User_UserAccountControl]
		FOREIGN KEY ([UserAccountControlId])
		REFERENCES [ActiveDirectory].[UserAccountControl] ([UserAccountControlId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[User].[UX_User_Key1]
GO
CREATE UNIQUE [UX_User_Key1]
	ON [ActiveDirectory].[User]	([ObjectGUID] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[User].[UX_User_Key2]
GO
CREATE UNIQUE [UX_User_Key2]
	ON [ActiveDirectory].[User]	([DistinguishedName] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[User].[IX_User_ParentOrganizationalUnitId]
GO
CREATE [IX_User_ParentOrganizationalUnitId]
	ON [ActiveDirectory].[User]	([ParentOrganizationalUnitId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[User].[IX_User_ObjectCategoryId]
GO
CREATE [IX_User_ObjectCategoryId]
	ON [ActiveDirectory].[User]	([ObjectCategoryId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[User].[IX_User_UserAccountControlId]
GO
CREATE [IX_User_UserAccountControlId]
	ON [ActiveDirectory].[User]	([UserAccountControlId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[GroupManagerGroup]
GO
CREATE TABLE [ActiveDirectory].[GroupManagerGroup]
(
	[GroupManagerGroupId] [int] IDENTITY(1, 1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[ManagerGroupId] [int] NOT NULL,
	CONSTRAINT [PK_GroupManagerGroup]
		PRIMARY KEY CLUSTERED ([GroupManagerGroupId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_GroupManagerGroup_Group]
		FOREIGN KEY ([GroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])
,
	CONSTRAINT [FK_GroupManagerGroup_Group_Manager]
		FOREIGN KEY ([ManagerGroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[GroupManagerGroup].[UX_GroupManagerGroup_Key]
GO
CREATE UNIQUE [UX_GroupManagerGroup_Key]
	ON [ActiveDirectory].[GroupManagerGroup]
	(
		[GroupId] ASC,
		[ManagerGroupId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[GroupManagerUser]
GO
CREATE TABLE [ActiveDirectory].[GroupManagerUser]
(
	[GroupManagerUserId] [int] IDENTITY(1, 1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[ManagerUserId] [int] NOT NULL,
	CONSTRAINT [PK_GroupManagerUser]
		PRIMARY KEY CLUSTERED ([GroupManagerUserId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_GroupManagerUser_Group]
		FOREIGN KEY ([GroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])
,
	CONSTRAINT [FK_GroupManagerUser_User_Manager]
		FOREIGN KEY ([ManagerUserId])
		REFERENCES [ActiveDirectory].[User] ([UserId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[GroupManagerUser].[UX_GroupManagerUser_Key]
GO
CREATE UNIQUE [UX_GroupManagerUser_Key]
	ON [ActiveDirectory].[GroupManagerUser]
	(
		[GroupId] ASC,
		[ManagerUserId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[GroupMembershipGroup]
GO
CREATE TABLE [ActiveDirectory].[GroupMembershipGroup]
(
	[GroupMembershipGroupId] [int] IDENTITY(1, 1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[MemberGroupId] [int] NOT NULL,
	CONSTRAINT [PK_GroupMembershipGroup]
		PRIMARY KEY CLUSTERED ([GroupMembershipGroupId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_GroupMembershipGroup_Group]
		FOREIGN KEY ([GroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])
,
	CONSTRAINT [FK_GroupMembershipGroup_Group_Member]
		FOREIGN KEY ([MemberGroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[GroupMembershipGroup].[UX_GroupMembershipGroup_Key]
GO
CREATE UNIQUE [UX_GroupMembershipGroup_Key]
	ON [ActiveDirectory].[GroupMembershipGroup]
	(
		[GroupId] ASC,
		[MemberGroupId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[GroupMembershipUser]
GO
CREATE TABLE [ActiveDirectory].[GroupMembershipUser]
(
	[GroupMembershipUserId] [int] IDENTITY(1, 1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[MemberUserId] [int] NOT NULL,
	CONSTRAINT [PK_GroupMembershipUser]
		PRIMARY KEY CLUSTERED ([GroupMembershipUserId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_GroupMembershipUser_Group]
		FOREIGN KEY ([GroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])
,
	CONSTRAINT [FK_GroupMembershipUser_User_Member]
		FOREIGN KEY ([MemberUserId])
		REFERENCES [ActiveDirectory].[User] ([UserId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[GroupMembershipUser].[UX_GroupMembershipUser_Key]
GO
CREATE UNIQUE [UX_GroupMembershipUser_Key]
	ON [ActiveDirectory].[GroupMembershipUser]
	(
		[GroupId] ASC,
		[MemberUserId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[GroupObjectClass]
GO
CREATE TABLE [ActiveDirectory].[GroupObjectClass]
(
	[GroupObjectClassId] [int] IDENTITY(1, 1) NOT NULL,
	[GroupId] [int] NOT NULL,
	[ObjectClassId] [int] NOT NULL,
	CONSTRAINT [PK_GroupObjectClass]
		PRIMARY KEY CLUSTERED ([GroupObjectClassId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_GroupObjectClass_Group]
		FOREIGN KEY ([GroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])
,
	CONSTRAINT [FK_GroupObjectClass_ObjectClass]
		FOREIGN KEY ([ObjectClassId])
		REFERENCES [ActiveDirectory].[ObjectClass] ([ObjectClassId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[GroupObjectClass].[UX_GroupObjectClass_Key]
GO
CREATE UNIQUE [UX_GroupObjectClass_Key]
	ON [ActiveDirectory].[GroupObjectClass]
	(
		[GroupId] ASC,
		[ObjectClassId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[ManagerialHierarchy]
GO
CREATE TABLE [ActiveDirectory].[ManagerialHierarchy]
(
	[ManagerialHierarchyId] [int] IDENTITY(1, 1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ManagerUserId] [int] NOT NULL,
	CONSTRAINT [PK_ManagerialHierarchy]
		PRIMARY KEY CLUSTERED ([ManagerialHierarchyId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_ManagerialHierarchy_User]
		FOREIGN KEY ([UserId])
		REFERENCES [ActiveDirectory].[User] ([UserId])
,
	CONSTRAINT [FK_ManagerialHierarchy_User_Manager]
		FOREIGN KEY ([ManagerUserId])
		REFERENCES [ActiveDirectory].[User] ([UserId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[ManagerialHierarchy].[UX_ManagerialHierarchy_Key]
GO
CREATE UNIQUE [UX_ManagerialHierarchy_Key]
	ON [ActiveDirectory].[ManagerialHierarchy]
	(
		[UserId] ASC,
		[ManagerUserId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[temp]
GO
CREATE TABLE [ActiveDirectory].[temp]
(
	[tempId] [int] IDENTITY(1, 1) NOT NULL,
	[u] [uniqueidentifier] NOT NULL ROWGUIDCOL,
	[GroupId] [int] NOT NULL,
	[t] [sys].[sysname] NOT NULL,
	[d] [decimal](18, 2) NULL
		CONSTRAINT [DF_temp_d] DEFAULT ((1)),
	[comp1] [decimal](19, 2)
		AS ([d]+(1)),
	[comp2] [int]
		AS ([i]+(1)),
	CONSTRAINT [PK_temp]
		PRIMARY KEY CLUSTERED ([tempId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_temp_Group]
		FOREIGN KEY ([GroupId])
		REFERENCES [ActiveDirectory].[Group] ([GroupId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[temp].[UX_temp_Key1]
GO
CREATE UNIQUE [UX_temp_Key1]
	ON [ActiveDirectory].[temp]
	(
		[GroupId] DESC,
		[u] ASC
	)
	INCLUDE ([d])
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[temp].[UX_temp_Key2]
GO
CREATE UNIQUE [UX_temp_Key2]
	ON [ActiveDirectory].[temp]	([GroupId] DESC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[UserObjectClass]
GO
CREATE TABLE [ActiveDirectory].[UserObjectClass]
(
	[UserObjectClassId] [int] IDENTITY(1, 1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ObjectClassId] [int] NOT NULL,
	CONSTRAINT [PK_UserObjectClass]
		PRIMARY KEY CLUSTERED ([UserObjectClassId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_UserObjectClass_User]
		FOREIGN KEY ([UserId])
		REFERENCES [ActiveDirectory].[User] ([UserId])
,
	CONSTRAINT [FK_UserObjectClass_ObjectClass]
		FOREIGN KEY ([ObjectClassId])
		REFERENCES [ActiveDirectory].[ObjectClass] ([ObjectClassId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[UserObjectClass].[UX_UserObjectClass_Key]
GO
CREATE UNIQUE [UX_UserObjectClass_Key]
	ON [ActiveDirectory].[UserObjectClass]
	(
		[UserId] ASC,
		[ObjectClassId] ASC
	)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Table [ActiveDirectory].[UserPhone]
GO
CREATE TABLE [ActiveDirectory].[UserPhone]
(
	[UserPhoneId] [int] IDENTITY(1, 1) NOT NULL,
	[UserId] [int] NOT NULL,
	[PhoneTypeId] [tinyint] NOT NULL,
	[Number] [nvarchar](400) NOT NULL,
	[NormailizedNumber] [nvarchar](400) NOT NULL,
	[E164Format] [nvarchar](20) NULL,
	[Extension] [nvarchar](10) NULL,
	CONSTRAINT [PK_UserPhone]
		PRIMARY KEY CLUSTERED ([UserPhoneId])
		WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
		ON [PRIMARY],
	CONSTRAINT [FK_UserPhone_User]
		FOREIGN KEY ([UserId])
		REFERENCES [ActiveDirectory].[User] ([UserId])
,
	CONSTRAINT [FK_UserPhone_PhoneType]
		FOREIGN KEY ([PhoneTypeId])
		REFERENCES [ActiveDirectory].[PhoneType] ([PhoneTypeId])

) ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[UserPhone].[IX_UserPhone_UserId]
GO
CREATE [IX_UserPhone_UserId]
	ON [ActiveDirectory].[UserPhone]	([UserId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Index [ActiveDirectory].[UserPhone].[IX_UserPhone_PhoneTypeId]
GO
CREATE [IX_UserPhone_PhoneTypeId]
	ON [ActiveDirectory].[UserPhone]	([PhoneTypeId] ASC)
	WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
GO
--Create Function [ActiveDirectory].[GetDigitsOnly]
GO
CREATE OR ALTER FUNCTION [ActiveDirectory].[GetDigitsOnly]
(
	@Text [nvarchar](400)
)
RETURNS [nvarchar](400)
AS
BEGIN
	--Older versions of SQL Server do not support the new TRANSLATE function
	--REPLACE(TRANSLATE([SourcePhone].[Number], N' !"#$%&''()*+,-./:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~', REPLICATE(N' ', 85)), N' ', N'')
	DECLARE @ReturnValue [nvarchar](400) = @Text
	WHILE PATINDEX('%[^0-9]%', @ReturnValue) > 0
		BEGIN
			SET @ReturnValue = STUFF(@ReturnValue, PATINDEX('%[^0-9]%', @ReturnValue), 1, '')
    END
    RETURN @ReturnValue
END

GO
--Create Function [ActiveDirectory].[GetE164PhoneNumber]
GO
CREATE OR ALTER FUNCTION [ActiveDirectory].[GetE164PhoneNumber]
(
	@NormalizedNumber [nvarchar](400)
)
RETURNS [nvarchar](400)
AS
BEGIN
	DECLARE @ReturnValue [nvarchar](400) =
	CASE
		WHEN LEN(@NormalizedNumber) = 10
			THEN CONCAT(N'+1', @NormalizedNumber)
		WHEN LEN(@NormalizedNumber) > 10
			THEN CONCAT(N'+1', LEFT(@NormalizedNumber, 10))
		ELSE NULL
	END
    RETURN @ReturnValue
END

GO
--Create Function [ActiveDirectory].[GetNaturalPathFromLDIFPath]
GO
CREATE OR ALTER FUNCTION [ActiveDirectory].[GetNaturalPathFromLDIFPath]
(
	@LDIFPath [nvarchar](400)
)
RETURNS [nvarchar](400)
AS
BEGIN
	--This function is required because the version of SQL in use does not support STRING_SPLIT with ordinal output
	--And have to use the hack method of STRING_AGG due to being on older version of SQL Server.
	DECLARE @ReturnValue [nvarchar](400)
	DECLARE @LDIFComponent TABLE
	(
		[Id] [int] IDENTITY(1, 1) NOT NULL,
		[LDAPValue] [nvarchar](400) NOT NULL,
		[ComponentType] [nvarchar](400) NOT NULL,
		[ComponentName] [nvarchar](400) NOT NULL
	)
	INSERT INTO @LDIFComponent([LDAPValue], [ComponentType], [ComponentName])
		SELECT
			[value] AS [LDAPValue],
			CASE LEFT([value], (CHARINDEX(N'=', [value]) - 1))
				WHEN N'DC' THEN N'Domain Component'
				WHEN N'DN' THEN N'Distinguished Name'
				WHEN N'OU' THEN N'Organizational Unit'
				WHEN N'CN' THEN N'Common Name'
			END AS [ComponentType],
			RIGHT([value], (LEN([value]) - CHARINDEX(N'=', [value]))) AS [ComponentName]
			FROM STRING_SPLIT(@LDIFPath, ',')
	SELECT @ReturnValue =
		CONCAT
		(
			LEFT([Domain].[Domain], (LEN([Domain].[Domain]) - 1)),
			N'\',
			LEFT([Path].[Path], (LEN([Path].[Path]) - 1))
		)
		FROM
		(
			SELECT
			(
				SELECT CONCAT([ComponentName], N'.')
					FROM @LDIFComponent
					WHERE [ComponentType] = N'Domain Component'
					ORDER BY [Id] ASC
					FOR XML PATH('')
			) AS [Domain]
		) AS [Domain]
			CROSS JOIN
			(
				SELECT
				(
					SELECT CONCAT([ComponentName], N'\')
						FROM @LDIFComponent
						WHERE [ComponentType] != N'Domain Component'
						ORDER BY [Id] DESC
						FOR XML PATH('')
				) AS [Path]
			) AS [Path]
	RETURN @ReturnValue
END

GO
--Create Function [ActiveDirectory].[Temsdfasdf]
GO
CREATE OR ALTER FUNCTION [ActiveDirectory].[Temsdfasdf]
(
	@Pam22 [sys].[sysname]
)
RETURNS [nvarchar](1232)
AS
BEGIN
	RETURN CONCAT(@Pam22, 'asdfasdfasdf')
END

GO
--Create Procedure [ActiveDirectory].[AddUserAccountControl]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[AddUserAccountControl]
(
	@UserAccountControl [int]
)

AS
BEGIN
	SET NOCOUNT ON
	DECLARE @True [bit] = 1
	DECLARE @False [bit] = 0
	IF NOT EXISTS
	(
		SELECT 1
			FROM [ActiveDirectory].[UserAccountControl]
			WHERE [UserAccountControl].[UserAccountControlId] = @UserAccountControl
	)
		BEGIN
			INSERT INTO [ActiveDirectory].[UserAccountControl]
			(
				[UserAccountControlId],
				[LoginScriptWillRun],
				[AccountIsDisabled],
				[HomeDirectoryIsRequire],
				[AccountIsLockedOut],
				[PasswordIsNotRequired],
				[UserCannotChangePassword],
				[UserCanSendEncryptedPassword],
				[AccountFor MatchingAccountInTrustedDomain],
				[NormalAccount],
				[InternalDomainTrustAccount],
				[WorkstationTrustAccount],
				[ServerTrustAccount],
				[PasswordNeverExpires],
				[MajorityNodeSetLogonAccount],
				[SmartcardIsRequired],
				[AccountIsTrustedForDelegation],
				[AccountIsNotDelegated],
				[OnlyAllowDataEncryptionStandardKeyTypes],
				[DoNotRequireKerberosPerAuthorization],
				[PasswordHasExpired],
				[AccountIsTrustedForAuthenticationDelegation],
				[AccountIsReadOnlyDomainController]
			)
				SELECT
					@UserAccountControl AS [UserAccountControlId],
					IIF((@UserAccountControl & 1) <> 0, @True, @False) AS [LoginScriptWillRun],
					IIF((@UserAccountControl & 2) <> 0, @True, @False) AS [AccountIsDisabled],
					IIF((@UserAccountControl & 8) <> 0, @True, @False) AS [HomeDirectoryIsRequire],
					IIF((@UserAccountControl & 16) <> 0, @True, @False) AS [AccountIsLockedOut],
					IIF((@UserAccountControl & 32) <> 0, @True, @False) AS [PasswordIsNotRequired],
					IIF((@UserAccountControl & 64) <> 0, @True, @False) AS [UserCannotChangePassword],
					IIF((@UserAccountControl & 128) <> 0, @True, @False) AS [UserCanSendEncryptedPassword],
					IIF((@UserAccountControl & 256) <> 0, @True, @False) AS [AccountFor MatchingAccountInTrustedDomain],
					IIF((@UserAccountControl & 512) <> 0, @True, @False) AS [NormalAccount],
					IIF((@UserAccountControl & 2048) <> 0, @True, @False) AS [InternalDomainTrustAccount],
					IIF((@UserAccountControl & 4096) <> 0, @True, @False) AS [WorkstationTrustAccount],
					IIF((@UserAccountControl & 8192) <> 0, @True, @False) AS [ServerTrustAccount],
					IIF((@UserAccountControl & 65536) <> 0, @True, @False) AS [PasswordNeverExpires],
					IIF((@UserAccountControl & 131072) <> 0, @True, @False) AS [MajorityNodeSetLogonAccount],
					IIF((@UserAccountControl & 262144) <> 0, @True, @False) AS [SmartcardIsRequired],
					IIF((@UserAccountControl & 524288) <> 0, @True, @False) AS [AccountIsTrustedForDelegation],
					IIF((@UserAccountControl & 1048576) <> 0, @True, @False) AS [AccountIsNotDelegated],
					IIF((@UserAccountControl & 2097152) <> 0, @True, @False) AS [OnlyAllowDataEncryptionStandardKeyTypes],
					IIF((@UserAccountControl & 4194304) <> 0, @True, @False) AS [DoNotRequireKerberosPerAuthorization],
					IIF((@UserAccountControl & 8388608) <> 0, @True, @False) AS [PasswordHasExpired],
					IIF((@UserAccountControl & 16777216) <> 0, @True, @False) AS [AccountIsTrustedForAuthenticationDelegation],
					IIF((@UserAccountControl & 67108864) <> 0, @True, @False) AS [AccountIsReadOnlyDomainController]
		END
END

GO
--Create Procedure [ActiveDirectory].[GetGroupLastWhenChangedTime]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[GetGroupLastWhenChangedTime]

AS
BEGIN
	SELECT ISNULL(MAX([Group].[WhenChangedTime]), MAX([Group].[WhenCreatedTime])) AS [WhenChangedTime]
		FROM [ActiveDirectory].[Group]
END

GO
--Create Procedure [ActiveDirectory].[GetUserLastWhenChangedTime]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[GetUserLastWhenChangedTime]

AS
BEGIN
	SELECT ISNULL(MAX([User].[WhenChangedTime]), MAX([User].[WhenCreatedTime])) AS [WhenChangedTime]
		FROM [ActiveDirectory].[User]
END

GO
--Create Procedure [ActiveDirectory].[ProcessGroupManagerChanges]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[ProcessGroupManagerChanges]

AS
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

GO
--Create Procedure [ActiveDirectory].[ProcessGroupMembershipChanges]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[ProcessGroupMembershipChanges]

AS
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

GO
--Create Procedure [ActiveDirectory].[ProcessManagerialChanges]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[ProcessManagerialChanges]

AS
BEGIN
/*
	NO ACTION NEEDED
	Case A:
		If no manager in stage and no manager in hierarchy
			Then do nothing
	Case B:
		If manager in stage matches manager in hierarchy
			Then do nothing

	ACTION NEEDED
	Case C:
		If manager in stage and no manager in hierarchy
			Then insert new hierarchy record
	Case D:
		If no manager in stage and manager in hierarchy
			Then delete hierarchy record
	Case E:
		If manager in stage does not match manager in hierarchy
			Then update manager in hierarchy record
*/
	DECLARE @UserId [int]
	DECLARE @ManagerUserId [int]
	DECLARE @StagedManagerialHierarchyId [int]
	SELECT @StagedManagerialHierarchyId = [StagedManagerialHierarchy].[StagedManagerialHierarchyId]
		FROM [ActiveDirectory].[StagedManagerialHierarchy]
		WHERE [StagedManagerialHierarchy].[IsProcessed] = 0
		ORDER BY [StagedManagerialHierarchy].[InsertTimestamp]
	WHILE @StagedManagerialHierarchyId IS NOT NULL
		BEGIN
			SELECT
				@UserId = [User_Subordinate].[UserId],
				@ManagerUserId = [User_Manager].[UserId]
				FROM [ActiveDirectory].[StagedManagerialHierarchy]
					INNER JOIN [ActiveDirectory].[User] AS [User_Subordinate]
						ON [StagedManagerialHierarchy].[objectGuid] = [User_Subordinate].[objectGuid]
					LEFT OUTER JOIN [ActiveDirectory].[User] AS [User_Manager]
						ON [StagedManagerialHierarchy].[managerDistinguishedName] = [User_Manager].[DistinguishedName]
				WHERE [StagedManagerialHierarchy].[StagedManagerialHierarchyId] = @StagedManagerialHierarchyId
			--Case C: Insert
			IF
				@ManagerUserId IS NOT NULL
				AND NOT EXISTS
				(
					SELECT 1
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE [ManagerialHierarchy].[UserId] = @UserId
				)
					INSERT INTO [ActiveDirectory].[ManagerialHierarchy]([UserId], [ManagerUserId])
						VALUES(@UserId, @ManagerUserId)

			--Case D: Delete
			IF
				@ManagerUserId IS NULL
				AND EXISTS
				(
					SELECT 1
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE [ManagerialHierarchy].[UserId] = @UserId
				)
					DELETE
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE [ManagerialHierarchy].[UserId] = @UserId

			--Case E: Update
			IF
				@ManagerUserId IS NOT NULL
				AND EXISTS
				(
					SELECT 1
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE
							[ManagerialHierarchy].[UserId] = @UserId
							AND [ManagerialHierarchy].[ManagerUserId] != @ManagerUserId
				)
					UPDATE [ActiveDirectory].[ManagerialHierarchy]
						SET [ManagerUserId] = @ManagerUserId
						WHERE [UserId] = @UserId

			UPDATE [ActiveDirectory].[StagedManagerialHierarchy]
				SET [IsProcessed] = 1
				WHERE [StagedManagerialHierarchy].[StagedManagerialHierarchyId] = @StagedManagerialHierarchyId
			SET @StagedManagerialHierarchyId = NULL
			SELECT @StagedManagerialHierarchyId = [StagedManagerialHierarchy].[StagedManagerialHierarchyId]
				FROM [ActiveDirectory].[StagedManagerialHierarchy]
				WHERE [StagedManagerialHierarchy].[IsProcessed] = 0
				ORDER BY [StagedManagerialHierarchy].[InsertTimestamp]
		END
	TRUNCATE TABLE [ActiveDirectory].[StagedManagerialHierarchy]
END

GO
--Create Procedure [ActiveDirectory].[RebuildIndexes]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[RebuildIndexes]

AS
BEGIN
	ALTER INDEX [UX_Group_ObjectGUID]
		ON [ActiveDirectory].[Group]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_Group_DistinguishedName]
		ON [ActiveDirectory].[Group]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_Group_ParentOrganizationalUnitId]
		ON [ActiveDirectory].[Group]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_Group_ObjectCategoryId]
		ON [ActiveDirectory].[Group]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_Group_GroupTypeId]
		ON [ActiveDirectory].[Group]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_GroupManagerGroup_Key]
		ON [ActiveDirectory].[GroupManagerGroup]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_GroupManagerUser_Key]
		ON [ActiveDirectory].[GroupManagerUser]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_GroupMembershipGroup_Key]
		ON [ActiveDirectory].[GroupMembershipGroup]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_GroupMembershipUser_Key]
		ON [ActiveDirectory].[GroupMembershipUser]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_GroupObjectClass_Key]
		ON [ActiveDirectory].[GroupObjectClass]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_ManagerialHierarchy_Key]
		ON [ActiveDirectory].[ManagerialHierarchy]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_ObjectCategory_Name]
		ON [ActiveDirectory].[ObjectCategory]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_ObjectClass_Name]
		ON [ActiveDirectory].[ObjectClass]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_OrganizationalUnit_LDIFPath]
		ON [ActiveDirectory].[OrganizationalUnit]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_PhoneType_Name]
		ON [ActiveDirectory].[PhoneType]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_User_ObjectGUID]
		ON [ActiveDirectory].[User]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_User_DistinguishedName]
		ON [ActiveDirectory].[User]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_User_ParentOrganizationalUnitId]
		ON [ActiveDirectory].[User]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_User_ObjectCategoryId]
		ON [ActiveDirectory].[User]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_User_UserAccountControlId]
		ON [ActiveDirectory].[User]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_UserAccountControlFlag_Name]
		ON [ActiveDirectory].[UserAccountControlFlag]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [UX_UserObjectClass_Key]
		ON [ActiveDirectory].[UserObjectClass]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_UserPhone_UserId]
		ON [ActiveDirectory].[UserPhone]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	ALTER INDEX [IX_UserPhone_PhoneTypeId]
		ON [ActiveDirectory].[UserPhone]
		REBUILD PARTITION = ALL
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
END

GO
--Create Procedure [ActiveDirectory].[Temmtp]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[Temmtp]
(
	@Param22 [sys].[sysname]
)

AS
BEGIN
	DECLARE @RetVal [int] = 12
	SELECT
		@Param22,
		@ASDF,
		@de,
		@ti
	RETURN @RetVal
END

GO
--Create Procedure [ActiveDirectory].[ImportGroup]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[ImportGroup]
(
	@GroupJSON [nvarchar](MAX)
)

AS
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

GO
--Create Procedure [ActiveDirectory].[ImportUser]
GO
CREATE OR ALTER PROCEDURE [ActiveDirectory].[ImportUser]
(
	@UserJSON [nvarchar](MAX)
)

AS
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

GO
