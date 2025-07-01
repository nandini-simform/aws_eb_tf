resource "aws_iam_role" "eb_service_role" {
  name               = var.service_role_name
  assume_role_policy = data.aws_iam_policy_document.eb_service_assume.json
}

resource "aws_iam_role_policy_attachment" "service_role_attachment" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}
# Attach Multicontainer Docker policy (optional, if you plan to use Docker)
resource "aws_iam_role_policy_attachment" "instance_role_docker" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}
resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.eb_instance_role.name
}

resource "aws_iam_role" "eb_instance_role" {
  name               = "${var.env_name}-${var.instance_profile_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "instance_role_attachment" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy_document" "eb_service_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet" "all_subnets" {
  for_each = toset(var.subnet_ids) // Ensure var.subnet_ids is passed as a list
  id       = each.value
}
resource "aws_s3_bucket" "eb_app_versions" {
  count  = var.s3_bucket == "" ? 1 : 0
  bucket = replace("${lower(var.app_name)}-app-version", "/[^a-z0-9-]/", "-") 
  acl    = "private"
  tags = merge(var.app_tags, {
    Name = "${var.app_name}-eb-app-versions"
  })
  force_destroy = true // Be careful with this in prod, enables easy deletion
}

locals {
  private_subnet_ids = [
    for subnet in data.aws_subnet.all_subnets :
    //  if enable_private_deployment is true, we want private subnets (map_public_ip_on_launch == false)
    // if enable_private_deployment is false, we want public subnets (map_public_ip_on_launch == true)
    subnet.id if var.enable_private_deployment ? subnet.map_public_ip_on_launch == false : subnet.map_public_ip_on_launch == true
  ]
  resolved_s3_key = var.local_file_path != "" ? "elastic-beanstalk-uploads/${filemd5(var.local_file_path)}-${basename(var.local_file_path)}" : var.s3_key

 resolved_s3_bucket = var.s3_bucket != "" ? var.s3_bucket : aws_s3_bucket.eb_app_versions[0].id
  
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "Managed by Terraform"
  tags        = var.app_tags
}
resource "aws_s3_bucket_object" "app_source_upload" {
  // Only create this S3 object if app_code_option is "upload" AND a local file path is provided
  count = var.app_code_option == "upload" && var.local_file_path != "" ? 1 : 0

  bucket = local.resolved_s3_bucket
  key    = local.resolved_s3_key
  source = var.local_file_path
  etag   = filemd5(var.local_file_path) # Good for detecting changes
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  // Only create an application version if app_code_option is "upload"
  count = var.app_code_option == "upload" ? 1 : 0

  name = var.app_version_label != "" ? var.app_version_label : "v-${formatdate("YYYYMMDDHHmmss", timestamp())}-${substr(filemd5(var.local_file_path), 0, 8)}"

  application = aws_elastic_beanstalk_application.app.name

  // Use the S3 bucket and key from the uploaded object or directly from variables
  bucket = local.resolved_s3_bucket
  key    = var.local_file_path != "" ? aws_s3_bucket_object.app_source_upload[0].key : var.s3_key

  // If we uploaded a local file, ensure the S3 upload completes first
  depends_on  = [
    aws_elastic_beanstalk_application.app,
    aws_s3_bucket_object.app_source_upload # This dependency is crucial for local file uploads
  ]
}
resource "aws_elastic_beanstalk_environment" "env" {
  name                = var.env_name
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  tier               = var.env_type

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }
  setting {
  namespace = "aws:elasticbeanstalk:environment"
  name      = "ServiceRole"
  value     = aws_iam_role.eb_service_role.name
  }


  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOMAIN_NAME"
    value     = var.domain_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_CODE_OPTION"
    value     = var.app_code_option
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "UPLOAD_SOURCE"
    value     = var.app_source_type
  }

  dynamic "setting" {
    for_each = var.vpc_id != "" ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = var.vpc_id
    }
  }
   dynamic "setting" {
    for_each = length(local.private_subnet_ids) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(",", local.private_subnet_ids)
    }
  }

 dynamic "setting" {
    for_each = var.enable_private_deployment ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "AssociatePublicIpAddress"
      value     = "false"
    }
  }


  dynamic "setting" {
    for_each = var.enable_auto_scaling ? [1] : []
    content {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value     = tostring(var.max_instance_count)
    }
  }

  dynamic "setting" {
    for_each = var.enable_auto_scaling ? [1] : []
    content {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value     = tostring(var.min_instance_count)
    }
  }

  depends_on = [aws_elastic_beanstalk_application.app]
}

