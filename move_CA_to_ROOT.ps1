

$cert = (Get-Childitem cert:\LocalMachine\CA | Where-Object { $_.subject -like '*CertReq Test Root*' }).Thumbprint

move-item -path cert:\LocalMachine\CA\$cert -Destination cert:\LocalMachine\Root\