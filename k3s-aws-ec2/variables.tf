variable "type" {
  type        = string
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
  sensitive   = true
}

variable "ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
  default     = "ami-03d3eec31be6ef6f9"
}

variable "root_block_device" {
  type        = string
  description = "Root block device for the EC2 instance"
  default     = "20"
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups for the EC2 instance"
  default     = ["default"]
}

variable "key_name" {
  type        = string
  description = "Key name for the EC2 instance"
  default     = "ec2-key"

}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"

}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}