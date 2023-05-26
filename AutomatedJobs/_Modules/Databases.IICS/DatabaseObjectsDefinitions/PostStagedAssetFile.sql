BEGIN
	INSERT INTO [_SCHEMANAME_].[StagedAssetFile]([FederatedId], [FileName], [FileType], [Content])
		VALUES(@FederatedId, @FileName, @FileType, @Content)
END
