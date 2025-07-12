# Production-Grade Shared GitHub Actions Workflow for Azure AKS

A comprehensive, production-ready shared GitHub Actions workflow system for deploying applications to Azure Kubernetes Service (AKS) with multi-environment support, security scanning, and Azure Key Vault integration.

## 🎯 Key Features

✅ **Multi-Environment Support** (dev, staging, prod)  
✅ **Multi-Application Types** (Java Spring Boot, Node.js)  
✅ **Semantic Versioning** for production, SHA-based for development  
✅ **Comprehensive Security Scans** (SonarQube, Checkmarx, Trivy, OWASP)  
✅ **Azure Key Vault Integration** for secrets management  
✅ **Helm Chart Deployment** with dynamic configurations  
✅ **PR Quality Gates** with automated checks  
✅ **Container Security** and vulnerability scanning  

## 📁 Project Structure

```
.
├── .github/
│   ├── workflows/
│   │   ├── shared-deployment.yml      # 🔄 Main reusable workflow
│   │   ├── pr-checks.yml             # 🛡️  PR quality gates
│   │   ├── java-app-deployment.yml   # ☕ Java app example
│   │   └── nodejs-app-deployment.yml # 🟢 Node.js app example
│   └── actions/
│       ├── setup-environment/        # 🔧 Environment setup
│       ├── build-application/        # 🏗️  Build & push images
│       ├── security-scans/           # 🔒 Security scanning
│       ├── azure-keyvault/          # 🗝️  Key Vault integration
│       └── helm-deploy/             # 🚀 Helm deployment
├── helm-charts/
│   └── generic-app/                 # 📦 Generic Helm chart template
├── DEPLOYMENT_GUIDE.md             # 📖 Comprehensive guide
└── README.md                       # 📝 This file
```

## ⚡ Quick Start

1. **Copy the workflows and actions** to your repository
2. **Configure GitHub secrets** (Azure credentials, tokens)
3. **Set up Azure Key Vault** with application secrets
4. **Create application workflow** using the shared workflow
5. **Push code** and watch the magic happen! ✨

## 🔐 Security-First Approach

- **Zero hardcoded secrets** - All sensitive data in Azure Key Vault
- **Multi-layer security scanning** - SAST, dependency checks, container scans
- **PR protection rules** - No merge without passing quality gates
- **Least privilege access** - Service principals with minimal permissions
- **Container hardening** - Non-root users, read-only filesystems

## 🚀 Usage Example

```yaml
name: My App Deployment

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    uses: ./.github/workflows/shared-deployment.yml
    with:
      application_name: 'my-awesome-app'
      environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}
      application_type: 'java-spring-boot'
      dockerfile_path: './Dockerfile'
      helm_chart_path: './helm-chart'
    secrets: inherit
```

## 📚 Documentation

For detailed setup instructions, configuration options, and troubleshooting, see the [Deployment Guide](DEPLOYMENT_GUIDE.md).

## 🎯 Target Audience

- **DevOps Engineers** implementing CI/CD pipelines
- **Platform Engineers** building shared infrastructure
- **Development Teams** deploying to Kubernetes
- **Security Teams** ensuring compliance and security

## 🛠️ Technologies Used

- **GitHub Actions** - CI/CD orchestration
- **Azure AKS** - Kubernetes platform
- **Azure Container Registry** - Container images
- **Azure Key Vault** - Secret management
- **Helm** - Kubernetes package management
- **Docker** - Containerization
- **SonarQube** - Code quality analysis
- **Checkmarx** - Static security testing
- **Trivy** - Container vulnerability scanning

---

⭐ **Star this repository** if you find it useful!  
🤝 **Contributions welcome** - see the [Deployment Guide](DEPLOYMENT_GUIDE.md) for details.