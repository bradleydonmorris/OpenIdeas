CREATE OR ALTER PROCEDURE [Logging].[ClearLogs]
(
	@Project [nvarchar](50),
	@Script [nvarchar](50),
	@Host [nvarchar](50),
	@ScriptFilePath [nvarchar](400),
	@RetentionDays [int]
)
AS
BEGIN
	DECLARE @OlderThan [datetime2](7) = DATEADD([day], ((-1)*@RetentionDays), SYSUTCDATETIME())
	DECLARE @Log TABLE ([LogId] [int])
	INSERT INTO @Log([LogId])
		SELECT [Log].[LogId]
			FROM [Logging].[Project]
				INNER JOIN [Logging].[Script]
					ON [Project].[ProjectId] = [Script].[ProjectId]
				INNER JOIN [Logging].[Invocation]
					ON [Script].[ScriptId] = [Invocation].[ScriptId]
				INNER JOIN [Logging].[Log]
					ON [Invocation].[InvocationId] = [Log].[InvocationId]
			WHERE
				[Project].[Name] = @Project
				AND [Script].[Name] = @Script
				AND [Invocation].[Host] = @Host
				AND [Invocation].[ScriptFilePath] = @ScriptFilePath
				AND [Log].[OpenLogTime] < @OlderThan
	DELETE
		FROM [Logging].[Entry]
		WHERE [LogId] IN (SELECT [LogId] FROM @Log)
	DELETE
		FROM [Logging].[Variable]
		WHERE [LogId] IN (SELECT [LogId] FROM @Log)
	DELETE
		FROM [Logging].[Timer]
		WHERE [LogId] IN (SELECT [LogId] FROM @Log)
	DELETE
		FROM [Logging].[Log]
		WHERE [LogId] IN (SELECT [LogId] FROM @Log)
END
