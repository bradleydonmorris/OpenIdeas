INSERT INTO `Vendor`(`VendorGUID`, `Name`, `WebSite`)
    SELECT
        `Source`.`VendorGUID`,
        `Source`.`Name`,
        `Source`.`WebSite`
        FROM
        (
            SELECT
                @VendorGUID AS `VendorGUID`,
                @Name AS `Name`,
                @WebSite AS `WebSite`
        ) AS `Source`
            LEFT OUTER JOIN `Vendor` AS `Target`
                ON `Source`.`Name` = `Target`.`Name` COLLATE NOCASE
        WHERE `Target`.`VendorId` IS NULL