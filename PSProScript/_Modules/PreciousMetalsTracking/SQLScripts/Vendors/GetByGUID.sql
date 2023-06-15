SELECT
    `Vendor`.`VendorGUID`,
    `Vendor`.`Name`,
    `Vendor`.`WebSite`
    FROM `Vendor`
    WHERE `Vendor`.`VendorGUID` = @VendorGUID COLLATE NOCASE