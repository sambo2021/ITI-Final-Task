
![docker](https://img.shields.io/badge/Docker-Container-blue)
![terraform](https://img.shields.io/badge/Terraform-Infrastructure-darkblue)
![ansible](https://img.shields.io/badge/Ansible-Configuration-lightblack)
![jenkins](https://img.shields.io/badge/Jenkins-Automation-white)
![aws](https://img.shields.io/badge/AWS-CloudProvider-yellow)
![Kuberntes](https://img.shields.io/badge/kubernetes-Orchesterator-blue)
<div id="header" text-align="center"> <h1> Final ITI project intake 42 </h1></div>
<div>
<h4>
This project provision an ec2 on aws and configure to run minikube to function as a a single-node kubernetes cluster, deploy a nodejs app and install nginx to function as a reverse-proxy
Follow the Steps section to run this project.
</h4>
</div>

### :hammer_and_wrench: Languages and Tools :
<div >
<img src="https://github.com/devicons/devicon/blob/master/icons/nodejs/nodejs-original-wordmark.svg" title="nodejs" alt="nodejs" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/jenkins/jenkins-original.svg" title="Jenkins" alt="Jenkins" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/terraform/terraform-original-wordmark.svg" title="Terraform" alt="Terraform" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/ansible/ansible-original-wordmark.svg" title="Ansible" alt="Ansible" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/bash/bash-original.svg" title="Bash" alt="Bash" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/docker/docker-original-wordmark.svg" title="Docker" alt="docker" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/kubernetes/kubernetes-plain-wordmark.svg" title="kubernetes" alt="kubernetes" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/mysql/mysql-original-wordmark.svg" title=Mysql" alt="mysql" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/git/git-original-wordmark.svg" title="git" alt="git" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/github/github-original-wordmark.svg" title="github" alt="github" width="40" height="40"/>&nbsp;
 <img src="https://github.com/devicons/devicon/blob/master/icons/linux/linux-original.svg" title="linux" alt="linux" width="40" height="40"/>&nbsp;       
</div>

### Prerequisites

- Create an aws iam user with programmatic access. Run the following command to access the aws and create resources
```sh
   aws configure
```
- Create a S3 bucket to be used to store the terraform state file and enable versioning. Add the name of the S3 bucket to the main.tf file in the Minikube-Infra directory.
- Create a Dynamodb table named iti-final-task with partition key named LockID of type String.



### Steps to Deploy the application
- Clone the the repo
```sh
   git clone git@github.com:sambo2021/ITI-Final-Task.git
```
- Build infrastructure, run provisioner on EC2 to run minikube and nginx as a reverse proxy, deploy jenkins and nexus resources on the k8s cluster.
```sh
  ./Build.sh
```
- To build infrastructure, connect to remote minikube, deploy jenkins and nexus resources ->  ./Build.sh
- Open jenkins by ec2 ip and set user name and password, then download kubernetes plugin and configure a cloud node of kubernetes
- Then add config file taht downloades locally by script as secret file on jenkins using id mykubeconfig
- Dont forget to restart jenkins 
- Open nexus at ec2-ip/nexus and set username and password *the same user name and password as secret.tf in ./Kubernetes-Resources* and create docker hosted repo at http port 8082 
- Back to jenkins and create a job of pipline by this repo link and Jenkinsfile
- Then you can access your application at ec2-ip/app  
- To destroy the whole infrastructure->  ./Destroy.sh 
- To know how we build the docker file inside kaniko container see Links number 2 
- And to know prequesities that we had done of config file and kubernetes node cloud on jenkins see Links number 3

### What behind Build.sh
- creating empty key and 2 inventory files as shown :
  ```sh
    touch ./Minikube-Infra/TF_key.pem
    touch ./Ansible-Credentials/inventory
    touch ./Get-Passwords/inventory
  ```  
- building minikube cluster remotely on ec2 and using its local exec to set ec2 ip to inventory in ../Ansible-Credentials/inventory , ../Get-Passwords/inventory and kubernetes provider in ../Kubernetes-Resources/main.tf
   ```sh
    cd ./Minikube-Infra
    terraform init
    terraform apply -auto-approve
   ```

- play ansible that get all cluster certificates and config file to local ../Kubernetes-Resources
   ```sh
    cd ../Ansible-Credentials
    ansible-playbook  playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' --verbose
    ```
- after getting config file change its certificates urls by content of downlodes certificates 
   ```sh 
    cd ../Kubernetes-Resources
    var1=$(cat ca.crt | base64 -w 0 ; echo )
    sed -i -e "/certificate-authority:/ s/certificate-authority:[^/\n]*/certificate-authority-data: ${var1}/g"  ./config
    var2=$(cat client.crt | base64 -w 0 ; echo )
    sed -i -e "/client-certificate:/ s/client-certificate:[^/\n]*/client-certificate-data: ${var2}/g"  ./config
    var3=$(cat client.key | base64 -w 0 ; echo )
    sed -i -e "/client-key:/ s/client-key:[^/\n]*/client-key-data: ${var3}/g"  ./config  
    sed -i "s|/root/.minikube/ca.crt||g" ./config
    sed -i "s|/root/.minikube/profiles/minikube/client.crt||g" ./config
    sed -i "s|/root/.minikube/profiles/minikube/client.key||g" ./config
   ```
- now kubernetes provider has its ec2 ip which apiserver endpoint listen to and has all its certificate and has config that gonna be use by jenkins secret file credentials to deploy on minikube from pipeline 
- apply all kubernetes resources to build jenkins and nexus  
   ```sh
    terraform init
    terraform apply -auto-approve
   ``` 
- getting jenkins & nexus passwords and apply new nexus cluster ip service to ../CI-CD/app.yaml and ../Kubernetes-Resources/secret.tf
   ```sh
    cd ../Get-Passwords
    ansible-playbook -i inventory playbook.yaml --private-key ../Minikube-Infra/TF_key.pem -u ubuntu --ssh-common-args='-oStrictHostKeyChecking=no' 
   ``` 
- applly agian kubernetes resources to change that new service ip cause the old one from our previous build
   ```sh 
    cd ../Kubernetes-Resources
    terraform apply -auto-approve
   ```
- now pushing all new changes to git hub 
    ```sh
    cd ..
    git add . 
    git commit -m "update nexus service ip to new one"
    git push -u origin master
    ```
- printing jenkins password and nexus password on terminal 
   ```sh
    echo "Infrastructure has been built Successfully "
    echo "-------------------"
    echo "Jenkins-Password : "
    awk ' {print $1}' ./Get-Passwords/file.txt
    echo "-------------------"
    echo "nexus-Password : "
    awk ' {print $2}' ./Get-Passwords/file.txt 
    echo "--------------------"
   ```


### To access the cluster from Your machine do the following:
- Replace the certificates path with tha actual data and add -data to the end of each field for example certificate-authority: would become certificate-authority-data:
Also, use the output of the following commmand to populate the corresponding field 
cat ca.crt | base64 -w 0 ; echo 
cat client.key | base64 -w 0 ; echo
cat client.crt | base64 -w 0 ; echo 
- Change the value of server field to "https://public_IP_of_ec2:49154"
- Replace the kubeconfig file with this file 

### Links:
- Configure Kubernetes Cloud to run pod as a agents
https://devopscube.com/jenkins-build-agents-kubernetes/ 

- Build Docker image on kaniko
https://devopscube.com/build-docker-image-kubernetes-pod/

- Pipeline for to build and Deploy on k8s cluster:
https://www.youtube.com/watch?v=YnZQJAMK6JI&ab_channel=JustmeandOpensource