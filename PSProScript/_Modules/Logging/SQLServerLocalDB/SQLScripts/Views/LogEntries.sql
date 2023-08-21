CREATE OR ALTER VIEW [Logging].[LogEntries]
AS
	SELECT
		[Project].[Name] AS [Project],
		[Script].[Name] AS [Script],
		[Invocation].[ScriptFilePath],
		[Invocation].[Host],
		[Log].[LogGUID],
		[Log].[OpenLogTime],
		[Log].[CloseLogTime],
		[Level].[Name] AS [Level],
		[Entry].[EntryTime],
		[Entry].[Number],
		[Entry].[Text]
		FROM [Logging].[Project]
			INNER JOIN [Logging].[Script]
				ON [Project].[ProjectId] = [Script].[ProjectId]
			INNER JOIN [Logging].[Invocation]
				ON [Script].[ScriptId] = [Invocation].[ScriptId]
			INNER JOIN [Logging].[Log]
				ON [Invocation].[InvocationId] = [Log].[InvocationId]
			INNER JOIN [Logging].[Entry]
				ON [Log].[LogId] = [Entry].[LogId]
			INNER JOIN [Logging].[Level]
				ON [Entry].[LevelId] = [Level].[LevelId]