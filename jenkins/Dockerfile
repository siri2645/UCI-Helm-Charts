#This Dockerfile is used to build the Jenkins-Agent

FROM jenkins/inbound-agent:latest-jdk17
USER root

RUN apt-get update

RUN apt-get install -y \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common \
  wget \
  unzip

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
  && chmod +x get_helm.sh \
  && ./get_helm.sh

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install

USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]