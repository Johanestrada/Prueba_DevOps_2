Prueba DevOps 2 - E-Commerce Deployment

Proyecto integral de desplegabilidad en AWS con microservicios Spring Boot, frontend React y orquestación con EKS (Kubernetes), ECR y Terraform.



 



## Componentes

### Backend Microservicios
- **Ventas API** (`back-Ventas_SpringBoot/`): Gestión de ventas y compras
- **Despachos API** (`back-Despachos_SpringBoot/`): Gestión de envíos
- Ambos en Spring Boot 3.4.4 con JPA y MySQL 8

### Frontend
- **React + Vite** (`front_despacho/`)
- Tailwind CSS
- Nginx como proxy inverso

### Base de Datos
- **MySQL 8** en instancia EC2 dentro de la VPC
- Acceso desde EKS usando `SPRING_DATASOURCE_URL` y secret Kubernetes


### Infraestructura (Terraform)
- VPC
- Subnets públicas y privadas
- EKS Cluster (Kubernetes)
- ECR
- NAT Gateway
- VPC Endpoints
- Security Groups

### Orquestación (Kubernetes)
- Deployments para Microservicios y Frontend
- Services (ClusterIP/LoadBalancer)
- ConfigMaps para variables de entorno

---

## Arquitectura del Proyecto

A continuación se muestra el diagrama de la arquitectura desplegada en AWS, incluyendo el flujo desde los repositorios, la construcción y almacenamiento de imágenes en ECR, y el despliegue en EKS/Kubernetes:

![Diagrama Arquitectura AWS EKS](infra/AWS_Diagrama.png)

---

# Despliegue Rápido

## Prerequisitos

- AWS CLI configurado
- Terraform >= 1.0
- Docker Desktop
- Node.js 20+

---

## 1. Clonar Repositorio

```bash
git clone <repo-url>
cd Prueba_DevOps_2
```

---

## 2. Configurar AWS CLI

```bash
aws configure
```

Ingresar:
- Access Key
- Secret Key
- Region: `us-east-1`
- Output format: `json`

---

## 3. Desplegar Infraestructura

```bash
cd infra/terraform

terraform plan

TF_VAR_mysql_root_password="<your_mysql_password>" terraform apply -auto-approve
```

---

## 4. Obtener DNS del Frontend

```bash
aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --query 'LoadBalancers[?Type==`application` && contains(DNSName, `frontend`) == `true`].DNSName' \
  --output text
```

## 5. Obtener IP de MySQL

```bash
cd infra/terraform
terraform output -raw mysql_private_ip
```

---

# CI/CD Pipeline

## Flujo

```text
develop/main
      ↓
GitHub Actions
      ↓
Build & Test
      ↓
Docker Build
      ↓
Push ECR
      ↓
Terraform Apply
      ↓
EKS Deploy
```

> Nota: El workflow activo para despliegue es `.github/workflows/cd.yml` (EKS). El archivo `.github/workflows/cd.deploy.yml` se conserva solo como referencia.

---

## Secrets GitHub

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
SPRING_DATASOURCE_URL
SPRING_DATASOURCE_USERNAME
SPRING_DATASOURCE_PASSWORD
MYSQL_ROOT_PASSWORD
MYSQL_DATABASE
```

---

# Variables Terraform

Archivo:

```text
infra/terraform/terraform.tfvars
```

Contenido:

```hcl
aws_region    = "us-east-1"
project_name  = "inventario-devops"
key_pair_name = ""
```

Para no subir secretos al repositorio, copie el archivo de ejemplo:

```bash
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
```

> Nota: `mysql_root_password` no debe quedar en el repositorio. Use `TF_VAR_mysql_root_password` o un archivo `terraform.tfvars` local que no se suba.

---

# Acceso a Servicios

| Servicio | Acceso |
|----------|---------|
| Frontend | ALB DNS |
| Ventas API | http://ALB:8080/swagger-ui |
| Despachos API | http://ALB:8080/swagger-ui |
| MySQL | EC2-IP:3306 |

---

# Docker Build Manual

## Login ECR

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
```

---

## Backend Ventas

```bash
cd back-Ventas_SpringBoot/Springboot-API-REST

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO=${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/inventario-devops-ventas-back

docker build -t ${REPO}:latest .
docker push ${REPO}:latest
```

---

## Backend Despachos

```bash
cd back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO=${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/inventario-devops-despachos-back

docker build -t ${REPO}:latest .
docker push ${REPO}:latest
```

---

## Frontend

```bash
cd front_despacho

npm install
npm run build

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO=${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/inventario-devops-frontend

docker build -t ${REPO}:latest .
docker push ${REPO}:latest
```

---

# Nota sobre ECS

Este repositorio usa EKS en producción. El archivo `.github/workflows/cd.deploy.yml` se conserva solo como referencia histórica y no está activo.

---

## Ver imágenes ECR

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr list-images \
  --repository-name inventario-devops-ventas-back \
  --region us-east-1
```

---

# Estructura del Proyecto

```text
Prueba_DevOps_2/
├── .github/
│   └── workflows/
│       ├── ci.backend.yml
│       └── cd.deploy.yml
├── infra/
│   └── k8s/
├── back-Ventas_SpringBoot/
├── back-Despachos_SpringBoot/
├── front_despacho/
├── docker-compose.yml
└── README.md
```

---
