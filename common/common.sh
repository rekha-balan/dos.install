
versioncommon="2018.04.17.02"

echo "--- Including common.sh version $versioncommon ---"
function GetCommonVersion() {
    echo $versioncommon
}

function Write-Output()
{
    echo $1
}

function Write-Host()
{
    echo $1
}

function Write-Status(){
    echo "$1";
}

function InstallPrerequisites(){
    # increase sudo timeout: https://apple.stackexchange.com/questions/10139/how-do-i-increase-sudo-password-remember-timeout?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    # sudo sh -c 'echo "\nDefaults timestamp_timeout=-1">>/etc/sudoers'
    Write-Status "--- updating yum packages ---"
    #sudo yum update -y -q -e 0
    # http://man7.org/linux/man-pages/man8/yum.8.html
    # foo=$(sudo yum -y check-update)
    # if [ $? = 100 ];then 
    #     sudo yum update -y
    # fi

    sudo yum update -y

    echo "---- RAM ----"
    declare -i freememInBytes=10
    freememInBytes=$(free|awk '/^Mem:/{print $2}')
    freememInMB=$(($freememInBytes/1024))
    echo "Free Memory: $freememInMB MB"
    free -h
    echo "--- disk space ---"
    df -h

    Write-Status "installing yum-utils and other packages"
    # yum-version: lock yum packages so they don't update automatically
    # yum-utils: for yum-config-manager
    # net-tools: for DNS tools
    # nmap: nmap command for listing open ports
    # curl: for downloading
    # lsof: show open files
    # ntp: Network Time Protocol
    # nano: simple editor
    # bind-utils: for dig, host

    sudo yum -y install yum-versionlock yum-utils net-tools nmap curl lsof ntp nano bind-utils 

    Write-Status "removing unneeded packages"
    # https://www.tecmint.com/remove-unwanted-services-in-centos-7/
    sudo yum -y remove postfix chrony

    Write-Status "turning off swap"
    # https://blog.alexellis.io/kubernetes-in-10-minutes/
    sudo swapoff -a
    echo "removing swap from /etc/fstab"
    grep -v "swap" /etc/fstab | sudo tee /etc/fstab
    echo "--- current swap files ---"
    sudo cat /proc/swaps
    
    # Register the Microsoft RedHat repository
    echo "--- adding microsoft repo for powershell ---"
    sudo yum-config-manager --add-repo https://packages.microsoft.com/config/rhel/7/prod.repo

    # curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

    # Install PowerShell
    echo "--- installing powershell ---"
    sudo yum install -y powershell
    # sudo yum install -y powershell-6.0.2-1.rhel.7
    # sudo yum versionlock powershell    
}
function createShortcutFordos(){
    local baseUrl=$1
    local prerelease=${2:-false}

    mkdir -p $HOME/bin
    installscript="$HOME/bin/dos"
    rm -f $installscript
    if [[ ! -f "$installscript" ]]; then
        echo "#!/bin/bash" > $installscript
        echo curl -o "${HOME}/onprem-menu.ps1" -sSL "${baseUrl}/menus/onprem-menu.ps1?p="'$RANDOM' >> $installscript
        if [[ "$prerelease" = true ]]; then
            echo pwsh -f "${HOME}/onprem-menu.ps1 -baseUrl ${baseUrl} -prerelease yes" >> $installscript
        else
            echo pwsh -f "${HOME}/onprem-menu.ps1 -baseUrl ${baseUrl} -prerelease no" >> $installscript
        fi

        chmod +x $installscript
        echo "NOTE: Next time just type 'dos' to bring up this menu"

        # from http://web.archive.org/web/20120621035133/http://www.ibb.net/~anne/keyboard/keyboard.html
        # curl -o ~/.inputrc "${baseUrl}/kubernetes/inputrc"
    fi    
}

echo "--- Finished including common.sh version $versioncommon ---"
