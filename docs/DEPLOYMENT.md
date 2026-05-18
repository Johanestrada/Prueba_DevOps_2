# 🚀 Guía de Despliegue - Prueba DevOps 2

Instrucciones completas para desplegar tu infraestructura en AWS con CI/CD automático.

---

## 📋 Checklist Pre-Despliegue

- [ ] Cuenta AWS activa
- [ ] AWS CLI instalado y configurado (`aws configure`)
- [ ] Terraform instalado (v1.0+)
- [ ] Git configurado
- [ ] Docker Desktop corriendo
- [ ] Node.js 20+ instalado
- [ ] Acceso a repositorio GitHub con permisos de Admin

---

## ✅ Paso 1: Preparación Local

### 1.1 Clonar repositorio
```bash
git clone https://github.com/tu-usuario/Prueba_DevOps_2.git
cd Prueba_DevOps_2
```

### 1.2 Verificar estructura
```bash
ls -la
# Debería mostrar: back-Despachos_SpringBoot, back-Ventas_SpringBoot, front_despacho, infra, .github, etc.
```

### 1.3 Configurar AWS
```bash
aws configure
# Ingresa:
# - AWS Access Key ID: [tu-access-key]
# - AWS Secret Access Key: [tu-secret-key]
# - Default region: us-east-1
# - Default output format: json
```

---

## ✅ Paso 2: Preparar Credenciales AWS

### 2.1 Obtener credenciales de usuario IAM

1. Ve a **AWS Console** → **IAM** → **Users**
2. Crea un nuevo usuario o usa uno existente
3. Asigna permisos: `AmazonEC2FullAccess`, `AmazonECS_FullAccess`, `AmazonECRFullAccess`, `AdministratorAccess` (O usa la política mínima de [GITHUB_SECRETS.md](./GITHUB_SECRETS.md))
4. En **Security credentials**, haz clic en **Create access key**
5. Copia:
   - Access Key ID
   - Secret Access Key

### 2.2 Obtener Account ID
```bash
aws sts get-caller-identity --query Account --output text
# Salida: 348374603543 (tu account ID)
```

---

## ✅ Paso 3: Configurar GitHub Secrets

### 3.1 Ir a GitHub Repository Settings
1. Abre tu repositorio en GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Haz clic en **"New repository secret"**

### 3.2 Agregar Secrets uno por uno

**Secret 1: AWS_ACCESS_KEY_ID**
```
Name: AWS_ACCESS_KEY_ID
Value: [tu-access-key-id-aqui]
```

**Secret 2: AWS_SECRET_ACCESS_KEY**
```
Name: AWS_SECRET_ACCESS_KEY
Value: [tu-secret-access-key-aqui]
```

**Secret 3: AWS_ACCOUNT_ID**
```
Name: AWS_ACCOUNT_ID
Value: 348374603543
```

**Secret 4: MYSQL_ROOT_PASSWORD**
```
Name: MYSQL_ROOT_PASSWORD
Value: 123456789
```

**Secret 5: MYSQL_DATABASE**
```
Name: MYSQL_DATABASE
Value: ecommerce
```

### 3.3 Verificar Secrets
```bash
gh secret list
```

Deberías ver:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_ACCOUNT_ID
MYSQL_ROOT_PASSWORD
MYSQL_DATABASE
```

---

## ✅ Paso 4: Despliegue Manual Inicial (Recomendado)

### 4.1 Desplegar Infraestructura
```bash
cd infra

# Verificar cambios
terraform plan

# Aplicar
terraform apply -auto-approve
```

**Esto crea**:
- VPC con subnets públicas/privadas
- ECS Cluster
- EC2 MySQL
- ECR Repositories
- VPC Endpoints
- Security Groups

### 4.2 Construir y Subir Imágenes
```bash
# Login ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 348374603543.dkr.ecr.us-east-1.amazonaws.com

# Ventas Backend
cd ../back-Ventas_SpringBoot/Springboot-API-REST
docker build -t 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-ventas-back:latest .
docker push 348374603543.dkr.ecr.us-east-1.amazonaws.com/prueba_devops_2-ventas-back:latest

# Despachos Backend
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

### 4.3 Actualizar Servicios ECS
```powershell
$cluster = "arn:aws:ecs:us-east-1:348374603543:cluster/prueba_devops_2-ecs-cluster"

aws ecs update-service --cluster $cluster --service ventas-back-service --force-new-deployment --region us-east-1
aws ecs update-service --cluster $cluster --service despachos-back-service --force-new-deployment --region us-east-1
aws ecs update-service --cluster $cluster --service frontend-service --force-new-deployment --region us-east-1
```

---

## ✅ Paso 5: Obtener URLs de Acceso

