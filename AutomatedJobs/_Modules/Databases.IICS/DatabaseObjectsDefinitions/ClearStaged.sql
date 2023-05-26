BEGIN
	IF (@ClearAssetFile = 1)
		TRUNCATE TABLE [_SCHEMANAME_].[StagedAssetFile]
	IF (@ClearAsset = 1)
		TRUNCATE TABLE [_SCHEMANAME_].[StagedAsset]
	IF (@ClearActivityLog = 1)
		TRUNCATE TABLE [_SCHEMANAME_].[StagedActivityLog]
END
