Function Dev-SetVSDirsHidden()
{
    [String] $DefaultRepoDirectoryPath = "C:\Users\" + $env:USERNAME + "\source\repos";
    ForEach ($Directory In (Get-ChildItem -Path $DefaultRepoDirectoryPath -Directory -Filter ".vs" -Recurse))
    {
        If (-not ($Directory.Attributes -band [System.IO.FileAttributes]::Hidden))
        {
            Write-Host $Directory.FullName
            Write-Host "`tNot hidden. Marking as hidden.";
            $Directory.Attributes = $Directory.Attributes -bor [System.IO.FileAttributes]::Hidden;
        }
    }
}

Function Dev-SetGitDirsHidden()
{
    [String] $DefaultRepoDirectoryPath = "C:\Users\" + $env:USERNAME + "\source\repos";
    ForEach ($Directory In (Get-ChildItem -Path $DefaultRepoDirectoryPath -Directory -Filter ".git" -Recurse))
    {
        If (-not ($Directory.Attributes -band [System.IO.FileAttributes]::Hidden))
        {
            Write-Host $Directory.FullName
            Write-Host "`tNot hidden. Marking as hidden.";
            $Directory.Attributes = $Directory.Attributes -bor [System.IO.FileAttributes]::Hidden;
        }
    }
}

Function Dev-NewBlankSolution()
{
    Param
    (
        [Parameter(Mandatory=$false)]
        [String] $Name
    )
    If ($Name -eq $null -or [String]::IsNullOrWhiteSpace($Name))
    {
        $Name = Split-Path -Path $PWD -Leaf;
    }
    If (-not $Name.EndsWith(".sln"))
    {
        $Name += ".sln"
    }
    [String] $FilePath = Join-Path -Path $PWD -ChildPath $Name;
    [String] $Contents =@"

Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 16
VisualStudioVersion = 16.0.31702.278
MinimumVisualStudioVersion = 10.0.40219.1
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = ".repofiles", ".repofiles", "{@Guid_1}"
	ProjectSection(SolutionItems) = preProject
		.gitignore = .gitignore
		LICENSE = LICENSE
		README.md = README.md
	EndProjectSection
EndProject
Global
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = {@Guid_2}
	EndGlobalSection
EndGlobal
"@
    For ($Loop = 1; $Loop -le 2; $Loop ++)
    {
        [Guid] $NewGuid = [Guid]::NewGuid();
        $Contents = $Contents.Replace("{@Guid_" + $Loop + "}", $NewGuid.ToString("B"));
    }
    Write-Host -Object $("Creating " + $Name);
    Set-Content -Path $FilePath -Value $Contents;
}

Function Dev-CAP()
{
    [String] $CommitMessage = [DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss.fffffffK") + " (" + $env:USERNAME + ") - {@Action}";
    [String] $Output = git status --porcelain=v1 | Out-String;
    If ($Output.Length -gt 0)
    {
        $CommitMessage = $CommitMessage.Replace("{@Action}", "Commit and Push (CAP.ps1)");
        Write-Host -Object $CommitMessage;
        Write-Host -Object $Output;
        git add . *>$null;
        git commit --message $CommitMessage *>$null;
        git push origin -q *>$null
    }
    Else
    {
	    Write-Host -Object "Nothing to Commit and Push";
    }
}
