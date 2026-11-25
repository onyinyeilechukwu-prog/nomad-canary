variable "image_tag" {
  type        = string
  description = "Image tag (commit SHA) to deploy"
}

job "demo" {
  type        = "service"

  group "web" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "15s"
      mode     = "fail"
    }

    update {
      max_parallel     = 1
      min_healthy_time = "10s"
      healthy_deadline = "2m"
      auto_revert      = true
      canary           = 1
      auto_promote     = true
    }

    service {
      name     = "demo"
      port     = "http"
      provider = "consul"

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "deploy" {
      driver = "docker"

      config {
        image = "ghcr.io/onyinyeilechukwu-prog/nomad-canary:${var.image_tag}"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
