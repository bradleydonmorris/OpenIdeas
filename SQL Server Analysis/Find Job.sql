SELECT
	[sysjobs].[name] AS [JobName],
	[sysjobsteps].[step_name] AS [StepName],
	[sysjobsteps].[command]
	FROM [msdb].[dbo].[sysjobs]
		INNER JOIN [msdb].[dbo].[sysjobsteps]
			ON [sysjobs].[job_id] = [sysjobsteps].[job_id]
	WHERE [sysjobsteps].[command] LIKE '%udp_rezcentral_index_creation_job%'