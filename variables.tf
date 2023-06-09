variable "name" {
  type        = string
  description = "The name of the website."
}

variable "route53_zone_id" {
  type        = string
  description = "The Route 53 Zone ID."
}

variable "fqdn" {
  type        = string
  description = "The FQDN of the website."
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "A list of subject alternative names."
  default     = []
}
