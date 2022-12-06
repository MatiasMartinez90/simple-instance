terraform{
    backend "s3" {
        bucket = "state-tf-bgh"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "wlab-prd-v2" {
  ami           = "ami-08e167817c87ed7fd"
  instance_type = "t3.micro"
  key_name = "mmartinez"
  vpc_security_group_ids = ["sg-0597cfbb551a7bf27"]
  availability_zone = "us-east-1a"

  tags = {
    Name = "wlab-prd-v3"
  }
}
locals {
  volumes = {
 
    "/dev/sdf" = "2"    
    "/dev/sdg" = "50"                    
    }
}

resource "aws_ebs_volume" "wlab-prd-v2-volumes" {
  for_each          = local.volumes
  type              = "gp2"
  size              = each.value
  availability_zone = "us-east-1a"
  tags = {
    Name = "SAP-PRD-v2"
  }
}

resource "aws_volume_attachment" "wlab-prd-v2-volumes" {
  for_each    = local.volumes
  device_name = each.key
  instance_id = aws_instance.wlab-prd-v2.id
  volume_id   = aws_ebs_volume.wlab-prd-v2-volumes[each.key].id
}


output "ip_instance" {
  value = aws_instance.wlab-prd-v2.public_ip
}
