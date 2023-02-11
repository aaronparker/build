#Requires -Modules VcRedist
<#
    Installs the supported Microsoft Visual C++ Redistributables (2012, 2013, 2022)
#>
[CmdletBinding()]
param (
    [System.String] $Path = "$Env:SystemDrive\Apps\Microsoft\VcRedist"
)

#region Script logic
New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null

# Run tasks/install apps
try {
    Import-Module -Name "VcRedist" -Force
    Save-VcRedist -VcList (Get-VcList) -Path $Path | Out-Null
}
catch {
    throw $_.Exception.Message
}

try {
    Write-Information -MessageData ":: Install Microsoft Visual C++ Redistributables" -InformationAction "Continue"
    Install-VcRedist -VcList (Get-VcList) -Path $Path -Silent | Out-Null
}
catch {
    throw $_.Exception.Message
}
#endregion
