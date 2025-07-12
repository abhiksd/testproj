# Production-Grade Shared GitHub Actions Workflow for Azure AKS

This repository contains a comprehensive, production-ready shared GitHub Actions workflow system for deploying applications to Azure Kubernetes Service (AKS). The system supports multiple environments, multiple application types, and implements security best practices.

## 🏗️ Architecture Overview

```
.github/
├── workflows/
│   ├── shared-deployment.yml     # Main reusable workflow
│   ├── pr-checks.yml            # PR quality gates
│   ├── java-app-deployment.yml  # Example Java app workflow
│   └── nodejs-app-deployment.yml # Example Node.js app workflow
└── actions/
    ├── setup-environment/       # Environment setup composite action
    ├── build-application/       # Build & push composite action
    ├── security-scans/          # Security scanning composite action
    ├── azure-keyvault/          # Azure Key Vault integration
    └── helm-deploy/             # Helm deployment composite action
```

## 🚀 Features

### Multi-Environment Support
- **Development**: Short SHA-based versioning, reduced resources
- **Staging**: Semantic versioning for release candidates
- **Production**: Semantic versioning with strict security controls

### Multi-Application Support
- **Java Spring Boot**: Maven/Gradle builds, JaCoCo coverage, SpotBugs analysis
- **Node.js**: npm/yarn builds, Jest testing, ESLint validation

### Security & Quality Gates
- **Container Security**: Trivy vulnerability scanning
- **SAST**: SonarQube and Checkmarx integration
- **Dependency Scanning**: OWASP Dependency Check
- **Secret Management**: Azure Key Vault integration
- **PR Protection**: Comprehensive quality gates

### Deployment Features
- **Helm Charts**: Dynamic value generation with environment-specific configurations
- **Versioning**: Semantic versioning for production, SHA-based for development
- **Health Checks**: Automated deployment verification
- **Rollback**: Atomic deployments with automatic rollback on failure

## 🛠️ Setup Instructions

### 1. Azure Infrastructure Prerequisites

```bash
# Create Azure resources
az group create --name myResourceGroup --location eastus

# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Create Azure Container Registry
az acr create \
  --resource-group myResourceGroup \
  --name myACR \
  --sku Standard

# Create Azure Key Vault
az keyvault create \
  --name myKeyVault \
  --resource-group myResourceGroup \
  --location eastus
```

### 2. Service Principal Setup

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "myApp-deployment" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/myResourceGroup \
  --sdk-auth
```

### 3. GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CLIENT_ID` | Service Principal Client ID | `12345678-1234-1234-1234-123456789012` |
| `AZURE_CLIENT_SECRET` | Service Principal Client Secret | `your-client-secret` |
| `AZURE_TENANT_ID` | Azure Tenant ID | `87654321-4321-4321-4321-210987654321` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `11111111-2222-3333-4444-555555555555` |
| `ACR_LOGIN_SERVER` | Container Registry URL | `myacr.azurecr.io` |
| `AKS_CLUSTER_NAME` | AKS Cluster Name | `myAKSCluster` |
| `AKS_RESOURCE_GROUP` | AKS Resource Group | `myResourceGroup` |
| `SONAR_TOKEN` | SonarQube Token | `your-sonar-token` |
| `CHECKMARX_TOKEN` | Checkmarx Token | `your-checkmarx-token` |
| `AZURE_KEY_VAULT_NAME` | Key Vault Name | `myKeyVault` |

### 4. Azure Key Vault Secret Configuration

Store application secrets in Azure Key Vault using the naming convention:
`{application-name}-{environment}-{secret-name}`

```bash
# Example secrets for user-service in production
az keyvault secret set --vault-name myKeyVault --name "user-service-prod-database-url" --value "postgresql://..."
az keyvault secret set --vault-name myKeyVault --name "user-service-prod-database-password" --value "secure-password"
az keyvault secret set --vault-name myKeyVault --name "user-service-prod-jwt-secret" --value "jwt-signing-key"
```

## 📋 Usage Examples

### Java Spring Boot Application

Create `.github/workflows/my-java-app.yml`:

```yaml
name: My Java App Deployment

on:
  push:
    branches: [main, develop]
    paths: ['my-java-app/**']

jobs:
  deploy:
    uses: ./.github/workflows/shared-deployment.yml
    with:
      application_name: 'user-service'
      environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}
      application_type: 'java-spring-boot'
      dockerfile_path: './my-java-app/Dockerfile'
      helm_chart_path: './helm-charts/my-java-app'
    secrets: inherit
```

### Node.js Application

Create `.github/workflows/my-nodejs-app.yml`:

