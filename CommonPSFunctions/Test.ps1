# Split-PDF `
#     -MergedFilePath "C:\Users\bmorris\Downloads\Adult Guardianship Handbook June 2022\Adult-Guardianship-Handbook-June-2022-Checklist.pdf" `
#     -FolderPath "C:\Users\bmorris\Downloads\Adult Guardianship Handbook June 2022\Split";


$Files = @(
    @{ "UpperTitle" = "STEP BY STEP CHECKLIST TO ADULT GUARDIANSHIP"; "ProperTitle" = "Step By Step Checklist To Adult Guardianship"; "FileName" = "01-Step By Step Checklist To Adult Guardianship.pdf"; "BeginPage" = 1; "EndPage" = 9; },
    @{ "UpperTitle" = "FORMS"; "ProperTitle" = "Forms"; "FileName" = "02-Forms.pdf"; "BeginPage" = 10; "EndPage" = 10; },
    @{ "UpperTitle" = "PETITION FOR GUARDIANSHIP"; "ProperTitle" = "Petition For Guardianship"; "FileName" = "03-Petition For Guardianship.pdf"; "BeginPage" = 11; "EndPage" = 13; },
    @{ "UpperTitle" = "NOTICE OF HEARING PETITION FOR GUARDIANSHIP"; "ProperTitle" = "Notice Of Hearing Petition For Guardianship"; "FileName" = "04-Notice Of Hearing Petition For Guardianship.pdf"; "BeginPage" = 14; "EndPage" = 14; },
    @{ "UpperTitle" = "NOTICE OF HEARING PETITION FOR LETTERS OF GUARDIANSHIP"; "ProperTitle" = "Notice Of Hearing Petition For Letters Of Guardianship"; "FileName" = "05-Notice Of Hearing Petition For Letters Of Guardianship.pdf"; "BeginPage" = 15; "EndPage" = 15; },
    @{ "UpperTitle" = "ORDER FOR HEARING PETITION FOR GUARDIANSHIP"; "ProperTitle" = "Order For Hearing Petition For Guardianship"; "FileName" = "06-Order For Hearing Petition For Guardianship.pdf"; "BeginPage" = 16; "EndPage" = 16; },
    @{ "UpperTitle" = "ORDER APPOINTING GENERAL GUARDIAN"; "ProperTitle" = "Order Appointing General Guardian"; "FileName" = "07-Order Appointing General Guardian.pdf"; "BeginPage" = 17; "EndPage" = 19; },
    @{ "UpperTitle" = "LETTERS OF SPECIAL GUARDIANSHIP, GUARDIAN’S OATH"; "ProperTitle" = "Letters Of Special Guardianship, Guardian’S Oath"; "FileName" = "08-Letters Of Special Guardianship, Guardian’S Oath.pdf"; "BeginPage" = 20; "EndPage" = 20; },
    @{ "UpperTitle" = "LETTERS OF GENERAL GUARDIANSHIP, GUARDIAN’S OATH"; "ProperTitle" = "Letters Of General Guardianship, Guardian’S Oath"; "FileName" = "09-Letters Of General Guardianship, Guardian’S Oath.pdf"; "BeginPage" = 21; "EndPage" = 21; },
    @{ "UpperTitle" = "AFFIDAVIT OF MAILING AND PERSONAL SERVICE"; "ProperTitle" = "Affidavit Of Mailing And Personal Service"; "FileName" = "10-Affidavit Of Mailing And Personal Service.pdf"; "BeginPage" = 22; "EndPage" = 22; },
    @{ "UpperTitle" = "ORDER APPOINTING SPECIAL GUARDIAN"; "ProperTitle" = "Order Appointing Special Guardian"; "FileName" = "11-Order Appointing Special Guardian.pdf"; "BeginPage" = 23; "EndPage" = 25; },
    @{ "UpperTitle" = "APPLICATION FOR SPECIAL GUARDIANSHIP"; "ProperTitle" = "Application For Special Guardianship"; "FileName" = "12-Application For Special Guardianship.pdf"; "BeginPage" = 26; "EndPage" = 28; },
    @{ "UpperTitle" = "PAUPER’S AFFIDAVIT"; "ProperTitle" = "Pauper’S Affidavit"; "FileName" = "13-Pauper’S Affidavit.pdf"; "BeginPage" = 29; "EndPage" = 31; },
    @{ "UpperTitle" = "INVENTORY OF WARD’S ESTATE"; "ProperTitle" = "Inventory Of Ward’S Estate"; "FileName" = "14-Inventory Of Ward’S Estate.pdf"; "BeginPage" = 32; "EndPage" = 32; },
    @{ "UpperTitle" = "PLAN FOR THE CARE AND TREATMENT OF THE WARD"; "ProperTitle" = "Plan For The Care And Treatment Of The Ward"; "FileName" = "15-Plan For The Care And Treatment Of The Ward.pdf"; "BeginPage" = 33; "EndPage" = 33; },
    @{ "UpperTitle" = "PLAN FOR THE MANAGEMENT OF THE PROPERTY OF THE WARD"; "ProperTitle" = "Plan For The Management Of The Property Of The Ward"; "FileName" = "16-Plan For The Management Of The Property Of The Ward.pdf"; "BeginPage" = 34; "EndPage" = 34; },
    @{ "UpperTitle" = "ORDER APPROVING THE PLANS FOR CARE AND MANAGEMENT"; "ProperTitle" = "Order Approving The Plans For Care And Management"; "FileName" = "17-Order Approving The Plans For Care And Management.pdf"; "BeginPage" = 35; "EndPage" = 35; },
    @{ "UpperTitle" = "ANNUAL REPORT AND PROPOSED PLAN FOR THE CARE AND TREATMENT OF A WARD AND MANAGEMENT OF THE WARD’S PROPERTY"; "ProperTitle" = "Annual Report And Proposed Plan For The Care And Treatment Of A Ward And Management Of The Ward’S Property"; "FileName" = "18-Annual Report And Proposed Plan For The Care And Treatment Of A Ward And Management Of The Ward’S Property.pdf"; "BeginPage" = 36; "EndPage" = 39; },
    @{ "UpperTitle" = "GUARDIAN’S BOND"; "ProperTitle" = "Guardian’S Bond"; "FileName" = "19-Guardian’S Bond.pdf"; "BeginPage" = 40; "EndPage" = 41; },
    @{ "UpperTitle" = "ORDER APPROVING CONVEYANCE OF REAL PROPERTY"; "ProperTitle" = "Order Approving Conveyance Of Real Property"; "FileName" = "20-Order Approving Conveyance Of Real Property.pdf"; "BeginPage" = 42; "EndPage" = 43; },
    @{ "UpperTitle" = "PETITION FOR CONSERVATORSHIP"; "ProperTitle" = "Petition For Conservatorship"; "FileName" = "21-Petition For Conservatorship.pdf"; "BeginPage" = 44; "EndPage" = 46; },
    @{ "UpperTitle" = "CONSENT BY WARD TO APPOINTMENT OF CONSERVATOR"; "ProperTitle" = "Consent By Ward To Appointment Of Conservator"; "FileName" = "22-Consent By Ward To Appointment Of Conservator.pdf"; "BeginPage" = 47; "EndPage" = 47; },
    @{ "UpperTitle" = "ORDER OF COURT IDENTIFYING WHO RECEIVES NOTICE OF THE PETITION FOR CONSERVATORSHIP"; "ProperTitle" = "Order Of Court Identifying Who Receives Notice Of The Petition For Conservatorship"; "FileName" = "23-Order Of Court Identifying Who Receives Notice Of The Petition For Conservatorship.pdf"; "BeginPage" = 48; "EndPage" = 48; },
    @{ "UpperTitle" = "ORDER APPOINTING CONSERVATOR"; "ProperTitle" = "Order Appointing Conservator"; "FileName" = "24-Order Appointing Conservator.pdf"; "BeginPage" = 49; "EndPage" = 49; },
    @{ "UpperTitle" = "AFFIDAVIT OF MAILING INITIAL REPORT AND PLAN OF MANAGEMENT"; "ProperTitle" = "Affidavit Of Mailing Initial Report And Plan Of Management"; "FileName" = "25-Affidavit Of Mailing Initial Report And Plan Of Management.pdf"; "BeginPage" = 50; "EndPage" = 51; },
    @{ "UpperTitle" = "LETTERS OF CONSERVATORSHIP"; "ProperTitle" = "Letters Of Conservatorship"; "FileName" = "26-Letters Of Conservatorship.pdf"; "BeginPage" = 52; "EndPage" = 52; },
    @{ "UpperTitle" = "OATH OF CONSERVATOR"; "ProperTitle" = "Oath Of Conservator"; "FileName" = "27-Oath Of Conservator.pdf"; "BeginPage" = 53; "EndPage" = 53; },
    @{ "UpperTitle" = "INITIAL REPORT OF CONSERVATOR"; "ProperTitle" = "Initial Report Of Conservator"; "FileName" = "28-Initial Report Of Conservator.pdf"; "BeginPage" = 54; "EndPage" = 54; },
    @{ "UpperTitle" = "PLAN FOR THE MANAGEMENT OF THE WARD’S ESTATE"; "ProperTitle" = "Plan For The Management Of The Ward’S Estate"; "FileName" = "29-Plan For The Management Of The Ward’S Estate.pdf"; "BeginPage" = 55; "EndPage" = 55; },
    @{ "UpperTitle" = "VERIFIED APPLICATION AND PETITION FOR CONVEYANCE OF REAL PROPERTY"; "ProperTitle" = "Verified Application And Petition For Conveyance Of Real Property"; "FileName" = "30-Verified Application And Petition For Conveyance Of Real Property.pdf"; "BeginPage" = 56; "EndPage" = 56; },
    @{ "UpperTitle" = "NOTICE AND ORDER OF HEARING VERIFIED APPLICATION AND PETITION FOR CONVEYANCE OF REAL PROPERTY"; "ProperTitle" = "Notice And Order Of Hearing Verified Application And Petition For Conveyance Of Real Property"; "FileName" = "31-Notice And Order Of Hearing Verified Application And Petition For Conveyance Of Real Property.pdf"; "BeginPage" = 57; "EndPage" = 57; },
    @{ "UpperTitle" = "AFFIDAVIT OF MAILING VERIFIED APPLICATION AND PETITION FOR CONVEYANCE OF REAL PROPERTY"; "ProperTitle" = "Affidavit Of Mailing Verified Application And Petition For Conveyance Of Real Property"; "FileName" = "32-Affidavit Of Mailing Verified Application And Petition For Conveyance Of Real Property.pdf"; "BeginPage" = 58; "EndPage" = 58; },
    @{ "UpperTitle" = "MOTION TO DISCHARGE CONSERVATOR"; "ProperTitle" = "Motion To Discharge Conservator"; "FileName" = "33-Motion To Discharge Conservator.pdf"; "BeginPage" = 59; "EndPage" = 59; },
    @{ "UpperTitle" = "NOTICE AND ORDER OF HEARING APPLICATION FOR DISCHARGE OF CONSERVATOR"; "ProperTitle" = "Notice And Order Of Hearing Application For Discharge Of Conservator"; "FileName" = "34-Notice And Order Of Hearing Application For Discharge Of Conservator.pdf"; "BeginPage" = 60; "EndPage" = 60; },
    @{ "UpperTitle" = "ORDER DISSOLVING CONSERVATORSHIP AND DISCHARGING CONSERVATOR"; "ProperTitle" = "Order Dissolving Conservatorship And Discharging Conservator"; "FileName" = "35-Order Dissolving Conservatorship And Discharging Conservator.pdf"; "BeginPage" = 61; "EndPage" = 62; }
);
[String] $SourceDirectoryPath = "C:\Users\bmorris\Downloads\Adult Guardianship Handbook June 2022\Split";
[String] $DestinationDirectoryPath = "C:\Users\bmorris\Downloads\Adult Guardianship Handbook June 2022\Breakout";
[Collections.Generic.List[String]] $FilePaths = [Collections.Generic.List[String]]::new();
ForEach ($File In $Files)
{
    $DestinationFilePath = [IO.Path]::Combine($DestinationDirectoryPath, $File.FileName);
    If ($File.BeginPage -eq $File.EndPage)
    {
        [String] $SourceFilePath = [IO.Path]::Combine($SourceDirectoryPath, [String]::Format("{0}.pdf", $File.BeginPage.ToString().PadLeft(2, "0")));
        Write-Host -Object $DestinationFilePath;
        Write-Host -Object ([String]::Format("`t{0}", $SourceFilePath));
        Copy-Item -Path $SourceFilePath -Destination $DestinationFilePath;
    }
    Else
    {
        [void] $FilePaths.Clear();
        Write-Host -Object $DestinationFilePath;
        For ($FileNumber = $File.BeginPage; $FileNumber -le $File.EndPage; $FileNumber ++)
        {
            [String] $SourceFilePath = [IO.Path]::Combine($SourceDirectoryPath, [String]::Format("{0}.pdf", $FileNumber.ToString().PadLeft(2, "0")));
            [void] $FilePaths.Add($SourceFilePath);
            Write-Host -Object ([String]::Format("`t{0}", $SourceFilePath));
        }
        Merge-PDFs -MergedFilePath $DestinationFilePath -FilePaths $FilePaths.ToArray();
    }
}
