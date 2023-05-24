#https://github.com/itext/itext7-dotnet
#https://github.com/xoofx/markdig
<#

nuget install Markdig
nuget install Microsoft.SharePointOnline.CSOM

Install-Module PowershellGet -Force
Install-PackageProvider -Name NuGet -Force
Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v3 -ProviderName NuGet
Install-Package Common.Logging
Install-Package Common.Logging.Core
Install-Package itext7
Install-Package Markdig

#>

Add-Type -Path ([IO.Path]::Combine($HOME, "source\repos\bradleydonmorris\OpenIdeas\CommonPSFunctions\libs\iTextSharp.dll"));
Add-Type -Path ([IO.Path]::Combine($HOME, "source\repos\bradleydonmorris\OpenIdeas\CommonPSFunctions\libs\Markdig.0.26.0\lib\net452\Markdig.dll"));

Function Convert-MDToHTML()
{
    Param
    (
		[Parameter(Mandatory=$false, ValueFromPipeline)]
        [String] $Path,

        [Parameter(Mandatory=$false)]
        [String] $Markdown,

		[Parameter(Mandatory=$false)]
        [String] $OutputPath,

		[Parameter(Mandatory=$false)]
        [String] $Style
    )
	[String[]] $MarkdownExtensions = @(
        "common"
        "advanced"
        "gfm-pipetables"
        "pipetables"
        "gfm-pipetables"
        "emphasisextras"
        "listextras"
        "hardlinebreak"
        "footnotes"
        "footers"
        "citations"
        "attributes"
        "gridtables"
        "abbreviations"
        "emojis"
        "definitionlists"
        "customcontainers"
        "figures"
        "mathematics"
        "bootstrap"
        "medialinks"
        "smartypants"
        "autoidentifiers"
        "tasklists"
        "diagrams"
        "nofollowlinks"
        "noopenerlinks"
        "noreferrerlinks"
        "yaml"
        "nonascii-noescape"
        "autolinks"
        "globalization"
    );
    [String] $MarkdownExtensionsList = [String]::Join('+',$MarkdownExtensions)
    #[String] $MarkdownExtensionsList = "advanced+pipetables";
    [Boolean] $SaveToFile = $true;
    [String] $Title = "";
    If ($OutputPath -eq $null -or [String]::IsNullOrWhiteSpace($OutputPath))
    {
		$SaveToFile = $false
	}
	[Markdig.MarkdownPipelineBuilder] $MarkdownPipelineBuilder = [Markdig.MarkdownPipelineBuilder]::new();
	[Markdig.MarkdownPipelineBuilder] $MarkdownPipelineBuilder = [Markdig.MarkDownExtensions]::Configure($MarkdownPipelineBuilder, $MarkdownExtensionsList)
	[Markdig.MarkdownPipeline] $MarkdownPipeline = $MarkdownPipelineBuilder.Build()
    If ($Path -ne $null -and ![String]::IsNullOrWhiteSpace($Path))
    {
		$Markdown = [System.IO.File]::ReadAllText($Path);
        $Title = [IO.Path]::GetFileNameWithoutExtension($Path);
    }
    [String] $HTML = [Markdig.Markdown]::ToHtml($Markdown, $MarkdownPipeline);
    If ($Style -ne $null -and ![String]::IsNullOrWhiteSpace($Style))
    {
        If (!$Style.EndsWith("`r`n") -or !$Style.EndsWith("`n"))
        {
            $Style += "`r`n";
        }
        $HTML = "<html>`r`n<head>`r`n`t<title>" + $Title + "</title>`r`n`t<style>`r`n" + $Style + "`t</style>`r`n</head>`r`n<body>`r`n" + $HTML + "`r`n</body>`r`n</html>";
    }
    Else
    {
        $HTML = "<html>`r`n<head>`r`n`t<title>" + $Title + "</title>`r`n</head>`r`n<body>`r`n" + $HTML + "`r`n</body>`r`n</html>";
    }
	If ($SaveToFile)
	{
		[void] [System.IO.File]::WriteAllText($OutputPath, $HTML);
	}
	Else
	{
		Return $HTML;
	}
}

