# Cisco VPN W/O Defender Autoconnect
A powershell script that auto connects a Cisco Anyconnect VPN with and without defender token

## INTRODUCTION
This is a powershell script that I wrote to automatically login into cisco Anyconnect VPN both using defender token as well as without it. Note that this script was written with only defender token in mind. If you need to use cisco anyconnect VPN client with another type of token, this script needs to be modified accordingly. The script is pretty straight forward and is easy to setup and run. Please look at the setup instructions below.

## SETUP
### PREREQUISITES
1. You need to have powershell installed and you need a minimum of version 2.0.
2. You need to have .Net framework installed
3. You need to have atleast powershell version 5.0 installed if you intend to use this script with defender token.
4. This script was tested agianst cisco anyconnect version 3.1. 
5. This script was tested using one identity defender soft token for windows with version 5.9.1

### INSTRUCTIONS
1. Clone or download the file AnyConnectAutoConnect.ps1
2. Fill the  path for vpncliAbsolutePath, vpnuiAbsolutePath and defendertokenfilepath
3. If you call the program with the VPN URL, username and password it will connect automatically without taking defender token into account
4. IF you need the script to work with one identity Defender token, you need to call the script with VPN URL, username, password and password for defender token.
5. To connect without using defender token, you can create a .bat file with the following command
```console
powershell ". .\AnyConnectAutoConnect.ps1; VPNConnect -vpnaddress \"{your VPN Address here}\" -user \"{your username}\" -pass \"{Your password}\""
```
6. To connect using defender token, you can create a .bat file with the following command
```console
powershell ". .\AnyConnectAutoConnect.ps1; VPNConnect -vpnaddress \"{your VPN Address here}\" -user \"{your username}\" -pass \"{Your password}\" -defenderpass \"{your defender password}\""
```
