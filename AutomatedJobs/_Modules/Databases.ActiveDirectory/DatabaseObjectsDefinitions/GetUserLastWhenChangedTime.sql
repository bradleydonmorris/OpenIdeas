BEGIN
	SELECT ISNULL(MAX([User].[WhenChangedTime]), MAX([User].[WhenCreatedTime])) AS [WhenChangedTime]
		FROM [ActiveDirectory].[User]
END
