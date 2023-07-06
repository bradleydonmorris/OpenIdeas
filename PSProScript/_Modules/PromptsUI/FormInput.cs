using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml.Linq;
using static System.Windows.Forms.Design.AxImporter;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using ComboBox = System.Windows.Forms.ComboBox;
using Label = System.Windows.Forms.Label;
using TextBox = System.Windows.Forms.TextBox;
using Button = System.Windows.Forms.Button;

namespace PSProPrompt
{
    public class FormInput : Form
    {
        private Button ButtonCancel;
        private Button ButtonOkay;
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }
        private void InitializeComponent()
        {
            ButtonCancel = new Button();
            ButtonOkay = new Button();
            SuspendLayout();
            // 
            // ButtonCancel
            // 
            ButtonCancel.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            ButtonCancel.DialogResult = DialogResult.Cancel;
            ButtonCancel.Location = new Point(397, 426);
            ButtonCancel.Name = "ButtonCancel";
            ButtonCancel.Size = new Size(75, 23);
            ButtonCancel.TabIndex = 4;
            ButtonCancel.Text = "Cancel";
            ButtonCancel.UseVisualStyleBackColor = true;
            ButtonCancel.Click += ButtonCancel_Click;
            // 
            // ButtonOkay
            // 
            ButtonOkay.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            ButtonOkay.DialogResult = DialogResult.OK;
            ButtonOkay.Location = new Point(316, 426);
            ButtonOkay.Name = "ButtonOkay";
            ButtonOkay.Size = new Size(75, 23);
            ButtonOkay.TabIndex = 3;
            ButtonOkay.Text = "Okay";
            ButtonOkay.UseVisualStyleBackColor = true;
            ButtonOkay.Click += ButtonOkay_Click;
            // 
            // FormInput
            // 
            AcceptButton = ButtonOkay;
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = SystemColors.ControlDark;
            CancelButton = ButtonCancel;
            ClientSize = new Size(484, 461);
            Controls.Add(ButtonCancel);
            Controls.Add(ButtonOkay);
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "FormInput";
            ShowIcon = false;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "FormInput";
            ResumeLayout(false);
        }


        private readonly List<Prompt> Prompts = new();
        private Int32 NextTop = 12;
        private Int32 LastTabIndex = (-1);

        #region Add Prompts
        public void AddStringPrompt(String name, String label, String? description, Boolean isRequired, String? defaultValue)
            => this.Prompts.Add(new StringPrompt(name, label, description, isRequired, defaultValue));
        public void AddMaskedPrompt(String name, String label, String? description, Boolean isRequired)
            => this.Prompts.Add(new MaskedPrompt(name, label, description, isRequired));
        public void AddDatePrompt(String name, String label, String? description, Boolean isRequired, DateTime? defaultValue)
            => this.Prompts.Add(new DatePrompt(name, label, description, isRequired, defaultValue));
        public void AddDateTimePrompt(String name, String label, String? description, Boolean isRequired, DateTime? defaultValue, TimeZoneInfo? timeZoneInfo)
            => this.Prompts.Add(new DateTimePrompt(name, label, description, isRequired, defaultValue, timeZoneInfo));
        public void AddNumericPrompt(String name, String label, String? description, Boolean isRequired, Double? defaultValue)
            => this.Prompts.Add(new NumericPrompt(name, label, description, isRequired, defaultValue));
        public void AddIntegerPrompt(String name, String label, String? description, Boolean isRequired, Int32? defaultValue)
            => this.Prompts.Add(new IntegerPrompt(name, label, description, isRequired, defaultValue));
        public void AddDateRangePrompt(String name, String label, String? description, Boolean isRequired, DateTime? defaultValue, DateTime minValue, DateTime maxValue)
            => this.Prompts.Add(new DateRangePrompt(name, label, description, isRequired, defaultValue, minValue, maxValue));
        public void AddDateTimeRangePrompt(String name, String label, String? description, Boolean isRequired, DateTime? defaultValue, TimeZoneInfo? timeZoneInfo, DateTime minValue, DateTime maxValue)
            => this.Prompts.Add(new DateTimeRangePrompt(name, label, description, isRequired, defaultValue, timeZoneInfo, minValue, maxValue));
        public void AddNumericRangePrompt(String name, String label, String? description, Boolean isRequired, Double? defaultValue, Double minValue, Double maxValue)
            => this.Prompts.Add(new NumericRangePrompt(name, label, description, isRequired, defaultValue, minValue, maxValue));
        public void AddIntegerRangePrompt(String name, String label, String? description, Boolean isRequired, Int32? defaultValue, Int32 minValue, Int32 maxValue)
            => this.Prompts.Add(new IntegerRangePrompt(name, label, description, isRequired, defaultValue, minValue, maxValue));
        public void AddBooleanPrompt(String name, String label, String? description, Boolean isRequired, Boolean? defaultValue)
            => this.Prompts.Add(new BooleanPrompt(name, label, description, isRequired, defaultValue));
        public void AddBooleanPrompt(String name, String label, String? description, Boolean isRequired, Boolean? defaultValue, String positiveLabel, String negativeLabel, String? nullLabel)
            => this.Prompts.Add(new BooleanPrompt(name, label, description, isRequired, defaultValue, positiveLabel, negativeLabel, nullLabel));
        public void AddDropDownPrompt(String name, String label, String? description, Boolean isRequired, String? defaultValue, params String[] options)
            => this.Prompts.Add(new DropDownPrompt(name, label, description, isRequired, defaultValue, options));
        public void AddDropDownPrompt(String name, String label, String? description, Boolean isRequired, String? defaultValue, String? nullLabel, params String[] options)
            => this.Prompts.Add(new DropDownPrompt(name, label, description, isRequired, defaultValue, nullLabel, options));
        #endregion Add Prompts


