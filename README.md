Prueba DevOps 2 - E-Commerce Deployment

![Diagrama de Arquitectura del Proyecto](front_despacho/src/diagrama_pp2.png)

Proyecto integral de desplegabilidad en AWS con microservicios Spring Boot, frontend React y orquestación con ECS, ECR y Terraform.

Componentes

Backend Microservicios
Ventas API (back-Ventas_SpringBoot/): Gesión de ventas y compras
Despachos API (back-Despachos_SpringBoot/): Gestión de envíos
Ambos en Spring Boot 3.4.4 con JPA, MySQL 8

Frontend
React + Vite (front_despacho/): UI con Tailwind CSS
Nginx como proxy inverso

Base de Datos
MySQL 8 en EC2 pública (10.0.2.166)
Dentro de VPC con acceso restringido desde ECS

Infraestructura (Terraform)
VPC, subnets públicas/privadas
ECS Cluster + servicios ECR
NAT Gateway para tráfico de egreso
VPC Endpoints: ECR API, ECR DKR, CloudWatch Logs, STS
Security Groups para aislamiento

Estructura De Directorios

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