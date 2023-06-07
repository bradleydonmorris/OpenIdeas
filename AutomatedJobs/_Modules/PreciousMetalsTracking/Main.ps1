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
        [void] $Global:Job.PreciousMetalsTracking.Data.VerifyDatabase();
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
        $Global:Job.Sqlite.CreateIfNotFound(
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
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $VendorName
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Job.SQLite.GetRecords(
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
    -Name "ExistsMetalType" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Job.SQLite.GetTableRowCount(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            "MetalType",
            @{ "Name" = $Name}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "IsInUseMetalType" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int641] $Count = $Global:Job.SQLite.GetScalar(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "MetalType_IsInUse.sql")),
            @{ "Name" = $Name}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "GetAllMetalTypes" `
    -MemberType "ScriptMethod" `
    -Value {
        Return $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "MetalType_GetAll.sql")),
            $null,
            @( "Name" ),
            $null
        );
    }
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
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "MetalType_Add.sql")),
            @{ "Name" = $Name; }
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "RenameMetalType" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $OldName,

            [Parameter(Mandatory=$true)]
            [String] $NewName
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "MetalType_Rename.sql")),
            @{
                "OldName" = $OldName;
                "NewName" = $NewName;
            }
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "RemoveMetalType" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $Name
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "MetalType_Remove.sql")),
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
                    @{ "Selector" = "L"; "Name" = "Lookups"; "Text" = "Lookup Data"; },
                    @{ "Selector" = "V"; "Name" = "Vendors"; "Text" = "Vendors"; },
                    @{ "Selector" = "I"; "Name" = "Items"; "Text" = "Items"; },
                    @{ "Selector" = "T"; "Name" = "Transactions"; "Text" = "Transactions"; },
                    @{ "Selector" = "X"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
                )
            )
            Switch ($MenuResponse)
            {
                "Lookups"
                {
                    [void] $Global:Job.PreciousMetalsTracking.Menus.ShowLookupsMenu();
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
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
    -Name "ShowLookupsMenu" `
    -MemberType "ScriptMethod" `
    -Value {
        [Boolean] $ShowInvalidChoiceMessage = $false;
        [Boolean] $ExitMenu = $false
        While (!$ExitMenu)
        {
            Clear-Host;
            [String] $VendorMenuResponse = $Global:Job.Prompts.ShowMenu(0, $ShowInvalidChoiceMessage,
                @(
                    @{ "Selector" = "MT"; "Name" = "MetalTypes"; "Text" = "Metal Types"; },
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "MetalTypes"
                {
                    [void] $Global:Job.PreciousMetalsTracking.Menus.ShowMetalTypesMenu();
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
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Menus `
    -Name "ShowMetalTypesMenu" `
    -MemberType "ScriptMethod" `
    -Value {
        [Boolean] $ShowInvalidChoiceMessage = $false;
        [Boolean] $ExitMenu = $false
        While (!$ExitMenu)
        {
            Clear-Host;
            [String] $VendorMenuResponse = $Global:Job.Prompts.ShowMenu(0, $ShowInvalidChoiceMessage,
                @(
                    @{ "Selector" = "L"; "Name" = "List"; "Text" = "List Metal Types"; },
                    @{ "Selector" = "A"; "Name" = "Add"; "Text" = "Add Metal Type"; },
                    @{ "Selector" = "M"; "Name" = "Modify"; "Text" = "Modify Metal Type"; },
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove Metal Type"; }
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "List"
                {
                    Clear-Host;
                    $MetalTypes = $Global:Job.PreciousMetalsTracking.Data.GetAllMetalTypes();
                    If ($MetalTypes)
                    {
                        If ($MetalTypes.Count -gt 0)
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowMetalTypes($MetalTypes);
                        }
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound("Metal Types");
                        }
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound("Metal Types");
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    [String] $MetalTypeName = $Global:Job.Prompts.StringResponse("Enter Metal Type Name", "");
                    If (![String]::IsNullOrEmpty($MetalTypeName))
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Data.AddMetalType($MetalTypeName);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    [String] $OldMetalTypeName = $Global:Job.Prompts.StringResponse("Enter Current Metal Type Name", "");
                    [String] $NewMetalTypeName = $Global:Job.Prompts.StringResponse("Enter New Metal Type Name", "");
                    If (![String]::IsNullOrEmpty($OldMetalTypeName))
                    {
                        If ($Global:Job.PreciousMetalsTracking.Data.ExistsMetalType($OldMetalTypeName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.ExistsMetalType($NewMetalTypeName))
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowAlreadyExists([String]::Format("Metal Type `"{0}`"", $NewMetalTypeName));
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Data.RenameMetalType($OldMetalTypeName, $NewMetalTypeName);
                            }
                        }
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound([String]::Format("Metal Type `"{0}`"", $OldMetalTypeName));
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    [String] $MetalTypeName = $Global:Job.Prompts.StringResponse("Enter Metal Type Name", "");
                    If (![String]::IsNullOrEmpty($MetalTypeName))
                    {
                        If ($Global:Job.PreciousMetalsTracking.Data.IsInUseMetalType($MetalTypeName))
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowIsInUse([String]::Format("Metal Type `"{0}`"", $MetalTypeName));
                        }
                        Else
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Data.RemoveMetalType($MetalTypeName);
                        }
                    }
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
                    [Collections.Hashtable] $Vendor = $Global:Job.PreciousMetalsTracking.Data.GetVendorByName($VendorName);
                    If ($Vendor)
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowVendor($Vendor);
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound("Vendor");
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Vendor.Get");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Vendor.Modify");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Vendor.Remove");
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
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Menus `
    -Name "ShowItemsMenu" `
    -MemberType "ScriptMethod" `
    -Value {
        [Boolean] $ShowInvalidChoiceMessage = $false;
        [Boolean] $ExitMenu = $false
        While (!$ExitMenu)
        {
            Clear-Host;
            [String] $VendorMenuResponse = $Global:Job.Prompts.ShowMenu(0, $ShowInvalidChoiceMessage,
                @(
                    @{ "Selector" = "G"; "Name" = "Get"; "Text" = "Get Item"; },
                    @{ "Selector" = "A"; "Name" = "Add"; "Text" = "Add Item"; },
                    @{ "Selector" = "M"; "Name" = "Modify"; "Text" = "Modify Item"; },
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove Item"; }
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "Get"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Item.Get");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Item.Add");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Item.Modify");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Item.Remove");
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

#region Outputs
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
#endregion Outputs