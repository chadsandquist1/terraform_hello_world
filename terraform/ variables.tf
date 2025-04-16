variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet" {
    description = "The subnet of the vpc"
    type        = string
}

variable "container_image" {
    description = "container image of the cluster"
}

variable "bucket_name" {
    description = "s3 bucket name"
}