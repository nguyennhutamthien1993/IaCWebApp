variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "location_abbreviation" {
  type = string
}

variable "instance_count" {
  type = string
  default = "2"
}

variable "environment" {
  type = string
}

variable "application" {
  type = string
}

variable "managed_disk_name" {
  type = string
}

variable "vm_root_username" {
  type = string
}

variable "image_linux" {
  type = string
}

variable "common_tags" {
  type = object({
    Environment = string,
    Application = string,
    CreatedBy = string 
  })
}
