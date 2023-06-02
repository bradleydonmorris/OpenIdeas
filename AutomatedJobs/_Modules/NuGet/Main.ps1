Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "NuGet" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
    Add-Member `
    -InputObject $Global:Job.NuGet `
    -TypeName "String" `
    -NotePropertyName "ExecPath" `
    -NotePropertyValue ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "nuget.exe"));
Add-Member `
    -InputObject $Global:Job.NuGet `
    -TypeName "String" `
    -NotePropertyName "PackagesDirectoryPath" `
    -NotePropertyValue ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath))), "_Packages"));
Add-Member `
    -InputObject $Global:Job.NuGet `
    -Name "InstallPackage" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName
        )
        Start-Process `
            -FilePath $Global:Job.NuGet.ExecPath `
            -ArgumentList @(
                "install",
                $PackageName,
                "-DependencyVersion Highest",
                [String]::Format("-OutputDirectory {0}", $Global:Job.NuGet.PackagesDirectoryPath)
            ) `
            -NoNewWindow;
    }
Add-Member `
    -InputObject $Global:Job.NuGet `
    -Name "IsPackageInstalled" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName
        )
        [Boolean] $ReturnValue = $false;
        [Object] $Package = $null;
        Try
        {
            $Package = Get-Package -Name $PackageName -Destination $Global:Job.NuGet.PackagesDirectoryPath -ErrorAction SilentlyContinue;
        }
        Finally { }
        If ($Package)
            { $ReturnValue = $true; }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.NuGet `
    -Name "AddAssembly" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $AssemblyRelativePath
        )
        [String] $AssemblyFilePath = [IO.Path]::Combine($Global:Job.NuGet.PackagesDirectoryPath, $AssemblyRelativePath);
        Add-Type -Path $AssemblyFilePath;
    }
If (![IO.File]::Exists($Global:Job.NuGet.ExecPath))
{
    $ProgressPreference = "SilentlyContinue";
    Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $Global:Job.NuGet.ExecPath
    $ProgressPreference = "Continue";
}
Set-Alias -Name "nuget" -Value $Global:Job.NuGet.ExecPath -Scope Global
