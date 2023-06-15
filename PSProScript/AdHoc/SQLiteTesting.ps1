. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "PreciousMetalsTracking"
);

$Global:Session.PreciousMetalsTracking.Open([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.sqlite3"));

# $Global:Session.PreciousMetalsTracking.VerifyDatabase();

# $Global:Session.PreciousMetalsTracking.GetVendorByName("APMEX");
# $Global:Session.PreciousMetalsTracking.GetVendorByGUID([Guid]::Parse("48011eee-6d05-450f-8480-8e7cce94fc1b"));

# $Vendor = $Global:Session.PreciousMetalsTracking.AddVendor("APMEXsadf", "asdfasdfasdfasdf");
# $Global:Session.PreciousMetalsTracking.GetVendorByGUID($Vendor.VendorGUID);
# $Global:Session.PreciousMetalsTracking.RemoveVendor($Vendor.VendorGUID);

# $Global:Session.PreciousMetalsTracking.AddMetalType("Copper");

# SELECT COUNT(*) FROM `MetalType` WHERE `Name` = @Param0

# $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName
# $Global:Session.Sqlite.GetScalar(
#     $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
#     [String]::Format("SELECT COUNT(*) FROM ``{0}``{1}",
#         "MetalType",
#         " WHERE `Name` = @Param0"
#     ),
#     @{ "Param0" = "Silver"}
# );
