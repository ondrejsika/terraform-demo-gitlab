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
  name  = "gitlab"
  region = "fra1"
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
  domain = "sikademo.com"
  name   = "gitlab"
  value  = digitalocean_droplet.gitlab.ipv4_address
  type   = "A"
  proxied = false
}

resource "cloudflare_record" "registry" {
  domain = "sikademo.com"
  name   = "registry"
  value  = "gitlab.sikademo.com"
  type   = "CNAME"
  proxied = false
}

resource "cloudflare_record" "pages" {
  domain = "sikademo.com"
  name   = "pages"
  value  = "gitlab.sikademo.com"
  type   = "CNAME"
  proxied = false
}

resource "cloudflare_record" "pages_wildcard" {
  domain = "sikademo.com"
  name   = "*.pages"
  value  = "gitlab.sikademo.com"
  type   = "CNAME"
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
  domain = "sikademo.com"
  name   = "runner"
  value  = digitalocean_droplet.runner.ipv4_address
  type   = "A"
  proxied = false
}

resource "digitalocean_droplet" "web1" {
  image  = "docker-18-04"
  name   = "web1"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
}

resource "cloudflare_record" "web1" {
  domain = "sikademo.com"
  name   = "web1"
  value  = digitalocean_droplet.web1.ipv4_address
  type   = "A"
  proxied = false
}

resource "cloudflare_record" "web1_wildcard" {
  domain = "sikademo.com"
  name   = "*.web1"
  value  = "web1.sikademo.com"
  type   = "CNAME"
  proxied = false
}

resource "digitalocean_firewall" "web" {
  name = "web"

  droplet_ids = [digitalocean_droplet.web1.id]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "2376"
      source_addresses   = [digitalocean_droplet.runner.ipv4_address]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "80"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "8080"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "tcp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "udp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
}
