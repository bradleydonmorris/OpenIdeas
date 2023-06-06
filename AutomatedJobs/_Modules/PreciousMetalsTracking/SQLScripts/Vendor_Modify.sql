UPDATE `Vendor`(`VendorGUID`, `Name`, `WebSite`)
    SET
        `Name` = @Name,
        `WebSite` = @WebSite
    WHERE `VendorGUID` = @VendorGUID
