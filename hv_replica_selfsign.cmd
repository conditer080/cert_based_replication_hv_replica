@Echo Off
Color CF
cd %systemroot%\system32
call :IsAdmin

Color 0F

cls

@echo off

:prestart
echo --------hyper-v win serv 2016 + replica script v 0.1--------
echo YOU must have at last windows 2016 server machines.
echo Before continue this script you must ADD DNS SUFFIX to both
echo hyper-v and replica server and reboot them. DNS suffix must be equal on both servers

FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Domain"`) DO (
    set nv_domain=%%B
    )

echo PLEASE CHECK is your dns suffix = %nv_domain% and FQDN servername = %computername%.%nv_domain%
echo example: your dns suffix = abc servername = hv-main01.abc
echo if so you can continue this script
echo please type Y to continue
        SET /P agreement=
        IF '%agreement%'=='y' goto main_run
	goto prestart


:main_run

cd /d %~dp0

echo %computername%.%nv_domain% >nv_domain_var.txt

echo please type real replica name server without suffix
echo Example : hv-replica001
SET /P replica=
echo please type password for export/import certificate
SET /P pass=
echo %replica%.%nv_domain% >replica_srv_name.txt
echo %pass% >cert_password.txt

powershell Set-ExecutionPolicy Unrestricted -Force

powershell New-SelfSignedCertificate -DnsName "%computername%.%nv_domain%" -CertStoreLocation "cert:\LocalMachine\My" -TestRoot -KeyAlgorithm RSA -KeyLength 2048 -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(23)>info_cert_HV_HOST.txt
powershell New-SelfSignedCertificate -DnsName "%replica%.%nv_domain%" -CertStoreLocation "cert:\LocalMachine\My" -TestRoot -KeyAlgorithm RSA -KeyLength 2048 -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(23)>info_cert_REPLICA_HOST.txt

certutil.exe -p "%pass%" -exportpfx "%replica%.%nv_domain%" to_replica_cert.pfx > replica_cert_info.txt

powershell .\move_CA_to_ROOT.ps1

certutil.exe -p "%pass%" -exportpfx "ROOT" "CertReq Test Root" cer_root.pfx > cer_root_info.txt

set trs=%homepath%\desktop\TO_REPLICA_SERVER
mkdir=%trs%\

copy to_replica_cert.pfx %trs%\
copy cer_root.pfx %trs%\
copy move_CA_to_ROOT.ps1 %trs%\

echo @echo off >%trs%\RUN_on_REPLICA_ONLY.cmd
echo cd /d %%~dp0 >>%trs%\RUN_on_REPLICA_ONLY.cmd
echo reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\Replication" /v DisableCertRevocationCheck /d 1 /t REG_DWORD /f>>%trs%\RUN_on_REPLICA_ONLY.cmd
echo echo please check  %replica%==%%computername%% >>%trs%\RUN_on_REPLICA_ONLY.cmd
echo echo if they equal press any key to continue , otherwise close command prompt window >>%trs%\RUN_on_REPLICA_ONLY.cmd
echo echo remove all files except move_CA_to_ROOT.ps1 and hv_replica_selfsign.cmd >>%trs%\RUN_on_REPLICA_ONLY.cmd
echo echo and start from scratch with proper replica server name >>%trs%\RUN_on_REPLICA_ONLY.cmd
echo pause >>%trs%\RUN_on_REPLICA_ONLY.cmd

echo powershell Import-PfxCertificate -FilePath 'to_replica_cert.pfx' -Password (ConvertTo-SecureString -String '%pass%' -AsPlainText -Force) -CertStoreLocation cert:\LocalMachine\My\>>%trs%\RUN_on_REPLICA_ONLY.cmd
echo powershell Import-PfxCertificate -FilePath 'cer_root.pfx' -Password (ConvertTo-SecureString -String '%pass%' -AsPlainText -Force) -CertStoreLocation cert:\LocalMachine\Root\>>%trs%\RUN_on_REPLICA_ONLY.cmd

echo powershell .\move_CA_to_ROOT.ps1>>%trs%\RUN_on_REPLICA_ONLY.cmd

echo pause >>%trs%\RUN_on_REPLICA_ONLY.cmd


pause

exit


:IsAdmin
Reg.exe query "HKU\S-1-5-19\Environment"
If Not %ERRORLEVEL% EQU 0 (
 Cls & Echo You must have administrator rights to continue ... 
 Pause & Exit
)
Cls
goto:eof