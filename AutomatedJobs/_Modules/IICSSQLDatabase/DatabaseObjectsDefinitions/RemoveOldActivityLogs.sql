BEGIN
	IF @KeepLogsForDays > 0
		BEGIN
			DECLARE @OlderThan [datetime2](7) = DATEADD([DAY], (-1)*@KeepLogsForDays, SYSUTCDATETIME())
			DECLARE @IdsToDelete TABLE ([ActivityLogId] [bigint])
			INSERT INTO @IdsToDelete ([ActivityLogId])
				SELECT [ActivityLog].[ActivityLogId]
				  FROM [_SCHEMANAME_].[ActivityLog]
				  WHERE [ActivityLog].[StartTime] < @OlderThan
			DELETE
				FROM [_SCHEMANAME_].[ActivityLogAsset]
				WHERE [ActivityLogId] IN (SELECT [ActivityLogId] FROM @IdsToDelete)
			DELETE
				FROM [_SCHEMANAME_].[ActivityLogSchedule]
				WHERE [ActivityLogId] IN (SELECT [ActivityLogId] FROM @IdsToDelete)
			DELETE
				FROM [_SCHEMANAME_].[ActivityLog]
				WHERE [ActivityLogId] IN (SELECT [ActivityLogId] FROM @IdsToDelete)
		END
END
