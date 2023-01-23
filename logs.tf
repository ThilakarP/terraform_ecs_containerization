resource "aws_cloudwatch_log_group" "ecscloudwatchlogs" {
  name              = "ecscloudwatchlogs"
  retention_in_days = 7

}