### 5.1 Frontend ALB
```bash
aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --filters "Name=LoadBalancerName,Values=prueba-devops-frontend-alb" \
  --query 'LoadBalancers[0].DNSName' \
  --output text
```

**Salida**: `prueba-devops-frontend-alb-123456789.us-east-1.elb.amazonaws.com`

### 5.2 MySQL EC2 IP
```bash
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=prueba_devops_2-mysql" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

**Salida**: `34.123.45.67`

### 5.3 Verificar Servicios
```bash
# Frontend
http://prueba-devops-frontend-alb-123456789.us-east-1.elb.amazonaws.com

# Swagger Ventas
http://prueba-devops-frontend-alb-123456789.us-east-1.elb.amazonaws.com:8080/swagger-ui

# MySQL
mysql -h 34.123.45.67 -uroot -p123456789 -e "USE ecommerce; SHOW TABLES;"
```

---

## ✅ Paso 6: Commit y Push a GitHub (Activar CD)

### 6.1 Deshacer cambios locales de tfvars (para no guardar credenciales)
```bash
cd infra
git checkout terraform.tfvars
```

### 6.2 Crear rama feature/ci-cd
```bash
git checkout -b feature/ci-cd
```

### 6.3 Commitear cambios
```bash
git add .
git commit -m "chore: add CI/CD pipelines and documentation"
git push origin feature/ci-cd
```

**✅ GitHub Actions ejecutará el workflow de CD automáticamente en push a feature/ci-cd**

---

## ✅ Paso 7: Monitorear Despliegue

### 7.1 Ver ejecución en GitHub
1. Repositorio → **Actions**
2. Selecciona el workflow **"CD - Deploy to AWS ECS"**
3. Haz clic en el último run

### 7.2 Revisar logs
- Si hay error, expande el paso que falló
- Copia el error y busca en Google o Stack Overflow

### 7.3 Verificar recursos en AWS
```bash
# ECS Tasks
aws ecs list-tasks --cluster arn:aws:ecs:us-east-1:348374603543:cluster/prueba_devops_2-ecs-cluster --region us-east-1

# ECR Images
aws ecr list-images --repository-name prueba_devops_2-ventas-back --region us-east-1
```

---

## 🔄 Flujo Futuro (Después de Configurar)

Después de la configuración inicial, el flujo es simple:

```
1. Edita código
2. Haz commit en 'develop'
3. Crea PR develop → main
4. Merge en main
5. GitHub Actions despliega automáticamente ✅
6. CD obtiene IP pública y la muestra
```

---

## 🆘 Troubleshooting Común

### "InvalidKeyPair.NotFound: The key pair 'pruebita2' does not exist"
**Solución**: Cambiar `terraform.tfvars`:
```hcl
key_pair_name    = "prueba_2"  # o el key pair que exista en tu AWS
```

### "ECR image not found"
**Solución**: Verificar que la imagen existe:
```bash
aws ecr describe-images --repository-name prueba_devops_2-ventas-back --region us-east-1
```

### "Tasks are PENDING (no se lanzan)"
**Solución**: Ver eventos:
```bash
aws ecs describe-services --cluster arn:aws:ecs:us-east-1:348374603543:cluster/prueba_devops_2-ecs-cluster --services ventas-back-service --region us-east-1 --query 'services[0].events[*].message'
```

### "GitHub Actions secrets not found"
**Solución**: Verificar que estén en Settings → Secrets (no en variables):
```bash
gh secret list
```

---

## 📊 Monitoreo Continuado

### Ver logs de ECS
```bash
aws logs tail /ecs/prueba_devops_2 --since 1h --follow
```

### Ver estado de tareas
```bash
aws ecs list-tasks --cluster arn:aws:ecs:us-east-1:348374603543:cluster/prueba_devops_2-ecs-cluster --region us-east-1 | jq '.taskArns'
```

### Conectar a MySQL desde local
```bash
mysql -h <EC2-IP> -uroot -p<PASSWORD> -e "SELECT * FROM ecommerce.orders LIMIT 5;"
```

---

## 🎯 Checklist Post-Despliegue

- [ ] Frontend accesible en ALB DNS
- [ ] APIs respondiendo en Swagger
- [ ] MySQL accessible desde local
- [ ] CloudWatch logs mostrando mensajes de las aplicaciones
- [ ] GitHub Actions ejecutándose sin errores
- [ ] Cambios en código generan automáticos redeploys al hacer push a main

---

## 📞 Soporte

Si necesitas ayuda:
1. Revisa los logs en GitHub Actions
2. Revisa CloudWatch `/ecs/prueba_devops_2`
3. Ejecuta `aws ecs describe-services` para ver eventos
4. Copia el error en Google o Stack Overflow

---

**Última actualización**: May 18, 2026
**Autor**: DevOps Team
