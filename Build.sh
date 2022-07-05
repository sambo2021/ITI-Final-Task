#! /bin/bash 
if [[ ! -f "./Minikube-Infra/TF_key.pem" ]]; then
    touch ./Minikube-Infra/TF_key.pem
    #chmod 400 ./Minikube-Infra/TF_key.pem
    touch ./Ansible-Credentials/inventory
    cd ./Minikube-Infra
    terraform init
    terraform apply -auto-approve
    cd ../Ansible-Credentials
    ansible-playbook -i inventory playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' --verbose
    cd ../Kubernetes-Resources
    terraform init
    terraform apply -auto-approve
    cd ../Get-Passwords
    ansible-playbook -i inventory playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' 
    cd ../Kubernetes-Resources
    terraform apply -auto-approve
    cd ..
    echo "Infrastructure has been built Successfully "
    echo "Jenkins-Password : "
    sed -n '1p' ./Get-Passwords/file.echo 
    echo "-------------------"
    echo "nexus-Password : "
    sed -n '2p' ./Get-Passwords/file.echo 
    echo "--------------------"
    
    

fi

