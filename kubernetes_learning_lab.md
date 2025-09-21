# Kubernetes Learning Lab - Complete Curriculum

## Overview
This hands-on lab teaches Kubernetes fundamentals through practical exercises using a WebSphere Liberty application. The curriculum progresses from basic concepts to advanced patterns needed for Azure Kubernetes Service (AKS) operations.

## Prerequisites and Environment Setup

### System Requirements
- **Operating System**: Linux, macOS, or Windows with WSL2
- **Memory**: Minimum 8GB RAM (16GB recommended)
- **CPU**: 2+ cores
- **Disk**: 20GB free space
- **Network**: Internet connection for downloading components

### Required Software Installation

#### 1. Install Docker
**Ubuntu/WSL2:**
```bash
# Update package index
sudo apt update

# Install Docker
sudo apt install docker.io

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Logout and login again, then test
docker --version
```

**macOS:**
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Or using Homebrew:
brew install --cask docker
```

**Windows:**
- Install Docker Desktop for Windows with WSL2 backend
- Enable WSL2 integration in Docker Desktop settings

#### 2. Install kubectl
**Linux:**
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable and move to PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

**macOS:**
```bash
# Using Homebrew
brew install kubectl

# Or download directly
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Windows (WSL2):**
```bash
# Same as Linux commands above, run in WSL2 terminal
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

#### 3. Install Minikube
**Linux:**
```bash
# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

**macOS:**
```bash
# Using Homebrew
brew install minikube

# Or download directly
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

**Windows (WSL2):**
```bash
# Download and install in WSL2
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### 4. Install Java 11 and Maven
**Ubuntu/WSL2:**
```bash
# Install Java 11
sudo apt update
sudo apt install openjdk-11-jdk

# Install Maven
sudo apt install maven

# Verify installations
java -version
mvn -version
```

**macOS:**
```bash
# Using Homebrew
brew install openjdk@11
brew install maven

# Set JAVA_HOME
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
source ~/.zshrc
```

#### 5. Install Helm
**Linux/WSL2:**
```bash
# Download and install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

**macOS:**
```bash
# Using Homebrew
brew install helm
```

#### 6. Install dos2unix (for WSL2/Linux)
```bash
# Install dos2unix for file conversion
sudo apt install dos2unix
```

### Environment Configuration

#### Fix WSL2 Line Endings (Windows Users)
If using WSL2, configure Git and your editor to use Unix line endings:
```bash
# Configure Git for Unix line endings
git config --global core.autocrlf input
git config --global core.eol lf

# Convert existing files
find . -type f \( -name "*.sh" -o -name "*.java" -o -name "*.xml" -o -name "*.properties" -o -name "*.yml" -o -name "*.yaml" \) -exec dos2unix {} \;
```

#### VSCode Configuration (Optional but Recommended)
If using VSCode with WSL2, add these settings to your VSCode settings.json:
```json
{
    "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
    "terminal.integrated.shellArgs.linux": ["-i"],
    "terminal.integrated.env.linux": {
        "TERM": "xterm-256color"
    },
    "files.eol": "\n"
}
```

### Start Minikube Cluster
```bash
# Start Minikube with Docker driver
minikube start --driver=docker --memory=4096 --cpus=2

# Enable necessary addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

### Configure Docker Environment for Minikube
```bash
# Configure shell to use Minikube's Docker daemon
eval $(minikube docker-env)

# Verify Docker is pointing to Minikube
docker ps
```

### Verify Installation
Run these commands to ensure everything is working:
```bash
# Check all components
minikube status
kubectl version --client
docker --version
java -version
mvn -version
helm version

# Test cluster connectivity
kubectl get pods --all-namespaces
```

## Lab Environment Setup

### Initial Configuration
```bash
# Ensure Minikube is running
minikube status

# Configure Docker environment for Minikube
eval $(minikube docker-env)

# Verify cluster access
kubectl cluster-info
kubectl get nodes
```

### Build Application Image in Minikube
```bash
# Navigate to your Liberty app directory
cd /path/to/liberty-simple-app

# Build image in Minikube's Docker daemon
docker build -t liberty-simple:v1 .

# Verify image exists
docker images | grep liberty-simple
```

---

## Module 1: Basic Pod Deployment

### Learning Objectives
- Understand pods as the smallest deployable unit
- Learn basic kubectl commands and their internal mechanics
- Practice creating and managing pods
- Comprehend pod lifecycle and failure scenarios

### Theory: Pod Architecture and Design

**Why Pods, Not Just Containers?**
Pods solve several fundamental challenges in container orchestration:

**Shared Execution Environment**
- Pods create a shared context for containers, similar to how a VM provides shared resources for processes
- All containers in a pod share the same network namespace (single IP, port space)
- Shared storage volumes accessible to all containers
- Shared process namespace (optional) for debugging scenarios

**Atomic Scheduling Unit**
- Kubernetes schedules pods atomically - all containers run on the same node
- Resource requirements are calculated for the entire pod
- Lifecycle events (start, stop, restart) affect the entire pod

