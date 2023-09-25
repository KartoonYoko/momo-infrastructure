variable "network_zone" {
  description = "Yandex.Cloud network availability zones"
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
  type        = set(string)
}