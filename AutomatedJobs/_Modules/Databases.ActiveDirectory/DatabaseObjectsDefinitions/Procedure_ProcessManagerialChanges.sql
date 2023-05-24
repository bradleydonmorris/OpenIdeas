BEGIN
/*
	NO ACTION NEEDED
	Case A:
		If no manager in stage and no manager in hierarchy
			Then do nothing
	Case B:
		If manager in stage matches manager in hierarchy
			Then do nothing

	ACTION NEEDED
	Case C:
		If manager in stage and no manager in hierarchy
			Then insert new hierarchy record
	Case D:
		If no manager in stage and manager in hierarchy
			Then delete hierarchy record
	Case E:
		If manager in stage does not match manager in hierarchy
			Then update manager in hierarchy record
*/
	DECLARE @UserId [int]
	DECLARE @ManagerUserId [int]
	DECLARE @StagedManagerialHierarchyId [int]
	SELECT @StagedManagerialHierarchyId = [StagedManagerialHierarchy].[StagedManagerialHierarchyId]
		FROM [ActiveDirectory].[StagedManagerialHierarchy]
		WHERE [StagedManagerialHierarchy].[IsProcessed] = 0
		ORDER BY [StagedManagerialHierarchy].[InsertTimestamp]
	WHILE @StagedManagerialHierarchyId IS NOT NULL
		BEGIN
			SELECT
				@UserId = [User_Subordinate].[UserId],
				@ManagerUserId = [User_Manager].[UserId]
				FROM [ActiveDirectory].[StagedManagerialHierarchy]
					INNER JOIN [ActiveDirectory].[User] AS [User_Subordinate]
						ON [StagedManagerialHierarchy].[objectGuid] = [User_Subordinate].[objectGuid]
					LEFT OUTER JOIN [ActiveDirectory].[User] AS [User_Manager]
						ON [StagedManagerialHierarchy].[managerDistinguishedName] = [User_Manager].[DistinguishedName]
				WHERE [StagedManagerialHierarchy].[StagedManagerialHierarchyId] = @StagedManagerialHierarchyId
			--Case C: Insert
			IF
				@ManagerUserId IS NOT NULL
				AND NOT EXISTS
				(
					SELECT 1
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE [ManagerialHierarchy].[UserId] = @UserId
				)
					INSERT INTO [ActiveDirectory].[ManagerialHierarchy]([UserId], [ManagerUserId])
						VALUES(@UserId, @ManagerUserId)

			--Case D: Delete
			IF
				@ManagerUserId IS NULL
				AND EXISTS
				(
					SELECT 1
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE [ManagerialHierarchy].[UserId] = @UserId
				)
					DELETE
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE [ManagerialHierarchy].[UserId] = @UserId

			--Case E: Update
			IF
				@ManagerUserId IS NOT NULL
				AND EXISTS
				(
					SELECT 1
						FROM [ActiveDirectory].[ManagerialHierarchy]
						WHERE
							[ManagerialHierarchy].[UserId] = @UserId
							AND [ManagerialHierarchy].[ManagerUserId] != @ManagerUserId
				)
					UPDATE [ActiveDirectory].[ManagerialHierarchy]
						SET [ManagerUserId] = @ManagerUserId
						WHERE [UserId] = @UserId

			UPDATE [ActiveDirectory].[StagedManagerialHierarchy]
				SET [IsProcessed] = 1
				WHERE [StagedManagerialHierarchy].[StagedManagerialHierarchyId] = @StagedManagerialHierarchyId
			SET @StagedManagerialHierarchyId = NULL
			SELECT @StagedManagerialHierarchyId = [StagedManagerialHierarchy].[StagedManagerialHierarchyId]
				FROM [ActiveDirectory].[StagedManagerialHierarchy]
				WHERE [StagedManagerialHierarchy].[IsProcessed] = 0
				ORDER BY [StagedManagerialHierarchy].[InsertTimestamp]
		END
	TRUNCATE TABLE [ActiveDirectory].[StagedManagerialHierarchy]
END
