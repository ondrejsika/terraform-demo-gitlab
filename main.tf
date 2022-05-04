data "digitalocean_droplet_snapshot" "gitlab" {
  name_regex  = "^gitlab-.*"
  region      = "fra1"
  most_recent = true
}

data "digitalocean_ssh_key" "ondrejsika" {
  name = "ondrejsika"
}

resource "digitalocean_droplet" "gitlab" {
  image  = data.digitalocean_droplet_snapshot.gitlab.id
  name   = "gitlab"
  region = "fra1"
  size   = "s-8vcpu-16gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id,
  ]
}

resource "cloudflare_record" "gitlab" {
  zone_id = var.cloudflare_zone_id
  name    = "gitlab"
  value   = digitalocean_droplet.gitlab.ipv4_address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "registry" {
  zone_id = var.cloudflare_zone_id
  name    = "registry"
  value   = "gitlab.sikademo.com"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "pages" {
  zone_id = var.cloudflare_zone_id
  name    = "pages"
  value   = "gitlab.sikademo.com"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "pages_wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.pages"
  value   = "gitlab.sikademo.com"
  type    = "CNAME"
  proxied = false
}

resource "digitalocean_droplet" "runner" {
  image  = "docker-18-04"
  name   = "runner"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
}

resource "cloudflare_record" "runner" {
  zone_id = var.cloudflare_zone_id
  name    = "runner"
  value   = digitalocean_droplet.runner.ipv4_address
  type    = "A"
  proxied = false
}

output "gitlab_ip" {
  value = digitalocean_droplet.gitlab.ipv4_address
}
output "runner_ip" {
  value = digitalocean_droplet.runner.ipv4_address
}
output "gitlab_domain" {
  value = cloudflare_record.gitlab.hostname
}
output "runner_domain" {
  value = cloudflare_record.runner.hostname
}
