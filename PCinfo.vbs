'the current path of the script in share folder, also the local script will check for any update in this script
shareDir = "\\share_folder\anyPath\pcinfo\"

'the local folder witch the script will be coppied to the pc, i choose public folder because it will be accessable for all users, if you have better location you can use it.
localScriptlocaltion="c:\users\public\"


'get user info:

'here will get user info from the domian
Set objSysInfo = CreateObject("ADSystemInfo")
    Set objCurrentUser = GetObject("LDAP://" & objSysInfo.UserName)
    UserName=objCurrentUser.givenName &" "& objcurrentuser.lastname  
    department=objcurrentuser.department
userid =CreateObject("WScript.Network").UserName 'user name
PCname=CreateObject("WScript.Network").ComputerName ] 'pc name 
domianname=objSysInfo.DomainShortName 'domian name, it is useful if we neet to check if the pc is connected to the domian or not, or if we have more than one domian

'get the IP Address
dim NIC1, Nic, IP, MAC
Set NIC1 =     GetObject("winmgmts:").InstancesOf("Win32_NetworkAdapterConfiguration")
For Each Nic in NIC1
    if Nic.IPEnabled then
        IP = Nic.IPAddress(0) 'IP Address
        MAC = Nic.MACAddress(0) 'MAC Adress
    End if
Next

'get Windows info
Set SystemSet = GetObject("winmgmts:").InstancesOf ("Win32_OperatingSystem")
for each System in SystemSet 
windowsver= System.Caption
memory= int(System.TotalVisibleMemorySize/1000000)'in bytes
serialno= System.SerialNumber
version= System.Version

'this is some additional info if you need:
'msgbox System.Manufacturer 
'msgbox System.BuildType 
'msgbox System.Locale
'msgbox System.WindowsDirectory
next 

'get current Date
Dim lastUpdate
lastUpdate = DateDiff("s", "01/01/1970 00:00:00", Now())'convert the time to unix timestamp, because the time format is not the same in all PCs.

'the full info varibles:
info="pcname=>"&PCname&_
    ",userid=>"&userid&_
    ",department=>"&department&_
    ",username=>"&username&_
    ",ip=>"&IP&_
    ",mac=>"&MAC&_
    ",domian=>"&domianname&_
    ",windows=>"&windowsver&_
    ",version=>"&version&_
    ",memory=>"&memory&_
    ",serialno=>"&serialno&_
    ",update=>"&lastUpdate

'write the information to text file
filename=Replace(MAC,":","")'file name will be the mac address ,it was before the pc name, but the MAC is better because it is not changable.
reportpath=shareDir+"reports\"+filename+".txt" ' the location to store the text file in the shared location in 'reports' folder, that folder need to be created before.

Set FSO=CreateObject("Scripting.FileSystemObject")
newContents=info
if(FSO.FileExists(reportpath)) then 'if the text file exist
Set File = FSO.OpenTextFile(reportpath,1) 'open the file for read only
existContents = File.ReadAll ' take the content frome the exist file to move it after the new line
File.Close
newContents = newContents & vbCrLf & existContents 'Write the new info in the begin of the file, vbCrlf is for move to new line
Set File = FSO.OpenTextFile(reportpath,2) 'open the file for write only
else 'if the file is not exist
Set File = FSO.CreateTextFile(reportpath,True)' create the file 
end if
File.Write newContents ' write the content to the file
File.Close
'----------------------------------------------------------

'check for registry key for startup
'to insure the script will run frequntly, we will let the script run every time the user is loging in, by applying a registry key to the windows registry
Function checkReg ' check if the registry key is exist
Const HKEY_LOCAL_MACHINE = &H80000002
Set objRegistry = GetObject("winmgmts:\\" & ".\root\default:StdRegProv")
strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" 'path of the registry store all start up apps and services
strValueName = "SamiPCinfocollector" 'the name of the registry key, you can name it whatever what you want, it will not make a difrent, as long as if it is on the currect path. 
objRegistry.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
checkReg=not IsNull(strValue)' return true or false 
End Function

'Check the script file if it is installed in the pc or not for install it
if (not checkReg) then 'if the registry key is not installed
    FSO.CopyFile shareDir+"script\injection.reg", localScriptlocaltion+"injection.reg"'copy registry file to local path, because the script cannot exuted it if it is not locally
    CreateObject("Wscript.Shell").Run ("regedit /S "+localScriptlocaltion+"injection.reg")''apply the registry key key
    WScript.Sleep 3000 ' wait before checking, because it will take time.
    if (checkReg) then ' if the registry key is installed
        msgbox "Registry key install successfully :)",vbOKOnly ,"" 'if every thing is ok, till you 
    else
        msgbox "Faild to install the script, try to install it with Administrator user",vbCritical,"ATC IT PC Checker"
    end if
end if


'Get update for exist script from the share folder
if (FSO.FileExists(localScriptlocaltion+WScript.ScriptName)) then 'if the script exist localy
    localscriptMdate=DateDiff("s", "01/01/1970 00:00:00", FSO.GetFile(WScript.ScriptFullName).DateLastModified)'get local script modification date
    remotescriptMdate=DateDiff("s", "01/01/1970 00:00:00", FSO.GetFile(shareDir+"script\"+WScript.ScriptName).DateLastModified)'get remote script modification date
    'msgbox remotescriptMdate-localscriptMdate
    if remotescriptMdate>localscriptMdate then 'of the remote script modification date is larg than the local script, than mean there is an update
        FSO.CopyFile shareDir+"script\"+WScript.ScriptName, localScriptlocaltion+WScript.ScriptName 'apply the update by replace the local script with the remote script
       ' msgbox "update"
       WScript.Sleep 3000 
       Wscript.CreateObject("WScript.Shell").Run localScriptlocaltion+WScript.ScriptName'execute the new updated script
       wscript.quit 'end the current script
    end if
else' if the script file is not installed in the local folder
    FSO.CopyFile shareDir+"script\"+WScript.ScriptName, localScriptlocaltion+WScript.ScriptName'copy the script file 
    WScript.Sleep 3000
    if (not FSO.FileExists(localScriptlocaltion+WScript.ScriptName)) then 'check if is it coppied or not
        msgbox "Faild to install the script, try to install it with Administrator user",vbCritical,"ATC IT PC Checker"
    else
        msgbox (replace(info,",",vbNewLine)),vbInformation ,"ATC IT PC Checker"' if it is coppied, view the pc information for the first time
    end if
end if

'THE END
'hope you like it, Sami Khanfor
' https://github.com/samikhanfor
'https://twitter.com/samikhanfor
'https://www.linkedin.com/in/samikhanfor/




