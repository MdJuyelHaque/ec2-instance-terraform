variable "client_ips" {
  description = "Name -> CI address mapping for SGs"
  default = {
   "ABC" = "167.92.126.2"
  }
}
variable "client_cidrs" {
  description = "Name -> CI address mapping for SGs"
  default = {
    "ABCD" = "167.92.126.0/24"
  }
}

