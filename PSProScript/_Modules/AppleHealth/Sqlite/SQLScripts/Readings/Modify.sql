BEGIN TRANSACTION;
UPDATE `Reading`
    SET
    	`DataProviderId` = `DataProvider`.`DataProviderId`,
        `UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`,
        `TypeId` = `Type`.`TypeId`,
        `ReadingGUID` = `Source`.`ReadingGUID`,
        `Key` = `Source`.`Key`,
        `CreationDate` = `Source`.`CreationDate`,
        `StartDate` = `Source`.`StartDate`,
        `EndDate` = `Source`.`EndDate`,
        `Value` = `Source`.`Value`,
        `EntryDate` = `Source`.`EntryDate`,
        `EntryTime` = `Source`.`EntryTime`
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
	WHERE `Reading`.`ReadingGUID` = `Source`.`ReadingGUID`
;
END TRANSACTION;
