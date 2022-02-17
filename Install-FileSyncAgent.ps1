# Global Variables
$storageSyncServiceName = "prometheus-tsdb-sync-service"
$tenantId = "a445ee81-2b91-4806-883b-1dc673d59147"
$applicationId = "f7d0b419-9ff9-49b5-81a8-1cba5ce5dd93"
$securedPassword = "F-qT4mkOXW9CPu-rjxYeVFp1eh4TNtY8g3"
$securedPass = ConvertTo-SecureString -String $securedPassword -AsPlainText -Force


$installType = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\").InstallationType

# This step is not required for Server Core
if ($installType -ne "Server Core") {
    # Disable Internet Explorer Enhanced Security Configuration 
    # for Administrators
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 -Force

    # Disable Internet Explorer Enhanced Security Configuration 
    # for Users
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 -Force

    # Force Internet Explorer closed, if open. This is required to fully apply the setting.
    # Save any work you have open in the IE browser. This will not affect other browsers,
    # including Microsoft Edge.
    Stop-Process -Name iexplore -ErrorAction SilentlyContinue
}

# install the Az module if it does not exist already.
if (Get-InstalledModule -Name Az) {
    Write-Host "Module exists"
} 
else {
    # Install the AZ module for current user and forcefully
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

# Gather the OS version
$osver = [System.Environment]::OSVersion.Version

Write-Host "Begin downloading storage sync agent..."

# Download the appropriate version of the Azure File Sync agent for your OS.
if ($osver.Equals([System.Version]::new(10, 0, 17763, 0))) {
    Invoke-WebRequest `
        -Uri https://aka.ms/afs/agent/Server2019 `
        -OutFile "StorageSyncAgent.msi" 
} elseif ($osver.Equals([System.Version]::new(10, 0, 14393, 0))) {
    Invoke-WebRequest `
        -Uri https://aka.ms/afs/agent/Server2016 `
        -OutFile "StorageSyncAgent.msi" 
} elseif ($osver.Equals([System.Version]::new(6, 3, 9600, 0))) {
    Invoke-WebRequest `
        -Uri https://aka.ms/afs/agent/Server2012R2 `
        -OutFile "StorageSyncAgent.msi" 
} else {
    throw [System.PlatformNotSupportedException]::new("Azure File Sync is only supported on Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019")
}

Write-Host "Storage sync agent installation downloaded"

Write-Host "Begin installation..."

# Install the MSI. Start-Process is used to PowerShell blocks until the operation is complete.
# Note that the installer currently forces all PowerShell sessions closed - this is a known issue.
Start-Process -FilePath "StorageSyncAgent.msi" -ArgumentList "/quiet" -Wait

Write-Host "Installation of storage sync agent completed"

# Note that this cmdlet will need to be run in a new session based on the above comment.
# You may remove the temp folder containing the MSI and the EXE installer
Remove-Item -Path ".\StorageSyncAgent.msi" -Recurse -Force

Write-Host "Register the server to file sync service"
# connect to azure account using service principal
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $securedPass
Connect-AzAccount -ServicePrincipal -TenantId $tenantId -Credential $credential


# Get the azure resource for the storage sync service
$storageSyncService = Get-AzStorageSyncService -Name $storageSyncServiceName -ResourceGroupName PromitorRG

# register the server to the sync server
$registeredServer = Register-AzStorageSyncServer -ParentObject $storageSyncService

Write-Host "Registered the server to file sync service."