Function Convert-HTMLToPDF()
{
    Param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        [String] $Path,

		[Parameter(Mandatory=$true)]
        [String] $OutputPath,

        [Parameter(Mandatory=$false)]
        [String] $PageSize,

        [Parameter(Mandatory=$false)]
        [String] $Orientation
    )
    If ($PageSize -eq $null -or [String]::IsNullOrWhiteSpace($PageSize))
    {
        $PageSize = "Letter";
    }
    If ($Orientation -eq $null -or [String]::IsNullOrWhiteSpace($Orientation))
    {
        $Orientation = "Portrait";
    }
    [String] $Arguments = "--orientation " + $Orientation + " --enable-local-file-access --page-size " + $PageSize + " --log-level none";
    Start-Process -FilePath "C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" -ArgumentList $Arguments,"`"$Path`"","`"$OutputPath`"" -NoNewWindow;
}

Function Convert-MDToPDF()
{
    Param
    (
		[Parameter(Mandatory=$false, ValueFromPipeline)]
        [String] $Path,

        [Parameter(Mandatory=$false)]
        [String] $Markdown,

		[Parameter(Mandatory=$true)]
        [String] $OutputPath
    )
    If ($Path -eq $null -or [String]::IsNullOrWhiteSpace($Path))
    {
        ConvertHTML-ToPDF -HTML $(ConvertMD-ToHTML -Markdown $Markdown) -OutputPath $OutputPath;
    }
    Else
    {
        ConvertHTML-ToPDF -HTML $(ConvertMD-ToHTML -Path $Path) -OutputPath $OutputPath;
    }
}

Function Merge-PDFs()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $MergedFilePath,

        [Parameter(Mandatory=$true)]
        [String[]] $FilePaths
    )
    [iTextSharp.text.Document] $Document = [iTextSharp.text.Document]::new();
    [System.IO.MemoryStream] $MemoryStream = [System.IO.MemoryStream]::new();
    [iTextSharp.text.pdf.PdfCopy] $PdfCopy = [iTextSharp.text.pdf.PdfCopy]::new($Document, $MemoryStream);
    [void] $Document.Open();
    ForEach ($FilePath In $FilePaths)
    {
	    [iTextSharp.text.pdf.PdfReader] $PdfReader = [iTextSharp.text.pdf.PdfReader]::new($FilePath);
	    [void] $PdfReader.ConsolidateNamedDestinations();
        For ($Loop = 1; $Loop -le $PdfReader.NumberOfPages; $Loop ++)
	    {
		    [void] $PdfCopy.AddPage($PdfCopy.GetImportedPage($PdfReader, $Loop));
	    }
	    [void] $PdfReader.Close();
        [void] $PdfReader.Dispose();
    }
    [void] $PdfCopy.Close();
    [void] $Document.Close();

    [void] $PdfCopy.Dispose();
    [void] $Document.Dispose();

    [Byte[]] $ByteArray = $MemoryStream.ToArray();
    
    If ([System.IO.File]::Exists($MergedFilePath))
    {
        [void] [System.IO.File]::Delete($MergedFilePath);
    }
    [void] [System.IO.File]::WriteAllBytes($MergedFilePath, $ByteArray)
    [void] $MemoryStream.Close();
    [void] $MemoryStream.Dispose();
}

Function Split-PDF()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $MergedFilePath,

        [Parameter(Mandatory=$true)]
        [String[]] $FolderPath
    )
    If (![IO.Directory]::Exists($FolderPath))
    {
        [void] [IO.Directory]::CreateDirectory($FolderPath);
    }
    [iTextSharp.text.pdf.PdfReader] $PdfReader = [iTextSharp.text.pdf.PdfReader]::new($MergedFilePath);
	[Int32] $PadCount = $PdfReader.NumberOfPages.ToString().Length;
    [String] $SplitFilePathTemplate = [IO.Path]::Combine($FolderPath, "{@PageNumber}.pdf");
	For ($PageNumber = 1; $PageNumber -le $PdfReader.NumberOfPages; $PageNumber ++)
	{
        [String] $SplitFilePath = $SplitFilePathTemplate.Replace("{@PageNumber}", $PageNumber.ToString().PadLeft($PadCount, "0"));
        [iTextSharp.text.Document] $Document = [iTextSharp.text.Document]::new($PdfReader.GetPageSizeWithRotation(1));
        [iTextSharp.text.pdf.PdfCopy] $PdfCopy = [iTextSharp.text.pdf.PdfCopy]::new($Document, [IO.FileStream]::new($SplitFilePath, [IO.FileMode]::Create));
        [void] $Document.Open();
        [void] $PdfCopy.AddPage($PdfCopy.GetImportedPage($PdfReader, $PageNumber));
		[void] $Document.Close();
    }
}
