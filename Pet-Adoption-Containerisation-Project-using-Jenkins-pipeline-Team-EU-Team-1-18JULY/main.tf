##################################################################
# KEY PAIR
##################################################################

#UTILISE A KEYPAIR FOR EC2 ACCESS
resource "aws_key_pair" "PACPJP_key" {
  key_name   = "PACPJP_key"
  public_key = file(var.path-to-publickey)
}

##################################################################
# VPC
##################################################################

#CREATE VPC
resource "aws_vpc" "PACPJP-VPC" {
  cidr_block       = var.VPC_cidr
  instance_tenancy = "default"

  tags = {
    name = var.VPC_name
  }
}


##################################################################
# PUBLIC SUBNET 1
##################################################################

#CREATE PUBLIC SUBNET1

resource "aws_subnet" "PACPJP-PubSbnt1-EU1" {
  vpc_id            = aws_vpc.PACPJP-VPC.id
  cidr_block        = var.Pub_Subnet1_cidr
  availability_zone = "eu-west-2a"

  tags = {
    name = var.Pub_Subnet1_name
  }
}



##################################################################
# PUBLIC SUBNET 2
##################################################################

#CREATE PUBLIC SUBNET2

resource "aws_subnet" "PACPJP-PubSbnt2-EU1" {
  vpc_id            = aws_vpc.PACPJP-VPC.id
  cidr_block        = var.Pub_Subnet2_cidr
  availability_zone = "eu-west-2b"

  tags = {
    name = var.Pub_Subnet2_name
  }
}




##################################################################
# PRIVATE SUBNET 1
##################################################################

#CREATE PRIVATE SUBNET1

resource "aws_subnet" "PACPJP-PrvSbnt1-EU1" {
  vpc_id            = aws_vpc.PACPJP-VPC.id
  cidr_block        = var.Prv_Subnet1_cidr
  availability_zone = "eu-west-2a"

  tags = {
    name = var.Prv_Subnet1_name
  }
}


##################################################################
# PRIVATE SUBNET 2
##################################################################

#CREATE PRIVATE SUBNET2
resource "aws_subnet" "PACPJP-PrvSbnt2-EU1" {
  vpc_id            = aws_vpc.PACPJP-VPC.id
  cidr_block        = var.Prv_Subnet2_cidr
  availability_zone = "eu-west-2b"
  tags = {
    name = var.Prv_Subnet2_name
  }
}
##################################################################
# INTERNET GATEWAY (IGW)
##################################################################
#CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "PACPJP-IGw-EU1" {
  vpc_id = aws_vpc.PACPJP-VPC.id
  tags = {
    name = var.IGw_name
  }
}
##################################################################
# NAT GATEWAY (NAT-GW)
##################################################################
#CREATE NAT GATEWAY FOR PRIVATE SUBNET
resource "aws_nat_gateway" "PACPJP-NATGw-EU1" {
  allocation_id = aws_eip.PACPJP-EIP-EU1.id
  subnet_id     = aws_subnet.PACPJP-PubSbnt1-EU1.id
  tags = {
    Name = "PACPJP-NATGw"
  }
}
##################################################################
# ELASTIC IP
##################################################################
#CREATE ELASTIC IP FOR NATGw
resource "aws_eip" "PACPJP-EIP-EU1" {
  vpc = true
}
##################################################################
# ROUTE TABLE FOR PUBLIC SUBNET
##################################################################
#CREATE PUBLIC ROUTE TABLE
resource "aws_route_table" "PACPJP-PubRT-EU1" {
  vpc_id = aws_vpc.PACPJP-VPC.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.PACPJP-IGw-EU1.id
  }
  tags = {
    name = var.Pub_RT_name
  }
}
##################################################################
# ROUTE TABLE ASSOCIATIONS FOR PUBLIC SUBNET 1
##################################################################
#CREATE PUBLIC Sbnt1 w/Pub ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Pub1-RTAssc-EU1" {
  subnet_id      = aws_subnet.PACPJP-PubSbnt1-EU1.id
  route_table_id = aws_route_table.PACPJP-PubRT-EU1.id
}
##################################################################
# ROUTE TABLE ASSOCIATIONS FOR PUBLIC SUBNET 2
##################################################################
#CREATE PUBLIC Sbnt2 w/Pub ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Pub2-RTAssc-EU1" {
  subnet_id      = aws_subnet.PACPJP-PubSbnt2-EU1.id
  route_table_id = aws_route_table.PACPJP-PubRT-EU1.id
}
##################################################################
# ROUTE TABLE FOR PRIVATE SUBNET
##################################################################
#CREATE PRIVATE ROUTE TABLE
resource "aws_route_table" "PACPJP-PrvRT-EU1" {
  vpc_id = aws_vpc.PACPJP-VPC.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_nat_gateway.PACPJP-NATGw-EU1.id
  }
  tags = {
    name = var.Prv_RT_name
  }
}
##################################################################
# ROUTE TABLE ASSOCIATIONS FOR PRIVATE SUBNET 1
##################################################################

