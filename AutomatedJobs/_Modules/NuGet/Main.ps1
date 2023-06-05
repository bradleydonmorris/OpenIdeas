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
            -FilePath $Global:Job.NuGet.ExecPath `
            -ArgumentList @(
                "install",
                $PackageName,
                "-DependencyVersion Highest",
                [String]::Format("-Version {0}", $Version),
                [String]::Format("-OutputDirectory {0}", $Global:Job.Directories.Packages)
            ) `
            -NoNewWindow;
    }
Add-Member `
    -InputObject $Global:Job.NuGet `
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
            $Package = Get-Package -Name $PackageName -Destination $Global:Job.Directories.Packages -AllVersions -ErrorAction SilentlyContinue |
                Where-Object -FilterScript {$_.Version -eq $Version };
        }
        Finally { }
        If ($Package)
            { $ReturnValue = $true; }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.NuGet `
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
        If (!$Global:Job.NuGet.IsPackageVersionInstalled($PackageName, $Version))
        {
            [void] $Global:Job.NuGet.InstallPackageVersion($PackageName, $Version);
        }
    }
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
                [String]::Format("-OutputDirectory {0}", $Global:Job.Directories.Packages)
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
            $Package = Get-Package -Name $PackageName -Destination $Global:Job.Directories.Packages -ErrorAction SilentlyContinue;
        }
        Finally { }
        If ($Package)
            { $ReturnValue = $true; }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.NuGet `
    -Name "InstallPackageIfMissing" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PackageName
        )
        If (!$Global:Job.NuGet.IsPackageInstalled($PackageName))
        {
            [void] $Global:Job.NuGet.InstallPackage($PackageName);
        }
    }
Add-Member `
    -InputObject $Global:Job.NuGet `
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
        [String] $AssemblyFilePath = [IO.Path]::Combine($Global:Job.Directories.Packages, $RelativePath);
        [Object] $Assembly = [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object -FilterScript { $_.GetName().Name -eq $Name}
        If (-not $Assembly)
        {
            Add-Type -Path $AssemblyFilePath;
        }
    }
If (![IO.File]::Exists($Global:Job.NuGet.ExecPath))
{
    $ProgressPreference = "SilentlyContinue";
    Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $Global:Job.NuGet.ExecPath
    $ProgressPreference = "Continue";
}
Set-Alias -Name "nuget" -Value $Global:Job.NuGet.ExecPath -Scope Global
