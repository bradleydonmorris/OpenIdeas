
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Messages" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
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
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
    -Name "ShowItem" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [PSObject] $Item
        )
        Write-Host `
            -Object ([String]::Format(
                "ITEM`r`n`tGUID: {0}`r`n`tName: {1}`r`n`tMetal Type: {2}`r`n`tPurity: {3}`r`n`tOunces: {4}",
                $Item.ItemGUID,
                $Item.Name,
                $Item.MetalType,
                $Item.Purity,
                $Item.Ounces
            )) `
            -ForegroundColor Green;
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
    -Name "ShowLookupValues" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $LookupDisplayNamePlural,

            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[PSObject]] $LookupValues
        )
        Write-Host `
            -Object ($LookupDisplayNamePlural) `
            -ForegroundColor Green;
        ForEach ($LookupValue In $LookupValues)
        {
            Write-Host `
                -Object ([String]::Format("`t{0}", $LookupValue.Name)) `
                -ForegroundColor Green;
        }
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
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
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
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
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
    -Name "ShowIsInUse" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Prefix
        )
        Write-Host `
            -Object ([String]::Format(
                "{0} IS IN USE!",
                $Prefix.ToUpper()
            )) `
            -ForegroundColor Red;
        [void] $Global:Job.Prompts.PressEnter();
    }
    Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
    -Name "ShowMustBeDouble" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Prefix
        )
        Write-Host `
            -Object ([String]::Format(
                "{0} MUST BE DOUBLE (eg. 0.999)!",
                $Prefix.ToUpper()
            )) `
            -ForegroundColor Red;
        [void] $Global:Job.Prompts.PressEnter();
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
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
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Messages `
    -Name "ShowExit" `
    -MemberType "ScriptMethod" `
    -Value {
        Write-Host `
            -Object "Exited Application" `
            -ForegroundColor Red;
    }
