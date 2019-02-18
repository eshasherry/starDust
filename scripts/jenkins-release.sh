#!/bin/bash -l

#################### SETUP ####################
# set -e is for failing the script if one step fails
set -e
# set +x is for showing only the output of the commands does not echo actual command
set +x

# assumption $incrementLevel is accepted as parameter
if [ -z $incrementLevel ]; then
    echo "Did not pass incrementLevel as environment variable"
    exit 69
fi

#################### GIT FETCH LATEST TAG ####################
# IMPORTANT - to copy the ssh key into default location - so jenkins can fetch tag from git and later in tag and push tag to git
cp $mySecretLocationForSSHKey ~/.ssh/id_rsa

git fetch --tags
export latestTag=$(git tag --sort=-version:refname | head -1)
echo "Latest Tag $latestTag"

#################### NEW VERSION ####################
# set versioning using semver
npm install -g semver@5.4.1

export NEWVERSION=$(semver $latestTag -i $incrementLevel)
echo "New version is $NEWVERSION"


#################### DEPLOYING ####################
#This configuration is from https://github.com/LoyaltyOne/optout
#You need to setup LIGHTBEND Credentials and Post-Build Commit Status Hook and AWS Credentials for Deployment to DEV with ecs-service
echo "Setting up AWS profile, region, etc"
source /etc/profile
export AWS_DEFAULT_REGION=us-east-1
echo $ECR_ROLE
eval $(assume-role --role-arn="$ECR_ROLE")

# This is needed to login on AWS and push the image on ECR
# pip install awscli
eval $(aws ecr get-login --no-include-email)
echo "AWS setup done"

# Build and push image to ECR
echo "Maven clean, compile and creating package and push image"
mvn -Dbuild.number=$NEWVERSION clean package docker:build -DpushImage

echo "Docker package created and pushed"
#################### GIT TAGGING ####################
# tag git with latest version
echo "Trying to tag $NEWVERSION"
git tag "$NEWVERSION"
git push --tags
echo "Tag pushed"
