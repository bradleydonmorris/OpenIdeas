 . ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "PromptsUI",
    "GnuPG"
);


[Collections.Generic.List[PSObject]] $Prompts = [Collections.Generic.List[PSObject]]::new();
[void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("FirstName", "First Name of Person", "Bradley"));
[void] $Prompts.Add($Global:Session.PromptsUI.GetStringPrompt("LastName", "Last Name of Person", "Morris"));
#$Prompts;

Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;

[System.Windows.Forms.Button] $ButtonOkay = [System.Windows.Forms.Button]::new();
$ButtonOkay.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom + [System.Windows.Forms.AnchorStyles]::Right;
$ButtonOkay.DialogResult = [System.Windows.Forms.DialogResult]::OK;
$ButtonOkay.Location = [System.Drawing.Point]::new(316, 426);
$ButtonOkay.Name = "ButtonOkay";
$ButtonOkay.Size = [System.Drawing.Size]::new(75, 23);
$ButtonOkay.TabIndex = 0;
$ButtonOkay.Text = "Okay";
$ButtonOkay.UseVisualStyleBackColor = $true;

[System.Windows.Forms.Button] $ButtonCancel = [System.Windows.Forms.Button]::new();
$ButtonCancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom + [System.Windows.Forms.AnchorStyles]::Right;
$ButtonCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel;
$ButtonCancel.Location = [System.Drawing.Point]::new(397, 426);
$ButtonCancel.Name = "ButtonCancel";
$ButtonCancel.Size = [System.Drawing.Size]::new(75, 23);
$ButtonCancel.TabIndex = 0;
$ButtonCancel.Text = "Cancel";
$ButtonCancel.UseVisualStyleBackColor = $true;

[System.Windows.Forms.Form] $FormInput = [System.Windows.Forms.Form]::new();
$FormInput.AcceptButton = $ButtonOkay;
$FormInput.CancelButton = $ButtonCancel;
$FormInput.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font;
$FormInput.ClientSize = [System.Drawing.Size]::new(484, 461);
[void] $FormInput.Controls.Add($ButtonOkay);
[void] $FormInput.Controls.Add($ButtonCancel);
$FormInput.Name = "FormInput";
$FormInput.Text = "Enter your input";
$FormInput.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog;
$FormInput.MaximizeBox = $false;
$FormInput.MinimizeBox = $false;
$FormInput.ShowIcon = $false;
$FormInput.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

[Int32] $TabIndex = (-1);
ForEach ($Prompt In $Prompts)
{
    If ($Prompt.Type -eq "String")
    {
        $TabIndex ++;
        $Prompt.PromptControl = [System.Windows.Forms.TextBox]::new();
        $Prompt.PromptControl.Location = [System.Drawing.Point]::new(12, 27);
        $Prompt.PromptControl.Name = [String]::Format("Prompt_{0}", $Prompt.Name);
        $Prompt.PromptControl.Size = [System.Drawing.Size]::new(460, 23);
        $Prompt.PromptControl.TabIndex = $TabIndex;
        If (![String]::IsNullOrEmpty($Prompt.Default))
        {
            $Prompt.PromptControl.Text = $Prompt.Default;
        }
        [void] $FormInput.Controls.Add($Prompt.PromptControl);
    }
    Break;
}
$FormInput.ResumeLayout($false);
[System.Windows.Forms.DialogResult] $DialogResult = $FormInput.ShowDialog($this);
Write-Host $DialogResult
$FormInput.Controls.Find("Prompt_FirstName", $false).Text
