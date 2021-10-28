# @component CalcApp:AWS_VPC:SecurityGroup (#sg)
# @connects #vpc to #sg with Network
# @control Ingress Egress Lists (#ingressegress)
# @exposes #subnet to #uaccess with NOT defining traffic allowed into the vpc
# @mitigates #subnet against #uaccess with #ingressegress

#by only allowing traffic from given IP's & Ports
resource "aws_security_group" "cyber94_jhiguita_calculator_2_webserver_sg_tf" {
  name = "cyber94_jhiguita_calculator_2_webserver_sg"

  vpc_id = var.var_aws_vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cyber94_jhiguita_calculator_2_webserver_sg"
  }
}

# @component CalcApp:AWS_VPC:SecurityGroup:Subnet:AppServer (#app)
# @connects #subnet to #app with Network
# @component CalcApp:AWS_VPC:SecurityGroup:Subnet:DBServer (#db)
# @connects #subnet to #db with Network
# @component CalcApp:AWS_VPC:SecurityGroup:Subnet:AppServer:CalculatorApp (#calc)
# @connects #app to #calc with Network
# @threat Unauthorised Access (#uaccess)
# @control AWS Vault (#vault)
# @exposes #app to #uaccess with AWS keys not being properly secured or managed
# @mitigates #app against #uaccess with #vault


resource "aws_instance" "cyber94_jhiguita_calculator_2_webserver_tf" {
    ami = var.var_aws_ami_ubuntu_1804
    instance_type = "t2.micro"
    subnet_id = var.var_web_subnet_id
    count = 2
    associate_public_ip_address = true
    key_name = var.var_ssh_key_name

    vpc_security_group_ids = [aws_security_group.cyber94_jhiguita_calculator_2_webserver_sg_tf.id]
    user_data = templatefile("../init-scripts/docker-install.sh", {SPECIAL_ARG="This is an argument from Terraform"})
    tags = {
      Name = "cyber94_jhiguita_calculator_2_webserver_tf_${count.index}"
    }
}

resource "aws_route53_record" "cyber94_jhiguita_calculator_2_webserver_dns_tf" {
  zone_id = var.var_dns_zone_id
  name = "www"
  type = "A"
  ttl = "30"
  records = aws_instance.cyber94_jhiguita_calculator_2_webserver_tf.*.public_ip

}
