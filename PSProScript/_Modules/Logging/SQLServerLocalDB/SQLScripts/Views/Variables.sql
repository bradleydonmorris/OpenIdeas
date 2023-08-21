CREATE OR ALTER VIEW [Logging].[Variables]
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
			INNER JOIN [Logging].[Variable]
				ON [Log].[LogId] = [Variable].[LogId]
