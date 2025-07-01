module "beanstalk" {
  source = "./modules/beanstalk"

  app_name              = "my-python-app"
  env_name              = "my-python-env"
  env_type              = "WebServer"
  solution_stack_name   = "64bit Amazon Linux 2023 v4.6.0 running Python 3.12"
  app_tags = {
    Environment = "dev"
    Project     = "python-eb"
  }

  domain_name           = "my-python-app-domain"
  app_code_option       = "upload"
  app_source_type       = "local"
  local_file_path       = "./flask-app.zip"
  s3_key                = ""
  s3_bucket             = ""
  app_version_label     = ""
  platform              = "Python"

  service_role_name     = "aws-elasticbeanstalk-service-role"
  instance_profile_name = "${var.app_name}-eb-instance-profile"

  vpc_id                = "vpc-012bb66b464409e22"
  subnet_ids            = ["subnet-03a15fbaa914ec04c"]
  enable_private_deployment = false
}