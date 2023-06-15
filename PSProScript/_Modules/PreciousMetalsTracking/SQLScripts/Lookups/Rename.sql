UPDATE `$(Lookup)`
    SET `Name` = @NewName
    WHERE `Name` = @OldName COLLATE NOCASE
