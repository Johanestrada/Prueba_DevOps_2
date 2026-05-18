# Prueba DevOps 2 - E-Commerce Deployment

Proyecto integral de desplegabilidad en AWS con microservicios Spring Boot, frontend React y orquestación con ECS, ECR y Terraform.

---

## 📋 Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS CLOUD                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               VPC (10.0.0.0/16)                         │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │                                                          │   │
│  │  ┌──────────────────┐         ┌──────────────────┐     │   │
│  │  │  Public Subnet   │         │ Private Subnet   │     │   │
│  │  │  (10.0.1.0/24)   │         │ (10.0.2.0/24)    │     │   │
│  │  │                  │         │                  │     │   │
│  │  │  ┌────────────┐  │         │ ┌──────────────┐│     │   │
│  │  │  │  Frontend  │  │         │ │ ECS Tasks    ││     │   │
│  │  │  │ (ECS ALB)  │  │         │ │ - Ventas     ││     │   │
│  │  │  └────────────┘  │         │ │ - Despachos  ││     │   │
│  │  │                  │         │ │ - MySQL      ││     │   │
│  │  │  ┌────────────┐  │         │ └──────────────┘│     │   │
│  │  │  │  MySQL EC2 │  │         │                  │     │   │
│  │  │  └────────────┘  │         │  VPC Endpoints:  │     │   │
│  │  │                  │         │  - ECR API       │     │   │
│  │  │    NAT Gateway   │         │  - ECR DKR       │     │   │
│  │  │    EIP           │         │  - CloudWatch    │     │   │
│  │  └──────────────────┘         │  - STS           │     │   │
│  │                                │                  │     │   │
│  │                                └──────────────────┘     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Registro de Contenedores (ECR)            │   │
│  │  - prueba_devops_2-frontend:latest                     │   │
│  │  - prueba_devops_2-ventas-back:latest                  │   │
│  │  - prueba_devops_2-despachos-back:latest               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           CloudWatch Logs & Monitoring                 │   │
│  │  - Log Group: /ecs/prueba_devops_2                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions (CI/CD)                       │
├─────────────────────────────────────────────────────────────────┤
│  [Push develop]  →  [CI: Test]  →  [CD: Build & Deploy]        │
│  - Build JARs        - Maven test    - Docker build            │
│  - Build React       - MySQL tests   - ECR push                │
│                                      - Terraform apply         │
│                                      - ECS update              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🏗 Componentes

### Backend Microservicios
- **Ventas API** (`back-Ventas_SpringBoot/`): Gesión de ventas y compras
- **Despachos API** (`back-Despachos_SpringBoot/`): Gestión de envíos
- Ambos en Spring Boot 3.4.4 con JPA, MySQL 8

### Frontend
- **React + Vite** (`front_despacho/`): UI con Tailwind CSS
- Nginx como proxy inverso

### Base de Datos
- **MySQL 8** en EC2 pública (10.0.2.166)
- Dentro de VPC con acceso restringido desde ECS

### Infraestructura (Terraform)
- **VPC**, subnets públicas/privadas
- **ECS Cluster** + servicios ECR
- **NAT Gateway** para tráfico de egreso
- **VPC Endpoints**: ECR API, ECR DKR, CloudWatch Logs, STS
- **Security Groups** para aislamiento

---

## 🚀 Despliegue Rápido

### Prerequisitos
- AWS CLI configurado
- Terraform >= 1.0
- Docker Desktop
- Node.js 20+ (opcional, si builds local)

### 1️⃣ Clonar Repositorio
```bash
git clone <repo-url>
cd Prueba_DevOps_2
```

### 2️⃣ Configurar Credenciales AWS
```bash
aws configure
# Ingresa: Access Key, Secret Key, Region (us-east-1), Format (json)
```

### 3️⃣ Desplegar Infraestructura
```bash
cd infra

# Revisar cambios
terraform plan

# Aplicar cambios
terraform apply -auto-approve
```

### 4️⃣ Obtener IP Pública (después deployment)
```bash
# Frontend (ALB)
aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --query 'LoadBalancers[?LoadBalancerName==`prueba_devops_2-frontend-alb`].DNSName' \
  --output text

# MySQL (EC2 pública)
terraform state show aws_instance.mysql | grep public_ip
```

---

## 📦 CI/CD Pipeline

### Flujo: `develop` → `main` → Deploy AWS

**Trigger**: Push a `develop` o `main`

**Pasos**:
1. ✅ **Checkout** - Descargar código
2. ✅ **Build & Test**
   - Maven compile + test (Ventas, Despachos)
   - npm build (Frontend)
