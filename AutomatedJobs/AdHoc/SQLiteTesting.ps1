. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "Sqlite",
    "PreciousMetalsTracking"
);
#[String] $DatabasePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.sqlite3");
#$Global:Job.PreciousMetalsTracking.VerifyDatabase($DatabasePath);
#$Global:Job.PreciousMetalsTracking.GetVendorByName($DatabasePath, "APMEX");

$Global:Job.SQLite.SetConnection(
    "PreciousMetalsTracking",
    [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.sqlite3"),
    "In memory only",
    $false
);

#$Global:Job.SQLite.GetConnection("PreciousMetalsTracking");

#$Global:Job.PreciousMetalsTracking.GetVendorByName("PreciousMetalsTracking", "APMEXw");
#$Global:Job.PreciousMetalsTracking.GetVendorByGUID("PreciousMetalsTracking", [Guid]::Parse("48011eee-6d05-450f-8480-8e7cce94fc1b"));
#$Global:Job.PreciousMetalsTracking.AddVendor("PreciousMetalsTracking", "APMEXw", "httpddddd");

$Global:Job.PreciousMetalsTracking.RemoveVendor("PreciousMetalsTracking",
[Guid]::Parse("cf5e888f-1e2f-4849-9f6a-5549d11f243a"));

#
#$Global:Job.Sqlite.ConvertParameter([DateTime]::MaxValue);
#$Global:Job.Sqlite.ConvertParameter([Guid]::NewGuid());
#[Guid]::Parse("6d94c03367b34d7aa1ba1c076ce30f9d")

