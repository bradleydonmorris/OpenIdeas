. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "PreciousMetalsTracking"
);
[String] $DatabasePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.sqlite3");
$Global:Job.PreciousMetalsTracking.VerifyDatabase($DatabasePath);
$Global:Job.PreciousMetalsTracking.GetVendorByName($DatabasePath, "APMEX");
