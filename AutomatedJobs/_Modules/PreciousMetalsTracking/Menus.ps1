Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Menus" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Menus `
    -TypeName "System.Boolean" `
    -NotePropertyName "ExitApplication" `
    -NotePropertyValue $false;
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
                    @{ "Selector" = "XX"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
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
                    [void] $Global:Job.PreciousMetalsTracking.Menus.ShowItemsMenu();
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Transactions"
                {
                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotImpletemented("Transactions");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "ExitApplication"
                {
                    $Global:Job.PreciousMetalsTracking.Menus.ExitApplication = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
            If ($Global:Job.PreciousMetalsTracking.Menus.ExitApplication -eq $true)
            {
                $Global:Job.PreciousMetalsTracking.Exit();
                $ShowInvalidChoiceMessage = $false;
                $ExitMenu = $true;
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
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; },
                    @{ "Selector" = "XX"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "MetalTypes"
                {
                    [void] $Global:Job.PreciousMetalsTracking.Menus.ShowLookupMenu("Metal Types", "Metal Type", "MetalType");
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "ExitMenu"
                {
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $true;
                }
                "ExitApplication"
                {
                    $Global:Job.PreciousMetalsTracking.Menus.ExitApplication = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
            If ($Global:Job.PreciousMetalsTracking.Menus.ExitApplication -eq $true)
            {
                $ShowInvalidChoiceMessage = $false;
                $ExitMenu = $true;
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
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove $LookupDisplayNameSingular"; },
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Lookups Menu"; },
                    @{ "Selector" = "XX"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
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
                            [void] $Global:Job.PreciousMetalsTracking.Messages.ShowLookupValues($LookupDisplayNamePlural, $LookupValues);
                        }
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound($LookupDisplayNamePlural);
                        }
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound($LookupDisplayNamePlural);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    [String] $LookupValue = $Global:Job.Prompts.StringResponse("Enter $LookupDisplayNameSingular Name", "");
                    If (![String]::IsNullOrEmpty($LookupValue))
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Data.Lookups.Add($LookupTableName, $LookupValue);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }   
                "Modify"
                {
                    [String] $OldLookupValue = $Global:Job.Prompts.StringResponse("Enter Current $LookupDisplayNameSingular Name", "");
                    [String] $NewLookupValue = $Global:Job.Prompts.StringResponse("Enter New $LookupDisplayNameSingular Name", "");
                    If (![String]::IsNullOrEmpty($OldLookupValue))
                    {
                        If ($Global:Job.PreciousMetalsTracking.Data.Lookups.Exists($LookupTableName, $OldLookupValue))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Lookups.Exists($LookupTableName, $NewLookupValue))
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowAlreadyExists([String]::Format("{0} `"{1}`"", $LookupDisplayNameSingular, $NewLookupValue));
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Data.Lookups.Rename($LookupTableName, $OldLookupValue, $NewLookupValue);
                            }
                        }
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound([String]::Format("{0} `"{1}`"", $LookupDisplayNameSingular, $OldLookupValue));
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    [String] $LookupValue = $Global:Job.Prompts.StringResponse("Enter $LookupDisplayNameSingular Name", "");
                    If (![String]::IsNullOrEmpty($LookupValue))
                    {
                        If ($Global:Job.PreciousMetalsTracking.Data.Lookups.IsInUse($LookupTableName, $LookupValue))
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Messages.ShowIsInUse([String]::Format("$LookupDisplayNameSingular `"{0}`"", $LookupValue));
                        }
                        Else
                        {
                            [void] $Global:Job.PreciousMetalsTracking.Data.Lookups.Remove($LookupTableName, $LookupValue);
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
                "ExitApplication"
                {
                    $Global:Job.PreciousMetalsTracking.Menus.ExitApplication = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
            If ($Global:Job.PreciousMetalsTracking.Menus.ExitApplication -eq $true)
            {
                $ShowInvalidChoiceMessage = $false;
                $ExitMenu = $true;
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
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove Vendor"; },
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; },
                    @{ "Selector" = "XX"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
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
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowVendor($Vendor);
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound("Vendor");
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
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowAlreadyExists([String]::Format("Vendor `"{0}`"", $VendorName));
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
                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowVendor($Vendor);
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

                    If ($Vendor)
                    {
                        [Boolean] $NewVendorNameExists = $true;
                        [String] $NewVendorName = $null;
                        While ($NewVendorNameExists)
                        {
                            $NewVendorName = $Global:Job.Prompts.StringResponse("Enter New Vendor Name", $Vendor.Name);
                            If (![String]::IsNullOrEmpty($NewVendorName))
                            {
                                If (
                                    $NewVendorName -ne $Vendor.Name -and
                                    $Global:Job.PreciousMetalsTracking.Data.Vendors.Exists($NewVendorName)
                                )
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowAlreadyExists([String]::Format("Vendor `"{0}`"", $NewVendorName));
                                    $NewVendorNameExists = $true;
                                }
                                Else
                                {
                                    $NewVendorNameExists = $false;
                                }
                            }
                            Else
                            {
                                $NewVendorNameExists = $true;
                            }
                        }
                        $Vendor.Name = $NewVendorName;
                        $Vendor.WebSite = $Global:Job.Prompts.StringResponse("New Vendor Web Site", $Vendor.WebSite);
                        [PSObject] $Vendor = $Global:Job.PreciousMetalsTracking.Data.Vendors.Modify($Vendor.VendorGUID, $Vendor.Name, $Vendor.WebSite);
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowVendor($Vendor);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
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
                                $VendorExists = $true;
                                If ($Global:Job.PreciousMetalsTracking.Data.Vendors.IsInUse($VendorName))
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowIsInUse($VendorName);
                                }
                                Else
                                {
                                    $Vendor = $Global:Job.PreciousMetalsTracking.Data.Vendors.GetByName($VendorName);
                                    [void] $Global:Job.PreciousMetalsTracking.Data.Vendors.Remove($Vendor.VendorGUID);
                                }
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound($VendorName);
                                $VendorExists = $false;
                            }
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
                "ExitApplication"
                {
                    $Global:Job.PreciousMetalsTracking.Menus.ExitApplication = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
            If ($Global:Job.PreciousMetalsTracking.Menus.ExitApplication -eq $true)
            {
                $ShowInvalidChoiceMessage = $false;
                $ExitMenu = $true;
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
                    @{ "Selector" = "R"; "Name" = "Remove"; "Text" = "Remove Item"; },
                    @{ "Selector" = "X"; "Name" = "ExitMenu"; "Text" = "Return to Main Menu"; },
                    @{ "Selector" = "XX"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
                )
            );
            Switch ($VendorMenuResponse)
            {
                "Get"
                {
                    Clear-Host;
                    [String] $ItemName = $Global:Job.Prompts.StringResponse("Enter Item Name", "");
                    [PSObject] $Item = $Global:Job.PreciousMetalsTracking.Data.Items.GetByName($ItemName);
                    If ($Item)
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowItem($Item);
                    }
                    Else
                    {
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound("Item");
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Add"
                {
                    Clear-Host;
                    [Boolean] $ItemExists = $true;
                    [String] $ItemName = $null;
                    While ($ItemExists)
                    {
                        $ItemName = $Global:Job.Prompts.StringResponse("Enter Item Name", "");
                        If (![String]::IsNullOrEmpty($ItemName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Items.Exists($ItemName))
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowAlreadyExists([String]::Format("Item `"{0}`"", $ItemName));
                                $ItemExists = $true;
                            }
                            Else
                            {
                                $ItemExists = $false;
                            }
                        }
                        Else
                        {
                            $ItemExists = $false;
                        }
                    }

                    [Boolean] $ItemMetalTypeExists = $false;
                    [String] $ItemMetalType = $null;
                    While (!$ItemMetalTypeExists)
                    {
                        $ItemMetalType = $Global:Job.Prompts.StringResponse("Enter Metal Type Name", "");
                        If (![String]::IsNullOrEmpty($ItemMetalType))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Lookups.Exists("MetalType", $ItemMetalType))
                            {
                                $ItemMetalTypeExists = $true;
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound([String]::Format("Metal Type `"{0}`"", $ItemMetalType));
                                $ItemMetalTypeExists = $false;
                            }
                        }
                        Else
                        {
                            $ItemMetalTypeExists = $false;
                        }
                    }

                    [Boolean] $PurityIsDouble = $false;
                    [String] $PurityText = $null;
                    [Double] $Purity = 0;
                    While (!$PurityIsDouble)
                    {
                        $PurityText = $Global:Job.Prompts.StringResponse("Enter Purity", "0.999");
                        If (![String]::IsNullOrEmpty($PurityText))
                        {
                            If ([Double]::TryParse($PurityText, [ref]$Purity))
                            {
                                $PurityIsDouble = $true;
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowMustBeDouble("Purity");
                                $PurityIsDouble = $false;
                            }
                        }
                        Else
                        {
                            $PurityIsDouble = $false;
                        }
                    }

                    [Boolean] $OuncesIsDouble = $false;
                    [String] $OuncesText = $null;
                    [Double] $Ounces = 0;
                    While (!$OuncesIsDouble)
                    {
                        $OuncesText = $Global:Job.Prompts.StringResponse("Enter Ounces", "");
                        If (![String]::IsNullOrEmpty($OuncesText))
                        {
                            If ([Double]::TryParse($OuncesText, [ref]$Ounces))
                            {
                                $OuncesIsDouble = $true;
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowMustBeDouble("Ounces");
                                $OuncesIsDouble = $false;
                            }
                        }
                        Else
                        {
                            $OuncesIsDouble = $false;
                        }
                    }
                    [PSObject] $Item = $Global:Job.PreciousMetalsTracking.Data.Items.Add($ItemName, $ItemMetalType, $Purity, $Ounces);
                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowItem($Item);
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Modify"
                {
                    Clear-Host;
                    [Boolean] $ItemExists = $false;
                    [String] $ItemName = $null;
                    [PSObject] $Item = $null;
                    While (!$ItemExists)
                    {
                        $ItemName = $Global:Job.Prompts.StringResponse("Enter Item Name", "");
                        If (![String]::IsNullOrEmpty($ItemName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Items.Exists($ItemName))
                            {
                                $Item = $Global:Job.PreciousMetalsTracking.Data.Items.GetByName($ItemName);
                                $ItemExists = $true;
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound([String]::Format("Item `"{0}`"", $ItemName));
                                $ItemExists = $false;
                            }
                        }
                    }

                    If ($Item)
                    {
                        [Boolean] $NewItemNameExists = $true;
                        [String] $NewItemName = $null;
                        While ($NewItemNameExists)
                        {
                            $NewItemName = $Global:Job.Prompts.StringResponse("Enter New Item Name", $Item.Name);
                            If (![String]::IsNullOrEmpty($NewItemName))
                            {
                                If (
                                    $NewItemName -ne $Item.Name -and
                                    $Global:Job.PreciousMetalsTracking.Data.Items.Exists($NewItemName)
                                )
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowAlreadyExists([String]::Format("Item `"{0}`"", $NewItemName));
                                    $NewItemNameExists = $true;
                                }
                                Else
                                {
                                    $NewItemNameExists = $false;
                                }
                            }
                            Else
                            {
                                $NewItemNameExists = $true;
                            }
                        }
                        $Item.Name = $NewItemName;

                        [Boolean] $ItemMetalTypeExists = $false;
                        [String] $ItemMetalType = $null;
                        While (!$ItemMetalTypeExists)
                        {
                            $ItemMetalType = $Global:Job.Prompts.StringResponse("Enter Metal Type Name", $Item.MetalType);
                            If (![String]::IsNullOrEmpty($ItemMetalType))
                            {
                                If ($Global:Job.PreciousMetalsTracking.Data.Lookups.Exists("MetalType", $ItemMetalType))
                                {
                                    $ItemMetalTypeExists = $true;
                                }
                                Else
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound([String]::Format("Metal Type `"{0}`"", $ItemMetalType));
                                    $ItemMetalTypeExists = $false;
                                }
                            }
                            Else
                            {
                                $ItemMetalTypeExists = $false;
                            }
                        }
                        $Item.MetalType = $ItemMetalType;

                        [Boolean] $PurityIsDouble = $false;
                        [String] $PurityText = $null;
                        [Double] $Purity = 0;
                        While (!$PurityIsDouble)
                        {
                            $PurityText = $Global:Job.Prompts.StringResponse("Enter Purity", $Item.Purity.ToString());
                            If (![String]::IsNullOrEmpty($PurityText))
                            {
                                If ([Double]::TryParse($PurityText, [ref]$Purity))
                                {
                                    $PurityIsDouble = $true;
                                }
                                Else
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowMustBeDouble("Purity");
                                    $PurityIsDouble = $false;
                                }
                            }
                            Else
                            {
                                $PurityIsDouble = $false;
                            }
                        }
                        $Item.Purity = $Purity;

                        [Boolean] $OuncesIsDouble = $false;
                        [String] $OuncesText = $null;
                        [Double] $Ounces = 0;
                        While (!$OuncesIsDouble)
                        {
                            $OuncesText = $Global:Job.Prompts.StringResponse("Enter Ounces", $Item.Ounces.ToString());
                            If (![String]::IsNullOrEmpty($OuncesText))
                            {
                                If ([Double]::TryParse($OuncesText, [ref]$Ounces))
                                {
                                    $OuncesIsDouble = $true;
                                }
                                Else
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowMustBeDouble("Ounces");
                                    $OuncesIsDouble = $false;
                                }
                            }
                            Else
                            {
                                $OuncesIsDouble = $false;
                            }
                        }
                        $Item.Ounces = $Ounces;
                        [PSObject] $Item = $Global:Job.PreciousMetalsTracking.Data.Items.Modify($Item.ItemGUID, $Item.Name, $Item.MetalType,  $Item.Purity,  $Item.Ounces);
                        [void] $Global:Job.PreciousMetalsTracking.Messages.ShowItem($Item);
                    }
                    $ShowInvalidChoiceMessage = $false;
                    $ExitMenu = $false;
                }
                "Remove"
                {
                    Clear-Host;
                    [Boolean] $ItemExists = $false;
                    [String] $ItemName = $null;
                    [PSObject] $Item = $null;
                    While (!$ItemExists)
                    {
                        $ItemName = $Global:Job.Prompts.StringResponse("Enter Item Name", "");
                        If (![String]::IsNullOrEmpty($ItemName))
                        {
                            If ($Global:Job.PreciousMetalsTracking.Data.Items.Exists($ItemName))
                            {
                                $ItemExists = $true;
                                If ($Global:Job.PreciousMetalsTracking.Data.Items.IsInUse($ItemName))
                                {
                                    [void] $Global:Job.PreciousMetalsTracking.Messages.ShowIsInUse($ItemName);
                                }
                                Else
                                {
                                    $Item = $Global:Job.PreciousMetalsTracking.Data.Items.GetByName($ItemName);
                                    [void] $Global:Job.PreciousMetalsTracking.Data.Items.Remove($Item.ItemGUID);
                                }
                            }
                            Else
                            {
                                [void] $Global:Job.PreciousMetalsTracking.Messages.ShowNotFound($ItemName);
                                $ItemExists = $false;
                            }
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
                "ExitApplication"
                {
                    $Global:Job.PreciousMetalsTracking.Menus.ExitApplication = $true;
                }
                Default
                {
                    $ShowInvalidChoiceMessage = $true;
                    $ExitMenu = $false;
                }
            }
            If ($Global:Job.PreciousMetalsTracking.Menus.ExitApplication -eq $true)
            {
                $ShowInvalidChoiceMessage = $false;
                $ExitMenu = $true;
            }
        }
    }
