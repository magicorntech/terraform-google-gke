# resource "local_file" "gke_connect" {
#   filename = "${path.root}/_deployables/1_gke_connect.txt"
#   content  = <<EOF
# ##### Connect to GKE Cluster
# gcloud container clusters get-credentials ${google_container_cluster.main.name} --region=${data.google_client_config.current.region} --project=${data.google_project.current.project_id}
# EOF
# }

# # Note: GKE has built-in cluster autoscaling, no need for separate cluster autoscaler deployment

# resource "local_file" "ingress_nginx" {
#   filename = "${path.root}/_deployables/2_ingress_nginx.txt"
#   content  = <<EOF
# ##### (if necessary) Update Local Helm Repository
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# ##### Deploy NGINX Ingress Controller
# helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
#   --namespace ingress-nginx \
#   --create-namespace \
#   --set controller.service.type=LoadBalancer \
#   --set controller.service.loadBalancerSourceRanges="{0.0.0.0/0}" \
#   --set controller.metrics.enabled=true \
#   --set controller.podAnnotations."prometheus\.io/scrape"="true" \
#   --set controller.podAnnotations."prometheus\.io/port"="10254"
# EOF
# }

# resource "local_file" "tools_debug" {
#   filename = "${path.root}/_deployables/3_tools_debug.yaml"
#   content  = <<EOF
# apiVersion: apps/v1
# kind: DaemonSet
# metadata:
#   name: tools-debug-by-magicorn
#   namespace: kube-system
#   labels:
#     k8s-app: debug-tools
#     maintainer: magicorn
# spec:
#   selector:
#     matchLabels:
#       k8s-app: debug-tools
#   template:
#     metadata:
#       labels:
#         k8s-app: debug-tools
#         maintainer: magicorn
#     spec:
#       volumes:
#         - name: host
#           hostPath:
#             path: /
#             type: Directory
#       containers:
#         - name: tools-debug-by-magicorn
#           image: public.ecr.aws/magicorn/tools-debug:latest
#           command:
#             - sleep
#             - "infinity"
#           resources:
#             limits:
#               cpu: 500m
#               memory: 1000Mi
#             requests:
#               cpu: 100m
#               memory: 200Mi
#           volumeMounts:
#             - name: host
#               mountPath: /host
#           terminationMessagePath: /dev/termination-log
#           terminationMessagePolicy: File
#           imagePullPolicy: Always
#       restartPolicy: Always
#       terminationGracePeriodSeconds: 5
#       dnsPolicy: ClusterFirst
#       schedulerName: default-scheduler
#   updateStrategy:
#     type: RollingUpdate
#     rollingUpdate:
#       maxUnavailable: 1
#       maxSurge: 0
#   revisionHistoryLimit: 3
# EOF
# }

# resource "local_file" "workload_identity_setup" {
#   filename = "${path.root}/_deployables/4_workload_identity_setup.txt"
#   content  = <<EOF
# ##### Setup Workload Identity for applications
# # This file contains setup instructions for Workload Identity bindings

# %{if var.enable_workload_identity && length(var.workload_identity_bindings) > 0}
# # Configured Workload Identity bindings:
# %{for binding in var.workload_identity_bindings}
# # - Namespace: ${binding.namespace}, Service Account: ${binding.service_account}, Role: ${binding.role}
# %{endfor}

# # For each unique namespace/service account combination, you need to:
# %{for binding in distinct([for b in var.workload_identity_bindings : "${b.namespace}/${b.service_account}"])}
# # Setup for: ${split("/", binding)[0]}/${split("/", binding)[1]}
# # 1. Create the namespace if it doesn't exist
# kubectl create namespace ${split("/", binding)[0]} --dry-run=client -o yaml | kubectl apply -f -

# # 2. Create the service account if it doesn't exist
# kubectl create serviceaccount ${split("/", binding)[1]} --namespace ${split("/", binding)[0]} --dry-run=client -o yaml | kubectl apply -f -

# # 3. Annotate the service account to use Workload Identity
# kubectl annotate serviceaccount ${split("/", binding)[1]} \
#   --namespace ${split("/", binding)[0]} \
#   iam.gke.io/gcp-service-account=${google_service_account.node.email}

# %{endfor}
# %{else}
# # No Workload Identity bindings configured
# # To add Workload Identity bindings, update the workload_identity_bindings variable in your Terraform configuration
# %{endif}

# # Example: Manual setup for additional service accounts
# # 1. Create a Google service account for your application
# # gcloud iam service-accounts create my-app-sa \
# #   --project=${data.google_project.current.project_id} \
# #   --description="Service account for my application" \
# #   --display-name="My App Service Account"

# # 2. Grant necessary permissions to the service account
# # gcloud projects add-iam-policy-binding ${data.google_project.current.project_id} \
# #   --member="serviceAccount:my-app-sa@${data.google_project.current.project_id}.iam.gserviceaccount.com" \
# #   --role="roles/storage.objectViewer"

# # 3. Allow the Kubernetes service account to impersonate the Google service account
# # gcloud iam service-accounts add-iam-policy-binding \
# #   --role roles/iam.workloadIdentityUser \
# #   --member "serviceAccount:${data.google_project.current.project_id}.svc.id.goog[NAMESPACE/KSA_NAME]" \
# #   my-app-sa@${data.google_project.current.project_id}.iam.gserviceaccount.com

# # 4. Annotate the Kubernetes service account
# # kubectl annotate serviceaccount KSA_NAME \
# #   --namespace NAMESPACE \
# #   iam.gke.io/gcp-service-account=my-app-sa@${data.google_project.current.project_id}.iam.gserviceaccount.com
# EOF
# }
