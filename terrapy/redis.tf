resource "aws_elasticache_subnet_group" "cache_group" {
    name = "${var.app_name}-${var.env_name}-sn-grp"
    description = "${var.app_name}-${var.env_name} subnet group for redis"
    subnet_ids = ["${aws_subnet.subnet_0.id}", "${aws_subnet.subnet_1.id}"]
}

resource "aws_elasticache_cluster" "redis" {
    cluster_id = "${format("%.7s-%.7s", var.app_name, var.env_name)}-redis"
    engine = "redis"
    node_type = "${var.redis_node_type}"
    port = 6379
    num_cache_nodes = 1  # Must be 1 for redis, but still required

    subnet_group_name = "${aws_elasticache_subnet_group.cache_group.name}"

    lifecycle {
      #  prevent_destroy = true
    }

    tags {
        Name = "${var.app_name}-${var.env_name}-redis"
        role = "redis"
    }
}
