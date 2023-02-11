#Requires -Modules PSWindowsUpdate
<#
    Installs all available Windows updates with PSWindowsUpdate
#>
[CmdletBinding()]
param ()

try {
    # Delete the policy setting created by MDT
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f | Out-Null

    # Install updates
    Write-Information -MessageData ":: Installing Windows updates" -InformationAction "Continue"
    Import-Module -Name "PSWindowsUpdate"
    Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -IgnoreReboot
}
catch {
    throw $_.Exception.Message
}
