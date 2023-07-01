Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PromptsUI" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.PromptsUI `
    -TypeName "Int32" `
    -NotePropertyName "LastTabIndex" `
    -NotePropertyValue (-1);
Add-Member `
    -InputObject $Global:Session.PromptsUI `
    -Name "GetStringPrompt" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [String] $Name,
            [String] $Label,
            [String] $Description,
            [String] $Default,
            [String] $IsRequired
        )
        [PSObject] $ReturnValue = [PSObject]::new();
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Type" -NotePropertyValue "String";
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue $Name;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Label" -NotePropertyValue $Label;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Description" -NotePropertyValue $Description;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Default" -NotePropertyValue $Default;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "IsRequired" -NotePropertyValue $IsRequired;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "IsProvided" -NotePropertyValue $false;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "ValidationMessage" -NotePropertyValue $null;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "ValueControlName" -NotePropertyValue ([String]::Format("TextBox{0}", $Name));
        Add-Member -InputObject $ReturnValue -TypeName "System.Windows.Forms.GroupBox" -NotePropertyName "PromptControl" -NotePropertyValue $null;
        [System.Windows.Forms.GroupBox] $GroupBox = [System.Windows.Forms.GroupBox]::new();
        #$GroupBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left + [System.Windows.Forms.AnchorStyles]::Right;
        $GroupBox.Location = [System.Drawing.Point]::new(12, 12);
        $GroupBox.Name = [String]::Format("GroupBox{0}", $Name);
        $GroupBox.Text = $Label;
        If ([String]::IsNullOrEmpty($Description))
        {
            $GroupBox.Size = [System.Drawing.Size]::new(460, 57);
        }
        Else
        {
            $GroupBox.Size = [System.Drawing.Size]::new(460, 71);
            [System.Windows.Forms.Label] $Label = [System.Windows.Forms.Label]::new();
            $Label.AutoSize = $true;
            $Label.Location = [System.Drawing.Point]::new(6, 48);
            $Label.Name = [String]::Format("Label{0}", $Name);
            $Label.Size = [System.Drawing.Size]::new(205, 15);
            $Label.Text = $Description;
            [void] $GroupBox.Controls.Add($Label);
        }
        [System.Windows.Forms.TextBox] $TextBox = [System.Windows.Forms.TextBox]::new();
        $TextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left + [System.Windows.Forms.AnchorStyles]::Right;
        $TextBox.Location = [System.Drawing.Point]::new(6, 22);
        $TextBox.Name = [String]::Format("TextBox{0}", $Name);
        $Global:Session.PromptsUI.LastTabIndex ++;
        $TextBox.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
        $TextBox.Size = [System.Drawing.Size]::new(448, 23);
        $TextBox.Text = (
            (![String]::IsNullOrEmpty($Default)) ?
                $Default :
                ""
        );
        [void] $GroupBox.Controls.Add($TextBox);
        $ReturnValue.PromptControl = $GroupBox;
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.PromptsUI `
    -Name "GetDatePrompt" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [String] $Name,
            [String] $Label,
            [String] $Description,
            [DateTime] $Default,
            [String] $IsRequired
        )
        [PSObject] $ReturnValue = [PSObject]::new();
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Type" -NotePropertyValue "Date";
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue $Name;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Label" -NotePropertyValue $Label;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Description" -NotePropertyValue $Description;
        Add-Member -InputObject $ReturnValue -TypeName "System.DateTime" -NotePropertyName "Default" -NotePropertyValue $Default;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "IsRequired" -NotePropertyValue $IsRequired;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "IsProvided" -NotePropertyValue $false;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "ValidationMessage" -NotePropertyValue $null;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "ValueControlName" -NotePropertyValue ([String]::Format("DateTimePicker{0}", $Name));
        Add-Member -InputObject $ReturnValue -TypeName "System.Windows.Forms.GroupBox" -NotePropertyName "PromptControl" -NotePropertyValue $null;
        [System.Windows.Forms.GroupBox] $GroupBox = [System.Windows.Forms.GroupBox]::new();
        #$GroupBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left + [System.Windows.Forms.AnchorStyles]::Right;
        $GroupBox.Location = [System.Drawing.Point]::new(12, 12);
        $GroupBox.Name = [String]::Format("GroupBox{0}", $Name);
        $GroupBox.Text = $Label;
        If ([String]::IsNullOrEmpty($Description))
        {
            $GroupBox.Size = [System.Drawing.Size]::new(460, 57);
        }
        Else
        {
            $GroupBox.Size = [System.Drawing.Size]::new(460, 71);
            [System.Windows.Forms.Label] $Label = [System.Windows.Forms.Label]::new();
            $Label.AutoSize = $true;
            $Label.Location = [System.Drawing.Point]::new(6, 48);
            $Label.Name = [String]::Format("Label{0}", $Name);
            $Label.Size = [System.Drawing.Size]::new(205, 15);
            $Label.Text = $Description;
            [void] $GroupBox.Controls.Add($Label);
        }
        [System.Windows.Forms.DateTimePicker] $DateTimePicker = [System.Windows.Forms.DateTimePicker]::new();
        $DateTimePicker.Anchor = [System.Windows.Forms.AnchorStyles]::Left + [System.Windows.Forms.AnchorStyles]::Right;
        $DateTimePicker.CustomFormat = "yyyy-MM-dd";
        $DateTimePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom;
        $DateTimePicker.Location = [System.Drawing.Point]::new(6, 22);
        $DateTimePicker.Name = [String]::Format("DateTimePicker{0}", $Name);
        $Global:Session.PromptsUI.LastTabIndex ++;
        $DateTimePicker.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
        $DateTimePicker.Size = [System.Drawing.Size]::new(448, 23);
        $DateTimePicker.Value = (
            (
                $Default -ne [DateTime]::MinValue -and
                $Default -ne [DateTime]::MaxValue
            ) ?
                $Default :
                [DateTime]::Now
        );
        [void] $GroupBox.Controls.Add($DateTimePicker);
        $ReturnValue.PromptControl = $GroupBox;
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.PromptsUI `
    -Name "GetMaskedPrompt" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [String] $Name,
            [String] $Label,
            [String] $Description,
            [String] $IsRequired
        )
        [PSObject] $ReturnValue = [PSObject]::new();
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Type" -NotePropertyValue "Masked";
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue $Name;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Label" -NotePropertyValue $Label;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Description" -NotePropertyValue $Description;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Default" -NotePropertyValue $null;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "IsRequired" -NotePropertyValue $IsRequired;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "IsProvided" -NotePropertyValue $false;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "ValidationMessage" -NotePropertyValue $null;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "ValueControlName" -NotePropertyValue ([String]::Format("TextBox{0}", $Name));
        Add-Member -InputObject $ReturnValue -TypeName "System.Windows.Forms.GroupBox" -NotePropertyName "PromptControl" -NotePropertyValue $null;
        [System.Windows.Forms.GroupBox] $GroupBox = [System.Windows.Forms.GroupBox]::new();
        $GroupBox.Location = [System.Drawing.Point]::new(12, 12);
        $GroupBox.Name = [String]::Format("GroupBox{0}", $Name);
        $GroupBox.Text = $Label;
        If ([String]::IsNullOrEmpty($Description))
        {
            $GroupBox.Size = [System.Drawing.Size]::new(460, 57);
        }
        Else
        {
            $GroupBox.Size = [System.Drawing.Size]::new(460, 129);
            [System.Windows.Forms.Label] $Label = [System.Windows.Forms.Label]::new();
            $Label.AutoSize = $true;
            $Label.Location = [System.Drawing.Point]::new(6, 48);
            $Label.Name = [String]::Format("Label{0}", $Name);
            $Label.Size = [System.Drawing.Size]::new(205, 15);
            $Label.Text = $Description;
            [void] $GroupBox.Controls.Add($Label);
        }

        [System.Windows.Forms.TextBox] $TextBox = [System.Windows.Forms.TextBox]::new();
        $TextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left + [System.Windows.Forms.AnchorStyles]::Right;
        $TextBox.Location = [System.Drawing.Point]::new(6, 22);
        $TextBox.Name = [String]::Format("TextBox{0}", $Name);
        $Global:Session.PromptsUI.LastTabIndex ++;
        $TextBox.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
        $TextBox.Size = [System.Drawing.Size]::new(448, 23);
        $TextBox.PasswordChar = "•";
        [void] $GroupBox.Controls.Add($TextBox);

        [System.Windows.Forms.Label] $LabelConfirm = [System.Windows.Forms.Label]::new();
        $LabelConfirm.AutoSize = $true;
        $LabelConfirm.Location = [System.Drawing.Point]::new(6, 73);
        $LabelConfirm.Name = [String]::Format("Label{0}Confirm", $Name);
        $LabelConfirm.Size = [System.Drawing.Size]::new(205, 15);
        $LabelConfirm.Text = "Confirm Entry";
        [void] $GroupBox.Controls.Add($LabelConfirm);


        [System.Windows.Forms.TextBox] $TextBoxConfirm = [System.Windows.Forms.TextBox]::new();
        $TextBoxConfirm.Anchor = [System.Windows.Forms.AnchorStyles]::Left + [System.Windows.Forms.AnchorStyles]::Right;
        $TextBoxConfirm.Location = [System.Drawing.Point]::new(6, 95);
        $TextBoxConfirm.Name = [String]::Format("TextBox{0}Confirm", $Name);
        $Global:Session.PromptsUI.LastTabIndex ++;
        $TextBoxConfirm.TabIndex = $Global:Session.PromptsUI.LastTabIndex;
        $TextBoxConfirm.Size = [System.Drawing.Size]::new(448, 23);
        [void] $GroupBox.Controls.Add($TextBoxConfirm);

        $ReturnValue.PromptControl = $GroupBox;
        Return $ReturnValue;
    }
