
# When processing the rules for tagging and pushing container images with the
# "latest" tag, the following variable will be the version that is considered
# to be the latest.
LATEST_VERSION=18-3.6

# The following flags are set based on VERSION and VARIANT environment variables
# that may have been specified, and are used by rules to determine which
# versions/variants are to be processed.  If no VERSION or VARIANT environment
# variables were specified, process everything (the default).
do_default=true
do_alpine=true

ifdef VARIANT
    ifneq ($(VARIANT),default)
    ifneq ($(VARIANT),alpine)
        $(error VARIANT must be either default or alpine)
    endif
    endif
endif

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

COPY_SCRIPT_DIRS = \
	$(if $(filter true,$(do_default)),$(VERSIONS)) \
	$(if $(filter true,$(do_alpine)),$(addsuffix /alpine,$(VERSIONS)))

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

# The repository and image names default to the official but can be overridden
# via environment variables.
REPO_NAME  ?= postgis
IMAGE_NAME ?= postgis

DOCKER=docker
DOCKERHUB_DESC_IMG=peterevans/dockerhub-description:5

GIT=git
OFFIMG_LOCAL_CLONE=$(HOME)/official-images
OFFIMG_REPO_URL=https://github.com/docker-library/official-images.git


build: copy-scripts $(foreach version,$(VERSIONS),build-$(version))

# Build one tag with: make image 18 3.6 alpine (omit the variant for Debian).
# Append multi to export both platforms as a local OCI archive.
ifneq ($(filter image,$(MAKECMDGOALS)),)
  IMAGE_GOALS := $(filter-out image,$(MAKECMDGOALS))
  IMAGE_MULTI := $(filter multi,$(lastword $(IMAGE_GOALS)))
  ifneq ($(IMAGE_MULTI),)
    IMAGE_GOALS := $(filter-out multi,$(IMAGE_GOALS))
  endif
  ifneq ($(words $(IMAGE_GOALS)),2)
    ifneq ($(words $(IMAGE_GOALS)),3)
      $(error usage: make image <postgres-version> <postgis-version> [default|debian|alpine] [multi])
    endif
  endif
  IMAGE_VERSION := $(word 1,$(IMAGE_GOALS))-$(word 2,$(IMAGE_GOALS))
  IMAGE_VARIANT := $(if $(word 3,$(IMAGE_GOALS)),$(word 3,$(IMAGE_GOALS)),default)
  ifneq ($(filter default debian alpine,$(IMAGE_VARIANT)),$(IMAGE_VARIANT))
    $(error image variant must be default, debian, or alpine)
  endif
  ifeq ($(IMAGE_VARIANT),debian)
    IMAGE_VARIANT := default
  endif
  ifeq ($(wildcard $(IMAGE_VERSION)/Dockerfile),)
    $(error no Dockerfile for $(IMAGE_VERSION))
  endif
  ifeq ($(IMAGE_VARIANT),alpine)
    ifeq ($(wildcard $(IMAGE_VERSION)/alpine/Dockerfile),)
      $(error no Alpine Dockerfile for $(IMAGE_VERSION))
    endif
  endif
  IMAGE_SUFFIX := $(if $(filter alpine,$(IMAGE_VARIANT)),-alpine,)
  .PHONY: $(IMAGE_GOALS) $(IMAGE_MULTI)
  $(IMAGE_GOALS) $(IMAGE_MULTI):
	@:
endif

image:
ifneq ($(IMAGE_MULTI),)
	VERSION=$(IMAGE_VERSION) VARIANT=$(IMAGE_VARIANT) $(DOCKER) buildx bake --file docker-bake.hcl --pull --set image.output=type=oci,dest=postgis-$(IMAGE_VERSION)$(IMAGE_SUFFIX).oci.tar image
else
	+$(MAKE) VERSION=$(IMAGE_VERSION) VARIANT=$(IMAGE_VARIANT) build-$(IMAGE_VERSION)
endif

copy-scripts:
	@for directory in $(COPY_SCRIPT_DIRS); do \
		if [ -d "$$directory" ]; then \
			cp -p initdb-postgis.sh update-postgis.sh "$$directory/"; \
		fi; \
	done

all: update
	+$(MAKE) build test

update:
	$(DOCKER) run --rm -v "$(CURDIR):/work" -w /work docker.io/buildpack-deps ./update.sh


### RULES FOR BUILDING ###

define build-version
build-$1: copy-scripts
ifeq ($(do_default),true)
	$(DOCKER) build --pull -t $(REPO_NAME)/$(IMAGE_NAME):$1 $1
	$(DOCKER) images          $(REPO_NAME)/$(IMAGE_NAME):$1
endif
ifeq ($(do_alpine),true)
ifneq ("$(wildcard $1/alpine)","")
	$(DOCKER) build --pull -t $(REPO_NAME)/$(IMAGE_NAME):$1-alpine $1/alpine
	$(DOCKER) images          $(REPO_NAME)/$(IMAGE_NAME):$1-alpine
endif
endif
endef
$(foreach version,$(VERSIONS),$(eval $(call build-version,$(version))))


## RULES FOR TESTING ###

test-prepare:
ifeq ("$(wildcard $(OFFIMG_LOCAL_CLONE))","")
	@for attempt in 1 2 3; do \
		if $(GIT) -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet --depth 1 $(OFFIMG_REPO_URL) $(OFFIMG_LOCAL_CLONE); then \
			exit 0; \
		fi; \
		rm -rf "$(OFFIMG_LOCAL_CLONE)"; \
		echo "official-images clone failed (attempt $$attempt/3); retrying" >&2; \
		sleep $$((attempt * 5)); \
	done; \
	exit 1
endif

test: copy-scripts $(foreach version,$(VERSIONS),test-$(version))
	./test/update-warnings.sh

define test-version
test-$1: test-prepare build-$1
ifeq ($(do_default),true)
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh -c test/postgis-config.sh $(REPO_NAME)/$(IMAGE_NAME):$1
endif
ifeq ($(do_alpine),true)
ifneq ("$(wildcard $1/alpine)","")
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh -c test/postgis-config.sh $(REPO_NAME)/$(IMAGE_NAME):$1-alpine
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
	$(DOCKER) image push $(REPO_NAME)/$(IMAGE_NAME):$1
endif
ifeq ($(do_alpine),true)
ifneq ("$(wildcard $1/alpine)","")
	$(DOCKER) image push $(REPO_NAME)/$(IMAGE_NAME):$1-alpine
endif
endif
endef
$(foreach version,$(VERSIONS),$(eval $(call push-version,$(version))))

push-latest: tag-latest $(PUSH_LATEST_DEP)
	$(DOCKER) image push $(REPO_NAME)/$(IMAGE_NAME):latest
	@$(DOCKER) run -v "$(CURDIR):/workspace" \
                      -e DOCKERHUB_USERNAME='$(DOCKERHUB_USERNAME)' \
                      -e DOCKERHUB_PASSWORD='$(DOCKERHUB_ACCESS_TOKEN)' \
                      -e DOCKERHUB_REPOSITORY='$(REPO_NAME)/$(IMAGE_NAME)' \
                      -e README_FILEPATH='/workspace/README.md' $(DOCKERHUB_DESC_IMG)


.PHONY: build image all copy-scripts update test-prepare test tag-latest push push-latest \
        $(foreach version,$(VERSIONS),build-$(version)) \
        $(foreach version,$(VERSIONS),test-$(version)) \
        $(foreach version,$(VERSIONS),push-$(version))
