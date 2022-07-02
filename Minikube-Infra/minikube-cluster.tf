#creating public ec2 instance 
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "TF_key" {
  key_name = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
    provisioner "local-exec" { 
    #Create "TF_key.pem" to your computer!!
    command = <<-EOT
     echo '${tls_private_key.rsa.private_key_pem}' > ${path.cwd}/TF_key.pem
     chmod 400 ${path.cwd}/TF_key.pem 
     EOT
  }
}
resource "aws_instance" "publicinstance" {
  instance_type = "t2.large"
  ami = "ami-0d70546e43a941d70" #https://cloud-images.ubuntu.com/locator/ec2/ (Ubuntu)
  subnet_id = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.publicsecuritygroup.id]
  #keypair created in the region an i downloaded the private 
  key_name = "TF_key"
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "20"
  }
  tags = {

    "Name" = "Minikube-Cluster"
  }
  depends_on = [
    tls_private_key.rsa,
    aws_key_pair.TF_key,

  ]
  provisioner "remote-exec" {
    inline = [
      
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl",
      "sudo chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      

      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",

      "sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo chmod +x /home/ubuntu/minikube-linux-amd64",
      "sudo cp minikube-linux-amd64 /usr/local/bin/minikube",
      "sudo minikube start --memory 7500 --cpus 2 --disk-size 10GB --apiserver-ips=${self.public_ip} --listen-address=0.0.0.0 --driver=docker --force",
      
      "sudo kubectl get pods",
      "sudo kubectl create namespace tools",
      "sudo kubectl create namespace dev",
      
    ]

 
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./TF_key.pem")
    }
  }

  provisioner "local-exec" { 
    #adding instance public ip to inventory file 
    command = <<-EOT
     echo "[remote-server]" > ../Ansible-Credentials/inventory
     echo '${self.public_ip}' >> ../Ansible-Credentials/inventory
     sed -i -e 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'"${self.public_ip}"'/g'  ../Kubernetes-Resources/main.tf
     EOT
  }
 
}


