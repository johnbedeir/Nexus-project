# Nexus-Project

This project automates the deployment of a Nexus VM on Azure using Terraform, builds a Java web application, and facilitates deployment using Docker and Kubernetes. It also integrates CI/CD pipelines with GitHub Actions for streamlined image building and pushing to Nexus.

---

## Prerequisites

- **Azure Subscription**: Ensure you have access to an Azure account.
- **Terraform**: Install Terraform CLI ([Download Terraform](https://www.terraform.io/downloads)).
- **Docker**: Install Docker ([Install Docker](https://docs.docker.com/get-docker/)).
- **Minikube** (or a Kubernetes cluster): Install Minikube ([Install Minikube](https://minikube.sigs.k8s.io/docs/start/)).
- **Java & Maven**: Install Java Development Kit (JDK) and Maven.

---

## Steps to Deploy

### **1. Configure Azure Infrastructure**

#### **Set Up Terraform Variables**

1. Add your Azure subscription ID to `terraform/subscription.txt`:

   ```bash
   4b0000b-cxxx-40000-bxxxx-b8xxxxxx6a
   ```

2. Configure `terraform/terraform.tfvars` with the following:
   ```bash
   subscription_id="4b0000b-cxxx-40000-bxxxx-b8xxxxxx6a"
   location="East US"
   tenant_id="6fxxxxxf-2xxx-4xxxx-8xxd-1fxxxxxxxxx6"
   vmuser="<VM_USERNAME>" # Your VM SSH username
   ```

#### **Build the Infrastructure**

Run the provided script to build the Azure infrastructure:

```bash
cd terraform/
./build.sh
```

#### **Outputs**

Once completed, you’ll receive the public IP of the Nexus VM:

```bash
vm_public_ip = "13.82.212.227"
```

---

### **2. Connect to the Nexus VM**

- SSH into the Nexus VM using the public IP and the username configured in `terraform.tfvars`:

`The Script will do this step for you and echo the admin password in the console.`

```bash
ssh <VM_USERNAME>@13.82.212.227
```

- Retrieve the Nexus password for initial login.

---

### **3. Configure Nexus**

Navigate to `Nexus` using the Public IP of the Nexus VM and the port `13.82.212.227:8081`

Sign in using the username `admin` and the password (that will be shown in your terminal).

Create a repository for your docker image, make sure it is `docker-hosted`

### **4. Run the Java Application Locally**

#### **Build the Application**

Navigate to the `app` directory and package the Java web app:

```bash
cd app/
mvn package
```

#### **Run the Application**

Run the packaged `.jar` file:

```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

Access the application at `http://localhost:8080`.

---

### **5. Run the Application Using Docker**

#### **Build the Docker Image**

```bash
cd app/
docker build -t javawebapp-img .
```

#### **Run the Docker Container**

```bash
docker run --name javaapp-container -p 8080:8080 javawebapp-img:latest
```

Access the application at `http://localhost:8080`.

---

### **6. Configure Nexus for Docker**

#### **Enable HTTP Port**

1. Log in to Nexus.
2. Navigate to **Settings > Repositories**.
3. Select the repository or create a new one (e.g., `docker-hosted`).
4. Enable **HTTP Port** (e.g., `8082`) and **Docker V1 API**.

<img src=imgs/http.png>

#### **Update Docker Daemon**

Edit the `daemon.json` file on your system to include the Nexus registry:

```bash
{
  "insecure-registries": ["13.82.212.227:8082"]
}
```

Restart Docker:

```bash
sudo systemctl restart docker
```

### Also Navigate to `Nexus` go to `Settings` then choose `Realms` and set `Docker Bearer Token` to be `Active`

<img src=imgs/docker.png>

---

### **7. Deploy the Application Using Kubernetes**

#### **Start Kubernetes**

Start Minikube or your local Kubernetes cluster:

```bash
minikube start
```

#### **Create a Namespace**

Create a namespace for the application:

```bash
kubectl create ns javawebapp-namespace
```

#### **Deploy the Application**

Apply the Kubernetes manifests:

```bash
kubectl apply -n javawebapp-namespace -f k8s
```

---

### **8. CI/CD with GitHub Actions**

#### **Configure GitHub Secrets**

1. Navigate to **Settings > Secrets and Variables > Actions** in your GitHub repository.
2. Add the following secrets:
   - `NEXUS_REGISTRY` (e.g., `13.82.212.227:8082`)
   - `NEXUS_USERNAME` (e.g., `admin`)
   - `NEXUS_PASSWORD` (e.g., `<your-nexus-password>`)

#### **Trigger CI/CD**

Commit your changes to the repository. This triggers the GitHub Actions workflow to:

1. Build the Docker image.
2. Push the image to the Nexus registry.

<img src=imgs/github-actions.png>

<img src=imgs/nexus.png>

### **9. Deploy Monitoring**

Deploy Monitoring stack using Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack
```

Using `k9s` Navigate to `svc` and at the service `kube-prometheus-stack-grafana` press `shift`+`f` to port forward locally at `http://localhost:3000`

#### Access Grafana

```bash
Username: admin
Password: prom-operator
```

<img src=imgs/grafana.png>

### **10. Deploy ArgoCD**

Deploy ArgoCD using Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

helm install argo argo/argo-cd
```

Port forward to localhost

```bash
kubectl port-forward service/argo-argocd-server -n default 8080:443
```

### Create a New Application in ArgoCD

1. **Navigate to Applications**:

   - After adding your repository, go to the **Applications** section from the left sidebar.

2. **Create a New Application**:

   - Click the **New App** button.

3. **Application Configuration**:

   - **Application Name**: Provide a name for your application, e.g., `my-app`.
   - **Project**: Select `default` unless you've set up a custom project.
   - **Sync Policy**: Set to manual or automatic depending on your needs.
   - **Repository URL**: Choose the repository you added earlier.
   - **Path**: Specify the path to the directory where your Kubernetes manifests or Helm chart are located, e.g., `k8s/`.
   - **Cluster**: Choose the cluster where you want to deploy the application (usually the in-cluster Kubernetes context).
   - **Namespace**: Enter the Kubernetes namespace where the application should be deployed, e.g., `default`.

4. **Sync Options**:

   - You can enable auto-sync to automatically deploy changes from the repository to the cluster.
   - Optionally, enable self-heal and prune resources.

5. **Create the Application**:
   - Once all the fields are configured, click **Create** to create the application.

### 5. Sync and Deploy the Application

1. After the application is created, you will be redirected to the application dashboard.
2. If you've set up auto-sync, ArgoCD will automatically deploy the application based on the configurations in the repository.
3. If manual sync is enabled:
   - Click on the **Sync** button to manually trigger the deployment.
   - Monitor the sync status and logs to ensure the application is deployed correctly.

### **10. Destroy the Nexus VM**

To destroy the whole terraform environment that was created for the `Nexus VM` just run the following script:

```
./destroy.sh
```

This should destroy the environment and make sure nothing is left on the Azure cloud.

## Notes

- **Security**: Enable HTTPS on Nexus for secure communication.
- **Customizations**: Modify `terraform.tfvars` and Kubernetes manifests (`k8s`) to fit your needs.
