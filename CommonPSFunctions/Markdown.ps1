Add-Type -Path ([IO.Path]::Combine($HOME, "source\repos\bradleydonmorris\Common\PowerShell\Functions\libs\Markdig.dll"));
Add-Type -Path ([IO.Path]::Combine($HOME, "source\repos\bradleydonmorris\Common\PowerShell\Functions\libs\iTextSharp.dll"));


Function ConvertMD-ToHTML()
{
    Param
    (
		[Parameter(Mandatory=$false, ValueFromPipeline)]
        [String] $Path,

        [Parameter(Mandatory=$false)]
        [String] $Markdown,

		[Parameter(Mandatory=$false)]
        [String] $OutputPath
    )
	[String[]] $MarkdownExtensions = @(
		'abbreviations' ## .UseAbbreviations()
		'autoidentifiers' ## .UseAutoIdentifiers()
		'citations' ## .UseCitations()
		'customcontainers' ## .UseCustomContainers()
		'definitionlists' ## .UseDefinitionLists()
		'emphasisextras' ## .UseEmphasisExtras()
		'figures' ## .UseFigures()
		'footers' ## .UseFooters()
		'footnotes' ## .UseFootnotes()
		'gridtables' ## .UseGridTables()
		'mathematics' ## .UseMathematics()
		'medialinks' ## .UseMediaLinks()
		'pipetables' ## .UsePipeTables()
		'listextras' ## .UseListExtras()
		'tasklists' ## .UseTaskLists()
		'diagrams' ## .UseDiagrams()
		'autolinks' ## .UseAutoLinks()
		'attributes' ## .UseGenericAttributes()
	);
	[Boolean] $SaveToFile = $true;
    If ($OutputPath -eq $null -or [String]::IsNullOrWhiteSpace($OutputPath))
    {
		$SaveToFile = $false
	}
	[Markdig.MarkdownPipelineBuilder] $MarkdownPipelineBuilder = [Markdig.MarkdownPipelineBuilder]::new();
	$MarkdownPipelineBuilder = [Markdig.MarkDownExtensions]::Configure($MarkdownPipelineBuilder,[String]::Join('+',$MarkdownExtensions))
	[Markdig.MarkdownPipeline] $MarkdownPipeline = $MarkdownPipelineBuilder.Build()
    If ($InputPath -ne $null -and ![String]::IsNullOrWhiteSpace($InputPath))
    {
		$Markdown = [System.IO.File]::ReadAllText($Path);
	}
    [String] $HTML = [Markdig.Markdown]::ToHtml($Markdown, $MarkdownPipeline);
	If ($SaveToFile)
	{
		[void] [System.IO.File]::WriteAllText($OutputPath, $HTML);
	}
	Else
	{
		Return $HTML;
	}
}

Function ConvertHTML-ToPDF()
{
    Param
    (
		[Parameter(Mandatory=$false, ValueFromPipeline)]
        [String] $Path,

        [Parameter(Mandatory=$false)]
        [String] $HTML,

		[Parameter(Mandatory=$true)]
        [String] $OutputPath
    )

    [System.IO.MemoryStream] $MemoryStream = [System.IO.MemoryStream]::new();
    [iTextSharp.text.Document] $Document = [iTextSharp.text.Document]::new([iTextSharp.text.PageSize]::LETTER, 72, 72, 72, 72);
    [iTextSharp.text.pdf.PdfWriter] $PdfWriter = [iTextSharp.text.pdf.PdfWriter]::GetInstance($Document, $MemoryStream);
    [void] $Document.Open();

    [iTextSharp.text.html.simpleparser.HTMLWorker] $HTMLWorker = [iTextSharp.text.html.simpleparser.HTMLWorker]::new($Document);
    [System.IO.StringReader] $StringReader = [System.IO.StringReader]::new($HTML);
    [void] $HTMLWorker.Parse($StringReader);

    [void] $Document.Close();

    [System.IO.File]::WriteAllBytes($OutputPath, $MemoryStream.ToArray());

    [void] $Document.Dispose();
    [void] $MemoryStream.Close();
    [void] $MemoryStream.Dispose();
    [void] $PdfWriter.Close();
    [void] $PdfWriter.Dispose();
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
