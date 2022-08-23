#provider "aws" {
#  # version = "~> 2.0"
#  region  = "us-east-1"
#}
#
#
##Definição Role e Policy
#resource "aws_iam_role" "lambda_role" {
#name   = "Spacelift_Test_Lambda_Function_Role"
#assume_role_policy = <<EOF
#{
# "Version": "2012-10-17",
# "Statement": [
#   {
#     "Action": "sts:AssumeRole",
#     "Principal": {
#       "Service": "lambda.amazonaws.com"
#     },
#     "Effect": "Allow",
#     "Sid": ""
#   }
# ]
#}
#EOF
#}
#
#resource "aws_iam_policy" "iam_policy_for_lambda" {
#
# name         = "aws_iam_policy_for_terraform_aws_lambda_role"
# path         = "/"
# description  = "AWS IAM Policy for managing aws lambda role"
# policy = <<EOF
#{
# "Version": "2012-10-17",
# "Statement": [
#   {
#     "Action": [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ],
#     "Resource": "arn:aws:logs:*:*:*",
#     "Effect": "Allow"
#   }
# ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
# role        = aws_iam_role.lambda_role.name
# policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
#}
#
#
#
#
##prepara jar
#data "template_file" "pom_template" {
#
#  template = file("./src/main/resources/templates/pom.tpl")
#
#  vars = {
#    artifact      = "TerraformLambdaDeploy"
#    version       = "0.0.1-SNAPSHOT"
#    description   = "TerraformLambdaDeploy"
#  }
#}
#
#resource "local_file" "pom_xml" {
#  content         = data.template_file.pom_template.rendered
#  filename        = "./pom.xml"
#}
#
#locals {
#
#  lambda_payload_filename = "./target/TerraformLambdaDeploy-0.0.1-SNAPSHOT.jar"
#}
#
#resource "null_resource" "build" {
#
#  provisioner "local-exec" {
#    command = "mvn package -f pom.xml"
#  }
#
#  depends_on = [
#    local_file.pom_xml
#  ]
#
#}
#
#
##Sobe Infra Lambda
#resource "aws_lambda_function" "terraform_lambda_func" {
#  filename      = "${path.module}/target/original-TerraformLambdaDeploy-0.0.1-SNAPSHOT.jar"
#  function_name = "Spacelift_Test_Lambda_Function"
#  role          = aws_iam_role.lambda_role.arn
#  handler       = "Handler.handleRequest"
#  runtime       = "java11"
#  source_code_hash          = "${base64sha256(filebase64(local.lambda_payload_filename))}"
#  timeout       = 25
#  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
#}
#
#
##Sobe Infra CloudWatch
#resource "aws_cloudwatch_event_rule" "every_one_minute" {
#  name = "Spacelift_Test_Lambda_Function"
#  description = "Fires every one minute"
#  schedule_expression = "rate(1 minute)"
#}
#
#resource "aws_cloudwatch_event_target" "check_terraform_lambda_func_every_five_minutes" {
#  rule = aws_cloudwatch_event_rule.every_one_minute.name
#  target_id = "check_foo"
#  arn = aws_lambda_function.terraform_lambda_func.arn
#}
#
#resource "aws_lambda_permission" "allow_cloudwatch_to_call_terraform_lambda_func" {
#  statement_id = "AllowExecutionFromCloudWatch"
#  action = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.terraform_lambda_func.function_name
#  principal = "events.amazonaws.com"
#  source_arn = aws_cloudwatch_event_rule.every_one_minute.arn
#}
#

provider "aws" {

  region = var.region

}

data "template_file" "pom_template" {

  template = file("./src/main/resources/templates/pom.tpl")

  vars = {
    artifact      = var.lambda_function_name
    version      = var.version1
    description   = "${var.lambda_function_name} Lambda Function"
  }
}

resource "local_file" "pom_xml" {
  content         = data.template_file.pom_template.rendered
  filename        = "./pom.xml"
}


resource "null_resource" "build" {

  provisioner "local-exec" {
    command = "mvn package -f ./pom.xml"
  }

  depends_on = [
    local_file.pom_xml
  ]

}

resource "aws_iam_role" "role_lambda_aws_cli" {
  name = "${var.lambda_function_name}-ROLE"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

#  tags = var.tags
}

locals {

  lambda_payload_filename = "./target/${var.lambda_function_name}-${var.version1}.jar"
}

resource "aws_lambda_function" "lambda_aws_cli" {

  filename                  = local.lambda_payload_filename

  function_name             = var.lambda_function_name
  role                      = aws_iam_role.role_lambda_aws_cli.arn
  handler                   = var.lambda_handler
  runtime                   = var.lambda_runtime
  memory_size               = var.lambda_memory

  source_code_hash          = "${base64sha256(filebase64(local.lambda_payload_filename))}"

#  environment {
#    variables   =  var.lambda_environment
#  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.aws_cli_log_group,
    null_resource.build
  ]

#  tags = var.tags
}

resource "aws_cloudwatch_log_group" "aws_cli_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

#  tags = var.tags

}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF

#  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.role_lambda_aws_cli.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_cloudwatch_event_rule" "every_days" {
  name = "once-a-minute"
  description = "Once a minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "schedule" {
  rule = "${aws_cloudwatch_event_rule.every_days.name}"
  target_id = aws_lambda_function.lambda_aws_cli.id
  arn = "${aws_lambda_function.lambda_aws_cli.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_aws_cli.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.every_days.arn}"
}

variable lambda_function_name {
  description     = "TerraformLambdaDeploy"
  default = "TerraformLambdaDeploy"
  type            = string
}

variable lambda_memory {
  description     = "1024"
  default = 1024
  type            = number
}

variable lambda_runtime {
  description     = "java11"
  default = "java11"
  type            = string
}

variable lambda_handler {
  description     = "Handler.handleRequest"
  default =  "Handler.handleRequest"
  type            = string
}

#variable lambda_environment {
#  description     = "environment variables"
#  type            = map(any)
#}

#variable tags {
#  description     = "Tag list"
#  type            = map(any)
#}

variable region {
  description     = "us-east-1"
  default = "us-east-1"
  type            = string
}

variable version1 {
  description     = "0.0.1"
  type            = string
}



