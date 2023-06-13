[void] $Global:Job.LoadModule("Connections");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "GoogleAPI" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.GoogleAPI `
    -Name "NewConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        [PSCustomObject] $ReturnValue = ConvertFrom-Json -InputObject @"
            {
                "Comments": "Connection for Google API",
                "ClientId": null,
                "ClientSecret": null,
                "AuthURI": "https://accounts.google.com/o/oauth2/auth",
                "TokenURI": "https://oauth2.googleapis.com/token",
                "RedirectURI":"https://localhost:8080",
                "Scopes": [],
                "RefreshToken": null,
                "CustomerId": "C03vo01mv"
            }
"@;
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.GoogleAPI `
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
        $Values = $Global:Job.Connections.Get($ConnectionName);
        [Collections.Hashtable] $TokenRequestBody = @{
            "client_id" = $Values.ClientId;
            "client_secret" = $Values.ClientSecret;
            "refresh_token" = $Values.RefreshToken;
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
            $Global:Job.Connections.Set($ConnectionName, $Values);
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.GoogleAPI `
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
        [String] $AccessToken = $Global:Job.GoogleAPI.GetRefreshedToken($ConnectionName);
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
            [void] $ReturnValue.AddRange($Response.users);
            While (
                $Response.users.Count -gt 0 -and
                ![String]::IsNullOrEmpty($Response.nextPageToken)
            )
            {
                $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", $Response.nextPageToken)) -Method Get;
                [void] $ReturnValue.AddRange($Response.users);
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.GoogleAPI `
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
        [String] $AccessToken = $Global:Job.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/groups" +
            "?maxResults=200" +
            "&customer=my_customer" +
            "&pageToken={@PageToken}" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", "")) -Method Get;
        If ($Response.groups.Count -gt 0)
        {
            If ($IncludeMembers)
            {
                ForEach ($Group In $Response.groups)
                {
                    Add-Member `
                        -InputObject $Group `
                        -TypeName "Collections.ArrayList" `
                        -NotePropertyName "Members" `
                        -NotePropertyValue ($Global:Job.GoogleAPI.GetGroupMembers($ConnectionName, $Group.id));
                    [void] $ReturnValue.Add($Group);
                }
            }
            Else
            { [void] $ReturnValue.AddRange($Response.groups); }
            While (
                $Response.groups.Count -gt 0 -and
                ![String]::IsNullOrEmpty($Response.nextPageToken)
            )
            {
                $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", $Response.nextPageToken)) -Method Get;
                [void] $ReturnValue.AddRange($Response.groups);
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.GoogleAPI `
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
        [String] $AccessToken = $Global:Job.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/groups/$GroupId/members" +
            "?maxResults=200" +
            "&pageToken={@PageToken}" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", "")) -Method Get;
        If ($Response.members.Count -gt 0)
        {
            [void] $ReturnValue.AddRange($Response.members);
            While (
                $Response.members.Count -gt 0 -and
                ![String]::IsNullOrEmpty($Response.nextPageToken)
            )
            {
                $Response = Invoke-RestMethod -Uri ($URI.Replace("{@PageToken}", $Response.nextPageToken)) -Method Get;
                [void] $ReturnValue.AddRange($Response.members);
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.GoogleAPI `
    -Name "GetOrgUnits" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[String]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Collections.Generic.List[String]] $ReturnValue = [Collections.Generic.List[String]]::new();
        [String] $AccessToken = $Global:Job.GoogleAPI.GetRefreshedToken($ConnectionName);
        [String] $URI = "https://admin.googleapis.com/admin/directory/v1/customer/my_customer/orgunits" +
            "?type=ALL" +
            "&access_token=$AccessToken";
        $Response = Invoke-RestMethod -Uri $URI -Method Get;
        If ($Response.organizationUnits.Count -gt 0)
        {
            [void] $Result.AddRange($Response.organizationUnits);
        }
        Return $Result;
    };
