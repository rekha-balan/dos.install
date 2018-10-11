$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set-Location $naPath

$ErrorActionPreference = "Stop"

Import-Module Pester

$VerbosePreference = "continue"

$module = "dos-install-common-kube"
Get-Module "$module" | Remove-Module -Force

Import-Module "$here\$module.psm1" -Force

# $module = Get-Module -Name $module
# $module
# $module | Select-Object *


Invoke-Pester "$here\Module.Tests.ps1"

Invoke-Pester "$here\functions\LaunchKubernetesDashboard.Tests.ps1" -Verbose
