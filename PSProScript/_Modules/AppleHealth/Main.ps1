#[void] $Global:Session.LoadModule("Compression7Zip");
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "AppleHealth" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -TypeName "System.String" `
    -NotePropertyName "DatabaseType" `
    -NotePropertyValue "SQLServer";

. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), $Global:Session.AppleHealth.DatabaseType, "Data.ps1"));


Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -TypeName "System.String" `
    -NotePropertyName "ConnectionName" `
    -NotePropertyValue $null;

Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "DecompressExport" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [String] $ExportFilePath,
            [String] $OutputDirectoryPath
        )
        [String] $ReturnValue = $null;
        Expand-Archive `
            -Path  $ExportFilePath `
            -DestinationPath $OutputDirectoryPath;
        If ([IO.File]::Exists([IO.Path]::Combine($OutputDirectoryPath, "apple_health_export\export.xml")))
        {
            $ReturnValue = [IO.Path]::Combine($OutputDirectoryPath, "apple_health_export\export.xml");
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "ImportData" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
        )
        $Global:Session.Logging.TimedExecute("Check for New Export", {
            Try {
                $Global:Session.Variables.Set("LastHashFilePath", [IO.Path]::Combine($Global:Session.DataDirectory, "lasthash.txt"));
                $Global:Session.Variables.Set("AppleHealthExportZIPFilePath", [IO.Path]::Combine($Global:Session.DataDirectory, "export.zip"));
                [String] $LastHash = $null;
                If ([IO.File]::Exists($Global:Session.Variables.Get("LastHashFilePath")))
                {
                    $LastHash = [IO.File]::ReadAllText($Global:Session.Variables.Get("LastHashFilePath"));
                }
                [String] $CurrentHash = (Get-FileHash -Path ($Global:Session.Variables.Get("AppleHealthExportZIPFilePath"))).Hash;
                If ($LastHash -ne $CurrentHash)
                {
                    [IO.File]::WriteAllText($Global:Session.Variables.Get("LastHashFilePath"), $CurrentHash);
                    $Global:Session.Variables.Set("ExportIsNew", $true);
                }
                Else
                {
                    $Global:Session.Variables.Set("ExportIsNew", $false);
                }
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });
        
        $Global:Session.Logging.TimedExecute("Extract if New", {
            Try {
                If ($Global:Session.Variables.Get("ExportIsNew"))
                {
                    $Global:Session.Variables.Set(
                        "ExportDirectoryPath",
                        [IO.Path]::Combine($Global:Session.DataDirectory, [String]::Format("export_{0}", [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")))
                    );
                    [String] $AppleHealthExportXMLFilePath = $Global:Session.AppleHealth.DecompressExport(
                        $Global:Session.Variables.Get("AppleHealthExportZIPFilePath"),
                        $Global:Session.Variables.Get("ExportDirectoryPath")
                    );
                    If (![String]::IsNullOrEmpty($AppleHealthExportXMLFilePath))
                    {
                        $Global:Session.Variables.Set("AppleHealthExportXMLFilePath", $AppleHealthExportXMLFilePath);
                        $Global:Session.Variables.Set("IsExtracted", $true);
                    }
                    Else
                    {
                        $Global:Session.Variables.Set("IsExtracted", $false);
                    }
                }
                Else
                {
                    $Global:Session.Logging.WriteEntry("Information", "export.zip is not new.");
                }
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });
        
        $Global:Session.Logging.TimedExecute("Import XML Data", {
            Try {
                [void] $Global:Session.AppleHealth.Data.ImportXML();
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "GetYearlyStatistics" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Int32] $Year
        )
        Return $Global:Session.AppleHealth.Data.GetYearlyStatistics($Year);
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "BuildLegendImage" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([System.Windows.Forms.DataVisualization.Charting.Series])]
        Param
        (
            [System.Drawing.Color] $Color,
            [String] $Text,
            [String] $FilePath
        )
        [Int32] $Width = 500;
        [Int32] $Height = 20;
        [System.Drawing.Bitmap] $BitmapTemplate = [System.Drawing.Bitmap]::new($Width, $Height);
        [System.Drawing.Graphics] $GraphicsTemplate = [System.Drawing.Graphics]::FromImage($BitmapTemplate);
        [System.Drawing.Font] $LegendFont = [System.Drawing.Font]::new("Courier New", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel);
        [void] $GraphicsTemplate.DrawLine([System.Drawing.Pen]::new($Color, 3), [System.Drawing.Point]::new(0, 9), [System.Drawing.Point]::new(15, 9));
        [void] $GraphicsTemplate.DrawString($Text, $LegendFont, [System.Drawing.SolidBrush]::new($Color), 20, 1);
        $Width = (20 + $GraphicsTemplate.MeasureString($Text, $LegendFont).Width);
        [System.Drawing.Bitmap] $Bitmap = [System.Drawing.Bitmap]::new($Width, $Height);
        [System.Drawing.Graphics] $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap);
        [void] $Graphics.DrawImageUnscaled($BitmapTemplate, 0, 0, $Width, $Height);
        [void] $Bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png);
        [void] $GraphicsTemplate.Dispose();
        [void] $BitmapTemplate.Dispose();
        [void] $Graphics.Dispose();
        [void] $Bitmap.Dispose();
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "BuildChartSeries" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([System.Windows.Forms.DataVisualization.Charting.Series])]
        Param
        (
            [String] $ChartAreaName,
            [String] $SeriesName,
            [Collections.Generic.List[PSObject]] $Values,
            [System.Drawing.Color] $Color
        )
        [System.Windows.Forms.DataVisualization.Charting.Series] $ReturnValue = [System.Windows.Forms.DataVisualization.Charting.Series]::new();
        $ReturnValue.LegendText = $SeriesName;
        $ReturnValue.MarkerStyle = [System.Windows.Forms.DataVisualization.Charting.MarkerStyle]::None;
        $ReturnValue.XValueType = [System.Windows.Forms.DataVisualization.Charting.ChartValueType]::Date;
        $ReturnValue.YAxisType = [System.Windows.Forms.DataVisualization.Charting.ChartValueType]::Double;
        $ReturnValue.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
        $ReturnValue.Color = $Color;
        $ReturnValue.ChartArea = $ChartAreaName;
        [void] $ReturnValue.Points.Clear();
        ForEach ($Value In $Values)
        {
            [void] $ReturnValue.Points.AddXY([DateTime]$Value.XValue, [Double]$Value.YValue);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "BuildYearChart" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [String] $Name,
            [Int32] $Year,
            [Collections.ArrayList] $SeriesCollection,
            [String] $OutputFilePath
        )
        [System.Windows.Forms.DataVisualization.Charting.Chart] $Chart = [System.Windows.Forms.DataVisualization.Charting.Chart]::new();
        [System.Windows.Forms.DataVisualization.Charting.ChartArea] $ChartArea = [System.Windows.Forms.DataVisualization.Charting.ChartArea]::new();
        [void] $Chart.ChartAreas.Clear();
        $ChartArea.Name = $Name;
        $ChartArea.AxisX.IntervalType = [System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType]::Months;
        $ChartArea.AxisX.Interval = 1;
        $ChartArea.AxisX.LabelStyle.Format = "yyyy-MM-dd";
        $ChartArea.AxisX.IsMarginVisible = $false;
        $ChartArea.AxisX.Minimum = ([DateTime]"$Year-01-01").ToOADate();
        $ChartArea.AxisX.Maximum = ([DateTime]"$Year-12-31").ToOADate();
        $ChartArea.AxisY.Title = $Name;
        $ChartArea.AxisY.IsStartedFromZero = $false;
        $ChartArea.AxisY.Interval = 10;
        $ChartArea.AxisY.LabelStyle.Interval = 10;
        $ChartArea.AxisY.MajorGrid.Interval = 10;
        $ChartArea.AxisY.TextOrientation = [System.Windows.Forms.DataVisualization.Charting.TextOrientation]::Rotated270;
        $ChartArea.AxisY.IntervalType = [System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType]::Number;
        [void] $Chart.ChartAreas.Add($ChartArea);
        [void] $Chart.Series.Clear();
        ForEach ($Series In $SeriesCollection)
        {
            [void] $Chart.Series.Add($Global:Session.AppleHealth.BuildChartSeries(
                $ChartArea.Name,
                $Series.Name,
                $Series.Values,
                $Series.Color
            ));
        }
        $Chart.Size = [System.Drawing.Size]::new(800, 200);
        $Chart.BorderColor = [System.Drawing.Color]::FromArgb(255, 0, 0, 0);
        $Chart.BorderDashStyle = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Solid;
        $Chart.BorderWidth = 2;
        [void] $Chart.SaveImage($OutputFilePath, [System.Windows.Forms.DataVisualization.Charting.ChartImageFormat]::Png);
    }

Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "BuildRestingHeartRateChart" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Int32] $Year,
            [PSCustomObject] $Values,
            [Collections.Hashtable] $SeriesColors,
            [String] $OutputPath
        )
        [System.Windows.Forms.DataVisualization.Charting.Chart] $Chart = [System.Windows.Forms.DataVisualization.Charting.Chart]::new();
        [System.Windows.Forms.DataVisualization.Charting.ChartArea] $ChartArea = [System.Windows.Forms.DataVisualization.Charting.ChartArea]::new();
        [void] $Chart.ChartAreas.Clear();
        $ChartArea.Name = "Resting Heart Rate";
        $ChartArea.AxisX.IntervalType = [System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType]::Months;
        $ChartArea.AxisX.Interval = 1;
        $ChartArea.AxisX.LabelStyle.Format = "yyyy-MM-dd";
        $ChartArea.AxisX.IsMarginVisible = $false;
        $ChartArea.AxisX.Minimum = ([DateTime]"$Year-01-01").ToOADate();
        $ChartArea.AxisX.Maximum = ([DateTime]"$Year-12-31").ToOADate();
        $ChartArea.AxisY.Title = "Resting Heart Rate"
        $ChartArea.AxisY.IsStartedFromZero = $false;
        $ChartArea.AxisY.Interval = 10;
        $ChartArea.AxisY.LabelStyle.Interval = 10;
        $ChartArea.AxisY.MajorGrid.Interval = 10;
        $ChartArea.AxisY.TextOrientation = [System.Windows.Forms.DataVisualization.Charting.TextOrientation]::Rotated270;
        $ChartArea.AxisY.IntervalType = [System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType]::Number;
        [void] $Chart.ChartAreas.Add($ChartArea);

        [void] $Chart.Series.Clear();

        [void] $Chart.Series.Add($Global:Session.AppleHealth.BuildChartSeries($ChartArea.Name, "Resting Heart Rate",
            ($Values |
                Select-Object -Property @(
                    @{ "label" = "XValue"; "expression" = {$_.Date}},
                    @{ "label" = "YValue"; "expression" = {$_.RestingHeartRate}}
            )),
            $SeriesColors["Resting Heart Rate"]));

        $Chart.Size = [System.Drawing.Size]::new(800, 200);
        $Chart.BorderColor = [System.Drawing.Color]::FromArgb(255, 0, 0, 0);
        $Chart.BorderDashStyle = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Solid;
        $Chart.BorderWidth = 2;
        
        [void] $Chart.SaveImage($OutputPath, [System.Windows.Forms.DataVisualization.Charting.ChartImageFormat]::Png);
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -Name "CreateYearlyStatisticsFile" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Int32] $Year,
            [String] $OutputDirectory
        )
        [void] $Global:Session.Variables.Set("YearlyStatistics_Year", $Year);
        $Global:Session.Logging.TimedExecute("Get Yearly Statistics", {
            Try {
                [void] $Global:Session.Variables.Set("YearlyStatistics", $Global:Session.AppleHealth.GetYearlyStatistics($Global:Session.Variables.Get("YearlyStatistics_Year")));
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Weight Badges", {
            Try {
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [Collections.Hashtable] $YearlyStatistics_WeightBadgeFilePaths = [Collections.Hashtable]::new();
                ForEach ($Aggregate In $YearlyStatistics.Weight.Aggregates)
                {
                    [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}WeightBadge.svg", $Year, $Aggregate.Aggregation));
                    $Message = [String]::Format("{0} ({1})", $Aggregate.Weight, $Aggregate.Date);
                    [void] $YearlyStatistics_WeightBadgeFilePaths.Add($Aggregate.Aggregation, $FilePath);
                    [void] $Global:Session.ShieldsIO.Download($Aggregate.Aggregation, $Message, "blue", $FilePath);
                }
                [void] $Global:Session.Variables.Set("YearlyStatistics_WeightBadgeFilePaths", $YearlyStatistics_WeightBadgeFilePaths);
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Weight Chart", {
            Try {
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Collections.Generic.List[PSObject]] $SeriesCollection = [Collections.Generic.List[PSObject]]::new();
                [PSObject] $WeightSeries = [PSObject]::new();
                Add-Member -InputObject $WeightSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Weight";
                Add-Member -InputObject $WeightSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 0, 255));
                Add-Member -InputObject $WeightSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.Weight.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.Weight}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$WeightSeries);
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\WeightChart.png", $Year));
                [void] $Global:Session.Variables.Set("YearlyStatistics_WeightChartFilePath", $FilePath);
                [void] $Global:Session.AppleHealth.BuildYearChart(
                    "Weight",
                    $Year,
                    $SeriesCollection,
                    $FilePath);
                ForEach ($Series In $SeriesCollection)
                {
                    [String] $LegendFilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}Legend.png", $Year, $Series.Name.Replace(" ", "")));
                    [void] $Global:Session.Variables.Set(
                        [String]::Format("YearlyStatistics_{0}LegendFilePath", $Series.Name.Replace(" ", "")),
                        $LegendFilePath);
                    $Global:Session.AppleHealth.BuildLegendImage(
                        $Series.Color,
                        $Series.Name,
                        $LegendFilePath
                    );
                }
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Blood Pressure Badges", {
            Try {
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [Collections.Hashtable] $YearlyStatistics_BloodPressureBadgeFilePaths = [Collections.Hashtable]::new();
                ForEach ($Aggregate In $YearlyStatistics.BloodPressure.Aggregates)
                {
                    [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}BloodPressureBadge.svg", $Year, $Aggregate.Aggregation));
                    $Message = [String]::Format("{0}/{1}, {2} ({3})", $Aggregate.Systolic, $Aggregate.Diastolic, $Aggregate.MeanArterialPressure, $Aggregate.Date);
                    [void] $YearlyStatistics_BloodPressureBadgeFilePaths.Add($Aggregate.Aggregation, $FilePath);
                    [void] $Global:Session.ShieldsIO.Download($Aggregate.Aggregation, $Message, "blue", $FilePath);
                }
                [void] $Global:Session.Variables.Set("YearlyStatistics_BloodPressureBadgeFilePaths", $YearlyStatistics_BloodPressureBadgeFilePaths);
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Blood Pressure Chart", {
            Try {

                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Collections.Generic.List[PSObject]] $SeriesCollection = [Collections.Generic.List[PSObject]]::new();

                [PSObject] $SystolicSeries = [PSObject]::new();
                Add-Member -InputObject $SystolicSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Systolic";
                Add-Member -InputObject $SystolicSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 0, 255));
                Add-Member -InputObject $SystolicSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.BloodPressure.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.Systolic}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$SystolicSeries);

                [PSObject] $DiastolicSeries = [PSObject]::new();
                Add-Member -InputObject $DiastolicSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Diastolic";
                Add-Member -InputObject $DiastolicSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 255, 0));
                Add-Member -InputObject $DiastolicSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.BloodPressure.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.Diastolic}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$DiastolicSeries);

                [PSObject] $MeanArterialPressureSeries = [PSObject]::new();
                Add-Member -InputObject $MeanArterialPressureSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Mean Arterial Pressure";
                Add-Member -InputObject $MeanArterialPressureSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 255, 0, 0));
                Add-Member -InputObject $MeanArterialPressureSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.BloodPressure.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.MeanArterialPressure}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$MeanArterialPressureSeries);

                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\BloodPressureChart.png", $Year));
                [void] $Global:Session.Variables.Set("YearlyStatistics_BloodPressureChartFilePath", $FilePath);
                [void] $Global:Session.AppleHealth.BuildYearChart(
                    "Blood Pressure",
                    $Year,
                    $SeriesCollection,
                    $FilePath);
                ForEach ($Series In $SeriesCollection)
                {
                    [String] $LegendFilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}Legend.png", $Year, $Series.Name.Replace(" ", "")));
                    [void] $Global:Session.Variables.Set(
                        [String]::Format("YearlyStatistics_{0}LegendFilePath", $Series.Name.Replace(" ", "")),
                        $LegendFilePath);
                    $Global:Session.AppleHealth.BuildLegendImage(
                        $Series.Color,
                        $Series.Name,
                        $LegendFilePath
                    );
                }
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Resting Heart Rate Badges", {
            Try {
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [Collections.Hashtable] $YearlyStatistics_RestingHeartRateBadgeFilePaths = [Collections.Hashtable]::new();
                ForEach ($Aggregate In $YearlyStatistics.RestingHeartRate.Aggregates)
                {
                    [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}RestingHeartRateBadge.svg", $Year, $Aggregate.Aggregation));
                    $Message = [String]::Format("{0} ({1})", $Aggregate.RestingHeartRate, $Aggregate.Date);
                    [void] $YearlyStatistics_RestingHeartRateBadgeFilePaths.Add($Aggregate.Aggregation, $FilePath);
                    [void] $Global:Session.ShieldsIO.Download($Aggregate.Aggregation, $Message, "blue", $FilePath);
                }
                [void] $Global:Session.Variables.Set("YearlyStatistics_RestingHeartRateBadgeFilePaths", $YearlyStatistics_RestingHeartRateBadgeFilePaths);
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Resting Heart Rate Chart", {
            Try {
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Collections.Generic.List[PSObject]] $SeriesCollection = [Collections.Generic.List[PSObject]]::new();
                [PSObject] $RestingHeartRateSeries = [PSObject]::new();
                Add-Member -InputObject $RestingHeartRateSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Resting Heart Rate";
                Add-Member -InputObject $RestingHeartRateSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 0, 255));
                Add-Member -InputObject $RestingHeartRateSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.RestingHeartRate.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.RestingHeartRate}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$RestingHeartRateSeries);
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\RestingHeartRateChart.png", $Year));
                [void] $Global:Session.Variables.Set("YearlyStatistics_RestingHeartRateChartFilePath", $FilePath);
                [void] $Global:Session.AppleHealth.BuildYearChart(
                    "Resting Heart Rate",
                    $Year,
                    $SeriesCollection,
                    $FilePath);
                ForEach ($Series In $SeriesCollection)
                {
                    [String] $LegendFilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}Legend.png", $Year, $Series.Name.Replace(" ", "")));
                    [void] $Global:Session.Variables.Set(
                        [String]::Format("YearlyStatistics_{0}LegendFilePath", $Series.Name.Replace(" ", "")),
                        $LegendFilePath);
                    $Global:Session.AppleHealth.BuildLegendImage(
                        $Series.Color,
                        $Series.Name,
                        $LegendFilePath
                    );
                }


