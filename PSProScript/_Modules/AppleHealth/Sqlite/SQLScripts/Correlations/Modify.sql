BEGIN TRANSACTION;
UPDATE `Correlation`
    SET
    	`DataProviderId` = `DataProvider`.`DataProviderId`,
        `TypeId` = `Type`.`TypeId`,
        `CorrelationGUID` = `Source`.`CorrelationGUID`,
        `Key` = `Source`.`Key`,
        `CreationDate` = `Source`.`CreationDate`,
        `StartDate` = `Source`.`StartDate`,
        `EndDate` = `Source`.`EndDate`,
        `EntryDate` = `Source`.`EntryDate`,
        `EntryTime` = `Source`.`EntryTime`
    FROM
    (
        SELECT
            @CorrelationGUID AS `CorrelationGUID`,
            @DataProvider AS `DataProvider`,
            @Type AS `Type`,
            @Key AS `Key`,
            @CreationDate AS `CreationDate`,
            @StartDate AS `StartDate`,
            @EndDate AS `EndDate`,
            @EntryDate AS `EntryDate`,
            @EntryTime AS `EntryTime`
    ) AS `Source`
        INNER JOIN `DataProvider`
            ON `Source`.`DataProvider` = `DataProvider`.`Name` COLLATE NOCASE
        INNER JOIN `Type`
            ON `Source`.`Type` = `Type`.`Name` COLLATE NOCASE
	WHERE `Correlation`.`CorrelationGUID` = `Source`.`CorrelationGUID`
;
END TRANSACTION;
