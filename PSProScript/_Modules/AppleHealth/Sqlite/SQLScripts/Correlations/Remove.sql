BEGIN TRANSACTION;
DELETE FROM `Correlation`
    WHERE `Correlation`.`CorrelationGUID` = @CorrelationGUID COLLATE NOCASE
;
END TRANSACTION;
