# Powershell 3.0

# WARNING :: Use this script own risk !! 

# Global variables
#$volumeSize= $env:EBS_VOLUME_SIZE
#$driveLetter = $env:EBS_DRIVE_LETTER
#$awsSecretKey = $env:AWS_ACCESS_KEY_ID
#$awsAccessKey = $env:AWS_SECRET_ACCESS_KEY
#$Region = $env:REGION

$volumeSize= "4" 
$driveLetter = "E:" 
$awsSecretKey =  "AKIAIAUHWCPWPUPHKDPA"
$awsAccessKey = "SECRETE_KEY"

# Connect AWS 
Initialize-AWSDefaults -AccessKey $awsSecretKey -SecretKey $awsAccessKey -Region $Region

# Get details 
$InstanceId = (Invoke-WebRequest '169.254.169.254/latest/meta-data/instance-id').Content
$AZ = (Invoke-WebRequest '169.254.169.254/latest/meta-data/placement/availability-zone').Content
$Region = $AZ.Substring(0, $AZ.Length -1)

# Create EBS volume 
$volume = New-EC2Volume -Size $volumeSize -AvailabilityZone $AZ -VolumeType standard

While ($volume.Status -ne 'available')
{
  $volume = Get-EC2Volume -VolumeId $volume.volumeId
  Start-Sleep -Seconds 15
}

# Attach volume 
Add-EC2Volume -VolumeId $volume.VolumeId –InstanceId $InstanceId -Device 'xvdg'

echo $InstanceId

# Check if offline disk available or not, if not then exit 
@"
list disk
list volume
"@ | Out-File "list_disk.txt" -Encoding ascii 
diskpart /S .\list_disk.txt  > disk_status
$wordToFind = "Offline"
$input_file = "disk_status"
$count = @( Get-Content $input_file | Where-Object { $_.Contains("$wordToFind") } ).Count
if ( $count -ge 1 )
{
   echo "Offline disk found"
} else {

   echo "No Offline Disk"
   exit 
}

## Get Disk number of offline disk 
Get-Content disk_status | ForEach-Object{
    $split = $_ -split " "
	$columne_2 = $split[2]  -replace "`t|`n|`r",""
	$columne_3 = $split[3]  -replace "`t|`n|`r",""
	if ($_ -match "Offline"){
	   $offline_disk = $columne_3
	   echo $offline_disk
	}
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
	if ($_ -match "partition"){
	   $new_volume = $vol_columne_3
	   echo $new_volume
	}
}

# Format newly added volume 
@"
select disk $offline_disk
format FS=NTFS LABEL=TEST-DRIVE UNIT=64K QUICK NOERR
select volume $new_volume
assign mount=$driveLetter
"@ | Out-File "format_vol" -Encoding ascii 

diskpart /S .\format_vol
