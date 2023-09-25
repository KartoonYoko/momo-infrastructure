variable "yc_instance_zone" {
  default     = "ru-central1-a"
  type        = string
  description = "Instance availability zone"
  validation {
    condition     = contains(toset(["ru-central1-a", "ru-central1-b", "ru-central1-c"]), var.yc_instance_zone)
    error_message = "Select availability zone from the list: ru-central1-a, ru-central1-b, ru-central1-c."
  }
  sensitive = true
  nullable  = false
} 

variable "yc_platform_id" {
  default     = "standard-v1"
  type        = string
  description = ""
  sensitive = false
  nullable  = false
}

variable "yc_scheduling_policy_preemptible" {
  type        = bool
  default     = false
}

variable "yc_image_id" {
  default     = ""
  type        = string
}

variable "yc_subnet_id" {
  default     = ""
  type        = string
}

variable "yc_instance_name" {
  default     = "vm-momo-instance"
  type        = string
}