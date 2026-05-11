# Exercise 3.1 — EC2 Compute Module

Curso: Optimizaciones y Desempeño — Cloud Deployment Automation

---

# Objetivo

Construir un módulo reusable de Terraform para desplegar una instancia EC2 que ejecute un servidor HTTP en Ruby.

La infraestructura incluye:

- EC2 instance
- IAM Role
- IAM Instance Profile
- Inline IAM Policy
- Security Group
- User-data bootstrap
- Descarga de aplicación desde S3

---

# Arquitectura

```text
S3 Bucket
└── server.rb

EC2 Instance
├── IAM Role
├── IAM Instance Profile
├── Security Group
└── User Data
    ├── instala Ruby
    ├── descarga server.rb
    └── ejecuta servidor HTTP
```
----

# Estructura del proyecto
```text
oyd-exercise-3-1/
├── app/
│   └── server.rb
├── infra/
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── main.tf
│   ├── envs/
│   │   └── dev/
│   │       └── dev.tfvars
│   ├── modules/
│   │   └── compute_ec2/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── evidence/
│       └── instance.txt
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
└── README.md
```
----
# Variables Utilizadas

| Variable      | Valor                 |
| ------------- | --------------------- |
| region        | us-west-2             |
| environment   | dev                   |
| instance_type | t3.micro              |
| ami_id        | ami-0d43f0bb92e485897 |
| app_s3_bucket | exercise-3-1-oyd      |

---

# Terraform Commands
## Inicialización
terraform init

## Validación
terraform validate

## Plan
terraform plan -var-file=envs/dev/dev.tfvars

## Apply
terraform apply -var-file=envs/dev/dev.tfvars

## Destroy
terraform destroy -var-file=envs/dev/dev.tfvars

# Validación de la aplicación
## Health endpoint
curl http://35.91.99.55:8080/health

Respuesta:

{"status":"ok","compute":"ec2"}

## Echo endpoint
curl -X POST http://35.91.99.55:8080/echo \
  -H 'Content-Type: application/json' \
  -d '{"msg":"hello"}'

Respuesta:

{"msg":"hello","compute":"ec2"}

---
# Seguridad aplicada
## IAM Least Privilege
La política IAM permite únicamente:

s3:GetObject

sobre:

arn:aws:s3:::exercise-3-1-oyd/server.rb

Sin wildcards en Actions ni Resources.

# CI Pipeline
El repositorio incluye un workflow de GitHub Actions ubicado en:

[.github/workflows/terraform-ci.yml](.github/workflows/terraform-ci.yml)

El pipeline se ejecuta automáticamente en cada Pull Request dirigido hacia main.

## Validaciones ejecutadas
+ terraform fmt --check -recursive
+ terraform init -backend=false
+ terraform validate
+ terraform plan -var-file=envs/dev/dev.tfvars
+ publicación automática del plan como comentario en el Pull Request

## Seguridad
Las credenciales AWS son inyectadas exclusivamente mediante GitHub Secrets:

| Secret                |
| --------------------- |
| AWS_ACCESS_KEY_ID     |
| AWS_SECRET_ACCESS_KEY |
| AWS_REGION            |

No existen credenciales hardcodeadas en el repositorio.


# Evidence
Contenido de:

[Archivo de evidencia](infra/evidence/instance.txt)

---
# Conceptos aplicados
## Conceptos aplicados
- Terraform Modules
- EC2 provisioning
- IAM Roles
- IAM Instance Profiles
- Least Privilege IAM
- Security Groups
- User-data bootstrapping
- S3 integration
- GitHub Actions
- CI Pipelines
- Infrastructure as Code
---

# Autor
Sergio Geovany Garcia Smith
Carnet 25008130


