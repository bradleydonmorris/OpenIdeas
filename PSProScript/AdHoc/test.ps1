. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "Utilities",
    "AppleHealth",
    "ShieldsIO"
);
$Global:Session.Logging.OutputToHost = $true;
#$Global:Session.Logging.Config.DatabaseConnectionName
#$Global:Session.Logging.Config
#$Global:Session.AppleHealth.DatabaseType = "Sqlite";
#$Global:Session.AppleHealth.ConnectionName = "AppleHealth-SQlite";
#[void] $Global:Session.SQLite.SetConnection($Global:Session.AppleHealth.ConnectionName, $null, $true, [IO.Path]::Combine($Global:Session.DataDirectory, "Data.sqlite"));

#$Global:Session.AppleHealth.DatabaseType = "SQLServer";
#C:\Integrations\Connections\AppleHealth-SQLServerLocalDB.json
#C:\Integrations\Connections\AppleHealth-SQLServerLocalDB.json

[void] $Global:Session.AppleHealth.SetDatabaseConnection("AppleHealth-SQLServerLocalDB");
#$Global:Session.AppleHealth.SetDatabaseType("SQLServerLocalDB");
$Global:Session.AppleHealth.DatabaseType
[void] $Global:Session.AppleHealth.VerifyDatabase();



# [Data.SqlClient.SqlConnection] $Connection = $null;
# [Data.SqlClient.SqlCommand] $Command = $null;
# $Connection = [Data.SqlClient.SqlConnection]::new("Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=C:\Integrations\Data\AdHoc\AppleHealth\LifeBook.mdf;Integrated Security=True;Connect Timeout=30");
# $Connection.Open();
# $Command = [Data.SqlClient.SqlCommand]::new("SELECT * FROM sys.objects", $Connection);
# $Command.CommandTimeout = 0;
# $Command.CommandType = [Data.CommandType]::Text;
#     ForEach ($ParameterKey In $Parameters.Keys)
#     {
#         [String] $Name = $ParameterKey;
#         If ($Name.StartsWith("@"))
#             { $Name = $Name.Substring(1)}
#         If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
#         {
#             [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
#         }
#         Else
#         {
#             [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
#             [void] $Command.Parameters.AddWithValue($Name, (
#                 $SqlXml.IsNull ?  
#                     [System.DBNull]::Value :
#                     $SqlXml
#             ));
#         }
#     }
#     $ReturnValue = $Command.ExecuteScalar();
#     If ($ReturnValue -is [System.DBNull])
#     {
#         $ReturnValue = $null;
#     }




# # $LogObject = ([ordered]@{
# #     "Log" = [ordered]@{
# #         "LogGUID" = $Global:Session.Logging.LogGUID;
# #         "OpenLogTime" = $Global:Session.Logging.OpenLogTime;
# #         "CloseLogTime" = $Global:Session.Logging.CloseLogTime;
# #         "Project" = $Global:Session.Project;
# #         "Script" = $Global:Session.Script;
# #         "ScriptFilePath" = $Global:Session.ScriptFilePath;
# #         "Host" = $Global:Session.Host;
# #     };
# #     "Variables" = $Global:Session.Variables.Dictionary;
# #     "Timers" = $Global:Session.Logging.Timers.GetTimersSimplified();
# #     "Entries" = $Global:Session.Logging.Entries;
# # })

# # $LogObject.GetType().AssemblyQualifiedName

# # Add-Type -AssemblyName System.Windows.Forms
# # Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# # [System.Windows.Forms.DataVisualization.Charting.Chart] $Chart = [System.Windows.Forms.DataVisualization.Charting.Chart]::new();
# # [System.Windows.Forms.DataVisualization.Charting.ChartArea] $ChartArea = [System.Windows.Forms.DataVisualization.Charting.ChartArea]::new();
# # [System.Windows.Forms.DataVisualization.Charting.Series] $SeriesWeight = [System.Windows.Forms.DataVisualization.Charting.Series]::new();
# # [System.Windows.Forms.DataVisualization.Charting.Legend] $Legend = [System.Windows.Forms.DataVisualization.Charting.Legend]::new();
# # $SeriesWeight.Label = "Weight";
# # $SeriesWeight.AxisLabel = "Weight";

# # [void] $Chart.Series.Add($SeriesWeight);
# # [void] $Chart.ChartAreas.Add($ChartArea);
# # [void] $Chart.Legends.Add($Legend);
# # $Chart.Dock = [System.Windows.Forms.DockStyle]::Fill

