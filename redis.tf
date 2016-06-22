resource "aws_elasticache_cluster" "redis" {
    cluster_id = "${format("%.14s", var.project_name)}-redis"
    engine = "redis"
    node_type = "${var.redis_node_type}"
    port = 6379
    num_cache_nodes = 1  # Must be 1 for redis, but still required

    lifecycle {
        prevent_destroy = true
    }

    tags {
        name = "Pycon Rapidpro Redis"
        environment = "${var.environment}"
        deployment = "${var.deployment}"
        role = "redis"
    }
}


