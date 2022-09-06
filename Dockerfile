FROM python:3.8-slim-buster

COPY deploy.sh /usr/local/bin/deploy

ENV HELM_PLUGINS=/var/lib/helm/plugins
ENV HELM_DIFF_IGNORE_UNKNOWN_FLAGS=true

# Install the toolset.
RUN apt -y update && apt -y install curl git \
    && pip install awscli \
    && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl \
    && mkdir -p $HELM_PLUGINS \
    && helm plugin install https://github.com/databus23/helm-diff

CMD deploy
