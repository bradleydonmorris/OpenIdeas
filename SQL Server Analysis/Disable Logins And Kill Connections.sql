DECLARE @Database TABLE ( [Name] [sys].[sysname] )
DECLARE @Login TABLE ( [Name] [sys].[sysname] )
INSERT INTO @Database([Name]) VALUES
	(N'42080'), (N'RezCentral')

--Server Login name. Not database user name
INSERT INTO @Login([Name]) VALUES
	(N'DomoServiceUser'), (N'domoreportsuser')

DECLARE @SQLStatement [nvarchar](MAX)
DECLARE @SessionId [int]
DECLARE @DatabaseName [sys].[sysname]
DECLARE @LoginName [sys].[sysname]

--Disable the Logins
DECLARE _LoginToDisconnect
	CURSOR FORWARD_ONLY READ_ONLY FOR
	SELECT [Name] FROM @Login
OPEN _LoginToDisconnect
FETCH NEXT FROM _LoginToDisconnect INTO @LoginName
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQLStatement = CONCAT(N'ALTER LOGIN ', QUOTENAME(@LoginName), ' DISABLE')
		PRINT CONCAT(N'Disabling ', QUOTENAME(@LoginName))
		--EXEC(@SQLStatement)
		FETCH NEXT FROM _LoginToDisconnect INTO @LoginName
	END
CLOSE _LoginToDisconnect
DEALLOCATE _LoginToDisconnect

--Kill active sessions for the Logins
--(@@SPID is filtered out to prevent accidently killing this session)
DECLARE _SessionToKill
	CURSOR FORWARD_ONLY READ_ONLY FOR
	SELECT DISTINCT
		[dm_exec_sessions].[session_id] [SessionId],
		[databases].[name] AS [DatabaseName],
		[sql_logins].[name] AS [LoginName]
		FROM [sys].[dm_exec_sessions]
			INNER JOIN [sys].[dm_exec_connections]
				ON [dm_exec_sessions].[session_id] = [dm_exec_connections].[session_id]
			INNER JOIN [sys].[sql_logins]
				ON [dm_exec_sessions].[security_id] = [sql_logins].[sid]
			--We only really care about locks at the database level, not down to the object level.
			INNER JOIN [sys].[dm_tran_locks]
				ON [dm_exec_sessions].[session_id] = [dm_tran_locks].[request_session_id]
			INNER JOIN [sys].[databases]
				ON [dm_tran_locks].[resource_database_id] = [databases].[database_id]
			INNER JOIN @Login AS [@Login]
				ON [sql_logins].[name] = [@Login].[Name]
			INNER JOIN @Database AS [@Database]
				ON [databases].[name] = [@Database].[Name]
		WHERE [dm_exec_sessions].[session_id] != @@SPID
OPEN _SessionToKill
FETCH NEXT FROM _SessionToKill INTO @SessionId, @DatabaseName, @LoginName
WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQLStatement = CONCAT(N'KILL ', @SessionId)
		PRINT CONCAT(N'Killing ', @SessionId, N' for ', QUOTENAME(@LoginName), N' on ', QUOTENAME(@DatabaseName))
		--EXEC(@SQLStatement)
		FETCH NEXT FROM _SessionToKill INTO @SessionId, @DatabaseName, @LoginName
	END
CLOSE _SessionToKill
DEALLOCATE _SessionToKill
