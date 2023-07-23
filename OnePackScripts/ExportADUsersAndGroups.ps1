[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [String] $RootLDIF,

    [Parameter(Mandatory=$true)]
    [String] $ChangedUserFilePath,

    [Parameter(Mandatory=$true)]
    [String] $ChangedGroupFilePath,

    [Parameter(Mandatory=$true)]
    [String] $ChangedGroupMemberFilePath,
    
    [Parameter(Mandatory=$false)]
    [DateTime] $UserLastChangedTime = [DateTime]::UnixEpoch,

    [Parameter(Mandatory=$false)]
    [DateTime] $GroupLastChangedTime = [DateTime]::UnixEpoch,

    [Parameter(Mandatory=$false)]
    [String] $Delimiter = "|"
)

Function Get-ChangedADUsers()
{
    [OutputType([Collections.Generic.List[String]])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $RootLDIF,

        [Parameter(Mandatory=$true)]
        [DateTime] $ChangedSince
    )
    [Collections.Generic.List[String]] $ReturnValue = [Collections.Generic.List[String]]::new();
    [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($RootLDIF);
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
Function Get-ADUser()
{
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $RootLDIF,

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
    [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($RootLDIF);
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
        $ReturnValue.objectClass = [Collections.Generic.List[Object]]::new();
        ForEach ($PropertyValue In $DirectoryEntry.objectClass)
        {
            [void] $ReturnValue.objectClass.Add($PropertyValue);
        }
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
Function Get-ChangedADGroups()
{
    [OutputType([Collections.Generic.List[String]])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $RootLDIF,

        [Parameter(Mandatory=$true)]
        [DateTime] $ChangedSince
    )
    [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
    [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($RootLDIF);
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
Function Get-ADGroup()
{
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $RootLDIF,

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
    [System.DirectoryServices.DirectoryEntry] $RootDirectoryEntry = [System.DirectoryServices.DirectoryEntry]::new($RootLDIF);
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
        $ReturnValue.objectClass = [Collections.Generic.List[Object]]::new();
        ForEach ($PropertyValue In $DirectoryEntry.objectClass)
        {
            [void] $ReturnValue.objectClass.Add($PropertyValue);
        }
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

        $ReturnValue.Members = [Collections.Generic.List[PSObject]]::new();
        If ($DirectoryEntry.Properties.Contains("member"))
        {
            [Int32] $RangeLoop = 0;
            While ($true)
            {
                $RangeLoop ++;
                ForEach ($MemberDistiguishedName In $DirectoryEntry.Properties["member"])
                {
                    [void] $ReturnValue.Members.Add($MemberDistiguishedName);
                }
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

Function Export-ChangedADUsers()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $RootLDIF,

        [Parameter(Mandatory=$true)]
        [DateTime] $ChangedSince,

        [Parameter(Mandatory=$false)]
        [String] $Delimiter,

        [Parameter(Mandatory=$true)]
        [String] $OutputFilePath
    )
    If ([String]::IsNullOrEmpty($Delimiter))
    {
        $Delimiter = "|";
    }
    [String] $ObjectClassDelimieter = ",";
    If ($Delimiter -ne "|")
    {
        $ObjectClassDelimieter = "|"
    }
    [System.Text.StringBuilder] $StringBuilderHeader = [System.Text.StringBuilder]::new();
    [void] $StringBuilderHeader.Append("objectGuid");
    [void] $StringBuilderHeader.AppendFormat("{0}objectSid", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}objectClass", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}objectCategory", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}userPrincipalName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}distinguishedName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}cn", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}sAMAccountName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}displayName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}name", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}parentDistinguishedName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}givenName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}middleName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}sn", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}initials", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}title", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}department", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}company", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}manager", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}description", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}employeeNumber", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}employeeID", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}extensionAttribute1", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}extensionAttribute2", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}extensionAttribute3", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}mail", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}telephoneNumber", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}mobile", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}pager", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}facsimileTelephoneNumber", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}ipPhone", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}homePhone", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}msExchMailboxGuid", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}url", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}wWWHomePage", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}otherFacsimileTelephoneNumber", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}otherHomePhone", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}otherIpPhone", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}otherMobile", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}otherPager", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}otherTelephone", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}physicalDeliveryOfficeName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}postalCode", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}streetAddress", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}postOfficeBox", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}l", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}st", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}c", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}countryCode", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}co", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}lastLogoff", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}lastLogon", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}lastLogonTimestamp", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}pwdLastSet", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}accountExpires", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}homeDrive", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}homeDirectory", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}profilePath", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}scriptPath", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}userWorkstations", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}logonHours", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}info", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}userAccountControl", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}uSNCreated", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}uSNChanged", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}whenCreated", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}whenChanged", $Delimiter);
    Set-Content -Path $OutputFilePath -Value ($StringBuilderHeader.ToString());
    ForEach ($DistinguishedName In (Get-ChangedADUsers -RootLDIF $RootLDIF -ChangedSince $ChangedSince))
    {
        $User = Get-ADUser -RootLDIF $RootLDIF -DistinguishedName $DistinguishedName;
        [System.Text.StringBuilder] $StringBuilderLine = [System.Text.StringBuilder]::new();
        [void] $StringBuilderLine.Append($User.objectGuid.ToString());
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.objectSid);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.objectClass -join $ObjectClassDelimieter);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.objectCategory);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.userPrincipalName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.distinguishedName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.cn);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.sAMAccountName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.displayName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.name);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.parentDistinguishedName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.givenName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.middleName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.sn);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.initials);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.title);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.department);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.company);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.manager);
        If (![String]::IsNullOrEmpty($User.description))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.description.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.employeeNumber);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.employeeID);
        If (![String]::IsNullOrEmpty($User.extensionAttribute1))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.extensionAttribute1.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        If (![String]::IsNullOrEmpty($User.extensionAttribute2))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.extensionAttribute2.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        If (![String]::IsNullOrEmpty($User.extensionAttribute3))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.extensionAttribute3.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.mail);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.telephoneNumber);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.mobile);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.pager);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.facsimileTelephoneNumber);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.ipPhone);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.homePhone);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.msExchMailboxGuid);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.url);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.wWWHomePage);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.otherFacsimileTelephoneNumber);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.otherHomePhone);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.otherIpPhone);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.otherMobile);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.otherPager);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.otherTelephone);
        If (![String]::IsNullOrEmpty($User.physicalDeliveryOfficeName))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.physicalDeliveryOfficeName.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.postalCode);
        If (![String]::IsNullOrEmpty($User.streetAddress))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.streetAddress.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        If (![String]::IsNullOrEmpty($User.postOfficeBox))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.postOfficeBox.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.l);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.st);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.c);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.countryCode);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.co);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.lastLogoff);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.lastLogon);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.lastLogonTimestamp);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.pwdLastSet);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.accountExpires);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.homeDrive);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.homeDirectory);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.profilePath);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.scriptPath);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.userWorkstations);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.logonHours);
        If (![String]::IsNullOrEmpty($User.info))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.info.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.userAccountControl);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.uSNCreated);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.uSNChanged);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.whenCreated);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $User.whenChanged);
        Add-Content -Path $OutputFilePath -Value ($StringBuilderLine.ToString());
    }
}

