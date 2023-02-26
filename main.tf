locals {
  runner_vm_count = 1
}

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
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf1234
chpasswd:
  expire: false
runcmd:
  - |
    rm -rf /etc/update-motd.d/99-one-click
    apt-get update
    apt-get install -y curl sudo git mc htop vim tree
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
EOF
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
  count = local.runner_vm_count

  image  = "docker-18-04"
  name   = "runner${count.index}"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf1234
chpasswd:
  expire: false
write_files:
- path: /root/setup-gitlab-runner.sh
  permissions: "0755"
  owner: root:root
  content: |
    #!/bin/sh
    slu login --url https://vault-slu.sikalabs.io --user gitlab-ci-sikademo --password gitlab-ci-sikademo
    slu gitlab-ci setup-runner --gitlab sikademo
runcmd:
  - |
    rm -rf /etc/update-motd.d/99-one-click
    apt-get update
    apt-get install -y curl sudo git mc htop vim tree
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
EOF
}

resource "cloudflare_record" "runner" {
  count = local.runner_vm_count

  zone_id = var.cloudflare_zone_id
  name    = "runner${count.index}"
  value   = digitalocean_droplet.runner[count.index].ipv4_address
  type    = "A"
  proxied = false
}

output "gitlab_ip" {
  value = digitalocean_droplet.gitlab.ipv4_address
}
output "runner_ips" {
  value = digitalocean_droplet.runner[*].ipv4_address
}
output "gitlab_domain" {
  value = cloudflare_record.gitlab.hostname
}
output "runner_domains" {
  value = cloudflare_record.runner[*].hostname
}
