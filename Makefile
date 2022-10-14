
# When processing the rules for tagging and pushing container images with the
# "latest" tag, the following variable will be the version that is considered
# to be the latest.
LATEST_VERSION=14-3.3

# The following flags are set based on VERSION and VARIANT environment variables
# that may have been specified, and are used by rules to determine which
# versions/variants are to be processed.  If no VERSION or VARIANT environment
# variables were specified, process everything (the default).
do_default=true
do_alpine=true

# The following logic evaluates VERSION and VARIANT variables that may have
# been previously specified, and modifies the "do" flags depending on the values.
# The VERSIONS variable is also set to contain the version(s) to be processed.
ifdef VERSION
    VERSIONS=$(VERSION) # If a version was specified, VERSIONS only contains the specified version
    ifdef VARIANT       # If a variant is specified, unset all do flags and allow subsequent logic to set them again where appropriate
        do_default=false
        do_alpine=false
        ifeq ($(VARIANT),default)
            do_default=true
        endif
        ifeq ($(VARIANT),alpine)
            do_alpine=true
        endif
    endif
    ifeq ("$(wildcard $(VERSION)/alpine)","") # If no alpine subdirectory exists, don't process the alpine version
        do_alpine=false
    endif
else # If no version was specified, VERSIONS should contain all versions
    VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))
endif

# The "latest" tag will only be provided for default images (no variant) so
# only define the dependencies when the default image will be built.
ifeq ($(do_default),true)
    BUILD_LATEST_DEP=build-$(LATEST_VERSION)
    PUSH_LATEST_DEP=push-$(LATEST_VERSION)
    PUSH_DEP=push-latest $(PUSH_LATEST_DEP)
    # The "latest" tag shouldn't be processed if a VERSION was explicitly
    # specified but does not correspond to the latest version.
    ifdef VERSION
        ifneq ($(VERSION),$(LATEST_VERSION))
           PUSH_LATEST_DEP=
           BUILD_LATEST_DEP=
           PUSH_DEP=
        endif
    endif
endif

# The repository and image names default to the official but can be overriden
# via environment variables.
REPO_NAME  ?= postgis
IMAGE_NAME ?= postgis

DOCKER=docker
DOCKERHUB_DESC_IMG=peterevans/dockerhub-description:latest

GIT=git
OFFIMG_LOCAL_CLONE=$(HOME)/official-images
OFFIMG_REPO_URL=https://github.com/docker-library/official-images.git


build: $(foreach version,$(VERSIONS),build-$(version))

all: update build test

update:
	$(DOCKER) run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh


### RULES FOR BUILDING ###

define build-version
build-$1:
ifeq ($(do_default),true)
	$(DOCKER) buildx build --pull --platform=linux/amd64,linux/arm64 -t $(REPO_NAME)/$(IMAGE_NAME):$(shell echo $1) $1
endif
ifeq ($(do_alpine),true)
ifneq ("$(wildcard $1/alpine)","")
	$(DOCKER) buildx build --pull --platform=linux/amd64,linux/arm64 -t $(REPO_NAME)/$(IMAGE_NAME):$(shell echo $1)-alpine $1/alpine
endif
endif
endef
$(foreach version,$(VERSIONS),$(eval $(call build-version,$(version))))


## RULES FOR TESTING ###

test-prepare:
ifeq ("$(wildcard $(OFFIMG_LOCAL_CLONE))","")
	$(GIT) clone $(OFFIMG_REPO_URL) $(OFFIMG_LOCAL_CLONE)
endif

test: $(foreach version,$(VERSIONS),test-$(version))

define test-version
test-$1: test-prepare build-$1
ifeq ($(do_default),true)
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh -c test/postgis-config.sh $(REPO_NAME)/$(IMAGE_NAME):$(version)
endif
ifeq ($(do_alpine),true)
ifneq ("$(wildcard $1/alpine)","")
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh -c test/postgis-config.sh $(REPO_NAME)/$(IMAGE_NAME):$(version)-alpine
endif
endif
endef
$(foreach version,$(VERSIONS),$(eval $(call test-version,$(version))))


### RULES FOR TAGGING ###

tag-latest: $(BUILD_LATEST_DEP)
	$(DOCKER) image tag $(REPO_NAME)/$(IMAGE_NAME):$(LATEST_VERSION) $(REPO_NAME)/$(IMAGE_NAME):latest


### RULES FOR PUSHING ###

push: $(foreach version,$(VERSIONS),push-$(version)) $(PUSH_DEP)

define push-version
push-$1: test-$1
ifeq ($(do_default),true)
	$(DOCKER) image push $(REPO_NAME)/$(IMAGE_NAME):$(version)
endif
ifeq ($(do_alpine),true)
ifneq ("$(wildcard $1/alpine)","")
	$(DOCKER) image push $(REPO_NAME)/$(IMAGE_NAME):$(version)-alpine
endif
endif
endef
$(foreach version,$(VERSIONS),$(eval $(call push-version,$(version))))

push-latest: tag-latest $(PUSH_LATEST_DEP)
	$(DOCKER) image push $(REPO_NAME)/$(IMAGE_NAME):latest
	@$(DOCKER) run -v "$(PWD)":/workspace \
                      -e DOCKERHUB_USERNAME='$(DOCKERHUB_USERNAME)' \
                      -e DOCKERHUB_PASSWORD='$(DOCKERHUB_ACCESS_TOKEN)' \
                      -e DOCKERHUB_REPOSITORY='$(REPO_NAME)/$(IMAGE_NAME)' \
                      -e README_FILEPATH='/workspace/README.md' $(DOCKERHUB_DESC_IMG)


.PHONY: build all update test-prepare test tag-latest push push-latest \
        $(foreach version,$(VERSIONS),build-$(version)) \
        $(foreach version,$(VERSIONS),test-$(version)) \
        $(foreach version,$(VERSIONS),push-$(version))