#CREATE PRIVATE Sbnt1 w/Prv ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Prv1-RTAssc-EU1" {
  subnet_id      = aws_subnet.PACPJP-PrvSbnt1-EU1.id
  route_table_id = aws_route_table.PACPJP-PrvRT-EU1.id
}
##################################################################
# ROUTE TABLE ASSOCIATIONS FOR PRIVATE SUBNET 2
##################################################################
#CREATE PRIVATE Sbnt2 w/Prv ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Prv2-RTAssc-EU1" {
  subnet_id      = aws_subnet.PACPJP-PrvSbnt2-EU1.id
  route_table_id = aws_route_table.PACPJP-PrvRT-EU1.id
}
##################################################################
# FRONTEND SECURITY GROUP
##################################################################
#CREATE FRONTEND SECURITY GROUP
resource "aws_security_group" "PACPJP_FE_SG_EU1" {
  name        = "PACPJP-FE_SGp-EU1"
  description = "Allow SSH & Jenkins inbound traffic"
  vpc_id      = aws_vpc.PACPJP-VPC.id
  ingress {
    description = "HTTP from VPC"
    from_port   = var.port_http
    to_port     = var.port_http
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "Jenkins from VPC"
    from_port   = var.port_jenkins
    to_port     = var.port_jenkins
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = var.fe_sg_name
  }
}
##################################################################
# BACKEND SECURITY GROUP
##################################################################
#CREATE BACKEND SECURITY GROUP
resource "aws_security_group" "PACPJP_BE_SG_EU1" {
  name        = "PACPJP-BE_SGp-EU1"
  description = "Allow SSH & MySQL inbound traffic"
  vpc_id      = aws_vpc.PACPJP-VPC.id
  ingress {
    description = "RDS from NAT"
    from_port   = var.port_mysql
    to_port     = var.port_mysql
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  #   ingress {
  #     description = "SSH from VPC"
  #     from_port   = var.port_ssh
  #     to_port     = var.port_ssh
  #     protocol    = "tcp"
  #     cidr_blocks = [var.all_cidr]
  #   }
  egress {
    from_port   = var.port_egress
    to_port     = var.port_egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = var.be_sg_name
  }
}

################################################################################
# JENKINS SERVER
################################################################################
resource "aws_instance" "PACPJP_Jenkins_Host" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.PACPJP-PubSbnt1-EU1.id
  vpc_security_group_ids      = [aws_security_group.PACPJP_FE_SG_EU1.id]
  key_name                    = var.keypair_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo yum update –y
sudo yum upgrade -y
sudo yum install wget -y
sudo yum install git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install fontconfig -y
sudo yum install java-11-openjdk -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum install docker-ce -y
# sudo systemctl start docker
echo "license_key: eu01xxbc4708e1fdb63633cc49bb88b3ce5cNRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo yum install sshpass -y
sudo su
echo Admin123@ | passwd ec2-user --stdin
echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd reload
sudo chmod -R 700 .ssh/
sudo chown -R ec2-user:ec2-user .ssh/
sudo su - ec2-user -c "ssh-keygen -f ~/.ssh/jenkinskey_rsa -t rsa -b 4096 -m PEM -N ''"
sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
sudo su - ec2-user -c 'sshpass -p "Admin123@" ssh-copy-id -i /home/ec2-user/.ssh/jenkinskey_rsa.pub ec2-user@${data.aws_instance.PACPJP_Ansible_Node.public_ip} -p 22'
ssh-copy-id -i /home/ec2-user/.ssh/jenkinskey_rsa.pub ec2-user@localhost -p 22
sudo usermod -aG docker jenkins
sudo usermod -aG docker jenkins ec2-user
sudo service sshd restart
sudo hostnamectl set-hostname Jenkins
EOF
  tags = {
    Name = "PACPJP_Jenkins_Host"
  }
}
################################################################################
# DOCKER SERVER
################################################################################
resource "aws_instance" "PACPJP_Docker_Host" {
  ami                         = var.ami
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.PACPJP-PubSbnt1-EU1.id
  vpc_security_group_ids      = [aws_security_group.PACPJP_FE_SG_EU1.id]
  key_name                    = var.keypair_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py 
sudo systemctl start docker
sudo systemctl enable docker
echo "license_key: eu01xxbc4708e1fdb63633cc49bb88b3ce5cNRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo usermod -aG docker ec2-user
sudo hostnamectl set-hostname Docker
EOF
  tags = {
    Name = "PACPJP_Docker_Host"
  }
}

