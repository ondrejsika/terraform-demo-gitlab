variable "do_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  email = var.cloudflare_email
  token = var.cloudflare_token
}

data "digitalocean_droplet_snapshot" "gitlab" {
  name        = "gitlab"
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
  size   = "s-4vcpu-8gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time provisioner'"
  }
}

resource "cloudflare_record" "gitlab" {
  domain  = "sikademo.com"
  name    = "gitlab"
  value   = digitalocean_droplet.gitlab.ipv4_address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "registry" {
  domain  = "sikademo.com"
  name    = "registry"
  value   = "gitlab.sikademo.com"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "pages" {
  domain  = "sikademo.com"
  name    = "pages"
  value   = "gitlab.sikademo.com"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "pages_wildcard" {
  domain  = "sikademo.com"
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
  domain  = "sikademo.com"
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