<#
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\RestingHeartRateChart.png", $Year));
                [void] $Global:Session.Variables.Set("YearlyStatistics_RestingHeartRateChartFilePath", $FilePath);
                [Collections.Hashtable] $SeriesColors = @{ "Resting Heart Rate" = [System.Drawing.Color]::FromArgb(255, 0, 0, 255); }
                [void] $Global:Session.AppleHealth.BuildRestingHeartRateChart(
                    $Year,
                    $YearlyStatistics.RestingHeartRate.Values,
                    $SeriesColors,
                    $FilePath);
                ForEach ($SeriesColorKey In $SeriesColors.Keys)
                {
                    [String] $LegendFilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}Legend.png", $Year, $SeriesColorKey.Replace(" ", "")));
                    [void] $Global:Session.Variables.Set(
                        [String]::Format("YearlyStatistics_{0}LegendFilePath", $SeriesColorKey.Replace(" ", "")),
                        $LegendFilePath);
                    $Global:Session.AppleHealth.BuildLegendImage(
                        $SeriesColors[$SeriesColorKey],
                        $SeriesColorKey,
                        $LegendFilePath
                    );
                }
#>
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Energy Burned Badges", {
            Try {
                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [Collections.Hashtable] $YearlyStatistics_EnergyBurnedBadgeFilePaths = [Collections.Hashtable]::new();
                ForEach ($Aggregate In $YearlyStatistics.EnergyBurned.Aggregates)
                {
                    [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}EnergyBurnedBadge.svg", $Year, $Aggregate.Aggregation));
                    $Message = [String]::Format("{0}/{1}, ({2})", $Aggregate.BasalEnergyBurned, $Aggregate.ActiveEnergyBurned, $Aggregate.Date);
                    [void] $YearlyStatistics_EnergyBurnedBadgeFilePaths.Add($Aggregate.Aggregation, $FilePath);
                    [void] $Global:Session.ShieldsIO.Download($Aggregate.Aggregation, $Message, "blue", $FilePath);
                }
                [void] $Global:Session.Variables.Set("YearlyStatistics_EnergyBurnedBadgeFilePaths", $YearlyStatistics_EnergyBurnedBadgeFilePaths);
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Build Energy Burned Chart", {
            Try {

                $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");
                [Collections.Generic.List[PSObject]] $SeriesCollection = [Collections.Generic.List[PSObject]]::new();

                [PSObject] $BasalEnergyBurnedSeries = [PSObject]::new();
                Add-Member -InputObject $BasalEnergyBurnedSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Basal";
                Add-Member -InputObject $BasalEnergyBurnedSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 0, 255));
                Add-Member -InputObject $BasalEnergyBurnedSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.EnergyBurned.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.BasalEnergyBurned}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$BasalEnergyBurnedSeries);

                [PSObject] $ActiveEnergyBurnedSeries = [PSObject]::new();
                Add-Member -InputObject $ActiveEnergyBurnedSeries -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Active";
                Add-Member -InputObject $ActiveEnergyBurnedSeries -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 255, 0));
                Add-Member -InputObject $ActiveEnergyBurnedSeries -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue (
                    $YearlyStatistics.EnergyBurned.Values |
                    Select-Object -Property @(
                        @{ "label" = "XValue"; "expression" = {$_.Date}},
                        @{ "label" = "YValue"; "expression" = {$_.ActiveEnergyBurned}}
                    )
                );
                [void] $SeriesCollection.Add([PSObject]$ActiveEnergyBurnedSeries);

                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\EnergyBurnedChart.png", $Year));
                [void] $Global:Session.Variables.Set("YearlyStatistics_EnergyBurnedChartFilePath", $FilePath);
                [void] $Global:Session.AppleHealth.BuildYearChart(
                    "Energy Burned",
                    $Year,
                    $SeriesCollection,
                    $FilePath);
                ForEach ($Series In $SeriesCollection)
                {
                    [String] $LegendFilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats\{1}Legend.png", $Year, $Series.Name.Replace(" ", "")));
                    [void] $Global:Session.Variables.Set(
                        [String]::Format("YearlyStatistics_{0}LegendFilePath", $Series.Name.Replace(" ", "")),
                        $LegendFilePath);
                    $Global:Session.AppleHealth.BuildLegendImage(
                        $Series.Color,
                        $Series.Name,
                        $LegendFilePath
                    );
                }
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });

        $Global:Session.Logging.TimedExecute("Create Yearly Statistics Markdown File", {
            Try {
                [Int32] $Year = $Global:Session.Variables.Get("YearlyStatistics_Year");
                [String] $FilePath = [IO.Path]::Combine($OutputDirectory, [String]::Format("{0}_YearlyStats.md", $Year));
                [void] $Global:Session.Variables.Set("YearlyStatistics_MarkdownFilePath", $FilePath);

                [System.Text.StringBuilder] $StringBuilder = [System.Text.StringBuilder]::new();
                [void] $StringBuilder.AppendFormat("# {0} Statistics`n`n", $Year);

                [void] $StringBuilder.Append("### Weight (lbs)`n");
                [Collections.Hashtable] $YearlyStatistics_WeightBadgeFilePaths = $Global:Session.Variables.Get("YearlyStatistics_WeightBadgeFilePaths");
                [String] $WeightBadgeLine = [String]::Empty;
                ForEach ($BadgeFileKey In $YearlyStatistics_WeightBadgeFilePaths.Keys)
                {
                    $WeightBadgeLine += [String]::Format("![{1}]({0}_YearlyStats/{1}WeightBadge.svg) ", $Year, $BadgeFileKey);
                }
                [void] $StringBuilder.AppendFormat("{0}`n`n", $WeightBadgeLine.Trim());
                [void] $StringBuilder.AppendFormat("![WeightLegend]({0}_YearlyStats/WeightLegend.png)  `n", $Year);
                [void] $StringBuilder.AppendFormat("![WeightChart]({0}_YearlyStats/WeightChart.png)`n`n", $Year);

                [void] $StringBuilder.Append("### Blood Pressure (mmHg)`n");
                [Collections.Hashtable] $YearlyStatistics_BloodPressureBadgeFilePaths = $Global:Session.Variables.Get("YearlyStatistics_BloodPressureBadgeFilePaths");
                [String] $BloodPressureBadgeLine = [String]::Empty;
                ForEach ($BadgeFileKey In $YearlyStatistics_BloodPressureBadgeFilePaths.Keys)
                {
                    $BloodPressureBadgeLine += [String]::Format("![{1}BloodPressure]({0}_YearlyStats/{1}BloodPressureBadge.svg) ", $Year, $BadgeFileKey);
                }
                [void] $StringBuilder.AppendFormat("{0}`n`n", $BloodPressureBadgeLine.Trim());
                [void] $StringBuilder.AppendFormat("![SystolicLegend]({0}_YearlyStats/SystolicLegend.png) ![DiastolicLegend]({0}_YearlyStats/DiastolicLegend.png) ![MeanArterialPressureLegend]({0}_YearlyStats/MeanArterialPressureLegend.png)  `n", $Year);
                [void] $StringBuilder.AppendFormat("![BloodPressureChart]({0}_YearlyStats/BloodPressureChart.png)`n`n", $Year);

                [void] $StringBuilder.Append("### RestingHeartRate (beats/min)`n");
                [Collections.Hashtable] $YearlyStatistics_RestingHeartRateBadgeFilePaths = $Global:Session.Variables.Get("YearlyStatistics_RestingHeartRateBadgeFilePaths");
                [String] $RestingHeartRateBadgeLine = [String]::Empty;
                ForEach ($BadgeFileKey In $YearlyStatistics_RestingHeartRateBadgeFilePaths.Keys)
                {
                    $RestingHeartRateBadgeLine += [String]::Format("![{1}RestingHeartRate]({0}_YearlyStats/{1}RestingHeartRateBadge.svg) ", $Year, $BadgeFileKey);
                }
                [void] $StringBuilder.AppendFormat("{0}`n`n", $RestingHeartRateBadgeLine.Trim());
                [void] $StringBuilder.AppendFormat("![RestingHeartRateLegend]({0}_YearlyStats/RestingHeartRateLegend.png)  `n", $Year);
                [void] $StringBuilder.AppendFormat("![RestingHeartRateChart]({0}_YearlyStats/RestingHeartRateChart.png)`n`n", $Year);

                [void] $StringBuilder.Append("### Energy Burned (Calories)`n");
                [Collections.Hashtable] $YearlyStatistics_EnergyBurnedBadgeFilePaths = $Global:Session.Variables.Get("YearlyStatistics_EnergyBurnedBadgeFilePaths");
                [String] $EnergyBurnedBadgeLine = [String]::Empty;
                ForEach ($BadgeFileKey In $YearlyStatistics_EnergyBurnedBadgeFilePaths.Keys)
                {
                    $EnergyBurnedBadgeLine += [String]::Format("![{1}EnergyBurned]({0}_YearlyStats/{1}EnergyBurnedBadge.svg) ", $Year, $BadgeFileKey);
                }
                [void] $StringBuilder.AppendFormat("{0}`n`n", $EnergyBurnedBadgeLine.Trim());
                [void] $StringBuilder.AppendFormat("![BasalLegend]({0}_YearlyStats/BasalLegend.png) ![ActiveLegend]({0}_YearlyStats/ActiveLegend.png)  `n", $Year);
                [void] $StringBuilder.AppendFormat("![EnergyBurnedChart]({0}_YearlyStats/EnergyBurnedChart.png)`n`n", $Year);

                [void] [IO.File]::WriteAllText($FilePath, $StringBuilder.ToString());
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });
    }
