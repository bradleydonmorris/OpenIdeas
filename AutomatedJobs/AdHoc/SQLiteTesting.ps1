. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "Sqlite",
    "PreciousMetalsTracking"
);



$Global:Job.PreciousMetalsTracking.Open([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.sqlite3"));
# $Global:Job.PreciousMetalsTracking.VerifyDatabase();

# $Global:Job.PreciousMetalsTracking.GetVendorByName("APMEX");
# $Global:Job.PreciousMetalsTracking.GetVendorByGUID([Guid]::Parse("48011eee-6d05-450f-8480-8e7cce94fc1b"));

# $Vendor = $Global:Job.PreciousMetalsTracking.AddVendor("APMEXsadf", "asdfasdfasdfasdf");
# $Global:Job.PreciousMetalsTracking.GetVendorByGUID($Vendor.VendorGUID);
# $Global:Job.PreciousMetalsTracking.RemoveVendor($Vendor.VendorGUID);

# $Global:Job.PreciousMetalsTracking.AddMetalType("Copper");



#SELECT COUNT(*) FROM `MetalType` WHERE `Name` = @Param0

# $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName
# $Global:Job.Sqlite.GetScalar(
#     $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
#     [String]::Format("SELECT COUNT(*) FROM ``{0}``{1}",
#         "MetalType",
#         " WHERE `Name` = @Param0"
#     ),
#     @{ "Param0" = "Silver"}
# );
