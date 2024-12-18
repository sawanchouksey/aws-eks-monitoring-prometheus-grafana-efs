# Comprehensive Guide: AWS EKS Monitoring Cluster Setup with Prometheus, Grafana, and EFS Persistence

## Introduction

### AWS EKS
Amazon Elastic Kubernetes Service (EKS) is a fully managed Kubernetes service provided by AWS. It makes it easy to deploy, manage, and scale Kubernetes applications in the cloud. EKS takes care of the heavy lifting involved in running Kubernetes, allowing you to focus on building your applications.

### Nginx Ingress Controller
The Nginx Ingress Controller is a Kubernetes ingress controller that uses the Nginx web server as a reverse proxy and load balancer. It provides advanced routing and load balancing capabilities for your Kubernetes services, making it easier to expose your applications to the internet.

### Prometheus
Prometheus is a powerful open-source monitoring and alerting solution for Kubernetes. It collects and stores time-series data, allowing you to monitor the health and performance of your applications and infrastructure. Prometheus is a key component for observability in Kubernetes environments.

### Grafana
Grafana is an open-source data visualization and monitoring platform that is often used in conjunction with Prometheus. It provides a flexible and customizable interface for creating dashboards, graphs, and alerts to help you gain insights into your Kubernetes workloads and infrastructure.

### EFS CSI Driver
The Amazon Elastic File System (EFS) Container Storage Interface (CSI) Driver is a Kubernetes storage driver that allows you to use EFS as a persistent storage solution for your Kubernetes applications. This enables you to store and share data across your Kubernetes cluster.

With these components in place, you'll be able to set up a robust and scalable Kubernetes environment on AWS EKS, with advanced ingress routing, comprehensive monitoring and observability, and persistent storage using EFS.

## Prerequisites
- AWS Account
- AWS CLI installed and configured
- Terraform installed
- kubectl installed
- Helm installed
- Basic understanding of Kubernetes and AWS services
- Internet connectivity (for isolated on-prim env you need to do changes in helm charts)

## 1. IAM Role and Policy Preparation

### 1.1 Create IAM Roles for EKS

1. Create an IAM role for EKS cluster management i.e. `eksClusterRole`.

### 1.2 Create IAM Roles for EKS Node Groups

1. Create an IAM role for EKS worker nodes: i.e. `AmazonEKSNodeRole`

2. Create policy for `ebs csi driver` from file `iam-ebs-csi-policy.json` & `efs csi driver` from file `iam-ebs-csi-policy.json` and attach required policies for worker nodes role `AmazonEKSNodeRole`.

## 3. EKS Cluster and EFS Creation from terraform in AWS.
1. Update `terraform.tfvars` file with all variables values with respect to your environment.

2. Initialize Terraform:
```bash
cd terraform-eks
terraform init
terraform fmt
```

3. Plan and apply Terraform configuration:
```bash
terraform validate
terraform plan
terraform apply
```

## 3. Connect eks update kubeconfig with eks cluster

1. Configure kubectl:
```bash
aws eks update-kubeconfig \
  --name YOUR_CLUSTER_NAME \
  --region YOUR_REGION
```

2. Verify EKS cluster:
```bash
kubectl get nodes
```

## 4. Create `monitoring` namespace in eks cluster

1. create namespace
```bash
kubectl create namespace monitoring    
```

2. create storage classes based on requirements i.e. `ebs=gp2|efs=efs-sc`
```bash
kubectl apply -f ebs-sci.yaml
OR
kubectl apply -f efs-sci.yaml  
```

3. Creat and annotate service account for `efs-csi driver`

```bash
kubectl edit sa -n kube-system efs-csi-controller-sa
```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: efs-csi-controller-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<EFS-CsiDriverRole>
```

4. Apply the mainfest after updating the `efs-csi-controller-sa.yaml`
```bash
kubectl apply -f efs-csi-controller-sa.yaml
```

## 5. Nginx Ingress Controller Installation

1. Install Nginx Ingress Controller:
```bash
cd helm-charts
helm install nginx-ingress ingress-nginx --namespace monitoring
```

## 6. Prometheus Installation

1. Install Prometheus with EFS volume persistence:
```bash
helm install prometheus helm-charts/prometheus/prometheuss \
  --namespace monitoring
```

## 7. Grafana Installation

1. Install Grafana with EFS volume persistence:
```bash
helm install grafana helm-charts/grafana \
  --namespace monitoring
```

2. Get the `admin` password for grafana console
```bash
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## 8. Post-Installation Verification

1. Check Nginx Ingress:
```bash
kubectl get services -n ingress-nginx
```

2. Verify Prometheus and Grafana:
```bash
kubectl get pods -n monitoring
```

3. verify Nginx Service with Load Balancer
```bash
kubectl get svc -n monitoring | grep nginx
```

4. Check the grafana console from browser with `Nginx LoadBalancerIP & DNS Name` and login with `admin` credentials.
```
http://<NginxloadBalancerIP & DNS>
```


## Troubleshooting
- Ensure AWS CLI is configured with correct credentials
- Verify VPC and subnet configurations
- Check IAM role and policy attachments for eks, node group, load balancer and efs.
- Validate Terraform and Helm configurations
- Ensure PVC configured correctly
- Ensure events to check for errors

## Security Recommendations
- Use least privilege IAM roles
- Enable encryption for EFS
- Use private subnets for EKS nodes
- Implement network policies

## Cleanup
To remove all resources:
```bash
helm uninstall grafana -n monitoring
helm uninstall prometheus -n monitoring
helm uninstall nginx-ingress -n monitoring
cd ../terraform-eks
terraform destroy
```

## Additional Notes
- Always refer to the latest AWS and Kubernetes documentation
- Customize configurations based on your specific requirements
- Regularly update Helm charts and EKS versions

## References
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [Helm Charts Documentation](https://helm.sh/docs/)
- [Nginx Ingress Docuementation](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm)
- [Prometheus Documentation](https://prometheus.io/)
- [Grafana Documentation](http://grafana.org/)

### Support Me

**If you find my content useful or enjoy what I do, you can support me by buying me a coffee. Your support helps keep this website running and encourages me to create more content.**

[![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/sawanchokso)

**Your generosity is greatly appreciated!**

##### Thank you for your support!💚