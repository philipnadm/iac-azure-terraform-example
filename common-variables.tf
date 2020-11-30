#Define application name
variable "app_name" {
  type = string
  description = "Your unique application name, used as a prefix for all resources"

}
#Define application environment
variable "app_environment" {
  type = string
  description = "Application environment"
  default = "test"
}

#Define the internal department responsible for the application
variable "department_id" {
  type = string
  description = "Application environment"
  default = "562301"
}

#Define subscription ID
variable "sub_id" {
  type = string
  description = "Subscription ID"
  
}