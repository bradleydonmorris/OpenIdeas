Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Outputs" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Outputs `
    -Name "ShowVendor" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [PSObject] $Vendor
        )
        Write-Host `
            -Object ([String]::Format(
                "VENDOR`r`n`tGUID: {0}`r`n`tName: {1}`r`n`tWeb Site: {2}",
                $Vendor.VendorGUID,
                $Vendor.Name,
                $Vendor.WebSite
            )) `
            -ForegroundColor Green;
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Outputs `
    -Name "ShowMetalTypes" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[PSObject]] $MetalTypes
        )
        Write-Host `
            -Object "METAL TYPES" `
            -ForegroundColor Green;
        ForEach ($MetalType In $MetalTypes)
        {
            Write-Host `
                -Object ([String]::Format("`t{0}", $MetalType.Name)) `
                -ForegroundColor Green;
        }
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Outputs `
    -Name "ShowNotFound" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Prefix
        )
        Write-Host `
            -Object ([String]::Format(
                "{0} NOT FOUND!",
                $Prefix.ToUpper()
            )) `
            -ForegroundColor Red;
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Outputs `
    -Name "ShowAlreadyExists" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Prefix
        )
        Write-Host `
            -Object ([String]::Format(
                "{0} ALREADY EXISTS!",
                $Prefix.ToUpper()
            )) `
            -ForegroundColor Red;
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Outputs `
    -Name "ShowNotImpletemented" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Prefix
        )
        Write-Host `
            -Object ([String]::Format(
                "{0} NOT IMPLEMENTED!",
                $Prefix.ToUpper()
            )) `
            -ForegroundColor Red;
        [void] $Global:Job.Prompts.PressEnter();
    }
