REGISTRY = docker.io
USER = travelping
PROJECT = nfv-k8s
VERSION = 0.1.0

GIT_SHA = $(shell git rev-parse HEAD | cut -c1-8)

IMAGE = $(REGISTRY)/$(USER)/$(PROJECT):$(VERSION)
IMAGE_LATEST = $(REGISTRY)/$(USER)/$(PROJECT):latest

usage:
	@echo "Usage: make <Command> [Options]"
	@echo
	@echo "Commands"
	@echo "    install"
	@echo "    uninstall"
	@echo
	@echo "    docker-build"
	@echo "    docker-clean"
	@echo "    docker-dist-clean"
	@echo "    docker-push"
	@echo "    docker-release"
	@echo "    docker-local-release"
	@echo
	@echo "    version"
	@echo
	@echo "Options"
	@echo "    REGISTRY=<Docker registry> (default: $(REGISTRY))"
	@echo "    PROJECT=<Image Name> (default: $(PROJECT))"
	@echo "    USER=<Docker ID> (default: $(USER))"
	@echo "    VERSION=<Version> (default: $(VERSION))"

install:
	install bin/$(PROJECT) /usr/local/bin/$(PROJECT)

uninstall:
	rm -f /usr/local/bin/$(PROJECT)

docker-build:
	docker build . -t $(IMAGE)

docker-clean:
	docker rmi $(IMAGE)

docker-distclean: docker-clean
	docker rmi $(IMAGE_LATEST)

docker-push:
	docker push $(IMAGE)

docker-local-release:
	docker tag $(IMAGE) $(IMAGE_LATEST)

docker-release: docker-local-release docker-push
	docker push $(IMAGE_LATEST)

version:
	@echo "Version $(VERSION) (git-$(GIT_SHA))"