**Container Runtime Interface (CRI)**
Understanding how containers actually run:
- **Image Pull**: Runtime downloads container image from registry
- **Container Creation**: Runtime creates container with specified configuration
- **Resource Isolation**: Uses Linux namespaces and cgroups for isolation
- **Health Monitoring**: kubelet monitors container health via probes

### Hands-On Exercise

#### 1.1 Create Your First Pod
```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: liberty-pod
  labels:
    app: liberty
spec:
  containers:
  - name: liberty-container
    image: liberty-simple:v1
    ports:
    - containerPort: 9080
    imagePullPolicy: Never  # Use local image
```

#### 1.2 Deploy and Interact
```bash
# Apply the pod configuration
kubectl apply -f pod.yaml

# Check pod status
kubectl get pods
kubectl get pods -o wide

# Describe the pod (detailed info)
kubectl describe pod liberty-pod

# View pod logs
kubectl logs liberty-pod

# Access the application
kubectl port-forward pod/liberty-pod 8080:9080
# Test: curl http://localhost:8080/hello

# Execute commands in the pod
kubectl exec -it liberty-pod -- /bin/bash

# Clean up
kubectl delete pod liberty-pod
```

#### 1.3 Practice Commands
```bash
# Various ways to get information
kubectl get pods
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods --show-labels
kubectl get pods -l app=liberty

# Watch pods in real-time
kubectl get pods -w
```

### Assessment Questions
1. What happens if a pod crashes?
2. How do you access logs from a crashed pod?
3. What's the difference between a pod and a container?

---

## Module 2: ReplicaSets and Deployments

### Learning Objectives
- Understand the need for ReplicaSets and their reconciliation loops
- Learn deployment strategies and update mechanisms
- Practice scaling and updates with zero downtime
- Comprehend the relationship between Deployments, ReplicaSets, and Pods

### Theory: Controller Pattern and Reconciliation

**The Controller Pattern**
Controllers implement Kubernetes' core automation through continuous reconciliation loops:

**Reconciliation Loop Steps:**
1. **Observe**: Read current state from API server
2. **Analyze**: Compare current state to desired state
3. **Act**: Make changes to reconcile differences
4. **Record**: Update status and emit events
5. **Repeat**: Loop with appropriate intervals

**ReplicaSet Responsibilities:**
- **High Availability**: Automatically replace failed pods
- **Load Distribution**: Spread workload across multiple instances
- **Scaling**: Adjust pod count based on demand
- **Template Management**: Ensure all pods match specified template

**Deployment Capabilities:**
- **Rolling Updates**: Gradually replace old pods with new ones
- **Rollbacks**: Revert to previous ReplicaSet versions
- **Pause/Resume**: Stop and resume update processes
- **History Tracking**: Maintain revision history

### Hands-On Exercise

#### 2.1 Create a Deployment
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: liberty-deployment
  labels:
    app: liberty
spec:
  replicas: 3
  selector:
    matchLabels:
      app: liberty
  template:
    metadata:
      labels:
        app: liberty
    spec:
      containers:
      - name: liberty-container
        image: liberty-simple:v1
        ports:
        - containerPort: 9080
        imagePullPolicy: Never
```

#### 2.2 Deploy and Scale
```bash
# Deploy the application
kubectl apply -f deployment.yaml

# Check deployment status
kubectl get deployments
kubectl get replicasets
kubectl get pods

# Scale the deployment
kubectl scale deployment liberty-deployment --replicas=5
kubectl get pods

# Scale down
kubectl scale deployment liberty-deployment --replicas=2

# View deployment history
kubectl rollout history deployment liberty-deployment
```

#### 2.3 Rolling Updates
```bash
# Update the deployment image (simulate new version)
kubectl set image deployment/liberty-deployment liberty-container=liberty-simple:v2

# Watch the rollout
kubectl rollout status deployment liberty-deployment

# Rollback if needed
kubectl rollout undo deployment liberty-deployment

# Rollback to specific revision
kubectl rollout undo deployment liberty-deployment --to-revision=1
```

### Assessment Tasks
1. Scale your deployment to 10 replicas
2. Perform a rolling update
3. Rollback the update
4. Delete a pod and observe what happens

---

## Module 3: Services and Networking

### Learning Objectives
- Understand service types and their networking implementations
- Learn service discovery mechanisms and DNS integration
- Practice exposing applications with different access patterns
- Comprehend load balancing and traffic distribution

### Theory: Service Abstraction and Networking

**Service Design Goals**
Services solve critical networking challenges in dynamic environments:

**Dynamic IP Problem**
- Pods get ephemeral IP addresses that change frequently
- Applications need stable endpoints for communication
- Direct pod-to-pod connections are fragile

**Service Implementation**
- **kube-proxy**: Implements service networking on each node
- **iptables mode**: Creates iptables rules for load balancing
- **IPVS mode**: Uses Linux IPVS for high-performance load balancing

**DNS Integration**
Kubernetes provides built-in DNS for service discovery:
- Every service gets a DNS A record
- DNS names follow predictable patterns: `service-name.namespace-name.svc.cluster.local`
- Pods automatically get DNS configuration

### Hands-On Exercise

#### 3.1 ClusterIP Service (Internal Access)
```yaml
# service-clusterip.yaml
apiVersion: v1
kind: Service
metadata:
  name: liberty-service-internal
