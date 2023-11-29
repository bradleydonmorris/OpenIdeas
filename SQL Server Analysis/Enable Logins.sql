DECLARE @Login TABLE ( [Name] [sys].[sysname] )
--Server Login name. Not database user name
INSERT INTO @Login([Name]) VALUES
	(N'DomoServiceUser'), (N'domoreportsuser')

DECLARE @SQLStatement [nvarchar](MAX)
DECLARE @LoginName [sys].[sysname]

--Enable the Logins
DECLARE _LoginToDisconnect
	CURSOR FORWARD_ONLY READ_ONLY FOR
	SELECT [Name] FROM @Login
OPEN _LoginToDisconnect
FETCH NEXT FROM _LoginToDisconnect INTO @LoginName
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQLStatement = CONCAT(N'ALTER LOGIN ', QUOTENAME(@LoginName), ' ENABLE')
		PRINT CONCAT(N'Enabling ', QUOTENAME(@LoginName))
		--EXEC(@SQLStatement)
		FETCH NEXT FROM _LoginToDisconnect INTO @LoginName
	END
CLOSE _LoginToDisconnect
DEALLOCATE _LoginToDisconnect
