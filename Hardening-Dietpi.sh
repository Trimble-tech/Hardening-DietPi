#!/bin/bash

#   --Chris Trimble GNU GPLv3 2025--
##This script is written to be easy/forgiving for novices but tweakable for advanced users.
##For further information, refer to README.md and comments in this code

echo "Hello."
echo "This script will tweak Dietpi for better security."
echo "If you have questions, please refer to README.md."
echo "---"
sleep 2
##Need to check for + remove old files if script was ran before
    ##Provides some reset if minds change
echo "Checking for old config files..."
sudo rm /etc/modprobe.d/disable-rds.conf
sudo rm /etc/modprobe.d/disable-sctp.conf

echo "Security Audits like Lynis often request tools like these to be installed for security:"
echo "  libpam-tmpdir"
echo "  needrestart"
echo "  debsecan"
echo "  debsums"
echo "  apt-utils"
echo "  sed"

while true; do
    read -r -p "Do you want to install these tools? [Y/N] " yn
        case $yn in
        [Yy]* ) 
                echo "Installing..."
                sudo apt install libpam-tmpdir needrestart debsecan debsums sed apt-utils -y
                echo "Complete." 
                break;;

        [Nn]* ) echo 'Not Installing packages.' && break;;

        * ) echo 'Yes or No?' ;;
    esac
done

while true; do
    read -r -p "Do you want to install these Fail2Ban? [Y/N] " yn
        case $yn in
        [Yy]* ) 
                echo "Installing..."
                ##Fail2Ban on DietPi seems to not always work when installed manually
                ##Install with DietPi-Software works well, so invoking DietPi-Software
                sudo /boot/dietpi/dietpi-software install 73
                echo "Complete." 
                break;;

        [Nn]* ) echo 'Not Installing Fail2Ban.' && break;;

        * ) echo 'Yes or No?' ;;
    esac
done

##Installing only created problems for DietPi tools.

##Replaced unattended-upgrades with DietPi specific tool enabled in boot config file.
##May require reboot to take effect
while true; do
    read -r -p "Do you want to enable automatic system updates? [Y/N] " yn
        case $yn in
        [Yy]* ) 
                echo "Enabling automatic updates..." 
                ##No harm in being careful...
                mkdir ~/backups
                cp /boot/dietpi.txt ~/backups/dietpi.txt
                echo "Original boot file backup is in '~/backups'."
                ls ~/backups/

                ##Enables auto update in /boot/dietpi.txt
                sudo sed -i 's/CONFIG_CHECK_APT_UPDATES=.*/CONFIG_CHECK_APT_UPDATES=2/g' /boot/dietpi.txt
                echo "Complete." 
                break;;

        [Nn]* ) echo "Not enabling automatic updates." && break;;

        * ) echo 'Yes or No?' ;;
    esac
done

##Pointing to /bin/true disables services by not loading them in kernel (requires reboot)
##Delete created files to restore functionality (inside /etc/modprobe.d/)
while true; do
    read -r -p "Do you want to disable RDS (Reliable Datagram Sockets)? [Y/N]" yn
        case $yn in
        [Yy]* ) 
                echo "Disabling RDS..." 
                echo 'install rds /bin/true' >> ~/disable-rds.conf 
                sudo mv ~/disable-rds.conf /etc/modprobe.d/ 
                echo "Complete."
                break;;

        [Nn]* ) echo "Leaving enabled." && break;;

        * ) echo 'Yes or No?' ;;
    esac
done

while true; do
    read -r -p "Do you want to disable SCTP (Stream Control Transmission Protocol)? [Y/N]" yn
        case $yn in
        [Yy]* ) 
                echo "Disabling SCTP..." 
                echo 'install sctp /bin/true' >> ~/disable-sctp.conf 
                sudo mv ~/disable-sctp.conf /etc/modprobe.d/ 
                echo "Complete." 
                break;;

        [Nn]* ) echo "Leaving enabled." && break;;

        * ) echo 'Yes or No?' ;;
    esac
done

##Most of these SSH settings are safe defaults to prevent brute-force attacks without affecting users.
##Only exception is SSH keys & disabling passwords; I prompt here to make keys to prevent lock-outs.
echo "SSH can be made more secure by changing settings."
echo "We can use keys, reconfigure features, and disable root login."
while true; do
    read -r -p "Do you have SSH keys? [Y/N] " yn
    case $yn in
        [Yy]* ) echo "Okay, let's put them to use." && break;;

        [Nn]* ) 
                echo "You will need SSH keys to fully secure SSH."
                echo "Check out SSH-Key-Builder and then run this script again (https://github.com/Trimble-tech/SSH-Key-Builder)." 
                exit ;;

        * ) echo 'Yes or No?' ;;
    esac
