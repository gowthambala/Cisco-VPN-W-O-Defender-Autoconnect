Function VPNConnect($vpnaddress, $user, $pass, $defenderpass)
{
#Add all the necessary .net framework classes
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class SetWindow {
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@ -ErrorAction Stop
#Need to see if there is a way to combine these two together. 
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class CheckWindow {
[DllImport("user32.dll")]
public static extern bool IsWindowVisible(IntPtr hwnd);
}
'@ -ErrorAction Stop
#path to anyconnect files
[string]$vpncliAbsolutePath = "{Path to your VPN CLI}\vpncli.exe"
[string]$vpnuiAbsolutePath  = "{Path to your VPN UI}\vpnui.exe"
[string]$defendertokenfilepath  = "{Path to your defender token if you are using it}\DefenderDesktopToken.exe"

#diconnect any existing VPN sessions
start-Process -WindowStyle Hidden -FilePath $vpncliAbsolutePath -ArgumentList 'disconnect' -wait
    #Terminate all vpnui processes 
    Get-Process | ForEach-Object {
        if($_.ProcessName.ToLower() -eq "vpnui") {
            $Id = $_.Id; Stop-Process $Id -Force; 
        }
    }
    #Terminate all vpncli processes.
    Get-Process | ForEach-Object {
        if($_.ProcessName.ToLower() -eq "vpncli"){
            $Id = $_.Id; Stop-Process $Id -Force; 
        }
    }
    
    #start VPN CLI    
    Start-Process -FilePath $vpncliAbsolutePath -ArgumentList "connect $vpnaddress"
    $counter = 0; $h = 0;
    while($counter++ -lt 1000 -and $h -eq 0)
    {
        sleep -m 250
        $h = (Get-Process vpncli).MainWindowHandle
    }
    #if it takes more than 20 seconds then display failure message
    if($h -eq 0){echo "Could not start VPNUI it takes too long."}
    else{[void] [SetWindow]::SetForegroundWindow($h)}
    #Add login and password
    [System.Windows.Forms.SendKeys]::SendWait("{Enter}")
    [System.Windows.Forms.SendKeys]::SendWait("$pass{Enter}")
    while($counter++ -lt 5)
    {
        sleep -m 250
    }
    #if defender password is specified then we assume defender token is being used and so we start up the defender program
    $defenderMainWindowHandle = 0
    if($defenderpass -ne $null)
    {
    $ProcessActive = Get-Process "DefenderDesktopToken.exe" -ErrorAction SilentlyContinue
    if($ProcessActive -eq $null) # evaluating if the program is running
    {
	$defenderHandle = start-Process -FilePath $defendertokenfilepath -Passthru
    #Wait for the defender program to start
    while($counter++ -lt 1000 -and $defenderMainWindowHandle -eq 0)
    {
        sleep -m 250
        $defenderMainWindowHandle = $defenderHandle.MainWindowHandle
    }
    [void] [SetWindow]::SetForegroundWindow($defenderMainWindowHandle)
    }
    else
    {
    [void] [SetWindow]::SetForegroundWindow($ProcessActive)
    }
    [System.Windows.Forms.SendKeys]::SendWait("$defenderpass")
    [System.Windows.Forms.SendKeys]::SendWait("{Enter}")
    #Code executes faster than UI element rendering so we take a quick break here
    while($counter++ -lt 250)
    {
        sleep -m 6
    }
    #Get a hold of the CLI command window handle so we can input the defender token
    while($counter++ -lt 250)
    {
        sleep -m 10
        $h = (Get-Process vpncli).MainWindowHandle
    }
    [System.Windows.Forms.SendKeys]::SendWait("{Enter}")
    $secondpass = Get-Clipboard 
    [void] [SetWindow]::SetForegroundWindow($h)
    [System.Windows.Forms.SendKeys]::SendWait("$secondpass{Enter}")
    } 
    [System.Windows.Forms.SendKeys]::SendWait("y{Enter}")
    #if window is closed, then start vpnui
    while($counterx++ -lt 1000)
    {
        sleep -m 250
        if([CheckWindow]::IsWindowVisible($h))
        {
        }else
        {
        break
        }
    }
   
    start-Process -NoNewWindow -FilePath $vpnuiAbsolutePath
    }
   