PROJECT = kube
VERSION = 0.4.0

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
	@echo "Usage: make <Command>"
	@echo
	@echo "Commands"
	@echo "    shellcheck"
	@echo
	@echo "    install"
	@echo
	@echo "    docker-build"
	@echo "    docker-push"
	@echo "    docker-release"
	@echo "    docker-local-release"
	@echo "    docker-clean"
	@echo "    docker-distclean"
	@echo
	@echo "    git-release"
	@echo "    version"

shellcheck:
	shellcheck -as bash src/$(PROJECT){,-*}

install:
	mkdir -p /usr/local/bin
	find src -type f -exec install "{}" /usr/local/bin \;

uninstall:
	cd src && find * -type f -exec rm -f /usr/local/bin/"{}" \;
	rmdir /usr/local/bin 2>/dev/null || true

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