# # $SeriesWeight.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
# # $SeriesWeight.Points.DataBindXY(
# #     @("2023-01-01", "2023-01-02", "2023-01-03"),
# #     @(80, 90, 110))
# # #Set up the window and add the chart to the window
# # [System.Windows.Forms.Form] $Window = [System.Windows.Forms.Form]::new();
# # $Window.Text = "Beautiful Pie Charts"
# # $Window.Controls.Add($Chart);
# # #Show the window
# # $Window.ShowDialog();

# # # [String] $ConnectionName = "AppleHealth-SQLServer";
# # # [String] $Schema = "AppleHealth";
# # # [String] $Procedure = "ImportXML";
# # # [xml] $XMLHealthData = [IO.File]::ReadAllText("C:\Integrations\Data\AdHoc\AppleHealth\export_20230811134729\apple_health_export\export.xml");
# # # [Collections.Hashtable] $Parameters = @{
# # #     "XMLHealthData" = $XMLHealthData.DocumentElement;
# # # }

# # # [Data.SqlClient.SqlConnection] $Connection = $null;
# # # [Data.SqlClient.SqlCommand] $Command = $null;
# # # [String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
# # # Try
# # # {
# # #     $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
# # #     $Connection.Open();
# # #     $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
# # #     $Command.CommandType = [Data.CommandType]::StoredProcedure;
# # #     ForEach ($ParameterKey In $Parameters.Keys)
# # #     {
# # #         [String] $Name = $ParameterKey;
# # #         If ($Name.StartsWith("@"))
# # #             { $Name = $Name.Substring(1)}
# # #         If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
# # #         {
# # #             [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
# # #         }
# # #         Else
# # #         {
# # #             [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
# # #             [void] $Command.Parameters.AddWithValue($Name, (
# # #                 $SqlXml.IsNull ?  
# # #                     [System.DBNull]::Value :
# # #                     $SqlXml
# # #             ));
# # #         }
# # #     }
# # #     $Command.Parameters[0]
# # #     [void] $Command.ExecuteNonQuery();
# # # }
# # # Finally
# # # {
# # #     If ($Command)
# # #         { [void] $Command.Dispose(); }
# # #     If ($Connection)
# # #     {
# # #         If (!$Connection.State -ne [Data.ConnectionState]::Closed)
# # #             { [void] $Connection.Close(); }
# # #         [void] $Connection.Dispose();
# # #     }
# # # }


# # # [String] $FilePath = "C:\Integrations\Data\AdHoc\AppleHealth\Temp5.sqlite";
# # # [String] $ActiveConnectionName = [String]::Format(
# # #     "{0}_{1}_{2}",
# # #     $Global:Session.Project,
# # #     $Global:Session.Script,
# # #     [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")
# # # )
# # # [void] $Global:Session.SQLite.SetConnection(
# # #     $ActiveConnectionName,
# # #     "In memory only",
# # #     $false,
# # #     $FilePath
# # # );

# # # $Global:Session.Sqlite.CreateIfNotFound(
# # #     $ActiveConnectionName,
# # #     [IO.File]::ReadAllText("C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\PSProScript\_Modules\AppleHealth\SQLScripts\CreateSchema.sql"),
# # #     $null
# # # );

# # # $Global:Session.AppleHealth.OpenDatabase($Global:Session.Variables.Get("SQLiteDatabaseFilePath"));

# # # [System.Data.Sqlite.SqliteConnectionStringBuilder] $SqliteConnectionStringBuilder = [System.Data.Sqlite.SqliteConnectionStringBuilder]::new();
# # # $SqliteConnectionStringBuilder.DataSource = "C:\Integrations\Data\AdHoc\AppleHealth\Temp.sqlite";
# # # $SqliteConnectionStringBuilder.FailIfMissing = $false;
# # # $SqliteConnectionStringBuilder.ForeignKeys = $true;
# # # $SqliteConnectionStringBuilder.JournalMode = [System.Data.Sqlite.SQLiteJournalModeEnum]::Memory;
# # # $SqliteConnectionStringBuilder.SyncMode = [System.Data.Sqlite.SynchronizationModes]::Off;
# # # $SqliteConnectionStringBuilder.BinaryGUID = $true;
# # # $SqliteConnectionStringBuilder.DateTimeFormat = [System.Data.Sqlite.SQLiteDateFormats]::ISO8601;
# # # $SqliteConnectionStringBuilder.DateTimeKind = [DateTimeKind]::Utc;
# # # $SqliteConnectionStringBuilder.CacheSize
# # # [Data.Sqlite.SqliteConnection] $Connection = [Data.Sqlite.SqliteConnection]::new($SqliteConnectionStringBuilder.ConnectionString);
# # # [void] $Connection.Open();

