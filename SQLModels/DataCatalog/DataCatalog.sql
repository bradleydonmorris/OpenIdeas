IF UPPER(N'$(DropObjects)') = N'TRUE'
	BEGIN
		DROP TABLE IF EXISTS [$(SchemaName)].[MappingStaticSourceNote]
		DROP TABLE IF EXISTS [$(SchemaName)].[MappingColumnsNote]
		DROP TABLE IF EXISTS [$(SchemaName)].[MappingTablesNote]
		DROP TABLE IF EXISTS [$(SchemaName)].[MappingNote]
        DROP TABLE IF EXISTS [$(SchemaName)].[MappingStaticSource]
		DROP TABLE IF EXISTS [$(SchemaName)].[MappingColumns]
		DROP TABLE IF EXISTS [$(SchemaName)].[MappingTables]
		DROP TABLE IF EXISTS [$(SchemaName)].[Mapping]
		DROP TABLE IF EXISTS [$(SchemaName)].[Column]
		DROP TABLE IF EXISTS [$(SchemaName)].[Table]
		DROP TABLE IF EXISTS [$(SchemaName)].[Schema]
		DROP TABLE IF EXISTS [$(SchemaName)].[Database]
		DROP TABLE IF EXISTS [$(SchemaName)].[Instance]
		DROP TABLE IF EXISTS [$(SchemaName)].[DataType]
		DROP TABLE IF EXISTS [$(SchemaName)].[InstanceType]
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

BEGIN --InstanceType
	SET @TableName = N'InstanceType'
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
	INSERT INTO [$(SchemaName)].[InstanceType]([Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				VALUES
					('SQL Server'),
					('PostgreSQL'),
					('Flat File'),
					('Excel File'),
					('JSON File')
			) AS [Source]([Name])
				LEFT OUTER JOIN [$(SchemaName)].[InstanceType] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[InstanceTypeId] IS NULL
END --InstanceType

BEGIN --DataType
	SET @TableName = N'DataType'
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
						"Name": "InstanceTypeId",
						"Type": "tinyint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "InstanceType",
							"Column": "InstanceTypeId"
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
	SET @IndexColumns = N'InstanceTypeId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	PRINT CONCAT(NCHAR(9), N'Adding Initial Data')
	INSERT INTO [$(SchemaName)].[DataType]([InstanceTypeId], [Name])
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				VALUES
					(N'JSON File', N'string'),
					(N'JSON File', N'number'),
					(N'JSON File', N'boolean'),
					(N'JSON File', N'array'),
					(N'JSON File', N'object')
			) AS [Source]([InstanceTypeName], [Name])
                INNER JOIN [$(SchemaName)].[InstanceType]
					ON [Source].[InstanceTypeName] = [InstanceType].[Name]
				LEFT OUTER JOIN [$(SchemaName)].[InstanceType] AS [Target]
					ON
                        [InstanceType].[InstanceTypeId] = [Target].[InstanceTypeId]
                        AND [Source].[Name] = [Target].[Name]
			WHERE [Target].[InstanceTypeId] IS NULL
END --DataType

BEGIN --Instance
	SET @TableName = N'Instance'
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
						"Name": "InstanceTypeId",
						"Type": "tinyint",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "InstanceType",
							"Column": "InstanceTypeId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Path",
						"Type": "nvarchar",
                        "Length": 700,
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
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'Path')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'InstanceTypeId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Instance

BEGIN --Database
	SET @TableName = N'Database'
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
						"Name": "InstanceId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Instance",
							"Column": "InstanceId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Path",
						"Type": "nvarchar",
                        "Length": 700,
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
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'Path')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'InstanceId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Database

BEGIN --Schema
	SET @TableName = N'Schema'
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
						"Name": "DatabaseId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Database",
							"Column": "DatabaseId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Path",
						"Type": "nvarchar",
                        "Length": 700,
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
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'Path')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'DatabaseId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Schema

BEGIN --Table
	SET @TableName = N'Table'
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
						"Name": "SchemaId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Schema",
							"Column": "SchemaId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Path",
						"Type": "nvarchar",
                        "Length": 700,
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
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'Path')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'SchemaId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Table

BEGIN --Column
	SET @TableName = N'Column'
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
						"Name": "TableId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Table",
							"Column": "TableId"
						}
					},
					{
						"Name": "DataTypeId",
						"Type": "int",
						"IsNullable": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "DataType",
							"Column": "DataTypeId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Path",
						"Type": "nvarchar",
                        "Length": 700,
						"IsNullable": false
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false
					},
					{
						"Name": "Ordinal",
						"Type": "int",
						"IsNullable": false
					},
					{
						"Name": "Length",
						"Type": "smallint",
						"IsNullable": true
					},
					{
						"Name": "Precision",
						"Type": "tinyint",
						"IsNullable": true
					},
					{
						"Name": "Scale",
						"Type": "tinyint",
						"IsNullable": true
					},
					{
						"Name": "IsNullable",
						"Type": "bit",
						"IsNullable": false,
						"Default": "0"
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'Path')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'TableId,Name'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --Column

BEGIN --Mapping
	SET @TableName = N'Mapping'
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
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false,
						"IsIdentity": false
					},
					{
						"Name": "Description",
						"Type": "nvarchar",
						"Length": 500,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

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
END --Mapping

BEGIN --MappingTables
	SET @TableName = N'MappingTables'
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
						"Name": "MappingId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Mapping",
							"Column": "MappingId"
						}
					},
					{
						"Name": "SourceTableId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Table",
							"Column": "TableId",
							"Suffix": "Source"
						}
					},
					{
						"Name": "TargetTableId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Table",
							"Column": "TableId",
							"Suffix": "Target"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "LinkingComment",
						"Type": "nvarchar",
						"Length": 500,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'MappingId,SourceTableId,TargetTableId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingTables

BEGIN --MappingColumns
	SET @TableName = N'MappingColumns'
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
						"Name": "MappingTablesId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "MappingTables",
							"Column": "MappingTablesId"
						}
					},
					{
						"Name": "SourceColumnId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Column",
							"Column": "ColumnId",
							"Suffix": "Source"
						}
					},
					{
						"Name": "TargetColumnId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Column",
							"Column": "ColumnId",
							"Suffix": "Target"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "TranformationComment",
						"Type": "nvarchar",
						"Length": 500,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'MappingTablesId,TargetColumnId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingColumns

BEGIN --MappingStaticSource
	SET @TableName = N'MappingStaticSource'
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
						"Name": "MappingTablesId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "MappingTables",
							"Column": "MappingTablesId"
						}
					},
					{
						"Name": "TargetColumnId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Column",
							"Column": "ColumnId",
							"Suffix": "Target"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Name",
						"Type": "sys.sysname",
						"IsNullable": false,
						"IsIdentity": false
					},
					{
						"Name": "Value",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": false,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = N'MappingTablesId,TargetColumnId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_Key')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingStaticSource

BEGIN --MappingNote
	SET @TableName = N'MappingNote'
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
						"Name": "MappingId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "Mapping",
							"Column": "MappingId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Text",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'MappingId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingNote

BEGIN --MappingTablesNote
	SET @TableName = N'MappingTablesNote'
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
						"Name": "MappingTablesId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "MappingTables",
							"Column": "MappingTablesId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Text",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'MappingTablesId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingTablesNote

BEGIN --MappingColumnsNote
	SET @TableName = N'MappingColumnsNote'
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
						"Name": "MappingColumnsId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "MappingColumns",
							"Column": "MappingColumnsId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Text",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'MappingColumnsId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingColumnsNote

BEGIN --MappingStaticSourceNote
	SET @TableName = N'MappingStaticSourceNote'
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
						"Name": "MappingStaticSourceId",
						"Type": "int",
						"IsNullable": false,
						"IsIdentity": false,
						"ForeignKey": {
							"Schema": "' + @SchemaName + N'",
							"Table": "MappingColumns",
							"Column": "MappingColumnsId"
						}
					},
					{
						"Name": "' + @TableName + N'GUID",
						"Type": "uniqueidentifier",
						"IsNullable": false,
						"IsRowGUID": true,
						"Default": "NEWSEQUENTIALID()"
					},
					{
						"Name": "Text",
						"Type": "nvarchar",
						"Length": -1,
						"IsNullable": true,
						"IsIdentity": false
					}
				]'
			)
			EXECUTE(@TableCreateStatement)
		END
	ELSE PRINT CONCAT(NCHAR(9), N'Table Already Exists')

	SET @IsIndexUnique = 1
	SET @IndexColumns = CONCAT(@TableName, N'GUID')
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_KeyGUID')
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')

	SET @IsIndexUnique = 0
	SET @IndexColumns = N'MappingStaticSourceId'
	SET @IndexName = CONCAT(IIF(@IsIndexUnique = 1, N'UX_', N'IX_'), @TableName, N'_', @IndexColumns)
	IF [dbo].[IndexExists](@SchemaName, @TableName, @IndexName) = 0
		BEGIN
			PRINT CONCAT(NCHAR(9), N'Creating Index ', QUOTENAME(@IndexName), N'(', @IndexColumns, N')')
			SET @IndexCreateStatement = [dbo].[GetIndexCreateStatement](@IndexFileGroupName, @IsIndexUnique, @SchemaName, @TableName, @IndexName, @IndexColumns)
			EXECUTE(@IndexCreateStatement)
		END
		ELSE PRINT CONCAT(NCHAR(9), N'Index ', QUOTENAME(@IndexName), N' Already Exists')
