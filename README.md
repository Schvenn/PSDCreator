## Overview
PSDCreator creates PSD1 files for new modules and writes them to disk for you, saving time.

     Usage: PSDCreator <-defaults> <-help>

-defaults will bypass all but the necessary fields and will either populate the rest with the defaults configured in the PSD1 file, or leave them empty. The fields that must be populated at the prompt are:

    • Name
    • Description
    • Tags
    • All custom fields
## Fields Written to Disk
All fields below can be modified at the prompt.

    @{RootModule =          <- This must be populated at the prompt.
    ModuleVersion =         <- This default is set in PSDCreator.psd1.
    GUID =                  <- This is created by the function when it is executed.
    Author =                <- This default is set in PSDCreator.psd1.
    CompanyName =           <- This default is set in PSDCreator.psd1.
    Copyright =             <- This default is set in PSDCreator.psd1.
    Description =           <- This must be populated at the prompt.
    PowerShellVersion =     <- This default is set in PSDCreator.psd1.
    FunctionsToExport = @() <- This defaults to the RootModule name.
    CmdletsToExport = @()   <- This is optional.
    VariablesToExport = @() <- This is optional.
    AliasesToExport = @()   <- This is optional.
    FileList = @()          <- This defaults to the RootModule name as the PSM1 file and license.txt
    
    PrivateData = @{PSData = 
    @{Tags = @()}           <- This must be populated at the prompt.
    LicenseUri =            <- DefaultLicenseURISuffix is set in PSDCreator.psd1.
                               This appends to ProjectUri, based on standard GitHub URI format.
    ProjectUri =            <- This default is set in PSDCreator.psd1.
    ReleaseNotes =          <- This defaults to 'Initial release.'
    
    CustomFields =          <- All of these and their values are populated at the prompt.
    }}
