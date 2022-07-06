#! /bin/bash 
if [[ ! -f "./Minikube-Infra/TF_key.pem" ]]; then
    # creating empty key and inventory
    touch ./Minikube-Infra/TF_key.pem
    touch ./Ansible-Credentials/inventory
    touch ./Get-Passwords/inventory
    # building minikube cluster locally and using its local exec 
    # to set ec2 ip to inventory in ../Ansible-Credentials/inventory and kubernetes provider in ../Kubernetes-Resources/main.tf
    cd ./Minikube-Infra
    terraform init
    terraform apply -auto-approve

    #play ansible that get all certificates and config file to local ../Kubernetes-Resources
    cd ../Ansible-Credentials
    ansible-playbook -i inventory playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' --verbose
    
    # after getting config file change its certificates by data 
    cd ../Kubernetes-Resources
    var1="$(cat ca.crt | base64 -w 0 ; echo )"
    sed -i -e "/certificate-authority:/ s/certificate-authority:[^/\n]*/certificate-authority-data: ${var1}/g"  ./config
    var2="$(cat client.crt | base64 -w 0 ; echo )"
    sed -i -e "/client-certificate:/ s/client-certificate:[^/\n]*/client-certificate-data: ${var2}/g"  ./config
    var3="$(cat client.key | base64 -w 0 ; echo )"
    sed -i -e "/client-key:/ s/client-key:[^/\n]*/client-key-data: ${var3}/g"  ./config  
    
    # now kubernetes provider has its ec2 ip which apiserver endpoint listen to 
    # and has all its certificate 
    # and has config that gonna be use by jenkins secret file credentials to deploy on minikube from pipeline 
    # apply all kubernetes resources 

    terraform init
    terraform apply -auto-approve
    
    # getting jenkins & nexus passwords and apply new nexus cluster ip service to ../CI-CD/app.yaml
    cd ../Get-Passwords
    ansible-playbook -i inventory playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' 
    # applly agian kubernetes resources to change that new service ip cause the old one from our previous build
    cd ../Kubernetes-Resources
    terraform apply -auto-approve
    
    cd ..
    echo "Infrastructure has been built Successfully "
    echo "Jenkins-Password : "
    sed -n '1p' ./Get-Passwords/file.txt
    echo "-------------------"
    echo "nexus-Password : "
    sed -n '2p' ./Get-Passwords/file.txt 
    echo "--------------------"
    echo "nexus-repo-cluster-ip : "
    sed -n '3p' ./Get-Passwords/file.txt 
    
    

fi

