. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "GnuPG"
);

#"C:\Integrations\Keys";

[String] $DefaultHomeDirectory = "C:\Integrations\Keys"; #[IO.Path]::Combine($env:APPDATA, "gnupg");
[String] $HomeDirectory = $Global:Session.Prompts.StringResponse("Home Directory", $DefaultHomeDirectory)
If ($HomeDirectory -eq $DefaultHomeDirectory)
{
    $HomeDirectory = $null;
}


[Boolean] $ExitMenu = $false;
While (!$ExitMenu)
{
    Clear-Host;
    [String] $MenuResponse = $Global:Session.Prompts.ShowMenu(100,
        @(
            @{ "Selector" = "L"; "Name" = "ListAllKeys"; "Text" = "List Keys"; },
            @{ "Selector" = "XX"; "Name" = "ExitApplication"; "Text" = "Exit Application"; }
        )
    )
    Switch ($MenuResponse)
    {
        "ListAllKeys"
        {
            Clear-Host;
            ForEach ($Key In $Global:Session.GnuPG.GetKeys($HomeDirectory))
            {
                Write-Host -Object ([String]::Format(
                    "{0} <{1}>`n`t{2}`n`tType: {3}`tExpiry Date: {4}`n`tComment: {5}`n",
                    $Key.Name, $Key.EmailAddress,
                    $Key.Fingerprint,
                    $Key.KeyType, $Key.ExpiryDate,
                    $Key.Comment
                ));
            }
            $Global:Session.Prompts.PressEnter();
            $ExitMenu = $false;
        }
        "ExitApplication"
        {
            $ExitMenu = $true;
        }
        Default
        {
            $ExitMenu = $false;
        }
    }
}




#$Global:Session.GnuPG.AddPrivateKey("C:\Integrations\Keys\0x27FCEB66-sec.asc", "JustAPhrase", "C:\Integrations\Keys");
#$Global:Session.GnuPG.AddPublicKey("C:\Integrations\Keys\0x27FCEB66-pub.asc", "C:\Integrations\Keys");

#$Global:Session.GnuPG.RemovePrivateKey("BC1462F2F02D32AE75C3EA52FECBB050A83FB6BC", $HomeDirectory);
#$Global:Session.GnuPG.RemovePublicKey("BC1462F2F02D32AE75C3EA52FECBB050A83FB6BC", $HomeDirectory);





