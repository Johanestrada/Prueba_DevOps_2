Param(
  [string]$ProjectName,
  [string]$Region,
  [string]$Profile = ""
)

function Read-Param([string]$message, [string]$default) {
  if ([string]::IsNullOrWhiteSpace($default)) {
    return Read-Host "$message"
  }
  $input = Read-Host "$message [$default]"
  if ([string]::IsNullOrWhiteSpace($input)) { return $default }
  return $input
}

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
  $ProjectName = Read-Param "Nombre del proyecto (terraform var.project_name)" ""
}
if ([string]::IsNullOrWhiteSpace($Region)) {
  $Region = Read-Param "AWS Region" "us-east-1"
}
if ([string]::IsNullOrWhiteSpace($Profile)) {
  $Profile = Read-Param "AWS CLI profile (dejar vacío para usar el predeterminado)" ""
}

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
  Write-Error "Debes indicar el nombre del proyecto."
  exit 1
}

$awsArgs = @()
if (-not [string]::IsNullOrWhiteSpace($Profile)) {
  $awsArgs += "--profile"
  $awsArgs += $Profile
}
$awsArgs += "--region"
$awsArgs += $Region

Write-Host "Obteniendo account ID de AWS..."
$accountId = aws @awsArgs sts get-caller-identity --query Account --output text 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($accountId)) {
  Write-Error "No se pudo obtener el account ID de AWS. Verifica tus credenciales AWS CLI y el perfil."
  exit 1
}

$registry = "$accountId.dkr.ecr.$Region.amazonaws.com"
Write-Host "Cuenta AWS: $accountId"
Write-Host "Registry ECR: $registry"

Write-Host "Iniciando sesión en ECR..."
aws @awsArgs ecr get-login-password | docker login --username AWS --password-stdin $registry
if ($LASTEXITCODE -ne 0) {
  Write-Error "Error en docker login a ECR."
  exit 1
}

$images = @{
  "frontend" = "front_despacho"
  "ventas-back" = "back-Ventas_SpringBoot/Springboot-API-REST"
  "despachos-back" = "back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO"
}

foreach ($imageKey in $images.Keys) {
  $repoName = "$ProjectName-$imageKey"
  Write-Host "\n=== Preparando repositorio: $repoName ==="

  $desc = aws @awsArgs ecr describe-repositories --repository-names $repoName 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Repositorio $repoName no existe. Creando..."
    aws @awsArgs ecr create-repository --repository-name $repoName | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Error "No se pudo crear el repositorio ECR $repoName."
      exit 1
    }
  } else {
    Write-Host "Repositorio $repoName existe."
  }

  $localTag = "$ProjectName-$imageKey:1.0"
  $ecrTag = "$registry/$repoName:1.0"
  $contextPath = $images[$imageKey]

  Write-Host "Construyendo imagen local $localTag desde $contextPath..."
  docker build -t $localTag $contextPath
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al construir la imagen $localTag."
    exit 1
  }

  Write-Host "Etiquetando imagen para ECR: $ecrTag"
  docker tag $localTag $ecrTag
  if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo etiquetar la imagen $localTag."
    exit 1
  }

  Write-Host "Subiendo imagen a ECR: $ecrTag"
  docker push $ecrTag
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al subir la imagen $ecrTag."
    exit 1
  }

  Write-Host "Imagen $repoName subida correctamente."
}

Write-Host "\nTodas las imágenes se subieron correctamente a ECR."
