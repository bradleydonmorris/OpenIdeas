	SELECT DISTINCT
		[dm_exec_sessions].[session_id] AS [SessionId],
		[server_principals].[name] AS [LoginName],
		[dm_exec_sessions].[host_name] AS [HostName],
		[dm_exec_sessions].[program_name] AS [ApplicationName],
		[dm_exec_sessions].[client_interface_name] AS [ClientInterfaceName],
		[databases].[name] AS [DatabaseName]
		FROM [sys].[dm_exec_sessions]
			LEFT OUTER JOIN [sys].[dm_exec_connections]
				ON [dm_exec_sessions].[session_id] = [dm_exec_connections].[session_id]
			INNER JOIN [sys].[server_principals]
				ON [dm_exec_sessions].[security_id] = [server_principals].[sid]
			LEFT OUTER JOIN [sys].[databases]
				ON [dm_exec_sessions].[database_id] = [databases].[database_id]
	--WHERE [server_principals].[name] = N'FOX\bmorris'
	WHERE [dm_exec_sessions].[session_id] = 119
--SELECT * FROM [sys].[server_principals]

/*

dbo_Fleet-Notes

dbo_RO_History

dbo_Service
*/