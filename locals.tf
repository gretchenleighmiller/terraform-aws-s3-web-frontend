locals {
  kebab_case_name       = join("-", regexall("[[:alnum:]]+", lower(var.name)))
  upper_camel_case_name = join("", regexall("[[:alnum:]]+", title(var.name)))

  bucket_name    = "${random_uuid.bucket_suffix.keepers.name}-${random_uuid.bucket_suffix.result}"
  domain_aliases = concat([var.fqdn], var.subject_alternative_names)
}
