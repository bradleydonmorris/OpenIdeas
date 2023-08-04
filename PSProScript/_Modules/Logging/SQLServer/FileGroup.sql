DECLARE @Directory [nvarchar](400) = N'C:\MSSQL15.MSSQLSERVER\MSSQL\DATA'
IF @Directory NOT LIKE N'%\'
	SET @Directory += N'\'

DECLARE @FileName [nvarchar](400) = N'Logging'
DECLARE @SQLStatement [nvarchar](MAX)
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[filegroups]
		WHERE [filegroups].[name] = @FileName
)
	BEGIN
		SET @SQLStatement = CONCAT(N'ALTER DATABASE ', QUOTENAME(DB_NAME()), N' ADD FILEGROUP ', QUOTENAME(@FileName))
		EXECUTE(@SQLStatement)
	END
IF NOT EXISTS
(
	SELECT 1
		FROM [sys].[database_files]
			INNER JOIN [sys].[filegroups]
				ON [database_files].[data_space_id] = [filegroups].[data_space_id]
		WHERE
			 [filegroups].[name] = @FileName
			 AND [database_files].[name] = @FileName
)
	BEGIN
		SET @SQLStatement = CONCAT(N'ALTER DATABASE ', QUOTENAME(DB_NAME()), N' ADD FILE (NAME = N''', @FileName, ''', FILENAME = N''', @Directory, DB_NAME(), N'_', @FileName, '.ndf'', SIZE = 3072KB, FILEGROWTH = 65536KB) TO FILEGROUP ', QUOTENAME(@FileName))
		EXECUTE(@SQLStatement)
	END
