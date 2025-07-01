variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the Elastic Beanstalk Application"
  type        = string
}

variable "app_tags" {
  description = "Optional tags for the application"
  type        = map(string)
  default     = {
    Environment = "Dev"
    Project     = "Name of the Project"
  }
}

variable "service_role_name" {
  description = "IAM role name for the Elastic Beanstalk service"
  type        = string
  default     = "aws-elasticbeanstalk-service-role"
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the Elastic Beanstalk environment"
  type        = string
  default     = "aws-elasticbeanstalk-ec2-role-default"
}

variable "env_name" {
  description = "Elastic Beanstalk Environment Name"
  type        = string
}

variable "env_description" {
  description = "Environment Description"
  type        = string
  default     = ""
}

variable "env_type" {
  description = "Type of Beanstalk environment"
  type        = string
  default     = "WebServer"
}

variable "solution_stack_name" {
  description = "Full solution stack name for Elastic Beanstalk (e.g. 64bit Amazon Linux 2 v3.4.8 running Node.js 18)"
  type        = string
}

variable "platform" {
  description = "Platform for the environment (Java, Node.js, Python, Ruby, Go, .NET, PHP)"
  type        = string
  validation {
    condition = contains(
      ["Java", "Node.js", "Python", "Ruby", "Go", ".NET", "PHP", "Docker"],
      var.platform
    )
    error_message = "This platform is not supported in EB"
  }
}

variable "domain_name" {
  description = "Unique domain name prefix for the environment"
  type        = string
}

variable "app_code_option" {
  description = "Choose between 'sample' or 'upload'"
  type        = string
  default     = "sample"
}

variable "app_source_type" {
  description = "Choose upload source: 's3' or 'local'"
  type        = string
  default     = "s3"
  validation {
    condition     = contains(["s3", "local"], var.app_source_type)
    error_message = "app_source_type must be either 's3' or 'local'."
  }
}

variable "s3_bucket" {
  description = "S3 bucket for the application code (if upload_source is s3)"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 object key for the app code"
  type        = string
  sensitive   = true
  default     = ""
}

variable "local_file_path" {
  description = "Path to the local .zip file to upload to S3"
  type        = string
  default     = ""
}

variable "key_pair" {
  description = "The name of the key pair to use for EC2 instances in the Elastic Beanstalk environment"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC to use for the Elastic Beanstalk environment."
  type        = string
  default     = ""
  }

variable "subnet_ids" {
  description = "List of subnet IDs to be used"
  type        = list(string)
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
  default =    ""
}

variable "enable_private_deployment" {
  description = "Deploy into private subnets only (no public IP)"
  type        = bool
  default     = true
}
