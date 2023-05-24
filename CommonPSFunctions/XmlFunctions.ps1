Function Get-XMLFileStructure()
{
    Param
    (
        [String] $XMLFilePath,
        [String] $OutputDirectory
    )
    If (![IO.Directory]::Exists($OutputDirectory))
    {
        [IO.Directory]::CreateDirectory($OutputDirectory);
    }
    [System.Xml.XmlDocument] $XmlDocument = [System.Xml.XmlDocument]::new();
    [void] $XmlDocument.Load($XMLFilePath);
    [String] $NodeListFilePath = [IO.Path]::Combine($OutputDirectory, "NodeList.txt");
    [String] $AttributeListFilePath = [IO.Path]::Combine($OutputDirectory, "AttributeList.txt");
    [String] $TextNodeListFilePath = [IO.Path]::Combine($OutputDirectory, "TextNodeList.txt");

    [Collections.Hashtable] $Nodes = [Collections.Hashtable]::new();
    [Collections.Hashtable] $TextNodes = [Collections.Hashtable]::new();
    [Collections.Hashtable] $Attributes = [Collections.Hashtable]::new();

    ForEach ($XmlNode In $XmlDocument.SelectNodes("//*"))
    {
        [String] $Path = $XmlNode.LocalName;
        $ParentNode = $XmlNode.ParentNode;
        While ($ParentNode -ne $null)
        {
            If ($ParentNode.LocalName -ne "#document")
            {
                $Path = [String]::Format("{0}/{1}", $ParentNode.LocalName, $Path);
            }
            $ParentNode = $ParentNode.ParentNode;
        }
        $Path = "/" + $Path;
    
        If (!$Nodes.ContainsKey($Path))
        {
            [void] $Nodes.Add($Path, $XmlNode.LocalName);
        }

        If ($XmlNode.HasChildNodes)
        {
            If ($XmlNode.ChildNodes[0].NodeType -eq [System.Xml.XmlNodeType]::Text)
            {
                [Int32] $TextNodeLength = $XmlNode.ChildNodes[0].Value.Length;
                [String] $AttributePath = $Path + "/text()";
                If (!$Attributes.ContainsKey($AttributePath))
                {
                    [void] $Attributes.Add($AttributePath, @{
                        "AttributePath" = $AttributePath;
                        "Path" = $Path;
                        "Name" = "text()";
                        "Length" = $TextNodeLength;
                    });
                }
                ElseIf ($Attributes[$AttributePath]["Length"] -lt $TextNodeLength)
                {
                    $Attributes[$AttributePath]["Length"] = $TextNodeLength;
                }
                If (!$TextNodes.ContainsKey($Path))
                {
                    [void] $TextNodes.Add($Path, $TextNodeLength);
                }
                ElseIf ($TextNodes[$Path] -lt $TextNodeLength)
                {
                    $TextNodes[$Path] = $TextNodeLength;
                }
            }
        }

        If ($XmlNode.HasAttributes)
        {
            ForEach ($Attribute In $XmlNode.Attributes)
            {
                [String] $AttributePath = $Path + "/@" + $Attribute.Name;
                [Int32] $AttributeLength = $Attribute.Value.Length;
                If (!$Attributes.ContainsKey($AttributePath))
                {
                    [void] $Attributes.Add($AttributePath, @{
                        "AttributePath" = $AttributePath;
                        "Path" = $Path;
                        "Name" = $Attribute.Name;
                        "Length" = $AttributeLength;
                    });
                }
                ElseIf ($Attributes[$AttributePath]["Length"] -lt $AttributeLength)
                {
                    $Attributes[$AttributePath]["Length"] = $AttributeLength;
                }
            }
        }
    }

    Set-Content -Path $NodeListFilePath -Value "Path`tName";
    ForEach ($NodeKey In $Nodes.Keys)
    {
        Add-Content -Path $NodeListFilePath -Value ($NodeKey + "`t" + $Nodes[$NodeKey].ToString());
    }

    Set-Content -Path $TextNodeListFilePath -Value "Path`tMaxLength";
    ForEach ($TextNodeKey In $TextNodes.Keys)
    {
        Add-Content -Path $TextNodeListFilePath -Value ($TextNodeKey + "`t" + $TextNodes[$TextNodeKey].ToString());
    }

    [String] $AttributeListFilePath = [IO.Path]::Combine($OutputDirectory, "AttributeList.txt");

    Set-Content -Path $AttributeListFilePath -Value "AttributePath`tPath`tName`tMaxLength";
    ForEach ($AttributeKey In $Attributes.Keys)
    {
        Add-Content -Path $AttributeListFilePath -Value (
            $AttributeKey + "`t" +
            $Attributes[$AttributeKey]["Path"].ToString() + "`t" +
            $Attributes[$AttributeKey]["Name"].ToString() + "`t" +
            $Attributes[$AttributeKey]["Length"].ToString()
        );
    }
}
<#
Get-XMLFileStructure -XMLFilePath "C:\DJRC_europcar_WL_XML_1885_001_202203232359_F.xml" -OutputDirectory "C:\Users\bmorris\Downloads\djrc";

Get-XMLFileStructure `
    -XMLFilePath "C:\DJRC_europcar_WL_XML_1885_001_202203232359_F.xml" `
    -OutputDirectory "C:\Users\bmorris\Downloads\djrc";
#>
