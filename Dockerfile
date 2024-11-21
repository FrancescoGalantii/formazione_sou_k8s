FROM python:3.9-slim

RUN pip install flask

ARG KUBECTL_VERSION=v1.27.3
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

ARG HELM_VERSION=v3.11.0
RUN curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
&& tar -zxvf "helm-${HELM_VERSION}-linux-amd64.tar.gz" \
&& mv linux-amd64/helm /usr/local/bin/ \
&& rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64 

WORKDIR /app

COPY app.py /app

EXPOSE 8000

CMD ["python3", "app.py"]
