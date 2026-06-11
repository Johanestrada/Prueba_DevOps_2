# Prueba DevOps 2 - Despliegue de E-Commerce en AWS EKS

Proyecto de despliegue de una aplicación de E-Commerce en AWS, utilizando microservicios (Spring Boot), un frontend (React) y orquestación con Kubernetes (EKS). La infraestructura se gestiona como código con Terraform y el ciclo de CI/CD se automatiza con GitHub Actions.

## Arquitectura

A continuación se muestra el diagrama de la arquitectura desplegada en AWS. El flujo va desde el código en GitHub, pasando por la construcción de imágenes en ECR, hasta el despliegue final en un clúster de EKS.

![Diagrama de Arquitectura en AWS](infra/AWS_Diagrama.png)

## 📜 Índice

- [Componentes del Proyecto](#-componentes-del-proyecto)
- [🚀 Despliegue Rápido](#-despliegue-rápido)
  - [Prerrequisitos](#prerrequisitos)
  - [Pasos de Despliegue](#pasos-de-despliegue)
- [🤖 Pipeline CI/CD](#-pipeline-cicd)
  - [Flujo de Trabajo](#flujo-de-trabajo)
  - [Secrets de GitHub](#secrets-de-github-requeridos)
- [🔧 Desarrollo Local](#-desarrollo-local)
  - [Build Manual de Docker](#build-manual-de-docker)
- [📂 Estructura del Proyecto](#-estructura-del-proyecto)

---

## 🛠️ Componentes del Proyecto

### Backend Microservicios
- **API de Ventas** (`/back-Ventas_SpringBoot`): Microservicio en Spring Boot para la gestión de ventas.
- **API de Despachos** (`/back-Despachos_SpringBoot`): Microservicio en Spring Boot para la gestión de despachos.

### Frontend
- **Aplicación de Cliente** (`/front_despacho`): Interfaz de usuario construida con React, Vite y Tailwind CSS, servida a través de Nginx.

### Base de Datos
- **MySQL 8**: Desplegada en una instancia EC2 pública, con acceso restringido por Security Groups para permitir conexiones solo desde el clúster de EKS.

### Infraestructura (Terraform)
El directorio `/infra/terraform` contiene el código para provisionar:
- **Red:** VPC, Subnets públicas/privadas, Internet Gateway y NAT Gateway.
- **Computo:** Clúster de EKS con un grupo de nodos autogestionado.
- **Contenedores:** Repositorios ECR para las imágenes Docker.
- **Seguridad:** Security Groups para controlar el tráfico entre los componentes.

### Orquestación (Kubernetes)
El directorio `/infra/k8s` contiene los manifiestos para desplegar:
- **Deployments:** Para cada microservicio y el frontend.
- **Services:** Para exponer las aplicaciones (ClusterIP para comunicación interna y LoadBalancer para el frontend).
- **Secrets:** Para gestionar las credenciales de la base de datos de forma segura.

---

## 🚀 Despliegue Rápido

----
### Prerrequisitos
- AWS CLI configurado
- Terraform >= 1.0
- Docker Desktop
- Node.js 20+
- `kubectl`

---

### Pasos de Despliegue

1.  **Clonar el Repositorio**
```bash
git clone <repo-url>
cd Prueba_DevOps_2
