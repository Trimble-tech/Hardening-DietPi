## Hardening DietPi

This Bash script runs on [DietPi](https://dietpi.com/) systems to provide security tweaks the default settings do not include. The goal is to introduce good network security to users in a simple manner, with sane defaults and options aimed at lightweight systems.

### Prerequisites

1. An installed instance of DietPi Linux.
2. If you decide to harden SSH (the option is given at runtime), you must have SSH keys setup on the server. Check out my script SSH-key-builder if you need help with that **(https://github.com/Trimble-tech/SSH-Key-Builder)**.

### Usage

##### Download this script to your local system:.

* Most may prefer to download to a laptop or desktop, then move it over with a tool like [SCP](https://www.redhat.com/sysadmin/secure-file-transfer-scp-sftp): 
  1. If you are using Dropbear (the default) SSH server, you need to install *openssh-client* for SCP to work (**sudo apt install openssh-client**). This includes an SCP binary Dropbear doesn't ship. If you use OpenSSH as the server, SCP is included.
  2. Copy the script with SCP using: **scp Hardening-Dietpi.sh dietpi@your-server-IP-address:/home/dietpi/**

##### Make the script executable:

* Using chmod can mark the script file executable: **chmod +x Hardening-Dietpi.sh**

##### Execute the script:

* **./Hardening-Dietpi.sh**

### License

**Hardening DietPi** is licensed by Chris Trimble under the GPL v3 Open Source license (2023). Refer to file "LICENSE" for more information.
