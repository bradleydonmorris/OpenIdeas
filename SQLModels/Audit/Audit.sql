IF UPPER(N'$(DropObjects)') = N'TRUE'
	BEGIN
		DROP PROCEDURE IF EXISTS [$(SchemaName)].[ProcessAuditPackets]
		DROP PROCEDURE IF EXISTS [$(SchemaName)].[PostHost]
		DROP PROCEDURE IF EXISTS [$(SchemaName)].[PostApplication]
		DROP PROCEDURE IF EXISTS [$(SchemaName)].[PostUser]
		DROP PROCEDURE IF EXISTS [$(SchemaName)].[PostAuditPacket]
		DROP TABLE IF EXISTS [$(SchemaName)].[AuditPacket]
		DROP TABLE IF EXISTS [$(SchemaName)].[AuditEntityPaths]
		DROP TABLE IF EXISTS [$(SchemaName)].[AuditEntityChange]
		DROP TABLE IF EXISTS [$(SchemaName)].[EntityAttribute]
		DROP TABLE IF EXISTS [$(SchemaName)].[AuditEntityLocator]
		DROP TABLE IF EXISTS [$(SchemaName)].[AuditEntity]
		DROP TABLE IF EXISTS [$(SchemaName)].[EntityType]
		DROP TABLE IF EXISTS [$(SchemaName)].[Action]
		DROP TABLE IF EXISTS [$(SchemaName)].[Audit]
		DROP TABLE IF EXISTS [$(SchemaName)].[Host]
		DROP TABLE IF EXISTS [$(SchemaName)].[Application]
		DROP TABLE IF EXISTS [$(SchemaName)].[User]
	END

DECLARE @TableFileGroupName [sys].[sysname] = N'$(TableFileGroup)'
DECLARE @TextFileGroupName [sys].[sysname] = N'$(TextFileGroup)'
DECLARE @IndexFileGroupName [sys].[sysname] = N'$(IndexFileGroup)'
DECLARE @SchemaName [sys].[sysname] = N'$(SchemaName)'
DECLARE @TableName [sys].[sysname]
DECLARE @IndexName [sys].[sysname]
DECLARE @IndexColumns [nvarchar](MAX)
DECLARE @IsIndexUnique [bit]
DECLARE @TableCreateStatement [nvarchar](MAX)
DECLARE @IndexCreateStatement [nvarchar](MAX)
BEGIN --Schema
	PRINT CONCAT(N'Schema ', QUOTENAME(@SchemaName))
	IF [dbo].[SchemaExists](@SchemaName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Schema')
			EXECUTE(N'CREATE SCHEMA [$(SchemaName)]')
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Schema Already Exists')
END --Schema

BEGIN --User
	SET @TableName = N'User'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					},
					{
						"Name": "UserName",
						"Type": "sys.sysname",
						"IsNullable": false
					},
					{
						"Name": "EmailAddress",
						"Type": "nvarchar",
						"Length": 320,
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)		
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'UserName'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'EmailAddress'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_EmailAddress')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --User

BEGIN --Application
	SET @TableName = N'Application'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)		
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Application

BEGIN --Host
	SET @TableName = N'Host'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)		
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Host

BEGIN --Action
	SET @TableName = N'Action'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "tinyint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)		
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	PRINT CONCAT(NCHAR(9), N'Adding Initial Data')
	INSERT INTO [$(SchemaName)].[Action]([Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				VALUES
					('INSERT'),
					('UPDATE'),
					('DELETE')
			) AS [Source]([Name])
				LEFT OUTER JOIN [$(SchemaName)].[Action] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[ActionId] IS NULL
END --Action

BEGIN --EntityType
	SET @TableName = N'EntityType'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)		
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --EntityType

