INSERT INTO `Vendor`(`VendorGUID`, `Name`, `WebSite`)
SELECT
`Source`.`VendorGUID`,
`Source`.`Name`,
`Source`.`WebSite`
FROM
(
SELECT
`GUID` AS `VendorGUID`,
'APMEX' AS `Name`,
'https://www.apmex.com/' AS `WebSite`
FROM `GenerateGUID`
) AS `Source`
LEFT OUTER JOIN `Vendor` AS `Target`
ON `Source`.`Name` = `Target`.`Name`
WHERE `Target`.`VendorId` IS NULL