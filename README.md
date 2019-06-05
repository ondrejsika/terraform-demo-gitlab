# Example of Terraform, Digital Ocean, Kubernetes

    Ondrej Sika <ondrej@ondrejsika.com>
    https://github.com/ondrejsika/terraform-do-kubernetes-example

## Tutorial

### Install Terraform & kubectl first

```
brew install kubernetes-cli
brew install terraform
```

### Clone repository

```
git clone git@github.com:ondrejsika/terraform-do-kubernetes-example.git
```

### Initialize Terraform

```
terraform init
```

### See infrastructure changes

```
terraform plan
```

### Apply infrastructure changes

```
terraform apply -auto-approve
```

### Get your Kubernetes config

```
terraform output kubeconfig > kubeconfig
```

### Test connection to cluster

```
export KUBECONFIG=kubeconfig
kubectl cluster-info
kubectl get nodes
```

### Destroy your infrastructure

```
terraform destroy -auto-approve
```