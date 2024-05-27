variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region in which the infrastructure will be provisioned"
}
variable "VPC_Name" {
  type        = string
  description = "The AWS VPC name"
  default     = "app-vpc"
}

variable "VPC_CIDR_Block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC cidr block"
}

variable "Public_Subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Public subnet block"
}

variable "Availability_Zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "The availability zone where the infrastructure will be deployed"
}

variable "Internet_Gateway_Name" {
  type        = string
  default     = "Internet_Gateway"
  description = "The name given to the internet gateway"
}

variable "db_subnet_group_name" {
  type        = string
  default     = "db-subnet-group"
  description = "Name for the rds subnet group"
}

variable "db_engine" {
  type        = string
  default     = "postgres"
  description = "The kind of rds sql engine to be used"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "The db instance class to be used"
}

variable "db_user_name" {
  type        = string
  default     = "dbuser"
  description = "RDS database user name"
}

variable "db_engine_version" {
  type        = string
  default     = "16.2"
  description = "The db_engine version used"
}

variable "rds_identifier" {
  type        = string
  default     = "rds-labmda"
  description = "RDS instance identifier"
}
variable "db_name" {
  type        = string
  default     = "rdslambda"
  description = "The RDS db name"
}

variable "db_backup_windows" {
  type        = string
  default     = "00:00-01:00"
  description = "The time windows in which backups will be taken"
}

variable "db_maintenance_windows" {
  type        = string
  default     = "Mon:02:00-Mon:03:00"
  description = "The time windows in which maintenance is allowed"
}

variable "snapshot_identifier" {
  type        = string
  default     = "Last-Snapshot"
  description = "The name of the last db snapshot taken before deletion"
}

variable "KMS_Key_Name" {
  type        = string
  default     = "RDS-Lambda-KMS-Key"
  description = "The name of the KMS key used to encrypt the RDS instance"
}

variable "db_replica_maintenance_windows" {
  type        = string
  default     = "Mon:01:30-Mon:02:00"
  description = "The maintenance window for the RDS replica"
}

variable "rds_proxy_name" {
  type        = string
  default     = "rds-lambda-proxy"
  description = "The name of the rds proxy resource"
}

variable "input_api_path" {
  type        = string
  default     = "inputs"
  description = "API path for input to rds lambda"
}

variable "Input_Lambda_Stage_Name" {
  type        = string
  default     = "input"
  description = "The input lambda function apiGW stage name"
}

variable "get_api_path" {
  type        = string
  default     = "retrieve"
  description = "Retrieve all the values stored in the db"
}

variable "Get_stage_name" {
  type        = string
  default     = "get"
  description = "The get lambda function apiGW stage name"
}