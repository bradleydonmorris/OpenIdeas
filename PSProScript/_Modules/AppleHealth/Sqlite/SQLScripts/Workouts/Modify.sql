BEGIN TRANSACTION;
UPDATE `Workout`
    SET
    	`DataProviderId` = `DataProvider`.`DataProviderId`,
        `UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`,
        `TypeId` = `Type`.`TypeId`,
        `WorkoutGUID` = `Source`.`WorkoutGUID`,
        `Key` = `Source`.`Key`,
        `CreationDate` = `Source`.`CreationDate`,
        `StartDate` = `Source`.`StartDate`,
        `EndDate` = `Source`.`EndDate`,
        `Duration` = `Source`.`Duration`,
        `EntryDate` = `Source`.`EntryDate`,
        `EntryTime` = `Source`.`EntryTime`
    FROM
    (
        SELECT
            @WorkoutGUID AS `WorkoutGUID`,
            @DataProvider AS `DataProvider`,
            @UnitOfMeasure AS `UnitOfMeasure`,
            @Type AS `Type`,
            @WorkoutGUID AS `WorkoutGUID`,
            @Key AS `Key`,
            @CreationDate AS `CreationDate`,
            @StartDate AS `StartDate`,
            @EndDate AS `EndDate`,
            @Duration AS `Duration`,
            @EntryDate AS `EntryDate`,
            @EntryTime AS `EntryTime`
    ) AS `Source`
        INNER JOIN `DataProvider`
            ON `Source`.`DataProvider` = `DataProvider`.`Name` COLLATE NOCASE
        INNER JOIN `UnitOfMeasure`
            ON `Source`.`UnitOfMeasure` = `UnitOfMeasure`.`Name` COLLATE NOCASE
        INNER JOIN `Type`
            ON `Source`.`Type` = `Type`.`Name` COLLATE NOCASE
	WHERE `Workout`.`WorkoutGUID` = `Source`.`WorkoutGUID`
;
END TRANSACTION;
