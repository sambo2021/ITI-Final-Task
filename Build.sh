#! /bin/bash 
if [[ ! -f "./Minikube-Infra/TF_key.pem" ]]; then
    touch ./Minikube-Infra/TF_key.pem
    chmod 400 ./Minikube-Infra/TF_key.pem
    touch ./Ansible-Credentials/inventory
    cd ./Minikube-Infra
    terraform apply -auto-approve
    cd ../Ansible-Credentials
    ansible-playbook -i inventory playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' --verbose
fi

