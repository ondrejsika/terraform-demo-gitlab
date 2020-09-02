terraform {
  required_providers {
    cloudflare = {
      source = "terraform-providers/cloudflare"
      version = "1.18"
    }
    digitalocean = {
      source = "terraform-providers/digitalocean"
    }
  }
  required_version = ">= 0.13"
}
