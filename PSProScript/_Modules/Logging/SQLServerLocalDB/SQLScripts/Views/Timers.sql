CREATE OR ALTER VIEW [Logging].[Timers]
AS
	SELECT
		[Project].[Name] AS [Project],
		[Script].[Name] AS [Script],
		[Invocation].[ScriptFilePath],
		[Invocation].[Host],
		[Log].[LogGUID],
		[Log].[OpenLogTime],
		[Log].[CloseLogTime],
		[Timer].[Sequence],
		[Timer].[Name],
		[Timer].[BeginTime],
		[Timer].[EndTime],
		[Timer].[ElapsedSeconds],
		CONCAT
		(
			IIF(FLOOR(([Timer].[ElapsedSeconds] * 1000) / 86400000) > 0, CONCAT(FORMAT(FLOOR(([Timer].[ElapsedSeconds] * 1000) / 86400000), N'0'), N'd '), N''),
			FORMAT(DATEADD([MILLISECOND], (([Timer].[ElapsedSeconds] * 1000) - (FLOOR(([Timer].[ElapsedSeconds] * 1000) / 86400000) * 86400000)), TRY_CAST(N'00:00:00' AS [time](7))), N'hh\:mm\:ss\.fffffff')
		) AS [ElapsedTime]
		FROM [Logging].[Project]
			INNER JOIN [Logging].[Script]
				ON [Project].[ProjectId] = [Script].[ProjectId]
			INNER JOIN [Logging].[Invocation]
				ON [Script].[ScriptId] = [Invocation].[ScriptId]
			INNER JOIN [Logging].[Log]
				ON [Invocation].[InvocationId] = [Log].[InvocationId]
			INNER JOIN [Logging].[Timer]
				ON [Log].[LogId] = [Timer].[LogId]
