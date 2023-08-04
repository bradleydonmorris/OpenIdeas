BEGIN TRANSACTION;
INSERT INTO `CorrelationReading`(`CorrelationId`, `ReadingId`)
    SELECT
        `Correlation`.`CorrelationId`,
        `Reading`.`ReadingId`
        FROM
        (
            SELECT
                @CorrelationGUID AS `CorrelationGUID`,
                @ReadingGUID AS `ReadingGUID`
        ) AS `Source`
        	INNER JOIN `Correlation`
        		ON `Source`.`CorrelationGUID` = `Correlation`.`CorrelationGUID` COLLATE NOCASE
        	INNER JOIN `Reading`
        		ON `Source`.`ReadingGUID` = `Reading`.`ReadingGUID` COLLATE NOCASE
            LEFT OUTER JOIN `CorrelationReading` AS `Target`
                ON
                    `Correlation`.`CorrelationId` = `Target`.`CorrelationId`
                    AND `Reading`.`ReadingId` = `Target`.`ReadingId`
        WHERE `Target`.`CorrelationReadingId` IS NULL
;
END TRANSACTION;
