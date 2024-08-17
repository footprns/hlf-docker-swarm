variable "amb" {
  description = "Configuration for the blockchain network and member"
  type = object({
    NetworkId       = string
    MemberId        = string
    vpc_ep_svc_name = string
  })
}

variable "ec2_network" {
  description = "Configuration for the ec2 network"
  type = object({
    key_name          = string
    availability_zone = string
    vpc_id            = string
    subnet_id         = string
    security_groups = map(list(object({
      type        = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })))
  })
}

variable "fabric" {
  description = "Configuration for fabric node"
  type = object({
    manager = object({
    })
    worker1 = object({
    })
    worker2 = object({
    })
    worker3 = object({
    })
  })
}
