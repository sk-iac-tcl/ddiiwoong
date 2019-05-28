provider "aws" {
    region = "ap-northeast-2"
}

resource "aws_instance" "example" {
    ami                    = "ami-067c32f3d5b9ace91"
    instance_type          = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]

    user_data = <<-EOF
                #! /bin/bash
                echo "Hello" > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port   = "${var.server_port}"
        to_port     = "${var.server_port}"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "The port the server will use for HTTP request"
    default     = 8080
}

output "public_ip" {
    value = "${aws_instance.example.public_ip}"
}