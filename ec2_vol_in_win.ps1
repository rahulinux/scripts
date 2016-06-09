# Powershell 3.0

# WARNING :: Use this script own risk !! 

# 1. Check Current running instance has EBS volume, if already attached then exit
# 2. if no EBS then Create Volume in AWS
# 3. Attach to Current Instance where this script is running
# 4. Add tags to volumes
# 5. Change instance attribute to Delete Volume on termination
# 6. Search Offline disk, if not found then exit
# 7. If Offline disk found then create raw partition
# 8. Since windows create volume that increment, then this script will find the volume which respective to offline disk which we added.
# 9. Once volume get detected then it will format that volume with NTFS
# 10. Finally assign volume letter 

# Global variables
#$volumeSize= $env:EBS_VOLUME_SIZE
#$driveLetter = $env:EBS_DRIVE_LETTER
#$awsSecretKey = $env:AWS_ACCESS_KEY_ID
#$awsAccessKey = $env:AWS_SECRET_ACCESS_KEY
#$Region = $env:REGION

$volumeSize= "4" 
$volumeType = "standard" 
$driveLetter = "E:" 
$awsSecretKey =  "AKHSKJDH2839DHFAKE"
$awsAccessKey = "asdflksajflajsdlfjaslf2034SECRET"

# Check all disk before adding 

@"
list disk
"@ | Out-File "disk_list" -Encoding ascii 

diskpart /S disk_list | ?{$_ -match "Online"} | %{($_ -split "\s+")[2]} > before


# Get details 
$InstanceId = (Invoke-WebRequest '169.254.169.254/latest/meta-data/instance-id').Content
$AZ = (Invoke-WebRequest '169.254.169.254/latest/meta-data/placement/availability-zone').Content
$Region = $AZ.Substring(0, $AZ.Length -1)

# Connect AWS 
Initialize-AWSDefaults -AccessKey $awsSecretKey -SecretKey $awsAccessKey -Region $Region

$volumes = @(get-ec2volume) | ? { $_.Attachments.InstanceId -eq $InstanceId}

if ($($volumes.length) -gt 1){
    Write-Host "Volume exists, skipping Create and Attach."
    Write-Host "volumes: $($volumes)"
    exit 
} else {

    Write-Host "Creating Volume.."

    # Create EBS volume 
    $volume = New-EC2Volume -Size $volumeSize -AvailabilityZone $AZ -VolumeType $volumeType


    While ($volume.Status -ne 'available')
    {
       $volume = Get-EC2Volume -VolumeId $volume.volumeId
       Write-Host "Wating for volume to be available $volume.volumeId"
       Start-Sleep -Seconds 15
    }
  
    # Attach volume  
    Add-EC2Volume -VolumeId $volume.VolumeId –InstanceId $InstanceId -Device '/dev/xvdg'

    $spec = New-Object Amazon.EC2.Model.InstanceBlockDeviceMappingSpecification
    $spec.DeviceName = "/dev/xvdg"
    $spec.Ebs = New-Object Amazon.EC2.Model.EbsInstanceBlockDeviceSpecification
    $spec.Ebs.DeleteOnTermination = $true

    Edit-EC2InstanceAttribute -InstanceId $InstanceId -BlockDeviceMapping $spec
    
    Write-Host $volume

    #Tags for EBS Volume 
    
    $Tags = @()
    
    $CostCenter = New-Object Amazon.EC2.Model.Tag
    $CostCenter.Key = "Cost-Center"
    $CostCenter.Value = "$financecostcenter"
    $Tags += $CostCenter
        
    $ProjectID = New-Object Amazon.EC2.Model.Tag
    $ProjectID.Key = "Project-ID"
    $ProjectID.Value = "$financeprojectid"
    $Tags += $ProjectID
      
    $BackupTag = New-Object Amazon.EC2.Model.Tag
    $BackupTag.Key = "Backup"
    $BackupTag.Value = "$backup"
    $Tags += $BackupTag
      
    Write-Host "Setting EC2 Tags"
    New-EC2Tag -ResourceId $volume.VolumeId -Region $Region -Tags $Tags
       
}

# wait for 10 seconds to attach the disk 
Write-Host "Waiting for disk attachment"
Start-Sleep -s 15

# Check if offline disk available or not, if not then exit 
@"
list disk
"@ | Out-File "list_disk.txt" -Encoding ascii 
diskpart /S .\list_disk.txt  > disk_status

diskpart /S .\list_disk.txt | ?{$_ -match "Online"} | %{($_ -split "\s+")[2]} > after

$offline_disk = diff (Get-Content before) (Get-Content after) | foreach {$_.InputObject} | ?{$_ -match "Online"} | %{($_ -split "\s+")[2]}

if (!$offline_disk){
  
   Write-Host "No new disk found"
   exit 
}


# Adding disk part commands to file 
@"
select disk $offline_disk
online disk noerr
select disk $offline_disk 
convert GPT noerr
attributes disk clear readonly NOERR
create partition primary NOERR
"@ | Out-File "disk_cmd" -Encoding ascii 

diskpart /S .\disk_cmd

# Check with volume get added 
@"
select disk $offline_disk
detail disk
"@ | Out-File "added_vol" -Encoding ascii 

diskpart /S .\added_vol > check_vol 

## Get volume number of new disk 
Get-Content check_vol | ForEach-Object{
    $split = $_ -split " "
    $vol_columne_2 = $split[2]  -replace "`t|`n|`r",""
    $vol_columne_3 = $split[3]  -replace "`t|`n|`r",""
    if ($_ -match "RAW"){
       $new_volume = $vol_columne_3
       Write-Host "Raw Partition found at volume $new_volume"
       
    }
}

# Format newly added volume 
@"
select disk $offline_disk
select volume $new_volume
format FS=NTFS LABEL=TEST-DRIVE UNIT=64K QUICK NOERR
assign mount=$driveLetter
"@ | Out-File "format_vol" -Encoding ascii 

diskpart /S .\format_vol
