REGISTRY = docker.io
USER = travelping
PROJECT = cennsonic
VERSION = $(shell cat src/$(PROJECT) | grep version= | cut -d= -f2)

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
	@echo "    git-release"
	@echo
	@echo "    docker-build"
	@echo "    docker-clean"
	@echo "    docker-distclean"
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
	install src/$(PROJECT) /usr/local/bin/$(PROJECT)

uninstall:
	rm -f /usr/local/bin/$(PROJECT)

git-release:
	git tag -a $(VERSION)
	git push origin $(VERSION)

docker-build:
	docker build . -t $(IMAGE)

docker-clean:
	docker system prune -f --filter label=project=$(PROJECT)

docker-distclean: docker-clean
	docker images -qf label=project=cennsonic | docker rmi

docker-push:
	docker push $(IMAGE)

docker-local-release:
	docker tag $(IMAGE) $(IMAGE_LATEST)

docker-release: docker-local-release docker-push
	docker push $(IMAGE_LATEST)

version:
	@echo "Version $(VERSION) (git-$(GIT_SHA))"
