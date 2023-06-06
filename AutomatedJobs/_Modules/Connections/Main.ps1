#This script creates methods to manage logs
# that are stored in the Logs directory
# which should be specified in the ".jobs-config.json".

#These Modules require Posh-SSH
# On newer Windows machines, SSH is built in.
If (-not (Get-Module -ListAvailable -Name "Posh-SSH"))
{
    Install-Module -Name Posh-SSH
} 
If (-not (Get-Module -Name "Posh-SSH"))
{
    Import-Module -Name "Posh-SSH"
} 

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
    -TypeName "System.Management.Automation.PSObject" `
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
        [Boolean] $Result = $false;
        If (!$Name.EndsWith(".json"))
        {
            $Name += ".json";
        }
        [String] $FilePath = [IO.Path]::Combine($Global:Job.Directories.ConnectionsRoot, $Name);
        $Result = [IO.File]::Exists($FilePath);
        Return $Result;
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

#### NEED TO DEPRECATE THINGS BELOW HERE
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetSQLServerConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([String])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         [String] $Result = $null;
#         $Values = $Global:Job.Connections.Get($Name);
#         If ($Values.AuthType -eq "UserNameAndPassword")
#         {
#             $Result = "Server=tcp:" + $Values.Instance + ";" +
#                 "Database=" + $Values.Database + ";" +
#                 "User ID=" + $Values.UserName + ";" +
#                 "Password=" + $Values.Password + ";";
#         }
#         If ($Values.AuthType -eq "Integrated")
#         {
#             $Result = "Server=tcp:" + $Values.Instance + ";" +
#                 "Database=" + $Values.Database + ";" +
#                 "Trusted_Connection=True;";
#         }
#         Return $Result;
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([PSCustomObject])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         [PSCustomObject] $Result = $null;
#         If (!$Name.EndsWith(".json"))
#         {
#             $Name += ".json";
#         }
#         [String] $FilePath = [IO.Path]::Combine($Global:Job.Directories.ConnectionsRoot, $Name);
#         If (![IO.File]::Exists($FilePath))
#         {
#             Throw [System.IO.FileNotFoundException]::new("Connection File not found", $FilePath);
#         }
#         Else
#         {
#             $Result = Get-Content -Path $FilePath | ConvertFrom-Json;
#         }
#         Return $Result;
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [PSCustomObject] $Connection
#         )
#         If (!$Name.EndsWith(".json"))
#         {
#             $Name += ".json";
#         }
#         If (-not $Connection.Comments)
#         {
#             Add-Member `
#                 -InputObject $Connection `
#                 -TypeName "String" `
#                 -NotePropertyName "Comments" `
#                 -NotePropertyValue $null;
#         }
#         If ([String]::IsNullOrEmpty($Connection.Comments))
#         {
#             $Connection.Comments = $null;
#         }
#         ConvertTo-Json -InputObject $Connection |
#             Set-Content -Path ([IO.Path]::Combine($Global:Job.Directories.ConnectionsRoot, $Name));
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetBasicCredential" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([System.Management.Automation.PSCredential])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         [System.Management.Automation.PSCredential] $Result = $null;
#         $Values = $Global:Job.Connections.Get($Name);
#         [System.Security.SecureString] $SecurePassword = ConvertTo-SecureString -String ($Values.Password) -AsPlainText -Force;
#         $Result = [System.Management.Automation.PSCredential]::new($Values.UserName, $SecurePassword);
#         Return $Result;
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetBasicCredential" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $UserName,
    
#             #VSCode will throw a warning on this parameter name.
#             #  So what? That's the name we want.
#             [Parameter(Mandatory=$true)]
#             [String] $Password,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         $Global:Job.Connections.Set(
#             $Name,
#             [PSCustomObject]@{
#                 "UserName" = $UserName
#                 "Password" = $Password
#                 "Comments" = $Comments
#             }
#         );
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetSMTPConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([System.Net.Mail.SmtpClient])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         [System.Net.Mail.SmtpClient] $Result = $null;
#         $Values = $Global:Job.Connections.Get($Name);
#         [System.Security.SecureString] $SecurePassword = ConvertTo-SecureString -String ($Values.Password) -AsPlainText -Force;
#         [System.Management.Automation.PSCredential] $Credential = [System.Management.Automation.PSCredential]::new($Values.UserName, $SecurePassword);
#         [System.Net.Mail.SmtpClient] $Result = [System.Net.Mail.SmtpClient]::new();
#         $Result.Credentials = $Credential;
#         $Result.EnableSsl = $Values.EnableSSL;
#         $Result.Host = $Values.HostName;
#         $Result.Port = $Values.Port;
#         Return $Result;
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetSMTPConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $HostName,
    
#             [Parameter(Mandatory=$true)]
#             [Int32] $Port,
    
#             [Parameter(Mandatory=$true)]
#             [Switch] $EnableSSL,
    
#             [Parameter(Mandatory=$true)]
#             [String] $UserName,
    