done

while true; do
    read -r -p "Is your server using OpenSSH or Dropbear? [O/D] " od
        case $od in
        [Oo]* )

                echo "Hardening SSH service..."
                ##Make backups of files before making changes
                ##I iterate this verbally in script, since users may have issues with config/want peace of mind in headless (no display) setups.
                mkdir ~/backups
                touch ~/backups/sshd_config-OLD
                touch ~/backups/dietpi.OLD
                cp /etc/ssh/sshd_config ~/backups/sshd_config-OLD
                cp /etc/ssh/sshd_config.d/dietpi.conf ~/backups/dietpi.OLD
                echo "Original SSH file copied to sshd_config-OLD" ##Backups can't be in /etc/ssh because it makes apt/SSH errors
                echo "Dietpi SSH file copied to dietpi.OLD"
                echo ' '
                echo "Contents of '~/backups':" && ls ~/backups
                echo ' '
                echo "To reverse changes copy these files over the originals."
                echo "Original SSH file is /etc/ssh/sshd_config"
                echo "Original DietPi file is /etc/ssh/sshd_config.d/dietpi.conf"
                ##Sleep for readability
                sleep 2

        ##SSHD
                sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config ##Requires keys if uncommented
                sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config ##If you like root login change 'PermitRootLogin no' to 'PermitRootLogin prohibit-password'.

                sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' /etc/ssh/sshd_config ##Limits login attempts in supplement to fail2ban (no ban but bounces without fail2ban)
                sudo sed -i 's/#MaxSessions 10/MaxSessions 3/g' /etc/ssh/sshd_config ##Number of open SSH connections unlikely to ever be more than 3; 10 is excessive.

                sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config ##Uncommonly needed
                sudo sed -i 's/#TCPKeepAlive yes/TCPKeepAlive no/g' /etc/ssh/sshd_config ##Set with above option

                sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/g' /etc/ssh/sshd_config ##Shortens timeout on connections
                sudo sed -i 's/#Compression delayed/Compression no/g' /etc/ssh/sshd_config ##Connection compression has minor security issues but may be beneficial if your internet is dial-up (slow).

                sudo sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config ##Disable Graphical forwarding through SSH, only consider if remote desktops are in use.

                ##Dietpi-conf (extra config file in Dietpi): Make sure your options here match SSHD options
                sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/dietpi.conf
                sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config.d/dietpi.conf

        ##Verifies integrity of ssh configuration to prevent breakage
                sudo sshd -t -f /etc/ssh/sshd_config
                sudo sshd -t -f /etc/ssh/sshd_config.d/dietpi.conf
                
                break;;

        [Dd]* )
                ##Dropbear has many different ways to be configured
                    ##2FA and other options could be considered in future
                    ##For now opting to require keys and disable root login to match OpenSSH

                echo "Hardening Dropbear SSH service..."

                mkdir ~/backups
                touch ~/backups/dropbear.OLD
                cp /etc/default/dropbear ~/backups/dropbear.OLD
                echo "Original Dropbear SSH file copied to dropbear-OLD"
                echo "Dietpi SSH file copied to dietpi.OLD"
                echo ' '
                echo "Contents of '~/backups':" && ls ~/backups
                echo ' '
                echo "To reverse changes copy these files over the originals."
                echo "Original SSH file is /etc/default/dropbear"
                ##Sleep for readability
                sleep 2                

                ##disable Passwords and Root SSH
                ##I use ^ to specify only the line starting with DROPBEAR...
                    ##Other lines would get modded otherwise
                sudo sed -i 's/^DROPBEAR_EXTRA_ARGS=""/DROPBEAR_EXTRA_ARGS=" -g -s "/g' /etc/default/dropbear

                break;;
        * ) echo 'Yes or No?' ;;
    esac
done

##Mission critical systems may prefer only restarting some services like SSH instead of the whole system.
echo "Some of these actions may require restarting services to take full effect."
while true; do
    read -r -p "Do you want to Reboot your system, go to Dietpi-services, or Nothing else? [R/D/N] " rdn
    case $rdn in
        [Rr]* ) ##Launching dietpi-services non-interactively only works in the /boot/dietpi directory.
                echo "Rebooting system, Goodbye!" 
                sudo reboot 
                exit ;;
        
        [Dd]* ) 
                echo "Entering Dietpi-Services..." 
                sudo /boot/dietpi/dietpi-services
                exit ;;

        [Nn]* ) 
                echo "Exiting, do not forget to reboot/restart services when possible." 
                exit ;;

        * ) echo "R will reboot, D will go to Dietpi-services, and N will do nothing."
    esac
done
exit
