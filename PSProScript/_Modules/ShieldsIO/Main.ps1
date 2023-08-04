Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "ShieldsIO" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
    Add-Member `
    -InputObject $Global:Session.ShieldsIO `
    -Name "BuildURL" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [String] $Label,
            [String] $Message,
            [String] $Color
        )
        Return [String]::Format("https://img.shields.io/badge/{0}-{1}-{2}",
            $Label.Replace("_", "__").Replace("-", "--").Replace(" ", "_"),
            $Message.Replace("_", "__").Replace("-", "--").Replace(" ", "_"),
            $Color.ToLower()
        );
    }
Add-Member `
    -InputObject $Global:Session.ShieldsIO `
    -Name "Download" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [String] $Label,
            [String] $Message,
            [String] $Color,
            [String] $OutputFilePath
        )
        $PreviousProgressPreference = $global:ProgressPreference;
        $global:ProgressPreference = "SilentlyContinue";
        Invoke-WebRequest `
            -Uri ([String]::Format("https://img.shields.io/badge/{0}-{1}-{2}",
                $Label.Replace("_", "__").Replace("-", "--").Replace(" ", "_"),
                $Message.Replace("_", "__").Replace("-", "--").Replace(" ", "_"),
                $Color.ToLower()
            )) `
            -OutFile $OutputFilePath;
        $global:ProgressPreference = $PreviousProgressPreference;
    }
