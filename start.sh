#!/usr/bin/env bash

# if you plan on using AWS CLI and would like to pass environment variables to the Vagrant VM 
# prefix . or source before this script to set the environment variables 

echo "Enter AWS default region: "
read AWS_REGION 
echo "Enter AWS Key ID: "
read AWS_KEYID 
echo "Enter AWS Secret Key: "
read AWS_SECRET 
#echo "Enter AWS MFA role ARN: "
#read AWS_ROLEARN
#echo "Enter AWS MFA ARN: "
#read AWS_MFAARN
export AWS_DEFAULT_REGION=$AWS_REGION
export AWS_ACCESS_KEY_ID=$AWS_KEYID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET
#export AWS_MFA_ROLE_ARN=$AWS_ROLEARN
#export AWS_MFA_ARN=$AWS_MFAARN
