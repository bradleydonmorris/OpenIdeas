BEGIN TRANSACTION;
INSERT INTO `Workout`(`DataProviderId`, `UnitOfMeasureId`, `TypeId`, `WorkoutGUID`, `Key`, `CreationDate`, `StartDate`, `EndDate`, `Duration`, `EntryDate`, `EntryTime`)
    SELECT
    	`DataProvider`.`DataProviderId`,
        `UnitOfMeasure`.`UnitOfMeasureId`,
        `Type`.`TypeId`,
        `Source`.`WorkoutGUID`,
        `Source`.`Key`,
        `Source`.`CreationDate`,
        `Source`.`StartDate`,
        `Source`.`EndDate`,
        `Source`.`Duration`,
        `Source`.`EntryDate`,
        `Source`.`EntryTime`
        FROM
        (
            SELECT
                @WorkoutGUID AS `WorkoutGUID`,
                @DataProvider AS `DataProvider`,
                @UnitOfMeasure AS `UnitOfMeasure`,
                @Type AS `Type`,
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
            LEFT OUTER JOIN `Workout` AS `Target`
                ON `Source`.`Key` = `Target`.`Key` COLLATE NOCASE
        WHERE `Target`.`WorkoutId` IS NULL
;
END TRANSACTION;
