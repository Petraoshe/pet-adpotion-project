output "Jenkins_Public_ip" {
  value = aws_instance.PACPJP_Jenkins_Host.public_ip
}

output "Docker_Public_ip" {
  value = aws_instance.PACPJP_Docker_Host.public_ip
}

output "Ansible_Public_ip" {
  value = aws_instance.PACPJP_Ansible_Node.public_ip
}
#########################################################################
# The rest of the script should be applied AFTER Application Deployment #
#########################################################################
output "Name_Servers" {
  value = aws_route53_zone.PACPJP_Hosted_zone.name_servers
}
output "lb_dns_name_docker" {
  value = aws_lb.PACPJP-alb.dns_name
}