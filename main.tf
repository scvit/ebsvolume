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





resource "aws_instance" "custom_ami_ec2" {
  ami = "ami-046bb63c4eb2b2743" # custom ami 입력 
  instance_type = "t3.micro"
  key_name = "mw.jo-test"
  associate_public_ip_address = true
  subnet_id = "subnet-f67ad99d"
  hibernation = false
  # security_groups = ["sg-cd5253ab"]


  root_block_device {
    #encrypted  = local.ec2_encrypt
    #kms_key_id = local.ec2_encrypt == "true" ? local.ec2_kms_key_arn : null

    delete_on_termination = true
    volume_type           = "gp3" #each.value.ec2_root_volume.ec2_root_volume_type
    volume_size           = 30 #each.value.ec2_root_volume.ec2_root_volume_size
    iops                  = 3000 #contains(["io1", "io2", "gp3"], each.value.ec2_root_volume.ec2_root_volume_type) && each.value.ec2_root_volume.ec2_root_volume_iops != "" ? each.value.ec2_root_volume.ec2_root_volume_iops : null
    throughput            = 250 #contains(["gp3"], each.value.ec2_root_volume.ec2_root_volume_type) && each.value.ec2_root_volume.ec2_root_volume_throughput != "" ? each.value.ec2_root_volume.ec2_root_volume_throughput : null

    # tags = "mw-root-volume-tags" # merge({ Name = "vol-${regex("ec2-(.*)", "${each.key}")[0]}-root" }, try(each.value.ec2_root_volume.ec2_root_volume_sub_tag, {}))
  }


  tags = {
    Name = "ec2-from-customami"

  }

}

output "ebs_volume" {
value = aws_instance.custom_ami_ec2.ebs_block_device
}


locals {
  ebs_id = {for k, v in aws_instance.custom_ami_ec2.ebs_block_device : v.device_name => v.volume_id }
}





# ebs volume 
resource "aws_ebs_volume" "example" {
  for_each = local.ebs_id
  type = "gp3"
 
  availability_zone = "ap-northeast-2a"
  size = 20
  throughput = 125
  iops = 3000

  tags = {
    Name = "ebs_volume_import-${each.key}"
  }

}


import {
  for_each = local.ebs_id
  to = aws_ebs_volume.example[each.key]
  id = each.value
}


 resource "aws_volume_attachment" "ebs_att" {
   for_each = local.ebs_id
   device_name =  each.key # "/dev/sdb"
   volume_id   =  each.value # aws_instance.custom_ami_ec2.ebs_block_device[0].volume_id
   instance_id = aws_instance.custom_ami_ec2.id
  }


import {
  for_each = local.ebs_id
  to = aws_volume_attachment.ebs_att[each.key]
  id = "${each.key}:${each.value}:${aws_instance.custom_ami_ec2.id}"
  # DEVICE_NAME:VOLUME_ID:INSTANCE_ID
}




/*
# root volume
resource "aws_ebs_volume" "root" {
  type = "gp3"
 
  availability_zone = "ap-northeast-2a"
  size = 10
  throughput = 125
  iops = 3000

  tags = {
    Name = "root_volume_1"
  }

   
}

import {
  to = aws_ebs_volume.root
  id = "vol-0be86ce25f03773a7"
}
*/


