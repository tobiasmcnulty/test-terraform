resource "aws_elasticache_cluster" "redis" {
    cluster_id = "${project_name}-redis"
    engine = "redis"
    node_type = "${redis_node_type}"
    port = 11211
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