BEGIN --AuditPacket
	SET @TableName = N'AuditPacket'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "Timestamp",
						"Type": "datetime2",
						"Length": 7,
						"IsNullable": false,
						"Default": "SYSUTCDATETIME()"
					},
					{
						"Name": "IsProcessed",
						"Type": "bit",
						"IsNullable": false,
						"Default": "0"
					},
					{
						"Name": "JSON",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'Timestamp'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --AuditPacket

BEGIN --Audit
	SET @TableName = N'Audit'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "UserId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "User",
							"Column": "UserId"
						}
					},
					{
						"Name": "ApplicationId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Application",
							"Column": "ApplicationId"
						}
					},
					{
						"Name": "HostId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Host",
							"Column": "HostId"
						}
					},
					{
						"Name": "BeginTime",
						"Type": "datetime2",
						"Length": 7,
						"IsNullable": false
					},
					{
						"Name": "EndTime",
						"Type": "datetime2",
						"Length": 7,
						"IsNullable": false
					},
					{
						"Name": "TotalEntitiesChanged",
						"Type": "int",
						"IsNullable": false
					},
					{
						"Name": "TotalAttributesChanged",
						"Type": "int",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'UserId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_UserId')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'ApplicationId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'HostId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'BeginTime,EndTime'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Times')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Audit

BEGIN --AuditEntity
	SET @TableName = N'AuditEntity'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "AuditId",
						"Type": "bigint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Audit",
							"Column": "AuditId"
						}
					},
					{
						"Name": "EntityTypeId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "EntityType",
							"Column": "EntityTypeId"
						}
					},
					{
						"Name": "ActionId",
						"Type": "tinyint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Action",
							"Column": "ActionId"
						}
					},
					{
						"Name": "EntityGUID",
						"Type": "uniqueidentifier",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'AuditId,EntityGUID'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'EntityTypeId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'ActionId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --AuditEntity

BEGIN --AuditEntityLocator
	SET @TableName = N'AuditEntityLocator'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "AuditEntityId",
						"Type": "bigint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "AuditEntity",
							"Column": "AuditEntityId"
						}
					},
					{
						"Name": "EntityTypeId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "EntityType",
							"Column": "EntityTypeId"
						}
					},
					{
						"Name": "Order",
						"Type": "int",
						"IsNullable": false
					},
					{
						"Name": "EntityGUID",
						"Type": "uniqueidentifier",
						"IsNullable": false
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'AuditEntityId,EntityGUID'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'EntityTypeId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'Order'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --AuditEntityLocator

BEGIN --AuditEntityPaths
	SET @TableName = N'AuditEntityPaths'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "AuditEntityId",
						"Type": "bigint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "AuditEntity",
							"Column": "AuditEntityId"
						}
					},
					{
						"Name": "TypePath",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": false
					},
					{
						"Name": "NamePath",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": false
					},
					{
						"Name": "GUIDPath",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'AuditEntityId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --AuditEntityPaths

BEGIN --EntityAttribute
	SET @TableName = N'EntityAttribute'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "EntityTypeId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "EntityType",
							"Column": "EntityTypeId"
						}
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'EntityTypeId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --EntityAttribute

