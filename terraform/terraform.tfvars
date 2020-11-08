cloud_watch_rule_name        = "ec2_state_changed_to_lambda"
cloud_watch_rule_description = "sends ec2 state changed events to lambda"

// ec2

es_domain_name   = "es4ec2"
es_instance_type = "t3.small.elasticsearch"

lambda_name                       = "ec2_state_change_to_es"
lambda_iam_role_name              = "iam_es4ec2_for_lambda"
lambda_execution_role_name        = "execution_role_for_es4ec2_lambda"
lambda_execution_role_description = "allows lambda to send cloudwatch logs and describe network interfaces"

ec2_instance_policy_name        = "ec2_access_to_kibana_and_es"
ec2_instance_policy_description = "allows ec2 instances to access, view and edit data in kibana and es"
ec2_instance_role_name          = "ec2_access_to_kibana_and_es"
