
variable "yc_cloud_id" { 
  type = string 
}

variable "yc_folder_id" { 
  type = string 
}

variable "yc_key_file" {
  type    = string
  default = "./key.json"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}


variable "zone_a" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "zone_b" {
  description = "Second availability zone"
  type        = string
  default     = "ru-central1-b"
}

variable "vm_user" {
  description = "Default VM user"
  type        = string
  default     = "ubuntu"
}