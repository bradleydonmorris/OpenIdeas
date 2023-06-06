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

# Clear-Host;
# [String] $MenuResponse = $Global:Job.Prompts.ShowMenu(0,
#     @(
#         @{ "Selector" = "V"; "Name" = "Vendors"; "Text" = "Vendors"; },
#         @{ "Selector" = "I"; "Name" = "Items"; "Text" = "Items"; },
#         @{ "Selector" = "T"; "Name" = "Transactions"; "Text" = "Transactions"; }
#     )
# )
# Switch ($MenuResponse)
# {
#     "Vendors"
#     {
#         [String] $VendorMenuResponse = $Global:Job.Prompts.ShowMenu(0,
#             @(
#                 @{ "Selector" = "G"; "Name" = "Get"; "Text" = "Get Vendor"; },
#                 @{ "Selector" = "A"; "Name" = "Add"; "Text" = "Add Vendor"; },
#                 @{ "Selector" = "M"; "Name" = "Modify"; "Text" = "Modify Vendor"; },
#                 @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove Vendor"; }
#             )
#         );
#         Switch ($VendorMenuResponse)
#         {
#             "Get"
#             {
#                 Clear-Host;
#                 [String] $VendorName = $Global:Job.Prompts.StringResponse("Enter Vendor Name", "");

#                 $Global:Job.PreciousMetalsTracking.GetVendorByName($VendorName);
#             }
#         }
#     }
#     "Items" {}
#     "Transactions" {}
#     Default {}
# }
