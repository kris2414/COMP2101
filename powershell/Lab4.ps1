Write-Output "System Hardware:"
$system = Get-WmiObject win32_computersystem
$system | Select-Object Description | Format-List

Write-Output "Operating System:"
$os = Get-WmiObject win32_operatingsystem
$os | Select-Object Name, Version | Format-List

Write-Output "Processor Information:"
$processor = Get-WmiObject win32_processor
$processor | Select-Object Description, MaxClockSpeed, NumberOfCores, L3CacheSize | Format-List 

Write-Output "RAM Information:"
$totalram = 0
Get-WmiObject -class win32_physicalmemory | foreach {
    New-Object -TypeName psobject -Property @{
        Vendor = $_.manufacturer
        Description = $_.description
        "Size(MB)" = $_.capacity/1mb
        Bank = $_.banklabel
        Slot = $_.devicelocator
    }
    $totalram += $_.capacity/1mb
} | Format-Table Vendor, Description, "Size(MB)", Bank, Slot
"Total RAM: ${totalram}MB"
""

Write-Output "Physical Disk Summary:"
$diskdrives = Get-CIMInstance CIM_diskdrive
foreach ($disk in $diskdrives) {
      $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
      foreach ($partition in $partitions) {
            $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
                     new-object -typename psobject -property @{Vendor = $disk.Manufacturer
                                                               Model = $disk.model
                                                               "Size(GB)" = $logicaldisk.size / 1gb -as [int]
                                                               "Free Space(GB)" = $logicaldisk.FreeSpace / 1gb -as [int]
                                                               "Percentage Free" = $logicaldisk.FreeSpace * 100 / $logicaldisk.size
                                                               } | Format-Table Vendor, Model, "Size(GB)", "Free Space(GB)", "Percentage Free"
           }
      }
  } 

Write-Output "Network Adapter Summary:"
$adapters = get-ciminstance win32_networkadapterconfiguration 
$adapters | Where-Object ipenabled -EQ 1 | 
Select-Object Description, Index, IPAddress, IPSubnet, DNSDomain, @{n="DNSServer";e={$_.DNSServerSearchOrder }} |
Format-Table

Write-Output "Video Card Summary:"
$gpu = Get-WmiObject win32_videocontroller
$gpu | Select-Object @{n="Vendor";e={$_.AdapterCompatibility}}, Description, @{n="Screen Resolution";e={$_.VideoModeDescription}} | Format-List