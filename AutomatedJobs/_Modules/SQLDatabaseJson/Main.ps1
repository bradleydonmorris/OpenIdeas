Class NamedSQLScript {
    [String] $Mode;
    [Int32] $Sequence;
    [String] $Type;
    [String] $Name;
    [String] $Script;

    NamedSQLScript (
        [String] $mode,
        [Int32] $sequence,
        [String] $type,
        [String] $name,
        [String] $script
    )
    {
        $this.Mode = $mode;
        $this.Sequence = $sequence;
        $this.Type = $type;
        $this.Name = $name;
        $this.Script = $script;
    }
}

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SQLDatabaseJson" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -TypeName "String" `
    -NotePropertyName "ExportScriptPath" `
    -NotePropertyValue ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "ExportDatabaseStructure.sql"));
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "Export" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,

            [Parameter(Mandatory=$true)]
            [String] $OutputFolderPath
        )
        If ($OutputFolderPath.EndsWith("DatabaseObjects.json"))
        {
            $OutputFolderPath = [IO.Path]::GetDirectoryName($OutputFolderPath);
        }
        [String] $DatabaseObjectsPath = [IO.Path]::Combine($OutputFolderPath, "DatabaseObjects.json");
        [String] $DefinitionsFolderPath = [IO.Path]::Combine($OutputFolderPath, "DatabaseObjectsDefinitions");
        $Output = $Global:Job.Databases.GetLargeSQLScalarValue(
            $Instance,
            $Database,
            [IO.File]::ReadAllText($Global:Job.SQLDatabaseJson.ExportScriptPath),
            @{ "SchemaName" = $Schema; }
        ) | ConvertFrom-Json -Depth 100
        
        If ([IO.Directory]::Exists($DefinitionsFolderPath))
        {
            [void] [IO.Directory]::Delete($DefinitionsFolderPath, $true);
        }
        [void] [IO.Directory]::CreateDirectory($DefinitionsFolderPath);
        ForEach($Module In $Output.Modules)
        {
            [IO.File]::WriteAllText(
                [IO.Path]::Combine($DefinitionsFolderPath, $Module.ContentFileReference),
                $Module.Content
            );
            $Module.PSObject.Properties.Remove("Content");
        }
        $Output |
            ConvertTo-Json -Depth 100 |
            Out-File -FilePath $DatabaseObjectsPath;
    };
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "GetIndexCreate" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,
    
            [Parameter(Mandatory=$true)]
            [String] $Index,

            [Parameter(Mandatory=$true)]
            [Boolean] $IsUnique,

            [Parameter(Mandatory=$true)]
            [Object] $Columns,

            [Parameter(Mandatory=$true)]
            [Object] $IncludeColumns,

            [Parameter(Mandatory=$true)]
            [String] $FileGroup
        )
        [String] $ReturnValue = "CREATE ";
        [Int32] $CurrentLoopIndex = 0;
        If ($IsUnique)
        {
            $ReturnValue += "UNIQUE ";
        }
        $ReturnValue += [String]::Format("[{0}]`r`n", $Index);
        $ReturnValue += [String]::Format("`tON [{0}].[{1}]", $Schema, $Table);
        If ($Columns.Count -eq 1)
        {
            $ReturnValue += [String]::Format("`t([{0}] {1})`r`n", $Columns[0].Name, ($Columns[0].SortDirection -eq "Descending" ? "DESC" : "ASC"));
        }
        Else
        {
            $CurrentLoopIndex = 0;
            $ReturnValue += "`r`n`t(`r`n"
            ForEach ($Column In $Columns)
            {
                $ReturnValue += [String]::Format("`t`t[{0}] {1}", $Column.Name, ($Column.SortDirection -eq "Descending" ? "DESC" : "ASC"));
                $CurrentLoopIndex ++;
                If ($CurrentLoopIndex -lt $Columns.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n";
            }
            $ReturnValue += "`t)`r`n"
        }
        If ($IncludeColumns.Count -eq 1)
        {
            $ReturnValue += [String]::Format("`tINCLUDE ([{0}])`r`n", $IncludeColumns[0].Name);
        }
        ElseIf  ($IncludeColumns.Count -gt 1)
        {
            $CurrentLoopIndex = 0;
            $ReturnValue += "`r`n`tINCLUDE`r`n`t(`r`n"
            ForEach ($Column In $IncludeColumns)
            {
                $CurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`t`t[{0}]", $Column.Name);
                If ($CurrentLoopIndex -lt $IncludeColumns.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n";
            }
            $ReturnValue += "`t)`r`n"
        }
        $ReturnValue += "`tWITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)`r`n";
        $ReturnValue += [String]::Format("`tON [{0}]", $FileGroup);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "GetTableCreate" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,

            [Parameter(Mandatory=$true)]
            [Object] $Columns,

            [Parameter(Mandatory=$true)]
            [String] $HeapFileGroup,

            [Parameter(Mandatory=$true)]
            [String] $LobFileGroup
        )
        [String] $ReturnValue = [String]::Format("CREATE TABLE [{0}].[{1}]`r`n", $Schema, $Table);
        [Int32] $CurrentLoopIndex = 0;
        [Boolean] $HasPrimaryKey = $false;
        [Boolean] $HasForeignKeys = $false;
        If (($Columns |Where-Object -FilterScript { $_.IsPrimaryKey -or $_.ForeignKey }).Count -gt 0)
        {
            $HasPrimaryKey = $true;
        }
        If (($Columns |Where-Object -FilterScript { $_.ForeignKey }).Count -gt 0)
        {
            $HasForeignKeys = $true;
        }
        $CurrentLoopIndex = 0;
        $ReturnValue += "(`r`n"
        ForEach ($Column In ($Columns | Sort-Object -Property "Ordinal"))
        {
            $CurrentLoopIndex ++;
            $ReturnValue += [String]::Format("`t[{0}] {1}", $Column.Name, $Column.CondensedType);
            If ($Column.IsIdentity)
            {
                $ReturnValue += " IDENTITY(1, 1)";
            }
            If (![String]::IsNullOrEmpty($Column.Computation.Definition))
            {
                $ReturnValue += [String]::Format("`r`n`t`tAS {0}", $Column.Computation.Definition);
            }
            Else
            {
                $ReturnValue += [String]::Format(" {0}", ($Column.IsNullable ? "NULL" : "NOT NULL"));
            }
            If (![String]::IsNullOrEmpty($Column.Default.Definition))
            {
                $ReturnValue += [String]::Format("`r`n`t`tCONSTRAINT [DF_{0}_{1}] DEFAULT {2}", $Table, $Column.Name, $Column.Default.Definition);
            }
            If ($Column.IsRowGUID)
            {
                $ReturnValue += " ROWGUIDCOL";
            }
            If (
                ($CurrentLoopIndex -lt $Columns.Count) -or
                $HasPrimaryKey -or $HasForeignKeys
            )
            {
                $ReturnValue += ",";
            }
            $ReturnValue += "`r`n"
        }
        If ($HasPrimaryKey)
        {
            $PrimaryKey = $Columns |
                Where-Object -FilterScript { $_.IsPrimaryKey } |
                Select-Object -First 1;
            $ReturnValue += [String]::Format("`tCONSTRAINT [PK_{0}]`r`n", $Table);
            $ReturnValue += [String]::Format("`t`tPRIMARY KEY CLUSTERED ([{0}])`r`n", $PrimaryKey.Name);
            $ReturnValue += "`t`tWITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),`r`n";
            $ReturnValue += [String]::Format("`t`tON [{0}]", $HeapFileGroup);
            If ($HasForeignKeys)
            {
                $ReturnValue += ",";
            }
            $ReturnValue += "`r`n"
        }
        If ($HasForeignKeys)
        {
            $CurrentLoopIndex = 0;
            $ForeignKeyColumns = $Columns |
                Where-Object -FilterScript { $_.ForeignKey } |
                Sort-Object -Property "Ordinal";
            ForEach ($ForeignKeyColumn In $ForeignKeyColumns)
            {
                $CurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`tCONSTRAINT [FK_{0}_{1}{2}]`r`n",
                    $Table,
                    $ForeignKeyColumn.ForeignKey.Table,
                    (
                        ![String]::IsNullOrEmpty($ForeignKeyColumn.ForeignKey.Suffix) ?
                            [String]::Format("_{0}", $ForeignKeyColumn.ForeignKey.Suffix) :
                            ""
                    )
                );
                $ReturnValue += [String]::Format("`t`tFOREIGN KEY ([{0}])`r`n", $ForeignKeyColumn.Name);
                $ReturnValue += [String]::Format("`t`tREFERENCES [{0}].[{1}] ([{2}])`r`n",
                    $ForeignKeyColumn.ForeignKey.Schema,
                    $ForeignKeyColumn.ForeignKey.Table,
                    $ForeignKeyColumn.ForeignKey.Column
                );
                If ($CurrentLoopIndex -lt $ForeignKeyColumns.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n"
            }
        }
        $ReturnValue += [String]::Format(") ON [{0}]", $HeapFileGroup);
        If (![String]::IsNullOrEmpty($LobFileGroup))
        {
            $ReturnValue += [String]::Format(" TEXTIMAGE_ON [{0}]", $LobFileGroup);
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "GetFunctionCreate" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Function,

            [Parameter(Mandatory=$true)]
            [Object] $Returns,

            [Parameter(Mandatory=$true)]
            [Object] $Parameters,

            [Parameter(Mandatory=$true)]
            [String] $ContentFile
        )
        [String] $ReturnValue = [String]::Format("CREATE OR ALTER FUNCTION [{0}].[{1}]`r`n", $Schema, $Function);
        [Int32] $CurrentLoopIndex = 0;
        If ($Parameters.Count -gt 0)
        {
            $ReturnValue += "(`r`n";
            $CurrentLoopIndex = 0;
            ForEach ($Parameter In ($Parameters | Sort-Object -Property "Sequence"))
            {
                $CurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`t{0} {1}", $Parameter.Name, $Parameter.CondensedType);
                If ($Parameter.IsOutput)
                {
                    $ReturnValue += " OUTPUT";
                }
                If ($CurrentLoopIndex -lt $Parameters.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n"
            }
            $ReturnValue += ")`r`n";
        }
        $ReturnValue += [String]::Format("RETURNS {0}", $Returns.CondensedType);
        $ReturnValue += "`r`nAS`r`n";
        $ReturnValue += [IO.File]::ReadAllText($ContentFile);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "GetProcedureCreate" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Procedure,

            [Parameter(Mandatory=$true)]
            [Object] $Parameters,

            [Parameter(Mandatory=$true)]
            [String] $ContentFile
        )
        [String] $ReturnValue = [String]::Format("CREATE OR ALTER PROCEDURE [{0}].[{1}]`r`n", $Schema, $Procedure);
        [Int32] $CurrentLoopIndex = 0;
        If ($Parameters.Count -gt 0)
        {
            $ReturnValue += "(`r`n";
            $CurrentLoopIndex = 0;
            ForEach ($Parameter In ($Parameters | Sort-Object -Property "Sequence"))
            {
                $CurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`t{0} {1}", $Parameter.Name, $Parameter.CondensedType);
                If ($Parameter.IsOutput)
                {
                    $ReturnValue += " OUTPUT";
                }
                If ($CurrentLoopIndex -lt $Parameters.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n"
            }
            $ReturnValue += ")`r`n";
        }
        $ReturnValue += "`r`nAS`r`n";
        $ReturnValue += [IO.File]::ReadAllText($ContentFile);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "GetViewCreate" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $View,

            [Parameter(Mandatory=$true)]
            [String] $ContentFile
        )
        [String] $ReturnValue = [String]::Format("CREATE OR ALTER View [{0}].[{1}]`r`n", $Schema, $Procedure);
        $ReturnValue += "`r`nAS`r`n";
        $ReturnValue += [IO.File]::ReadAllText($ContentFile);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLDatabaseJson `
    -Name "BuildSQLScripts" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Schema,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearStructure,

            [Parameter(Mandatory=$true)]
            [Boolean] $DropSchema,

            [Parameter(Mandatory=$true)]
            [Boolean] $OverrideFileGroups,

            [Parameter(Mandatory=$true)]
            [String] $HeapFileGroupName,

            [Parameter(Mandatory=$true)]
            [String] $IndexFileGroupName,

            [Parameter(Mandatory=$true)]
            [String] $LobFileGroupName,

            [Parameter(Mandatory=$true)]
            [String] $InputFolderPath
        )
        [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();
        If ($InputFolderPath.EndsWith("DatabaseObjects.json"))
        {
            $InputFolderPath = [IO.Path]::GetDirectoryName($InputFolderPath);
        }
        [String] $DatabaseObjectsPath = [IO.Path]::Combine($InputFolderPath, "DatabaseObjects.json");
        [String] $DefinitionsFolderPath = [IO.Path]::Combine($InputFolderPath, "DatabaseObjectsDefinitions");
        $DatabaseObjects = [IO.File]::ReadAllText($DatabaseObjectsPath) | ConvertFrom-Json -Depth 100;
        If ($HeapFileGroupName)
        {
            $DatabaseObjects.Storage.HeapFileGroupName = $HeapFileGroupName;
        }
        If ($IndexFileGroupName)
        {
            $DatabaseObjects.Storage.IndexFileGroupName = $IndexFileGroupName;
        }
        If ($LobFileGroupName)
        {
            $DatabaseObjects.Storage.LobFileGroupName = $LobFileGroupName;
        }
        [Int32] $LastSequence = 0;
        If ($ClearStructure)
        {
            ForEach ($Item In ($DatabaseObjects.DropSequence | Sort-Object -Property "Sequence"))
            {
                $LastSequence = $Item.Sequence;
                [void] $ReturnValue.Add([NamedSQLScript]::new(
                    "Drop", $LastSequence, $Item.Type,
                    [String]::Format("[{0}].[{1}]", $Schema, $Item.Name),
                    [String]::Format("DROP {0} IF EXISTS [{1}].[{2}]", $Item.Type.ToUpper(), $Schema, $Item.Name)
                ));
            }
            If ($DropSchema)
            {
                $LastSequence ++;
                [void] $ReturnValue.Add([NamedSQLScript]::new(
                    "Drop", $LastSequence, "Schema",
                    [String]::Format("[{0}]", $Schema),
                    [String]::Format("DROP SCHEMA IF EXISTS [{0}]", $Schema)
                ));
            }
        }
        $LastSequence ++;
        [void] $ReturnValue.Add([NamedSQLScript]::new(
            "Drop", $LastSequence, "Schema",
            [String]::Format("[{0}]", $Schema),
            [String]::Format("CREATE SCHEMA [{0}]", $Schema)
        ));
        ForEach ($Table In ($DatabaseObjects.Tables | Sort-Object -Property "Sequence"))
        {
            [String] $HeapFileGroup = $null;
            [String] $LobFileGroup = $null;
            $HeapFileGroup = (
                (
                    ($Table.FileGroup -eq "DEFAULT_HEAP_FILE_GROUP") -or
                    $OverrideFileGroups
                ) ?
                $DatabaseObjects.Storage.HeapFileGroupName :
                $Table.FileGroup
            )
            If (![String]::IsNullOrEmpty($Table.LobFileGroupName))
            {
                $LobFileGroup = (
                    (
                        ($Table.LobFileGroupName -eq "DEFAULT_LOB_FILE_GROUP") -or
                        $OverrideFileGroups
                    ) ?
                    $DatabaseObjects.Storage.LobFileGroupName :
                    $Table.LobFileGroupName
                )
            }
            Else
            {
                $LobFileGroup = $null;
            }
            $LastSequence ++;
            [void] $ReturnValue.Add([NamedSQLScript]::new(
                "Create", $LastSequence, "Table",
                [String]::Format("[{0}].[{1}]", $Schema, $Table.Name),
                $Global:Job.SQLDatabaseJson.GetTableCreate($Schema, $Table.Name, $Table.Columns, $HeapFileGroup, $LobFileGroup)
            ));
            ForEach ($Index In $Table.Indexes)
            {
                $LastSequence ++;
                [void] $ReturnValue.Add([NamedSQLScript]::new(
                    "Create", $LastSequence, "Index",
                    [String]::Format("[{0}].[{1}].[{2}]", $Schema, $Table.Name, $Index.Name),
                    $Global:Job.SQLDatabaseJson.GetIndexCreate(
                        $Schema,
                        $Table.Name,
                        $Index.Name,
                        $Index.IsUnique,
                        $Index.Columns,
                        $Index.IncludeColumns,
                        (
                            (
                                ($Index.FileGroup -eq "DEFAULT_INDEX_FILE_GROUP") -or
                                $OverrideFileGroups
                            ) ?
                            $DatabaseObjects.Storage.IndexFileGroupName :
                            $Index.FileGroup
                        )
                    )
                ));
            }
        }
        ForEach ($Module In ($DatabaseObjects.Modules | Sort-Object -Property "Sequence"))
        {
            $LastSequence ++;
            [String] $ContentFile = [IO.Path]::Combine($DefinitionsFolderPath, $Module.ContentFileReference);
            Switch($Module.Type)
            {
                "Function"
                {
                    [void] $ReturnValue.Add([NamedSQLScript]::new(
                        "Create", $LastSequence, $Module.Type,
                        [String]::Format("[{0}].[{1}]", $Schema, $Module.Name),
                        $Global:Job.SQLDatabaseJson.GetFunctionCreate($Schema, $Module.Name, $Module.Returns, $Module.Parameters, $ContentFile)
                    ));
                }
                "Procedure"
                {
                    [void] $ReturnValue.Add([NamedSQLScript]::new(
                        "Create", $LastSequence, $Module.Type,
                        [String]::Format("[{0}].[{1}]", $Schema, $Module.Name),
                        $Global:Job.SQLDatabaseJson.GetProcedureCreate($Schema, $Module.Name, $Module.Parameters, $ContentFile)
                    ));
                }
                "View"
                {
                    [void] $ReturnValue.Add([NamedSQLScript]::new(
                        "Create", $LastSequence, $Module.Type,
                        [String]::Format("[{0}].[{1}]", $Schema, $Module.Name),
                        $Global:Job.SQLDatabaseJson.GetViewCreate($Schema, $Module.Name, $ContentFile)
                    ));
                }
                Default
                {
                    Write-Host -Object ([String]::Format("Unhandled Module Type ({0})", $Module.Type)) -ForegroundColor Red;
                }
            }
        }
        Return $ReturnValue;
    };
