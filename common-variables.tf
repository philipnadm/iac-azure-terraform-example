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

variable "tags" {
  description = "A map of tags that can be used as a variable"
  type = map(string)

  default = {
    environment = "test"
    department = "562301"
  }
}