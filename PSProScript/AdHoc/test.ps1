 . ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "PromptsUI",
    "GnuPG"
);

Add-Type -TypeDefinition ([IO.File]::ReadAllText("C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\PSProScript\_Modules\PromptsUI\FormInput.cs"));
#Add-Type -TypeDefinition ([IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "FormInput.sql")));



# [Collections.Generic.List[PSObject]] $Prompts = [Collections.Generic.List[PSObject]]::new();
# # [void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("FirstName", "First Name", "We need the first name of the person.", "Bradley"));
# # [void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("MiddleName", "Middle Name", $null, $null));
# # [void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("LastName", "Last Name", "We need the last name of person.", "Morris"));
# # [void] $Prompts.Add($Global:Session.PromptsUI.GetDatePrompt("DateOfBirth", "Date Of Birth", $null, [DateTime]::Parse("1977-11-02")));
# [void] $Prompts.Add($Global:Session.PromptsUI.GetMaskedPrompt("Password", "Password", "We need a passwoerd"));
# #$Prompts;

# # Add-Type -AssemblyName System.Windows.Forms;
# # Add-Type -AssemblyName System.Drawing;


# [System.Windows.Forms.Form] $FormInput = [System.Windows.Forms.Form]::new();
# $FormInput.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font;
# $FormInput.ClientSize = [System.Drawing.Size]::new(484, 47);
# $FormInput.Name = "FormInput";
# $FormInput.Text = "Input Requested";
# $FormInput.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog;
# $FormInput.MaximizeBox = $false;
# $FormInput.MinimizeBox = $false;
# $FormInput.ShowIcon = $false;
# $FormInput.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
# [Int32] $TabIndex = (-1);
# [Int32] $NextTop = 12;
# ForEach ($Prompt In $Prompts)
# {
#     $TabIndex ++;
#     $Prompt.PromptControl.Location = [System.Drawing.Point]::new(12, $NextTop);
#     [void] $FormInput.Controls.Add($Prompt.PromptControl);
#     $NextTop = $Prompt.PromptControl.Top + $Prompt.PromptControl.Height + 10;
# }

# [System.Windows.Forms.Button] $ButtonOkay = [System.Windows.Forms.Button]::new();
# $ButtonOkay.DialogResult = [System.Windows.Forms.DialogResult]::OK;
# $ButtonOkay.Location = [System.Drawing.Point]::new(316, $NextTop);
# $ButtonOkay.Name = "ButtonOkay";
# $ButtonOkay.Size = [System.Drawing.Size]::new(75, 23);
# $Global:Session.PromptsUI.LastTabIndex ++;
# $ButtonOkay.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
# $ButtonOkay.Text = "Okay";
# $ButtonOkay.UseVisualStyleBackColor = $true;

# [System.Windows.Forms.Button] $ButtonCancel = [System.Windows.Forms.Button]::new();
# $ButtonCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel;
# $ButtonCancel.Location = [System.Drawing.Point]::new(397, $NextTop);
# $ButtonCancel.Name = "ButtonCancel";
# $ButtonCancel.Size = [System.Drawing.Size]::new(75, 23);
# $Global:Session.PromptsUI.LastTabIndex ++;
# $ButtonCancel.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
# $ButtonCancel.Text = "Cancel";
# $ButtonCancel.UseVisualStyleBackColor = $true;

# $NextTop = $ButtonCancel.Top + $ButtonCancel.Height + 10
# $FormInput.AcceptButton = $ButtonOkay;
# $FormInput.CancelButton = $ButtonCancel;
# [void] $FormInput.Controls.Add($ButtonOkay);
# [void] $FormInput.Controls.Add($ButtonCancel);
# $FormInput.Height = $NextTop + 43;
# [void] $FormInput.ResumeLayout($false);
# [void] $FormInput.Refresh();
# [System.Windows.Forms.DialogResult] $DialogResult = $FormInput.ShowDialog($this);
# Write-Host $DialogResult
# [Collections.Hashtable] $ReturnValue = [Collections.Hashtable]::new();
# If ($DialogResult = [System.Windows.Forms.DialogResult]::OK)
# {
#     ForEach ($Prompt In $Prompts)
#     {
#         [Object] $Value = $null;
#         Switch ($Prompt.Type)
#         {
#             "String"
#             {
#                 [System.Windows.Forms.TextBox] $StringPrompt = $FormInput.Controls.Find($Prompt.ValueControlName, $true);
#                 $Value = $StringPrompt.Text;
#                 $Prompt.IsProvided = [String]::IsNullOrEmpty($Value);
#                 If ($Prompt.IsRequired -and !$Prompt.IsProvided)
#                 {
#                     $Prompt.ValidationMessage = "Must be provided."
#                 }
#             }
#             "Date" { $Value = $FormInput.Controls.Find($Prompt.ValueControlName, $true).Value.Date; }
#             "Masked" { $Value = $FormInput.Controls.Find($Prompt.ValueControlName, $true).Value.Date; }
#         }
#         [void] $ReturnValue.Add(
#             $Prompt.Name,
#             $Value
#         );
#     }
# }

# $ReturnValue;