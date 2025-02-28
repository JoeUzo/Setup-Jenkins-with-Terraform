resource "aws_security_group" "jenkins-sg" {
  name = "jenkins-sg"
  description = "Allow inbound traffic"
  vpc_id = module.vpc_module.vpc_id

  dynamic "ingress" {
    for_each = [
        {from = 80, to = 80, description = "Allow Port 80"},
        {from = 22, to = 22, description = "Allow Port 22"},
        {from = 8080, to = 8080, description = "Allow Port 8080"},
        {from = 50000, to = 50000, description = "Allow Port 50000"},
    ]
    content {
        from_port = ingress.value.from
        to_port = ingress.value.to
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all IPs and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }

}