terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~>5.0"
      configuration_aliases = [aws.east]
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
