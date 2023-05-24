. ([IO.Path]::Combine($HOME, "source\repos\bradleydonmorris\OpenIdeas\CommonPSFunctions\DocumentConversions.ps1"));
. ([IO.Path]::Combine($HOME, "source\repos\bradleydonmorris\OpenIdeas\CommonPSFunctions\LocationFunctions.ps1"));

Class NavSetFolder {
    [String] $Id;
    [String] $Name;
    [Collections.ArrayList] $Points = [Collections.ArrayList]::new();
    [Collections.ArrayList] $Legs = [Collections.ArrayList]::new();
    [Collections.ArrayList] $Routes = [Collections.ArrayList]::new();

    NavSetFolder (
        [String] $id,
        [String] $name
    )
    {
        $this.Id = $id;
        $this.Name = $name;
    }
}

Class NavSetLeg {
    [String] $Name;
    [String] $From;
    [String] $To;
    [Decimal] $Distance;
    [Decimal] $Heading;

    NavSetLeg (
        [String] $from,
        [String] $to,
        [Decimal] $distance,
        [Decimal] $heading
    )
    {
        $this.From = $from;
        $this.To = $to;
        $this.Distance = $distance;
        $this.Heading = $heading;
        $this.Name = [String]::Format("{0}->{1}", $this.From, $this.To);
    }
}

Class NavSetRouteLeg {
    [Int32] $Sequence;
    [String] $Name;
    [String] $From;
    [String] $To;
    [Decimal] $Distance;
    [Decimal] $Heading;

    NavSetRouteLeg (
        [Int32] $sequence,
        [NavSetLeg] $leg
    )
    {
        $this.Sequence = $sequence;
        $this.From = $leg.From;
        $this.To = $leg.To;
        $this.Distance = $leg.Distance;
        $this.Heading = $leg.Heading;
        $this.Name = $leg.Name;
    }

    NavSetRouteLeg (
        [Int32] $sequence,
        [String] $from,
        [String] $to,
        [Decimal] $distance,
        [Decimal] $heading
    )
    {
        $this.Sequence = $sequence;
        $this.From = $from;
        $this.To = $to;
        $this.Distance = $distance;
        $this.Heading = $heading;
        $this.Name = [String]::Format("{0}->{1}", $this.From, $this.To);
    }
}

Class NavSetPoint {
    [String] $Id;
    [String] $Name;
    [Decimal] $Latitude;
    [Decimal] $Longitude;
    [Collections.Hashtable] $Attributes;

    NavSetPoint (
        [String] $id,
        [String] $name,
        [Decimal] $latitude,
        [Decimal] $longitude
    )
    {
        $this.Id = $id;
        $this.Name = $name;
        $this.Latitude = $latitude;
        $this.Longitude = $longitude;
        $this.Attributes = [Collections.Hashtable]::new();
    }
}

Class NavSetRoute {
    [String] $Name;
    [Collections.ArrayList] $Legs;

    NavSetRoute (
        [String] $name,
        [Collections.ArrayList] $legs
    )
    {
        $this.Name = $name;
        $this.Legs = $legs;
    }
}



