helm upgrade \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --install --version v1.19.1 \
  --namespace cert-manager \
  --create-namespace \
  --set config.enableGatewayAPI=true \
  --set 'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}' \
  --set crds.enabled=true --set crds.keep=false

kubectl create namespace gateway --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f .env/cloudflare-issuer.yaml
kubectl apply -f .env/rnimbus-gateway.yaml