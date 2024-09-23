
if [ $# == 0 ]; then 
    echo "Missing gitops repo parameter"
    exit 
fi 

echo "Clone Gitops Repo" 
START_DIR=$(pwd)
rm -rf gitops-repo
git clone $1 gitops-repo

echo "Clone Jenkins Shared Library" 
rm -rf jenkins-lib
git clone https://github.com/redhat-appstudio/tssc-sample-jenkins jenkins-lib
cp jenkins-lib/resources/common.sh gitops-repo/rhtap
cp jenkins-lib/resources/gather-deploy-images.sh gitops-repo/rhtap
cp jenkins-lib/resources/init.sh gitops-repo/rhtap
cp jenkins-lib/resources/verify-deps-exist gitops-repo/rhtap
cp jenkins-lib/resources/verify-enterprise-contract.sh gitops-repo/rhtap 

echo "Used the same tasks from Jenkins to validate locally"
cd gitops-repo
export COSIGN_SECRET_PASSWORD="dummy"
export COSIGN_SECRET_KEY="dummy"
REQUIRED_ENV="MY_QUAY_USER COSIGN_SECRET_PASSWORD COSIGN_SECRET_KEY COSIGN_PUBLIC_KEY"
REQUIRED_BINARY="tree cosign ec "
rhtap/verify-deps-exist "$REQUIRED_ENV" "$REQUIRED_BINARY" 
ERR=$?
echo "Dependency Error $1 = $ERR" 
if [ $ERR != 0 ]; then
	echo "Fatal Error code for $1 = $ERR" 
	exit $ERR
fi
 
SETUP_ENV=rhtap/env.sh  
source $SETUP_ENV  

COUNT=0

function cleanup () {
    cd $START_DIR
    rm -rf gitops-repo
    rm -rf jenkins-lib
    rm -rf results 
}

function run () { 
    let "COUNT++"
    printf "\n"
    printf '=%.0s' {1..31}
    printf " %d " $COUNT
    printf '=%.0s' {1..32}
    bash $1
    ERR=$?
    echo "Error code for $1 = $ERR"
    printf '_%.0s' {1..64}
    printf "\n" 
    if [ $ERR != 0 ]; then
        echo "Fatal Error code for $1 = $ERR" 
        cleanup
        exit 1
    fi
}

run  "rhtap/init.sh"  
run  "rhtap/gather-deploy-images.sh"  
run  "rhtap/verify-enterprise-contract.sh"   

tree ./results 

cleanup