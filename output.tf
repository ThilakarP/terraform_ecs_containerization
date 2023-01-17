output "application_lb_dns_name" {
  description = "Application website will run here"
  value       = aws_lb.ecs_application_lb.dns_name
}