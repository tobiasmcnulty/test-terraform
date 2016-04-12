# RDS POSTGRES
resource "aws_db_instance" "rds" {
    lifecycle {
        prevent_destroy = true
    }
    engine = "postgres"

         allocated_storage = "${var.rds.storage}"
         engine_version = "${var.rds.postgres_version}"
         identifier = "${project_name}-rds"
         instance_class = "${var.rds.instance_type}"
         username = "${var.rds.master_username}"
         password = "${var.rds_master_password}"
}
output "rds_hostname" {
       value = "${aws_db_instance.rds.address}"
}
output "rds_master_user" {
       value = "${aws_db_instance.rds.username}"
}
