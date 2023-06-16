[void] $Global:Session.LoadModule("Connections");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "InformaticaAPI" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$true)]
            [String] $V3LoginURI,
    
            [Parameter(Mandatory=$true)]
            [String] $V2LoginURI,
    
            [Parameter(Mandatory=$true)]
            [String] $UserName,
    
            [Parameter(Mandatory=$false)]
            [String] $Password,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted
        )
        $Global:Session.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "V3LoginURI" = $V3LoginURI;
                "V2LoginURI" = $V2LoginURI;
                "UserName" = $UserName;
                "Password" = $Password;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        Return $Global:Session.Connections.Get($Name);
    };
Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "GetSession" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [PSCustomObject] $Connection = $Global:Session.Connections.Get($ConnectionName)
        If (-not $Global:Session.InformaticaAPI.Session)
        {
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI `
                -TypeName "System.Management.Automation.PSObject" `
                -NotePropertyName "Session" `
                -NotePropertyValue ([System.Management.Automation.PSObject]::new());
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session `
                -TypeName "System.Management.Automation.PSObject" `
                -NotePropertyName "V3" `
                -NotePropertyValue ([System.Management.Automation.PSObject]::new());
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session.V3 `
                -TypeName "System.String" `
                -NotePropertyName "LoginURL" `
                -NotePropertyValue $Connection.V3LoginURI;
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session.V3 `
                -TypeName "System.String" `
                -NotePropertyName "APIURL" `
                -NotePropertyValue $null;
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session.V3 `
                -TypeName "System.Collections.Hashtable" `
                -NotePropertyName "Headers" `
                -NotePropertyValue @{
                    "Content-Type" = "application/json";
                    "Accept" = "application/json";
                };
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session `
                -TypeName "System.Management.Automation.PSObject" `
                -NotePropertyName "V2" `
                -NotePropertyValue ([System.Management.Automation.PSObject]::new());
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session.V2 `
                -TypeName "System.String" `
                -NotePropertyName "LoginURL" `
                -NotePropertyValue $Connection.V2LoginURI;
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session.V2 `
                -TypeName "System.String" `
                -NotePropertyName "APIURL" `
                -NotePropertyValue $null;
            Add-Member `
                -InputObject $Global:Session.InformaticaAPI.Session.V2 `
                -TypeName "System.Collections.Hashtable" `
                -NotePropertyName "Headers" `
                -NotePropertyValue @{
                    "Content-Type" = "application/json";
                    "Accept" = "application/json";
                };
        }
        $PreviousProgressPreference = $global:ProgressPreference;
        $global:ProgressPreference = "SilentlyContinue";
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $V3LoginResponse = (
            (
                Invoke-WebRequest `
                    -Uri $Global:Session.InformaticaAPI.Session.V3.LoginURL `
                    -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                    -Method Post `
                    -Body (
                            ConvertTo-Json `
                                -InputObject @{
                                    "username" = $Connection.UserName;
                                    "password" = $Connection.Password;
                                } `
                                -Depth 100
                    )            
            ).Content |
                ConvertFrom-Json -Depth 100
        );
        $Global:Session.InformaticaAPI.Session.V3.APIURL = $V3LoginResponse.products[0].BaseAPIURL;
        [void] $Global:Session.InformaticaAPI.Session.V3.Headers.Add("INFA-SESSION-ID", $V3LoginResponse.userInfo.sessionId);
    
        $V2LoginResponse = (
            (
                Invoke-WebRequest `
                    -Uri $Global:Session.InformaticaAPI.Session.V2.LoginURL `
                    -Headers $Global:Session.InformaticaAPI.Session.V2.Headers `
                    -Method Post `
                    -Body (
                            ConvertTo-Json `
                                -InputObject @{
                                    "@type" = "login";
                                    "username" = $APIConnection.UserName;
                                    "password" = $APIConnection.Password;
                                } `
                                -Depth 100
                    )
                ).Content |
                    ConvertFrom-Json -Depth 100
        );
        $Global:Session.InformaticaAPI.Session.V2.APIURL = $V2LoginResponse.serverUrl;
        [void] $Global:Session.InformaticaAPI.Session.V2.Headers.Add("icSessionId", $V2LoginResponse.icSessionId);
    
        $global:ProgressPreference = $PreviousProgressPreference;
    };
#endregion Connection Methods

Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "GetAssets" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[String]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Project
        )
        $PreviousProgressPreference = $global:ProgressPreference;
        $global:ProgressPreference = "SilentlyContinue";
        [Collections.Generic.List[String]] $ReturnValue = [Collections.Generic.List[String]]::new();
        [Boolean] $ContinueAssetRetrieval = $true;
        [Int32] $AssetSkip = 0;
        While ($ContinueAssetRetrieval)
        {
            $ObjectResponse = (
                (
                    Invoke-WebRequest `
                        -Uri ([String]::Format("{0}/public/core/v3/objects?limit=100&skip={1}&q=location=='{2}'",
                            $Global:Session.InformaticaAPI.Session.V3.APIURL,
                            $AssetSkip,
                            $Project
                        )) `
                        -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                        -Method Get
                ).Content |
                    ConvertFrom-Json -Depth 100
            );
            If ($ObjectResponse.objects.Count -gt 0)
            {
                ForEach ($Asset In $ObjectResponse.objects)
                {
                    If (!$ReturnValue.Contains($Asset.id))
                    {
                        [void] $ReturnValue.Add($Asset.id);
                    }
                }
                $AssetSkip += 100;
                $ContinueAssetRetrieval = $true;
            }
            Else
            {
                $ContinueAssetRetrieval = $false;
            }
        }
    
        $global:ProgressPreference = $PreviousProgressPreference;
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "ExportAssets" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$false)]
            [Collections.Generic.List[String]] $Assets,
    
            [Parameter(Mandatory=$false)]
            [String] $OutputDirectoryPath,
    
            [Parameter(Mandatory=$false)]
            [Boolean] $IncludeConnections,
    
            [Parameter(Mandatory=$false)]
            [Boolean] $IncludeSchedules
        )
        $PreviousProgressPreference = $global:ProgressPreference;
        $global:ProgressPreference = "SilentlyContinue";
        [PSObject] $ReturnValue = [PSObject]@{
            "Assets" = [Collections.Generic.List[PSObject]]::new();
            "AssetFiles" = [Collections.Generic.List[PSObject]]::new();
        };
    
        [String] $TempExportDirectory = [IO.Path]::Combine([IO.Path]::GetTempPath(), [Guid]::NewGuid().ToString("N"));
        If ([IO.Directory]::Exists($TempExportDirectory))
        {
            [void] [IO.Directory]::Delete($TempExportDirectory);
        }
        [void] [IO.Directory]::CreateDirectory($TempExportDirectory);
        If (![IO.Directory]::Exists($OutputDirectoryPath))
        {
            [void] [IO.Directory]::CreateDirectory($OutputDirectoryPath);
        }
        Get-ChildItem -Path $OutputDirectoryPath -Recurse |
            ForEach-Object -Process {Remove-item -Recurse -Path $_.FullName };

        If ($Assets.Count -gt 0)
        {
            [Collections.Generic.List[PSObject]] $ExportBatches = [Collections.Generic.List[PSObject]]::new();
            [Int32] $ObjecthNumber = 0;
            [Int32] $BatchNumber = 1;
            [System.Collections.Hashtable] $Batch = @{
                "BatchNumber" = $BatchNumber;
                "Body" = @{
                    "name" = ([Guid]::NewGuid());
                    "objects" = [Collections.Generic.List[PSObject]]::new();
                };
                "ExportId" = $null;
                "Status" = $null;
            };
        
            ForEach ($Asset In $Assets)
            {
                If ($ObjecthNumber -eq $ExportBatchSize)
                {
                    [void] $ExportBatches.Add($Batch);
                    $BatchNumber ++;
                    [System.Collections.Hashtable] $Batch = @{
                        "BatchNumber" = $BatchNumber;
                        "Body" = @{
                            "name" = ([Guid]::NewGuid());
                            "objects" = [Collections.Generic.List[PSObject]]::new();
                        };
                        "ExportId" = $null;
                        "Status" = $null;
                    };
                    $ObjecthNumber = 0;    
                }
                $ObjecthNumber ++;
                [void] $Batch.Body.objects.Add(@{
                    "id" = $Asset;
                    "includeDependencies" = $false;
        
                });
            }
            [void] $ExportBatches.Add($Batch);
        }

        ForEach ($ExportBatch In $ExportBatches)
        {
            [System.String] $ExportBody =  $ExportBatch.Body |
                ConvertTo-Json -Depth 100;
            $ExportResponse = (
                (
                    Invoke-WebRequest `
                        -Uri ([String]::Format("{0}/public/core/v3/export", $Global:Session.InformaticaAPI.Session.V3.APIURL)) `
                        -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                        -Body $ExportBody `
                        -Method Post
                ).Content |
                    ConvertFrom-Json -Depth 100
            );
            $ExportBatch.ExportId = $ExportResponse.id;
            $ExportBatch.Status = $ExportResponse.status.state;
        }
    
        While (($ExportBatches | Where-Object -FilterScript { $_.Status -ne "SUCCESSFUL" }).Count -gt 0)
        {
            ForEach ($ExportBatch In ($ExportBatches | Where-Object -FilterScript { $_.Status -ne "SUCCESSFUL" }))
            {
                $ExportStatusResponse = (
                    (
                        Invoke-WebRequest `
                            -Uri ([String]::Format(
                                "{0}/public/core/v3/export/{1}",
                                $Global:Session.InformaticaAPI.Session.V3.APIURL,
                                $ExportBatch.ExportId
                            )) `
                            -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                            -Body $ExportBody `
                            -Method Get
                    ).Content |
                        ConvertFrom-Json -Depth 100
                );
                $ExportBatch.Status = $ExportStatusResponse.status.state;
            }
            Start-Sleep -Seconds 3;
        }
       
        ForEach ($ExportBatch In $ExportBatches)
        {
            [void] $ExportBatch.Add("DownloadPath", ([IO.Path]::Combine($TempExportDirectory, ($ExportBatch.ExportId + ".zip"))));
            [void] $ExportBatch.Add("ExtractPath", ([IO.Path]::Combine($TempExportDirectory, $ExportBatch.ExportId)));
            [void] $ExportBatch.Add("ExtractDirectoryPath", ([IO.Path]::Combine($OutputDirectoryPath, $ExportBatch.ExportId)));
            Invoke-WebRequest `
                -Uri ([String]::Format(
                    "{0}/public/core/v3/export/{1}/package",
                    $Global:Session.InformaticaAPI.Session.V3.APIURL,
                    $ExportBatch.ExportId
                )) `
                -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                -Method Get `
                -OutFile $ExportBatch.DownloadPath;
            Expand-Archive `
                -Path  $ExportBatch.DownloadPath `
                -DestinationPath $ExportBatch.ExtractPath;
            [IO.Directory]::Move($ExportBatch.ExtractPath, $ExportBatch.ExtractDirectoryPath);
            [void] [IO.File]::Delete($ExportBatch.DownloadPath);
        }
    
        If ([IO.Directory]::Exists($TempExportDirectory))
        {
            [void] [IO.Directory]::Delete($TempExportDirectory);
        }
    
        ForEach ($ExportBatch In $ExportBatches)
        {
            [void] $ExportBatch.Add("ContentCSVPath", [IO.Path]::Combine($ExportBatch.ExtractDirectoryPath, [String]::Format("ContentsofExportPackage_{0}.csv", $ExportBatch.Body.name)));
            [void] $ExportBatch.Add("ExportMetadataPath", [IO.Path]::Combine($ExportBatch.ExtractDirectoryPath, "exportMetadata.v2.json"));
            If ([IO.File]::Exists($ExportBatch.ExportMetadataPath))
            {
                [void] $ReturnValue.Assets.Add(@{
                    "Path" = "System";
                    "Name" = "ExportMetadata";
                    "Type" = "ExportMetadata";
                    "FederatedId" = $ExportBatch.ExportId;
                    "ZIPFilePath" = $null;
                    "ZIPFileExists" = $null;
                    "ExtractDirectoryPath" = $null;
                    "Files" = @( [IO.Path]::GetFileName($ExportBatch.ExportMetadataPath) );
                });
                [void] $ReturnValue.AssetFiles.Add(@{
                    "FederatedId" = $ExportBatch.ExportId;
                    "FileName" = [IO.Path]::GetFileName($ExportBatch.ExportMetadataPath);
                    "FilePath" = $ExportBatch.ExportMetadataPath;
                    "FileType" = "json";
                });
            }
        
            If ([IO.File]::Exists($ExportBatch.ContentCSVPath))
            {
                ForEach ($CSVRow In (Import-Csv -Delimiter "," -Path $ExportBatch.ContentCSVPath))
                {
                    [String] $ObjectZIPFilePath = [IO.Path]::Combine(
                        $ExportBatch.ExtractDirectoryPath,
                        $CSVRow.objectPath.Substring(1).Replace("/", "\"),
                        [String]::Format("{0}.{1}.zip", $CSVRow.objectName, $CSVRow.objectType)
                    );
                    [String] $ObjectExtractDirectoryPath = [IO.Path]::Combine(
                        $ExportBatch.ExtractDirectoryPath,
                        $CSVRow.objectPath.Substring(1).Replace("/", "\"),
                        [String]::Format("{0}.{1}", $CSVRow.objectName, $CSVRow.objectType)
                    );
                    $Asset = @{
                        "Path" = $CSVRow.objectPath;
                        "Name" = $CSVRow.objectName;
                        "Type" = $CSVRow.objectType;
                        "FederatedId" = $CSVRow.id;
                        "ZIPFilePath" = $ObjectZIPFilePath;
                        "ZIPFileExists" = [IO.File]::Exists($ObjectZIPFilePath);
                        "ExtractDirectoryPath" = $ObjectExtractDirectoryPath;
                        "Files" = [Collections.Generic.List[String]]::new();
                    };
                    If ($Asset.ZIPFileExists)
                    {
                        Expand-Archive `
                            -Path  $Asset.ZIPFilePath `
                            -DestinationPath $Asset.ExtractDirectoryPath `
                            -Force;
                        ForEach ($File In (Get-ChildItem -Path $Asset.ExtractDirectoryPath -Filter "*.json" -File ))
                        {
                            [void] $ReturnValue.AssetFiles.Add(@{
                                "FederatedId" = $CSVRow.id;
                                "FileName" = $File.Name;
                                "FilePath" = $File.FullName;
                                "FileType" = "json";
                            });
                            [void] $Asset.Files.Add($File.Name);
                        }
                        ForEach ($File In (Get-ChildItem -Path $Asset.ExtractDirectoryPath -Filter "*.xml" -File ))
                        {
                            [void] $ReturnValue.AssetFiles.Add(@{
                                "FederatedId" = $CSVRow.id;
                                "FileName" = $File.Name;
                                "FilePath" = $File.FullName;
                                "FileType" = "xml";
                            });
                            [void] $Asset.Files.Add($File.Name);
                        }
        
                        ForEach ($File In (Get-ChildItem -Path $Asset.ExtractDirectoryPath -Filter "*.bin" -File -Recurse ))
                        {
                            [void] $ReturnValue.AssetFiles.Add(@{
                                "FederatedId" = $CSVRow.id;
                                "FileName" = [IO.Path]::GetRelativePath($Asset.ExtractDirectoryPath, $File.FullName);
                                "FilePath" = $File.FullName;
                                "FileType" = "bin";
                            });
                            [void] $Asset.Files.Add($File.Name);
                        }
                    }
                    [void] $ReturnValue.Assets.Add($Asset);
                }
            }
        }
    
        ForEach ($Asset In $ReturnValue.Assets | Where-Object -FilterScript { $_.Type -eq "TASKFLOW" })
        {
            [String] $XMLFilePath = ($Asset.ExtractDirectoryPath + ".xml");
            If ([IO.File]::Exists($XMLFilePath))
            {
                [void] $ReturnValue.AssetFiles.Add(@{
                    "FederatedId" = $Asset.FederatedId;
                    "FileName" = [IO.Path]::GetFileName($XMLFilePath);
                    "FilePath" = $XMLFilePath;
                    "FileType" = "xml";
                });
            }
        }

        If ($IncludeConnections)
        {
            [String] $ConnectionsFilePath = [IO.Path]::Combine($OutputDirectoryPath, "Connections.json");
            (
                Invoke-WebRequest `
                    -Uri ([String]::Format("{0}/api/v2/connection", $Global:Session.InformaticaAPI.Session.V2.APIURL)) `
                    -Headers $Global:Session.InformaticaAPI.Session.V2.Headers `
                    -Method Get
            ).Content |
                Out-File -FilePath $ConnectionsFilePath;
            [void] $ReturnValue.Assets.Add(@{
                "Path" = "System";
                "Name" = "Connection";
                "Type" = "Connection";
                "FederatedId" = "System.Connection";
            });
            [void] $ReturnValue.AssetFiles.Add(@{
                "FederatedId" = "System.Connection";
                "FileName" = "Connections.json";
                "FilePath" = $ConnectionsFilePath;
                "FileType" = "json";
            });
        }
    
        If ($IncludeSchedules)
        {
            [String] $SchedulesFilePath = [IO.Path]::Combine($OutputDirectoryPath, "Schedules.json");
            (
                Invoke-WebRequest `
                    -Uri ([String]::Format("{0}/public/core/v3/schedule", $Global:Session.InformaticaAPI.Session.V3.APIURL)) `
                    -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                    -Method Get
            ).Content |
                    #ConvertFrom-Json -Depth 100 |
                    Out-File -FilePath $SchedulesFilePath;
            [void] $ReturnValue.Assets.Add(@{
                "Path" = "System";
                "Name" = "Schedule";
                "Type" = "Schedule";
                "FederatedId" = "System.Schedule";
            });
            [void] $ReturnValue.AssetFiles.Add(@{
                "FederatedId" = "System.Schedule";
                "FileName" = "Schedules.json";
                "FilePath" = $SchedulesFilePath;
                "FileType" = "json";
            });
        }
    
        $global:ProgressPreference = $PreviousProgressPreference;
        ConvertTo-Json -InputObject $ReturnValue -Depth 100 |
            Out-File -FilePath ([IO.Path]::Combine($OutputDirectoryPath, "Export.json"));
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "ExportLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[String]])]
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $OutputDirectoryPath,
    
            [Parameter(Mandatory=$false)]
            [DateTime] $LastDatabaseStartTime
        )
        $PreviousProgressPreference = $global:ProgressPreference;
        $global:ProgressPreference = "SilentlyContinue";
        [Collections.Generic.List[String]] $ReturnValue = [Collections.Generic.List[String]]::new();
    
        [Int32] $Offset = 0;
        [Boolean] $Continue = $true;
        [Boolean] $FileWritten = $false;
        While ($Continue)
        {
            $FileWritten = $false;
            $Response =
                (
                    Invoke-WebRequest `
                        -Uri ([String]::Format(
                            "{0}/api/v2/activity/activityLog?rowLimit=1000&offset={1}",
                            $Global:Session.InformaticaAPI.Session.V2.APIURL,
                            $Offset
                        )) `
                        -Headers $Global:Session.InformaticaAPI.Session.V2.Headers `
                        -Method Get
                ).Content |
                    ConvertFrom-Json -Depth 100;
            ForEach ($Entry In ($Response | Where-Object -FilterScript { $_.startTimeUtc -ge $LastDatabaseStartTime}))
            {
                [String] $FilePath = [IO.Path]::Combine($OutputDirectoryPath, [String]::Format("{0}_{1}.json", $Entry.id, $Entry.runId))
                If (![IO.File]::Exists($FilePath))
                {
                    $Entry |
                        ConvertTo-Json -Depth 100 |
                            Out-File -FilePath $FilePath
                    [void] $ReturnValue.Add($FilePath);
                    $FileWritten = $true;
                }
            }
            If (!$FileWritten)
            {
                $Continue = $false;
                Break;
            }
            Else
            {
                $Continue = $true;
                If ($Offset -eq 0) { $Offset = 950 }
                    Else { $Offset += 1000 }
            }
        }
        $global:ProgressPreference = $PreviousProgressPreference;
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.InformaticaAPI `
    -Name "GetSchedules" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        $PreviousProgressPreference = $global:ProgressPreference;
        $global:ProgressPreference = "SilentlyContinue";
        [Object] $ReturnValue = $null;
        $ReturnValue = (
            Invoke-WebRequest `
                -Uri ([String]::Format("{0}/public/core/v3/schedule", $Global:Session.InformaticaAPI.Session.V3.APIURL)) `
                -Headers $Global:Session.InformaticaAPI.Session.V3.Headers `
                -Method Get
        ).Content |
                ConvertFrom-Json -Depth 100;
        $global:ProgressPreference = $PreviousProgressPreference;
        Return $ReturnValue;
    };
