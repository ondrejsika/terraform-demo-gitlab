variable "do_token" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_kubernetes_cluster" "foo" {
  name    = "foo"
  region  = "nyc1"
  version = "1.14.2-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

output "kubeconfig" {
  value = "${digitalocean_kubernetes_cluster.foo.kube_config.0.raw_config}"
}
