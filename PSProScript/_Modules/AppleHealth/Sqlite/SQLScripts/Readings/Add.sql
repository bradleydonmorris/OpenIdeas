BEGIN TRANSACTION;
INSERT INTO `Reading`(`DataProviderId`, `UnitOfMeasureId`, `TypeId`, `ReadingGUID`, `Key`, `CreationDate`, `StartDate`, `EndDate`, `Value`, `EntryDate`, `EntryTime`)
    SELECT
    	`DataProvider`.`DataProviderId`,
        `UnitOfMeasure`.`UnitOfMeasureId`,
        `Type`.`TypeId`,
        `Source`.`ReadingGUID`,
        `Source`.`Key`,
        `Source`.`CreationDate`,
        `Source`.`StartDate`,
        `Source`.`EndDate`,
        `Source`.`Value`,
        `Source`.`EntryDate`,
        `Source`.`EntryTime`
        FROM
        (
            SELECT
                @ReadingGUID AS `ReadingGUID`,
                @DataProvider AS `DataProvider`,
                @UnitOfMeasure AS `UnitOfMeasure`,
                @Type AS `Type`,
                @Key AS `Key`,
                @CreationDate AS `CreationDate`,
                @StartDate AS `StartDate`,
                @EndDate AS `EndDate`,
                @Value AS `Value`,
                @EntryDate AS `EntryDate`,
                @EntryTime AS `EntryTime`
        ) AS `Source`
        	INNER JOIN `DataProvider`
        		ON `Source`.`DataProvider` = `DataProvider`.`Name` COLLATE NOCASE
        	INNER JOIN `UnitOfMeasure`
        		ON `Source`.`UnitOfMeasure` = `UnitOfMeasure`.`Name` COLLATE NOCASE
        	INNER JOIN `Type`
        		ON `Source`.`Type` = `Type`.`Name` COLLATE NOCASE
            LEFT OUTER JOIN `Reading` AS `Target`
                ON `Source`.`Key` = `Target`.`Key` COLLATE NOCASE
        WHERE `Target`.`ReadingId` IS NULL
;
END TRANSACTION;