3. ✅ **Docker Build & Push** → ECR
4. ✅ **Terraform Apply** - Actualizar infraestructura
5. ✅ **ECS Update** - Desplegar nuevas imágenes
6. ✅ **Output** - Mostrar IP pública accesible

### Secrets Requeridos (GitHub)
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION=us-east-1
ECR_REGISTRY=348374603543.dkr.ecr.us-east-1.amazonaws.com
MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=ecommerce
```

---

## 🔑 Variables Terraform

Editar `infra/terraform.tfvars`:
```hcl
aws_region       = "us-east-1"
project_name     = "prueba_devops_2"
key_pair_name    = "prueba_2"
```

---

## 🌐 Acceso a Servicios

| Servicio | Acceso | Nota |
|----------|--------|------|
| **Frontend** | HTTP ALB DNS | Vía ECS public IP |
| **Ventas API** | `http://<ALB>:8080/swagger-ui` | OpenAPI docs |
| **Despachos API** | `http://<ALB>:8080/swagger-ui` | OpenAPI docs |
| **MySQL** | `<EC2-PublicIP>:3306` | Credenciales en Secrets |

---

## 🛠 Comandos Locales Útiles

### Construir y Subir Imágenes Manualmente
```bash
# Autenticarse en ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 348374603543.dkr.ecr.us-east-1.amazonaws.com

# Backend Ventas
cd back-Ventas_SpringBoot/Springboot-API-REST
docker build -t 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-ventas-back:latest .
docker push 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-ventas-back:latest

# Backend Despachos
cd ../../back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO
docker build -t 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-despachos-back:latest .
docker push 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-despachos-back:latest

# Frontend
cd ../../front_despacho
npm install
npm run build
docker build -t 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-frontend:latest .
docker push 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-frontend:latest
```

### Forzar Redeploy ECS
```bash
$cluster = "arn:aws:ecs:us-east-1:348374603543:cluster/prueba_devops_2-ecs-cluster"

aws ecs update-service --cluster $cluster \
  --service ventas-back-service \
  --force-new-deployment --region us-east-1

aws ecs update-service --cluster $cluster \
  --service despachos-back-service \
  --force-new-deployment --region us-east-1

aws ecs update-service --cluster $cluster \
  --service frontend-service \
  --force-new-deployment --region us-east-1
```

### Ver Logs en CloudWatch
```bash
# Tail en tiempo real (última hora)
aws logs tail /ecs/prueba_devops_2 --since 1h --follow
```

---

## 📊 Monitoreo

### CloudWatch
- **Log Group**: `/ecs/prueba_devops_2`
- **Métricas**: CPU, memoria, tráfico de red por servicio

### ECS Console
- Cluster: `prueba_devops_2-ecs-cluster`
- Servicios: `ventas-back-service`, `despachos-back-service`, `frontend-service`
- Tasks: Número deseado vs corriendo

---

## 🐛 Troubleshooting

### Las tareas ECS no arrancan
1. Revisar eventos: `aws ecs describe-services --cluster <arn> --services <service-name>`
2. Ver logs: `aws logs tail /ecs/prueba_devops_2 --follow`
3. Comprobar ECR: `aws ecr describe-images --repository-name <name>`

### ECR imagen no encontrada
```bash
# Listar imágenes en ECR
aws ecr list-images --repository-name prueba_devops_2-ventas-back --region us-east-1

# Verificar que tiene tag 'latest'
aws ecr describe-images --repository-name prueba_devops_2-ventas-back --region us-east-1
```

### Conexión a MySQL desde local
```bash
# Obtener IP pública
aws ec2 describe-instances --region us-east-1 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
  --output table

# Conectar
mysql -h <PUBLIC_IP> -uroot -p<PASSWORD> -e "USE ecommerce; SHOW TABLES;"
```

---

## 📝 Estructura de Directorios

```
Prueba_DevOps_2/
├── .github/
│   └── workflows/
│       ├── ci.backend.yml         # CI: Testing
│       └── cd.deploy.yml          # CD: Deploy
├── infra/                          # Terraform IaC
│   ├── main.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── ecr.tf
│   ├── ecr_endpoints.tf
│   ├── 05-ecs-services.tf
│   ├── terraform.tfvars
│   └── ...
├── back-Ventas_SpringBoot/         # Microservicio Ventas
├── back-Despachos_SpringBoot/      # Microservicio Despachos
├── front_despacho/                 # Frontend React
├── docker-compose.yml              # Local dev
└── README.md
```

---

## 📄 Licencia

Proyecto educativo - DevOps & Cloud Engineering

---

**Última actualización**: May 18, 2026
