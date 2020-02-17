VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))
REPO_NAME  ?= postgis
IMAGE_NAME ?= postgis

all: build

build: $(VERSIONS)

define postgis-version
$1:
	docker build --pull -t $(REPO_NAME)/$(IMAGE_NAME):$(shell echo $1) $1
	docker build --pull -t $(REPO_NAME)/$(IMAGE_NAME):$(shell echo $1)-alpine $1/alpine
endef
$(foreach version,$(VERSIONS),$(eval $(call postgis-version,$(version))))

update:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

.PHONY: all build update $(VERSIONS)