# # # [Data.Sqlite.SqliteCommand] $CommandCreateTable = [Data.Sqlite.SqliteCommand]::new();
# # # $CommandCreateTable.Connection = $Connection;
# # # $CommandCreateTable.CommandType = [Data.CommandType]::Text;
# # # $CommandCreateTable.CommandText = "CREATE TABLE Foo(Id INTEGER NOT NULL PRIMARY KEY, FooGUID GUID NOT NULL, CreationDateUtc DATETIME NOT NULL)";
# # # [void] $CommandCreateTable.ExecuteNonQuery();
# # # [void] $CommandCreateTable.Dispose();

# # # For ($Loop = 0; $Loop -lt 10; $Loop ++)
# # # {
# # #     [Data.Sqlite.SqliteCommand] $CommandInsert = [Data.Sqlite.SqliteCommand]::new();
# # #     $CommandInsert.Connection = $Connection;
# # #     $CommandInsert.CommandType = [Data.CommandType]::Text;
# # #     $CommandInsert.CommandText = "INSERT INTO Foo(Id, FooGUID, CreationDateUtc) VALUES (@Id, @FooGUID, @CreationDateUtc)";
# # #     [void] $CommandInsert.Parameters.AddWithValue("@Id", $Loop);
# # #     [void] $CommandInsert.Parameters.AddWithValue("@FooGUID", [Guid]::NewGuid());
# # #     [void] $CommandInsert.Parameters.AddWithValue("@CreationDateUtc", [DateTime]::UtcNow.AddDays($Loop));
# # #     [void] $CommandInsert.ExecuteNonQuery();
# # #     [void] $CommandInsert.Dispose();
# # # }

# # # [Data.Sqlite.SqliteCommand] $CommandSelect = [Data.Sqlite.SqliteCommand]::new();
# # # $CommandSelect.Connection = $Connection;
# # # $CommandSelect.CommandText = "SELECT Id, FooGUID, CreationDateUtc FROM Foo";
# # # [Data.Sqlite.SqliteDataReader] $DataReader = $CommandSelect.ExecuteReader();
# # # While ($DataReader.Read())
# # # {
# # #     $DataReader.GetInt64($DataReader.GetOrdinal("Id"));
# # #     $DataReader.GetGuid($DataReader.GetOrdinal("FooGUID"));
# # #     $DataReader.GetDateTime($DataReader.GetOrdinal("CreationDateUtc"));
# # #     Break;
# # # }
# # # [void] $CommandSelect.Dispose();


# # # [void] $Connection.Close();
# # # [void] $Connection.Dispose();



# # # #connection.Execute("insert into Foo(Id, CreationDateUtc) values (@Id, @CreationDateUtc)", foo);
       


# # # #Add-Type -TypeDefinition ([IO.File]::ReadAllText("C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\PSProScript\_Modules\PromptsUI\FormInput.cs"));
# # # #Add-Type -TypeDefinition ([IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "FormInput.sql")));



# # # # [Collections.Generic.List[PSObject]] $Prompts = [Collections.Generic.List[PSObject]]::new();
# # # # # [void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("FirstName", "First Name", "We need the first name of the person.", "Bradley"));
# # # # # [void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("MiddleName", "Middle Name", $null, $null));
# # # # # [void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("LastName", "Last Name", "We need the last name of person.", "Morris"));
# # # # # [void] $Prompts.Add($Global:Session.PromptsUI.GetDatePrompt("DateOfBirth", "Date Of Birth", $null, [DateTime]::Parse("1977-11-02")));
# # # # [void] $Prompts.Add($Global:Session.PromptsUI.GetMaskedPrompt("Password", "Password", "We need a passwoerd"));
# # # # #$Prompts;

# # # # # Add-Type -AssemblyName System.Windows.Forms;
# # # # # Add-Type -AssemblyName System.Drawing;


