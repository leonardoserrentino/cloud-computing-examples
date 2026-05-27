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
