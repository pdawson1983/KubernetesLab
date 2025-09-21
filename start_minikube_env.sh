#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v minikube &> /dev/null; then
        print_error "minikube is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "docker is not installed or not in PATH"
        exit 1
    fi
    
    print_status "All prerequisites found"
}

# Check if Docker is running (WSL-compatible)
check_docker() {
    print_status "Checking Docker status..."
    
    # In WSL, Docker Desktop integration means docker command works even if 
    # 'docker info' might have different output
    if docker version &> /dev/null; then
        print_status "Docker is accessible"
        
        # Try to run a simple docker command to verify it's actually working
        if docker ps &> /dev/null; then
            print_status "Docker is running and accessible"
        else
            print_error "Docker command available but daemon not accessible"
            print_error "Make sure Docker Desktop has WSL integration enabled"
            exit 1
        fi
    else
        print_error "Docker is not accessible. Please ensure:"
        echo "  1. Docker Desktop is running on Windows"
        echo "  2. WSL integration is enabled in Docker Desktop settings"
        echo "  3. Your WSL distro is enabled in Docker Desktop"
        exit 1
    fi
}

# Check minikube status
check_minikube_status() {
    if minikube status &> /dev/null; then
        print_warning "Minikube is already running"
        read -p "Do you want to restart it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Stopping minikube..."
            minikube stop
        else
            print_status "Using existing minikube cluster"
            return 0
        fi
    fi
    return 1
}

# Start minikube
start_minikube() {
    print_status "Starting minikube..."
    
    if minikube start --driver=docker --cpus=2 --memory=4096; then
        print_status "Minikube started successfully"
    else
        print_error "Failed to start minikube"
        exit 1
    fi
}

# Configure Docker environment
setup_docker_env() {
    print_status "Configuring Docker environment for minikube..."
    
    # Get the docker-env command
    ENV_CMD=$(minikube docker-env 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        eval "$ENV_CMD"
        print_status "Docker environment configured"
        
        # Verify we're using minikube's docker
        if docker info 2>/dev/null | grep -q "minikube"; then
            print_status "Successfully connected to minikube's Docker daemon"
        else
            print_warning "May not be using minikube's Docker daemon"
        fi
    else
        print_error "Failed to get minikube docker environment"
        exit 1
    fi
}

# Verify cluster connectivity
verify_cluster() {
    print_status "Verifying cluster connectivity..."
    
    if kubectl cluster-info &> /dev/null; then
        print_status "Cluster is accessible"
        kubectl get nodes
    else
        print_error "Cannot connect to cluster"
        exit 1
    fi
}

# Enable useful addons
enable_addons() {
    print_status "Enabling useful addons..."
    
    minikube addons enable ingress
    minikube addons enable metrics-server
    minikube addons enable dashboard
    
    print_status "Addons enabled"
}

# Main execution
main() {
    print_status "Setting up Minikube environment for Kubernetes lab..."
    
    check_prerequisites
    check_docker
    
    if ! check_minikube_status; then
        start_minikube
    fi
    
    setup_docker_env
    verify_cluster
    enable_addons
    
    print_status "Setup complete!"
    echo
    print_status "To use this environment in other terminals, run:"
    echo "  eval \$(minikube docker-env)"
    echo
    print_status "Useful commands:"
    echo "  kubectl get nodes"
    echo "  minikube dashboard"
    echo "  minikube ip"
}

# Run main function
main "$@"