   resource "docker_image" "nginx" {
     name         = "nginx:alpine"
     keep_locally = true
   }

   resource "docker_container" "web" {
     count = var.frontend_replicas[terraform.workspace]
     name  = "web-${terraform.workspace}-${count.index + 1}"
     image = docker_image.nginx.image_id

     ports {
       internal = 80
       external = var.frontend_port[terraform.workspace] + count.index * 10
     }

     networks_advanced {
       name = docker_network.red_frontend.name
     }
   }

   output "web_containers" {
     value = docker_container.web[*].name
   }