        #region Build Prompts
        private void BuildStringPrompt(StringPrompt? prompt)
        {
            if (prompt is not null)
            {
                GroupBox groupBox = new()
                {
                    Text = prompt.Label,
                    Location = new Point(12, this.NextTop),
                    Size = new Size(460,
                        String.IsNullOrEmpty(prompt.Description)
                        ? 57 : 71
                    ),
                    BackColor = SystemColors.Control,
                    Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
                };
                this.LastTabIndex++;
                groupBox.Controls.Add(new TextBox()
                {
                    Name = prompt.ValueControlName,
                    TabIndex = this.LastTabIndex,
                    Size = new Size(448, 23),
                    Location = new Point(6, 22),
                    Text = (
                        String.IsNullOrEmpty(prompt.TypedDefaultValue)
                        ? ""
                        : prompt.TypedDefaultValue
                    ),
                    Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
                });
                if (!String.IsNullOrEmpty(prompt.Description))
                {
                    groupBox.Controls.Add(new Label()
                    {
                        Name = String.Format("Label{0}", prompt.Name),
                        Text = prompt.Description,
                        AutoSize = true,
                        Location = new Point(6, 48),
                        Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
                    });
                }
                this.NextTop = groupBox.Top + groupBox.Height + 10;
                this.Controls.Add(groupBox);
            }
        }

