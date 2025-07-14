function loadconfiguration {$script:powershell = Split-Path $profile; $script:baseModulePath = "$powershell\Modules\PSDCreator"; $script:configPath = Join-Path $baseModulePath "PSDCreator.psd1"
if (!(Test-Path $configPath)) {throw "Config file not found at $configPath"}
$script:config = Import-PowerShellDataFile -Path $configPath

# Pull config values into variables
$script:defaultauthour = $config.privatedata.defaultauthour
$script:defaultcompany = $config.privatedata.defaultcompany
$script:defaultcopyrightowner = $config.privatedata.defaultcopyrightowner
$script:defaultmoduleversion = $config.privatedata.defaultmoduleversion
$script:defaultpowershellversion = $config.privatedata.defaultpowershellversion
$script:defaultprojecturi = $config.privatedata.defaultprojecturi
$script:defaultlicenseurisuffix = $config.privatedata.defaultlicenseurisuffix}
loadconfiguration

# Modify fields sent to it with proper word wrapping.
function wordwrap ($field, $maximumlinelength) {if ($null -eq $field) {return $null}
$breakchars = ',.;?!\/ '; $wrapped = @()
if (-not $maximumlinelength) {[int]$maximumlinelength = (100, $Host.UI.RawUI.WindowSize.Width | Measure-Object -Maximum).Maximum}
if ($maximumlinelength -lt 60) {[int]$maximumlinelength = 60}
if ($maximumlinelength -gt $Host.UI.RawUI.BufferSize.Width) {[int]$maximumlinelength = $Host.UI.RawUI.BufferSize.Width}
foreach ($line in $field -split "`n", [System.StringSplitOptions]::None) {if ($line -eq "") {$wrapped += ""; continue}
$remaining = $line
while ($remaining.Length -gt $maximumlinelength) {$segment = $remaining.Substring(0, $maximumlinelength); $breakIndex = -1
foreach ($char in $breakchars.ToCharArray()) {$index = $segment.LastIndexOf($char)
if ($index -gt $breakIndex) {$breakIndex = $index}}
if ($breakIndex -lt 0) {$breakIndex = $maximumlinelength - 1}
$chunk = $segment.Substring(0, $breakIndex + 1); $wrapped += $chunk; $remaining = $remaining.Substring($breakIndex + 1)}
if ($remaining.Length -gt 0 -or $line -eq "") {$wrapped += $remaining}}
return ($wrapped -join "`n")}

# Display a horizontal line.
function line ($colour, $length, [switch]$pre, [switch]$post, [switch]$double) {if (-not $length) {[int]$length = (100, $Host.UI.RawUI.WindowSize.Width | Measure-Object -Maximum).Maximum}
if ($length) {if ($length -lt 60) {[int]$length = 60}
if ($length -gt $Host.UI.RawUI.BufferSize.Width) {[int]$length = $Host.UI.RawUI.BufferSize.Width}}
if ($pre) {Write-Host ""}
$character = if ($double) {"="} else {"-"}
Write-Host -f $colour ($character * $length)
if ($post) {Write-Host ""}}

function help {# Inline help.
function scripthelp ($section) {# (Internal) Generate the help sections from the comments section of the script.
line yellow 100 -pre; $pattern = "(?ims)^## ($section.*?)(##|\z)"; $match = [regex]::Match($scripthelp, $pattern); $lines = $match.Groups[1].Value.TrimEnd() -split "`r?`n", 2; Write-Host $lines[0] -f yellow; line yellow 100
if ($lines.Count -gt 1) {wordwrap $lines[1] 100 | Write-Host -f white | Out-Host -Paging}; line yellow 100}
$scripthelp = Get-Content -Raw -Path $PSCommandPath; $sections = [regex]::Matches($scripthelp, "(?im)^## (.+?)(?=\r?\n)")
if ($sections.Count -eq 1) {cls; Write-Host "$([System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)) Help:" -f cyan; scripthelp $sections[0].Groups[1].Value; ""; return}

$selection = $null
do {cls; Write-Host -f cyan "$(Get-ChildItem (Split-Path $PSCommandPath) | Where-Object { $_.FullName -ieq $PSCommandPath } | Select-Object -ExpandProperty BaseName) Help Sections:`n"
for ($i = 0; $i -lt $sections.Count; $i++) {Write-Host "$($i + 1). " -f cyan -n; Write-Host $sections[$i].Groups[1].Value -f white}
if ($selection) {scripthelp $sections[$selection - 1].Groups[1].Value}
Write-Host -f yellow "`nEnter a section number to view " -n; $input = Read-Host
if ($input -match '^\d+$') {$index = [int]$input
if ($index -ge 1 -and $index -le $sections.Count) {$selection = $index}
else {$selection = $null}} else {""; return}}
while ($true); return}

