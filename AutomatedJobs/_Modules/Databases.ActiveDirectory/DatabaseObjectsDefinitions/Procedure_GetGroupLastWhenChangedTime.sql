BEGIN
	SELECT ISNULL(MAX([Group].[WhenChangedTime]), MAX([Group].[WhenCreatedTime])) AS [WhenChangedTime]
		FROM [ActiveDirectory].[Group]
END
