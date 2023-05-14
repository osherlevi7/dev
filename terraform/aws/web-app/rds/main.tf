#set db subnet
resource "aws_db_subnet_group" "main" {
  name        = var.rds_name
  subnet_ids  = var.subnet_ids
}
#set security groups for the DB
resource "aws_security_group" "rds" {
  name_prefix = "rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#set DB instance 
resource "aws_db_instance" "main" {
  allocated_storage    = 10
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.rds_name
  username             = var.username
  password             = var.password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.vpc_security_group_ids
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}
