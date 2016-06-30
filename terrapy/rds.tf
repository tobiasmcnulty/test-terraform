# RDS POSTGRES
resource "aws_db_subnet_group" "db_group" {
    name = "${var.app_name}-${var.env_name}-sn-grp"
    description = "${var.app_name}-${var.env_name} DB subnet group"
    subnet_ids = ["${aws_subnet.subnet_0.id}", "${aws_subnet.subnet_1.id}"]
}

resource "aws_db_instance" "rds" {
    lifecycle {
       # prevent_destroy = true
    }
    engine = "postgres"

    allocated_storage = "${var.rds.storage}"
    engine_version = "${var.rds.postgres_version}"
    identifier = "${var.app_name}-${var.env_name}-rds"
    instance_class = "${var.rds.instance_type}"
    username = "${var.rds.master_username}"
    password = "${var.rds_master_password}"
    db_subnet_group_name = "${aws_db_subnet_group.db_group.name}"
    vpc_security_group_ids = ["${aws_security_group.sg_db.id}"]
}
