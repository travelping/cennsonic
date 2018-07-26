USER = travelping
PROJECT = nfv-k8s

VERSION = 0.1.0
GIT_SHA = $(shell git rev-parse HEAD | cut -c1-8)

IMAGE = $(USER)/$(PROJECT):$(VERSION)
IMAGE_LATEST = $(USER)/$(PROJECT):latest

all:
	@echo "Usage: make <COMMAND> [OPTIONS]"
	@echo
	@echo "COMMANDS"
	@echo "    docker-build"
	@echo "    docker-clean"
	@echo "    docker-push"
	@echo "    docker-release"
	@echo "    docker-login"
	@echo "    docker-logout"
	@echo ""
	@echo "    version"
	@echo
	@echo "OPTIONS"
	@echo "    PROJECT=<Image Name> (default: $(PROJECT))"
	@echo "    USER=<Docker ID> (default: $(USER))"
	@echo "    VERSION=<Version> (default: $(VERSION))"

docker-build:
	docker build . -t $(IMAGE)

docker-clean:
	docker rmi $(IMAGE)

docker-push:
	docker push $(IMAGE)

docker-release: docker-push
	docker tag $(IMAGE) $(IMAGE_LATEST)
	docker push $(IMAGE_LATEST)

docker-login:
	docker login --username $(USER)

docker-logout:
	docker logout

version:
	@echo "Version $(VERSION) (git-$(GIT_SHA))"
