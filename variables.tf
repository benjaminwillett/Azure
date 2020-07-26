variable "location" {}

variable "tags" {
  type = "map"
  
  default = {
    Environment = "Terraform GS"
    Dept = "Engineering"
  }
}
   
