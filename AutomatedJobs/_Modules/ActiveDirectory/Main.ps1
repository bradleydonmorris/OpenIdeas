Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "ActiveDirectory" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
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
        [String] $Result = $null;
        $Values = $Global:Job.Connections.Get($Name);
        $Result = $Values.RootLDIF;
        Return $Result;
    };
Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetChangedUsers" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [DateTime] $ChangedSince
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($Global:Job.ActiveDirectory.GetLDAPConnection($ConnectionName));
        [String] $Filter = "(&(objectCategory=user)(whenChanged>={@WhenChanged}))".Replace("{@WhenChanged}", $ChangedSince.ToString("yyyyMMddHHmmss.fffffffZ"));
        [System.String[]] $PropertiesToLoad = @("distinguishedName");
        [System.DirectoryServices.DirectorySearcher] $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new($RootDirectoryEntry, $Filter, $PropertiesToLoad, [System.DirectoryServices.SearchScope]::Subtree);
        $DirectorySearcher.PageSize = 100;
        [System.DirectoryServices.SearchResultCollection] $SearchResultCollection = $DirectorySearcher.FindAll();
        ForEach ($SearchResult In $SearchResultCollection)
        {
            [void] $Results.Add($SearchResult.Properties["distinguishedName"][0]);
        }
        [void] $SearchResultCollection.Dispose();
        Return $Results;
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
        [PSCustomObject] $Results = ConvertFrom-Json -InputObject @"
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
                        $Results.objectSid = $ObjectSecurityIdentifier.ToString();
                    }
                }
            }
            If ($DirectoryEntry.Parent)
            {
                [System.DirectoryServices.DirectoryEntry] $ParentDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($DirectoryEntry.Parent);
                $Results.parentDistinguishedName = $ParentDirectoryEntry.distinguishedName[0];
            }
            If ($DirectoryEntry.Properties.Contains("manager"))
            {
                If ($DirectoryEntry.Properties["manager"].Value)
                {
                    $Results.manager = $DirectoryEntry.Properties["manager"].Value;
                }
            }
            If ($DirectoryEntry.msExchMailboxGuid)
            {
                If ($DirectoryEntry.msExchMailboxGuid.Value)
                {
                    If ($DirectoryEntry.msExchMailboxGuid.Value -is [Byte[]])
                    {
                        $Results.msExchMailboxGuid = [Guid]::new($DirectoryEntry.msExchMailboxGuid.Value).ToString();
                    }
                }
            }
        
            $Results.objectGuid = [Guid]::new($DirectoryEntry.objectGuid.Value).ToString();
            $Results.objectClass = [Collections.ArrayList]::new();
            $Results.objectClass.AddRange($DirectoryEntry.objectClass);
            $Results.objectCategory = $DirectoryEntry.objectCategory[0];
            $Results.UserPrincipalName = $DirectoryEntry.UserPrincipalName[0];
            $Results.distinguishedName = $DirectoryEntry.distinguishedName[0];
            $Results.cn = $DirectoryEntry.cn[0];
            $Results.sAMAccountName = $DirectoryEntry.sAMAccountName[0];
            $Results.displayName = $DirectoryEntry.displayName[0];
            $Results.name = $DirectoryEntry.name[0];
            $Results.givenName = $DirectoryEntry.givenName[0];
            $Results.middleName = $DirectoryEntry.middleName[0];
            $Results.sn = $DirectoryEntry.sn[0];
            $Results.initials = $DirectoryEntry.initials[0];
            $Results.title = $DirectoryEntry.title[0];
            $Results.department = $DirectoryEntry.department[0];
            $Results.company = $DirectoryEntry.company[0];
            $Results.description = $DirectoryEntry.description[0];
            $Results.employeeNumber = $DirectoryEntry.employeeNumber[0];
            $Results.employeeID = $DirectoryEntry.employeeID[0];
            $Results.extensionAttribute1 = $DirectoryEntry.extensionAttribute1[0];
            $Results.extensionAttribute2 = $DirectoryEntry.extensionAttribute2[0];
            $Results.extensionAttribute3 = $DirectoryEntry.extensionAttribute3[0];
            $Results.mail = $DirectoryEntry.mail[0];
            $Results.telephoneNumber = $DirectoryEntry.telephoneNumber[0];
            $Results.mobile = $DirectoryEntry.mobile[0];
            $Results.pager = $DirectoryEntry.pager[0];
            $Results.facsimileTelephoneNumber = $DirectoryEntry.facsimileTelephoneNumber[0];
            $Results.ipPhone = $DirectoryEntry.ipPhone[0];
            $Results.homePhone = $DirectoryEntry.homePhone[0];
            $Results.url = $DirectoryEntry.url[0];
            $Results.wWWHomePage = $DirectoryEntry.wWWHomePage[0];
            $Results.otherFacsimileTelephoneNumber = $DirectoryEntry.otherFacsimileTelephoneNumber[0];
            $Results.otherHomePhone = $DirectoryEntry.otherHomePhone[0];
            $Results.otherIpPhone = $DirectoryEntry.otherIpPhone[0];
            $Results.otherMobile = $DirectoryEntry.otherMobile[0];
            $Results.otherPager = $DirectoryEntry.otherPager[0];
            $Results.otherTelephone = $DirectoryEntry.otherTelephone[0];
            $Results.physicalDeliveryOfficeName = $DirectoryEntry.physicalDeliveryOfficeName[0];
            $Results.postalCode = $DirectoryEntry.postalCode[0];
            $Results.streetAddress = $DirectoryEntry.streetAddress[0];
            $Results.postOfficeBox = $DirectoryEntry.postOfficeBox[0];
            $Results.l = $DirectoryEntry.l[0];
            $Results.st = $DirectoryEntry.st[0];
            $Results.c = $DirectoryEntry.c[0];
            $Results.countryCode = $DirectoryEntry.countryCode[0];
            $Results.co = $DirectoryEntry.co[0];
            [Int64] $lastLogonInt64 = $SearchResult.Properties["lastLogon"][0];
            If ($lastLogonInt64 -eq 0 -or $lastLogonInt64 -gt [DateTime]::MaxValue.Ticks)
                { $Results.lastLogon = $null; }
            Else
                { $Results.lastLogon = [DateTime]::FromFileTimeUtc($lastLogonInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            [Int64] $lastLogoffInt64 = $SearchResult.Properties["lastLogoff"][0];
            If ($lastLogoffInt64 -eq 0 -or $lastLogoffInt64 -gt [DateTime]::MaxValue.Ticks)
                { $Results.lastLogoff = $null; }
            Else
                { $Results.lastLogoff = [DateTime]::FromFileTimeUtc($lastLogoffInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
            
            [Int64] $lastLogonTimestampInt64 = $SearchResult.Properties["lastLogonTimestamp"][0];
            If ($lastLogonTimestampInt64 -eq 0 -or $lastLogonTimestampInt64 -gt [DateTime]::MaxValue.Ticks)
                { $Results.lastLogonTimestamp = $null; }
            Else
                { $Results.lastLogonTimestamp = [DateTime]::FromFileTimeUtc($lastLogonTimestampInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            [Int64] $pwdLastSetInt64 = $SearchResult.Properties["pwdLastSet"][0];
            If ($pwdLastSetInt64 -eq 0 -or $pwdLastSetInt64 -gt [DateTime]::MaxValue.Ticks)
                { $Results.pwdLastSet = $null; }
            Else
                { $Results.pwdLastSet = [DateTime]::FromFileTimeUtc($pwdLastSetInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            [Int64] $accountExpiresInt64 = $SearchResult.Properties["accountExpires"][0];
            If ($accountExpiresInt64 -eq 0 -or $accountExpiresInt64 -gt [DateTime]::MaxValue.Ticks)
                { $Results.accountExpires = $null; }
            Else
                { $Results.accountExpires = [DateTime]::FromFileTimeUtc($accountExpiresInt64).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); }
        
            $Results.homeDrive = $DirectoryEntry.homeDrive[0];
            $Results.homeDirectory = $DirectoryEntry.homeDirectory[0];
            $Results.profilePath = $DirectoryEntry.profilePath[0];
            $Results.scriptPath = $DirectoryEntry.scriptPath[0];
            $Results.info = $DirectoryEntry.info[0];
            $Results.userAccountControl = $DirectoryEntry.userAccountControl[0];
        
            [Int64] $uSNCreatedInt64 = $SearchResult.Properties["uSNCreated"][0];
            $Results.uSNCreated = $uSNCreatedInt64;
            [Int64] $uSNChangedInt64 = $SearchResult.Properties["uSNChanged"][0];
            $Results.uSNChanged = $uSNChangedInt64;
            $Results.whenCreated = $DirectoryEntry.whenCreated[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
            $Results.whenChanged = $DirectoryEntry.whenChanged[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
            [void] $DirectoryEntry.Dispose();
        }
        [void] $SearchResultCollection.Dispose();
        Return $Results;
    };

Add-Member `
    -InputObject $Global:Job.ActiveDirectory `
    -Name "GetChangedGroups" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [DateTime] $ChangedSince
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($Global:Job.ActiveDirectory.GetLDAPConnection($ConnectionName));
        [String] $Filter = "(&(objectCategory=group)(whenChanged>={@WhenChanged}))".Replace("{@WhenChanged}", $ChangedSince.ToString("yyyyMMddHHmmss.fffffffZ"));
        [System.String[]] $PropertiesToLoad = @("distinguishedName");
        [System.DirectoryServices.DirectorySearcher] $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new($RootDirectoryEntry, $Filter, $PropertiesToLoad, [System.DirectoryServices.SearchScope]::Subtree);
        $DirectorySearcher.PageSize = 100;
        [System.DirectoryServices.SearchResultCollection] $SearchResultCollection = $DirectorySearcher.FindAll();
        ForEach ($SearchResult In $SearchResultCollection)
        {
            [void] $Results.Add($SearchResult.Properties["distinguishedName"][0]);
        }
        [void] $SearchResultCollection.Dispose();
        Return $Results;
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
        [PSCustomObject] $Results = ConvertFrom-Json -InputObject @"
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
                        $Results.objectSid = $ObjectSecurityIdentifier.ToString();
                    }
                }
            }
            If ($DirectoryEntry.Parent)
            {
                [System.DirectoryServices.DirectoryEntry] $ParentDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($DirectoryEntry.Parent);
                $Results.parentDistinguishedName = $ParentDirectoryEntry.distinguishedName[0];
            }
            If ($DirectoryEntry.Properties.Contains("managedBy"))
            {
                If ($DirectoryEntry.Properties["managedBy"].Value)
                {
                    $Results.managedBy = $DirectoryEntry.Properties["managedBy"].Value.ToString();
                }
            }
            $Results.objectGuid = [Guid]::new($DirectoryEntry.objectGuid.Value).ToString();
            $Results.objectClass = [Collections.ArrayList]::new();
            $Results.objectClass.AddRange($DirectoryEntry.objectClass);
            $Results.objectCategory = $DirectoryEntry.objectCategory[0];
            $Results.distinguishedName = $DirectoryEntry.distinguishedName[0];
            $Results.GroupType = $DirectoryEntry.GroupType[0];
            Switch ($Results.GroupType)
            {
                2
                {
                    $Results.GroupCategory = "Distribution";
                    $Results.GroupScope = "Global";
                }
                4
                {
                    $Results.GroupCategory = "Distribution";
                    $Results.GroupScope = "Local";
                }
                8
                {
                    $Results.GroupCategory = "Distribution";
                    $Results.GroupScope = "Universal";
                }
                -2147483646
                {
                    $Results.GroupCategory = "Security";
                    $Results.GroupScope = "Global";
                }
                -2147483644
                {
                    $Results.GroupCategory = "Security";
                    $Results.GroupScope = "Local";
                }
                -2147483640
                {
                    $Results.GroupCategory = "Security";
                    $Results.GroupScope = "Universal";
                }
            }

            $Results.cn = $DirectoryEntry.cn[0];
            $Results.sAMAccountName = $DirectoryEntry.sAMAccountName[0];
            $Results.displayName = $DirectoryEntry.displayName[0];
            $Results.name = $DirectoryEntry.name[0];
            $Results.description = $DirectoryEntry.description[0];
            $Results.mail = $DirectoryEntry.mail[0];

            [Int64] $uSNCreatedInt64 = $SearchResult.Properties["uSNCreated"][0];
            $Results.uSNCreated = $uSNCreatedInt64;
            [Int64] $uSNChangedInt64 = $SearchResult.Properties["uSNChanged"][0];
            $Results.uSNChanged = $uSNChangedInt64;
            $Results.whenCreated = $DirectoryEntry.whenCreated[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
            $Results.whenChanged = $DirectoryEntry.whenChanged[0].ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");

            $Results.Members = [Collections.ArrayList]::new();
            If ($DirectoryEntry.Properties.Contains("member"))
            {
                [Int32] $RangeLoop = 0;
                While ($true)
                {
                    $RangeLoop ++;
                    $Results.Members.AddRange($DirectoryEntry.Properties["member"]);
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
        Return $Results;
    };
