. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts"
);

[String] $PackageName = "SSH.NET";
If (!$Global:Session.NuGet.IsPackageInstalled($PackageName))
{
    [void] $Global:Session.NuGet.InstallPackage($PackageName);
}
