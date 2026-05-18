# Configuración de GitHub Secrets para CI/CD

Este documento explica qué secretos necesitas configurar en GitHub para que el pipeline de CI/CD funcione correctamente.

## 🔐 Secrets Requeridos

Los siguientes secretos deben ser agregados en **Settings → Secrets and variables → Actions**:

### AWS Credentials
```
AWS_ACCESS_KEY_ID
  └─ Tu AWS Access Key ID
  └─ Obtenlo de: https://console.aws.amazon.com/iam/home#/security_credentials

AWS_SECRET_ACCESS_KEY
  └─ Tu AWS Secret Access Key
  └─ (Mostrado solo UNA VEZ al crear la key - guárdalo bien)

AWS_SESSION_TOKEN
  └─ Tu AWS Session Token (Requerido para credenciales temporales como AWS Academy)
  └─ Obtenlo junto a las otras credenciales en tu laboratorio.

AWS_ACCOUNT_ID
  └─ Tu Account ID de AWS
  └─ Ejemplo: 348374603543
  └─ Obtén de: AWS Console → Account ID (arriba a la derecha)
```

### Database
```
MYSQL_ROOT_PASSWORD
  └─ Contraseña para usuario 'root' de MySQL
  └─ Usa la misma que en: infra/terraform.tfvars
  └─ Ejemplo: 123456789

MYSQL_DATABASE
  └─ Nombre de la base de datos
  └─ Valor: ecommerce
```

---

## 📋 Pasos para Agregar Secrets

### En GitHub Web UI:

1. Ve a tu repositorio
2. **Settings** → **Secrets and variables** → **Actions**
3. Haz clic en **"New repository secret"** para CADA secret:

```
Nombre: AWS_ACCESS_KEY_ID
Valor: <tu-access-key>
[Add secret]

Nombre: AWS_SECRET_ACCESS_KEY
Valor: <tu-secret-key>
[Add secret]

Nombre: AWS_SESSION_TOKEN
Valor: <tu-session-token>
[Add secret]

Nombre: AWS_ACCOUNT_ID
Valor: <tu-account-id>
[Add secret]

Nombre: MYSQL_ROOT_PASSWORD
Valor: <tu-contraseña>
[Add secret]

Nombre: MYSQL_DATABASE
Valor: ecommerce
[Add secret]
```

### O usando GitHub CLI:

```bash
# Reemplaza valores y ejecuta
gh secret set AWS_ACCESS_KEY_ID --body "xxx"
gh secret set AWS_SECRET_ACCESS_KEY --body "xxx"
gh secret set AWS_SESSION_TOKEN --body "xxx"
gh secret set AWS_ACCOUNT_ID --body "348374603543"
gh secret set MYSQL_ROOT_PASSWORD --body "123456"
gh secret set MYSQL_DATABASE --body "ecommerce"
```

---

## 🔍 Verificar Secrets Agregados

```bash
gh secret list
```

Deberías ver todos tus secrets listados (sin mostrar los valores).

---

## ⚠️ Notas de Seguridad

- 🚫 **NUNCA** commits secretos en el código
- 🔒 GitHub los encripta y no se muestran en logs
- 🔄 Rota tus access keys regularmente (cada 3-6 meses)
- 🛡️ Limita permisos IAM al mínimo necesario

---

## Permisos IAM Mínimos Recomendados

Para crear un usuario IAM con permisos limitados para CI/CD:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:us-east-1:*:repository/*"
    },
    {
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ecs:us-east-1:*:service/prueba_devops_2-ecs-cluster/*",
        "arn:aws:ecs:us-east-1:*:task-definition/ventas-back-task:*",
        "arn:aws:ecs:us-east-1:*:task-definition/despachos-back-task:*",
        "arn:aws:ecs:us-east-1:*:task-definition/frontend-task:*"
      ]
    },
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeLoadBalancers"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "terraform:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

---

## 🔄 Flujo de CI/CD con Secrets

```
[Push to main]
    ↓
[GitHub Actions Workflow]
    ↓
[Obtiene AWS_ACCESS_KEY_ID → Autentica en AWS]
    ↓
[Obtiene MYSQL_ROOT_PASSWORD → Configura BD]
    ↓
[Construye & pushea imágenes Docker a ECR]
    ↓
[Terraform apply con credenciales]
    ↓
[ECS update con imágenes nuevas]
    ↓
[✅ Services corriendo]
```

---

## 🆘 Troubleshooting

### Error: "Invalid credentials"
- Verifica que AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY sean correctos
- Comprueba que el Access Key no esté deshabilitado en IAM

### Error: "Secret not found"
- Asegúrate de usar el nombre exacto del secret
- GitHub Secrets son case-sensitive

### Error: "ECR unauthorized"
- Verifica que el usuario IAM tenga permisos `ecr:GetAuthorizationToken`

---

**Última actualización**: May 18, 2026
