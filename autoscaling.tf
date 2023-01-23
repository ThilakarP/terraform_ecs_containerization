resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster1.name}/${aws_ecs_service.ecs_service1.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_scheduled_action" "ecs_scaleout" {
  name               = "ecs-scaleout"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(00 23 * * ? *)"

  scalable_target_action {
    min_capacity = 2
    max_capacity = 2
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_scalein" {
  name               = "ecs-scalein"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(15 23 * * ? *)"

  scalable_target_action {
    min_capacity = 1
    max_capacity = 1
  }
}
