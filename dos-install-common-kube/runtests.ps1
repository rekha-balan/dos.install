$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

Import-Module Pester

$VerbosePreference = "continue"

$module = "dos-install-common-kube"
Get-Module "$module" | Remove-Module -Force

Import-Module "$here\$module.psm1" -Force

Invoke-Pester "$here\Module.Tests.ps1"

# Invoke-Pester "$here\functions\helpers\Find-OpenPort.Tests.ps1" -Verbose

# Invoke-Pester "$here\functions\LaunchKubernetesDashboard.Tests.ps1" -Verbose

Invoke-Pester "$here\functions\Stack\InstallStackInKubernetes.Tests.ps1" -Verbose
