[String] $PackageName = "Microsoft.Data.Sqlite.Core";
[String] $PackagesPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "_Packages");
[String] $NugetDirectoryPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "_Modules", "NuGet");
[String] $NugetFilePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "_Modules", "NuGet", "nuget.exe");
If (![IO.Directory]::Exists($NugetDirectoryPath))
    { [void] [IO.Directory]::CreateDirectory($NugetDirectoryPath); }
If (![IO.File]::Exists)
{
    [String] $NuGetSoureURL = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    Invoke-WebRequest $NuGetSoureURL -OutFile $NugetFilePath
}
Set-Alias -Name "nuget" -Value $NugetFilePath -Scope Global
nuget install "System.Data.SQLite" -DependencyVersion Highest -OutputDirectory $PackagesPath;

<#
#Get-PackageSource
[Microsoft.PackageManagement.Packaging.SoftwareIdentity] $Package = $null;
Try
{
    $Package = Get-Package -Name $PackageName -Destination $PackagesPath -ErrorAction SilentlyContinue;
}
Finally { }
If (-not $Package)
{
    Try
    {
        Install-Package -Name $PackageName -ProviderName NuGet -Scope CurrentUser -SkipDependencies -Destination $PackagesPath -Force -ErrorAction SilentlyContinue;
        $Package = Get-Package -Name $PackageName -Destination $PackagesPath -ErrorAction SilentlyContinue;
    }
    Finally { }
}
If ($Package)
    { Write-Host "Package Installed" -ForegroundColor Green }
Else
    { Write-Host "Package Not Installed" -ForegroundColor Red }

#$pbipath = Resolve-Path ".\Microsoft.PowerBI.Api.3.18.1\lib\netstandard2.0\Microsoft.PowerBI.Api.dll"
#[System.Reflection.Assembly]::LoadFrom($pbipath)
Get-Package -Name "System.Data.SQLite" -Destination $PackagesPath;
#>