Function Write-NavCourseRoutes()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Path,

		[Parameter(Mandatory=$true)]
        [String] $OutputFolder,

		[Parameter(Mandatory=$true)]
        [String] $MainTemplatePath,

		[Parameter(Mandatory=$true)]
        [String] $FormSetAnswerTemplatePath,

		[Parameter(Mandatory=$true)]
        [String] $FormSetBlankTemplatePath,

		[Parameter(Mandatory=$true)]
        [String] $LegsCSVPath,

        [Parameter(Mandatory=$false)]
        [Int32] $NumberOfRoutes,

		[Parameter(Mandatory=$false)]
        [String] $RouteNameListPath
    )
    If ($NumberOfRoutes -le 0)
    {
        $NumberOfRoutes = 16;
    }
    [String] $OutputAnswerPath = [IO.Path]::Combine($OutputFolder, "Output_{0}_ANSWER.html");
    [String] $OutputBlankPath = [IO.Path]::Combine($OutputFolder, "Output_{0}_BLANK.html");
    [Collections.Hashtable] $Folders = [Collections.Hashtable]::new();
    $GeoObject = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($Path));
    ForEach ($Feature In $GeoObject.features)
    {
        If ($Feature.properties.class -eq "Folder")
        {
            [void] $Folders.Add($Feature.id, [NavSetFolder]::new(
                    $Feature.properties.id,
                    $Feature.properties.title
            ));
        }
    }
    ForEach ($Feature In $GeoObject.features)
    {
        If ($Feature.properties.class -eq "Marker")
        {
            [NavSetPoint] $Point = [NavSetPoint]::new(
                $Feature.id,
                $Feature.properties.title,
                $Feature.geometry.coordinates[1],
                $Feature.geometry.coordinates[0]
            )
            If ($Feature.properties.description.Length -gt 0)
            {
                ForEach($DescriptionLine In ($Feature.properties.description -split "`n"))
                {
                    [String[]] $DescriptionLineElement = $DescriptionLine -split ":";
                    If ($DescriptionLineElement.Count -eq 1)
                    {
                        [void] $Point.Attributes.Add($DescriptionLineElement[0], $null);
                    }
                    ElseIf ($DescriptionLineElement.Count -eq 2)
                    {
                        [void] $Point.Attributes.Add($DescriptionLineElement[0], $DescriptionLineElement[1]);
                    }
                }
            }
            [void] $Folders[$Feature.properties.folderId].Points.Add($Point);
        }
    }
    ForEach ($FolderKey In $Folders.Keys)
    {
    
        ForEach ($FromPoint In $Folders[$FolderKey].Points)
        {
            ForEach ($ToPoint In ($Folders[$FolderKey].Points | Where-Object -FilterScript { $_.Name -ne $FromPoint.Name}))
            {
                [void] $Folders[$FolderKey].Legs.Add([NavSetLeg]::new(
                    $FromPoint.Name,
                    $ToPoint.Name,
                    (Get-DistanceMeters `
                        -Latitude1 $FromPoint.Latitude `
                        -Longitude1 $FromPoint.Longitude `
                        -Latitude2 $ToPoint.Latitude `
                        -Longitude2 $ToPoint.Longitude),
                    (Get-Bearing `
                    -Latitude1 $FromPoint.Latitude `
                    -Longitude1 $FromPoint.Longitude `
                    -Latitude2 $ToPoint.Latitude `
                    -Longitude2 $ToPoint.Longitude)
                ));
            }
        }
        ForEach ($Row In
                            Import-Csv -Path $LegsCSVPath -Delimiter "," |
                                Where-Object -FilterScript { $_.One_Begin -eq "A" }
        )
        {
            [String] $RouteName = (
                $Row.One_Begin +
                $Row.Two +
                $Row.Three +
                $Row.Four +
                $Row.Five +
                $Row.One_End
            ).ToCharArray() -join "->";
            [Collections.ArrayList] $RouteLegs = [Collections.ArrayList]::new();
            [void] $RouteLegs.Add([NavSetRouteLeg]::new(1, (
                $Folders[$FolderKey].Legs |
                    Where-Object -FilterScript {
                        $_.Name -eq ([String]::Format("{0}->{1}",
                            $Row.One_Begin,
                            $Row.Two
                        ))
                    } |
                    Select-Object -First 1
            )));
            [void] $RouteLegs.Add([NavSetRouteLeg]::new(2, (
                $Folders[$FolderKey].Legs |
                    Where-Object -FilterScript {
                        $_.Name -eq ([String]::Format("{0}->{1}",
                            $Row.Two,
                            $Row.Three
                        ))
                    } |
                    Select-Object -First 1
            )));
            [void] $RouteLegs.Add([NavSetRouteLeg]::new(3, (
                $Folders[$FolderKey].Legs |
                    Where-Object -FilterScript {
                        $_.Name -eq ([String]::Format("{0}->{1}",
                            $Row.Three,
                            $Row.Four
                        ))
                    } |
                    Select-Object -First 1
            )));
            [void] $RouteLegs.Add([NavSetRouteLeg]::new(4, (
                $Folders[$FolderKey].Legs |
                    Where-Object -FilterScript {
                        $_.Name -eq ([String]::Format("{0}->{1}",
                            $Row.Four,
                            $Row.Five
                        ))
                    } |
                    Select-Object -First 1
            )));
            [void] $RouteLegs.Add([NavSetRouteLeg]::new(5, (
                $Folders[$FolderKey].Legs |
                    Where-Object -FilterScript {
                        $_.Name -eq ([String]::Format("{0}->{1}",
                            $Row.Five,
                            $Row.One_End
                        ))
                    } |
                    Select-Object -First 1
            )));
            [void] $Folders[$FolderKey].Routes.Add([NavSetRoute]::new($RouteName, $RouteLegs));
        }
    }
    
    [Collections.ArrayList] $FormSetsAnswer = [Collections.ArrayList]::new();
    [Collections.ArrayList] $FormSetsBlank = [Collections.ArrayList]::new();
    [Int32] $RouteFormSet = 1;
    [Int32] $RouteForm = 1;
    [Int32] $RouteFormsCount = 0;
    [Collections.Hashtable] $Replacements = [Collections.Hashtable]::new();
    [String[]] $RouteNameList = @();
    If (![String]::IsNullOrEmpty($RouteNameListPath))
    {
        If ([IO.File]::Exists($RouteNameListPath))
        {
            $RouteNameList = ([IO.File]::ReadAllText($RouteNameListPath) -split "`n");
        }
    }
    ForEach ($FolderKey In $Folders.Keys)
    {
        ForEach ($Route In $Folders[$FolderKey].Routes)
        {
            $RouteFormsCount ++;
            [String] $RouteName = $null;
            If (
                ($RouteNameList.Length -gt 0) -and
                ($RouteNameList.Length -le $RouteFormsCount)
            )
            {
                $RouteName = $RouteNameList[$RouteFormsCount - 1];
            }
            If ([String]::IsNullOrEmpty($RouteName))
            {
                $RouteName = [String]::Format("{0} ({1})", $RouteFormsCount, $Route.Name.Replace("->", ""))
            }
            [void] $Replacements.Add(
                [String]::Format("[@Name_{0}]", $RouteForm),
                [String]::Format("Route {0}", $RouteName)
            );
            [void] $Replacements.Add([String]::Format("[@Format_{0}]", $RouteForm), "USNG");
            ForEach ($RouteLeg In ($Route.Legs | Sort-Object -Property Sequence))
            {
                $FromPoint = $Folders[$FolderKey].Points |
                    Where-Object -FilterScript { $_.Name -eq $RouteLeg.From} |
                        Select-Object -First 1;
                $ToPoint = $Folders[$FolderKey].Points |
                    Where-Object -FilterScript { $_.Name -eq $RouteLeg.To} |
                        Select-Object -First 1;
                If ($RouteLeg.Sequence -eq 1)
                {
                    [void] $Replacements.Add(
                        [String]::Format("[@Pos_{0}.{1}]", $RouteForm, $RouteLeg.Sequence),
                        ($FromPoint.Attributes["USNG"] | Format-USNG -AsHTML)
                    );
                }
                [void] $Replacements.Add(
                    [String]::Format("[@Pos_{0}.{1}]", $RouteForm, ($RouteLeg.Sequence + 1)),
                    ($ToPoint.Attributes["USNG"] | Format-USNG -AsHTML)
                );
                [void] $Replacements.Add(
                    [String]::Format("[@H_{0}.{1}]", $RouteForm, $RouteLeg.Sequence),
                    [String]::Format("{0}&deg;", $RouteLeg.Heading.ToString("0"))
                );
                [void] $Replacements.Add(
                    [String]::Format("[@D_{0}.{1}]", $RouteForm, $RouteLeg.Sequence),
                    [String]::Format("{0}m", $RouteLeg.Distance.ToString("0"))
                );
            }
            If ($RouteForm -lt 4)
            {
                $RouteForm ++;
            }
            Else
            {
                $RouteForm = 1;
                [String] $FormSetAnswerHTML = [IO.File]::ReadAllText($FormSetAnswerTemplatePath);
                [String] $FormSetBlankHTML = [IO.File]::ReadAllText($FormSetBlankTemplatePath);
                ForEach ($ReplacementKey In $Replacements.Keys)
                {
                    $FormSetAnswerHTML = $FormSetAnswerHTML.Replace($ReplacementKey, $Replacements[$ReplacementKey]);
                    $FormSetBlankHTML = $FormSetBlankHTML.Replace($ReplacementKey, $Replacements[$ReplacementKey]);
                }
                [void] $FormSetsAnswer.Add($FormSetAnswerHTML);
                [void] $FormSetsBlank.Add($FormSetBlankHTML);
                [void] $Replacements.Clear();
                $RouteFormSet ++;
            }
            If ($RouteFormsCount -ge $NumberOfRoutes)
            {
                Break;
            }
        }
    
        [String] $FolderName = $Folders[$FolderKey].Name;
    
        [String] $FolderOutputAnswerPath = [String]::Format($OutputAnswerPath, $FolderName);
        [String] $FolderOutputBlankPath = [String]::Format($OutputBlankPath, $FolderName);
    
        [String] $AnswerHTML = [IO.File]::ReadAllText($MainTemplatePath);
        $AnswerHTML = $AnswerHTML.Replace("[@FolderName]", $FolderName);
        $AnswerHTML = $AnswerHTML.Replace("[@Tables]", ($FormSetsAnswer -join ""));
    
        [Int32] $LastTableIndex = $AnswerHTML.LastIndexOf("<table class=`"mainTable pageBreak`">");
        $AnswerHTML = $AnswerHTML.Remove($LastTableIndex, "<table class=`"mainTable pageBreak`">".Length).Insert($LastTableIndex, "<table class=`"mainTable`">");
    
        [String] $BlankHTML = [IO.File]::ReadAllText($MainTemplatePath);
        $BlankHTML = $BlankHTML.Replace("[@FolderName]", $FolderName);
        $BlankHTML = $BlankHTML.Replace("[@Tables]", ($FormSetsBlank -join ""))
        $LastTableIndex = $AnswerHTML.LastIndexOf("<table class=`"mainTable pageBreak`">");
        $BlankHTML = $BlankHTML.Remove($LastTableIndex, "<table class=`"mainTable pageBreak`">".Length).Insert($LastTableIndex, "<table class=`"mainTable`">");
    
        [void] [IO.File]::WriteAllText($FolderOutputAnswerPath, $AnswerHTML);
        [void] [IO.File]::WriteAllText($FolderOutputBlankPath, $BlankHTML);
        $FolderOutputAnswerPath |
            Convert-HTMLToPDF -OutputPath ([IO.Path]::ChangeExtension($FolderOutputAnswerPath, "pdf"));
        $FolderOutputBlankPath |
            Convert-HTMLToPDF -OutputPath ([IO.Path]::ChangeExtension($FolderOutputBlankPath, "pdf"));
    }
}
