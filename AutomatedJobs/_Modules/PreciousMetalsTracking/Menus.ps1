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
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Items");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Transactions"
                {
                    $Global:Job.PreciousMetalsTracking.Outputs.ShowNotImpletemented("Transactions");
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
                    [void] $Global:Job.PreciousMetalsTracking.Menus.ShowMetalTypesMenu("Metal Types", "Metal Type", "MetalType");
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
    -Name "ShowLookupMenu" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $LookupDisplayNamePlural,

            [Parameter(Mandatory=$true)]
            [String] $LookupDisplayNameSingular,

            [Parameter(Mandatory=$true)]
            [String] $LookupTableName
        )
        [Boolean] $ShowInvalidChoiceMessage = $false;
        [Boolean] $ExitMenu = $false
        While (!$ExitMenu)
        {
            Clear-Host;
            [String] $VendorMenuResponse = $Global:Job.Prompts.ShowMenu(0, $ShowInvalidChoiceMessage,
                @(
                    @{ "Selector" = "L"; "Name" = "List"; "Text" = "List $LookupDisplayNamePlural"; },
                    @{ "Selector" = "A"; "Name" = "Add"; "Text" = "Add $LookupDisplayNameSingular"; },
                    @{ "Selector" = "M"; "Name" = "Modify"; "Text" = "Modify $LookupDisplayNameSingular"; },
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove $LookupDisplayNameSingular"; }
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "List"
                {
                    Clear-Host;
                    $LookupValues = $Global:Job.PreciousMetalsTracking.Data.Lookups.GetAll($LookupTableName);
                    If ($LookupValues)
                    {
                        If ($LookupValues.Count -gt 0)
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowMetalTypes($LookupValues);
                        }
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound($LookupDisplayNamePlural);
                        }
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound($LookupDisplayNamePlural);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    [String] $LooName = $Global:Job.Prompts.StringResponse("Enter $LookupDisplayNameSingular Name", "");
                    If (![String]::IsNullOrEmpty($MetalTypeName))
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Data.Lookups.Add($LookupTableName, $MetalTypeName);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    [String] $OldMetalTypeName = $Global:Job.Prompts.StringResponse("Enter Current $LookupDisplayNameSingular Name", "");
                    [String] $NewMetalTypeName = $Global:Job.Prompts.StringResponse("Enter New $LookupDisplayNameSingular Name", "");
                    If (![String]::IsNullOrEmpty($OldMetalTypeName))
                    {
                        If ($Global:Job.PreciousMetalsTracking.Data.Lookups.Exists($LookupTableName, $OldMetalTypeName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Lookups.Exists($LookupTableName, $NewMetalTypeName))
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowAlreadyExists([String]::Format("$LookupDisplayNameSingular `"{0}`"", $NewMetalTypeName));
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Data.Lookups.Rename($LookupTableName, $OldMetalTypeName, $NewMetalTypeName);
                            }
                        }
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowNotFound([String]::Format("$LookupDisplayNameSingular `"{0}`"", $OldMetalTypeName));
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    [String] $MetalTypeName = $Global:Job.Prompts.StringResponse("Enter $LookupDisplayNameSingular Name", "");
                    If (![String]::IsNullOrEmpty($MetalTypeName))
                    {
                        If ($Global:Job.PreciousMetalsTracking.Data.Lookups.IsInUse($LookupTableName, $MetalTypeName))
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowIsInUse([String]::Format("$LookupDisplayNameSingular `"{0}`"", $MetalTypeName));
                        }
                        Else
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Data.Lookups.Remove($LookupTableName, $MetalTypeName);
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
                    [PSObject] $Vendor = $Global:Job.PreciousMetalsTracking.Data.Vendors.GetByName($VendorName);
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
                    Clear-Host;
                    [Boolean] $VendorExists = $true;
                    [String] $VendorName = $null;
                    While ($VendorExists)
                    {
                        $VendorName = $Global:Job.Prompts.StringResponse("Enter Vendor Name", "");
                        If (![String]::IsNullOrEmpty($VendorName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Vendors.Exists($VendorName))
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowAlreadyExists([String]::Format("Vendor `"{0}`"", $VendorName));
                                $VendorExists = $true;
                            }
                            Else
                            {
                                $VendorExists = $false;
                            }
                        }
                    }
                    [String] $VendorWebSite = $Global:Job.Prompts.StringResponse("Enter Vendor Web Site", "");
                    [PSObject] $Vendor = $Global:Job.PreciousMetalsTracking.Data.Vendors.Add($VendorName, $VendorWebSite);
                    [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowVendor($Vendor);
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    Clear-Host;
                    [Boolean] $VendorExists = $false;
                    [String] $VendorName = $null;
                    [PSObject] $Vendor = $null;
                    While (!$VendorExists)
                    {
                        $VendorName = $Global:Job.Prompts.StringResponse("Enter Vendor Name", "");
                        If (![String]::IsNullOrEmpty($VendorName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Vendors.Exists($VendorName))
                            {
                                $Vendor = $Global:Job.PreciousMetalsTracking.Data.Vendors.GetByName($VendorName);
                                $VendorExists = $true;
                            }
                            Else
                            {
                                $VendorExists = $false;
                            }
                        }
                    }
                    $Vendor.Name = $Global:Job.Prompts.StringResponse("New Vendor Name", $Vendor.Name);
                    $Vendor.WebSite = $Global:Job.Prompts.StringResponse("New Vendor Web Site", $Vendor.WebSite);
                    [PSObject] $Vendor = $Global:Job.PreciousMetalsTracking.Data.Vendors.Modify($Vendor.VendorGUID, $Vendor.Name, $Vendor.WebSite);
                    [void] $Global:Job.PreciousMetalsTracking.Outputs.ShowVendor($Vendor);
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
