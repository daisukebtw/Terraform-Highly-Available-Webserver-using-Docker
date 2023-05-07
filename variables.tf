variable "region" {
  description = "AWS Region to use"
  type        = string
  default     = "eu-central-1"
}

variable "env" {
  description = "Environment name to use"
  type        = string
  default     = "dev"
}

variable "lc_name" {
  description = "Launch Configuration name"
  type        = string
  default     = "Main-LC"
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "S3 Bucket name"
  type        = string
  default     = "daisuke-terraform"
}

variable "s3_bucket_name" {
  description = "S3 Bucket name"
  type        = string
  default     = "daisuke-docker"
}
