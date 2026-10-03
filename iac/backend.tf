   resource "docker_image" "node" {
     name         = "node:20-alpine"
     keep_locally = true
   }

   resource "docker_container" "api" {
     count   = var.backend_replicas[terraform.workspace]
     name    = "api-${terraform.workspace}-${count.index + 1}"
     image   = docker_image.node.image_id
     command = ["sleep", "infinity"]

     env = [
       "APP_ENV=${terraform.workspace}",
       "DB_HOST=${docker_container.db.name}",
       "DB_PORT=5432"
     ]

     ports {
       internal = 3000
       external = var.backend_port[terraform.workspace] + count.index * 10
     }

     networks_advanced {
       name = docker_network.red_frontend.name
     }

     networks_advanced {
       name = docker_network.red_backend.name
     }
   }

   output "api_containers" {
     value = docker_container.api[*].name
   }