If (![IO.Directory]::Exists($Global:Job.Directories.ConnectionsRoot))
{
    [void] [IO.Directory]::CreateDirectory($Global:Job.Directories.ConnectionsRoot);
}
Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Connections" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Connections `
    -TypeName "System.ollections.Hashtable" `
    -NotePropertyName "InMemory" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Job.Connections `
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
        If ($Name.EndsWith(".json"))
        {
            $Name = $Name.Substring(0, ($Name.Length - 5));
        }
        If ($Global:Job.Connections.InMemory.ContainsKey($Name))
        {
            $ReturnValue = $true;
        }
        ElseIf ([IO.File]::Exists([IO.Path]::Combine($Global:Job.Directories.ConnectionsRoot, [String]::Format("{0}.json", $Name))))
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.Connections `
    -Name "Get" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [PSCustomObject] $ReturnValue = $null;
        If ($Name.EndsWith(".json"))
        {
            $Name = $Name.Substring(0, ($Name.Length - 5));
        }
        If ($Global:Job.Connections.InMemory.ContainsKey($Name))
        {
            $ReturnValue = $Global:Job.Connections.InMemory[$Name];
        }
        Else
        {
            [String] $FilePath = [IO.Path]::Combine($Global:Job.Directories.ConnectionsRoot, [String]::Format("{0}.json", $Name));
            If ([IO.File]::Exists($FilePath))
            {
                $ReturnValue = Get-Content -Path $FilePath | ConvertFrom-Json;
                [void] $Global:Job.Connections.InMemory.Add($Name, $ReturnValue);
            }
        }
        If (-not $ReturnValue)
        {
            Throw [System.Exception]::new("Connection not found");
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.Connections `
    -Name "Set" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$true)]
            [PSCustomObject] $Connection,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted
        )
        If (-not $Connection.Comments)
        {
            Add-Member `
                -InputObject $Connection `
                -TypeName "String" `
                -NotePropertyName "Comments" `
                -NotePropertyValue $null;
        }
        If ([String]::IsNullOrEmpty($Connection.Comments))
        {
            $Connection.Comments = $null;
        }
        If ($Name.EndsWith(".json"))
        {
            $Name = $Name.Substring(0, ($Name.Length - 5));
        }
        If ($Global:Job.Connections.InMemory.ContainsKey($Name))
        {
            $Global:Job.Connections.InMemory[$Name] = $Connection;
        }
        Else
        {
            [void] $Global:Job.Connections.InMemory.Add($Name, $Connection);
        }
        If ($IsPersisted)
        {
            [String] $FilePath = [IO.Path]::Combine($Global:Job.Directories.ConnectionsRoot, [String]::Format("{0}.json", $Name));
            ConvertTo-Json -InputObject $Connection |
                Set-Content -Path $FilePath;
        }
    };
