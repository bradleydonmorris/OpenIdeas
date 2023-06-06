[void] $Global:Job.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PreciousMetalsTracking" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "Open" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath
        )
        [void] $Global:Job.PreciousMetalsTracking.Data.SetActiveConnection($FilePath);
        [void] $Global:Job.PreciousMetalsTracking.Menus.ShowMainMenu();
    }


#region Data
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Data" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -TypeName "System.String" `
    -NotePropertyName "ActiveConnectionName" `
    -NotePropertyValue "";
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "SetActiveConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath
        )
        $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName = [String]::Format(
            "{0}_{1}_{2}",
            $Global:Job.Collection,
            $Global:Job.Script,
            [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")
        )
        [void] $Global:Job.SQLite.SetConnection(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            $FilePath,
            "In memory only",
            $false
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "VerifyDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "CreateSchema.sql")),
            $null
        );
    }


#region Vendor
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "GetVendorByName" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Hashtable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $VendorName
        )
        [Collections.ArrayList] $Records = $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_GetByName.sql")),
            @{ "VendorName" = $VendorName },
            @( "VendorGUID", "Name", "WebSite" ),
            @{ "VendorGUID" = "Guid" }
        );
        If ($Records.Count -eq 1)
        {
            Return $Records[0];
        }
        Else
        {
            Return $null;
        }
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "GetVendorByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Hashtable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        [Collections.ArrayList] $Records = $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_GetByGUID.sql")),
            @{ "VendorGUID" = $VendorGUID},
            @( "VendorGUID", "Name", "WebSite" ),
            @{ "VendorGUID" = "Guid" }
        );
        If ($Records.Count -eq 1)
        {
            Return $Records[0];
        }
        Else
        {
            Return $null;
        }
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "AddVendor" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Hashtable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $WebSite
        )
        [Collections.Hashtable] $ReturnValue = $Global:Job.PreciousMetalsTracking.Data.GetVendorByName($Name);
        If (-not $ReturnValue)
        {
            [Guid] $VendorGUID = [Guid]::NewGuid();
            $Global:Job.SQLite.Execute(
                $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
                [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_Add.sql")),
                @{
                    "VendorGUID" = $VendorGUID;
                    "Name" = $Name;
                    "WebSite" = $WebSite;
                }
            );
            $ReturnValue = $Global:Job.PreciousMetalsTracking.Data.GetVendorByName($Name);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "ModifyVendor" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Hashtable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID,

            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $WebSite
        )
        [Guid] $VendorGUID = [Guid]::NewGuid();
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_Modify.sql")),
            @{
                "VendorGUID" = $VendorGUID;
                "Name" = $Name;
                "WebSite" = $WebSite;
            }
        );
        Return $Global:Job.PreciousMetalsTracking.Data.GetVendorByGUID($VendorGUID);
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "RemoveVendor" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_Remove.sql")),
            @{ "VendorGUID" = $VendorGUID; }
        );
    }
#endregion Vendor

#region MetalType
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "AddMetalType" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "MetalType_Add.sql")),
            @{ "Name" = $Name; }
        );
    }
#endregion MetalType
#endregion Data

#region Menus
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Menus" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Menus `
    -Name "ShowMainMenu" `
    -MemberType "ScriptMethod" `
    -Value {
        [Boolean] $ShowInvalidChoiceMessage = $false;
        [Boolean] $ExitMenu = $false;
        While (!$ExitMenu)
        {
            Clear-Host;
            [String] $MenuResponse = $Global:Job.Prompts.ShowMenu(0, $ShowInvalidChoiceMessage,
                @(
                    @{ "Selector" = "V"; "Name" = "Vendors"; "Text" = "Vendors"; },
                    @{ "Selector" = "I"; "Name" = "Items"; "Text" = "Items"; },
                    @{ "Selector" = "T"; "Name" = "Transactions"; "Text" = "Transactions"; },
                    @{ "Selector" = "X"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
                )
            )
            Switch ($MenuResponse)
            {
                "Vendors"
                {
                    [void] $Global:Job.PreciousMetalsTracking.Menus.ShowVendorsMenu();
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Items"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Transactions"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "ExitApplication"
                {
                    #Close the application
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
        }
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Menus `
    -Name "ShowVendorsMenu" `
    -MemberType "ScriptMethod" `
    -Value {
        [Boolean] $ShowInvalidChoiceMessage = $false;
        [Boolean] $ExitMenu = $false
        While (!$ExitMenu)
        {
            Clear-Host;
            [String] $VendorMenuResponse = $Global:Job.Prompts.ShowMenu(0, $ShowInvalidChoiceMessage,
                @(
                    @{ "Selector" = "G"; "Name" = "Get"; "Text" = "Get Vendor"; },
                    @{ "Selector" = "A"; "Name" = "Add"; "Text" = "Add Vendor"; },
                    @{ "Selector" = "M"; "Name" = "Modify"; "Text" = "Modify Vendor"; },
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove Vendor"; }
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "Get"
                {
                    Clear-Host;
                    [String] $VendorName = $Global:Job.Prompts.StringResponse("Enter Vendor Name", "");
                    $Global:Job.PreciousMetalsTracking.GetVendorByName($VendorName);
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "ExitMenu"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
        }
    }
#endregion Menus