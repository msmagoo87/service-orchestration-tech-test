# First install Redis
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis \
    --namespace redis --create-namespace \
    --set auth.enabled=false \
    --set master.count=1 \
    --set master.resources.requests.memory=100Mi \
    --set master.resources.requests.cpu=100m \
    --set replica.replicaCount=1 \
    --set replica.resources.requests.memory=100Mi \
    --set replica.resources.requests.cpu=100m

# Then install the nginx controller
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --set controller.ingressClassResource.default=true \
  --set resources.requests.memory=100Mi \
  --set resources.requests.cpu=100m \
  --set cloneStaticSiteFromGit.gitSync.resources.requests.memory=100Mi \
  --set cloneStaticSiteFromGit.gitSync.resources.requests.cpu=100m \
  --set metrics.resources.requests.memory=100Mi \
  --set metrics.resources.requests.cpu=100m \
  --namespace ingress-nginx --create-namespace

# Then install the application
cd k8s
kubectl create namespace pw-crud
kustomize build . | kubectl apply -f -