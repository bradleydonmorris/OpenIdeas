[void] $Global:Session.LoadModule("Connections");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "GoogleAPI" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted,
    
            [Parameter(Mandatory=$true)]
            [String] $ClientId,
    
            [Parameter(Mandatory=$true)]
            [String] $ProjectId,
    
            [Parameter(Mandatory=$true)]
            [String] $AuthURI,
    
            [Parameter(Mandatory=$true)]
            [String] $TokenURI,
    
            [Parameter(Mandatory=$true)]
            [String] $AuthProviderx509CertURI,
    
            [Parameter(Mandatory=$true)]
            [String] $ClientSecret,
    
            [Parameter(Mandatory=$true)]
            [String] $RedirectURI,
    
            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[String]] $Scopes,
    
            [Parameter(Mandatory=$true)]
            [String] $RefreshToken
        )
        $Global:Session.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "ClientId" = $ClientId;
                "ProjectId" = $ProjectId;
                "AuthURI" = $AuthURI;
                "TokenURI" = $TokenURI;
                "AuthProviderx509CertURI" = $AuthProviderx509CertURI;
                "ClientSecret" = $ClientSecret;
                "RedirectURI" = $RedirectURI;
                "Scopes" = $Scopes;
                "RefreshToken" = $RefreshToken;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        Return $Global:Session.Connections.Get($Name);
    };
Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "GetRefreshedToken" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [String] $ReturnValue = $null;
        $Values = $Global:Session.GoogleAPI.GetConnection($ConnectionName);
        [Collections.Hashtable] $TokenRequestBody = @{
            "client_id" = $Values.ClientId;
            "client_secret" = $Values.ClientSecret;
            "refresh_token" = ([String]::IsNullOrEmpty($Values.RefreshToken) ? $null : $Values.RefreshToken);
            "grant_type" = "refresh_token";
        };
        $Tokens = Invoke-RestMethod -Uri $Values.TokenURI -Method POST -Body $TokenRequestBody;
        $ReturnValue = $Tokens.access_token;
        If (
            ![String]::IsNullOrEmpty($Tokens.refresh_token) -and
            $Values.RefreshToken -ne $Tokens.refresh_token
        )
        {
            $Values.RefreshToken = $Tokens.refresh_token
            $Global:Session.Connections.Update($ConnectionName, $Values);
        }
        Return $ReturnValue;
    };
#endregion Connection Methods

Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "GetUsers" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [String] $AccessToken = $Global:Session.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/users" +
            "?maxResults=200" +
            "&customer=my_customer" +
            "&projection=full" +
            "&showDeleted=false" +
            "&viewType=admin_view" +
            "&pageToken={@PageToken}" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", "")) -Method Get;
        If ($Response.users.Count -gt 0)
        {
            ForEach ($Users In $Response.users)
            {
                [void] $ReturnValue.Add([PSObject]$Users);
            }
            While (
                $Response.users.Count -gt 0 -and
                ![String]::IsNullOrEmpty($Response.nextPageToken)
            )
            {
                $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", $Response.nextPageToken)) -Method Get;
                ForEach ($Users In $Response.users)
                {
                    [void] $ReturnValue.Add([PSObject]$Users);
                }
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "GetGroups" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Boolean] $IncludeMembers
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [String] $AccessToken = $Global:Session.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/groups" +
            "?maxResults=200" +
            "&customer=my_customer" +
            "&pageToken={@PageToken}" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", "")) -Method Get;
        If ($Response.groups.Count -gt 0)
        {
            ForEach ($Group In $Response.groups)
            {
                If ($IncludeMembers)
                {
                    Add-Member `
                        -InputObject $Group `
                        -TypeName "System.Collections.Generic.List[PSObject]" `
                        -NotePropertyName "Members" `
                        -NotePropertyValue ($Global:Session.GoogleAPI.GetGroupMembers($ConnectionName, $Group.id));
                }
                [void] $ReturnValue.Add([PSObject]$Group);
            }
            While (
                $Response.groups.Count -gt 0 -and
                ![String]::IsNullOrEmpty($Response.nextPageToken)
            )
            {
                $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", $Response.nextPageToken)) -Method Get;
                ForEach ($Group In $Response.groups)
                {
                    If ($IncludeMembers)
                    {
                        Add-Member `
                            -InputObject $Group `
                            -TypeName "System.Collections.Generic.List[PSObject]" `
                            -NotePropertyName "Members" `
                            -NotePropertyValue ($Global:Session.GoogleAPI.GetGroupMembers($ConnectionName, $Group.id));
                    }
                    [void] $ReturnValue.Add([PSObject]$Group);
                }
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "GetGroupMembers" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $GroupId
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [String] $AccessToken = $Global:Session.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/groups/$GroupId/members" +
            "?maxResults=200" +
            "&pageToken={@PageToken}" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", "")) -Method Get;
        If ($Response.members.Count -gt 0)
        {
            ForEach ($Member In $Response.members)
            {
                [void] $ReturnValue.Add([PSObject]$Member);
            }
            While (
                $Response.members.Count -gt 0 -and
                ![String]::IsNullOrEmpty($Response.nextPageToken)
            )
            {
                $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", $Response.nextPageToken)) -Method Get;
                ForEach ($Member In $Response.members)
                {
                    [void] $ReturnValue.Add([PSObject]$Member);
                }
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.GoogleAPI `
    -Name "GetOrgUnits" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [String] $AccessToken = $Global:Session.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/customer/my_customer/orgunits" +
            "?type=ALL" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri $URI -Method Get;
        If ($Response.organizationUnits.Count -gt 0)
        {
            ForEach ($OrganizationUnit In $Response.organizationUnits)
            {
                [void] $ReturnValue.Add([PSObject]$OrganizationUnit);
            }
        }
        Return $ReturnValue;
    };