function PSDCreator ([switch]$defaults, [switch]$help){# Create PSD1 files for newly created modules.

# External call to help.
if ($help) {help; return}

line yellow 100 -pre; Write-Host -f cyan "PSDCreator:"; line yellow 100

Write-Host -f white "Name: " -n; $rootmodule = read-host
if ([string]::IsNullOrWhiteSpace($rootmodule)) {Write-Host -f red "`nThe module must have a name. Aborting.`n"; return}
$rootmodule = if ([System.IO.Path]::HasExtension($rootmodule)) {$rootmodule} else {"$rootmodule.psm1"}

if (-not $defaults) {Write-Host -f white "ModuleVersion (" -n; Write-Host -f yellow "$script:defaultmoduleversion" -n; Write-Host -f white "): " -n; $moduleversion = read-host}
$moduleversion = if ($moduleversion.length -lt 1) {$script:defaultmoduleversion} else {$moduleversion}

$guid = [guid]::NewGuid().ToString()
if (-not $defaults) {Write-Host -f white "GUID: " -n; Write-Host -f yellow $guid}

if (-not $defaults) {Write-Host -f white "Authour (" -n; Write-Host -f yellow "$script:defaultauthour" -n; Write-Host -f white "): " -n; $authour = read-host}
$authour = if ($authour.length -lt 1) {$script:defaultauthour}

if (-not $defaults) {Write-Host -f white "CompanyName (" -n; Write-Host -f yellow "$script:defaultcompany" -n; Write-Host -f white "): " -n; $companyname = read-host}
$companyname = if ($companyname.length -lt 1) {$script:defaultcompany}

$script:defaultcopyrightowner = "© $authour. All rights reserved."
if (-not $defaults) {Write-Host -f white "Copyright (" -n; Write-Host -f yellow "$script:defaultcopyrightowner" -n; Write-Host -f white "): " -n; $copyright = read-host}
$copyright = if ($copyright.length -lt 1) {$script:defaultcopyrightowner}

Write-Host -f white "Description: " -n; $description = read-host

if (-not $defaults) {Write-Host -f white "PowerShellVersion (" -n; Write-Host -f yellow "$script:defaultpowershellversion" -n; Write-Host -f white "): " -n; $powershellversion = read-host}
$powershellversion = if ($powershellversion.length -lt 1) {$script:defaultpowershellversion}

$function = [System.IO.Path]::GetFileNameWithoutExtension($rootmodule)
if (-not $defaults) {Write-Host -f white "FunctionsToExport (" -n; Write-Host -f yellow "$function" -n; Write-Host -f white "): " -n; $functions = read-host}
$functions = if ($functions.Length -gt 0) {($functions -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '} else {"`'$function`'"}

if (-not $defaults) {Write-Host -f white "CmdletsToExport: " -n; $cmdlets = read-host}
$cmdlets = if ($cmdlets.Length -gt 0) {($cmdlets -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '} else {$null}

if (-not $defaults) {Write-Host -f white "VariablesToExport: " -n; $variables = read-host}
$variables = if ($variables.Length -gt 0) {($variables -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '} else {$null}

if (-not $defaults) {Write-Host -f white "AliasesToExport: " -n; $aliases = read-host}
$aliases = if ($aliases.Length -gt 0) {($aliases -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '} else {$null}

$defaultfiles = @("'$rootmodule'")
if (-not $defaults) {Write-Host -f white "FileList (" -n; Write-Host -f yellow "$defaultfiles" -n; Write-Host -f white "): " -n; $filelist = read-host}
$filelist = if ($filelist.Length -gt 0) {($filelist -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '} else {"$defaultfiles"}

Write-Host -f white "Tags: " -n; $tags = read-host
$tags = if ($tags.Length -gt 0) {($tags -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '} else {$null}

$defaultlicenseuri = "$defaultprojecturi/$function/$script:defaultlicenseurisuffix"
if (-not $defaults) {Write-Host -f white "LicenseUri (" -n; Write-Host -f yellow "$defaultlicenseuri" -n; Write-Host -f white "): " -n; $licenseuri = read-host}
$licenseuri = if ($licenseuri.length -lt 1) {$defaultlicenseuri}

$script:defaultprojecturi = "$defaultprojecturi/$function"
if (-not $defaults) {Write-Host -f white "ProjectUri (" -n; Write-Host -f yellow "$script:defaultprojecturi" -n; Write-Host -f white "): " -n; $projecturi = read-host}
$projecturi = if ($projecturi.length -lt 1) {$script:defaultprojecturi}

$defaultreleasenotes = "Initial release."
if (-not $defaults) {Write-Host -f white "ReleaseNotes (" -n; Write-Host -f yellow "$defaultreleasenotes" -n; Write-Host -f white "): " -n; $releasenotes = read-host}
$releasenotes = if ($releasenotes.length -lt 1) {$defaultreleasenotes} else {$releasenotes}

$tophalf = "@{RootModule = '$rootmodule'`nModuleVersion = '$moduleversion'`nGUID = '$guid'`nAuthor = '$authour'`nCompanyName = '$companyname'`nCopyright = '$copyright'`nDescription = '$description'`nPowerShellVersion = '$powershellversion'`nFunctionsToExport = @($functions)`nCmdletsToExport = @($cmdlets)`nVariablesToExport = @($variables)`nAliasesToExport = @($aliases)`nFileList = @($filelist)`n`nPrivateData = @{PSData = @{Tags = @($tags)`nLicenseUri = '$licenseuri'`nProjectUri = '$projecturi'`nReleaseNotes = '$releasenotes'}"

line yellow 100; Write-Host -f cyan "How many custom variables do you need to create? " -n; [int]$customcount = read-host
$customVariables = @{}
for ($i = 1; $i -le $customcount; $i++) {Write-Host -f white "`nCustom variable $i name: " -n; $varName = Read-Host
if ([string]::IsNullOrWhiteSpace($varName)) {Write-Host -f yellow "Variable name cannot be empty. Skipping."; continue}
Write-Host -f white "Default value for '$varName': " -n; $varValue = Read-Host
$varValue = ($varValue -split ',' | Sort-Object | ForEach-Object {"'$($_.Trim())'"}) -join ', '; $varValue = $varValue -replace "''", "'"; $customVariables[$varName] = $varValue}
if ($customVariables.Count -gt 0) {$bottomhalf = "`n"; foreach ($key in $customVariables.Keys) {$bottomhalf += "`n$key = $($customVariables[$key])"}}
$bottomhalf += "}}"; $full=$tophalf+$bottomhalf

line yellow 100; Write-Host -f cyan "Confirm output to: " -n; Write-Host -f yellow "$powershell\modules\$function\$function.psd1`n"
Write-Host -f white $full
line yellow 100; Write-Host -f cyan "Continue? (Y/N) " -n; $confirmcontinue = Read-Host
if ($confirmcontinue -match "^[Nn]") {Write-Host -f red "Creation aborted."`n; return}
else {try {$full | Out-File -FilePath "$powershell\modules\$function\$function.psd1" -Encoding UTF8 -Force; Write-Host -f green "$function.psd1 written to disk.`n"}
catch {Write-Host -f red "$_`nWrite failed.`n"}; return}}

Export-ModuleMember -function psdcreator

# Helptext.

<#
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
FileList = @()          <- This defaults to the RootModule.psm1 file.

PrivateData = @{PSData = 
@{Tags = @()}           <- This must be populated at the prompt.
LicenseUri =            <- DefaultLicenseURISuffix is set in PSDCreator.psd1.
                           This appends to ProjectUri, based on standard GitHub URI format.
ProjectUri =            <- This default is set in PSDCreator.psd1.
ReleaseNotes =          <- This defaults to 'Initial release.'
}
CustomFields =          <- All of these and their values are populated at the prompt.
}}
## License
MIT License

Copyright (c) 2025 Craig Plath

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
##>
