BEGIN TRANSACTION;
DELETE FROM `CorrelationReading`
    WHERE `CorrelationReading`.`CorrelationId` IN
    (
        SELECT `CorrelationId`
            FROM `Correlation`
            WHERE `Correlation`.`CorrelationGUID` = @CorrelationGUID COLLATE NOCASE
    )
;
END TRANSACTION;
