BEGIN TRANSACTION;
DELETE FROM `CorrelationReading`
    WHERE `CorrelationReading`.`CorrelationReadingId` IN
    (
        SELECT `CorrelationReading`.`CorrelationReadingId`
            FROM `CorrelationReading`
                INNER JOIN `Correlation`
                    ON `CorrelationReading`.`CorrelationId` = `Correlation`.`CorrelationId`
                INNER JOIN `Reading`
                    ON `CorrelationReading`.`ReadingId` = `Reading`.`ReadingId`
            WHERE
                `Correlation`.`CorrelationGUID` = @CorrelationGUID COLLATE NOCASE
                AND `Reading`.`ReadingGUID` = @ReadingGUID COLLATE NOCASE
    )
;
END TRANSACTION;
