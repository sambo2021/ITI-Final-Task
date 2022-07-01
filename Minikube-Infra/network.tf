#networking 
# Create a VPC
resource "aws_vpc" "iti_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Minikube-Cluster"
    Env  = "devops"
  }
}
#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.iti_vpc.id
  tags = {
    Name = "iti-getway"
  }
}
#public subnet 
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.iti_vpc.id
  cidr_block = "10.0.0.0/24" 
  availability_zone = "us-west-2a"  
  # to assign public ip to included instances
  map_public_ip_on_launch = true   
  tags = {
    Name = "public-subnet-1"
  }
}
#public route table
resource "aws_route_table" "public-route-table" {
  vpc_id     = aws_vpc.iti_vpc.id
 route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
 } 
  tags = {
    Name = "public-route-table"
  }
}
#associate routing to internet gatway
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}
#public security group
resource "aws_security_group" "publicsecuritygroup" {
  name = "PublicSecurityGroup"
  description = "PublicSecurityGroup"
  vpc_id = aws_vpc.iti_vpc.id
  #allowing only ssh from outside
  # ingress {
  #   description="ssh"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  # }
  #   ingress {
  #    description="http"
  #    cidr_blocks = ["0.0.0.0/0"]
  #    from_port = 80
  #    to_port = 80
  #    protocol = "tcp"
  # }
  #   ingress {
  #    description="https"
  #    cidr_blocks = ["0.0.0.0/0"]
  #    from_port = 443
  #    to_port = 443
  #    protocol = "tcp"
  # }
  #    ingress {
  #   description = "jenkins-node-port"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   from_port = 31000
  #   to_port =  31000
  #   protocol = "tcp"
  # }
  #    ingress {
  #   description = "nexus-node-port"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   from_port = 32000
  #   to_port =  32000
  #   protocol = "tcp"
  # }
 ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  #allowing going to outside
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "PublicSecurityGroup"
  }
}
#end of networking 
#-------------------------------------------------------











