SELECT `Correlation`.`CorrelationGUID`
    FROM `Correlation`
    WHERE `Correlation`.`Key` = @Key COLLATE NOCASE