Function Export-ChangedADGroups()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $RootLDIF,

        [Parameter(Mandatory=$true)]
        [DateTime] $ChangedSince,

        [Parameter(Mandatory=$false)]
        [String] $Delimiter,

        [Parameter(Mandatory=$true)]
        [String] $OutputFilePath,

        [Parameter(Mandatory=$true)]
        [String] $MembersOutputFilePath
    )
    If ([String]::IsNullOrEmpty($Delimiter))
    {
        $Delimiter = "|";
    }
    [String] $ObjectClassDelimieter = ",";
    If ($Delimiter -ne "|")
    {
        $ObjectClassDelimieter = "|"
    }
    [System.Text.StringBuilder] $StringBuilderHeader = [System.Text.StringBuilder]::new();
    [void] $StringBuilderHeader.Append("objectGuid");
    [void] $StringBuilderHeader.AppendFormat("{0}objectSid", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}objectClass", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}objectCategory", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}GroupCategory", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}GroupScope", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}GroupType", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}distinguishedName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}cn", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}sAMAccountName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}displayName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}name", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}parentDistinguishedName", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}mail", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}managedBy", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}description", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}uSNCreated", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}uSNChanged", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}whenCreated", $Delimiter);
    [void] $StringBuilderHeader.AppendFormat("{0}whenChanged", $Delimiter);
    Set-Content -Path $OutputFilePath -Value ($StringBuilderHeader.ToString());
    Set-Content -Path $MembersOutputFilePath -Value ([String]::Format(
        "{0}{1}{2}",
        "GroupDistinguishedName",
        $Delimiter,
        "MemberDistinguishedName"
    ));
    ForEach ($DistinguishedName In (Get-ChangedADGroups -RootLDIF $RootLDIF -ChangedSince $ChangedSince))
    {
        $Group = Get-ADGroup -RootLDIF $RootLDIF -DistinguishedName $DistinguishedName;
        [System.Text.StringBuilder] $StringBuilderLine = [System.Text.StringBuilder]::new();
        [void] $StringBuilderLine.Append($Group.objectGuid.ToString());
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.objectSid);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.objectClass -join $ObjectClassDelimieter);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.objectCategory);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.GroupCategory);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.GroupScope);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.GroupType);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.distinguishedName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.cn);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.sAMAccountName);
        If (![String]::IsNullOrEmpty($Group.displayName))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.displayName.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.name);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.parentDistinguishedName);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.mail);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.managedBy);
        If (![String]::IsNullOrEmpty($Group.description))
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.description.Replace("`r", "\r").Replace("`n", "\n"));
        }
        Else
        {
            [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, "");
        }
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.uSNCreated);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.uSNChanged);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.whenCreated);
        [void] $StringBuilderLine.AppendFormat("{0}{1}", $Delimiter, $Group.whenChanged);
        Add-Content -Path $OutputFilePath -Value ($StringBuilderLine.ToString());
        ForEach ($MemberDistinguishedName In $Group.members)
        {
            Add-Content -Path $MembersOutputFilePath -Value ([String]::Format(
                "{0}{1}{2}",
                $Group.distinguishedName,
                $Delimiter,
                $MemberDistinguishedName
            ));
        }
    }
}

Export-ChangedADUsers `
    -RootLDIF $RootLDIF `
    -ChangedSince $UserLastChangedTime `
    -Delimiter $Delimiter `
    -OutputFilePath $ChangedUserFilePath;
Export-ChangedADGroups `
    -RootLDIF $RootLDIF `
    -ChangedSince $GroupLastChangedTime `
    -Delimiter $Delimiter `
    -OutputFilePath $ChangedGroupFilePath `
    -MembersOutputFilePath $ChangedGroupMemberFilePath;
