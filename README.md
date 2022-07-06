
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
 <img src="https://github.com/devicons/devicon/blob/master/icons/centos/centos-original-wordmark.svg" title="centos" alt="centos" width="40" height="40"/>&nbsp;        
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
- open jenkins by ec2 ip and set user name and password, then download kubernetes plugin and configure a cloud node of kubernetes as per kink number 1 
- then add config file taht downloades locally by script as secret file on jenkins using id mykubeconfig
- dont forget to restart jenkins 
- open nexus at ec2-ip/nexus and set username and password *the same user name and password as secret.tf in ./Kubernetes-Resources* and create docker hosted repo at http port 8082 
- back to jenkins and create a job of pipline by this repo link and Jenkinsfile
- then you can access your application at ec2-ip/app  
- to destroy the whole infrastructure->  ./Destroy.sh 
- to know how we build the docker file inside kaniko container see Link number 2 
- and to know prequesities that we had done of config file and kubernetes node cloud on jenkins see Link nunber 3



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