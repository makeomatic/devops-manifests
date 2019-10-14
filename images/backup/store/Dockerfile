FROM alpine

RUN apk --no-cache add python py-crcmod libc6-compat gnupg

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

ADD scripts/run.sh /run.sh

CMD ["/run.sh"]
