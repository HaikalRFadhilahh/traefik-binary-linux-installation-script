# Configuration Default Shell (Bash Shell / Shell sh)
#!/bin/bash

# Error Termination 
# set -e

# Create Function Clear Screen
clear_screen() {
    echo -e "\033c"
} 

# Install Traefik Binary
traefik_install () {
    # Check Wget Is Exist or Not
    if wget --help &> /dev/null;
    then
        # Remove Traefik Binary File First
        rm -rf traefik.tar.gz

        # Checking Architecture of Linux
        ARCH=$(uname -m)
        if [ "$ARCH" = "x86_64" ];
        then
            ARCH=amd64
        elif [ "$ARCH" = "aarch64" ];
        then
            ARCH=arm64
        fi

        # Insert Version of Traefik
        echo "INFO: List of Version Traefik https://github.com/traefik/traefik/releases"
        echo -n "Insert Version of Traefik (Default v3.4.0) : "
        read traefik_version
        if [ -z "$traefik_version" ];
        then
            traefik_version=v3.4.0
        fi

        # Clean Binary First
        rm -rf traefik.tar.gz
        rm -rf CHANGELOG.md
        rm -rf LICENSE.md
        rm -rf traefik

        # Download File
        echo "Downloading Traefik Binary File...."
        url_traefik_binary="https://github.com/traefik/traefik/releases/download/${traefik_version}/traefik_${traefik_version}_linux_${ARCH}.tar.gz"
        wget -O traefik.tar.gz $url_traefik_binary &> /dev/null
        echo "Downloading Traefik Binary File Done!"

        if [ "$?" -eq "0" ];
        then
            # Create User traefik and Group traefik for system
            useradd -r -s /sbin/nologin traefik &> /dev/null

            # Extract Traefik Binary File
            tar -xvf traefik.tar.gz &> /dev/null

            # Move traefik binary, config access and give access to use low port
            rm -rf CHANGELOG.md
            rm -rf LICENSE.md
            chmod a+x traefik
            mv traefik /usr/local/bin/traefik
            chown traefik:traefik /usr/local/bin/traefik
            setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik

            # Create Access
            mkdir -p /var/log/traefik
            touch /var/log/traefik/traefik-general-log
            touch /var/log/traefik/traefik-access-log
            chown -R traefik:traefik /var/log/traefik
            chmod -R 775 /var/log/traefik

            # Configuration /etc/traefik
            mkdir -p /etc/traefik
            cp traefik_config/*.yml /etc/traefik
            chown -R traefik:traefik /etc/traefik
            chmod -R 775 /etc/traefik

            # SSL Configuration
            touch /etc/traefik/acme.json
            chown traefik:traefik /etc/traefik/acme.json
            chmod 600 /etc/traefik/acme.json

            # Systemd Configuration
            mv traefik_config/traefik.service /etc/systemd/system/traefik.service
            systemctl daemon-reexec
            systemctl daemon-reload
            systemctl enable traefik.service
            systemctl start traefik.service

            # Message Success Install Traefik
            clear_screen
            print_text green "Success Installation Traefik Binary File!!"
        else
            rm -rf traefik.tar.gz
            clear_screen
            print_text red "Traefik Binary File Not Found!, Maybe Version that your input not valid or Your Linux Architecture not Support Traefik Binary File!"
        fi

    else
        print_text red "Cannot Download Traefik Binary because "wget" command not found. Please install package wget first!"
    fi
}

# Uninstall Traefik Binary
traefik_uninstall () {
    print_text yellow "Warning: Are you sure you want to remove traefik from your Linux Operating System? Some of the following files will be deleted: "
    echo "- '/usr/local/bin/traefik' -> Binary File Traefik"
    echo "- '/var/log/traefik/ -> Log File Traefik'"
    echo "- '/etc/traefik/ -> Configuration File Traefik'"
    echo -n "Will you continue? (Y/N) Default (N) : "
    read remove_confirmation
    echo "$remove_confirmation"
    if [ "$remove_confirmation" = "Y" ] || [ "$remove_confirmation" = "y" ];
    then
        clear_screen
        print_text green "Process Uninstall Traefik Binary..."
        # Remove Folder Traefik Configuration
        rm -rf /etc/traefik
        print_text green "Success Deleted Configuration Traefik Folder -> /etc/traefik"

        # Remove Folder Traefik Log
        rm -rf /var/log/traefik
        print_text green "Success Deleted Traefik Log Folder -> /var/log/traefik"

        # Waiting Time
        sleep 2

        # Checking Traefik Binary File
        if [ -f "/usr/local/bin/traefik" ];
        then
            # Remove Systemd Traefik Service Background
            systemctl stop traefik.service &> /dev/null
            systemctl disable traefik.service &> /dev/null
            systemctl mask traefik.service &> /dev/null
            rm /etc/systemd/system/traefik.service  
            systemctl daemon-reload &> /dev/null

            print_text green "Success Deleted, Disabled, Stop Traefik Service from Systemd -> /etc/systemd/system/traefik.service"

            # Remove Traefik Binary File
            rm -rf /usr/local/bin/traefik
            print_text green "Success Deleted Traefik Binary File -> /usr/local/bin/traefik"

            # Checking Traefik System User and Remove if Exist
            if id "traefik" &> /dev/null && [ "$(uname -s)" = "Linux" ];
            then
                userdel -r traefik
                if [ "$?" -eq "0" ];
                then
                    print_text green "Success Deleted User Traefik System"
                else
                    print_text red "Error Deleted User Traefik System"
                fi
            fi

            # Checking Group Traefik
            if getent group "traefik" &> /dev/null && [ "$(uname -s)" = "Linux" ];
            then
                groupdel traefik
                if [ "$?" -eq "0" ];
                then
                    print_text green "Success Deleted Group Traefik System"
                else
                    print_text red "Error Deleted Group Traefik System"
                fi
            fi

            # Waiting Time 
            sleep 3

            # Message Success Fully Deleted Traefik Binary
            print_text green "Success Deleted Traefik Binary!!"
        else
            print_text red "Binary Traefik not found. You can reinstall it through the menu provided in this script!"
        fi
    else
        clear_screen
        print_text red "Uninstall Traefik Binary Canceled!"
    fi
}


# Welcome Message
main () {
    echo "=============================="
    print_text white "Welcome to Traefik Binary Linux Server / Linux Desktop Installation Program"
    echo "=============================="
    echo "Please select the features available below : "
    echo "1. Instalation Traefik Binary on Linux"
    echo "2. Uninstall Traefik Binary on Linux"
    echo "3. Exit"
    echo -n "Please select the available features by entering the selection number: "
    read options
    case $options in
    1)
        traefik_install
        ;;
    2)
        traefik_uninstall
        ;;
    3)
        print_text blue "Thank you for using this installation script. I hope you can use Traefik well 🐳."
        break
        ;;
    *)
        clear_screen
        print_text red "Selection not found, please double check your selection."
        ;;
    esac
}

# Helper 
print_text() {
    color=$1
    text=$2
    case $color in
        red)
            echo -e "\033[1;31m$text\033[0m"  # 1 untuk bold, 31 untuk merah
            ;;
        green)
            echo -e "\033[1;32m$text\033[0m"  # 1 untuk bold, 32 untuk hijau
            ;;
        yellow)
            echo -e "\033[1;33m$text\033[0m"  # 1 untuk bold, 33 untuk kuning
            ;;
        blue)
            echo -e "\033[1;34m$text\033[0m"  # 1 untuk bold, 34 untuk biru
            ;;
        white)
            echo -e "\033[1;37m$text\033[0m"  # 1 untuk bold, 34 untuk white
            ;;
        *)
            echo "$text"
            ;;
    esac
}

# Main Program
# Checking if the Installation Script running user Sudo
if [ "$EUID" -eq "0" ];
then
    while true
    do
        main
    done
    exit 0
else
    # Check System Type Is Linux or Not
    if ! [ "$(uname -s)" = "Linux" ];
    then
        print_text red "Error: Installation Script not Support with Your Operating System Type. This Script only works on Linux!"
    fi

    # Check Script Running With Sudo Access or Not
    if [ "$EUID" -ne "0" ];
    then
        print_text red "Error: Please run this installation script with Super User / Sudo so that the script can have access to the traefik installation."
    fi
    exit 1
fi