```yaml
name: My Node.js App Deployment

on:
  push:
    branches: [main, develop]
    paths: ['my-nodejs-app/**']

jobs:
  deploy:
    uses: ./.github/workflows/shared-deployment.yml
    with:
      application_name: 'api-gateway'
      environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'staging' }}
      application_type: 'nodejs'
      dockerfile_path: './my-nodejs-app/Dockerfile'
      helm_chart_path: './helm-charts/my-nodejs-app'
    secrets: inherit
```

## 🔐 Security Best Practices

### 1. Secret Management
- All secrets stored in Azure Key Vault
- Application-specific secret isolation
- Automatic secret rotation support
- Secrets masked in GitHub Actions logs

### 2. Container Security
- Multi-stage Dockerfile builds
- Non-root user execution
- Read-only root filesystem
- Vulnerability scanning with Trivy

### 3. PR Protection Rules
Configure branch protection rules in GitHub:

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "PR Quality Gates / validate-pr",
      "PR Quality Gates / security-baseline",
      "PR Quality Gates / container-scan"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true
  }
}
```

### 4. Network Security
- Network policies for pod-to-pod communication
- Ingress with TLS termination
- Service mesh integration ready

## 🎯 Environment-Specific Configurations

### Development Environment
- **Namespace**: `dev-{application-name}`
- **Replicas**: 1
- **Resources**: Minimal (50m CPU, 64Mi RAM)
- **Autoscaling**: Disabled
- **Versioning**: Short SHA (`dev-abc1234`)

### Staging Environment
- **Namespace**: `staging-{application-name}`
- **Replicas**: 2
- **Resources**: Moderate (100m CPU, 128Mi RAM)
- **Autoscaling**: Enabled (2-5 replicas)
- **Versioning**: Release candidate (`1.2.0-rc.1`)

### Production Environment
- **Namespace**: `{application-name}` (default)
- **Replicas**: 3+
- **Resources**: Full allocation (1000m CPU, 1Gi RAM)
- **Autoscaling**: Enabled (3-10 replicas)
- **Versioning**: Semantic versioning (`1.2.0`)
- **Node Affinity**: Production node pool
- **Pod Anti-Affinity**: Spread across nodes

## 📊 Monitoring and Observability

### Metrics Collection
- Prometheus metrics endpoint (`/metrics`)
- Application performance monitoring
- Resource utilization tracking

### Logging
- Structured JSON logging
- Centralized log aggregation
- Log level configuration per environment

### Health Checks
- Liveness probe: `/health`
- Readiness probe: `/ready`
- Startup probe for slow-starting applications

## 🔄 Versioning Strategy

### Production Releases
1. Create a tag: `git tag v1.2.0`
2. Push tag: `git push origin v1.2.0`
3. Workflow automatically deploys with semantic version

### Development Builds
1. Push to feature branch
2. Workflow builds with short SHA: `dev-abc1234`
3. Deploys to development environment

### Release Candidates
1. Push to `release/v1.2.0` branch
2. Workflow builds with RC version: `1.2.0-rc.1`
3. Deploys to staging environment

## 🚨 Troubleshooting

### Common Issues

#### 1. Helm Deployment Failures
```bash
# Check Helm release status
helm status my-app -n my-namespace

# View deployment logs
kubectl logs deployment/my-app -n my-namespace

# Check pod events
kubectl describe pod -l app.kubernetes.io/name=my-app -n my-namespace
```

#### 2. Secret Access Issues
```bash
# Verify Key Vault access
az keyvault secret show --vault-name myKeyVault --name my-secret

# Check service principal permissions
az role assignment list --assignee {client-id}
```

#### 3. Image Pull Errors
```bash
# Test ACR connectivity
az acr login --name myACR

# Check image exists
az acr repository show-tags --name myACR --repository my-app
```

### Debug Mode

Enable debug mode by setting environment variables:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

## 🔧 Customization

### Adding New Application Types

1. Update `setup-environment` action
2. Add build logic in `build-application` action
3. Update security scans in `security-scans` action
4. Test with example application

### Custom Security Scans

Add custom security tools in `.github/actions/security-scans/action.yml`:

```yaml
- name: Custom Security Tool
  run: |
    custom-security-tool scan --path .
```

### Environment-Specific Values

Customize Helm values per environment in the helm-deploy action:

```yaml
# Add environment-specific configurations
if [[ "${{ inputs.environment }}" == "custom-env" ]]; then
  cat >> deployment-values.yaml << EOF
# Custom environment settings
customConfig:
  enabled: true
EOF
fi
```

## 📚 Additional Resources

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Helm Documentation](https://helm.sh/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the PR quality gates
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This workflow system is designed for production use. Ensure you understand the security implications and customize according to your organization's requirements.