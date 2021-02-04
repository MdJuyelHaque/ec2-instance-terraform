variable "developers_ips" {
  description = "Name -> IP address mapping for SGs"
  default = {
    "AC" = "220.221.133.66"

  }

}

variable "developers_ipv6" {
  description = "Name -> IP address mapping for SGs"
  default = {
    "AD" = "2602:18e:4181:d2e0:1173:b8d6:23f6:5a25"
  }

}