        // private void BuildMaskedPrompt(MaskedPrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 (String.IsNullOrEmpty(prompt.Description)
        //                     ? 109 : 137
        //                 )
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new TextBox()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             PasswordChar = '•',
        //             Text = (
        //                 String.IsNullOrEmpty(prompt.TypedDefaultValue)
        //                     ? ""
        //                     : prompt.TypedDefaultValue
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
        //         });
        //         groupBox.Controls.Add(new Label()
        //         {
        //             Name = String.Format("Label{0}Confirm", prompt.Name),
        //             Text = "Confirm Entry",
        //             AutoSize = true,
        //             Location = new Point(6, 57),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //         });
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new TextBox()
        //         {
        //             Name = String.Format("{0}Confirm", prompt.ValueControlName),
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 75),
        //             PasswordChar = '•',
        //             Text = (
        //                 String.IsNullOrEmpty(prompt.TypedDefaultValue)
        //                 ? ""
        //                 : prompt.TypedDefaultValue
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
        //         });
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 107),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildDatePrompt(DatePrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new DateTimePicker()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Format = DateTimePickerFormat.Custom,
        //             CustomFormat = "yyyy-MM-dd",
        //             Value = (
        //                 (prompt.TypedValue == DateTime.UnixEpoch)
        //                     ? DateTime.Now.Date
        //                     : prompt.TypedDefaultValue ?? DateTime.Now.Date
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
        //         });
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildDateTimePrompt(DateTimePrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new DateTimePicker()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(130, 23),
        //             Location = new Point(6, 22),
        //             Format = DateTimePickerFormat.Custom,
        //             CustomFormat = "yyyy-MM-dd HH:mm",
        //             Value = (
        //                 (prompt.TypedValue == DateTime.UnixEpoch)
        //                     ? DateTime.Now
        //                     : prompt.TypedDefaultValue ?? DateTime.Now
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
        //         });
        //         this.LastTabIndex++;
        //         ComboBox comboBox = new()
        //         {
        //             Name = String.Format("ComboBox{0}", prompt.Name),
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(312, 23),
        //             Location = new Point(142, 22),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //             DropDownStyle = ComboBoxStyle.DropDownList
        //         };
        //         foreach (TimeZoneInfo timeZoneInfo in TimeZoneInfo.GetSystemTimeZones())
        //         {
        //             comboBox.Items.Add(timeZoneInfo);
        //         }
        //         comboBox.SelectedItem = prompt.TimeZoneInfo;
        //         groupBox.Controls.Add(comboBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildNumericPrompt(NumericPrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         TextBox textBox = new()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Text = (
        //                 String.IsNullOrEmpty(prompt.TypedDefaultValue.ToString())
        //                 ? ""
        //                 : prompt.TypedDefaultValue.ToString()
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //         };
        //         textBox.KeyPress += this.Numeric_KeyPress;
        //         groupBox.Controls.Add(textBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildIntegerPrompt(IntegerPrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         TextBox textBox = new()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Text = (
        //                 String.IsNullOrEmpty(prompt.TypedDefaultValue.ToString())
        //                 ? ""
        //                 : prompt.TypedDefaultValue.ToString()
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //         };
        //         textBox.KeyPress += this.Integer_KeyPress;
        //         groupBox.Controls.Add(textBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildDateRangePrompt(DateRangePrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new DateTimePicker()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Format = DateTimePickerFormat.Custom,
        //             CustomFormat = "yyyy-MM-dd",
        //             Value = (
        //                 (prompt.TypedValue == DateTime.UnixEpoch)
        //                     ? DateTime.Now.Date
        //                     : prompt.TypedDefaultValue ?? DateTime.Now.Date
        //             ),
        //             MinDate = prompt.MinValue,
        //             MaxDate = prompt.MaxValue,
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
        //         });
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildDateTimeRangePrompt(DateTimeRangePrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new DateTimePicker()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(130, 23),
        //             Location = new Point(6, 22),
        //             Format = DateTimePickerFormat.Custom,
        //             CustomFormat = "yyyy-MM-dd HH:mm",
        //             Value = (
        //                 (prompt.TypedValue == DateTime.UnixEpoch)
        //                     ? DateTime.Now
        //                     : prompt.TypedDefaultValue ?? DateTime.Now
        //             ),
        //             MinDate = prompt.MinValue,
        //             MaxDate = prompt.MaxValue,
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point)
        //         });
        //         this.LastTabIndex++;
        //         ComboBox comboBox = new()
        //         {
        //             Name = String.Format("ComboBox{0}", prompt.Name),
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(312, 23),
        //             Location = new Point(142, 22),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //             DropDownStyle = ComboBoxStyle.DropDownList
        //         };
        //         foreach (TimeZoneInfo timeZoneInfo in TimeZoneInfo.GetSystemTimeZones())
        //         {
        //             comboBox.Items.Add(timeZoneInfo);
        //         }
        //         comboBox.SelectedItem = prompt.TimeZoneInfo;
        //         groupBox.Controls.Add(comboBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildNumericRangePrompt(NumericRangePrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         TextBox textBox = new()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Text = (
        //                 String.IsNullOrEmpty(prompt.TypedDefaultValue.ToString())
        //                 ? ""
        //                 : prompt.TypedDefaultValue.ToString()
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //         };
        //         textBox.KeyPress += this.Numeric_KeyPress;
        //         groupBox.Controls.Add(textBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildIntegerRangePrompt(IntegerRangePrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         TextBox textBox = new()
        //         {
        //             Name = prompt.ValueControlName,
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Text = (
        //                 String.IsNullOrEmpty(prompt.TypedDefaultValue.ToString())
        //                 ? ""
        //                 : prompt.TypedDefaultValue.ToString()
        //             ),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //         };
        //         textBox.KeyPress += this.Integer_KeyPress;
        //         groupBox.Controls.Add(textBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildBooleanPrompt(BooleanPrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new RadioButton()
        //         {
        //             Name = String.Format("{0}Positive", prompt.ValueControlName),
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(120, 19),
        //             Location = new Point(6, 22),
        //             Text = prompt.PositiveLabel,
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //             Checked = (prompt.TypedDefaultValue.HasValue && prompt.TypedDefaultValue.Value)
        //         });
        //         this.LastTabIndex++;
        //         groupBox.Controls.Add(new RadioButton()
        //         {
        //             Name = String.Format("{0}Negative", prompt.ValueControlName),
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(120, 19),
        //             Location = new Point(132, 22),
        //             Text = prompt.NegativeLabel,
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //             Checked = (prompt.TypedDefaultValue.HasValue && !prompt.TypedDefaultValue.Value)
        //         });
        //         if (!prompt.IsRequired)
        //         {
        //             this.LastTabIndex++;
        //             groupBox.Controls.Add(new RadioButton()
        //             {
        //                 Name = String.Format("{0}Null", prompt.ValueControlName),
        //                 TabIndex = this.LastTabIndex,
        //                 Size = new Size(120, 19),
        //                 Location = new Point(258, 22),
        //                 Text = prompt.NullLabel,
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //                 Checked = !prompt.TypedDefaultValue.HasValue
        //             });
        //         }
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }

        // private void BuildDropDownPrompt(DropDownPrompt? prompt)
        // {
        //     if (prompt is not null)
        //     {
        //         GroupBox groupBox = new()
        //         {
        //             Text = prompt.Label,
        //             Location = new Point(12, this.NextTop),
        //             Size = new Size(460,
        //                 String.IsNullOrEmpty(prompt.Description)
        //                 ? 57 : 71
        //             ),
        //             BackColor = SystemColors.Control,
        //             Font = new Font("Segoe UI", 11F, FontStyle.Bold, GraphicsUnit.Point)
        //         };
        //         this.LastTabIndex++;
        //         ComboBox comboBox = new()
        //         {
        //             Name = String.Format("TextBox{0}", prompt.Name),
        //             TabIndex = this.LastTabIndex,
        //             Size = new Size(448, 23),
        //             Location = new Point(6, 22),
        //             Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point),
        //             DropDownStyle = ComboBoxStyle.DropDownList
        //         };
        //         if (!prompt.IsRequired)
        //             comboBox.Items.Add(prompt.NullLabel);
        //         foreach (String item in prompt.Options)
        //             comboBox.Items.Add(item);
        //         if (prompt.TypedDefaultValue is not null)
        //             comboBox.SelectedItem = prompt.TypedDefaultValue;
        //         groupBox.Controls.Add(comboBox);
        //         if (!String.IsNullOrEmpty(prompt.Description))
        //         {
        //             groupBox.Controls.Add(new Label()
        //             {
        //                 Name = String.Format("Label{0}", prompt.Name),
        //                 Text = prompt.Description,
        //                 AutoSize = true,
        //                 Location = new Point(6, 48),
        //                 Font = new Font("Segoe UI", 9F, FontStyle.Italic, GraphicsUnit.Point)
        //             });
        //         }
        //         this.NextTop = groupBox.Top + groupBox.Height + 10;
        //         this.Controls.Add(groupBox);
        //     }
        // }
        #endregion Build Prompts

        private Boolean ValidatePrompts()
        {
            foreach (var prompt in this.Prompts)
            {
                switch (prompt.Type)
                {
                    case PromptType.String:
                        (prompt as StringPrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as TextBox)?.Text
                        );
                        break;
                    case PromptType.Masked:
                        (prompt as MaskedPrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as TextBox)?.Text,
                            (this.Controls.Find(String.Format("{0}Confirm", prompt.ValueControlName), true).FirstOrDefault() as TextBox)?.Text
                        );
                        break;
                    case PromptType.Date:
                        (prompt as DatePrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as DateTimePicker)?.Value
                        );
                        break;
                    case PromptType.DateTime:
                        (prompt as DateTimePrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as DateTimePicker)?.Value
                        );
                        break;
                    case PromptType.Numeric:
                        (prompt as NumericPrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as TextBox)?.Text
                        );
                        break;
                    case PromptType.Integer:
                        (prompt as IntegerPrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as TextBox)?.Text
                        );
                        break;
                    case PromptType.DateRange:
                        (prompt as DateRangePrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as DateTimePicker)?.Value
                        );
                        break;
                    case PromptType.DateTimeRange:
                        (prompt as DateTimeRangePrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as DateTimePicker)?.Value
                        );
                        break;
                    case PromptType.NumericRange:
                        (prompt as NumericRangePrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as TextBox)?.Text
                        );
                        break;
                    case PromptType.IntegerRange:
                        (prompt as IntegerRangePrompt)?.Validate(
                            (this.Controls.Find(prompt.ValueControlName, true).FirstOrDefault() as TextBox)?.Text
                        );
                        break;
                    case PromptType.Boolean:
                        (prompt as BooleanPrompt)?.Validate(
                            (this.Controls.Find(String.Format("{0}Positive", prompt.ValueControlName), true).FirstOrDefault() as RadioButton)?.Checked,
                            (this.Controls.Find(String.Format("{0}Negative", prompt.ValueControlName), true).FirstOrDefault() as RadioButton)?.Checked,
                            (this.Controls.Find(String.Format("{0}Positive", prompt.ValueControlName), true).FirstOrDefault() as RadioButton)?.Checked
                        );
                        break;
                    case PromptType.DropDown:
                        (prompt as DropDownPrompt)?.Validate(
                            (this.Controls.Find(String.Format("{0}", prompt.ValueControlName), true).FirstOrDefault() as ComboBox)?.SelectedText
                        );
                        break;
                }
            }
            return !this.Prompts.Exists(p => !p.IsValid);
        }

        public FormInput()
        {
            InitializeComponent();
            this.SuspendLayout();
            foreach (var prompt in this.Prompts)
            {
                switch (prompt.Type)
                {
                    case PromptType.String:
                        this.BuildStringPrompt(prompt as StringPrompt);
                        break;
                    // case PromptType.Masked:
                    //     this.BuildMaskedPrompt(prompt as MaskedPrompt);
                    //     break;
                    // case PromptType.Date:
                    //     this.BuildDatePrompt(prompt as DatePrompt);
                    //     break;
                    // case PromptType.DateTime:
                    //     this.BuildDateTimePrompt(prompt as DateTimePrompt);
                    //     break;
                    // case PromptType.Numeric:
                    //     this.BuildNumericPrompt(prompt as NumericPrompt);
                    //     break;
                    // case PromptType.Integer:
                    //     this.BuildIntegerPrompt(prompt as IntegerPrompt);
                    //     break;
                    // case PromptType.DateRange:
                    //     this.BuildDateRangePrompt(prompt as DateRangePrompt);
                    //     break;
                    // case PromptType.DateTimeRange:
                    //     this.BuildDateTimeRangePrompt(prompt as DateTimeRangePrompt);
                    //     break;
                    // case PromptType.NumericRange:
                    //     this.BuildNumericRangePrompt(prompt as NumericRangePrompt);
                    //     break;
                    // case PromptType.IntegerRange:
                    //     this.BuildIntegerRangePrompt(prompt as IntegerRangePrompt);
                    //     break;
                    // case PromptType.Boolean:
                    //     this.BuildBooleanPrompt(prompt as BooleanPrompt);
                    //     break;
                    // case PromptType.DropDown:
                    //     this.BuildDropDownPrompt(prompt as DropDownPrompt);
                    //     break;
                }
            }
            this.Height = this.NextTop + this.ButtonOkay.Height + 55;
            this.ResumeLayout(true);
        }

        private void Numeric_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (
                !Char.IsControl(e.KeyChar)
                && !Char.IsDigit(e.KeyChar)
                && (e.KeyChar != '.')
            )
            {
                e.Handled = true;
            }
            else if (
                (e.KeyChar == '.')
                && ((sender as TextBox)?.Text.IndexOf('.') > -1)
              )
            {
                e.Handled = true;
            }
        }

        private void Integer_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (
                !Char.IsControl(e.KeyChar)
                && !Char.IsDigit(e.KeyChar)
            )
            {
                e.Handled = true;
            }
        }

        private void ButtonOkay_Click(object sender, EventArgs e)
        {
            if (!this.ValidatePrompts())
            {
                String message = "Please check your entries.\r\n";
                foreach (Prompt prompt in this.Prompts.Where(p => !p.IsValid))
                    message += String.Format("\t{0}\r\n", prompt.ValidationMessage);
                MessageBox.Show(this, message, "Invalid Entries!", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
            {
                this.Hide();
                //Application.Exit();
            }
        }

        private void ButtonCancel_Click(object sender, EventArgs e)
        {
            this.Hide();
            //Application.Exit();
        }
    }

    public enum PromptType
    {
        String = 1,
        Masked = 2,
        Date = 3,
        DateTime = 4,
        Numeric = 5,
        Integer = 6,
        DateRange = 7,
        DateTimeRange = 8,
        NumericRange = 9,
        IntegerRange = 10,
        Boolean = 11,
        DropDown = 12
    }

    public class Prompt
    {
        public PromptType Type { get; set; }
        public String Name { get; set; }
        public String Label { get; set; }
        public String? Description { get; set; }
        public Object? DefaultValue { get; set; }
        public Object? Value { get; set; }
        public Boolean IsRequired { get; set; }
        public Boolean IsValid { get; set; }
        public String? ValidationMessage { get; set; }
        public String? ValueControlName { get; set; }

        public Prompt(PromptType type, String name, String label, String? description, Boolean isRequired, Object? defaultValue, String valueControlName)
        {
            this.Type = type;
            this.Name = name;
            this.Label = label;
            this.Description = description;
            this.DefaultValue = defaultValue;
            this.Value = null;
            this.IsRequired = isRequired;
            this.IsValid = false;
            this.ValueControlName = valueControlName;
        }

        public void Validate()
        {
            this.IsValid = false;
        }
    }
    public class StringPrompt : Prompt
    {
        public String? TypedValue { get; set; }
        public String? TypedDefaultValue { get; set; }

        public StringPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            String? defaultValue
        )
            : base(PromptType.String, name, label, description, isRequired, defaultValue, String.Format("TextBox{0}", name))
            => this.TypedDefaultValue = defaultValue;

        public void Validate(String? value)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && !String.IsNullOrEmpty(value)
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
    public class MaskedPrompt : Prompt
    {
        public String? TypedValue { get; set; }
        public String? TypedDefaultValue { get; set; }

        public MaskedPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired
        )
            : base(PromptType.Masked, name, label, description, isRequired, null, String.Format("TextBox{0}", name))
        { }

        public void Validate(String? value, String? confirmValue)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && !String.IsNullOrEmpty(value)
                    && !String.IsNullOrEmpty(confirmValue)
                    && value == confirmValue
                )
                ||
                (
                    !this.IsRequired
                    && value == confirmValue
                )
            );
            this.ValidationMessage = this.IsValid
                ? null
                : (value != confirmValue)
                    ? String.Format("\"{0}\" and Confirm must match.", this.Label)
                    : this.IsRequired && String.IsNullOrEmpty(value)
                        ? String.Format("\"{0}\" is required.", this.Label)
                        : null
            ;
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
    public class DatePrompt : Prompt
    {
        public DateTime? TypedValue { get; set; }
        public DateTime? TypedDefaultValue { get; set; }

        public DatePrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            DateTime? defaultValue
        )
            : base(PromptType.Date, name, label, description, isRequired, defaultValue, String.Format("DateTimePicker{0}", name))
        => this.TypedDefaultValue = defaultValue;

        public void Validate(DateTime? value)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && value != DateTime.UnixEpoch.Date
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
    public class DateTimePrompt : Prompt
    {
        public DateTime? TypedValue { get; set; }
        public DateTime? TypedDefaultValue { get; set; }
        public DateTime? TypedValueUTC { get; set; }
        public DateTime? TypedDefaultValueUTC { get; set; }
        public TimeZoneInfo TimeZoneInfo { get; set; }

        public DateTimePrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            DateTime? defaultValue,
            TimeZoneInfo? timeZoneInfo
        )
            : base(PromptType.DateTime, name, label, description, isRequired, defaultValue, String.Format("DateTimePicker{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.TimeZoneInfo = timeZoneInfo ?? TimeZoneInfo.Local;
            this.TypedDefaultValueUTC = 
                (this.TypedDefaultValue?.Kind == DateTimeKind.Utc)
                    ? this.TypedDefaultValueUTC = this.TypedDefaultValue
                    : this.TypedDefaultValueUTC = this.TypedDefaultValue?.ToUniversalTime();
        }

        public void Validate(DateTime? value)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && value != DateTime.UnixEpoch
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
    public class NumericPrompt : Prompt
    {
        public Double? TypedValue { get; set; }
        public Double? TypedDefaultValue { get; set; }

        public NumericPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            Double? defaultValue
        )
            : base(PromptType.Numeric, name, label, description, isRequired, defaultValue, String.Format("TextBox{0}", name))
        => this.TypedDefaultValue = defaultValue;

        public void Validate(String? value)
        {
            Double? typedValue = null;
            if (Double.TryParse(value, out Double result))
                typedValue = result;
            this.IsValid = (
                (
                    this.IsRequired
                    && typedValue.HasValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = typedValue;
            this.Value = this.TypedValue;
        }
    }
    public class IntegerPrompt : Prompt
    {
        public Int32? TypedValue { get; set; }
        public Int32? TypedDefaultValue { get; set; }

        public IntegerPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            Int32? defaultValue
        )
            : base(PromptType.Integer, name, label, description, isRequired, defaultValue, String.Format("TextBox{0}", name))
            => this.TypedDefaultValue = defaultValue;

        public void Validate(String? value)
        {
            Int32? typedValue = null;
            if (Int32.TryParse(value, out Int32 result))
                typedValue = result;
            this.IsValid = (
                (
                    this.IsRequired
                    && typedValue.HasValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = typedValue;
            this.Value = this.TypedValue;
        }
    }
    public class DateRangePrompt : Prompt
    {
        public DateTime? TypedValue { get; set; }
        public DateTime? TypedDefaultValue { get; set; }
        public DateTime MinValue { get; set; }
        public DateTime MaxValue { get; set; }

        public DateRangePrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            DateTime? defaultValue,
            DateTime minValue,
            DateTime maxValue
        )
            : base(PromptType.DateRange, name, label, description, isRequired, defaultValue, String.Format("DateTimePicker{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.MinValue = minValue;
            this.MaxValue = maxValue;
        }

        public void Validate(DateTime? value)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && value.HasValue
                    && value.Value.Date >= this.MinValue
                    && value.Value.Date <= this.MaxValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : (
                    value < this.MinValue
                    || value > this.MaxValue
                )
                    ? String.Format(
                        "\"{0}\" must be between {1} and {2}.",
                        this.Label,
                        this.MinValue.ToString("yyyy-MM-dd"),
                        this.MaxValue.ToString("yyyy-MM-dd")
                    )
                    : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
    public class DateTimeRangePrompt : Prompt
    {
        public DateTime? TypedValue { get; set; }
        public DateTime? TypedDefaultValue { get; set; }
        public DateTime? TypedValueUTC { get; set; }
        public DateTime? TypedDefaultValueUTC { get; set; }
        public TimeZoneInfo TimeZoneInfo { get; set; }
        public DateTime MinValue { get; set; }
        public DateTime MaxValue { get; set; }

        public DateTimeRangePrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            DateTime? defaultValue,
            TimeZoneInfo? timeZoneInfo,
            DateTime minValue,
            DateTime maxValue
        )
            : base(PromptType.DateTimeRange, name, label, description, isRequired, defaultValue, String.Format("DateTimePicker{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.TimeZoneInfo = timeZoneInfo ?? TimeZoneInfo.Local;
            this.TypedDefaultValueUTC =
                (this.TypedDefaultValue?.Kind == DateTimeKind.Utc)
                    ? this.TypedDefaultValueUTC = this.TypedDefaultValue
                    : this.TypedDefaultValueUTC = this.TypedDefaultValue?.ToUniversalTime();
            this.MinValue = minValue;
            this.MaxValue = maxValue;
        }

        public void Validate(DateTime? value)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && value.HasValue
                    && value >= this.MinValue
                    && value <= this.MaxValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : (
                    value < this.MinValue
                    || value > this.MaxValue
                )
                    ? String.Format(
                        "\"{0}\" must be between {1} and {2}.",
                        this.Label,
                        this.MinValue.ToString("yyyy-MM-dd HH:mm:ss"),
                        this.MaxValue.ToString("yyyy-MM-dd HH:mm:ss")
                    )
                    : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
    public class NumericRangePrompt : Prompt
    {
        public Double? TypedValue { get; set; }
        public Double? TypedDefaultValue { get; set; }
        public Double MinValue { get; set; }
        public Double MaxValue { get; set; }

        public NumericRangePrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            Double? defaultValue,
            Double minValue,
            Double maxValue
        )
            : base(PromptType.NumericRange, name, label, description, isRequired, defaultValue, String.Format("TextBox{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.MinValue = minValue;
            this.MaxValue = maxValue;
        }

        public void Validate(String? value)
        {
            Double? typedValue = null;
            if (Double.TryParse(value, out Double result))
                typedValue = result;
            this.IsValid = (
                (
                    this.IsRequired
                    && typedValue.HasValue
                    && typedValue >= this.MinValue
                    && typedValue <= this.MaxValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : (
                    typedValue < this.MinValue
                    || typedValue > this.MaxValue
                )
                    ? String.Format(
                        "\"{0}\" must be between {1} and {2}.",
                        this.Label,
                        this.MinValue,
                        this.MaxValue
                    )
                    : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = typedValue;
            this.Value = this.TypedValue;
        }
    }
    public class IntegerRangePrompt : Prompt
    {
        public Int32? TypedValue { get; set; }
        public Int32? TypedDefaultValue { get; set; }
        public Int32 MinValue { get; set; }
        public Int32 MaxValue { get; set; }

        public IntegerRangePrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            Int32? defaultValue,
            Int32 minValue,
            Int32 maxValue
        )
            : base(PromptType.IntegerRange, name, label, description, isRequired, defaultValue, String.Format("TextBox{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.MinValue = minValue;
            this.MaxValue = maxValue;
        }

        public void Validate(String? value)
        {
            Int32? typedValue = null;
            if (Int32.TryParse(value, out Int32 result))
                typedValue = result;
            this.IsValid = (
                (
                    this.IsRequired
                    && typedValue.HasValue
                    && typedValue >= this.MinValue
                    && typedValue <= this.MaxValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : (
                    typedValue < this.MinValue
                    || typedValue > this.MaxValue
                )
                    ? String.Format(
                        "\"{0}\" must be between {1} and {2}.",
                        this.Label,
                        this.MinValue,
                        this.MaxValue
                    )
                    : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = typedValue;
            this.Value = this.TypedValue;
        }
    }
    public class BooleanPrompt : Prompt
    {
        public Boolean? TypedValue { get; set; }
        public Boolean? TypedDefaultValue { get; set; }
        public String PositiveLabel { get; set; }
        public String NegativeLabel { get; set; }
        public String NullLabel { get; set; }

        public BooleanPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            Boolean? defaultValue
        )
            : base(PromptType.Boolean, name, label, description, isRequired, defaultValue, String.Format("RadioButton{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.PositiveLabel = "Yes";
            this.NegativeLabel = "No";
            this.NullLabel = "Not Specified";
        }

        public BooleanPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            Boolean? defaultValue,
            String positiveLabel,
            String negativeLabel,
            String? nullLabel
        )
            : this(name, label, description, isRequired, defaultValue)
        {
            this.PositiveLabel = positiveLabel;
            this.NegativeLabel = negativeLabel;
            this.NullLabel = (!String.IsNullOrEmpty(nullLabel)
                ? nullLabel
                : "Not Specified"
            );
        }

        public void Validate(Boolean? positiveChecked, Boolean? negativeChecked, Boolean? nullChecked)
        {
            Boolean? typedValue;
            if (positiveChecked is not null && positiveChecked.Value)
                typedValue = true;
            else if (negativeChecked is not null && negativeChecked.Value)
                typedValue = false;
            else if (nullChecked is not null && nullChecked.Value)
                typedValue = null;
            else
                typedValue = null;
            this.IsValid = (
                (
                    this.IsRequired
                    && typedValue.HasValue
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = typedValue;
            this.Value = this.TypedValue;
        }
    }
    public class DropDownPrompt : Prompt
    {
        public String? TypedValue { get; set; }
        public String? TypedDefaultValue { get; set; }
        public List<String> Options { get; set; }
        public String NullLabel { get; set; }

        public DropDownPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            String? defaultValue,
            params String[] options
        )
            : base(PromptType.DropDown, name, label, description, isRequired, defaultValue, String.Format("DropDown{0}", name))
        {
            this.TypedDefaultValue = defaultValue;
            this.Options = new();
            this.Options.AddRange(options);
            this.NullLabel = "Not Specified";
        }

        public DropDownPrompt(
            String name,
            String label,
            String? description,
            Boolean isRequired,
            String? defaultValue,
            String? nullLabel,
            params String[] options
        )
            : this(name, label, description, isRequired, defaultValue, options)
        {
            this.NullLabel = (!String.IsNullOrEmpty(nullLabel)
                ? nullLabel
                : "Not Specified"
            );
        }

        public void Validate(String? value)
        {
            this.IsValid = (
                (
                    this.IsRequired
                    && !String.IsNullOrEmpty(value)
                )
                || !this.IsRequired
            );
            this.ValidationMessage = this.IsValid
                ? null
                : String.Format("\"{0}\" is required.", this.Label);
            this.TypedValue = value;
            this.Value = this.TypedValue;
        }
    }
}
