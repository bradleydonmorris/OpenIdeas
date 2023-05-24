. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "GoogleAPI",
    "Prompts"
);
Clear-Host;
[String] $Name = $Global:Job.Prompts.StringResponse("Please provide connection name", $null);
# If ([String]::IsNullOrEmpty($Name))
#     { $Name = "GoogleAPI"; }
[PSCustomObject] $GoogleAPIConnection = [PSCustomObject]::new();
If ($Global:Job.Connections.Exists($Name))
    { $GoogleAPIConnection = $Global:Job.Connections.Get($Name); }
Else
    { $GoogleAPIConnection = $Global:Job.GoogleAPI.NewConnection(); }
$GoogleAPIConnection.CustomerId = $Global:Job.Prompts.StringResponse("Please provide the Customer Id", $GoogleAPIConnection.CustomerId);
$GoogleAPIConnection.ClientId = $Global:Job.Prompts.StringResponse("Please provide the Client Id", $GoogleAPIConnection.ClientId);
$GoogleAPIConnection.ClientSecret = $Global:Job.Prompts.StringResponse("Please provide the Client Secret", $GoogleAPIConnection.ClientSecret);
$GoogleAPIConnection.RedirectURI = $Global:Job.Prompts.StringResponse("Please provide the Redirect URI", $GoogleAPIConnection.RedirectURI);
$GoogleAPIConnection.AuthURI = $Global:Job.Prompts.StringResponse("Please provide the Auth URI", $GoogleAPIConnection.AuthURI);
$GoogleAPIConnection.TokenURI = $Global:Job.Prompts.StringResponse("Please provide the Token URI", $GoogleAPIConnection.TokenURI);
If ($GoogleAPIConnection.Scopes.Count -eq 0)
{
    If ($Global:Job.Prompts.BooleanResponse("Would you like to add the read only scope for Users, Groups, and Org Units"))
    {
        $GoogleAPIConnection.Scopes += "https://www.googleapis.com/auth/admin.directory.group.readonly";
        $GoogleAPIConnection.Scopes += "https://www.googleapis.com/auth/admin.directory.orgunit.readonly";
        $GoogleAPIConnection.Scopes += "https://www.googleapis.com/auth/admin.directory.user.readonly";
    }
}
If ($GoogleAPIConnection.Scopes.Count -gt 0)
{
    Write-Host -Object "The following scopes exist:";
    ForEach ($Scope In $GoogleAPIConnection.Scopes)
    {
        Write-Host -Object ("`t$Scope");
    }
}
[Boolean] $KeepAsking = $true;
While ($KeepAsking)
{
    If ($Global:Job.Prompts.BooleanResponse("Would you like to add a scope"))
    {
        [String] $NewScope = $Global:Job.Prompts.StringResponse("Please provide the new scope", $null);
        If ([String]::IsNullOrEmpty($NewScope))
        {
            $KeepAsking = $false;
        }
        Else
        {
            If (!$GoogleAPIConnection.Scopes.Contains($NewScope))
            {
                $GoogleAPIConnection.Scopes += $NewScope;
            }
        }
    }
    Else
    {
        $KeepAsking = $false;
    }
}
Clear-Host;
Write-Host -Object ("The following connection named `"" + $Name + "`" has been established.");
Write-Host -Object "If you continue to save this connection, a browser window will open to the Google login.";
Write-Host -Object "Once you log in and complete the authorization, you will be redirected to anoter page.";
Write-Host -Object "This page may not exists. However, it is important to copy the resulting address from the brower.";
Write-Host -Object "Return here once you have copied the address, and paste it into the prompt that will follow.";
Write-Host -Object "";
If ($Global:Job.Prompts.BooleanResponse("Would you like to save this connection"))
{
    $Global:Job.Connections.Set($Name, $GoogleAPIConnection);
    [String] $Scopes = [String]::Join(" ", $GoogleAPIConnection.Scopes)
    [System.String] $OAuthURI = $GoogleAPIConnection.AuthURI +
        "?client_id=" + $GoogleAPIConnection.ClientId +
        "&redirect_uri=" + $GoogleAPIConnection.RedirectURI +
        "&scope=" + $Scopes +
        "&access_type=offline" +
        "&approval_prompt=force" +
        "&response_type=code"
    Start-Process $OAuthURI;
    [String] $ResultingRedirectURL = $Global:Job.Prompts.StringResponse("Please provide the resulting URL", $null);
    If (![String]::IsNullOrEmpty($ResultingRedirectURL))
    {
        [String] $Code = [System.Web.HttpUtility]::ParseQueryString([Uri]::new($ResultingRedirectURL).Query)["code"];
        [Collections.Hashtable] $TokenRequestBody = @{
            "code" = $Code;
            "client_id" = $GoogleAPIConnection.ClientId;
            "client_secret" = $GoogleAPIConnection.ClientSecret;
            "redirect_uri" = $GoogleAPIConnection.RedirectURI;
            "grant_type" = "authorization_code";
        };
        $Tokens = Invoke-RestMethod -Uri $GoogleAPIConnection.TokenURI -Method POST -Body $TokenRequestBody;
        $GoogleAPIConnection.RefreshToken = $Tokens.refresh_token;
        ConvertTo-Json $Tokens
        $Global:Job.Connections.Set($Name, $GoogleAPIConnection);
    }
}

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();
