variable "VPC_cidr" {
  default = "10.0.0.0/16"
}

variable "VPC_name" {
  default = "PACPJP-VPC"
}

variable "Pub_Subnet1_cidr" {
  default = "10.0.1.0/24"
}

variable "Pub_Subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "Prv_Subnet1_cidr" {
  default = "10.0.3.0/24"
}

variable "Prv_Subnet2_cidr" {
  default = "10.0.4.0/24"
}

variable "all_cidr" {
  default = "0.0.0.0/0"
}

variable "Pub_Subnet1_name" {
  default = "PACPJP-PubSbnt1"
}
variable "Pub_Subnet2_name" {
  default = "PACPJP-PubSbnt2"
}

variable "Prv_Subnet1_name" {
  default = "PACPJP-PrvSbnt1"
}

variable "Pub_RT_name" {
  default = "PACPJP-PubRT"
}
variable "Prv_RT_name" {
  default = "PACPJP-PrvRT"
}
variable "Prv_Subnet2_name" {
  default = "PACPJP-PrvSbnt2"
}
variable "fe_sg_name" {
  default = "PACPJP-FE_SG"
}
variable "be_sg_name" {
  default = "PACPJP-BE_SG"
}
variable "IGw_name" {
  default = "PACPJP-IGw"
}
variable "path-to-publickey" {
  default     = "~/Keypairs/PACPJP_key.pub"
  description = "this is path to the keypair in our local machine"
}

variable "port_mysql" {
  default = "3306"
}

variable "port_http" {
  default = "80"
}

variable "port_ssh" {
  default = "22"
}

variable "port_jenkins" {
  default = "8080"
}

variable "port_docker" {
  default = "8085"
}

variable "port_egress" {
  default = "0"
}

variable "keypair_name" {
  default     = "PACPJP_key"
  description = "keypair name"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "ami" {
  default = "ami-035c5dc086849b5de"
}
variable "domain_name" {
  default = "divinedevs.com"
}

variable "rds_username" {
  default = "admin"
}
variable "rds_password" {
  default = "Admin123"
}