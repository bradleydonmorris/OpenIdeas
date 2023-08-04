BEGIN TRANSACTION;
INSERT INTO `Correlation`(`DataProviderId`, `TypeId`, `CorrelationGUID`, `Key`, `CreationDate`, `StartDate`, `EndDate`, `EntryDate`, `EntryTime`)
    SELECT
    	`DataProvider`.`DataProviderId`,
        `Type`.`TypeId`,
        `Source`.`CorrelationGUID`,
        `Source`.`Key`,
        `Source`.`CreationDate`,
        `Source`.`StartDate`,
        `Source`.`EndDate`,
        `Source`.`EntryDate`,
        `Source`.`EntryTime`
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
            LEFT OUTER JOIN `Correlation` AS `Target`
                ON `Source`.`Key` = `Target`.`Key` COLLATE NOCASE
        WHERE `Target`.`CorrelationId` IS NULL
;
END TRANSACTION;