spec:
  selector:
    app: liberty
  ports:
  - port: 80
    targetPort: 9080
  type: ClusterIP
```

#### 3.2 NodePort Service (External Access)
```yaml
# service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: liberty-service-external
spec:
  selector:
    app: liberty
  ports:
  - port: 80
    targetPort: 9080
    nodePort: 30080
  type: NodePort
```

#### 3.3 Deploy and Test Services
```bash
# Apply services
kubectl apply -f service-clusterip.yaml
kubectl apply -f service-nodeport.yaml

# Check services
kubectl get services
kubectl describe service liberty-service-internal

# Test internal service (from within cluster)
kubectl run test-pod --image=busybox -it --rm -- wget -qO- liberty-service-internal/hello

# Test external service
minikube service liberty-service-external --url
curl $(minikube service liberty-service-external --url)/hello

# Check endpoints
kubectl get endpoints
```

#### 3.4 Service Discovery
```bash
# Create a debug pod to test service discovery
kubectl run debug --image=busybox -it --rm -- sh

# Inside the debug pod:
nslookup liberty-service-internal
wget -qO- liberty-service-internal/hello

# Environment variables for service discovery
env | grep LIBERTY_SERVICE_INTERNAL
```

### Assessment Tasks
1. Create a LoadBalancer service (note: may not work in Minikube)
2. Access your application using different service types
3. Test service discovery from another pod

---

## Module 4: ConfigMaps and Secrets

### Learning Objectives
- Externalize application configuration from container images
- Manage sensitive data securely with Kubernetes primitives
- Practice configuration injection methods and update strategies
- Understand the security model and limitations of Secrets

### Theory: Configuration Management Philosophy

**Twelve-Factor App Principles**
Modern applications should separate configuration from code:
- Configuration varies across deployments (dev, staging, production)
- Code should be environment-agnostic
- Sensitive data requires special handling

**ConfigMap vs Secret Usage**
- **ConfigMaps**: Non-sensitive configuration data
- **Secrets**: Sensitive data (passwords, tokens, certificates)
- **Encoding vs Encryption**: Secrets use base64 encoding, not encryption
- **Security Best Practices**: Enable etcd encryption, use RBAC, rotate regularly

**Injection Methods**
- **Environment Variables**: Simple key-value pairs
- **Volume Mounts**: Complex configuration files
- **Projected Volumes**: Combine multiple sources

### Hands-On Exercise

#### 4.1 Create ConfigMap for Non-Sensitive Data
```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: liberty-config
data:
  HTTP_PORT: "9080"
  HTTPS_PORT: "9443"
  LOG_LEVEL: "INFO"
  DB_HOST: "postgres-service"
  DB_PORT: "5432"
  DB_NAME: "libertydb"
  application.properties: |
    app.name=Liberty Learning Lab
    app.version=1.0.0
    app.environment=development
```

#### 4.2 Create Secret for Sensitive Data
```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: liberty-secrets
type: Opaque
data:
  DB_USER: bGliZXJ0eXVzZXI=  # base64 encoded 'libertyuser'
  DB_PASSWORD: bGliZXJ0eXBhc3M=  # base64 encoded 'libertypass'
  API_KEY: YWJjZGVmZ2hpams=  # base64 encoded 'abcdefghijk'
```

#### 4.3 Updated Deployment Using ConfigMap and Secrets
```yaml
# deployment-with-config.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: liberty-deployment-config
spec:
  replicas: 2
  selector:
    matchLabels:
      app: liberty-config
  template:
    metadata:
      labels:
        app: liberty-config
    spec:
      containers:
      - name: liberty-container
        image: liberty-simple:v1
        ports:
        - containerPort: 9080
        envFrom:
        - configMapRef:
            name: liberty-config
        - secretRef:
            name: liberty-secrets
        volumeMounts:
        - name: config-volume
          mountPath: /config/application.properties
          subPath: application.properties
        imagePullPolicy: Never
      volumes:
      - name: config-volume
        configMap:
          name: liberty-config
```

#### 4.4 Deploy and Test
```bash
# Create ConfigMap and Secret
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

# Deploy application with configuration
kubectl apply -f deployment-with-config.yaml

# Check the configuration
kubectl get configmaps
kubectl get secrets
kubectl describe configmap liberty-config

# Verify environment variables in pod
kubectl exec -it deployment/liberty-deployment-config -- env | grep -E "(HTTP_PORT|DB_)"

# Check mounted files
kubectl exec -it deployment/liberty-deployment-config -- cat /config/application.properties
```

#### 4.5 Update Configuration
```bash
# Update ConfigMap
kubectl patch configmap liberty-config -p '{"data":{"LOG_LEVEL":"DEBUG"}}'

# Restart deployment to pick up changes
kubectl rollout restart deployment liberty-deployment-config

