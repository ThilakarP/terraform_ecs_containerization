# terraform_ecs_containerization

Hosting a web application on private subnet - ECS container using FARGATE, Application Load Balancer, Docker images.  Also, Scheduled AutoScaling of Container Service +1 (scale out - scale in) for 15 minutes.

1)  Build AWS resources using Terraform, backend as S3,  Github as code repository
2)  VPC and Networking (Subnets, Gateways, Route tables, Security groups, Load Balancer)
3)  Docker image form Elastic Container Registry
4)  Elastic Container Service
5)  Application Load Balancer
6)  Auto Scaling
7)  ECS logs configured to cloudwatch
8)  Application Load Balancer logs stored in S3 bucket.
