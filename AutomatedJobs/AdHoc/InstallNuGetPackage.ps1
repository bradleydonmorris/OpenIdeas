. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts"
);

[String] $PackageName = "SSH.NET";
If (!$Global:Job.NuGet.IsPackageInstalled($PackageName))
{
    [void] $Global:Job.NuGet.InstallPackage($PackageName);
}