# Verify changes
kubectl exec -it deployment/liberty-deployment-config -- env | grep LOG_LEVEL
```

### Assessment Tasks
1. Create a new ConfigMap with your own configuration values
2. Update a Secret and restart the deployment
3. Mount a ConfigMap as a file instead of environment variables

---

## Module 5: Namespaces and Multi-Environment

### Learning Objectives
- Understand namespace isolation and resource boundaries
- Implement multi-environment deployments with proper separation
- Practice resource quotas and limit ranges for governance
- Comprehend RBAC basics and namespace-scoped permissions

### Theory: Namespace Architecture and Multi-Tenancy

**Namespace Benefits**
- **Logical Separation**: Different teams, applications, or environments
- **Resource Isolation**: Prevent resource conflicts between tenants
- **Access Control**: RBAC can be applied at namespace level
- **Network Segmentation**: Network policies can isolate namespace traffic

**Resource Governance**
- **ResourceQuotas**: Limit aggregate resource consumption per namespace
- **LimitRanges**: Set min/max/default values for individual resources
- **Quality of Service**: Based on resource specifications (Guaranteed, Burstable, BestEffort)

**Cross-Namespace Communication**
Services can be accessed across namespaces using FQDN:
- Same namespace: `service-name`
- Different namespace: `service-name.namespace-name.svc.cluster.local`

### Hands-On Exercise

#### 5.1 Create Namespaces
```yaml
# namespaces.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    environment: dev
---
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    environment: staging
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: prod
```

#### 5.2 Environment-Specific ConfigMaps
```yaml
# dev-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: liberty-config
  namespace: development
data:
  HTTP_PORT: "9080"
  LOG_LEVEL: "DEBUG"
  DB_HOST: "postgres-dev"
  REPLICAS: "1"
  ENVIRONMENT: "development"
---
# staging-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: liberty-config
  namespace: staging
data:
  HTTP_PORT: "9080"
  LOG_LEVEL: "INFO"
  DB_HOST: "postgres-staging"
  REPLICAS: "2"
  ENVIRONMENT: "staging"
---
# prod-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: liberty-config
  namespace: production
data:
  HTTP_PORT: "9080"
  LOG_LEVEL: "WARN"
  DB_HOST: "postgres-prod"
  REPLICAS: "5"
  ENVIRONMENT: "production"
```

#### 5.3 Resource Quotas and Limits
```yaml
# resource-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "20"
    services: "10"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: development
spec:
  limits:
  - type: Container
    default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "1"
      memory: "1Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
```

#### 5.4 Deploy to Multiple Environments
```bash
# Create namespaces
kubectl apply -f namespaces.yaml

# Create environment-specific configs
kubectl apply -f dev-config.yaml
kubectl apply -f staging-config.yaml
kubectl apply -f prod-config.yaml

# Apply resource quotas
kubectl apply -f resource-quota.yaml

# Deploy to development
kubectl apply -f liberty-dev.yaml

# View resources across namespaces
kubectl get all --all-namespaces
kubectl get pods -n development
kubectl get pods -n staging
kubectl get pods -n production

# Check resource usage
kubectl describe quota -n development
```

#### 5.5 Cross-Namespace Communication Testing
```bash
# Test cross-namespace communication
kubectl run cross-ns-test -n staging --image=busybox --rm -it -- sh
# Inside pod:
nslookup liberty-service.development.svc.cluster.local
wget -qO- liberty-service.development.svc.cluster.local/hello
```

#### 5.6 Context and Namespace Management
```bash
# Set default namespace for kubectl commands
kubectl config set-context --current --namespace=development

# Create context for different environments
kubectl config set-context dev --namespace=development --cluster=minikube --user=minikube
kubectl config set-context staging --namespace=staging --cluster=minikube --user=minikube
kubectl config set-context prod --namespace=production --cluster=minikube --user=minikube

# Switch contexts
kubectl config use-context dev
kubectl get pods  # Shows pods in development namespace

kubectl config use-context staging
kubectl get pods  # Shows pods in staging namespace
```

### Assessment Tasks
1. Deploy the same application to all three environments with different configurations
2. Create a resource quota that limits development to 1 CPU and 1GB memory
3. Test cross-namespace service communication

---

## Module 6: Persistent Storage

### Learning Objectives
- Understand storage concepts and volume lifecycle in Kubernetes
- Implement persistent volumes and claims for stateful applications
- Deploy and manage databases with persistent storage
- Comprehend StatefulSets vs Deployments for stateful workloads

### Theory: Storage Architecture and Lifecycle

**Volume Abstraction Layers**
1. **Container Storage**: Ephemeral, tied to container lifecycle
2. **Pod Storage**: Shared among containers, tied to pod lifecycle
3. **Persistent Storage**: Independent of pod lifecycle, managed by cluster

**Persistent Volume Subsystem**
- **PersistentVolume (PV)**: Cluster resource representing storage
- **PersistentVolumeClaim (PVC)**: User request for storage
- **StorageClass**: Dynamic provisioning template

**Volume Lifecycle States**
- **Available**: Free volume not yet bound to claim
- **Bound**: Volume bound to claim
- **Released**: Claim deleted but volume not yet reclaimed
- **Failed**: Volume failed automatic reclamation

**StatefulSet Benefits**
- **Stable Network Identity**: Pods get predictable DNS names
- **Stable Storage**: Each pod gets dedicated persistent storage
- **Ordered Deployment**: Pods created in sequential order
- **Ordered Scaling**: Pods terminated in reverse order

### Hands-On Exercise

#### 6.1 Create Persistent Volume
```yaml
# persistent-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /data/postgres
```

#### 6.2 Create Persistent Volume Claim
```yaml
# persistent-volume-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: development
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual
```

#### 6.3 Deploy PostgreSQL Database
```yaml
# postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: development
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: libertydb
        - name: POSTGRES_USER
          value: libertyuser
        - name: POSTGRES_PASSWORD
          value: libertypass
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: development
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
```

#### 6.4 Deploy Storage Infrastructure
```bash
# Create the host directory in Minikube
minikube ssh "sudo mkdir -p /data/postgres && sudo chmod 777 /data/postgres"

