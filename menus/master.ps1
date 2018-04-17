$version = "2018.04.17.01"

# This script is meant for quick & easy install via:
#   Invoke-WebRequest -useb https://raw.githubusercontent.com/HealthCatalyst/dos.install/master/menus/master.ps1 | iex;
#   curl -sSL  https://raw.githubusercontent.com/HealthCatalyst/dos.install/master/menus/master.ps1 | pwsh -Interactive -NoExit -c -;

Write-Host "--- master.ps1 version $version ---"

$GITHUB_URL = "https://raw.githubusercontent.com/HealthCatalyst/dos.install/master"

$set = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$randomstring += $set | Get-Random

Write-Host "Powershell version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Build)"

mkdir -p ${HOME}

function ImportModuleFromUrl($module){
    Invoke-WebRequest -useb -Uri "${GITHUB_URL}/common/${module}.ps1?f=$randomstring" -OutFile "${HOME}/${module}.psm1"
    Import-Module -Name "${HOME}/${module}.psm1" -Force
}

ImportModuleFromUrl -module "common"

ImportModuleFromUrl -module "common-kube"

ImportModuleFromUrl -module "common-onprem"

# show Information messages
$InformationPreference = "Continue"

$userinput = ""
while ($userinput -ne "q") {
    Write-Host "================ Health Catalyst version $version, common functions kube:$(GetCommonKubeVersion) onprem:$(GetCommonOnPremVersion) ================"
    Write-Host "------ Infrastructure -------"
    Write-Host "1: Create Master VM"
    Write-Host "2: Create Worker VM"
    Write-Host "3: Create Single Node Cluster"
    Write-Host "4: Uninstall Docker and Kubernetes"
    Write-Host "-----------"
    Write-Host "q: Quit"
    $userinput = Read-Host "Please make a selection"
    switch ($userinput) {
        '1' {
            SetupMaster -baseUrl $GITHUB_URL -singlenode $false
        } 
        '2' {
            SetupNewNode -baseUrl $GITHUB_URL
        } 
        '3' {
            SetupMaster -baseUrl $GITHUB_URL -singlenode $true
        } 
        '4' {
            UninstallDockerAndKubernetes
        } 
        'q' {
            return
        }
    }
    $userinput = Read-Host -Prompt "Press Enter to continue or q to exit"
    if($userinput -eq "q"){
        return
    }
    [Console]::ResetColor()
    Clear-Host
}