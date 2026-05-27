# Cloud Computing Projects
# ☁️ Project 01: Enterprise IaC Foundation & Secure Networking

## Obiettivo Architetturale
Progettare e implementare una **Virtual Private Cloud (VPC)** resiliente e sicura su AWS utilizzando **Terraform**. Questo progetto stabilisce le fondamenta per le architetture successive, implementando la separazione tra reti pubbliche e private.

## Architettura
- **Public Subnets:** Ospitano un NAT Gateway (con Elastic IP) e un EC2 Bastion Host. Accesso diretto a Internet tramite Internet Gateway (IGW).
- **Private Subnets:** Isolate dall'esterno. Possono comunicare verso Internet (per aggiornamenti) solo uscendo tramite il NAT Gateway, garantendo sicurezza per futuri database o backend.
- **Security Groups:** Il traffico in ingresso è blindato. Il Bastion Host accetta connessioni SSH, e le istanze private accettano traffico *esclusivamente* dal Security Group del Bastion.

## Come eseguire il deploy
1. Configura le credenziali AWS in locale (`aws configure`).
2. Genera una chiave SSH per il Bastion: `ssh-keygen -t ed25519 -f ~/.ssh/aws_key`
3. Inizializza Terraform: `terraform init`
4. Controlla il piano di esecuzione: `terraform plan -out=path`
5. Effettua il provisioning: `terraform apply`

## Connessione per il test
```bash
ssh -i ~/.ssh/aws_key ec2-user@<BASTION_PUBLIC_IP_FROM_OUTPUTS>
```
6. Elimina per evitare costi: `terraform destroy`

# ⚡ Project 02: Serverless Event-Driven ETL Pipeline

## Architectural Overview
This project demonstrates a purely **Serverless Event-Driven Architecture** on AWS. It implements a lightweight Extract, Transform, Load (ETL) pipeline without provisioning any servers. 

Whenever a user or application uploads a `.csv` file to the Source S3 Bucket, an event is fired natively by AWS. This event triggers an AWS Lambda function (written in Python) that parses the CSV, converts the payload into JSON, and persists it in a Destination S3 Bucket.

## Key Concepts Demonstrated
- **Event-Driven Compute:** Execution is triggered by state changes (ObjectCreated) rather than scheduled or manual polling.
- **Principle of Least Privilege (IAM):** The Lambda execution role is strictly scoped. It can only `GetObject` from the source bucket and `PutObject` to the destination bucket.
- **Infrastructure as Code:** Everything, including the Python code packaging (ZIP), is managed seamlessly via Terraform.

## Deployment Instructions
1. Navigate to the project directory: `cd 02-serverless-event-driven`
2. Initialize Terraform: `terraform init`
3. Review the execution plan: `terraform plan`
4. Deploy the infrastructure: `terraform apply --auto-approve`

## How to Test
1. Note the `source_bucket_name` and `destination_bucket_name` from the Terraform outputs.
2. Create a local file named `users.csv` with the following content:
```csv
   id,first_name,last_name,role
   1,Jane,Doe,Admin
   2,John,Smith,User
