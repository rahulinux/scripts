instance_ids="IDS SEPERAED BY SPACE"

for id in $instance_ids
do
   # aws ec2 modify-instance-attribute --dry-run --instance-type t2.large --instance-id $id
   aws ec2 modify-instance-attribute --instance-type t2.large --instance-id $id 
done 