# Apply storage configurations
kubectl apply -f persistent-volume.yaml
kubectl apply -f persistent-volume-claim.yaml

# Deploy PostgreSQL
kubectl apply -f postgres-deployment.yaml

# Check storage status
kubectl get pv
kubectl get pvc -n development
kubectl describe pvc postgres-pvc -n development

# Verify PostgreSQL is running
kubectl get pods -n development
kubectl logs deployment/postgres -n development
```

#### 6.5 Test Data Persistence
```bash
# Connect to PostgreSQL and create test data
kubectl exec -it deployment/postgres -n development -- psql -U libertyuser -d libertydb

# Inside psql:
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Johnson', 'bob@example.com');

SELECT * FROM users;
\q

# Test persistence by deleting and recreating pod
kubectl delete pod -l app=postgres -n development
kubectl get pods -n development -w  # Watch replacement pod start

# Verify data survived pod restart
kubectl exec -it deployment/postgres -n development -- psql -U libertyuser -d libertydb -c "SELECT * FROM users;"
```

### Assessment Tasks
1. Create a StatefulSet instead of a Deployment for PostgreSQL
2. Test data persistence across pod restarts
3. Create a PVC that uses dynamic provisioning

---

## Module 7: Health Checks and Monitoring

### Learning Objectives
- Implement comprehensive health checks for applications
- Understand liveness, readiness, and startup probes
- Set up basic monitoring and observability infrastructure
- Practice troubleshooting with metrics and logs

### Theory: Kubernetes Probe Architecture

**Probe Types and Purposes**
- **Liveness Probes**: Determine if container is running properly (restarts container if failed)
- **Readiness Probes**: Determine if container is ready to receive traffic (removes from service endpoints)
- **Startup Probes**: Handle slow-starting containers (disables other probes until startup completes)

**Probe Implementation Methods**
- **HTTP GET**: Check HTTP endpoint status
- **TCP Socket**: Verify port is accepting connections
- **Exec**: Run command inside container, check exit code

**Health Check Design Patterns**
- **Shallow checks**: Fast, minimal dependencies (for liveness)
- **Deep checks**: Comprehensive, includes dependencies (for readiness)
- **Circuit breaker integration**: Prevent cascading failures

### Hands-On Exercise

#### 7.1 Add Health Endpoints to Liberty App
```java
// HealthServlet.java - Add to your Liberty project
package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/health")
public class HealthServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        // Simple health check
        boolean isHealthy = true;
        
        if (isHealthy) {
            response.setStatus(200);
            out.println("{\"status\": \"UP\", \"timestamp\": \"" + new java.util.Date() + "\"}");
        } else {
            response.setStatus(503);
            out.println("{\"status\": \"DOWN\", \"timestamp\": \"" + new java.util.Date() + "\"}");
        }
    }
}
```

#### 7.2 Deployment with Health Checks
```yaml
# deployment-with-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: liberty-with-probes
  namespace: development
spec:
  replicas: 3
  selector:
    matchLabels:
      app: liberty-probes
  template:
    metadata:
      labels:
        app: liberty-probes
    spec:
      containers:
      - name: liberty
        image: liberty-simple:v2  # Rebuild with health endpoints
        ports:
        - containerPort: 9080
        livenessProbe:
          httpGet:
            path: /health
            port: 9080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 9080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        startupProbe:
          httpGet:
            path: /health
            port: 9080
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 10
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        imagePullPolicy: Never
```

#### 7.3 Deploy Monitoring Stack
```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: development
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: development
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus
        args:
        - '--config.file=/etc/prometheus/prometheus.yml'
        - '--storage.tsdb.path=/prometheus'
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-service
  namespace: development
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: NodePort
```

#### 7.4 Testing Health Checks
```bash
# Rebuild image with health endpoints
eval $(minikube docker-env)
docker build -t liberty-simple:v2 .

# Deploy with probes
kubectl apply -f deployment-with-probes.yaml

# Monitor probe status
kubectl get pods -n development -w
kubectl describe pod -l app=liberty-probes -n development

# Test health endpoints
kubectl port-forward deployment/liberty-with-probes -n development 8080:9080
curl http://localhost:8080/health

# Simulate unhealthy pod
kubectl exec -it deployment/liberty-with-probes -n development -- pkill java
# Watch Kubernetes restart the pod automatically

# Deploy monitoring
kubectl apply -f prometheus-config.yaml

