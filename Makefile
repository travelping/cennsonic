PROJECT = cennsonic
VERSION = $(shell cat src/$(PROJECT) | grep VERSION= | cut -d= -f2)

REGISTRY = quay.io
USER = travelping

GIT_SHA = $(shell git rev-parse HEAD | cut -c1-8)

IMAGE = $(REGISTRY)/$(USER)/$(PROJECT):$(VERSION)
IMAGE_LATEST = $(REGISTRY)/$(USER)/$(PROJECT):latest

BUILD_ARGS = \
	--build-arg PROJECT=$(PROJECT) \
	--build-arg VERSION=$(VERSION) \
	--build-arg GIT_SHA=$(GIT_SHA)

usage:
	@echo "Usage: make <Command> [Options]"
	@echo
	@echo "Commands"
	@echo "    install"
	@echo "    uninstall"
	@echo
	@echo "    docker-build"
	@echo "    docker-clean"
	@echo "    docker-distclean"
	@echo "    docker-push"
	@echo "    docker-release"
	@echo "    docker-local-release"
	@echo
	@echo "    git-release"
	@echo "    version"
	@echo
	@echo "Options"
	@echo "    REGISTRY=<Docker Registry> # current: $(REGISTRY)"
	@echo "    PROJECT=<Image Name> # current: $(PROJECT)"
	@echo "    USER=<Docker ID> # current: $(USER)"
	@echo "    VERSION=<Version> # current: $(VERSION)"

install:
	install src/$(PROJECT) /usr/local/bin/$(PROJECT)
	install src/$(PROJECT)-user /usr/local/bin/$(PROJECT)-user

uninstall:
	rm -f /usr/local/bin/$(PROJECT)-user
	rm -f /usr/local/bin/$(PROJECT)

docker-build:
	docker build $(BUILD_ARGS) . -t $(IMAGE)

docker-push:
	docker push $(IMAGE)

docker-release: docker-local-release docker-push
	docker push $(IMAGE_LATEST)

docker-local-release:
	docker tag $(IMAGE) $(IMAGE_LATEST)

docker-clean:
	docker system prune -f --filter label=PROJECT=$(PROJECT)

docker-distclean: docker-clean
	docker rmi $(IMAGE_LATEST) $(IMAGE) 2>/dev/null || true

git-release:
	git tag -a $(VERSION)
	git push origin $(VERSION)

version:
	@echo "$(VERSION) (git-$(GIT_SHA))"
