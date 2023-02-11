#Requires -Modules Evergreen
<#
    Installs the latest version of Mozilla Firefox 64-bit with automatic update disabled
#>
[CmdletBinding()]
param (
    [System.String] $Path = "$Env:SystemDrive\Apps\Mozilla\Firefox",
    [System.String] $Language = "en-US"
)

#region Script logic
New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null
New-Item -Path "$Env:ProgramData\Evergreen\Logs" -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null

try {
    Import-Module -Name "Evergreen" -Force
    $App = Invoke-EvergreenApp -Name "MozillaFirefox" | `
        Where-Object { $_.Channel -eq "LATEST_FIREFOX_VERSION" -and $_.Architecture -eq "x64" -and $_.Language -eq $Language -and $_.Type -eq "msi" } | `
        Select-Object -First 1
    $OutFile = Save-EvergreenApp -InputObject $App -CustomPath $Path -WarningAction "SilentlyContinue"
}
catch {
    throw $_.Exception.Message
}

try {
    $LogFile = "$Env:ProgramData\Evergreen\Logs\MozillaFirefox$($App.Version).log" -replace " ", ""
    $Options = "DESKTOP_SHORTCUT=false
        TASKBAR_SHORTCUT=false
        INSTALL_MAINTENANCE_SERVICE=false
        REMOVE_DISTRIBUTION_DIR=true
        PREVENT_REBOOT_REQUIRED=true
        REGISTER_DEFAULT_AGENT=true"
    $params = @{
        FilePath     = "$Env:SystemRoot\System32\msiexec.exe"
        ArgumentList = "/package `"$($OutFile.FullName)`" $($Options -replace "\s+", " ") /quiet /log $LogFile"
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

Start-Sleep -Seconds 5
$Shortcuts = @("$Env:Public\Desktop\Mozilla Firefox.lnk")
Remove-Item -Path $Shortcuts -Force -ErrorAction "Ignore"
#endregion
