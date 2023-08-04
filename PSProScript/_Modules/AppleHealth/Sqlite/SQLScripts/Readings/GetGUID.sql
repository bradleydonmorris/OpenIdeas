SELECT `Reading`.`ReadingGUID`
    FROM `Reading`
    WHERE `Reading`.`Key` = @Key COLLATE NOCASE
