# Verify EC

This repo is used to validate EC using the RHTAP 1.4 Jenkins support.

The script checks out the gitops repo and the library components and runs them locally using the gitops repo env.sh file

Local env will need the environment variables for COSIGN_PUBLIC (this will be checked by the scripts)


## Usage
```
bash verify-ec.sh https://github.com/northdepot/demo-go-jenkins-gitops
```
