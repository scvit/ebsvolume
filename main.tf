terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.75.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  #access_key = var.access_key
  #secret_key = var.secret_key
}


# resource "aws_vpc" "main_change" {
#   cidr_block       = "10.20.0.0/16"
#   instance_tenancy = "default"

#   enable_dns_hostnames = true # route 53 dns하려면 필요 

#   tags = {
#     Name = "check_vcs_mwjo_change"
#   }
# } 

resource "aws_instance" "backup_ec2" {
  ami = "ami-02ecc1e340af39817" # custom ami 입력 
  instance_type = "t3.micro"
  key_name = "mw.jo-test"
  associate_public_ip_address = true
  subnet_id = "subnet-f67ad99d"
  hibernation = false
  # security_groups = ["sg-cd5253ab"]

  tags = {
    Name = "ec2-from-customami"

  }

}

/*
# ebs volume 
resource "aws_ebs_volume" "example" {
  type = "gp3"
 
  availability_zone = "ap-northeast-2a"
  size = 25
  throughput = 125
  iops = 3000

  tags = {
    Name = "ebs_volume_import"
  }

}

import {
  to = aws_ebs_volume.example
  id = "vol-0556ce682f8fe3a01"
}


 resource "aws_volume_attachment" "ebs_att" {
   device_name = "/dev/sdb"
   volume_id   =  "vol-0f64fef1c4faec301"
   instance_id = "i-092715b95501742bf"
  }

import {
  to = aws_volume_attachment.ebs_att
  id = "/dev/sdb:vol-0f64fef1c4faec301:i-092715b95501742bf"
  # DEVICE_NAME:VOLUME_ID:INSTANCE_ID
}

# root volume
resource "aws_ebs_volume" "root" {
  type = "gp3"
 
  availability_zone = "ap-northeast-2a"
  size = 8
  throughput = 125
  iops = 3000

  tags = {
    Name = "root_volume_1"
  }

   
}

import {
  to = aws_ebs_volume.root
  id = "vol-05310c3e1eb175c5f"
}


*/ 
