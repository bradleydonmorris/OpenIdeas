SELECT
    `Workout`.`WorkoutGUID`,
    `Workout`.`Key`,
    `DataProvider`.`Name` AS `DataProvider`,
    `UnitOfMeasure`.`Name` AS `UnitOfMeasure`,
    `Type`.`Name` AS `Type`,
    `Workout`.`CreationDate`,
    `Workout`.`StartDate`,
    `Workout`.`EndDate`,
    `Workout`.`Duration`,
    `Workout`.`EntryDate`,
    `Workout`.`EntryTime`
    FROM `Workout`
        INNER JOIN `DataProvider`
            ON `Workout`.`DataProviderId` = `DataProvider`.`DataProviderId` COLLATE NOCASE
        INNER JOIN `UnitOfMeasure`
            ON `Workout`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId` COLLATE NOCASE
        INNER JOIN `Type`
            ON `Workout`.`TypeId` = `Type`.`TypeId` COLLATE NOCASE
    WHERE `Workout`.`WorkoutGUID` = @WorkoutGUID COLLATE NOCASE
