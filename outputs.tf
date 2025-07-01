output "application_name" {
  value       = module.beanstalk.application_name
  description = "Name of the Elastic Beanstalk application"
}
output "environment_name" {
  value       = module.beanstalk.environment_name
  description = "Name of the Elastic Beanstalk environment"
}
output "environment_url" {
  value       = module.beanstalk.environment_url
  description = "URL of the Elastic Beanstalk environment"
}