data "aws_instance" "PACPJP_Docker_Host" {
  filter {
    name   = "tag:Name"
    values = ["PACPJP_Docker_Host"]
  }
  depends_on = [
    aws_instance.PACPJP_Docker_Host
  ]
}


################################################################################
# ANSIBLE SERVER
################################################################################
# Provision Ansible Host
resource "aws_instance" "PACPJP_Ansible_Node" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.keypair_name
  subnet_id                   = aws_subnet.PACPJP-PubSbnt1-EU1.id
  vpc_security_group_ids      = [aws_security_group.PACPJP_FE_SG_EU1.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install python3.8 -y
sudo alternatives --set python /usr/bin/python3.8
sudo yum -y install python3-pip
sudo yum install ansible -y
pip3 install ansible --user
sudo chown ec2-user:ec2-user /etc/ansible
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm
sudo yum install sshpass -y
echo "license_key: eu01xxbc4708e1fdb63633cc49bb88b3ce5cNRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo su
echo Admin123@ | passwd ec2-user --stdin
echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd reload
sudo chmod -R 700 .ssh/
sudo chown -R ec2-user:ec2-user .ssh/
sudo su - ec2-user -c "ssh-keygen -f ~/.ssh/pap2anskey_rsa -t rsa -N ''"
sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
sudo su - ec2-user -c 'sshpass -p "Admin123@" ssh-copy-id -i /home/ec2-user/.ssh/pap2anskey_rsa.pub ec2-user@${data.aws_instance.PACPJP_Docker_Host.public_ip} -p 22'
ssh-copy-id -i /home/ec2-user/.ssh/pap2anskey_rsa.pub ec2-user@localhost -p 22
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user
cd /etc
sudo chown ec2-user:ec2-user hosts
cat <<EOT>> /etc/ansible/hosts
localhost ansible_connection=local
[docker_host]
${data.aws_instance.PACPJP_Docker_Host.public_ip}  ansible_ssh_private_key_file=/home/ec2-user/.ssh/pap2anskey_rsa
EOT
sudo mkdir /opt/docker
sudo chown -R ec2-user:ec2-user /opt/docker
sudo chmod -R 700 /opt/docker
touch /opt/docker/Dockerfile
cat <<EOT>> /opt/docker/Dockerfile
# pull tomcat image from docker hub
FROM tomcat
FROM openjdk:8-jre-slim
#copy war file on the container
COPY spring-petclinic-2.4.2.war app/
WORKDIR app/
RUN pwd
RUN ls -al
ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
EOT
touch /opt/docker/docker-image.yml
cat <<EOT>> /opt/docker/docker-image.yml
---
 - hosts: localhost
  #root access to user
   become: true
   tasks:
   - name: login to dockerhub
     command: docker login -u cloudhight -p CloudHight_Admin123@
   - name: Create docker image from Pet Adoption war file
     command: docker build -t pet-adoption-image .
     args:
       chdir: /opt/docker
   - name: Add tag to image
     command: docker tag pet-adoption-image cloudhight/pet-adoption-image
   - name: Push image to docker hub
     command: docker push cloudhight/pet-adoption-image
   - name: Remove docker image from Ansible node
     command: docker rmi pet-adoption-image cloudhight/pet-adoption-image
     ignore_errors: yes
EOT
touch /opt/docker/docker-container.yml
cat <<EOT>> /opt/docker/docker-container.yml
---
 - hosts: docker_host
   become: true
   tasks:
   - name: login to dockerhub
     command: docker login -u cloudhight -p CloudHight_Admin123@
   - name: Stop any container running
     command: docker stop pet-adoption-container
     ignore_errors: yes
   - name: Remove stopped container
     command: docker rm pet-adoption-container
     ignore_errors: yes
   - name: Remove docker image
     command: docker rmi cloudhight/pet-adoption-image
     ignore_errors: yes
   - name: Pull docker image from dockerhub
     command: docker pull cloudhight/pet-adoption-image
     ignore_errors: yes
   - name: Create container from pet adoption image
     command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
     ignore_errors: yes
EOT
cat << EOT > /opt/docker/newrelic.yml
---
 - hosts: docker
   become: true
   tasks:
   - name: install newrelic agent
     command: docker run \
                     -d \
                     --name newrelic-infra \
                     --network=host \
                     --cap-add=SYS_PTRACE \
                     --privileged \
                     --pid=host \
                     -v "/:/host:ro" \
                     -v "/var/run/docker.sock:/var/run/docker.sock" \
                     -e NRIA_LICENSE_KEY=eu01xxbc4708e1fdb63633cc49bb88b3ce5cNRAL \
                     newrelic/infrastructure:latest
EOT
sudo hostnamectl set-hostname Ansible
EOF
  tags = {
    Name = "PACPJP_Ansible_Node"
  }
}

