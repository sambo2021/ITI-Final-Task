if [[  -f "./Minikube-Infra/TF_key.pem" ]]; then
    cd ./Kubernetes-Resources
    terraform destroy -auto-approve
    cd ../Minikube-Infra
    terraform destroy -auto-approve
    cd ..
    rm -f ./Minikube-Infra/TF_key.pem
    rm -f ./Ansible-Credentials/inventory
    rm -f ./Get-Passwords/inventory
    rm -f ./Kubernetes-Resources/client.crt
    rm -f ./Kubernetes-Resources/client.key
    rm -f ./Kubernetes-Resources/ca.crt
    rm -f ./Kubernetes-Resources/config
    rm -f ./Get-Passwords/file.txt
fi

