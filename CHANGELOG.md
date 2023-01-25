## Change Log:

#### Hardening DietPi v.0.1.0

* __Initial Public Release__
  * Deletes previous config files created for fresh start
  * Installs helpful Apt packages
  * Enables Unattended-Upgrades using custom config files instead of editing default
  * Can disable RDS, SCTP by just adding two files
  * Hardens SSH to require keys (if prompted), introduces sane defaults
  * Enabled end script to execute *dietpi-services* directly from user prompt