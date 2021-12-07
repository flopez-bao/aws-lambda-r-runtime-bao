#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

function releaseToRegion {
    version=$1
    region='us-east-1'
    bucket="aws-lambda-r-runtime.$region"
    echo "publishing layers to region $region"
    sam package \
        --output-template-file packaged.yaml \
        --s3-bucket r-lambda-runtimes \
        --s3-prefix R-${version} \
        --region ${region}
    echo "passed sam package..."
    version_="${version//\./_}"
    stack_name=r-${version//\./-}
    sam deploy \
        --template-file packaged.yaml \
        --stack-name ${stack_name} \
        --parameter-overrides Version=${version_} \
        --no-fail-on-empty-changeset \
        --region ${region} \
        --capabilities CAPABILITY_IAM
    layers=(runtime recommended awspack)
    echo "Published layers:"
    aws cloudformation describe-stack-resources \
        --stack-name ${stack_name} \
        --query "StackResources[?ResourceType=='AWS::Lambda::LayerVersion'].PhysicalResourceId" \
        --region ${region}
}

regions=(
          us-east-1
        )

for region in "${regions[@]}"
do
    releaseToRegion ${VERSION} ${region}
done
