FROM alpine

RUN apk --no-cache add ca-certificates jq python py-crcmod libc6-compat gnupg bash

### install gcloud
ENV CLOUD_SDK_VERSION=239.0.0
ENV PATH /google-cloud-sdk/bin:$PATH
RUN wget -O gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  tar zxvf gcloud.tar.gz && \
  rm gcloud.tar.gz && \
  ln -s /lib /lib64 && \
  gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image && \
  gcloud components install kubectl docker-credential-gcr

### install helm
RUN wget -O helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.14.3-linux-amd64.tar.gz && \
  tar zxvf helm.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  rm helm.tar.gz && rm -rf linux-amd64 && \
  helm init --client-only

### install skaffold
RUN wget -O skaffold https://storage.googleapis.com/skaffold/releases/v0.40.0/skaffold-linux-amd64 && \
  chmod +x skaffold && \
  mv skaffold /usr/local/bin
