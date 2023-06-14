[void] $Global:Job.LoadModule("Connections");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "ActiveDirectory" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
#region Connection Methods
Add-Member `
    -InputObject $Global:Job.SQLServer `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$true)]
            [String] $RootLDIF,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted
        )
        $Global:Job.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "RootLDIF" = $RootLDIF;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Job.SQLServer `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        $Values = $Global:Job.Connections.Get($Name);
        Return $Global:Job.SQLServer.GetConnectionString(
            $Values.Instance,
            $Values.Database,
            $Values.IntegratedSecurity, #if true then UserName and Password are ignored
            $Values.UserName,
            $Values.Password,
            [System.Net.Dns]::GetHostName(),
            [String]::Format("{0}/{1}",
                    $Global:Job.Project,
                    $Global:Job.Script
                )
        );
    };
Add-Member `
    -InputObject $Global:Job.SQLServer `
    -Name "GetConnectionString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [Boolean] $IntegratedSecurity,
    
            [Parameter(Mandatory=$true)]
            [String] $UserName,
    
            [Parameter(Mandatory=$true)]
            [String] $Password,
    
            [Parameter(Mandatory=$true)]
            [String] $WorkstationName,
    
            [Parameter(Mandatory=$true)]
            [String] $ApplicationName
        )
        $WorkstationName = (
            ![String]::IsNullOrEmpty($WorkstationName) ?
                $WorkstationName :
                [System.Net.Dns]::GetHostName()
        );
        $ApplicationName = (
            ![String]::IsNullOrEmpty($ApplicationName) ?
                $ApplicationName :
                [String]::Format("{0}/{1}",
                    $Global:Job.Project,
                    $Global:Job.Script
                )
        );
        [String] $Authentication = (
            $IntegratedSecurity ?
                "Trusted_Connection=True" :
                [String]::Format("User ID={0};Password={1}",
                    $UserName,
                    $Password
                )
        );
        Return [String]::Format(
            "Server={0};Database={1};{2};Workstation ID={3};Application Name={4};",
            $Instance,
            $Database,
            $Authentication,
            $WorkstationName,
            $ApplicationName
        );
    };
#endregion Connection Methods



Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Doc" `
    -NotePropertyValue (ConvertFrom-Json -InputObject ([IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Doc.json"))));
Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetLDAPConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [String] $ReturnValue = $null;
        $Values = $Global:Job.Connections.Get($Name);
        $ReturnValue = $Values.RootLDIF;
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetChangedUsers" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[String]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [DateTime] $ChangedSince
        )
        [Collections.Generic.List[String]] $ReturnValue = [Collections.Generic.List[String]]::new();
        [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($Global:Job.ActiveDirectory.GetLDAPConnection($ConnectionName));
        [String] $Filter = "(&(objectCategory=user)(whenChanged>={@WhenChanged}))".Replace("{@WhenChanged}", $ChangedSince.ToString("yyyyMMddHHmmss.fffffffZ"));
        [System.String[]] $PropertiesToLoad = @("distinguishedName");
        [System.DirectoryServices.DirectorySearcher] $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new($RootDirectoryEntry, $Filter, $PropertiesToLoad, [System.DirectoryServices.SearchScope]::Subtree);
        $DirectorySearcher.PageSize = 100;
        [System.DirectoryServices.SearchResultCollection] $SearchResultCollection = $DirectorySearcher.FindAll();
        ForEach ($SearchResult In $SearchResultCollection)
        {
            [void] $ReturnValue.Add($SearchResult.Properties["distinguishedName"][0]);
        }
        [void] $SearchResultCollection.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetUser" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $DistinguishedName
        )
        [PSCustomObject] $ReturnValue = ConvertFrom-Json -InputObject @"
        {
            "objectGuid": null, "objectSid": null, "objectClass": null, "objectCategory": null,
            "userPrincipalName": null, "distinguishedName": null, "cn": null, "sAMAccountName": null, "displayName": null, "name": null, "parentDistinguishedName": null,
            "givenName": null, "middleName": null, "sn": null, "initials": null,
            "title": null, "department": null, "company": null, "manager": null,
            "description": null, "employeeNumber": null,
            "employeeID": null, "extensionAttribute1": null, "extensionAttribute2": null, "extensionAttribute3": null,
            "mail": null, "telephoneNumber": null, "mobile": null, "pager": null, "facsimileTelephoneNumber": null, "ipPhone": null, "homePhone": null, "msExchMailboxGuid": null, "url": null, "wWWHomePage": null,
            "otherFacsimileTelephoneNumber": null, "otherHomePhone": null, "otherIpPhone": null, "otherMobile": null, "otherPager": null, "otherTelephone": null,
            "physicalDeliveryOfficeName": null, "postalCode": null, "streetAddress": null, "postOfficeBox": null, "l": null, "st": null, "c": null, "countryCode": null, "co": null,
            "lastLogoff": null, "lastLogon": null, "lastLogonTimestamp": null, "pwdLastSet": null, "accountExpires": null,
            "homeDrive": null, "homeDirectory": null, "profilePath": null, "scriptPath": null, "userWorkstations": null, "logonHours": null, "info": null, "userAccountControl": null,
            "uSNCreated": null, "uSNChanged": null, "whenCreated": null, "whenChanged": null
        }
"@;
        [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($Global:Job.ActiveDirectory.GetLDAPConnection($ConnectionName));
        [String] $Filter = "(&(distinguishedName={@DistinguishedName}))".Replace("{@DistinguishedName}", $DistinguishedName);
        [System.String[]] $PropertiesToLoad = @(
            "objectGuid", "objectSid", "objectClass", "objectCategory",
            "userPrincipalName", "distinguishedName", "cn", "sAMAccountName", "displayName", "name",
            "givenName", "middleName", "sn", "initials",
            "title", "department", "company", "manager",
            "description", "employeeNumber",
            "employeeID", "extensionAttribute1", "extensionAttribute2", "extensionAttribute3",
            "mail", "telephoneNumber", "mobile", "pager", "facsimileTelephoneNumber", "ipPhone", "homePhone", "msExchMailboxGuid", "url", "wWWHomePage",
            "otherFacsimileTelephoneNumber", "otherHomePhone", "otherIpPhone", "otherMobile", "otherPager", "otherTelephone",
            "physicalDeliveryOfficeName", "postalCode", "streetAddress", "postOfficeBox", "l", "st", "c", "countryCode", "co",
            "lastLogoff", "lastLogon", "lastLogonTimestamp", "pwdLastSet", "accountExpires",
            "homeDrive", "homeDirectory", "profilePath", "scriptPath", "userWorkstations", "logonHours", "info", "userAccountControl",
            "uSNCreated", "uSNChanged", "whenCreated", "whenChanged"
        );
        [System.DirectoryServices.DirectorySearcher] $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new($RootDirectoryEntry, $Filter, $PropertiesToLoad, [System.DirectoryServices.SearchScope]::Subtree);
        $DirectorySearcher.PageSize = 100;
        [System.DirectoryServices.SearchResultCollection] $SearchResultCollection = $DirectorySearcher.FindAll();
        ForEach ($SearchResult In $SearchResultCollection)
        {
            [System.DirectoryServices.DirectoryEntry] $DirectoryEntry = $SearchResult.GetDirectoryEntry();
            If ($DirectoryEntry.objectSid)
            {
                If ($DirectoryEntry.objectSid.Value)
                {
                    If ($DirectoryEntry.objectSid.Value -is [Byte[]])
                    {
                        [Byte[]] $ObjectSIDBytes = $DirectoryEntry.objectSid.Value;
                        [System.Security.Principal.SecurityIdentifier] $ObjectSecurityIdentifier = [System.Security.Principal.SecurityIdentifier]::new($ObjectSIDBytes, 0);
                        $ReturnValue.objectSid = $ObjectSecurityIdentifier.ToString();
                    }
                }
            }
            If ($DirectoryEntry.Parent)
            {
                [System.DirectoryServices.DirectoryEntry] $ParentDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($DirectoryEntry.Parent);
                $ReturnValue.parentDistinguishedName = $ParentDirectoryEntry.distinguishedName[0];
            }
            If ($DirectoryEntry.Properties.Contains("manager"))
            {
                If ($DirectoryEntry.Properties["manager"].Value)
                {
                    $ReturnValue.manager = $DirectoryEntry.Properties["manager"].Value;
                }
            }
            If ($DirectoryEntry.msExchMailboxGuid)
            {
                If ($DirectoryEntry.msExchMailboxGuid.Value)
                {
                    If ($DirectoryEntry.msExchMailboxGuid.Value -is [Byte[]])
                    {
                        $ReturnValue.msExchMailboxGuid = [Guid]::new($DirectoryEntry.msExchMailboxGuid.Value).ToString();
                    }
                }
            }
        
            $ReturnValue.objectGuid = [Guid]::new($DirectoryEntry.objectGuid.Value).ToString();
            $ReturnValue.objectClass = [Collections.ArrayList]::new();
            $ReturnValue.objectClass.AddRange($DirectoryEntry.objectClass);
            $ReturnValue.objectCategory = $DirectoryEntry.objectCategory[0];
            $ReturnValue.UserPrincipalName = $DirectoryEntry.UserPrincipalName[0];
            $ReturnValue.distinguishedName = $DirectoryEntry.distinguishedName[0];
            $ReturnValue.cn = $DirectoryEntry.cn[0];
            $ReturnValue.sAMAccountName = $DirectoryEntry.sAMAccountName[0];
            $ReturnValue.displayName = $DirectoryEntry.displayName[0];
            $ReturnValue.name = $DirectoryEntry.name[0];
            $ReturnValue.givenName = $DirectoryEntry.givenName[0];
            $ReturnValue.middleName = $DirectoryEntry.middleName[0];
            $ReturnValue.sn = $DirectoryEntry.sn[0];
            $ReturnValue.initials = $DirectoryEntry.initials[0];
            $ReturnValue.title = $DirectoryEntry.title[0];
            $ReturnValue.department = $DirectoryEntry.department[0];
            $ReturnValue.company = $DirectoryEntry.company[0];
            $ReturnValue.description = $DirectoryEntry.description[0];
            $ReturnValue.employeeNumber = $DirectoryEntry.employeeNumber[0];
            $ReturnValue.employeeID = $DirectoryEntry.employeeID[0];
            $ReturnValue.extensionAttribute1 = $DirectoryEntry.extensionAttribute1[0];
            $ReturnValue.extensionAttribute2 = $DirectoryEntry.extensionAttribute2[0];
            $ReturnValue.extensionAttribute3 = $DirectoryEntry.extensionAttribute3[0];
            $ReturnValue.mail = $DirectoryEntry.mail[0];
            $ReturnValue.telephoneNumber = $DirectoryEntry.telephoneNumber[0];
            $ReturnValue.mobile = $DirectoryEntry.mobile[0];
            $ReturnValue.pager = $DirectoryEntry.pager[0];
            $ReturnValue.facsimileTelephoneNumber = $DirectoryEntry.facsimileTelephoneNumber[0];
            $ReturnValue.ipPhone = $DirectoryEntry.ipPhone[0];
            $ReturnValue.homePhone = $DirectoryEntry.homePhone[0];
            $ReturnValue.url = $DirectoryEntry.url[0];
            $ReturnValue.wWWHomePage = $DirectoryEntry.wWWHomePage[0];
            $ReturnValue.otherFacsimileTelephoneNumber = $DirectoryEntry.otherFacsimileTelephoneNumber[0];
            $ReturnValue.otherHomePhone = $DirectoryEntry.otherHomePhone[0];
            $ReturnValue.otherIpPhone = $DirectoryEntry.otherIpPhone[0];
            $ReturnValue.otherMobile = $DirectoryEntry.otherMobile[0];
            $ReturnValue.otherPager = $DirectoryEntry.otherPager[0];
            $ReturnValue.otherTelephone = $DirectoryEntry.otherTelephone[0];
            $ReturnValue.physicalDeliveryOfficeName = $DirectoryEntry.physicalDeliveryOfficeName[0];
            $ReturnValue.postalCode = $DirectoryEntry.postalCode[0];
            $ReturnValue.streetAddress = $DirectoryEntry.streetAddress[0];
            $ReturnValue.postOfficeBox = $DirectoryEntry.postOfficeBox[0];
            $ReturnValue.l = $DirectoryEntry.l[0];
            $ReturnValue.st = $DirectoryEntry.st[0];
            $ReturnValue.c = $DirectoryEntry.c[0];
            $ReturnValue.countryCode = $DirectoryEntry.countryCode[0];
            $ReturnValue.co = $DirectoryEntry.co[0];
            [Int64] $lastLogonInt64 = $SearchResult.Properties["lastLogon"][0];
            If ($lastLogonInt64 -eq 0 -or $lastLogonInt64 -gt [DateTime]::MaxValue.Ticks)
                { $ReturnValue.lastLogon = $null; }
            Else
                { $ReturnValue.lastLogon = [DateTime]::FromFileTimeUtc($lastLogonInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            [Int64] $lastLogoffInt64 = $SearchResult.Properties["lastLogoff"][0];
            If ($lastLogoffInt64 -eq 0 -or $lastLogoffInt64 -gt [DateTime]::MaxValue.Ticks)
                { $ReturnValue.lastLogoff = $null; }
            Else
                { $ReturnValue.lastLogoff = [DateTime]::FromFileTimeUtc($lastLogoffInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
            
            [Int64] $lastLogonTimestampInt64 = $SearchResult.Properties["lastLogonTimestamp"][0];
            If ($lastLogonTimestampInt64 -eq 0 -or $lastLogonTimestampInt64 -gt [DateTime]::MaxValue.Ticks)
                { $ReturnValue.lastLogonTimestamp = $null; }
            Else
                { $ReturnValue.lastLogonTimestamp = [DateTime]::FromFileTimeUtc($lastLogonTimestampInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            [Int64] $pwdLastSetInt64 = $SearchResult.Properties["pwdLastSet"][0];
            If ($pwdLastSetInt64 -eq 0 -or $pwdLastSetInt64 -gt [DateTime]::MaxValue.Ticks)
                { $ReturnValue.pwdLastSet = $null; }
            Else
                { $ReturnValue.pwdLastSet = [DateTime]::FromFileTimeUtc($pwdLastSetInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            [Int64] $accountExpiresInt64 = $SearchResult.Properties["accountExpires"][0];
            If ($accountExpiresInt64 -eq 0 -or $accountExpiresInt64 -gt [DateTime]::MaxValue.Ticks)
                { $ReturnValue.accountExpires = $null; }
            Else
                { $ReturnValue.accountExpires = [DateTime]::FromFileTimeUtc($accountExpiresInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            $ReturnValue.homeDrive = $DirectoryEntry.homeDrive[0];
            $ReturnValue.homeDirectory = $DirectoryEntry.homeDirectory[0];
            $ReturnValue.profilePath = $DirectoryEntry.profilePath[0];
            $ReturnValue.scriptPath = $DirectoryEntry.scriptPath[0];
            $ReturnValue.info = $DirectoryEntry.info[0];
            $ReturnValue.userAccountControl = $DirectoryEntry.userAccountControl[0];
        
            [Int64] $uSNCreatedInt64 = $SearchResult.Properties["uSNCreated"][0];
            $ReturnValue.uSNCreated = $uSNCreatedInt64;
            [Int64] $uSNChangedInt64 = $SearchResult.Properties["uSNChanged"][0];
            $ReturnValue.uSNChanged = $uSNChangedInt64;
            $ReturnValue.whenCreated = $DirectoryEntry.whenCreated[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
            $ReturnValue.whenChanged = $DirectoryEntry.whenChanged[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
            [void] $DirectoryEntry.Dispose();
        }
        [void] $SearchResultCollection.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetChangedGroups" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[String]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [DateTime] $ChangedSince
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($Global:Job.ActiveDirectory.GetLDAPConnection($ConnectionName));
        [String] $Filter = "(&(objectCategory=group)(whenChanged>={@WhenChanged}))".Replace("{@WhenChanged}", $ChangedSince.ToString("yyyyMMddHHmmss.fffffffZ"));
        [System.String[]] $PropertiesToLoad = @("distinguishedName");
        [System.DirectoryServices.DirectorySearcher] $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new($RootDirectoryEntry, $Filter, $PropertiesToLoad, [System.DirectoryServices.SearchScope]::Subtree);
        $DirectorySearcher.PageSize = 100;
        [System.DirectoryServices.SearchResultCollection] $SearchResultCollection = $DirectorySearcher.FindAll();
        ForEach ($SearchResult In $SearchResultCollection)
        {
            [void] $ReturnValue.Add($SearchResult.Properties["distinguishedName"][0]);
        }
        [void] $SearchResultCollection.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetGroup" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $DistinguishedName
        )
        [PSCustomObject] $ReturnValue = ConvertFrom-Json -InputObject @"
        {
            "objectGuid": null, "objectSid": null, "objectClass": null, "objectCategory": null, "GroupCategory": null, "GroupScope": null, "GroupType": null,
            "distinguishedName": null, "cn": null, "sAMAccountName": null, "displayName": null, "name": null, "parentDistinguishedName": null,
            "mail": null, "managedBy": null,
            "description": null,
            "uSNCreated": null, "uSNChanged": null, "whenCreated": null, "whenChanged": null,
            "members": null
        }
"@;
        [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($Global:Job.ActiveDirectory.GetLDAPConnection($ConnectionName));
        [String] $Filter = "(&(distinguishedName={@DistinguishedName}))".Replace("{@DistinguishedName}", $DistinguishedName);
        [System.String[]] $PropertiesToLoad = @(
            "objectSid", "objectGuid", "objectClass", "objectCategory", "groupType"
            "distinguishedName", "cn", "displayName", "name", "sAMAccountName",
            "description",
            "mail", "managedBy",
            "uSNCreated", "uSNChanged", "whenCreated", "whenChanged",
            "member"
        );
        [System.DirectoryServices.DirectorySearcher] $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new($RootDirectoryEntry, $Filter, $PropertiesToLoad, [System.DirectoryServices.SearchScope]::Subtree);
        $DirectorySearcher.PageSize = 100;
        [System.DirectoryServices.SearchResultCollection] $SearchResultCollection = $DirectorySearcher.FindAll();
        ForEach ($SearchResult In $SearchResultCollection)
        {
            [System.DirectoryServices.DirectoryEntry] $DirectoryEntry = $SearchResult.GetDirectoryEntry();
            If ($DirectoryEntry.objectSid)
            {
                If ($DirectoryEntry.objectSid.Value)
                {
                    If ($DirectoryEntry.objectSid.Value -is [Byte[]])
                    {
                        [Byte[]] $ObjectSIDBytes = $DirectoryEntry.objectSid.Value;
                        [System.Security.Principal.SecurityIdentifier] $ObjectSecurityIdentifier = [System.Security.Principal.SecurityIdentifier]::new($ObjectSIDBytes, 0);
                        $ReturnValue.objectSid = $ObjectSecurityIdentifier.ToString();
                    }
                }
            }
            If ($DirectoryEntry.Parent)
            {
                [System.DirectoryServices.DirectoryEntry] $ParentDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($DirectoryEntry.Parent);
                $ReturnValue.parentDistinguishedName = $ParentDirectoryEntry.distinguishedName[0];
            }
            If ($DirectoryEntry.Properties.Contains("managedBy"))
            {
                If ($DirectoryEntry.Properties["managedBy"].Value)
                {
                    $ReturnValue.managedBy = $DirectoryEntry.Properties["managedBy"].Value.ToString();
                }
            }
            $ReturnValue.objectGuid = [Guid]::new($DirectoryEntry.objectGuid.Value).ToString();
            $ReturnValue.objectClass = [Collections.ArrayList]::new();
            $ReturnValue.objectClass.AddRange($DirectoryEntry.objectClass);
            $ReturnValue.objectCategory = $DirectoryEntry.objectCategory[0];
            $ReturnValue.distinguishedName = $DirectoryEntry.distinguishedName[0];
            $ReturnValue.GroupType = $DirectoryEntry.GroupType[0];
            Switch ($ReturnValue.GroupType)
            {
                2
                {
                    $ReturnValue.GroupCategory = "Distribution";
                    $ReturnValue.GroupScope = "Global";
                }
                4
                {
                    $ReturnValue.GroupCategory = "Distribution";
                    $ReturnValue.GroupScope = "Local";
                }
                8
                {
                    $ReturnValue.GroupCategory = "Distribution";
                    $ReturnValue.GroupScope = "Universal";
                }
                -2147483646
                {
                    $ReturnValue.GroupCategory = "Security";
                    $ReturnValue.GroupScope = "Global";
                }
                -2147483644
                {
                    $ReturnValue.GroupCategory = "Security";
                    $ReturnValue.GroupScope = "Local";
                }
                -2147483640
                {
                    $ReturnValue.GroupCategory = "Security";
                    $ReturnValue.GroupScope = "Universal";
                }
            }

            $ReturnValue.cn = $DirectoryEntry.cn[0];
            $ReturnValue.sAMAccountName = $DirectoryEntry.sAMAccountName[0];
            $ReturnValue.displayName = $DirectoryEntry.displayName[0];
            $ReturnValue.name = $DirectoryEntry.name[0];
            $ReturnValue.description = $DirectoryEntry.description[0];
            $ReturnValue.mail = $DirectoryEntry.mail[0];

            [Int64] $uSNCreatedInt64 = $SearchResult.Properties["uSNCreated"][0];
            $ReturnValue.uSNCreated = $uSNCreatedInt64;
            [Int64] $uSNChangedInt64 = $SearchResult.Properties["uSNChanged"][0];
            $ReturnValue.uSNChanged = $uSNChangedInt64;
            $ReturnValue.whenCreated = $DirectoryEntry.whenCreated[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
            $ReturnValue.whenChanged = $DirectoryEntry.whenChanged[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");

            $ReturnValue.Members = [Collections.ArrayList]::new();
            If ($DirectoryEntry.Properties.Contains("member"))
            {
                [Int32] $RangeLoop = 0;
                While ($true)
                {
                    $RangeLoop ++;
                    $ReturnValue.Members.AddRange($DirectoryEntry.Properties["member"]);
                    If (($MemberDNs.Count -eq 0) -or ($MemberDNs.Count -lt 1500))
                    {
                        Break;
                    }
                    Try
                    {
                        [String] $MemberRange = "member;range=" + ($RangeLoop * $MemberDNs.Count).ToString() + "-*"
                        [void] $DirectoryEntry.RefreshCache(@($MemberRange));
                    }
                    Catch
                    {
                        Break;
                    }
                }
            }
            [void] $DirectoryEntry.Dispose();
        }
        [void] $SearchResultCollection.Dispose();
        Return $ReturnValue;
    };
