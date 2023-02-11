#Requires -Modules Evergreen
<#
    Installs the latest Foxit PDF Reader with automatic updates disabled
#>
[CmdletBinding()]
param (
    [System.String] $Path = "$Env:SystemDrive\Apps\Foxit\PDFReader",
    [System.String] $Language = "English"
)

#region Script logic
# Create target folder
New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null
New-Item -Path "$Env:ProgramData\Evergreen\Logs" -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null

try {
    Import-Module -Name "Evergreen" -Force
    $App = Invoke-EvergreenApp -Name "FoxitReader" | Where-Object { $_.Language -eq $Language } | Select-Object -First 1
    $OutFile = Save-EvergreenApp -InputObject $App -CustomPath $Path -WarningAction "SilentlyContinue"
}
catch {
    throw $_.Exception.Message
}

try {
    $LogFile = "$Env:ProgramData\Evergreen\Logs\FoxitPDFReader$($App.Version).log" -replace " ", ""
    $Options = "AUTO_UPDATE=0
        NOTINSTALLUPDATE=1
        MAKEDEFAULT=0
        LAUNCHCHECKDEFAULT=0
        VIEW_IN_BROWSER=0
        DESKTOP_SHORTCUT=0
        STARTMENU_SHORTCUT_UNINSTALL=0
        DISABLE_UNINSTALL_SURVEY=1"
    $params = @{
        FilePath     = "$Env:SystemRoot\System32\msiexec.exe"
        ArgumentList = "/package `"$($OutFile.FullName)`" $($Options -replace "\s+", " ") ALLUSERS=1 /quiet /log $LogFile"
        NoNewWindow  = $true
        Wait         = $true
        PassThru     = $true
        ErrorAction  = "Continue"
    }
    $result = Start-Process @params
    Write-Information -MessageData ":: Install exit code: $($result.ExitCode)" -InformationAction "Continue"
}
catch {
    throw $_.Exception.Message
}

try {
    # Disable update tasks - assuming we're installing on a gold image or updates will be managed
    Get-Service -Name "FoxitReaderUpdateService*" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue"
}
catch {
    throw $_.Exception.Message
}
#endregion
