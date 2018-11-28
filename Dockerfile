FROM alpine:3.8

ARG PROJECT=
ARG VERSION=
ARG GIT_SHA=

LABEL PROJECT="${PROJECT}"

ARG KUBESPRAY_VERSION=2.6.0
ARG KUBESPRAY_URL=https://github.com/kubernetes-incubator/kubespray

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
    git clone -b "v${KUBESPRAY_VERSION}" \
              --single-branch \
              --depth 1 \
              "${KUBESPRAY_URL}" \
              "/${PROJECT}" && \
    rm -rf "${PROJECT}/.git" && \
    pip install -r "${PROJECT}/requirements.txt" && \
    apk del .build-deps && \
    echo "${VERSION} (git-${GIT_SHA})" > /version

COPY /infra /cluster/infra
COPY /config /cluster/config
COPY /ansible /$PROJECT

WORKDIR "/${PROJECT}"

RUN ln -s cluster.yml deploy.yml
