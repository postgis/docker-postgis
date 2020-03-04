VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))
REPO_NAME  ?= postgis
IMAGE_NAME ?= postgis

GIT=git
OFFIMG_LOCAL_CLONE=$(HOME)/official-images
OFFIMG_REPO_URL=https://github.com/docker-library/official-images.git

build: $(VERSIONS)

all: update build test

test: build test-prepare $(foreach version,$(VERSIONS),test-$(version))

define postgis-version
$1:
	docker build --pull -t $(REPO_NAME)/$(IMAGE_NAME):$(shell echo $1) $1
ifneq ("$(wildcard $1/alpine)","")
	docker build --pull -t $(REPO_NAME)/$(IMAGE_NAME):$(shell echo $1)-alpine $1/alpine
endif
endef
$(foreach version,$(VERSIONS),$(eval $(call postgis-version,$(version))))

update:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

test-prepare:
ifeq ("$(wildcard $(OFFIMG_LOCAL_CLONE))","")
	$(GIT) clone $(OFFIMG_REPO_URL) $(OFFIMG_LOCAL_CLONE)
endif

define test-version
test-$1: $1
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh -c test/postgis-config.sh $(REPO_NAME)/$(IMAGE_NAME):$(version)
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh -c test/postgis-config.sh $(REPO_NAME)/$(IMAGE_NAME):$(version)-alpine
endef
$(foreach version,$(VERSIONS),$(eval $(call test-version,$(version))))

.PHONY: build all test update test-prepare $(VERSIONS) $(foreach version,$(VERSIONS),test-$(version))
