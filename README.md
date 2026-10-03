# Laboratorio de aprovisionamiento

Este laboratorio enfocado en utilizar Terraform con buenas prácticas para aprovisionar, con Docker, un frontend (nginx), un backend (node) y una base de datos (PostgreSQL) en los ambientes `dev` y `qa`. Los contenedores se despliegan a partir de las imágenes oficiales de Docker Hub.

## Arquitectura

### Contenedores y puertos

| Ambiente | Componente | Contenedor | Puertos (externo:interno) |
|---|---|---|---|
| dev | Frontend (nginx) | `web-dev-1` | `4001:80` |
| dev | Backend (node) | `api-dev-1` | `4002:3000` |
| dev | Base de datos (postgres) | `bd-dev` | `4003:5432` |
| qa | Frontend (nginx) | `web-qa-1` / `web-qa-2` | `5001:80` / `5011:80` |
| qa | Backend (node) | `api-qa-1` / `api-qa-2` | `5002:3000` / `5012:3000` |
| qa | Base de datos (postgres) | `bd-qa` | `5003:5432` |

Cada réplica adicional suma 10 al puerto externo, porque en local no pueden compartir puerto.

### Redes

| Contenedor | `red-frontend-<ambiente>` | `red-backend-<ambiente>` |
|---|---|---|
| Frontend (web) | Sí | No |
| Backend (api) | Sí | Sí |
| Base de datos (bd) | No | Sí |

El frontend se comunica con el backend, y el backend con la base de datos. El frontend nunca se comunica con la base de datos, porque no comparten ninguna red.

## Requisitos

- Docker Desktop (abierto antes de ejecutar Terraform)
- Terraform
- Git

Imágenes utilizadas (se descargan automáticamente al hacer `terraform apply`, pero puedes descargarlas antes):

```powershell
docker pull nginx:alpine
docker pull node:20-alpine
docker pull postgres:16-alpine
```

## Despliegue paso a paso

Se trabaja **solo con los workspaces `dev` y `qa`**, no con `default`.

```powershell
git clone <url-del-repositorio>
cd <carpeta-del-repositorio>
cd iac
terraform init
```

Ambiente dev:

```powershell
terraform workspace new dev
terraform plan
terraform apply
```

Ambiente qa:

```powershell
terraform workspace new qa
terraform plan
terraform apply
```

Para cambiar entre ambientes ya creados:

```powershell
terraform workspace list
terraform workspace select dev
```

## Verificación

```powershell
docker ps --format "table {{.Names}}\t{{.Ports}}"
docker network ls --filter name=red-

docker exec bd-dev pg_isready
docker exec bd-qa pg_isready

docker network inspect red-frontend-dev
docker network inspect red-backend-dev

docker exec web-dev-1 wget -qO- -T 3 http://bd-dev:5432

docker exec web-qa-1 wget -qO- -T 3 http://api-dev-1:3000
```

En el navegador: http://localhost:4001 (dev), http://localhost:5001 y http://localhost:5011 (qa). Cada una debe mostrar la página de bienvenida por defecto de nginx, confirmando que el contenedor y el puerto están aprovisionados correctamente.