BEGIN --AuditEntityChange
	SET @TableName = N'AuditEntityChange'
	PRINT CONCAT(N'Table ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@TableName))
	IF [dbo].[TableExists](@SchemaName, @TableName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Table')
			SET @TableCreateStatement = [dbo].[GetTableCreateStatement]
			(
				@TableFileGroupName, @TextFileGroupName, @SchemaName, @TableName,
				--@ColumnsJSON
				N'
				[
					{
						"Name": "' + @TableName + N'Id",
						"Type": "bigint",
						"IsNullable": false,
						"IsIdentity": true,
						"IsPrimaryKey": true
					},
					{
						"Name": "AuditEntityId",
						"Type": "bigint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "AuditEntity",
							"Column": "AuditEntityId"
						}
					},
					{
						"Name": "EntityAttributeId",
						"Type": "bigint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "EntityAttribute",
							"Column": "EntityAttributeId"
						}
					},
					{
						"Name": "Order",
						"Type": "int",
						"IsNullable": false
					},
					{
						"Name": "PreviousValue",
						"Type": "nvarchar",
						"Length": 1000,
						"IsNullable": true
					},
					{
						"Name": "NewValue",
						"Type": "nvarchar",
						"Length": 1000,
						"IsNullable": true
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'AuditEntityId,EntityAttributeId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'Order'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --AuditEntityChange
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'PostUser'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[PostUser]
(
	@Name [sys].[sysname],
	@UserName [sys].[sysname],
	@EmailAddress [nvarchar](320)
)
AS
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS
	(
		SELECT 1
			FROM [$(SchemaName)].[User]
			WHERE
				[Name] = N'Bradley Don Morris'
				AND [UserName] = SUSER_SNAME()
				AND [EmailAddress] = N'bmorris@foxrentacar.com'
	)
		INSERT INTO [$(SchemaName)].[User]([Name], [UserName], [EmailAddress])
			VALUES(@Name, @UserName, @EmailAddress)
END
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'PostApplication'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[PostApplication]
(
	@Name [sys].[sysname]
)
AS
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS
	(
		SELECT 1
			FROM [$(SchemaName)].[Application]
			WHERE [Name] = @Name
	)
		INSERT INTO [$(SchemaName)].[Application]([Name]) VALUES(@Name)
END
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'PostHost'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[PostHost]
(
	@Name [sys].[sysname]
)
AS
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS
	(
		SELECT 1
			FROM [$(SchemaName)].[Host]
			WHERE [Name] = @Name
	)
		INSERT INTO [$(SchemaName)].[Host]([Name]) VALUES(@Name)
END
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'PostAuditPacket'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[PostAuditPacket]
(
	@AuditPacket [nvarchar](MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO [$(SchemaName)].[AuditPacket]([Timestamp], [IsProcessed], [JSON])
		VALUES(SYSUTCDATETIME(), 0, @AuditPacket)
END
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'ProcessAuditPackets'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[ProcessAuditPackets]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @AuditPacketId [bigint]
	DECLARE @JSON [nvarchar](MAX)
	DECLARE @BeginTime [datetime2](7)
	DECLARE @EndTime [datetime2](7)
	DECLARE @UserName [sys].[sysname]
	DECLARE @Application [sys].[sysname]
	DECLARE @Host [sys].[sysname]
	DECLARE @TotalEntitiesChanged [int]
	DECLARE @TotalAttributesChanged [int]
	DECLARE @AuditId [bigint]
	DECLARE @UserId [int]
	DECLARE @ApplicationId [int]
	DECLARE @HostId [int]
	WHILE EXISTS
	(
		SELECT 1
			FROM [$(SchemaName)].[AuditPacket]
			WHERE [AuditPacket].[IsProcessed] = 0
	)
		BEGIN
			SET @AuditId = NULL
			SELECT
				@AuditPacketId = [AuditPacket].[AuditPacketId],
				@JSON = [AuditPacket].[JSON]
				FROM [$(SchemaName)].[AuditPacket]
				WHERE [AuditPacket].[IsProcessed] = 0
				ORDER BY [AuditPacket].[Timestamp]
			PRINT @AuditPacketId --@JSON
			SELECT
				@BeginTime = [Audit_Source].[BeginTime],
				@EndTime = [Audit_Source].[EndTime],
				@UserName = [Audit_Source].[UserName],
				@Application = [Audit_Source].[Application],
				@Host = [Audit_Source].[Host],
				@TotalEntitiesChanged = [Audit_Source].[TotalEntitiesChanged],
				@TotalAttributesChanged = [Audit_Source].[TotalAttributesChanged]
				FROM OPENJSON(@JSON)
					WITH
					(
						[BeginTime] [datetime2](7) N'$.BeginTime',
						[EndTime] [datetime2](7) N'$.EndTime',
						[UserName] [sys].[sysname] N'$.UserName',
						[Application] [sys].[sysname] N'$.Application',
						[Host] [sys].[sysname] N'$.Host',
						[TotalEntitiesChanged] [int] N'$.TotalEntitiesChanged',
						[TotalAttributesChanged] [int] N'$.TotalAttributesChanged'
					) AS [Audit_Source]
			SELECT @UserId = [User].[UserId]
				FROM [$(SchemaName)].[User]
				WHERE [User].[UserName] = @UserName
			IF NULLIF(@UserId, 0) IS NULL
				BEGIN
					INSERT INTO [$(SchemaName)].[User]([Name], [UserName], [EmailAddress])
						VALUES(@UserName, @UserName, @UserName)
					SET @UserId = SCOPE_IDENTITY()
				END
			SELECT @ApplicationId = [Application].[ApplicationId]
				FROM [$(SchemaName)].[Application]
				WHERE [Application].[Name] = @Application
			IF NULLIF(@ApplicationId, 0) IS NULL
				BEGIN
					INSERT INTO [$(SchemaName)].[Application]([Name]) VALUES(@Application)
					SET @ApplicationId = SCOPE_IDENTITY()
				END
			SELECT @HostId = [Host].[HostId]
				FROM [$(SchemaName)].[Host]
				WHERE [Host].[Name] = @Host
			IF NULLIF(@HostId, 0) IS NULL
				BEGIN
					INSERT INTO [$(SchemaName)].[Host]([Name]) VALUES(@Host)
					SET @HostId = SCOPE_IDENTITY()
				END
			INSERT INTO [$(SchemaName)].[EntityType]([Name])
				SELECT [Source].[Name]
					FROM
					(
						SELECT DISTINCT [Entity_Source].[EntityType] AS [Name]
							FROM OPENJSON(@JSON, N'$.Entities')
									WITH ([EntityType] [sys].[sysname] N'$.EntityType') AS [Entity_Source]
					) AS [Source]
						LEFT OUTER JOIN [$(SchemaName)].[EntityType] AS [Target]
							ON [Source].[Name] = [Target].[Name]
					WHERE [Target].[EntityTypeId] IS NULL
			INSERT INTO [$(SchemaName)].[EntityAttribute]([EntityTypeId], [Name])
				SELECT DISTINCT
					[Source].[EntityTypeId],
					[Source].[Name]
					FROM
					(
						SELECT DISTINCT
							[EntityType].[EntityTypeId] AS [EntityTypeId],
							[EntityChange_Source].[Name] AS [Name]
							FROM OPENJSON(@JSON, N'$.Entities')
									WITH
									(
										[EntityType] [sys].[sysname] N'$.EntityType',
										[ChangesJSON] [nvarchar](MAX) N'$.Changes' AS JSON
									) AS [Entity_Source]
								CROSS APPLY OPENJSON([Entity_Source].[ChangesJSON])
									WITH ([Name] [sys].[sysname] N'$.Attribute') AS [EntityChange_Source]
								INNER JOIN [$(SchemaName)].[EntityType]
									ON [Entity_Source].[EntityType] = [EntityType].[Name]
					) AS [Source]
						LEFT OUTER JOIN [$(SchemaName)].[EntityAttribute] AS [Target]
							ON
								[Source].[EntityTypeId] = [Target].[EntityTypeId]
								AND [Source].[Name] = [Target].[Name]
					WHERE [Target].[EntityAttributeId] IS NULL

			INSERT INTO [$(SchemaName)].[Audit]([UserId], [ApplicationId], [HostId], [BeginTime], [EndTime], [TotalEntitiesChanged], [TotalAttributesChanged])
				VALUES(@UserId, @ApplicationId, @HostId, @BeginTime, @EndTime, @TotalEntitiesChanged, @TotalAttributesChanged)
			SET @AuditId = SCOPE_IDENTITY()
			INSERT INTO [$(SchemaName)].[AuditEntity]([AuditId], [EntityTypeId], [ActionId], [EntityGUID])
				SELECT DISTINCT
					[Source].[AuditId],
					[Source].[EntityTypeId],
					[Source].[ActionId],
					[Source].[EntityGUID]
					FROM
					(
						SELECT DISTINCT
							@AuditId AS [AuditId],
							[EntityType].[EntityTypeId],
							[Action].[ActionId],
							[Entity_Source].[EntityGUID] AS [EntityGUID]
							FROM OPENJSON(@JSON, N'$.Entities')
									WITH
									(
										[EntityGUID] [uniqueidentifier] N'$.EntityGUID',
										[EntityType] [sys].[sysname] N'$.EntityType',
										[Action] [varchar](10) N'$.Action'
									) AS [Entity_Source]
								INNER JOIN [$(SchemaName)].[EntityType]
									ON [Entity_Source].[EntityType] = [EntityType].[Name]
								INNER JOIN [$(SchemaName)].[Action]
									ON [Entity_Source].[Action] = [Action].[Name]
					) AS [Source]
						LEFT OUTER JOIN [$(SchemaName)].[AuditEntity] AS [Target]
							ON
								[Source].[AuditId] = [Target].[AuditId]
								AND [Source].[EntityGUID] = [Target].[EntityGUID]
					WHERE [Target].[AuditEntityId] IS NULL
			INSERT INTO [$(SchemaName)].[AuditEntityLocator]([AuditEntityId], [EntityTypeId], [Order], [EntityGUID], [Name])
				SELECT DISTINCT
					[Source].[AuditEntityId],
					[Source].[EntityTypeId],
					[Source].[Order],
					[Source].[EntityGUID],
					[Source].[Name]
					FROM
					(
						SELECT DISTINCT
							[AuditEntity].[AuditEntityId],
							[EntityType].[EntityTypeId],
							[EntityLocator_Source].[Order] AS [Order],
							[EntityLocator_Source].[EntityGUID] AS [EntityGUID],
							[EntityLocator_Source].[Name] AS [Name]
							FROM [$(SchemaName)].[AuditPacket]
								CROSS APPLY OPENJSON([AuditPacket].[JSON], N'$.Entities')
									WITH
									(
										[AuditEntityGUID] [uniqueidentifier] N'$.EntityGUID',
										[EntityLocatorsJSON] [nvarchar](MAX) N'$.EntityLocators' AS JSON
									) AS [Entity_Source]
								CROSS APPLY OPENJSON([Entity_Source].[EntityLocatorsJSON])
									WITH
									(
										[Order] [int] N'$.Order',
										[EntityGUID] [uniqueidentifier] N'$.GUID',
										[EntityType] [sys].[sysname] N'$.Type',
										[Name] [sys].[sysname] N'$.Name'
									) AS [EntityLocator_Source]
								INNER JOIN [$(SchemaName)].[EntityType]
									ON [EntityLocator_Source].[EntityType] = [EntityType].[Name]
								INNER JOIN [$(SchemaName)].[AuditEntity]
									ON
										@AuditId = [AuditEntity].[AuditId]
										AND [Entity_Source].[AuditEntityGUID] = [AuditEntity].[EntityGUID]
					) AS [Source]
						LEFT OUTER JOIN [$(SchemaName)].[AuditEntityLocator] AS [Target]
							ON
								[Source].[AuditEntityId] = [Target].[AuditEntityId]
								AND [Source].[EntityGUID] = [Target].[EntityGUID]
					WHERE [Target].[AuditEntityLocatorId] IS NULL
			INSERT INTO [$(SchemaName)].[AuditEntityPaths]([AuditEntityId], [TypePath], [NamePath], [GUIDPath])
					SELECT
						[Source].[AuditEntityId],
						[Source].[TypePath],
						[Source].[NamePath],
						[Source].[GUIDPath]
						FROM
						(
							SELECT
								[AuditEntity].[AuditEntityId],
								CASE
									WHEN CHARINDEX(N'|', [Paths].[TypePath]) > 0
										THEN REPLACE(LEFT([Paths].[TypePath], (LEN([Paths].[TypePath]) - 1)), N'|', N' -> ')
								END AS [TypePath],
								CASE
									WHEN CHARINDEX(N'|', [Paths].[NamePath]) > 0
										THEN REPLACE(LEFT([Paths].[NamePath], (LEN([Paths].[NamePath]) - 1)), N'|', N' -> ')
								END AS [NamePath],
								CASE
									WHEN CHARINDEX(N'|', [Paths].[GUIDPath]) > 0
										THEN REPLACE(LEFT([Paths].[GUIDPath], (LEN([Paths].[GUIDPath]) - 1)), N'|', N' -> ')
								END AS [GUIDPath]
								FROM OPENJSON(@JSON, N'$.Entities')
									WITH
									(
										[AuditEntityGUID] [uniqueidentifier] N'$.EntityGUID',
										[EntityLocatorsJSON] [nvarchar](MAX) N'$.EntityLocators' AS JSON
									) AS [Entity_Source]
									INNER JOIN [$(SchemaName)].[AuditEntity]
										ON
											@AuditId = [AuditEntity].[AuditId]
											AND [Entity_Source].[AuditEntityGUID] = [AuditEntity].[EntityGUID]
									CROSS APPLY
									(
										SELECT
											(
												SELECT
													CONCAT([EntityLocator_Source].[EntityType], N'|')
													FROM OPENJSON([Entity_Source].[EntityLocatorsJSON])
														WITH
														(
															[Order] [int] N'$.Order',
															[EntityType] [sys].[sysname] N'$.Type'
														) AS [EntityLocator_Source]
													ORDER BY [EntityLocator_Source].[Order] DESC
													FOR XML PATH('')
											) AS [TypePath],
											(
												SELECT
													CONCAT([EntityLocator_Source].[Name], N'|')
													FROM OPENJSON([Entity_Source].[EntityLocatorsJSON])
														WITH
														(
															[Order] [int] N'$.Order',
															[Name] [sys].[sysname] N'$.Name'
														) AS [EntityLocator_Source]
													ORDER BY [EntityLocator_Source].[Order] DESC
													FOR XML PATH('')
											) AS [NamePath],
											(
												SELECT
													CONCAT([EntityLocator_Source].[EntityGUID], N'|')
													FROM OPENJSON([Entity_Source].[EntityLocatorsJSON])
														WITH
														(
															[Order] [int] N'$.Order',
															[EntityGUID] [uniqueidentifier] N'$.GUID'
														) AS [EntityLocator_Source]
													ORDER BY [EntityLocator_Source].[Order] DESC
													FOR XML PATH('')
											) AS [GUIDPath]
									) AS [Paths]
							) AS [Source]
							LEFT OUTER JOIN [$(SchemaName)].[AuditEntityPaths] AS [Target]
								ON [Source].[AuditEntityId] = [Target].[AuditEntityId]
						WHERE [Target].[AuditEntityPathsId] IS NULL
			INSERT INTO [$(SchemaName)].[AuditEntityChange]([AuditEntityId], [EntityAttributeId], [Order], [PreviousValue], [NewValue])
				SELECT DISTINCT
					[Source].[AuditEntityId],
					[Source].[EntityAttributeId],
					[Source].[Order],
					[Source].[PreviousValue],
					[Source].[NewValue]
					FROM
					(
						SELECT DISTINCT
							[AuditEntity].[AuditEntityId] AS [AuditEntityId],
							[EntityAttribute].[EntityAttributeId] AS [EntityAttributeId],
							[EntityChange_Source].[Order] AS [Order],
							[EntityChange_Source].[PreviousValue] AS [PreviousValue],
							[EntityChange_Source].[NewValue] AS [NewValue]
							FROM OPENJSON(@JSON, N'$.Entities')
									WITH
									(
										[AuditEntityGUID] [uniqueidentifier] N'$.EntityGUID',
										[EntityType] [sys].[sysname] N'$.EntityType',
										[ChangesJSON] [nvarchar](MAX) N'$.Changes' AS JSON
									) AS [Entity_Source]
								CROSS APPLY OPENJSON([Entity_Source].[ChangesJSON])
									WITH
									(
										[Order] [int] N'$.Order',
										[Attribute] [sys].[sysname] N'$.Attribute',
										[PreviousValue] [nvarchar](1000) N'$.PreviousValue',
										[NewValue] [nvarchar](1000) N'$.NewValue'
									) AS [EntityChange_Source]
								LEFT OUTER  JOIN [$(SchemaName)].[AuditEntity]
									ON
										@AuditId = [AuditEntity].[AuditId]
										AND [Entity_Source].[AuditEntityGUID] = [AuditEntity].[EntityGUID]
								INNER JOIN [$(SchemaName)].[EntityType]
									ON [Entity_Source].[EntityType] = [EntityType].[Name]
								INNER JOIN [$(SchemaName)].[EntityAttribute]
									ON
										[EntityType].[EntityTypeId] = [EntityAttribute].[EntityTypeId]
										AND [EntityChange_Source].[Attribute] = [EntityAttribute].[Name]
					) AS [Source]
						LEFT OUTER JOIN [$(SchemaName)].[AuditEntityChange] AS [Target]
							ON
								[Source].[AuditEntityId] = [Target].[AuditEntityId]
								AND [Source].[EntityAttributeId] = [Target].[EntityAttributeId]
					WHERE [Target].[AuditEntityChangeId] IS NULL
			UPDATE [$(SchemaName)].[AuditPacket]
				SET [IsProcessed] = 1
				WHERE [AuditPacketId] = @AuditPacketId
		END
END
GO
PRINT CONCAT(N'Creating View ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'AuditExpanded'))
GO
CREATE OR ALTER VIEW [$(SchemaName)].[AuditExpanded]
AS
	SELECT
		[Audit].[AuditGUID],
		[User].[Name] AS [User],
		[User].[UserName],
		[User].[EmailAddress],
		[Application].[Name] AS [Application],
		[Host].[Name] AS [Host],
		[Audit].[BeginTime],
		[Audit].[EndTime],
		[Audit].[TotalEntitiesChanged],
		[Audit].[TotalAttributesChanged]
		FROM [$(SchemaName)].[Audit]
			INNER JOIN [$(SchemaName)].[User]
				ON [Audit].[UserId] = [User].[UserId]
			INNER JOIN [$(SchemaName)].[Application]
				ON [Audit].[ApplicationId] = [Application].[ApplicationId]
			INNER JOIN [$(SchemaName)].[Host]
				ON [Audit].[HostId] = [Host].[HostId]
GO
PRINT CONCAT(N'Creating View ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'AuditEntityExpanded'))
GO
CREATE OR ALTER VIEW [$(SchemaName)].[AuditEntityExpanded]
AS
	SELECT
		[Audit].[AuditGUID],
		[EntityType].[Name] AS [EntityType],
		[Action].[Name] AS [Action],
		[AuditEntity].[EntityGUID],
		[AuditEntityPaths].[TypePath],
		[AuditEntityPaths].[NamePath],
		[AuditEntityPaths].[GUIDPath]
		FROM [$(SchemaName)].[Audit]
			INNER JOIN [$(SchemaName)].[AuditEntity]
				ON [Audit].[AuditId] = [AuditEntity].[AuditId]
			INNER JOIN [$(SchemaName)].[EntityType]
				ON [AuditEntity].[EntityTypeId] = [EntityType].[EntityTypeId]
			INNER JOIN [$(SchemaName)].[Action]
				ON [AuditEntity].[ActionId] = [Action].[ActionId]
			INNER JOIN [$(SchemaName)].[AuditEntityPaths]
				ON [AuditEntity].[AuditEntityId] = [AuditEntityPaths].[AuditEntityId]
GO
PRINT CONCAT(N'Creating View ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'AuditEntityChangeExpanded'))
GO
CREATE OR ALTER VIEW [$(SchemaName)].[AuditEntityChangeExpanded]
AS
	SELECT
		[Audit].[AuditGUID],
		[EntityType].[Name] AS [EntityType],
		[Action].[Name] AS [Action],
		[AuditEntity].[EntityGUID],
		[AuditEntityChange].[Order],
		[EntityAttribute].[Name] AS [Attribute],
		[AuditEntityChange].[PreviousValue],
		[AuditEntityChange].[NewValue]
		FROM [$(SchemaName)].[Audit]
			INNER JOIN [$(SchemaName)].[AuditEntity]
				ON [Audit].[AuditId] = [AuditEntity].[AuditId]
			INNER JOIN [$(SchemaName)].[EntityType]
				ON [AuditEntity].[EntityTypeId] = [EntityType].[EntityTypeId]
			INNER JOIN [$(SchemaName)].[Action]
				ON [AuditEntity].[ActionId] = [Action].[ActionId]
			INNER JOIN [$(SchemaName)].[AuditEntityChange]
				ON [AuditEntity].[AuditEntityId] = [AuditEntityChange].[AuditEntityId]
			INNER JOIN [$(SchemaName)].[EntityAttribute]
				ON [AuditEntityChange].[EntityAttributeId] = [EntityAttribute].[EntityAttributeId]
GO