# # # # [System.Windows.Forms.Form] $FormInput = [System.Windows.Forms.Form]::new();
# # # # $FormInput.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font;
# # # # $FormInput.ClientSize = [System.Drawing.Size]::new(484, 47);
# # # # $FormInput.Name = "FormInput";
# # # # $FormInput.Text = "Input Requested";
# # # # $FormInput.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog;
# # # # $FormInput.MaximizeBox = $false;
# # # # $FormInput.MinimizeBox = $false;
# # # # $FormInput.ShowIcon = $false;
# # # # $FormInput.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
# # # # [Int32] $TabIndex = (-1);
# # # # [Int32] $NextTop = 12;
# # # # ForEach ($Prompt In $Prompts)
# # # # {
# # # #     $TabIndex ++;
# # # #     $Prompt.PromptControl.Location = [System.Drawing.Point]::new(12, $NextTop);
# # # #     [void] $FormInput.Controls.Add($Prompt.PromptControl);
# # # #     $NextTop = $Prompt.PromptControl.Top + $Prompt.PromptControl.Height + 10;
# # # # }

# # # # [System.Windows.Forms.Button] $ButtonOkay = [System.Windows.Forms.Button]::new();
# # # # $ButtonOkay.DialogResult = [System.Windows.Forms.DialogResult]::OK;
# # # # $ButtonOkay.Location = [System.Drawing.Point]::new(316, $NextTop);
# # # # $ButtonOkay.Name = "ButtonOkay";
# # # # $ButtonOkay.Size = [System.Drawing.Size]::new(75, 23);
# # # # $Global:Session.PromptsUI.LastTabIndex ++;
# # # # $ButtonOkay.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
# # # # $ButtonOkay.Text = "Okay";
# # # # $ButtonOkay.UseVisualStyleBackColor = $true;

# # # # [System.Windows.Forms.Button] $ButtonCancel = [System.Windows.Forms.Button]::new();
# # # # $ButtonCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel;
# # # # $ButtonCancel.Location = [System.Drawing.Point]::new(397, $NextTop);
# # # # $ButtonCancel.Name = "ButtonCancel";
# # # # $ButtonCancel.Size = [System.Drawing.Size]::new(75, 23);
# # # # $Global:Session.PromptsUI.LastTabIndex ++;
# # # # $ButtonCancel.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
# # # # $ButtonCancel.Text = "Cancel";
# # # # $ButtonCancel.UseVisualStyleBackColor = $true;

# # # # $NextTop = $ButtonCancel.Top + $ButtonCancel.Height + 10
# # # # $FormInput.AcceptButton = $ButtonOkay;
# # # # $FormInput.CancelButton = $ButtonCancel;
# # # # [void] $FormInput.Controls.Add($ButtonOkay);
# # # # [void] $FormInput.Controls.Add($ButtonCancel);
# # # # $FormInput.Height = $NextTop + 43;
# # # # [void] $FormInput.ResumeLayout($false);
# # # # [void] $FormInput.Refresh();
# # # # [System.Windows.Forms.DialogResult] $DialogResult = $FormInput.ShowDialog($this);
# # # # Write-Host $DialogResult
# # # # [Collections.Hashtable] $ReturnValue = [Collections.Hashtable]::new();
# # # # If ($DialogResult = [System.Windows.Forms.DialogResult]::OK)
# # # # {
# # # #     ForEach ($Prompt In $Prompts)
# # # #     {
# # # #         [Object] $Value = $null;
# # # #         Switch ($Prompt.Type)
# # # #         {
# # # #             "String"
# # # #             {
# # # #                 [System.Windows.Forms.TextBox] $StringPrompt = $FormInput.Controls.Find($Prompt.ValueControlName, $true);
# # # #                 $Value = $StringPrompt.Text;
# # # #                 $Prompt.IsProvided = [String]::IsNullOrEmpty($Value);
# # # #                 If ($Prompt.IsRequired -and !$Prompt.IsProvided)
# # # #                 {
# # # #                     $Prompt.ValidationMessage = "Must be provided."
# # # #                 }
# # # #             }
# # # #             "Date" { $Value = $FormInput.Controls.Find($Prompt.ValueControlName, $true).Value.Date; }
# # # #             "Masked" { $Value = $FormInput.Controls.Find($Prompt.ValueControlName, $true).Value.Date; }
# # # #         }
# # # #         [void] $ReturnValue.Add(
# # # #             $Prompt.Name,
# # # #             $Value
# # # #         );
# # # #     }
# # # # }

# # # # $ReturnValue;