# Access Prometheus UI
kubectl port-forward service/prometheus-service -n development 9090:9090
# Open http://localhost:9090 in browser
```

### Assessment Tasks
1. Create a health endpoint that actually checks database connectivity
2. Cause a pod to fail its health check and observe the restart
3. Configure different probe timings for a slow-starting application

---

## Module 8: Ingress and Load Balancing

### Learning Objectives
- Configure ingress controllers for external access and routing
- Implement path-based and host-based routing strategies
- Set up SSL/TLS termination and certificate management
- Practice advanced traffic management and load balancing

### Theory: Ingress Architecture and Design

**Problems Solved by Ingress**
- **NodePort limitations**: Non-standard ports, manual load balancer configuration
- **LoadBalancer cost**: One cloud load balancer per service
- **No application-layer routing**: Cannot route based on hostnames/paths

**Ingress Components**
- **Ingress Resource**: Kubernetes API object defining routing rules
- **Ingress Controller**: Implementation that reads resources and configures proxy
- **Load Balancer**: External component that routes traffic to ingress controller

**Routing Capabilities**
- **Host-based routing**: Different domains to different services
- **Path-based routing**: Different URL paths to different services
- **SSL/TLS termination**: Handle certificates at ingress layer
- **Advanced features**: Rate limiting, authentication, custom headers

### Hands-On Exercise

#### 8.1 Enable Ingress Controller
```bash
# Enable NGINX Ingress Controller in Minikube
minikube addons enable ingress

# Verify ingress controller is running
kubectl get pods -n ingress-nginx
kubectl get services -n ingress-nginx
```

#### 8.2 Basic Host-Based Ingress
```yaml
# basic-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: liberty-ingress
  namespace: development
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: liberty.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: liberty-service
            port:
              number: 80
```

#### 8.3 Path-Based Routing
```yaml
# path-based-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  namespace: development
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: services.liberty.local
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: liberty-service
            port:
              number: 80
      - path: /metrics
        pathType: Prefix
        backend:
          service:
            name: prometheus-service
            port:
              number: 9090
```

#### 8.4 Canary Deployment with Traffic Splitting
```yaml
# Deploy second version of application
# liberty-v2-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: liberty-v2
  namespace: development
spec:
  replicas: 2
  selector:
    matchLabels:
      app: liberty
      version: v2
  template:
    metadata:
      labels:
        app: liberty
        version: v2
    spec:
      containers:
      - name: liberty
        image: liberty-simple:v2
        ports:
        - containerPort: 9080
        env:
        - name: APP_VERSION
          value: "2.0.0"
        imagePullPolicy: Never
---
apiVersion: v1
kind: Service
metadata:
  name: liberty-v2-service
  namespace: development
spec:
  selector:
    app: liberty
    version: v2
  ports:
  - port: 80
    targetPort: 9080
---
# Canary ingress for 20% traffic to v2
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: liberty-canary
  namespace: development
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "20"
spec:
  ingressClassName: nginx
  rules:
  - host: liberty.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: liberty-v2-service
            port:
              number: 80
```

#### 8.5 Deploy and Test Ingress
```bash
# Add hosts to /etc/hosts for local testing
MINIKUBE_IP=$(minikube ip)
echo "$MINIKUBE_IP liberty.local" | sudo tee -a /etc/hosts
echo "$MINIKUBE_IP services.liberty.local" | sudo tee -a /etc/hosts

# Apply ingress configurations
kubectl apply -f basic-ingress.yaml
kubectl apply -f path-based-ingress.yaml

# Check ingress status
kubectl get ingress -n development
kubectl describe ingress liberty-ingress -n development

# Test basic ingress
curl http://liberty.local/hello

# Test path-based routing
curl http://services.liberty.local/app/hello
curl http://services.liberty.local/metrics

# Deploy v2 and canary ingress
kubectl apply -f liberty-v2-deployment.yaml

# Test canary deployment (20% traffic to v2)
for i in {1..10}; do
  curl http://liberty.local/hello
done
```

### Assessment Tasks
1. Configure host-based routing for multiple applications
2. Set up a canary deployment with 10% traffic split
3. Implement SSL termination with a self-signed certificate

---

## Module 9: Multi-Service Architecture

### Learning Objectives
- Design and implement microservices architecture patterns
- Practice service-to-service communication and discovery
- Implement distributed application patterns and resilience
- Understand service mesh concepts and benefits

### Theory: Microservices Architecture Principles

**Service Decomposition Strategies**
- **Business Domain**: Services aligned with business capabilities
- **Data Ownership**: Services own their data and databases
- **Team Structure**: Conway's Law - services reflect organizational structure
- **Scalability**: Different scaling needs drive service boundaries

**Communication Patterns**
- **Synchronous**: HTTP/REST, gRPC (request-response)
- **Asynchronous**: Message queues, event streaming (fire-and-forget)
- **Service Discovery**: DNS-based (Kubernetes native) vs registry-based

**Resilience Patterns**
- **Circuit Breaker**: Prevent cascading failures
- **Retry with Backoff**: Handle transient failures
- **Bulkhead**: Isolate resources for different operations
- **Timeout**: Prevent hanging requests

### Hands-On Exercise

#### 9.1 Frontend Service (Orchestration Layer)
```java
// FrontendServlet.java - New service
package com.example.frontend;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URI;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/dashboard")
public class FrontendServlet extends HttpServlet {
    
