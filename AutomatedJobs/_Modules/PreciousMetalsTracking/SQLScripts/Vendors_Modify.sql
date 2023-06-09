UPDATE `Vendor`
    SET
        `Name` = @Name,
        `WebSite` = @WebSite
    WHERE `VendorGUID` = @VendorGUID
