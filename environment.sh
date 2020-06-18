export TF_VAR_default_vpc=$(aws ec2 describe-vpcs | jq -r '[.Vpcs[] | select(.IsDefault==true)][0].VpcId')
export TF_VAR_subnet_id=$(aws ec2 describe-subnets | jq -r '.Subnets[] | select((.VpcId==env.TF_VAR_default_vpc) and .AvailabilityZone=="us-east-1d").SubnetId')
