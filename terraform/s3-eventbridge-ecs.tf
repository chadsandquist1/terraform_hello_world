locals {
  bucket_name     = vars.bucket_name
  event_bus_name  = "default"
  container_image = vars.container_image
  ecs_subnet_id   = vars.subnet
  region          = vars.aws_region

}

### S3 Resource Configuration ###
resource "aws_s3_bucket" "bucket" {
  bucket      = local.bucket_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true
}

resource "aws_s3_bucket_public_access_block" "bucket_bpa" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### Choreography Reporting Rule ###
resource "aws_cloudwatch_event_rule" "sandbox-s3-notification-rule" {
  name           = "sandbox-s3-notification-rule"
  description    = "Capture s3 events"
  event_bus_name = local.event_bus_name

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["${local.bucket_name}"]
    },
    "object": {
      "key": [{
        "prefix": "incoming.txt"
      }]
    }
  }
}
EOF
}

### Eventbridge Event Target ###
resource "aws_cloudwatch_event_target" "sandbox-s3-event-ecs-event-target" {
  target_id      = "sandbox-s3-event-ecs-event-target"
  rule           = aws_cloudwatch_event_rule.sandbox-s3-notification-rule.name
  arn            = aws_ecs_cluster.sandbox-ecs-test-cluster.id
  role_arn       = aws_iam_role.sandbox-eventbridge-invoke-ecs-role.arn
  event_bus_name = local.event_bus_name

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.sandbox-ecs-task-definition.arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = [ local.ecs_subnet_id ]
      assign_public_ip = true
   }
  }

  input_transformer {
    input_paths = {
      bucket_name        = "$.detail.bucket.name",
      object_key         = "$.detail.object.key",
      source-ip-address  = "$.detail.source-ip-address"
    }
    input_template = <<EOF
{
  "containerOverrides": [
    {
      "name": "sandbox-dump-env-vars",
      "environment" : [
        {
          "name" : "BUCKET_NAME",
          "value" : <bucket_name>
        },
        {
          "name" : "OBJECT_KEY",
          "value" : <object_key>
        },
        {
          "name" : "SOURCE_IP",
          "value" : <source-ip-address>
        }
      ]
    }
  ]
}
EOF
  }
}

### ECS Cluster ###
resource "aws_ecs_cluster" "sandbox-ecs-test-cluster" {
  name = "sandbox-ecs-test-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

### ECS Task Definition ###
resource "aws_ecs_task_definition" "sandbox-ecs-task-definition" {
  family                   = "sandbox-ecs-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.sandbox-ecs-task-role.arn
  execution_role_arn       = aws_iam_role.sandbox-ecs-task-execution-role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "sandbox-dump-env-vars",
    "image": "${local.container_image}",
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.sandbox-cw-log-grp-dump-env-vars.name}",
            "awslogs-region": "${local.aws_region}",
            "awslogs-stream-prefix": "ecs"
          }
    }
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

### CloudWatch Log Group ###
resource "aws_cloudwatch_log_group" "sandbox-cw-log-grp-dump-env-vars" {
  name = "/ecs/sandbox-dump-env-vars"
}

### ECS Task Execution Role ###
resource "aws_iam_role" "sandbox-ecs-task-execution-role" {
  name = "sandbox-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach AdministratorAccess policy
resource "aws_iam_role_policy_attachment" "ecs_task_pol_attach" {
  role       = aws_iam_role.sandbox-ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### Create a policy to access S3 buckets ###
resource "aws_iam_policy" "ecs_s3_access_policy"{
  name = "sandbox_ecs_s3_access_policy"
  policy = jsonencode({

    Version: "2012-10-17",
    Statement: [
      {
        Sid: "",
        Action: [
        "s3:GetObject",
        "s3:ListBucket"
        ],
        Effect: "Allow",
        Resource: [
             "arn:aws:s3:::${local.bucket_name}",
            "arn:aws:s3:::${local.bucket_name}/*"
        ]
      }
    ]
  })
}

### ECS Task Role ###
resource "aws_iam_role" "sandbox-ecs-task-role" {
  name                = "sandbox-ecs-task-role"
  managed_policy_arns = [
          "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
           aws_iam_policy.ecs_s3_access_policy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

### ECS Eventbridge Invocation Role ###
resource "aws_iam_role" "sandbox-eventbridge-invoke-ecs-role" {
  name                = "sandbox-eventbridge-invoke-ecs-role"
  managed_policy_arns = [aws_iam_policy.sandbox-eventbridge-invoke-ecs-policy.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "sandbox-eventbridge-invoke-ecs-policy" {
  name = "sandbox-eventbridge-invoke-ecs-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:RunTask"
            ],
            "Resource": [
                "${aws_ecs_task_definition.sandbox-ecs-task-definition.arn}:*",
                "${aws_ecs_task_definition.sandbox-ecs-task-definition.arn}"
            ],
            "Condition": {
                "ArnLike": {
                    "ecs:cluster": "${aws_ecs_cluster.sandbox-ecs-test-cluster.arn}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "ecs-tasks.amazonaws.com"
                }
            }
        }
    ]
})
}