    private static final String USER_SERVICE = "http://user-service";
    private static final String ORDER_SERVICE = "http://order-service";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Microservices Dashboard</title></head>");
        out.println("<body>");
        out.println("<h1>Microservices Dashboard</h1>");
        
        // Call user service
        try {
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest userRequest = HttpRequest.newBuilder()
                .uri(URI.create(USER_SERVICE + "/api/status"))
                .build();
                
            HttpResponse<String> userResponse = client.send(userRequest, 
                HttpResponse.BodyHandlers.ofString());
            
            out.println("<h2>User Service Status</h2>");
            out.println("<p>Response: " + userResponse.body() + "</p>");
            
        } catch (Exception e) {
            out.println("<p>User service unavailable: " + e.getMessage() + "</p>");
        }
        
        // Call order service
        try {
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest orderRequest = HttpRequest.newBuilder()
                .uri(URI.create(ORDER_SERVICE + "/api/orders/count"))
                .build();
                
            HttpResponse<String> orderResponse = client.send(orderRequest, 
                HttpResponse.BodyHandlers.ofString());
            
            out.println("<h2>Order Service</h2>");
            out.println("<p>Order count: " + orderResponse.body() + "</p>");
            
        } catch (Exception e) {
            out.println("<p>Order service unavailable: " + e.getMessage() + "</p>");
        }
        
