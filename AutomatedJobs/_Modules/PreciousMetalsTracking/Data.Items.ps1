Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Items" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "Exists" `
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
            "Item",
            @{ "Name" = $Name}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "IsInUse" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Job.SQLite.GetScalar(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Items", "IsInUse.sql")),
            @{ "Name" = $Name; }
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "GetByName" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ItemName
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Items", "GetByName.sql")),
            @{ "ItemName" = $ItemName },
            @( "ItemGUID", "Name", "MetalType", "Purity", "Ounces" ),
            @{ "ItemGUID" = "Guid"; "Purity" = "Double"; "Ounces" = "Double"; }
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $ItemGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Items", "GetByGUID.sql")),
            @{ "ItemGUID" = $ItemGUID},
            @( "ItemGUID", "Name", "MetalType", "Purity", "Ounces" ),
            @{ "ItemGUID" = "Guid"; "Purity" = "Double"; "Ounces" = "Double"; }
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $MetalType,

            [Parameter(Mandatory=$true)]
            [Double] $Purity,

            [Parameter(Mandatory=$true)]
            [Double] $Ounces
        )
        [PSObject] $ReturnValue = $Global:Job.PreciousMetalsTracking.Data.Items.GetByName($Name);
        If (-not $ReturnValue)
        {
            [Guid] $ItemGUID = [Guid]::NewGuid();
            $Global:Job.SQLite.Execute(
                $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
                [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Items", "Add.sql")),
                @{
                    "ItemGUID" = $ItemGUID;
                    "Name" = $Name;
                    "MetalType" = $MetalType;
                    "Purity" = $Purity;
                    "Ounces" = $Ounces;
                }
            );
            $ReturnValue = $Global:Job.PreciousMetalsTracking.Data.Items.GetByName($Name);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "Modify" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $ItemGUID,

            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $MetalType,

            [Parameter(Mandatory=$true)]
            [Double] $Purity,

            [Parameter(Mandatory=$true)]
            [Double] $Ounces
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Items", "Modify.sql")),
            @{
                "ItemGUID" = $ItemGUID;
                "Name" = $Name;
                "MetalType" = $MetalType;
                "Purity" = $Purity;
                "Ounces" = $Ounces;
        }
        );
        Return $Global:Job.PreciousMetalsTracking.Data.Items.GetByGUID($ItemGUID);
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Items `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $ItemGUID
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Items", "Remove.sql")),
            @{ "ItemGUID" = $ItemGUID; }
        );
    }