data "aws_instance" "PACPJP_Ansible_Node" {
  filter {
    name   = "tag:Name"
    values = ["PACPJP_Ansible_Node"]
  }

  depends_on = [
    aws_instance.PACPJP_Ansible_Node
  ]
}

#########################################################################
# The rest of the script should be applied AFTER Application Deployment #
#########################################################################

#Add an Application Load Balancer
resource "aws_lb" "PACPJP-alb" {
  name                       = "PACPJP1-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.PACPJP_FE_SG_EU1.id]
  subnets                    = [aws_subnet.PACPJP-PubSbnt1-EU1.id, aws_subnet.PACPJP-PubSbnt2-EU1.id]
  enable_deletion_protection = false

}
#Add a load balancer Listener
resource "aws_lb_listener" "PACPJP1-lb-listener" {
  load_balancer_arn = aws_lb.PACPJP-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PACPJP_tg.arn
  }
}
# Create a Target Group for Load Balancer
resource "aws_lb_target_group" "PACPJP_tg" {
  name     = "PACPJP1-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.PACPJP-VPC.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
    path                = "/"
  }
}

#Create Target group attachment
resource "aws_lb_target_group_attachment" "PACPJP-tg-att" {
  target_group_arn = aws_lb_target_group.PACPJP_tg.arn
  target_id        = aws_instance.PACPJP_Docker_Host.id
  port             = 8080
}


# # Create Docker_Host AMI Image
resource "aws_ami_from_instance" "PACPJP_Docker_Host_AMI" {
  name                    = "PACPJP_Docker_Host_AMI"
  source_instance_id      = data.aws_instance.PACPJP_Docker_Host.id
   snapshot_without_reboot = true
  depends_on = [
    aws_instance.PACPJP_Docker_Host,
  ]
  tags = {
    Name = "PACPJP-Docker-Host_AMI"
  }
}

# #Docker-launch-configuration
resource "aws_launch_configuration" "PACPJP1-lc" {
  name_prefix                 = "PACPJP1-lc"
  image_id                    = aws_ami_from_instance.PACPJP_Docker_Host_AMI.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.PACPJP_FE_SG_EU1.id]
  associate_public_ip_address = true
  key_name                    = var.keypair_name
user_data                   = <<-EOF
#!/bin/bash
sudo systemctl start docker
sudo systemctl enable docker
sudo docker start pet-adoption-container
sudo hostnamectl set-hostname DockerASG
EOF
}

#Creating Autoscaling Group 
resource "aws_autoscaling_group" "PACPJP-asg" {
  name                      = "PACPJP-asg"
  desired_capacity          = 3
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.PACPJP1-lc.name
  vpc_zone_identifier       = [aws_subnet.PACPJP-PubSbnt1-EU1.id, aws_subnet.PACPJP-PubSbnt2-EU1.id]
  target_group_arns         = ["${aws_lb_target_group.PACPJP_tg.arn}"]
  tag {
    key                 = "Name"
    value               = "PACPJP_Docker_ASG"
    propagate_at_launch = true
  }
}

#Creating Autoscaling Policy   
resource "aws_autoscaling_policy" "PACPJP-asg-pol" {
  name                   = "PACPJP-asg-pol"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.PACPJP-asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

################################################################################
# RDS DATABASE
################################################################################
# # Creating subnet group
# resource "aws_db_subnet_group" "PACPJP_DB_SN" {
#   name       = "pacpjp_db_sn"
#   subnet_ids = [aws_subnet.PACPJP-PrvSbnt1-EU1.id, aws_subnet.PACPJP-PrvSbnt2-EU1.id]

#   tags = {
#     Name = "PACPJP_DB_SN"
#   }
# }
# #Creating RDS database
# resource "aws_db_instance" "PACPJP_RDS" {
#   db_subnet_group_name   = aws_db_subnet_group.PACPJP_DB_SN.name
#   allocated_storage      = 10
#   identifier             = "pacpjp"
#   engine                 = "mysql"
#   engine_version         = "5.7"
#   instance_class         = "db.t2.micro"
#   multi_az               = true
#   db_name                = "PACPJP_DB_SQL"
#   username               = var.Rds_username
#   password               = var.Rds_password
#   parameter_group_name   = "default.mysql5.7"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.PACPJP_BE_SG_EU1.id]
# }

# Create Route 53
resource "aws_route53_zone" "PACPJP_Hosted_zone" {
name = var.domain_name
tags = {
Environment = "PACPJP_Hosted_zone"
}
}
resource "aws_route53_record" "PACPJP_A_record" {
zone_id = aws_route53_zone.PACPJP_Hosted_zone.zone_id
name = var.domain_name
type = "A"
alias {
name = aws_lb.PACPJP-alb.dns_name
zone_id = aws_lb.PACPJP-alb.zone_id
evaluate_target_health = false
}
}