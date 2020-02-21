# Shutdown all VirtualBox VMs, then shutdown the host

function Do-Shutdown {
    shutdown -s -t 5
}

function Get-VMs {
    return & $vbm list runningvms
}

$vbm = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$vms = Get-VMs

if ($vms.Length -eq 0) {
    Write-Host "No VirtualBox VM is running. Shutdown in 5 seconds."
    Do-Shutdown
}
else {
    Write-Host "The following VirtualBox VMs are runing: "
    foreach ($vm in $vms) {
        Write-Host "    $vm"
    }
    #Write-Host 
    $resp = Read-Host "Send ACPI Poweroff to the VMs (y/n)"
    if ($resp.ToLower().StartsWith('y')) {
        foreach ($vm in $vms) {
            $vmname = $vm.SubString(1, $vm.LastIndexOf(" ") - 2)
            Write-Host "Shutdown $vmname..."
            & $vbm controlvm $vmname acpipowerbutton
        }

        while ($vms.Length -gt 0) {
            Write-Host "Waiting for all VMs to shutdown..."
            Start-Sleep 1
            $vms = Get-VMs
        }

        Write-Host "OK, no VM running"
        Do-Shutdown
    } else {
        Write-Host "OK, please don't shutdown"
        Read-Host "Press ENTER to exit"
    }
}