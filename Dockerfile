FROM alpine:3.8

ARG PROJECT=nfv-k8s
ARG KUBESPRAY_VERSION=2.5.0
ARG GIT_URL=https://github.com/kubernetes-incubator/kubespray

RUN apk upgrade --update --no-cache && \
    apk add --no-cache openssh sshpass python && \
    apk add --no-cache --virtual .build-deps \
        git \
        g++ \
        make \
        py-pip \
        libffi-dev \
        python-dev \
        openssl-dev && \
    pip install --upgrade pip && \
    git clone -b v$KUBESPRAY_VERSION \
              --single-branch \
              --depth 1 \
              $GIT_URL \
              $PROJECT && \
    pip install -r $PROJECT/requirements.txt && \
    apk del .build-deps

ADD /cluster/config /cluster/config

WORKDIR /$PROJECT
