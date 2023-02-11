#Requires -Modules Evergreen
<#
    Installs Windows Customised Defaults to customise the image and the default profile https://stealthpuppy.com/image-customise/
#>
[CmdletBinding()]
param (
    [System.String] $Path = "$Env:SystemDrive\Apps\image-customise",
    [System.String] $Language = "en-AU",
    [System.String] $AppxMode = "Block"
)

#region Script logic
New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null

try {
    Write-Information -MessageData ":: Install Windows Customised Defaults" -InformationAction "Continue"
    $Installer = Invoke-EvergreenApp -Name "stealthpuppyWindowsCustomisedDefaults" | Where-Object { $_.Type -eq "zip" } | `
        Select-Object -First 1 | `
        Save-EvergreenApp -CustomPath $Path
    Expand-Archive -Path $Installer.FullName -DestinationPath $Path -Force
    $InstallFile = Get-ChildItem -Path $Path -Recurse -Include "Install-Defaults.ps1"
    Push-Location -Path $InstallFile.Directory
    & .\Install-Defaults.ps1 -Language $Language -AppxMode $AppxMode
    Pop-Location
}
catch {
    throw $_.Exception.Message
}
finally {
    Pop-Location
}
#endregion
