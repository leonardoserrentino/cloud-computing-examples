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
```
3. Upload the file to the source bucket using the AWS CLI:
```bash
aws s3 cp users.csv s3://<source_bucket_name>/
```
4. Wait a few seconds, then list the contents of the destination bucket. You will find `users.json`:
```bash
aws s3 ls s3://<destination_bucket_name>/
```
5. `terraform destroy`

# 🐳 Project 03: Containerized Microservices & REST API Communication

## Architectural Overview
This project demonstrates the transition from monolithic software design to a **decoupled microservices architecture** using **Docker** and **Docker Compose**. 

The system consists of two distinct microservices that communicate synchronously over HTTP REST APIs:
1. **Data Ingestion Service:** Functions as the public-facing entry point. It absorbs external client JSON payloads and proxies them downstream via standard HTTP protocols.
2. **Analytics Service:** Operates deep inside the private network boundary. It ingests the proxied data, applies computational thresholding formulas, and manages application state.

## Key Concepts Demonstrated
- **Multi-Stage Docker Builds:** Implements optimized, production-ready `Dockerfiles` separating the build compilation environment from the minimal runtime scratch space. This minimizes image sizing and cuts down security vulnerabilities.
- **Service Discovery & Container Networking:** Leverages an isolated custom Docker bridge network. Services talk to each other utilizing internal DNS resolution names mapping back to Compose service blocks (`http://analytics:5001`), abstracting raw IP configurations.
- **Architectural Isolation:** Independent dependency trees (`requirements.txt`), distinct build execution structures, and zero code coupling.

## How to Deploy and Run
1. Ensure Docker and Docker Compose are installed on your machine.
2. Navigate to the project directory: `cd 03-containerized-microservices`
3. Launch the containerized cluster in detached (background) mode:
   ```bash
   docker compose up --build -d
   ```
4. Verify that both containers are running properly:
   ```bash
   docker compose ps
   ```
## Verification & Testing Tasks
1. Send a mock sensor data payload directly to the public Ingestion Service endpoint via `curl`:
   ```bash
   curl -X POST http://localhost:5000/ingest \
     -H "Content-Type: application/json" \
     -d '{"sensor_id": "SR-99", "value": 142}'
   ```
2. Check the logs to view data forwarding interactions across the virtual bridge:
   ```bash
   docker compose logs
   ```
3. Query the Analytics Service metrics endpoint to see the saved state and computational modifier results:
   ```bash
   curl http://localhost:5001/metrics
   ```

## Teardown
To cleanly stop the containers and dismantle the virtual network:
```bash
docker compose down
```

# ☸️ Project 04: Kubernetes Orchestration & Predictive Autoscaling

## Architectural Overview
This project upgrades our containerized microservices to an enterprise-grade orchestration platform using **Kubernetes**. It transitions from a static Docker Compose network to a highly available, declarative cluster architecture.

Furthermore, this project outlines the design for a **Predictive Horizontal Pod Autoscaler (HPA)**. Instead of reacting retroactively to CPU spikes (which causes dropped packets during sudden traffic bursts), the architecture integrates a custom external metric (`predicted_requests_per_second_5m_ahead`). This allows Kubernetes to pre-warm and pre-scale pods based on mathematical forecasting models.

## Key Concepts Demonstrated
- **Kubernetes Primitives:** Deployments, Services (ClusterIP vs NodePort), and Namespaces.
- **Native Service Discovery:** Cross-service communication relies on Kubernetes CoreDNS (e.g., `analytics-service.cloud-innovator.svc.cluster.local`), eliminating hardcoded IPs.
- **Resource Limits & Requests:** Strict FinOps and stability controls at the container level to prevent "noisy neighbor" scenarios.
- **Advanced Autoscaling:** Multi-metric HPA configuration with custom scaling behaviors (rapid scale-up, delayed scale-down stabilization windows).

## Prerequisites for Local Testing
To run this locally, you need a local Kubernetes cluster like **Minikube** or **Kind**.
* Install `minikube` and `kubectl`.
* Start the cluster: `minikube start`
* Enable the metrics server: `minikube addons enable metrics-server`

## Deployment Instructions
1. First, point your terminal to Minikube's internal Docker daemon so it can find the images we built in Project 3:
   ```bash
   eval $(minikube docker-env)
   ```
2. Re-build the images from Project 3 directly inside the Minikube environment (navigate to the 03 folder to run this):
   ```bash
   docker build -t 03-containerized-microservices-data-ingestion:latest ./services/data-ingestion
   docker build -t 03-containerized-microservices-analytics:latest ./services/analytics
   ```
3. Navigate back to this directory (04-kubernetes-autoscaling) and apply the manifests:
   ```bash
   kubectl apply -f manifests/
   ```

## Verification
Check the status of your pods and the autoscaler:
```bash
kubectl get pods -n user
kubectl get svc -n user
kubectl get hpa -n user
```
```bash
# Get the Minikube IP
MINIKUBE_IP=$(minikube ip)

# Send a payload
curl -X POST http://$MINIKUBE_IP:30050/ingest \
     -H "Content-Type: application/json" \
     -d '{"sensor_id": "K8S-01", "value": 250}'
```

## Teardown
```bash
kubectl delete namespace user
```

---

## Appendix A: Troubleshooting Connection Refused (`localhost:8080`)

### The Problem
When running `kubectl apply`, you might encounter the following error:
> `Get "http://localhost:8080/openapi/v2?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused`

### The Architectural Context
`kubectl` is simply a remote control client. It relies on a configuration file (usually located at `~/.kube/config`) to know where the Kubernetes Control Plane (API Server) lives. If your local cluster is turned off, or `kubectl` doesn't know where it is, it defaults to looking for it on `localhost:8080`. When nothing answers there, it throws this error.

### The Runbook (Resolution Steps)

**1. Start the Local Cluster**
Ensure your local Kubernetes environment (like Minikube) is actually running.
```bash
minikube start
```
**2. Verify the Connection**
Confirm that kubectl is now pointing to the correct, newly spun-up cluster IP rather than the default localhost port.
```bash
kubectl cluster-info
```
Expected Output: You should see the Kubernetes control plane running at an IP like `https://192.168.x.x:8443`.
**Enable the Metrics Server (Required for HPA)**
Because our architecture uses a Horizontal Pod Autoscaler, the cluster must be capable of tracking resource utilization. Enable the addon:
```bash
minikube addons enable metrics-server
```
```bash
kubectl apply -f manifests/
```
