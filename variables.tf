variable "location" {
  type = string
   description = "Azure location of terraform server environment"
   default = "Australia East"
 }

variable "tags" {
  type = map(string)
  
  default = {"TEST":"TEEEEEEEEEEEEEEEEE"}
}
   
