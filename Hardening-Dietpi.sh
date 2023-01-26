#   --Chris Trimble GNU GPLv3 2023--

##This script is written to be easy/forgiving for novices but tweakable for advanced users.
##While all code should be desirable in current state, advanced options can be further tweaked looking at comments in code + README.txt
##All this prevents too many questions being asked at runtime.

echo "Hello."
echo "This script will tweak Dietpi for better security."
echo "If you have questions, please refer to README.txt or email me at:"
echo "  chris.trimble3.ct@gmail.com"
sleep 2
##Need to check for + remove old files if script was ran before, otherwise syntax errors occur
    ##Provides some reset if minds change
echo "Checking for old config files..."
sudo rm /etc/apt/apt.conf.d/95-Hardening-Dietpi-Config
sudo rm /etc/apt/apt.conf.d/96-Hardening-Dietpi-Reboots
sudo rm /etc/modprobe.d/disable-rds.conf
sudo rm /etc/modprobe.d/disable-sctp.conf

echo "Security Audits like Lynis often request tools like these to be installed for security:"
echo "  libpam-tmpdir"
echo "  apt-listbugs"
echo "  apt-listchanges"
echo "  needrestart"
echo "  debsecan"
echo "  debsums"
echo "  fail2ban"
##I actually need to also check that apt-utils and sed are installed.
    #1 apt-utils is needed to configure packages after install, apt complains otherwise
    #2 sed is usually preinstalled but critical for this script to work

while true; do
    read -p "Do you want to install these tools? [Y/N] " yn
        case $yn in
        [Yy]* ) echo "Installing..." && sudo apt install libpam-tmpdir apt-listbugs apt-listchanges needrestart debsecan debsums sed fail2ban apt-utils -y && echo "Complete." && break;;
        [Nn]* ) echo 'Not Installing packages.' && break;;
        * ) echo 'Yes or No?' ;;
    esac
done

##Allows auto-updates &/or reboots to be enabled with custom config
echo 'a selects auto upgrades, b selects auto upgrades and reboots, c does nothing.'
while true; do
    read -p "Would you like to enable Automatic Upgrades (a), Automatic Upgrades with Reboots (b), or only upgrade manually [no automation] (c)?" abc
        case $abc in
            [a]* ) 
                echo "Enabling Automatic Upgrades."
                sudo apt install unattended-upgrades apt-listchanges apt-utils -y
                ##Instead of editing the existing config, load our changes on top with custom file 
                ##Higher number in name loads in apt later & overwrites lower number (1-99)
                ##97-99 is taken by DietPi, picking 95 to prevent our options getting overwritten by defaults (70 & lower)
                sudo echo '//Hardening-Dietpi Config;;' > ~/95-Hardening-Dietpi-Config

                ##These changes made are to keep systems light; extra dependencies/old kernels can bog down a MicroSD or small USB
                sudo echo 'Unattended-Upgrade::Remove-New-Unused-Dependencies "true";;' >> ~/95-Hardening-Dietpi-Config
                sudo echo 'Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";;' >> ~/95-Hardening-Dietpi-Config

                ##This change slows updates a bit but protects Apt in power failure/allows user shutdown
                sudo echo 'Unattended-Upgrade::MinimalSteps "true";;' >> ~/95-Hardening-Dietpi-Config

                sudo mv ~/95-Hardening-Dietpi-Config /etc/apt/apt.conf.d/

                echo "Automatic Upgrades are now enabled"
                break;;
            
            [b]* ) 
                echo "Enabling Automatic Upgrades and Automatic Reboots."
                sudo apt install unattended-upgrades apt-listchanges -y
                ##Instead of editing the existing config, load our changes on top with custom file 
                ##Higher number in name loads in apt later & overwrites lower number (1-99)
                ##97-99 is taken by DietPi, picking 95 to prevent our options getting overwritten by defaults (70 & lower)
                echo '//Hardening-Dietpi Config;;' > ~/95-Hardening-Dietpi-Config
