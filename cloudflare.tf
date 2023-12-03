resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = "itsvc-cloudflared-tunnel-01"
  secret     = random_id.tunnel_secret.b64_std
  config_src = "cloudflare"
}

resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:latest"
}

resource "docker_container" "ubuntu" {
  name  = "itsvc-cloudflared-tunnel-01"
  image = docker_image.cloudflared.image_id
  restart = "always"
  command = [
    "tunnel", "--no-autoupdate", "run", "--token", cloudflare_tunnel.tunnel.tunnel_token
  ]   
}

