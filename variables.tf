variable "app_name" {
  description = "Name of the Elastic Beanstalk Application"
  type        = string
  default     = "flask-app"
}

variable "env_name" {
  description = "Elastic Beanstalk Environment Name"
  type        = string
  default     = "flask-app-env"
}

variable "platform" {
  description = "Platform for the environment"
  type        = string
  default     = "Python"
}

variable "solution_stack_name" {
  description = "Solution stack name for Elastic Beanstalk"
  type        = string
  default     = "64bit Amazon Linux 2 v3.4.8 running Python 3.8"
}

variable "env_type" {
  description = "Type of Beanstalk environment"
  type        = string
  default     = "Web Server"
}

variable "domain_name" {
  description = "Unique domain name prefix for the environment"
  type        = string
  default     = "flask-app"
}

variable "app_code_option" {
  description = "Choose between 'sample' or 'upload'"
  type        = string
  default     = "upload"
}

variable "app_source_type" {
  description = "Choose upload source: 's3' or 'local'"
  type        = string
  default     = "local"
}

variable "local_file_path" {
  description = "Path to the local .zip file to upload to S3"
  type        = string
  default     = "./application.zip"
}

variable "service_role_name" {
  description = "IAM role name for the Elastic Beanstalk service"
  type        = string
  default     = "aws-elasticbeanstalk-service-role-tf"
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the Elastic Beanstalk environment"
  type        = string
  default     = "aws-elasticbeanstalk-ec2-role-default"
}

variable "s3_bucket" {
  description = "S3 bucket for the application code (if upload_source is s3)"
  type        = string
  default     = ""
}
variable "key_pair" {
  description = "The name of the key pair to use for EC2 instances in the Elastic Beanstalk environment"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC to use for the Elastic Beanstalk environment."
  type        = string
  default     = "vpc-012bb66b464409e22"
}
variable "subnet_ids" {
  description = "List of subnet IDs to be used"
  type        = set(string)
  default     = ["valsubnet-04d15462dd7d16174"]
}

variable "enable_private_deployment" {
  description = "Deploy into private subnets only (no public IP)"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling"
  type        = bool
  default     = false
}

variable "min_instance_count" {
  description = "Minimum instance count for auto scaling"
  type        = number
  default     = 1
}

variable "max_instance_count" {
  description = "Maximum instance count for auto scaling"
  type        = number
  default     = 3
}

variable "app_version_label" {
  description = "Label for the Elastic Beanstalk application version"
  type        = string
  default     = "v1.0.0"
}