#             #VSCode will throw a warning on this parameter name.
#             #  So what? That's the name we want.
#             [Parameter(Mandatory=$true)]
#             [String] $Password,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         [Boolean] $SSL = $false;
#         If ($EnableSSL)
#         {
#             $SSL = $true;
#         }
#         $Global:Job.Connections.Set(
#             $Name,
#             [PSCustomObject]@{
#                 "HostName" = $HostName
#                 "Port" = $Port
#                 "EnableSSL" = $SSL
#                 "UserName" = $UserName
#                 "Password" = $Password
#                 "Comments" = $Comments
#             }
#         );
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetSFTPConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([SSH.SftpSession])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         [SSH.SftpSession] $Result = $null;
#         $Values = $Global:Job.Connections.Get($Name);
#         Get-SSHTrustedHost | Remove-SSHTrustedHost;
#         If ($Values.AuthType -eq "UserNameAndPassword")
#         {
#             [System.Security.SecureString] $SecurePassword = ConvertTo-SecureString -String ($Values.Password) -AsPlainText -Force;
#             [System.Management.Automation.PSCredential] $Credential = [System.Management.Automation.PSCredential]::new($Values.UserName, $SecurePassword);
#             $Result = New-SFTPSession -ComputerName $Values.HostName -Port $Values.Port -Credential $Credential -AcceptKey;
#         }
#         If ($Values.AuthType -eq "KeyFile")
#         {
#             If (![IO.File]::Exists($Values.KeyFile))
#             {
#                 Throw [System.IO.FileNotFoundException]::new("Key File not found", $Values.KeyFile);
#             }
#             $Result = New-SFTPSession -ComputerName $Values.HostName -Port $Values.Port -KeyFile $Values.KeyFile -AcceptKey;
#         }
# $Result.GetType();
#         Return $Result;
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetSFTPConnectionNormal" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $HostName,
    
#             [Parameter(Mandatory=$true)]
#             [Int32] $Port,
    
#             [Parameter(Mandatory=$true)]
#             [String] $UserName,
    
#             #VSCode will throw a warning on this parameter name.
#             #  So what? That's the name we want.
#             [Parameter(Mandatory=$false)]
#             [String] $Password,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         $Global:Job.Connections.Set(
#             $Name,
#             [PSCustomObject]@{
#                 "AuthType" = "UserNameAndPassword"
#                 "HostName" = $HostName
#                 "Port" = $Port
#                 "UserName" = $UserName
#                 "Password" = $Password
#                 "Comments" = $Comments
#             }
#         );
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetSFTPConnectionKeyFile" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $HostName,
    
#             [Parameter(Mandatory=$true)]
#             [Int32] $Port,
    
#             [Parameter(Mandatory=$true)]
#             [String] $KeyFile,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         If (![IO.File]::Exists($KeyFile))
#         {
#             Throw [System.IO.FileNotFoundException]::new("Key File not found", $KeyFile);
#         }
#         $Global:Job.Connections.Set(
#             $Name,
#             [PSCustomObject]@{
#                 "AuthType" = "KeyFile"
#                 "HostName" = $HostName
#                 "Port" = $Port
#                 "KeyFile" = $KeyFile
#                 "Comments" = $Comments
#             }
#         );
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetSQLServerConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $Instance,
    
#             [Parameter(Mandatory=$true)]
#             [String] $Database,
    
#             [Parameter(Mandatory=$false)]
#             [String] $UserName,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Password,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         [String] $AuthType = "Integrated";
#         If (![String]::IsNullOrEmpty($UserName))
#         {
#             $AuthType = "UserNameAndPassword";
#         }
#         If (![IO.File]::Exists($KeyFile))
#         {
#             Throw [System.IO.FileNotFoundException]::new("Key File not found", $KeyFile);
#         }
#         If ($AuthType -eq "Integrated")
#         {
#             $Global:Job.Connections.Set(
#                 $Name,
#                 [PSCustomObject]@{
#                     "AuthType" = $AuthType
#                     "Instance" = $Instance
#                     "Database" = $Database
#                     "Comments" = $Comments
#                 }
#             );
#         }
#         ElseIf ($AuthType -eq "UserNameAndPassword")
#         {
#             $Global:Job.Connections.Set(
#                 $Name,
#                 [PSCustomObject]@{
#                     "AuthType" = $AuthType
#                     "Instance" = $Instance
#                     "Database" = $Database
#                     "UserName" = $UserName
#                     "Password" = $Password
#                     "Comments" = $Comments
#                 }
#             );
#         }
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetThumbItAPIConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([PSCustomObject])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         Return $Global:Job.Connections.Get($Name);
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetThumbItAPIConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $URI,
    
#             [Parameter(Mandatory=$true)]
#             [String] $PartnerCode,
    
#             [Parameter(Mandatory=$false)]
#             [String] $APIKey,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         $Global:Job.Connections.Set(
#             $Name,
#             [PSCustomObject]@{
#                 "URI" = $URI
#                 "ParnterCode" = $ParnterCode
#                 "APIKey" = $APIKey
#                 "Comments" = $Comments
#             }
#         );
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "GetLDAPConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         [OutputType([String])]
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name
#         )
#         [String] $Result = $null;
#         $Values = $Global:Job.Connections.Get($Name);
#         $Result = $Values.RootLDIF;
#         Return $Result;
#     };
# Add-Member `
#     -InputObject $Global:Job.Connections `
#     -Name "SetLDAPConnection" `
#     -MemberType "ScriptMethod" `
#     -Value {
#         Param
#         (
#             [Parameter(Mandatory=$true)]
#             [String] $Name,
    
#             [Parameter(Mandatory=$true)]
#             [String] $RootLDIF,
    
#             [Parameter(Mandatory=$false)]
#             [String] $Comments
#         )
#         $Global:Job.Connections.Set(
#             $Name,
#             [PSCustomObject]@{
#                 "RootLDIF" = $RootLDIF
#                 "Comments" = $Comments
#             }
#         );
#     };



