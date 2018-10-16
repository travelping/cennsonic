FROM alpine:3.8

ARG PROJECT=cennsonic
ARG KUBESPRAY_VERSION=2.6.0
ARG GIT_URL=https://github.com/kubernetes-incubator/kubespray

LABEL project=$PROJECT

RUN apk upgrade --no-cache --update && \
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
              /$PROJECT && \
    rm -rf $PROJECT/.git && \
    pip install -r $PROJECT/requirements.txt && \
    apk del .build-deps

COPY /infra /cluster/infra
COPY /config /cluster/config
COPY /ansible /$PROJECT

WORKDIR /$PROJECT

RUN ln -s cluster.yml deploy.yml
