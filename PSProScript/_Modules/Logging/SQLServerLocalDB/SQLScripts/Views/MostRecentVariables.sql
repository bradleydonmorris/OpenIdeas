CREATE OR ALTER VIEW [Logging].[MostRecentVariables]
AS
	SELECT
		[Project].[Name] AS [Project],
		[Script].[Name] AS [Script],
		[Invocation].[ScriptFilePath],
		[Invocation].[Host],
		[Log].[LogGUID],
		[Log].[OpenLogTime],
		[Log].[CloseLogTime],
		[Variable].[Name],
		[Variable].[Value]
		FROM [Logging].[Project]
			INNER JOIN [Logging].[Script]
				ON [Project].[ProjectId] = [Script].[ProjectId]
			INNER JOIN [Logging].[Invocation]
				ON [Script].[ScriptId] = [Invocation].[ScriptId]
			INNER JOIN [Logging].[Log]
				ON [Invocation].[InvocationId] = [Log].[InvocationId]
			INNER JOIN
			(
					SELECT
						[Log].[InvocationId],
						MAX([Log].[OpenLogTime]) AS [MaximumOpenLogTime]
						FROM [Logging].[Log]
						GROUP BY [Log].[InvocationId]
			) AS [MostRecent]
				ON
					[Invocation].[InvocationId] = [MostRecent].[InvocationId]
					AND [Log].[OpenLogTime] = [MostRecent].[MaximumOpenLogTime]
			INNER JOIN [Logging].[Variable]
				ON [Log].[LogId] = [Variable].[LogId]
