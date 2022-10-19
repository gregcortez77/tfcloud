# Providers

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-2"
  alias= "OH"
}

# US-EAST-1 VPC & Subnet

resource "aws_vpc" "va_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name       = "VA_VPC"
    Descrption = "Im studying"
  }
}


resource "aws_subnet" "va_public" {
    depends_on = [
      aws_vpc.va_vpc
    ]
    vpc_id = aws_vpc.va_vpc.id
    cidr_block = "10.0.0.0/16"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public"
    }
  
}

# US-EAST-2 VPC

resource "aws_vpc" "oh_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "OH_VPC"
      Description = "Im studying part 2"
    }
    provider = aws.OH
  
}

# NTP/US-EAST-1 instance (in subnet)

resource "aws_instance" "ntp" {
    instance_type = "t2.micro"
    ami = "ami-026b57f3c383c2eec"
    tags = {
        Name = "NTP Server"
        Description = "NTP server in OH region"
    }
    depends_on = [
      aws_vpc.va_vpc
    ]
    subnet_id = aws_subnet.va_public.id
}

# Module for instance in US-EAST-1


module "ec2" {
    source = "./ec2"
    depends_on = [aws_instance.ntp]
    providers = {
      aws = aws.OH
     }
}

# Outputs

output "outputs" {
    value = [
        aws_subnet.va_public.id,
        aws_vpc.va_vpc.id        
    ]
}