END --MappingStaticSourceNote
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'PostTableStructure'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[PostTableStructure]
(
	@UserName [sys].[sysname],
	@Application [sys].[sysname],
	@Host [sys].[sysname],
	@JSON [nvarchar](MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @BeginTime [datetime2](7) = SYSUTCDATETIME()
	DECLARE @EndTime [datetime2](7)
	DECLARE @AuditPacket [nvarchar](MAX)
	DECLARE @InstanceTypeHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[InstanceTypeId] [tinyint] NOT NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Deleted_Name] [sys].[sysname] NULL
	)
	DECLARE @DataTypeHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[DataTypeId] [int] NOT NULL,
		[Inserted_InstanceTypeId] [int] NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Deleted_InstanceTypeId] [int] NULL,
		[Deleted_Name] [sys].[sysname] NULL
	)
	DECLARE @InstanceHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[InstanceId] [int] NOT NULL,
		[Inserted_InstanceTypeId] [tinyint] NULL,
		[Inserted_Path] [nvarchar](700) NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Deleted_InstanceTypeId] [tinyint] NULL,
		[Deleted_Path] [nvarchar](700) NULL,
		[Deleted_Name] [sys].[sysname] NULL
	)
	DECLARE @DatabaseHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[DatabaseId] [int] NOT NULL,
		[Inserted_InstanceId] [int] NULL,
		[Inserted_Path] [nvarchar](700) NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Deleted_InstanceId] [int] NULL,
		[Deleted_Path] [nvarchar](700) NULL,
		[Deleted_Name] [sys].[sysname] NULL
	)
	DECLARE @SchemaHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[SchemaId] [int] NOT NULL,
		[Inserted_DatabaseId] [int] NULL,
		[Inserted_Path] [nvarchar](700) NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Deleted_DatabaseId] [int] NULL,
		[Deleted_Path] [nvarchar](700) NULL,
		[Deleted_Name] [sys].[sysname] NULL
	)
	DECLARE @TableHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[TableId] [int] NOT NULL,
		[Inserted_SchemaId] [int] NULL,
		[Inserted_Path] [nvarchar](700) NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Deleted_SchemaId] [int] NULL,
		[Deleted_Path] [nvarchar](700) NULL,
		[Deleted_Name] [sys].[sysname] NULL
	)
	DECLARE @ColumnHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[ColumnId] [int] NOT NULL,
		[Inserted_TableId] [int] NULL,
		[Inserted_DataTypeId] [int] NULL,
		[Inserted_Path] [nvarchar](700) NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Inserted_Ordinal] [int] NULL,
		[Inserted_Length] [smallint] NULL,
		[Inserted_Precision] [tinyint] NULL,
		[Inserted_Scale] [tinyint] NULL,
		[Inserted_IsNullable] [bit] NULL,
		[Deleted_TableId] [int] NULL,
		[Deleted_DataTypeId] [int] NULL,
		[Deleted_Path] [nvarchar](700) NULL,
		[Deleted_Name] [sys].[sysname] NULL,
		[Deleted_Ordinal] [int] NULL,
		[Deleted_Length] [smallint] NULL,
		[Deleted_Precision] [tinyint] NULL,
		[Deleted_Scale] [tinyint] NULL,
		[Deleted_IsNullable] [bit] NULL
	)
	DECLARE @Entity TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[EntityType] [sys].[sysname] NOT NULL,
		[EntityGUID] [uniqueidentifier] NOT NULL,
		[ChangeCount] [int] NOT NULL
	)
	DECLARE @EntityLocator TABLE
	(
		[EntityType] [sys].[sysname] NOT NULL,
		[EntityGUID] [uniqueidentifier] NOT NULL,
		[Order] [int] NOT NULL,
		[Type] [sys].[sysname] NOT NULL,
		[GUID] [uniqueidentifier] NOT NULL,
		[Name] [sys].[sysname] NULL
	)
	DECLARE @EntityChange TABLE
	(
		[EntityType] [sys].[sysname] NOT NULL,
		[EntityGUID] [uniqueidentifier] NOT NULL,
		[Order] [int] NOT NULL,
		[Attribute] [sys].[sysname] NOT NULL,
		[PreviousValue] [sql_variant] NULL,
		[NewValue] [sql_variant] NULL
	)

	INSERT INTO [DataCatalog].[InstanceType]([Name])
		OUTPUT
			'INSERT' AS [Action],
			[inserted].[InstanceTypeId],
			[inserted].[Name] AS [Inserted_Name],
			NULL [Deleted_Name]
			INTO @InstanceTypeHistory
		SELECT DISTINCT [Source].[Name]
			FROM
			(
				SELECT [InstanceType_Source].[Name] AS [Name]
					FROM OPENJSON(@JSON)
						WITH ([Name] [sys].[sysname] N'$.InstanceType') AS [InstanceType_Source]
				UNION SELECT [DataType_Source].[Name]
					FROM OPENJSON(@JSON)
							WITH ([DatabasesJSON] [nvarchar](MAX) N'$.Databases' AS JSON) AS [Instance_Source]
						CROSS APPLY OPENJSON([Instance_Source].[DatabasesJSON])
							WITH ([SchemasJSON] [nvarchar](MAX) N'$.Schemas' AS JSON) AS [Database_Source]
						CROSS APPLY OPENJSON([Database_Source].[SchemasJSON])
							WITH ([TablesJSON] [nvarchar](MAX) N'$.Tables' AS JSON) AS [Schema_Source]
						CROSS APPLY OPENJSON([Schema_Source].[TablesJSON])
							WITH ([ColumnsJSON] [nvarchar](MAX) N'$.Columns' AS JSON) AS [Table_Source]
						CROSS APPLY OPENJSON([Table_Source].[ColumnsJSON])
							WITH ([DataTypeJSON] [nvarchar](MAX) N'$.DataType' AS JSON) AS [Column_Source]
						CROSS APPLY OPENJSON([Column_Source].[DataTypeJSON])
							WITH ([Name] [sys].[sysname] N'$.InstanceType') AS [DataType_Source]

			) AS [Source]
				LEFT OUTER JOIN [DataCatalog].[InstanceType] AS [Target]
					ON [Source].[Name] = [Target].[Name]
			WHERE [Target].[InstanceTypeId] IS NULL
	INSERT INTO [DataCatalog].[DataType]([InstanceTypeId], [Name])
		OUTPUT
			'INSERT' AS [Action],
			[inserted].[DataTypeId],
			[inserted].[InstanceTypeId] AS [Inserted_InstanceTypeId],
			[inserted].[Name] AS [Inserted_Name],
			NULL [Deleted_InstanceTypeId],
			NULL [Deleted_Name]
			INTO @DataTypeHistory
		SELECT DISTINCT
			[InstanceType].[InstanceTypeId],
			[Source].[Name]
			FROM
			(
				SELECT
					NULLIF(CONCAT(ISNULL([DataType_Source].[Name], N''), N''), N'') AS [Name],
					[DataType_Source].[InstanceType] AS [InstanceType]
					FROM OPENJSON(@JSON)
							WITH ([DatabasesJSON] [nvarchar](MAX) N'$.Databases' AS JSON) AS [Instance_Source]
						CROSS APPLY OPENJSON([Instance_Source].[DatabasesJSON])
							WITH ([SchemasJSON] [nvarchar](MAX) N'$.Schemas' AS JSON) AS [Database_Source]
						CROSS APPLY OPENJSON([Database_Source].[SchemasJSON])
							WITH ([TablesJSON] [nvarchar](MAX) N'$.Tables' AS JSON) AS [Schema_Source]
						CROSS APPLY OPENJSON([Schema_Source].[TablesJSON])
							WITH ([ColumnsJSON] [nvarchar](MAX) N'$.Columns' AS JSON) AS [Table_Source]
						CROSS APPLY OPENJSON([Table_Source].[ColumnsJSON])
							WITH ([DataTypeJSON] [nvarchar](MAX) N'$.DataType' AS JSON) AS [Column_Source]
						CROSS APPLY OPENJSON([Column_Source].[DataTypeJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name',
								[InstanceType] [sys].[sysname] N'$.InstanceType'
							) AS [DataType_Source]
			) AS [Source]
				INNER JOIN [DataCatalog].[InstanceType]
					ON [Source].[InstanceType] = [InstanceType].[Name]
				LEFT OUTER JOIN [DataCatalog].[DataType] AS [Target]
					ON
						[InstanceType].[InstanceTypeId] = [Target].[InstanceTypeId]
						AND [Source].[Name] = [Target].[Name]
			WHERE
				[Source].[Name] IS NOT NULL
				AND [Target].[DataTypeId] IS NULL
	INSERT INTO [DataCatalog].[Instance]([InstanceTypeId], [Path], [Name])
		OUTPUT
			'INSERT' AS [Action],
			[inserted].[InstanceId],
			[inserted].[InstanceTypeId] AS [Inserted_InstanceTypeId],
    		[inserted].[Path] AS [Inserted_Path],
			[inserted].[Name] AS [Inserted_Name],
			NULL AS [Deleted_InstanceTypeId],
    		NULL AS [Deleted_Path],
			NULL AS [Deleted_Name]
			INTO @InstanceHistory
		SELECT DISTINCT
			[Source].[InstanceTypeId],
            [Source].[Path],
			[Source].[Name]
			FROM
			(
				SELECT DISTINCT
					[InstanceType].[InstanceTypeId],
                    [Instance_Source].[Name] AS [Path],
					[Instance_Source].[Name] AS [Name]
					FROM OPENJSON(@JSON)
						WITH
						(
							[Name] [sys].[sysname] N'$.Name',
							[InstanceType] [sys].[sysname] N'$.InstanceType'
						) AS [Instance_Source]
						INNER JOIN [DataCatalog].[InstanceType]
							ON [Instance_Source].[InstanceType] = [InstanceType].[Name]
			) AS [Source]
				LEFT OUTER JOIN [DataCatalog].[Instance] AS [Target]
					ON
						[Source].[InstanceTypeId] = [Target].[InstanceTypeId]
						AND [Source].[Name] = [Target].[Name]
			WHERE [Target].[InstanceId] IS NULL
	INSERT INTO [DataCatalog].[Database]([InstanceId], [Path], [Name])
		OUTPUT
			'INSERT' AS [Action],
			[inserted].[DatabaseId],
			[inserted].[InstanceId] AS [Inserted_InstanceId],
    		[inserted].[Path] AS [Inserted_Path],
			[inserted].[Name] AS [Inserted_Name],
			NULL AS [Deleted_InstanceId],
    		NULL AS [Deleted_Path],
			NULL AS [Deleted_Name]
			INTO @DatabaseHistory
		SELECT DISTINCT
			[Instance].[InstanceId],
            [Source].[Path],
			[Source].[Name]
			FROM
			(
				SELECT
					[Instance_Source].[Name] AS [Instance],
                    CONCAT
                    (
                        [Instance_Source].[Name], N'|',
                        [Database_Source].[Name]
                    ) AS [Path],
					[Database_Source].[Name] AS [Name]
					FROM OPENJSON(@JSON)
						WITH
						(
							[Name] [sys].[sysname] N'$.Name',
							[DatabasesJSON] [nvarchar](MAX) N'$.Databases' AS JSON
						) AS [Instance_Source]
						CROSS APPLY OPENJSON([Instance_Source].[DatabasesJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name'
							) AS [Database_Source]
			) AS [Source]
				INNER JOIN [DataCatalog].[Instance]
					ON [Source].[Instance] = [Instance].[Name]
				LEFT OUTER JOIN [DataCatalog].[Database] AS [Target]
					ON
						[Instance].[InstanceId] = [Target].[InstanceId]
						AND [Source].[Name] = [Target].[Name]
			WHERE [Target].[DatabaseId] IS NULL
	INSERT INTO [DataCatalog].[Schema]([DatabaseId], [Path], [Name])
		OUTPUT
			'INSERT' AS [Action],
			[inserted].[SchemaId],
			[inserted].[DatabaseId] AS [Inserted_DatabaseId],
    		[inserted].[Path] AS [Inserted_Path],
			[inserted].[Name] AS [Inserted_Name],
			NULL AS [Deleted_DatabaseId],
    		NULL AS [Deleted_Path],
			NULL AS [Deleted_Name]
			INTO @SchemaHistory
		SELECT DISTINCT
			[Database].[DatabaseId],
            [Source].[Path],
			[Source].[Name]
			FROM
			(
				SELECT
					[Instance_Source].[Name] AS [Instance],
					[Database_Source].[Name] AS [Database],
                    CONCAT
                    (
                        [Instance_Source].[Name], N'|',
                        [Database_Source].[Name], N'|',
                        [Schema_Source].[Name]
                    ) AS [Path],
					[Schema_Source].[Name] AS [Name]
					FROM OPENJSON(@JSON)
						WITH
						(
							[Name] [sys].[sysname] N'$.Name',
							[DatabasesJSON] [nvarchar](MAX) N'$.Databases' AS JSON
						) AS [Instance_Source]
						CROSS APPLY OPENJSON([Instance_Source].[DatabasesJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name',
								[SchemasJSON] [nvarchar](MAX) N'$.Schemas' AS JSON
							) AS [Database_Source]
						CROSS APPLY OPENJSON([Database_Source].[SchemasJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name'
							) AS [Schema_Source]
			) AS [Source]
				INNER JOIN [DataCatalog].[Instance]
					ON [Source].[Instance] = [Instance].[Name]
				INNER JOIN [DataCatalog].[Database]
					ON
						[Instance].[InstanceId] = [Database].[InstanceId]
						AND [Source].[Database] = [Database].[Name]
				LEFT OUTER JOIN [DataCatalog].[Schema] AS [Target]
					ON
						[Database].[DatabaseId] = [Target].[DatabaseId]
						AND [Source].[Name] = [Target].[Name]
			WHERE [Target].[SchemaId] IS NULL
	INSERT INTO [DataCatalog].[Table]([SchemaId], [Path], [Name])
		OUTPUT
			'INSERT' AS [Action],
			[inserted].[TableId],
			[inserted].[SchemaId] AS [Inserted_SchemaId],
    		[inserted].[Path] AS [Inserted_Path],
			[inserted].[Name] AS [Inserted_Name],
			NULL AS [Deleted_SchemaId],
    		NULL AS [Deleted_Path],
			NULL AS [Deleted_Name]
			INTO @TableHistory
		SELECT DISTINCT
			[Schema].[SchemaId],
            [Source].[Path],
			[Source].[Name]
			FROM
			(
				SELECT
					[Instance_Source].[Name] AS [Instance],
					[Database_Source].[Name] AS [Database],
					[Schema_Source].[Name] AS [Schema],
                    CONCAT
                    (
                        [Instance_Source].[Name], N'|',
                        [Database_Source].[Name], N'|',
                        [Schema_Source].[Name], N'|',
                        [Table_Source].[Name]
                    ) AS [Path],
					[Table_Source].[Name] AS [Name]
					FROM OPENJSON(@JSON)
						WITH
						(
							[Name] [sys].[sysname] N'$.Name',
							[DatabasesJSON] [nvarchar](MAX) N'$.Databases' AS JSON
						) AS [Instance_Source]
						CROSS APPLY OPENJSON([Instance_Source].[DatabasesJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name',
								[SchemasJSON] [nvarchar](MAX) N'$.Schemas' AS JSON
							) AS [Database_Source]
						CROSS APPLY OPENJSON([Database_Source].[SchemasJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name',
								[TablesJSON] [nvarchar](MAX) N'$.Tables' AS JSON
							) AS [Schema_Source]
						CROSS APPLY OPENJSON([Schema_Source].[TablesJSON])
							WITH
							(
								[Name] [sys].[sysname] N'$.Name'
							) AS [Table_Source]

			) AS [Source]
				INNER JOIN [DataCatalog].[Instance]
					ON [Source].[Instance] = [Instance].[Name]
				INNER JOIN [DataCatalog].[Database]
					ON
						[Instance].[InstanceId] = [Database].[InstanceId]
						AND [Source].[Database] = [Database].[Name]
				INNER JOIN [DataCatalog].[Schema]
					ON
						[Database].[DatabaseId] = [Schema].[DatabaseId]
						AND [Source].[Schema] = [Schema].[Name]
				LEFT OUTER JOIN [DataCatalog].[Table] AS [Target]
					ON
						[Schema].[SchemaId] = [Target].[SchemaId]
						AND [Source].[Name] = [Target].[Name]
			WHERE [Target].[TableId] IS NULL
	MERGE [DataCatalog].[Column] AS [Target]
		USING
		(
			SELECT
				[Table].[TableId] AS [TableId],
				[DataType].[DataTypeId] AS [DataTypeId],
				[Column_Source].[Path] AS [Path],
				[Column_Source].[Name] AS [Name],
				ISNULL([Column_Source].[Ordinal], 0) AS [Ordinal],
				[Column_Source].[Length] AS [Length],
				[Column_Source].[Precision] AS [Precision],
				[Column_Source].[Scale] AS [Scale],
				[Column_Source].[IsNullable] AS [IsNullable]
				FROM
				(
					SELECT
						[Instance_Source].[Name] AS [Instance],
						[Database_Source].[Name] AS [Database],
						[Schema_Source].[Name] AS [Schema],
						[Table_Source].[Name] AS [Table],
                        CONCAT
                        (
                            [Instance_Source].[Name], N'|',
                            [Database_Source].[Name], N'|',
                            [Schema_Source].[Name], N'|',
                            [Table_Source].[Name], N'|',
                            [Column_Source].[Name]
                        ) AS [Path],
						[Column_Source].[Name] AS [Name],
						NULLIF(CONCAT(ISNULL([Column_Source].[DataTypeName], N''), N''), N'') AS [DataTypeName],
						[Column_Source].[DataTypeInstanceType] AS [DataTypeInstanceType],
        				[Column_Source].[Ordinal] AS [Ordinal],
						[Column_Source].[Length] AS [Length],
						[Column_Source].[Precision] AS [Precision],
						[Column_Source].[Scale] AS [Scale],
						[Column_Source].[IsNullable] AS [IsNullable]
						FROM OPENJSON(@JSON)
							WITH
							(
								[Name] [sys].[sysname] N'$.Name',
								[DatabasesJSON] [nvarchar](MAX) N'$.Databases' AS JSON
							) AS [Instance_Source]
							CROSS APPLY OPENJSON([Instance_Source].[DatabasesJSON])
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[SchemasJSON] [nvarchar](MAX) N'$.Schemas' AS JSON
								) AS [Database_Source]
							CROSS APPLY OPENJSON([Database_Source].[SchemasJSON])
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[TablesJSON] [nvarchar](MAX) N'$.Tables' AS JSON
								) AS [Schema_Source]
							CROSS APPLY OPENJSON([Schema_Source].[TablesJSON])
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[ColumnsJSON] [nvarchar](MAX) N'$.Columns' AS JSON
								) AS [Table_Source]
							CROSS APPLY OPENJSON([Table_Source].[ColumnsJSON])
								WITH
								(
									[Name] [sys].[sysname] N'$.Name',
									[DataTypeName] [sys].[sysname] N'$.DataType.Name',
									[DataTypeInstanceType] [sys].[sysname] N'$.DataType.InstanceType',
									[Ordinal] [int] N'$.Ordinal',
									[Length] [int] N'$.Length',
									[Precision] [tinyint] N'$.Precision',
									[Scale] [tinyint] N'$.Scale',
									[IsNullable] [bit] N'$.IsNullable'
								) AS [Column_Source]
				) AS [Column_Source]
					INNER JOIN [DataCatalog].[Instance]
						ON [Column_Source].[Instance] = [Instance].[Name]
					INNER JOIN [DataCatalog].[Database]
						ON
							[Instance].[InstanceId] = [Database].[InstanceId]
							AND [Column_Source].[Database] = [Database].[Name]
					INNER JOIN [DataCatalog].[Schema]
						ON
							[Database].[DatabaseId] = [Schema].[DatabaseId]
							AND [Column_Source].[Schema] = [Schema].[Name]
					INNER JOIN [DataCatalog].[Table]
						ON
							[Schema].[SchemaId] = [Table].[SchemaId]
							AND [Column_Source].[Table] = [Table].[Name]
					INNER JOIN [DataCatalog].[InstanceType] AS [InstanceType_DataType]
						ON [Column_Source].[DataTypeInstanceType] = [InstanceType_DataType].[Name]
					INNER JOIN [DataCatalog].[DataType]
						ON
							[InstanceType_DataType].[InstanceTypeId] = [DataType].[InstanceTypeId]
							AND [Column_Source].[DataTypeName] = [DataType].[Name]
		) AS [Source]
			ON
				[Target].[TableId] = [Source].[TableId]
				AND [Target].[Name] = [Source].[Name]
		WHEN MATCHED THEN UPDATE SET
				[DataTypeId] = [Source].[DataTypeId],
				[Path] = [Source].[Path],
				[Ordinal] = [Source].[Ordinal],
				[Length] = [Source].[Length],
				[Precision] = [Source].[Precision],
				[Scale] = [Source].[Scale],
				[IsNullable] = [Source].[IsNullable]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT([TableId], [DataTypeId], [Path], [Name], [Ordinal], [Length], [Precision], [Scale], [IsNullable])
				VALUES([Source].[TableId], [Source].[DataTypeId], [Source].[Path], [Source].[Name], [Source].[Ordinal], [Source].[Length], [Source].[Precision], [Source].[Scale], [Source].[IsNullable])
		OUTPUT
			$ACTION AS [Action],
			CASE
				WHEN $ACTION IN(N'INSERT', N'UPDATE')
					THEN [inserted].[ColumnId]
				WHEN $ACTION = N'DELETE'
					THEN [deleted].[ColumnId]
			END AS [ColumnId],
			[inserted].[TableId] AS [Inserted_TableId],
			[inserted].[DataTypeId] AS [Inserted_DataTypeId],
    		[inserted].[Path] AS [Inserted_Path],
			[inserted].[Name] AS [Inserted_Name],
			[inserted].[Ordinal] AS [Inserted_Ordinal],
			[inserted].[Length] AS [Inserted_Length],
			[inserted].[Precision] AS [Inserted_Precision],
			[inserted].[Scale] AS [Inserted_Scale],
			[inserted].[IsNullable] AS [Inserted_IsNullable],
			[deleted].[TableId] AS [Deleted_TableId],
			[deleted].[DataTypeId] AS [Deleted_DataTypeId],
    		[deleted].[Path] AS [Deleted_Path],
			[deleted].[Name] AS [Deleted_Name],
			[deleted].[Ordinal] AS [Deleted_Ordinal],
			[deleted].[Length] AS [Deleted_Length],
			[deleted].[Precision] AS [Deleted_Precision],
			[deleted].[Scale] AS [Deleted_Scale],
			[deleted].[IsNullable] AS [Deleted_IsNullable]
			INTO @ColumnHistory
	;

	SET @EndTime = SYSUTCDATETIME()
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@InstanceHistory].[Action],
			N'Instance' AS [EntityType],
			[Instance].[InstanceGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @InstanceHistory AS [@InstanceHistory]
				INNER JOIN [DataCatalog].[Instance]
					ON [@InstanceHistory].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'Path' AS [Attribute],
								CAST([@InstanceHistory].[Deleted_Path] AS [sql_variant]) AS [PreviousValue],
								CAST([@InstanceHistory].[Inserted_Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Name' AS [Attribute],
								CAST([@InstanceHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
								CAST([@InstanceHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@DatabaseHistory].[Action],
			N'Database' AS [EntityType],
			[Database].[DatabaseGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @DatabaseHistory AS [@DatabaseHistory]
				INNER JOIN [DataCatalog].[Database]
					ON [@DatabaseHistory].[DatabaseId] = [Database].[DatabaseId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'Path' AS [Attribute],
								CAST([@DatabaseHistory].[Deleted_Path] AS [sql_variant]) AS [PreviousValue],
								CAST([@DatabaseHistory].[Inserted_Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Name' AS [Attribute],
								CAST([@DatabaseHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
								CAST([@DatabaseHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@SchemaHistory].[Action],
			N'Schema' AS [EntityType],
			[Schema].[SchemaGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @SchemaHistory AS [@SchemaHistory]
				INNER JOIN [DataCatalog].[Schema]
					ON [@SchemaHistory].[SchemaId] = [Schema].[SchemaId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'Path' AS [Attribute],
								CAST([@SchemaHistory].[Deleted_Path] AS [sql_variant]) AS [PreviousValue],
								CAST([@SchemaHistory].[Inserted_Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Name' AS [Attribute],
								CAST([@SchemaHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
								CAST([@SchemaHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@TableHistory].[Action],
			N'Table' AS [EntityType],
			[Table].[TableGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @TableHistory AS [@TableHistory]
				INNER JOIN [DataCatalog].[Table]
					ON [@TableHistory].[TableId] = [Table].[TableId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'Path' AS [Attribute],
								CAST([@TableHistory].[Deleted_Path] AS [sql_variant]) AS [PreviousValue],
								CAST([@TableHistory].[Inserted_Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Name' AS [Attribute],
								CAST([@TableHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
								CAST([@TableHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@ColumnHistory].[Action],
			N'Column' AS [EntityType],
			[Column].[ColumnGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @ColumnHistory AS [@ColumnHistory]
				INNER JOIN [DataCatalog].[Column]
					ON [@ColumnHistory].[ColumnId] = [Column].[ColumnId]
				LEFT OUTER JOIN [DataCatalog].[DataType] AS [DataType_Inserted]
					ON [@ColumnHistory].[Inserted_DataTypeId] = [DataType_Inserted].[DataTypeId]
				LEFT OUTER JOIN [DataCatalog].[DataType] AS [DataType_Deleted]
					ON [@ColumnHistory].[Deleted_DataTypeId] = [DataType_Deleted].[DataTypeId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'Path' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_Path] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Name' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'DataType' AS [Attribute],
								CAST([DataType_Deleted].[Name] AS [sql_variant]) AS [PreviousValue],
								CAST([DataType_Inserted].[Name] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Ordinal' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_Ordinal] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_Ordinal] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Length' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_Length] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_Length] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Precision' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_Precision] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_Precision] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Scale' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_Scale] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_Scale] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'IsNullable' AS [Attribute],
								CAST([@ColumnHistory].[Deleted_IsNullable] AS [sql_variant]) AS [PreviousValue],
								CAST([@ColumnHistory].[Inserted_IsNullable] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0

	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'Instance' AS [EntityType],
			[Instance].[InstanceGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @InstanceHistory AS [@InstanceHistory]
				INNER JOIN [DataCatalog].[Instance]
					ON [@InstanceHistory].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Instance' AS [Type],
						[Instance].[InstanceGUID] AS [GUID],
						[Instance].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'Database' AS [EntityType],
			[Database].[DatabaseGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @DatabaseHistory AS [@DatabaseHistory]
				INNER JOIN [DataCatalog].[Database]
					ON [@DatabaseHistory].[DatabaseId] = [Database].[DatabaseId]
				INNER JOIN [DataCatalog].[Instance]
					ON [Database].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Database' AS [Type],
						[Database].[DatabaseGUID] AS [GUID],
						[Database].[Name] AS [Name]
					UNION ALL SELECT
						2 AS [Order],
						N'Instance' AS [Type],
						[Instance].[InstanceGUID] AS [GUID],
						[Instance].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'Schema' AS [EntityType],
			[Schema].[SchemaGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @SchemaHistory AS [@SchemaHistory]
				INNER JOIN [DataCatalog].[Schema]
					ON [@SchemaHistory].[SchemaId] = [Schema].[SchemaId]
				INNER JOIN [DataCatalog].[Database]
					ON [Schema].[DatabaseId] = [Database].[DatabaseId]
				INNER JOIN [DataCatalog].[Instance]
					ON [Database].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Schema' AS [Type],
						[Schema].[SchemaGUID] AS [GUID],
						[Schema].[Name] AS [Name]
					UNION ALL SELECT
						2 AS [Order],
						N'Database' AS [Type],
						[Database].[DatabaseGUID] AS [GUID],
						[Database].[Name] AS [Name]
					UNION ALL SELECT
						3 AS [Order],
						N'Instance' AS [Type],
						[Instance].[InstanceGUID] AS [GUID],
						[Instance].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'Table' AS [EntityType],
			[Table].[TableGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @TableHistory AS [@TableHistory]
				INNER JOIN [DataCatalog].[Table]
					ON [@TableHistory].[TableId] = [Table].[TableId]
				INNER JOIN [DataCatalog].[Schema]
					ON [Table].[SchemaId] = [Schema].[SchemaId]
				INNER JOIN [DataCatalog].[Database]
					ON [Schema].[DatabaseId] = [Database].[DatabaseId]
				INNER JOIN [DataCatalog].[Instance]
					ON [Database].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Table' AS [Type],
						[Table].[TableGUID] AS [GUID],
						[Table].[Name] AS [Name]
					UNION ALL SELECT
						2 AS [Order],
						N'Schema' AS [Type],
						[Schema].[SchemaGUID] AS [GUID],
						[Schema].[Name] AS [Name]
					UNION ALL SELECT
						3 AS [Order],
						N'Database' AS [Type],
						[Database].[DatabaseGUID] AS [GUID],
						[Database].[Name] AS [Name]
					UNION ALL SELECT
						4 AS [Order],
						N'Instance' AS [Type],
						[Instance].[InstanceGUID] AS [GUID],
						[Instance].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'Column' AS [EntityType],
			[Column].[ColumnGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @ColumnHistory AS [@ColumnHistory]
				INNER JOIN [DataCatalog].[Column]
					ON [@ColumnHistory].[ColumnId] = [Column].[ColumnId]
				INNER JOIN [DataCatalog].[Table]
					ON [Column].[TableId] = [Table].[TableId]
				INNER JOIN [DataCatalog].[Schema]
					ON [Table].[SchemaId] = [Schema].[SchemaId]
				INNER JOIN [DataCatalog].[Database]
					ON [Schema].[DatabaseId] = [Database].[DatabaseId]
				INNER JOIN [DataCatalog].[Instance]
					ON [Database].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Column' AS [Type],
						[Column].[ColumnGUID] AS [GUID],
						[Column].[Name] AS [Name]
					UNION ALL SELECT
						2 AS [Order],
						N'Table' AS [Type],
						[Table].[TableGUID] AS [GUID],
						[Table].[Name] AS [Name]
					UNION ALL SELECT
						3 AS [Order],
						N'Schema' AS [Type],
						[Schema].[SchemaGUID] AS [GUID],
						[Schema].[Name] AS [Name]
					UNION ALL SELECT
						4 AS [Order],
						N'Database' AS [Type],
						[Database].[DatabaseGUID] AS [GUID],
						[Database].[Name] AS [Name]
					UNION ALL SELECT
						5 AS [Order],
						N'Instance' AS [Type],
						[Instance].[InstanceGUID] AS [GUID],
						[Instance].[Name] AS [Name]
				) AS [EntityLocator]

	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'Instance' AS [EntityType],
			[Instance].[InstanceGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @InstanceHistory AS [@InstanceHistory]
				INNER JOIN [DataCatalog].[Instance]
					ON [@InstanceHistory].[InstanceId] = [Instance].[InstanceId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Name' AS [Attribute],
						CAST([@InstanceHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
						CAST([@InstanceHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'Database' AS [EntityType],
			[Database].[DatabaseGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @DatabaseHistory AS [@DatabaseHistory]
				INNER JOIN [DataCatalog].[Database]
					ON [@DatabaseHistory].[DatabaseId] = [Database].[DatabaseId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Name' AS [Attribute],
						CAST([@DatabaseHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
						CAST([@DatabaseHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'Schema' AS [EntityType],
			[Schema].[SchemaGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @SchemaHistory AS [@SchemaHistory]
				INNER JOIN [DataCatalog].[Schema]
					ON [@SchemaHistory].[SchemaId] = [Schema].[SchemaId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Name' AS [Attribute],
						CAST([@SchemaHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
						CAST([@SchemaHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'Table' AS [EntityType],
			[Table].[TableGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @TableHistory AS [@TableHistory]
				INNER JOIN [DataCatalog].[Table]
					ON [@TableHistory].[TableId] = [Table].[TableId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Name' AS [Attribute],
						CAST([@TableHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
						CAST([@TableHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'Column' AS [EntityType],
			[Column].[ColumnGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @ColumnHistory AS [@ColumnHistory]
				INNER JOIN [DataCatalog].[Column]
					ON [@ColumnHistory].[ColumnId] = [Column].[ColumnId]
				LEFT OUTER JOIN [DataCatalog].[DataType] AS [DataType_Inserted]
					ON [@ColumnHistory].[Inserted_DataTypeId] = [DataType_Inserted].[DataTypeId]
				LEFT OUTER JOIN [DataCatalog].[DataType] AS [DataType_Deleted]
					ON [@ColumnHistory].[Deleted_DataTypeId] = [DataType_Deleted].[DataTypeId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Name' AS [Attribute],
						CAST([@ColumnHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
						CAST([@ColumnHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						2 AS [Order],
						N'DataType' AS [Attribute],
						CAST([DataType_Deleted].[Name] AS [sql_variant]) AS [PreviousValue],
						CAST([DataType_Inserted].[Name] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						3 AS [Order],
						N'Length' AS [Attribute],
						CAST([@ColumnHistory].[Deleted_Length] AS [sql_variant]) AS [PreviousValue],
						CAST([@ColumnHistory].[Inserted_Length] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						4 AS [Order],
						N'Precision' AS [Attribute],
						CAST([@ColumnHistory].[Deleted_Precision] AS [sql_variant]) AS [PreviousValue],
						CAST([@ColumnHistory].[Inserted_Precision] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						5 AS [Order],
						N'Scale' AS [Attribute],
						CAST([@ColumnHistory].[Deleted_Scale] AS [sql_variant]) AS [PreviousValue],
						CAST([@ColumnHistory].[Inserted_Scale] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						6 AS [Order],
						N'IsNullable' AS [Attribute],
						CAST([@ColumnHistory].[Deleted_IsNullable] AS [sql_variant]) AS [PreviousValue],
						CAST([@ColumnHistory].[Inserted_IsNullable] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)

	SET @AuditPacket = CAST((
		SELECT
			@BeginTime AS [BeginTime],
			@EndTime AS [EndTime],
			@UserName AS [UserName],
			@Application AS [Application],
			@Host AS [Host],
			[ChangeStats].[TotalEntitiesChanged],
			ISNULL([ChangeStats].[TotalAttributesChanged], 0) AS [TotalAttributesChanged],
			JSON_QUERY((
				SELECT
					[@Entity].[Action],
					[@Entity].[EntityType],
					[@Entity].[EntityGUID],
					JSON_QUERY((
						SELECT
							[@EntityLocator].[Order],
							[@EntityLocator].[Type],
							[@EntityLocator].[GUID],
							[@EntityLocator].[Name]
							FROM @EntityLocator AS [@EntityLocator]
							WHERE
								[@EntityLocator].[EntityType] = [@Entity].[EntityType]
								AND [@EntityLocator].[EntityGUID] = [@Entity].[EntityGUID]
							ORDER BY [@EntityLocator].[Order] ASC
							FOR JSON PATH, INCLUDE_NULL_VALUES
					)) AS [EntityLocators],
					JSON_QUERY((
						SELECT
							[@EntityChange].[Order],
							[@EntityChange].[Attribute],
							[@EntityChange].[PreviousValue],
							[@EntityChange].[NewValue]
							FROM @EntityChange AS [@EntityChange]
							WHERE
								[@EntityChange].[EntityType] = [@Entity].[EntityType]
								AND [@EntityChange].[EntityGUID] = [@Entity].[EntityGUID]
							ORDER BY [@EntityChange].[Order] ASC
							FOR JSON PATH, INCLUDE_NULL_VALUES
					)) AS [Changes]
					FROM @Entity AS [@Entity]
					FOR JSON PATH, INCLUDE_NULL_VALUES
			)) AS [Entities]
			FROM
			(
				SELECT
					COUNT(*) AS [TotalEntitiesChanged],
					SUM([ChangeCount]) AS [TotalAttributesChanged]
					FROM @Entity AS [@Entity]
			) AS [ChangeStats]
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
	) AS [nvarchar](MAX))
	EXEC [$(AuditSchemaName)].[PostAuditPacket] @AuditPacket = @AuditPacket
END
GO
PRINT CONCAT(N'Creating Procedure ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'PostMapping'))
GO
CREATE OR ALTER PROCEDURE [$(SchemaName)].[PostMapping]
(
	@UserName [sys].[sysname],
	@Application [sys].[sysname],
	@Host [sys].[sysname],
	@JSON [nvarchar](MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @BeginTime [datetime2](7) = SYSUTCDATETIME()
	DECLARE @EndTime [datetime2](7)
	DECLARE @AuditPacket [nvarchar](MAX)
	DECLARE @MappingHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[MappingId] [int] NOT NULL,
		[Inserted_Name] [sys].[sysname] NULL,
		[Inserted_Description] [nvarchar](500) NULL,
		[Deleted_Name] [sys].[sysname] NULL,
		[Deleted_Description] [nvarchar](500) NULL
	)
	DECLARE @MappingTablesHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[MappingTablesId] [int] NOT NULL,
		[Inserted_MappingId] [int] NULL,
		[Inserted_SourceTableId] [int] NULL,
		[Inserted_TargetTableId] [int] NULL,
		[Inserted_LinkingComment] [nvarchar](500) NULL,
		[Deleted_MappingId] [int] NULL,
		[Deleted_SourceTableId] [int] NULL,
		[Deleted_TargetTableId] [int] NULL,
		[Deleted_LinkingComment] [nvarchar](500) NULL
	)
	DECLARE @MappingColumnsHistory TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[MappingColumnsId] [int] NOT NULL,
		[Inserted_MappingTablesId] [int] NULL,
		[Inserted_SourceColumnId] [int] NULL,
		[Inserted_TargetColumnId] [int] NULL,
		[Inserted_TranformationComment] [nvarchar](500) NULL,
		[Deleted_MappingId] [int] NULL,
		[Deleted_SourceColumnId] [int] NULL,
		[Deleted_TargetColumnId] [int] NULL,
		[Deleted_TranformationComment] [nvarchar](500) NULL
	)
	DECLARE @Entity TABLE
	(
		[Action] [varchar](10) NOT NULL,
		[EntityType] [sys].[sysname] NOT NULL,
		[EntityGUID] [uniqueidentifier] NOT NULL,
		[ChangeCount] [int] NOT NULL
	)
	DECLARE @EntityLocator TABLE
	(
		[EntityType] [sys].[sysname] NOT NULL,
		[EntityGUID] [uniqueidentifier] NOT NULL,
		[Order] [int] NOT NULL,
		[Type] [sys].[sysname] NOT NULL,
		[GUID] [uniqueidentifier] NOT NULL,
		[Name] [sys].[sysname] NULL
	)
	DECLARE @EntityChange TABLE
	(
		[EntityType] [sys].[sysname] NOT NULL,
		[EntityGUID] [uniqueidentifier] NOT NULL,
		[Order] [int] NOT NULL,
		[Attribute] [sys].[sysname] NOT NULL,
		[PreviousValue] [sql_variant] NULL,
		[NewValue] [sql_variant] NULL
	)

	MERGE [$(SchemaName)].[Mapping] AS [Target]
		USING
		(
			SELECT
				[Mapping_Source].[Name] AS [Name],
				[Mapping_Source].[Description] AS [Description]
				FROM OPENJSON(@JSON)
					WITH
					(
						[Name] [sys].[sysname] N'$.Name',
						[Description] [nvarchar](500) N'$.Description'
					) AS [Mapping_Source]
		) AS [Source]
			ON [Target].[Name] = [Source].[Name]
		WHEN MATCHED THEN UPDATE SET [Description] = [Source].[Description]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT([Name], [Description])
				VALUES([Source].[Name], [Source].[Description])
		OUTPUT
			$ACTION AS [Action],
			CASE
				WHEN $ACTION IN(N'INSERT', N'UPDATE')
					THEN [inserted].[MappingId]
				WHEN $ACTION = N'DELETE'
					THEN [deleted].[MappingId]
			END AS [MappingId],
			[inserted].[Name] AS [Inserted_Name],
			[inserted].[Description] AS [Inserted_Description],
			[deleted].[Name] AS [Deleted_Name],
			[deleted].[Description] AS [Deleted_Description]
			INTO @MappingHistory
	;

	MERGE [$(SchemaName)].[MappingTables] AS [Target]
		USING
		(
			SELECT
				[Mapping].[MappingId],
				[Source_Table].[TableId] AS [SourceTableId],
				[Target_Table].[TableId] AS [TargetTableId],
				[Tables_Source].[LinkingComment]
				FROM OPENJSON(@JSON)
					WITH
					(
						[Name] [sys].[sysname] N'$.Name',
						[TablesJSON] [nvarchar](MAX) N'$.Tables' AS JSON
					) AS [Mapping_Source]
					CROSS APPLY OPENJSON([Mapping_Source].[TablesJSON])
						WITH
						(
							[SourcePath] [nvarchar](700) N'$.SourcePath',
							[TargetPath] [nvarchar](700) N'$.TargetPath',
							[LinkingComment] [nvarchar](500) N'$.LinkingComment'
						) AS [Tables_Source]
					INNER JOIN [$(SchemaName)].[Mapping]
						ON [Mapping_Source].[Name] = [Mapping].[Name]
					INNER JOIN [$(SchemaName)].[Table] AS [Source_Table]
						ON [Tables_Source].[SourcePath] = [Source_Table].[Path]
					INNER JOIN [$(SchemaName)].[Table] AS [Target_Table]
						ON [Tables_Source].[TargetPath] = [Target_Table].[Path]
		) AS [Source]
			ON
				[Target].[MappingId] = [Source].[MappingId]
				AND [Target].[SourceTableId] = [Source].[SourceTableId]
				AND [Target].[TargetTableId] = [Source].[TargetTableId]
		WHEN MATCHED THEN UPDATE SET [LinkingComment] = [Source].[LinkingComment]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT([MappingId], [SourceTableId], [TargetTableId], [LinkingComment])
				VALUES([Source].[MappingId], [Source].[SourceTableId], [Source].[TargetTableId], [Source].[LinkingComment])
		OUTPUT
			$ACTION AS [Action],
			CASE
				WHEN $ACTION IN(N'INSERT', N'UPDATE')
					THEN [inserted].[MappingTablesId]
				WHEN $ACTION = N'DELETE'
					THEN [deleted].[MappingTablesId]
			END AS [MappingTablesId],
			[inserted].[MappingId] AS [Inserted_MappingId],
			[inserted].[SourceTableId] AS [Inserted_SourceTableId],
			[inserted].[TargetTableId] AS [Inserted_TargetTableId],
			[inserted].[LinkingComment] AS [Inserted_LinkingComment],
			[deleted].[MappingId] AS [Deleted_MappingId],
			[deleted].[SourceTableId] AS [Deleted_SourceTableId],
			[deleted].[TargetTableId] AS [Deleted_TargetTableId],
			[deleted].[LinkingComment] AS [Deleted_LinkingComment]
			INTO @MappingTablesHistory
	;

	MERGE [$(SchemaName)].[MappingColumns] AS [Target]
		USING
		(
			SELECT
				[MappingTables].[MappingTablesId] AS [MappingTablesId],
				[Source_Column].[ColumnId] AS [SourceColumnId],
				[Target_Column].[ColumnId] AS [TargetColumnId],
				[Columns_Source].[TranformationComment] AS [TranformationComment]
				FROM OPENJSON(@JSON)
					WITH
					(
						[Name] [sys].[sysname] N'$.Name',
						[TablesJSON] [nvarchar](MAX) N'$.Tables' AS JSON
					) AS [Mapping_Source]
					CROSS APPLY OPENJSON([Mapping_Source].[TablesJSON])
						WITH
						(
							[SourcePath] [nvarchar](700) N'$.SourcePath',
							[TargetPath] [nvarchar](700) N'$.TargetPath',
							[ColumnsJSON] [nvarchar](MAX) N'$.Columns' AS JSON
						) AS [Tables_Source]
					CROSS APPLY OPENJSON([Tables_Source].[ColumnsJSON])
						WITH
						(
							[SourcePath] [nvarchar](700) N'$.SourcePath',
							[TargetPath] [nvarchar](700) N'$.TargetPath',
							[TranformationComment] [nvarchar](500) N'$.TranformationComment'
						) AS [Columns_Source]
					INNER JOIN [$(SchemaName)].[Mapping]
						ON [Mapping_Source].[Name] = [Mapping].[Name]
					INNER JOIN [$(SchemaName)].[Table] AS [Source_Table]
						ON [Tables_Source].[SourcePath] = [Source_Table].[Path]
					INNER JOIN [$(SchemaName)].[Table] AS [Target_Table]
						ON [Tables_Source].[TargetPath] = [Target_Table].[Path]
					INNER JOIN [$(SchemaName)].[MappingTables]
						ON
							[Mapping].[MappingId] = [MappingTables].[MappingId]
							AND [Source_Table].[TableId] = [MappingTables].[SourceTableId]
							AND [Target_Table].[TableId] = [MappingTables].[TargetTableId]
					LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Source_Column]
						ON
							[Source_Table].[TableId] = [Source_Column].[TableId]
							AND [Columns_Source].[SourcePath] = [Source_Column].[Path]
					LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Target_Column]
						ON
							[Target_Table].[TableId] = [Target_Column].[TableId]
							AND [Columns_Source].[TargetPath] = [Target_Column].[Path]
		) AS [Source]
			ON
				[Target].[MappingTablesId] = [Source].[MappingTablesId]
				AND [Target].[SourceColumnId] = [Source].[SourceColumnId]
				AND [Target].[TargetColumnId] = [Source].[TargetColumnId]
		WHEN MATCHED THEN UPDATE SET [TranformationComment] = [Source].[TranformationComment]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT([MappingTablesId], [SourceColumnId], [TargetColumnId], [TranformationComment])
				VALUES([Source].[MappingTablesId], [Source].[SourceColumnId], [Source].[TargetColumnId], [Source].[TranformationComment])
		OUTPUT
			$ACTION AS [Action],
			CASE
				WHEN $ACTION IN(N'INSERT', N'UPDATE')
					THEN [inserted].[MappingColumnsId]
				WHEN $ACTION = N'DELETE'
					THEN [deleted].[MappingColumnsId]
			END AS [MappingColumnsId],
			[inserted].[MappingTablesId] AS [Inserted_MappingTablesId],
			[inserted].[SourceColumnId] AS [Inserted_SourceColumnId],
			[inserted].[TargetColumnId] AS [Inserted_TargetColumnId],
			[inserted].[TranformationComment] AS [Inserted_TranformationComment],
			[deleted].[MappingTablesId] AS [Deleted_MappingTablesId],
			[deleted].[SourceColumnId] AS [Deleted_SourceColumnId],
			[deleted].[TargetColumnId] AS [Deleted_TargetColumnId],
			[deleted].[TranformationComment] AS [Deleted_TranformationComment]
			INTO @MappingColumnsHistory
	;
	SET @EndTime = SYSUTCDATETIME()
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@MappingHistory].[Action],
			N'Mapping' AS [EntityType],
			[Mapping].[MappingGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @MappingHistory AS [@MappingHistory]
				INNER JOIN [$(SchemaName)].[Mapping]
					ON [@MappingHistory].[MappingId] = [Mapping].[MappingId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'Name' AS [Attribute],
								CAST([@MappingHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
								CAST([@MappingHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'Description' AS [Attribute],
								CAST([@MappingHistory].[Deleted_Description] AS [sql_variant]) AS [PreviousValue],
								CAST([@MappingHistory].[Inserted_Description] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@MappingTablesHistory].[Action],
			N'MappingTables' AS [EntityType],
			[MappingTables].[MappingTablesGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @MappingTablesHistory AS [@MappingTablesHistory]
				INNER JOIN [$(SchemaName)].[MappingTables]
					ON [@MappingTablesHistory].[MappingTablesId] = [MappingTables].[MappingTablesId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_DeletedSource]
					ON [@MappingTablesHistory].[Deleted_SourceTableId] = [Table_DeletedSource].[TableId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_InsertedSource]
					ON [@MappingTablesHistory].[Inserted_SourceTableId] = [Table_InsertedSource].[TableId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_DeletedTarget]
					ON [@MappingTablesHistory].[Deleted_TargetTableId] = [Table_DeletedTarget].[TableId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_InsertedTarget]
					ON [@MappingTablesHistory].[Inserted_TargetTableId] = [Table_InsertedTarget].[TableId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'SourcePath' AS [Attribute],
								CAST([Table_DeletedSource].[Path] AS [sql_variant]) AS [PreviousValue],
								CAST([Table_InsertedSource].[Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'TargetPath' AS [Attribute],
								CAST([Table_DeletedTarget].[Path] AS [sql_variant]) AS [PreviousValue],
								CAST([Table_InsertedTarget].[Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'LinkingComment' AS [Attribute],
								CAST([@MappingTablesHistory].[Deleted_LinkingComment] AS [sql_variant]) AS [PreviousValue],
								CAST([@MappingTablesHistory].[Inserted_LinkingComment] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @Entity([Action], [EntityType], [EntityGUID], [ChangeCount])
		SELECT
			[@MappingColumnsHistory].[Action],
			N'MappingColumns' AS [EntityType],
			[MappingColumns].[MappingColumnsGUID] AS [EntityGUID],
			[Change].[Count] AS [ChangeCount]
			FROM @MappingColumnsHistory AS [@MappingColumnsHistory]
				INNER JOIN [$(SchemaName)].[MappingColumns]
					ON [@MappingColumnsHistory].[MappingColumnsId] = [MappingColumns].[MappingColumnsId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_DeletedSource]
					ON [@MappingColumnsHistory].[Deleted_SourceColumnId] = [Column_DeletedSource].[ColumnId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_InsertedSource]
					ON [@MappingColumnsHistory].[Inserted_SourceColumnId] = [Column_InsertedSource].[ColumnId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_DeletedTarget]
					ON [@MappingColumnsHistory].[Deleted_TargetColumnId] = [Column_DeletedTarget].[ColumnId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_InsertedTarget]
					ON [@MappingColumnsHistory].[Inserted_TargetColumnId] = [Column_InsertedTarget].[ColumnId]
				CROSS APPLY
				(
					SELECT COUNT(*) AS [Count]
						FROM
						(
							SELECT
								N'SourcePath' AS [Attribute],
								CAST([Column_DeletedSource].[Path] AS [sql_variant]) AS [PreviousValue],
								CAST([Column_InsertedSource].[Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'TargetPath' AS [Attribute],
								CAST([Column_DeletedTarget].[Path] AS [sql_variant]) AS [PreviousValue],
								CAST([Column_InsertedTarget].[Path] AS [sql_variant]) AS [NewValue]
							UNION ALL SELECT
								N'TranformationComment' AS [Attribute],
								CAST([@MappingColumnsHistory].[Deleted_TranformationComment] AS [sql_variant]) AS [PreviousValue],
								CAST([@MappingColumnsHistory].[Inserted_TranformationComment] AS [sql_variant]) AS [NewValue]
						) AS [Change]
						WHERE
							[Change].[PreviousValue] != [Change].[NewValue]
							OR
							(
								[Change].[PreviousValue] IS NULL
								AND [Change].[NewValue] IS NOT NULL
							)
							OR
							(
								[Change].[PreviousValue] IS NOT NULL
								AND [Change].[NewValue] IS NULL
							)
				) AS [Change]
			WHERE [Change].[Count] > 0
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'Mapping' AS [EntityType],
			[Mapping].[MappingGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @MappingHistory AS [@MappingHistory]
				INNER JOIN [$(SchemaName)].[Mapping]
					ON [@MappingHistory].[MappingId] = [Mapping].[MappingId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Mapping' AS [Type],
						[Mapping].[MappingGUID] AS [GUID],
						[Mapping].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'MappingTables' AS [EntityType],
			[MappingTables].[MappingTablesGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @MappingTablesHistory AS [@MappingTablesHistory]
				INNER JOIN [$(SchemaName)].[MappingTables]
					ON [@MappingTablesHistory].[MappingTablesId] = [MappingTables].[MappingTablesId]
				INNER JOIN [$(SchemaName)].[Mapping]
					ON [MappingTables].[MappingId] = [Mapping].[MappingId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'MappingTables' AS [Type],
						[MappingTables].[MappingTablesGUID] AS [GUID],
						NULL AS [Name]
					UNION ALL SELECT
						2 AS [Order],
						N'Mapping' AS [Type],
						[Mapping].[MappingGUID] AS [GUID],
						[Mapping].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityLocator([EntityType], [EntityGUID], [Order], [Type], [GUID], [Name])
		SELECT
			N'MappingColumns' AS [EntityType],
			[MappingColumns].[MappingColumnsGUID] AS [EntityGUID],
			[EntityLocator].[Order],
			[EntityLocator].[Type],
			[EntityLocator].[GUID],
			[EntityLocator].[Name]
			FROM @MappingColumnsHistory AS [@MappingColumnsHistory]
				INNER JOIN [$(SchemaName)].[MappingColumns]
					ON [@MappingColumnsHistory].[MappingColumnsId] = [MappingColumns].[MappingColumnsId]
				INNER JOIN [$(SchemaName)].[MappingTables]
					ON [MappingColumns].[MappingTablesId] = [MappingTables].[MappingTablesId]
				INNER JOIN [$(SchemaName)].[Mapping]
					ON [MappingTables].[MappingId] = [Mapping].[MappingId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'MappingColumns' AS [Type],
						[MappingColumns].[MappingColumnsGUID] AS [GUID],
						NULL AS [Name]
					UNION ALL SELECT
						2 AS [Order],
						N'MappingTables' AS [Type],
						[MappingTables].[MappingTablesGUID] AS [GUID],
						NULL AS [Name]
					UNION ALL SELECT
						3 AS [Order],
						N'Mapping' AS [Type],
						[Mapping].[MappingGUID] AS [GUID],
						[Mapping].[Name] AS [Name]
				) AS [EntityLocator]
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'Mapping' AS [EntityType],
			[Mapping].[MappingGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @MappingHistory AS [@MappingHistory]
				INNER JOIN [$(SchemaName)].[Mapping]
					ON [@MappingHistory].[MappingId] = [Mapping].[MappingId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'Name' AS [Attribute],
						CAST([@MappingHistory].[Deleted_Name] AS [sql_variant]) AS [PreviousValue],
						CAST([@MappingHistory].[Inserted_Name] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						2 AS [Order],
						N'Description' AS [Attribute],
						CAST([@MappingHistory].[Deleted_Description] AS [sql_variant]) AS [PreviousValue],
						CAST([@MappingHistory].[Inserted_Description] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'MappingTables' AS [EntityType],
			[MappingTables].[MappingTablesGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @MappingTablesHistory AS [@MappingTablesHistory]
				INNER JOIN [$(SchemaName)].[MappingTables]
					ON [@MappingTablesHistory].[MappingTablesId] = [MappingTables].[MappingTablesId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_DeletedSource]
					ON [@MappingTablesHistory].[Deleted_SourceTableId] = [Table_DeletedSource].[TableId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_InsertedSource]
					ON [@MappingTablesHistory].[Inserted_SourceTableId] = [Table_InsertedSource].[TableId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_DeletedTarget]
					ON [@MappingTablesHistory].[Deleted_TargetTableId] = [Table_DeletedTarget].[TableId]
				LEFT OUTER JOIN [$(SchemaName)].[Table] AS [Table_InsertedTarget]
					ON [@MappingTablesHistory].[Inserted_TargetTableId] = [Table_InsertedTarget].[TableId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'SourcePath' AS [Attribute],
						CAST([Table_DeletedSource].[Path] AS [sql_variant]) AS [PreviousValue],
						CAST([Table_InsertedSource].[Path] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						2 AS [Order],
						N'TargetPath' AS [Attribute],
						CAST([Table_DeletedTarget].[Path] AS [sql_variant]) AS [PreviousValue],
						CAST([Table_InsertedTarget].[Path] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						3 AS [Order],
						N'LinkingComment' AS [Attribute],
						CAST([@MappingTablesHistory].[Deleted_LinkingComment] AS [sql_variant]) AS [PreviousValue],
						CAST([@MappingTablesHistory].[Inserted_LinkingComment] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	INSERT INTO @EntityChange([EntityType], [EntityGUID], [Order], [Attribute], [PreviousValue], [NewValue])
		SELECT
			N'MappingColumns' AS [EntityType],
			[MappingColumns].[MappingColumnsGUID] AS [EntityGUID],
			[ChangePivot].[Order],
			[ChangePivot].[Attribute],
			[ChangePivot].[PreviousValue],
			[ChangePivot].[NewValue]
			FROM @MappingColumnsHistory AS [@MappingColumnsHistory]
				INNER JOIN [$(SchemaName)].[MappingColumns]
					ON [@MappingColumnsHistory].[MappingColumnsId] = [MappingColumns].[MappingColumnsId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_DeletedSource]
					ON [@MappingColumnsHistory].[Deleted_SourceColumnId] = [Column_DeletedSource].[ColumnId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_InsertedSource]
					ON [@MappingColumnsHistory].[Inserted_SourceColumnId] = [Column_InsertedSource].[ColumnId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_DeletedTarget]
					ON [@MappingColumnsHistory].[Deleted_TargetColumnId] = [Column_DeletedTarget].[ColumnId]
				LEFT OUTER JOIN [$(SchemaName)].[Column] AS [Column_InsertedTarget]
					ON [@MappingColumnsHistory].[Inserted_TargetColumnId] = [Column_InsertedTarget].[ColumnId]
				CROSS APPLY
				(
					SELECT
						1 AS [Order],
						N'SourcePath' AS [Attribute],
						CAST([Column_DeletedSource].[Path] AS [sql_variant]) AS [PreviousValue],
						CAST([Column_InsertedSource].[Path] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						2 AS [Order],
						N'TargetPath' AS [Attribute],
						CAST([Column_DeletedTarget].[Path] AS [sql_variant]) AS [PreviousValue],
						CAST([Column_InsertedTarget].[Path] AS [sql_variant]) AS [NewValue]
					UNION ALL SELECT
						3 AS [Order],
						N'TranformationComment' AS [Attribute],
						CAST([@MappingColumnsHistory].[Deleted_TranformationComment] AS [sql_variant]) AS [PreviousValue],
						CAST([@MappingColumnsHistory].[Inserted_TranformationComment] AS [sql_variant]) AS [NewValue]
				) AS [ChangePivot]
			WHERE
				[ChangePivot].[PreviousValue] != [ChangePivot].[NewValue]
				OR
				(
					[ChangePivot].[PreviousValue] IS NULL
					AND [ChangePivot].[NewValue] IS NOT NULL
				)
				OR
				(
					[ChangePivot].[PreviousValue] IS NOT NULL
					AND [ChangePivot].[NewValue] IS NULL
				)
	SET @AuditPacket = CAST((
		SELECT
			@BeginTime AS [BeginTime],
			@EndTime AS [EndTime],
			@UserName AS [UserName],
			@Application AS [Application],
			@Host AS [Host],
			[ChangeStats].[TotalEntitiesChanged],
			ISNULL([ChangeStats].[TotalAttributesChanged], 0) AS [TotalAttributesChanged],
			JSON_QUERY((
				SELECT
					[@Entity].[Action],
					[@Entity].[EntityType],
					[@Entity].[EntityGUID],
					JSON_QUERY((
						SELECT
							[@EntityLocator].[Order],
							[@EntityLocator].[Type],
							[@EntityLocator].[GUID],
							[@EntityLocator].[Name]
							FROM @EntityLocator AS [@EntityLocator]
							WHERE
								[@EntityLocator].[EntityType] = [@Entity].[EntityType]
								AND [@EntityLocator].[EntityGUID] = [@Entity].[EntityGUID]
							ORDER BY [@EntityLocator].[Order] ASC
							FOR JSON PATH, INCLUDE_NULL_VALUES
					)) AS [EntityLocators],
					JSON_QUERY((
						SELECT
							[@EntityChange].[Order],
							[@EntityChange].[Attribute],
							[@EntityChange].[PreviousValue],
							[@EntityChange].[NewValue]
							FROM @EntityChange AS [@EntityChange]
							WHERE
								[@EntityChange].[EntityType] = [@Entity].[EntityType]
								AND [@EntityChange].[EntityGUID] = [@Entity].[EntityGUID]
							ORDER BY [@EntityChange].[Order] ASC
							FOR JSON PATH, INCLUDE_NULL_VALUES
					)) AS [Changes]
					FROM @Entity AS [@Entity]
					FOR JSON PATH, INCLUDE_NULL_VALUES
			)) AS [Entities]
			FROM
			(
				SELECT
					COUNT(*) AS [TotalEntitiesChanged],
					SUM([ChangeCount]) AS [TotalAttributesChanged]
					FROM @Entity AS [@Entity]
			) AS [ChangeStats]
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
	) AS [nvarchar](MAX))
	EXEC [$(AuditSchemaName)].[PostAuditPacket] @AuditPacket = @AuditPacket
END
GO
PRINT CONCAT(N'Creating View ', QUOTENAME(N'$(SchemaName)'), N'.', QUOTENAME(N'ColumnExpanded'))
GO
CREATE OR ALTER VIEW [$(SchemaName)].[ColumnExpanded]
AS
	SELECT
		[Instance].[InstanceGUID],
		[Database].[DatabaseGUID],
		[Schema].[SchemaGUID],
		[Table].[TableGUID],
		[Column].[ColumnGUID],
		[Column].[Path],
		[Instance].[Name] AS [InstanceName],
		[InstanceType].[Name] AS [InstanceType],
		[Database].[Name] AS [DatabaseName],
		[Schema].[Name] AS [SchemaName],
		[Table].[Name] AS [TableName],
		[Column].[Name] AS [ColumnName],
		[Column].[Ordinal],
		[DataType].[Name] AS [DataTypeName],
		[Column].[Length],
		[Column].[Precision],
		[Column].[Scale],
		[Column].[IsNullable]
		FROM [DataCatalog].[Instance]
			INNER JOIN [DataCatalog].[InstanceType]
				ON [Instance].[InstanceTypeId] = [InstanceType].[InstanceTypeId]
			INNER JOIN [DataCatalog].[Database]
				ON [Instance].[InstanceId] = [Database].[InstanceId]
			INNER JOIN [DataCatalog].[Schema]
				ON [Database].[DatabaseId] = [Schema].[DatabaseId]
			INNER JOIN [DataCatalog].[Table]
				ON [Schema].[SchemaId] = [Table].[SchemaId]
			INNER JOIN [DataCatalog].[Column]
				ON [Table].[TableId] = [Column].[TableId]
			INNER JOIN [DataCatalog].[DataType]
				ON [Column].[DataTypeId] = [DataType].[DataTypeId]
GO
