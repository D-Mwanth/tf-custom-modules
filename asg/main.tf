# dynamically fetch AMI for ubuntu 20
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# create EC2 instance launch template
resource "aws_launch_template" "this" {
  name          = "${var.tier_name}-tpl"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(var.user_data)
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = [var.tier_instance_sg]
  tags = {
    Name = "${var.tier_name}-tpl"
  }
}

# create auto scaling group
resource "aws_autoscaling_group" "asg_name" {
  name                      = "${var.tier_name}-asg"
  max_size                  = var.max_size              # max number of instances that this autoscaling group can scale out to
  min_size                  = var.min_size              # minimum number of instance this autoscalig group must contain
  desired_capacity          = var.desired_cap           # the number of instance we want to start with
  health_check_grace_period = 300                       # time in seconds aws waits before checking the health of a newly created instance
  health_check_type         = var.asg_health_check_type #health check that aws performs, "ELB" or default EC2
  vpc_zone_identifier       = var.subnet_ids            # id of subnets where the instances are launched
  target_group_arns         = [var.lb_tg_arn]           # arn of tg to associate the Autoscaling Group

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  # launch template to use to launch instances in the asg
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  # Ensure instances have a name tag
  tag {
    key                 = "Name"
    value               = "${var.tier_name}-asg-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.this]
}

# scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.tier_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name # asg to which the policy is applied
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"             #increase instance by 1
  cooldown               = "300"           # time before allowing another scaling to occur after the provious one completes
  policy_type            = "SimpleScaling" # adjustment to the capacity is fixed as specified by the scaling_adjustment
}

# an alarm to trigger the scale up policy to scale capacity of asg based on the CPUUtilization, comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.tier_name}-asg-scale-up-alarm"
  alarm_description   = "$Alarm to Triger ${var.tier_name} AutoScaling policy to scale up ASG based on CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2" # trigger alarm if cpu utilization is more than 70% for two consecutive periods 
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"     # cloudwatch will evaluate the metric in every 120 seconds and compare it against threshold
  statistic           = "Average" # compute the average of cpu utilization in the ASG (Aggregate value for metric data points collected from the target ASG)
  threshold           = "70"      #Created new instance if CPU utilization is greater than or equal to 70%
  # cloudwatch will monitor the cpu utilization for instance in the autoscaling group
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true # action is enable meaning will will be executed when triggered
  # action to perform when alarm transition to `alarm` state
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.tier_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decrease instance by one when the policy is triggered
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down cloud watch alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.tier_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10" # Instance will scale down when CPU utilization is lower than or equals to 10 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn] # trigger the AS scaling down policy
}