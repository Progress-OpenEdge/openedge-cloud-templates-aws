#!/bin/bash

# Load deployment parameters from configuration file
declare -A config
if [ -f "../deployment.conf" ]; then
    source ../deployment.conf
elif [ -f "./deployment.conf" ]; then
    source ./deployment.conf
else
    echo "deployment.conf not found. Please create it in the repo root or scripts directory."
    exit 1
fi

StackName=${1-test}

aws s3 cp ./deploy/cfn/${DBDeployPackage} s3://${PrivateBucket}/${DBDeployPackage}
aws s3 cp ./deploy/cfn/${PASOEDeployPackage} s3://${PrivateBucket}/${PASOEDeployPackage}
aws s3 cp ./deploy/cfn/${WebDeployPackage} s3://${PrivateBucket}/${WebDeployPackage}

aws s3 sync submodules s3://${PublicBucket}/openedge-cloud-templates-aws/submodules/ --delete 
aws s3 sync templates s3://${PublicBucket}/openedge-cloud-templates-aws/templates/ --delete 

aws cloudformation create-stack --stack-name $StackName \
    --capabilities CAPABILITY_IAM \
    --disable-rollback \
    --template-url https://s3.amazonaws.com/${PublicBucket}/openedge-cloud-templates-aws/templates/master.template.yaml \
    --parameters ParameterKey=KeyPairName,ParameterValue=${KeyPairName} \
                 ParameterKey=RemoteAccessCIDR,ParameterValue=0.0.0.0/0 \
                 ParameterKey=WebAccessCIDR,ParameterValue=0.0.0.0/0 \
                 ParameterKey=EmailAddress,ParameterValue=${EmailAddress} \
                 ParameterKey=QSS3BucketName,ParameterValue=${PublicBucket} \
                 ParameterKey=QSS3KeyPrefix,ParameterValue=openedge-cloud-templates-aws/ \
                 ParameterKey=InstanceType,ParameterValue=t3.large \
                 ParameterKey=MinScalingInstances,ParameterValue=1 \
		 ParameterKey=MaxScalingInstances,ParameterValue=3 \
                 ParameterKey=DeployBucket,ParameterValue=${PrivateBucket} \
                 ParameterKey=DeployBucketRegion,ParameterValue=${DeployBucketRegion} \
                 ParameterKey=DBDeployPackage,ParameterValue=${DBDeployPackage} \
                 ParameterKey=PASOEDeployPackage,ParameterValue=${PASOEDeployPackage} \
                 ParameterKey=WebDeployPackage,ParameterValue=${WebDeployPackage} \
                 "ParameterKey=AvailabilityZones,ParameterValue='${AvailabilityZones}'"

