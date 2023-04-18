FROM line/kubectl-kustomize:latest as kustomize
FROM ghcr.io/yannh/kubeconform:latest-alpine as kubeconform

FROM alpine:latest
COPY --from kustomize /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from kustomize /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from kubeconform /kubeconform /usr/local/bin/kubeconform

RUN apk add yq
