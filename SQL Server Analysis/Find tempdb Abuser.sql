SELECT
	[dm_exec_sessions].[session_id],
	[dm_exec_sessions].[login_time],
	[dm_exec_sessions].[host_name],
	[dm_exec_sessions].[program_name],
	[dm_exec_sessions].[client_interface_name],
	[dm_exec_sessions].[login_name],
	[dm_exec_sessions].[original_login_name],
	[databases].[name] AS [database],
	[databases_authenticating].[name] AS [authenticating_database],
	[dm_db_task_space_usage].[user_objects_alloc_page_count],
	[dm_db_task_space_usage].[internal_objects_alloc_page_count],
	[dm_db_task_space_usage].[user_objects_dealloc_page_count],
	[dm_db_task_space_usage].[internal_objects_dealloc_page_count],
	[dm_exec_requests_sql_text].[text]
	FROM
	(
		SELECT
			[dm_db_task_space_usage].[session_id],
			SUM([dm_db_task_space_usage].[user_objects_alloc_page_count]) AS [user_objects_alloc_page_count],
			SUM([dm_db_task_space_usage].[internal_objects_alloc_page_count]) AS [internal_objects_alloc_page_count],
			SUM([dm_db_task_space_usage].[user_objects_dealloc_page_count]) AS [user_objects_dealloc_page_count],
			SUM([dm_db_task_space_usage].[internal_objects_dealloc_page_count]) AS [internal_objects_dealloc_page_count],
			SUM
			(
				[dm_db_task_space_usage].[user_objects_alloc_page_count]
				+ [dm_db_task_space_usage].[internal_objects_alloc_page_count]
				+ [dm_db_task_space_usage].[user_objects_dealloc_page_count]
				+ [dm_db_task_space_usage].[internal_objects_dealloc_page_count]
			) AS [sum_for_order]
			FROM [tempdb].[sys].[dm_db_task_space_usage]
			GROUP BY [dm_db_task_space_usage].[session_id]
	) AS [dm_db_task_space_usage]
		INNER JOIN [master].[sys].[dm_exec_sessions]
			ON [dm_db_task_space_usage].[session_id] = [dm_exec_sessions].[session_id]
		LEFT OUTER JOIN [master].[sys].[databases]
			ON [dm_exec_sessions].[database_id] = [databases].[database_id]
		LEFT OUTER JOIN [master].[sys].[databases] AS [databases_authenticating]
			ON [dm_exec_sessions].[database_id] = [databases_authenticating].[database_id]
		LEFT OUTER JOIN
		(
			SELECT DISTINCT
				[dm_exec_requests].[session_id],
				[dm_exec_sql_text].[text]
				FROM [master].[sys].[dm_exec_requests]
					OUTER APPLY [master].[sys].[dm_exec_sql_text]([dm_exec_requests].[sql_handle]) AS [dm_exec_sql_text]
		) AS [dm_exec_requests_sql_text]
			ON [dm_db_task_space_usage].[session_id] = [dm_exec_requests_sql_text].[session_id]
	ORDER BY [dm_db_task_space_usage].[sum_for_order] DESC