        out.println("</body></html>");
    }
}
```

#### 9.2 User Service (Domain Service)
```java
// UserServiceServlet.java
package com.example.users;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.ThreadLocalRandom;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/api/*")
public class UserServiceServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        switch (pathInfo) {
            case "/status":
                out.println("{\"status\": \"OK\", \"service\": \"user-service\", \"timestamp\": \"" 
                    + new java.util.Date() + "\"}");
                break;
            case "/users/count":
                int count = ThreadLocalRandom.current().nextInt(100, 1000);
                out.println("{\"count\": " + count + "}");
                break;
            default:
                response.setStatus(404);
                out.println("{\"error\": \"Endpoint not found\"}");
        }
    }
}
```

#### 9.3 Order Service (Domain Service)
```java
// OrderServiceServlet.java
package com.example.orders;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.ThreadLocalRandom;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/api/*")
public class OrderServiceServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        switch (pathInfo) {
            case "/orders/count":
                int count = ThreadLocalRandom.current().nextInt(50, 500);
                out.println("{\"count\": " + count + "}");
                break;
            case "/status":
                out.println("{\"status\": \"OK\", \"service\": \"order-service\"}");
                break;
            default:
                response.setStatus(404);
                out.println("{\"error\": \"Endpoint not found\"}");
        }
    }
}
```

#### 9.4 Service Deployments
```yaml
# microservices-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-service
  namespace: development
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: frontend-service:v1
        ports:
        - containerPort: 9080
        env:
        - name: USER_SERVICE_URL
          value: "http://user-service"
        - name: ORDER_SERVICE_URL
          value: "http://order-service"
        imagePullPolicy: Never
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: development
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 9080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: development
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: user-service:v1
        ports:
        - containerPort: 9080
        imagePullPolicy: Never
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: development
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 9080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: development
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: order-service:v1
        ports:
        - containerPort: 9080
        imagePullPolicy: Never
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: development
spec:
  selector:
    app: order-service
  ports:
  - port: 80
    targetPort: 9080
```

#### 9.5 Deploy and Test Microservices
```bash
# Build all service images
eval $(minikube docker-env)
docker build -t frontend-service:v1 ./frontend
docker build -t user-service:v1 ./user-service
docker build -t order-service:v1 ./order-service

# Deploy all services
kubectl apply -f microservices-deployment.yaml

# Verify deployments
kubectl get pods -n development
kubectl get services -n development

# Test service discovery and communication
kubectl port-forward service/frontend-service -n development 8080:80

# Test frontend dashboard
curl http://localhost:8080/dashboard

# Test individual services
kubectl port-forward service/user-service -n development 8081:80
curl http://localhost:8081/api/status

kubectl port-forward service/order-service -n development 8082:80
curl http://localhost:8082/api/orders/count
```

### Assessment Tasks
1. Add a new microservice for inventory and integrate it with the existing services
2. Implement retry logic with exponential backoff
3. Add distributed tracing between services

---

## Module 10: CI/CD and GitOps

### Learning Objectives
- Implement automated deployment pipelines for Kubernetes applications
- Create and manage Helm charts for application packaging and templating
- Practice GitOps deployment strategies and patterns
- Set up comprehensive testing and quality gates in CI/CD pipelines

### Theory: CI/CD and GitOps Principles

**CI/CD Pipeline Stages**
1. **Source**: Code commit triggers pipeline
2. **Build**: Compile, test, package application
3. **Test**: Unit, integration, security tests
4. **Package**: Build container images, Helm charts
5. **Deploy**: Deploy to target environments
6. **Verify**: Health checks, smoke tests
7. **Promote**: Advance through environments

**GitOps Core Principles**
1. **Declarative**: System state declared in Git
2. **Versioned**: All changes tracked in version control
3. **Auditable**: Complete audit trail of deployments
4. **Automated**: Convergence to desired state is automated

**Helm Architecture**
- **Charts**: Packages of pre-configured Kubernetes resources
- **Templates**: Go templates with Kubernetes YAML
- **Values**: Configuration parameters for templates
- **Releases**: Deployed instances of charts

### Hands-On Exercise

#### 10.1 Create Helm Chart
```bash
# Create new Helm chart
helm create liberty-chart
cd liberty-chart

# Examine generated structure
tree .
```

#### 10.2 Customize Helm Templates
```yaml
# values.yaml
replicaCount: 3

image:
  repository: liberty-simple
  pullPolicy: Never
  tag: "v1"

service:
  type: ClusterIP
  port: 80
  targetPort: 9080

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: liberty.local
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

# Environment-specific values
environments:
  development:
    replicaCount: 2
    resources:
      limits:
        cpu: 250m
        memory: 256Mi
  
  production:
    replicaCount: 5
    resources:
      limits:
        cpu: 1000m
        memory: 1Gi

# Feature flags
features:
  monitoring: true
  tracing: false
```

#### 10.3 Enhanced Deployment Template
```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "liberty-chart.fullname" . }}
  labels:
    {{- include "liberty-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "liberty-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      labels:
        {{- include "liberty-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 9080
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            - name: ENVIRONMENT
              value: {{ .Values.environment | default "development" }}
            {{- if .Values.features.monitoring }}
            - name: MONITORING_ENABLED
              value: "true"
            {{- end }}
```

#### 10.4 Deploy with Helm
```bash
# Lint the chart
helm lint liberty-chart

# Dry run deployment
helm install liberty-dev liberty-chart --dry-run --debug -n development

# Deploy to development
helm install liberty-dev liberty-chart -n development \
  --set environment=development \
  --set replicaCount=2

# Deploy to staging with different values
helm install liberty-staging liberty-chart -n staging \
  --set environment=staging \
  --set replicaCount=3

# List releases
helm list -A

# Upgrade deployment
helm upgrade liberty-dev liberty-chart -n development \
  --set image.tag=v2

# View release history
helm history liberty-dev -n development

# Rollback if needed
helm rollback liberty-dev 1 -n development
```

#### 10.5 GitOps with ArgoCD
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: liberty-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/liberty-k8s
    targetRevision: HEAD
    path: helm/liberty-chart
    helm:
      valueFiles:
        - values.yaml
        - values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: development
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

#### 10.6 CI Pipeline Example (GitHub Actions)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up JDK 11
      uses: actions/setup-java@v2
      with:
        java-version: '11'
        distribution: 'temurin'
    
    - name: Build with Maven
      run: mvn clean package
    
    - name: Build Docker image
      run: |
        docker build -t liberty-simple:${{ github.sha }} .
        docker tag liberty-simple:${{ github.sha }} liberty-simple:latest
    
    - name: Deploy to development
      if: github.ref == 'refs/heads/main'
      run: |
        helm upgrade --install liberty-dev ./helm/liberty-chart \
          --namespace development \
          --set image.tag=${{ github.sha }} \
          --wait
```

### Assessment Tasks
1. Create environment-specific value files for Helm
2. Implement a canary deployment strategy using Helm
3. Set up a complete CI/CD pipeline with automated testing

---

## Final Project: Complete Microservices Application

### Project Requirements
Deploy a complete microservices application using all learned concepts:

1. **Architecture**: Frontend, Backend API, User Service, Database
2. **Environments**: Dev, Staging, Production namespaces
3. **Storage**: Persistent database with backups
4. **Networking**: Ingress with SSL termination
5. **Monitoring**: Health checks, metrics, logging
6. **Deployment**: Helm charts with CI/CD pipeline
7. **Scaling**: HPA and resource quotas
8. **Security**: Network policies, RBAC, secrets management

### Success Criteria
- Application accessible via ingress
- Services can communicate internally
- Database persists data across pod restarts
- Health checks prevent unhealthy pods from receiving traffic
- Rolling updates work without downtime
- Monitoring shows application metrics
- Deployments automated via Helm

---

## Next Steps for Azure Kubernetes Service (AKS)

After completing this lab, you'll be prepared for AKS with these additional topics:

### AKS-Specific Concepts
1. **Azure Integration**: ACR, Key Vault, AAD integration
2. **Node Pools**: System vs user node pools, spot instances
3. **Networking**: Azure CNI, Application Gateway Ingress
4. **Storage**: Azure Disk, Azure Files integration
5. **Security**: Pod Security Standards, Azure Policy
6. **Monitoring**: Azure Monitor, Container Insights
7. **GitOps**: Flux v2 integration

### Production Considerations
1. **Cost Optimization**: Resource right-sizing, cluster autoscaler
2. **Security**: Network policies, admission controllers
3. **Disaster Recovery**: Multi-region deployments, backup strategies
4. **Performance**: Resource limits, quality of service classes
5. **Compliance**: Policy enforcement, audit logging

This comprehensive lab provides hands-on experience with all fundamental Kubernetes concepts needed for successful AKS operations and cloud-native application development.