Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "NuGet" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.NuGet `
    -TypeName "String" `
    -NotePropertyName "ExecutablePath" `
    -NotePropertyValue ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "nuget.exe"));
Add-Member `
    -InputObject $Global:Session.NuGet `
    -Name "AddAssembly" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $RelativePath
        )
        [String] $AssemblyFilePath = [IO.Path]::Combine($Global:Session.Directories.Packages, $RelativePath);
        [Object] $Assembly = [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object -FilterScript { $_.GetName().Name -eq $Name}
        If (-not $Assembly)
        {
            Add-Type -Path $AssemblyFilePath;
        }
    }
Add-Member `
    -InputObject $Global:Session.NuGet `
    -Name "InstallPackage" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName
        )
        Start-Process `
            -FilePath $Global:Session.NuGet.ExecutablePath `
            -ArgumentList @(
                "install",
                $PackageName,
                "-DependencyVersion Highest",
                [String]::Format("-OutputDirectory {0}", $Global:Session.Directories.Packages)
            ) `
            -NoNewWindow;
    }
Add-Member `
    -InputObject $Global:Session.NuGet `
    -Name "InstallPackageIfMissing" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName
        )
        If (!$Global:Session.NuGet.IsPackageInstalled($PackageName))
        {
            [void] $Global:Session.NuGet.InstallPackage($PackageName);
        }
    }
Add-Member `
    -InputObject $Global:Session.NuGet `
    -Name "InstallPackageVersion" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName,

            [Parameter(Mandatory=$true)]
            [String] $Version
        )
        Start-Process `
            -FilePath $Global:Session.NuGet.ExecutablePath `
            -ArgumentList @(
                "install",
                $PackageName,
                "-DependencyVersion Highest",
                [String]::Format("-Version {0}", $Version),
                [String]::Format("-OutputDirectory {0}", $Global:Session.Directories.Packages)
            ) `
            -NoNewWindow;
    }
Add-Member `
    -InputObject $Global:Session.NuGet `
    -Name "InstallPackageVersionIfMissing" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName,

            [Parameter(Mandatory=$true)]
            [String] $Version
        )
        If (!$Global:Session.NuGet.IsPackageVersionInstalled($PackageName, $Version))
        {
            [void] $Global:Session.NuGet.InstallPackageVersion($PackageName, $Version);
        }
    }
Add-Member `
    -InputObject $Global:Session.NuGet `
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
            $Package = Get-Package -Name $PackageName -Destination $Global:Session.Directories.Packages -ErrorAction SilentlyContinue;
        }
        Finally { }
        If ($Package)
            { $ReturnValue = $true; }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.NuGet `
    -Name "IsPackageVersionInstalled" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName,

            [Parameter(Mandatory=$true)]
            [String] $Version
        )
        [Boolean] $ReturnValue = $false;
        [Object] $Package = $null;
        Try
        {
            $Package = Get-Package -Name $PackageName -Destination $Global:Session.Directories.Packages -AllVersions -ErrorAction SilentlyContinue |
                Where-Object -FilterScript {$_.Version -eq $Version };
        }
        Finally { }
        If ($Package)
            { $ReturnValue = $true; }
        Return $ReturnValue;
    }
If (![IO.File]::Exists($Global:Session.NuGet.ExecutablePath))
{
    $ProgressPreference = "SilentlyContinue";
    Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $Global:Session.NuGet.ExecutablePath
    $ProgressPreference = "Continue";
}
Set-Alias -Name "nuget" -Value $Global:Session.NuGet.ExecutablePath -Scope Global