ice
                ##These changes made are to keep systems light; extra dependencies/old kernels can bog down a MicroSD or small USB
                echo 'Unattended-Upgrade::Remove-New-Unused-Dependencies "true";;' >> ~/95-Hardening-Dietpi-Config
                echo 'Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";;' >> ~/95-Hardening-Dietpi-Config

                ##This change slows updates a bit but protects Apt/lets system shutdown properly
                echo 'Unattended-Upgrade::MinimalSteps "true";;' >> ~/95-Hardening-Dietpi-Config

                ##This section creates another file which enables the automatic reboots
                ##Simply delete this file if you don't want auto-reboots anymore
                echo '//Hardening-Dietpi-Reboots;;' > ~/96-Hardening-Dietpi-Reboots
                
                ##Turns on automatic reboots, which occur only:
                    #[1] If upgraded packages inform Apt of a need to reboot by creating file '/var/run/reboot-required' temporarily.
                    #[2] At the time specified in the file '96-Hardening-Dietpi-Reboots' (set to 2AM by script default).

                echo 'Unattended-Upgrade::Automatic-Reboot "true";;' >> ~/96-Hardening-Dietpi-Reboots
                ##Servers are likely to have at least one (maybe automated) user logged in, this makes sure the reboot still occurs.
                echo 'Unattended-Upgrade::Automatic-Reboot-WithUsers "true";;' >> ~/96-Hardening-Dietpi-Reboots
                ##Unlikely to cause disruption if reboot is at 02:00 (2AM local time)
                echo 'Unattended-Upgrade::Automatic-Reboot-Time "02:00";;' >> ~/96-Hardening-Dietpi-Reboots

                ##Can't create the file directly in /etc/apt/apt.conf (permissions), so creating and then moving
                sudo mv ~/95-Hardening-Dietpi-Config /etc/apt/apt.conf.d/
                sudo mv ~/96-Hardening-Dietpi-Reboots /etc/apt/apt.conf.d/

                echo "Automatic Upgrades and Reboots are now enabled"
                break;;
        
            [c]* ) 
                echo 'Not enabling automatic updates or reboots.'
                break;;
            
            * ) echo ' ' && echo 'a selects auto upgrades, b selects auto upgrades and reboots, c does nothing.' && echo 'Choose a, b, or c';;
    esac
done

##Pointing to /bin/true disables services by not loading them in kernel (requires reboot)
##Delete created files to restore functionality 
while true; do
    read -p "Do you want to disable RDS (Reliable Datagram Sockets) [Y/N] ?" yn
        case $yn in
        [Yy]* ) echo "Disabling RDS..." && echo 'install rds /bin/true' >> ~/disable-rds.conf && sudo mv ~/disable-rds.conf /etc/modprobe.d/ && echo "Complete." && break;;
        [Nn]* ) echo "Leaving enabled." && break;;
        * ) echo 'Yes or No?' ;;
    esac
done

while true; do
    read -p "Do you want to disable SCTP (Stream Control Transmission Protocol) [Y/N] ?" yn
        case $yn in
        [Yy]* ) echo "Disabling SCTP..." && echo 'install sctp /bin/true' >> ~/disable-sctp.conf && sudo mv ~/disable-sctp.conf /etc/modprobe.d/ && echo "Complete." && break;;
        [Nn]* ) echo "Leaving enabled." && break;;
        * ) echo 'Yes or No?' ;;
    esac
done

##Most of these SSH settings are safe defaults to prevent brute-force attacks without affecting users.
##Only exception is SSH keys & disabling passwords; I prompt here to make keys to prevent lock-outs.
echo "SSH can be made more secure by changing settings."
echo "We can use keys, reconfigure features, and disable root login."
while true; do
    read -p "Do you have SSH keys? [Y/N] " yn
    case $yn in
        [Yy]* ) echo "Okay, let's put them to use." && break;;
        [Nn]* ) echo "You will need SSH keys to fully secure SSH." && echo "Check out SSH-Key-Builder and then run this script again (https://github.com/Trimble-tech/SSH-Key-Builder)." && exit; break;;
        * ) echo 'Yes or No?' ;;
    esac
done

echo "Hardening SSH service..."
##Make backups of files before making changes
##I iterate this verbally in script, since users may have issues with config/want peace of mind in headless (no display) setups.
    ##cp isn't letting me copy to a new file, odd...
    touch sshd_config-OLD
    touch dietpi.OLD
    cp /etc/ssh/sshd_config sshd_config-OLD
    cp /etc/ssh/sshd_config.d/dietpi.conf dietpi.OLD
    echo "Original SSH file copied to sshd_config-OLD" ##Backups can't be in /etc/ssh because it makes apt/SSH errors
    echo "Dietpi SSH file copied to dietpi.OLD"
    echo ' '
    ls
    echo ' '
    echo "To reverse changes copy these files over the originals."
    echo "Original SSH file is /etc/ssh/sshd_config"
    echo "Original DietPi file is /etc/ssh/sshd_config.d/dietpi.conf"
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

##Mission critical systems may prefer only restarting some services like SSH instead of the whole system.
echo "Some of these actions may require restarting services to take full effect."
while true; do
    read -p "Do you want to Reboot your system, go to Dietpi-services, or Nothing else? [R/D/N] " rdn
    case $rdn in
        [Rr]* ) echo "Rebooting system, Goodbye!" && sudo reboot && exit; break;;
        ##Launching dietpi-services non-interactively only works in the /boot/dietpi directory.
        [Dd]* ) echo "Entering Dietpi-Services..." && cd /boot/dietpi && sudo ./dietpi-services && cd && exit; break;;
        [Nn]* ) echo "Exiting, do not forget to reboot/restart services when possible." && exit; break;;
        * ) echo "R will reboot, D will go to Dietpi-services, and N will do nothing."
    esac
done
exit