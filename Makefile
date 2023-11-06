# The registry, repository and image names default to the official but can be overriden
# via environment variables.
# For testing, You can start a local registry with:
#    docker run -d -p 5000:5000 --restart=always --name registry registry:2
#    with REGISTRY ?= localhost:5000

ENVFILE = .env
ifeq ($(TEST),true)
  ENVFILE = .env.test
endif
-include $(ENVFILE)
export

REGISTRY ?= docker.io
REPO_NAME  ?= postgis
IMAGE_NAME ?= postgis

ifeq ($(shell uname -m),x86_64)
	IMAGE_ARCH=amd64
else ifeq ($(shell uname -m),aarch64)
	IMAGE_ARCH=arm64
else
	$(error Architecture not supported)
endif

PUBLIC_IMAGE_NAME:=$(IMAGE_NAME)
ifeq ($(ENABLE_IMAGE_ARCH),true)
  IMAGE_NAME:=$(IMAGE_NAME)-$(IMAGE_ARCH)
endif

IMAGE_VERSION_ID :=""
ifeq ($(ENABLE_IMAGE_VERSION_ID),true)
	# Note: Make sure to keep this synchronized with the corresponding section in ./tools/environment_init.sh
	COMMIT_DATE=$(shell git log -1 --format=%cd --date=format:%Y%m%d)
	COMMIT_HASH=$(shell git log -1 --pretty=format:%h)
	BUILD_WEEK=$(shell date '+%Yw%U')
	IMAGE_VERSION_ID=-ver$(COMMIT_DATE)-$(COMMIT_HASH)-$(BUILD_WEEK)
endif

PUSH_FULL_IMAGENAME = ;$(DOCKER) image push $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):
FULL_IMAGENAME_WITH_T =  -t $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):

DOCKER ?=docker
DOCKERHUB_DESC_IMG=peterevans/dockerhub-description:latest
DOCKER_BUILDOPT ?= --network=host --progress=plain

GIT ?=git
OFFIMG_LOCAL_CLONE ?=$(HOME)/official-images
OFFIMG_REPO_URL ?=https://github.com/docker-library/official-images.git

# Default target: help
.DEFAULT_GOAL := help

# Dynamically determine versions and variants based on
#   the existence of Dockerfile at the depth of two directories
#     where the first directory names starting with a number.
DOCKERFILE_DIRS := $(shell find . -mindepth 2 -maxdepth 2 -type d -exec test -e '{}/Dockerfile' \; -print | sed 's|./||' | awk '/^[0-9]/ {print}')
VERSIONS := $(sort $(shell echo '$(DOCKERFILE_DIRS)' | tr ' ' '\n' | cut -d'/' -f1))
VARIANTS := $(sort $(shell echo '$(DOCKERFILE_DIRS)' | tr ' ' '\n' | cut -d'/' -f2))

check_variant:
ifeq ($(VARIANT),default)
	$(error VARIANT is set to 'default', which is not allowed!)
endif
ifeq ($(VARIANT),alpine)
	$(error VARIANT is set to 'alpine', which is not allowed!)
endif

# Build targets for each version-variant combination
define build-target
build-$(1)-$(2): check_variant \
			     $(if $(filter 2,$(shell echo $(1) | grep -o '-' | wc -l)),build-$(shell echo $(1) | cut -d- -f1,2)-$(2))
	@echo '::Building $(FULL_IMAGENAME_WITH_T)$(1)-$(2)   $(IMAGE_VERSION_ID)'
	@echo ':::::: dependency: $(if $(filter 2,$(shell echo $(1) | grep -o '-' | wc -l)),build-$(shell echo $(1) | cut -d- -f1,2)-$(2)) '
	$(DOCKER) build $(DOCKER_BUILDOPT) \
	                --build-arg="REGISTRY=$(REGISTRY)" \
	                --build-arg="REPO_NAME=$(REPO_NAME)" \
	                --build-arg="IMAGE_NAME=$(IMAGE_NAME)" \
					$(if $(filter 1,$(shell echo $(1) | grep -o '-' | wc -l)), --pull ) \
		  		    $(shell cat $(1)/$(2)/tags | sed 's#\([a-zA-Z0-9.-]*\)#$(subst $,,$(FULL_IMAGENAME_WITH_T))\1#g' ) \
					$(if $(IMAGE_VERSION_ID),$(shell cat $(1)/$(2)/tags | sed 's#\([a-zA-Z0-9.-]*\)#$(subst $,,$(FULL_IMAGENAME_WITH_T))\1$(IMAGE_VERSION_ID)#g' ),) \
					$(1)/$(2)
	$(DOCKER) image ls $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
	$(DOCKER) image ls             $(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
	$(DOCKER) image inspect $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call build-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))

# Build targets for each version
define build-version-target
build-$(1): $(shell echo '$(DOCKERFILE_DIRS)' | tr ' ' '\n' | grep ^$(1)/ | sed 's|$(1)/|build-$(1)-|')
endef
$(foreach version,$(VERSIONS),$(eval $(call build-version-target,$(version))))
# General build target
build: $(foreach dir,$(DOCKERFILE_DIRS),build-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir))))


# --------------------------------------------------

test-prepare:
ifeq ("$(wildcard $(OFFIMG_LOCAL_CLONE))","")
	@echo '::Cloning official-images $(OFFIMG_LOCAL_CLONE)'
	$(GIT) clone $(OFFIMG_REPO_URL) $(OFFIMG_LOCAL_CLONE)
else
	@echo '::Updating official-images : $(OFFIMG_LOCAL_CLONE)'
	cd $(OFFIMG_LOCAL_CLONE) && $(GIT) pull origin master
endif

# Test targets for each version-variant combination
define test-target
test-$(1)-$(2): test-prepare \
                build-$1-$(2) \
			    $(if $(filter 2,$(shell echo $(1) | grep -o '-' | wc -l)),test-$(shell echo $(1) | cut -d- -f1,2)-$(2))
	@echo ':Testing $(1)/$(2)' - $(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
	@echo ':::::: dependency: $(if $(filter 2,$(shell echo $(1) | grep -o '-' | wc -l)),test-$(shell echo $(1) | cut -d- -f1,2)-$(2)) '
	$(OFFIMG_LOCAL_CLONE)/test/run.sh \
	    -c $(OFFIMG_LOCAL_CLONE)/test/config.sh \
		-c test/postgis-config.sh \
		$(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)

endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call test-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))

# Build targets for each version
define test-version-target
test-$(1): $(shell echo '$(DOCKERFILE_DIRS)' | tr ' ' '\n' | grep ^$(1)/ | sed 's|$(1)/|test-$(1)-|')
endef
$(foreach version,$(VERSIONS),$(eval $(call test-version-target,$(version))))
# General test target
test: $(foreach dir,$(DOCKERFILE_DIRS),test-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir))))

# --------------------------------------------------
# Push targets for each version-variant combination
define push-target
push-$(1)-$(2): $(if $(filter 2,$(shell echo $(1) | grep -o '-' | wc -l)),push-$(shell echo $(1) | cut -d- -f1,2)-$(2))
	@echo '::push $(1)/$(2)'
	# push all image tags
	$(foreach tag,$(shell cat $(1)/$(2)/tags), \
		echo " -->  push1: $(tag) " && \
		$(DOCKER) image push $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(tag) ; \
	)

	$(if $(IMAGE_VERSION_ID), \
	   # push all image tags - with version id  ( -verYYYYMMDD-XXXXXX-YYYYwW W)
	   $(foreach tag,$(shell cat $(1)/$(2)/tags), \
		echo " -->  push2: $(tag)$(IMAGE_VERSION_ID) " && \
		$(DOCKER) image push $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(tag)$(IMAGE_VERSION_ID) ; \
		),)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call push-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))

# Build targets for each version
define push-version-target
push-$(1): $(shell echo '$(DOCKERFILE_DIRS)' | tr ' ' '\n' | grep ^$(1)/ | sed 's|$(1)/|push-$(1)-|')
endef
$(foreach version,$(VERSIONS),$(eval $(call push-version-target,$(version))))
# General push target
push: $(foreach dir,$(DOCKERFILE_DIRS),push-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir))))


# --------------------------------------------------
# Manifest targets for each version-variant combination
define manifest-target
manifest-$(1)-$(2): $(if $(filter 2,$(shell echo $(1) | grep -o '-' | wc -l)),manifest-$(shell echo $(1) | cut -d- -f1,2)-$(2))
	@echo '::Manifest $(1)/$(2)'
	$(foreach tag,$(shell cat $(1)/$(2)/tags), \
		echo " -->  manifest: $(1)/$(2):$(tag) " && \
		manifest-tool push from-args \
		    --platforms linux/amd64,linux/arm64 \
		    --template $(REGISTRY)/$(REPO_NAME)/$(PUBLIC_IMAGE_NAME)-ARCHVARIANT:$(tag) \
		    --target $(REGISTRY)/$(REPO_NAME)/$(PUBLIC_IMAGE_NAME):$(tag) || true; \
	)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call manifest-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))

# Manifest targets for each version
define manifest-version-target
manifest-$(1): $(shell echo '$(DOCKERFILE_DIRS)' | tr ' ' '\n' | grep ^$(1)/ | sed 's|$(1)/|manifest-$(1)-|')
endef
$(foreach version,$(VERSIONS),$(eval $(call manifest-version-target,$(version))))
# General manifest target
manifest: $(foreach dir,$(DOCKERFILE_DIRS),manifest-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir))))



# --------------------------------------------------
push-readme:
	@echo 'Docker pull $(DOCKERHUB_DESC_IMG)'
	$(DOCKER) pull $(DOCKERHUB_DESC_IMG);
	@echo 'Docker push README $(DOCKERHUB_DESC_IMG)'
	@echo 'DOCKERHUB_REPOSITORY="$(DOCKERHUB_README_REPOSITORY)"'
	$(DOCKER) run -v "$(PWD)":/workspace \
                  -e DOCKERHUB_USERNAME="$(DOCKERHUB_USERNAME)" \
                  -e DOCKERHUB_PASSWORD="$(DOCKERHUB_ACCESS_TOKEN)" \
                  -e DOCKERHUB_REPOSITORY="$(DOCKERHUB_README_REPOSITORY)" \
                  -e README_FILEPATH="/workspace/README.md" $(DOCKERHUB_DESC_IMG);



# --------------------------------------------------
# password: f62ba0 == echo -n "postgis" | md5sum | cut -c 1-6
define start-target
start-$(1)-$(2):
	$(DOCKER) run \
	      --name postgis-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1) \
		  -e POSTGRES_PASSWORD="pwf62ba0-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)" \
		  -v postgisdataf62ba0-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1):/var/lib/postgresql/data \
		  -d $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call start-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))
# --------------------------------------------------
define stop-target
stop-$(1)-$(2):
	$(DOCKER) stop postgis-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call stop-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))
# --------------------------------------------------
define psql-target
psql-$(1)-$(2):
	$(DOCKER) exec -ti postgis-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1) psql -U postgres
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call psql-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))
# --------------------------------------------------
define clean-target
clean-$(1)-$(2):
	@if [ "$$(docker ps -a -q -f name=postgis-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1))" ]; then \
		$(DOCKER) rm $$(docker ps -a -q -f name=postgis-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)); \
	else \
		echo "No such container to remove : postgis-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)"; \
	fi
	@if [ "$$(docker volume ls -q -f name=postgisdataf62ba0-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1))" ]; then \
		docker volume rm postgisdataf62ba0-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1); \
	else \
		echo "No such volume to remove    : postgisdataf62ba0-$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)"; \
	fi
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call clean-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))

# docker rm $(docker ps -a -f name=changedetection.io -q)
# --------------------------------------------------
all: check_variant update build test

dockerlist:
	docker images | grep "${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}" || true

update:
	@echo '::Updating Dockerfiles'
	$(DOCKER) pull buildpack-deps
	$(DOCKER) run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

check-gh-rate:
	@echo 'Checking github ratelimit ...'
	@curl -sI https://api.github.com/users/octocat | grep x-ratelimit

check_version:
	@echo "ENABLE_IMAGE_ARCH=$(ENABLE_IMAGE_ARCH)"
	@echo "ENABLE_IMAGE_VERSION_ID=$(ENABLE_IMAGE_VERSION_ID)"
	@echo "IMAGE_ARCH=$(IMAGE_ARCH)"
	@echo "IMAGE_VERSION_ID=$(IMAGE_VERSION_ID)"

# Rule to run shellcheck on all .sh files in the current directory, subdirectories, and sub-subdirectories.
lint:
	shellcheck *.sh ./*/*.sh ./*/*/*.sh ./*/*/*/*.sh -x

shfmt:
	shfmt -i 4 -w *.sh
	shfmt -i 4 -w ./tools/*.sh
	shfmt -i 4 -w ./test/*.sh
	shfmt -i 4 -w ./test/tests/*/*.sh

lregistryinfo:
	echo " ---- Registry info ---- "
	curl --location --silent --request GET "http://localhost:5000/v2/_catalog?page=1" | jq '.'
	curl --location --silent --request GET "http://localhost:5000/v2/${REPO_NAME}/${IMAGE_NAME}/tags/list?page=1" | jq '.'

# Remove all local images with the name localhost:5000/ and librarytest
# In a Makefile, the $ character has a special meaning, so you indeed need to escape it by using $$ instead of a single $.
imageclean:
	docker image ls | grep "^librarytest"     | awk '{print $$3}' | sort -u | xargs -rt docker rmi -f
	docker image ls | grep "^localhost:5000/" | awk '{print $$3}' | sort -u | xargs -rt docker rmi -f

imageclean_${REPO_NAME}_${IMAGE_NAME}:
	docker image ls | grep "^${REPO_NAME}/${IMAGE_NAME}" | awk '{print $$3}' | sort -u | xargs -rt docker rmi -f

# Help target
help: check_variant
	@echo ' Available make targets:'
	@echo '------------------------------------ '
	@echo 'build        : Build the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' build-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' build-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo 'test         : Test the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' test-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' test-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo 'push         : Push to the registry the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' push-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' push-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo 'manifest     : Manifest registry the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' manifest-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' manifest-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo '              [[ Start the docker image ]]'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' start-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '              [[ Stop the docker image ]]'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' stop-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '              [[ psql exec the docker image ]]'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' psql-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '              [[ clean docker image and volume ]]'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' clean-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo 'all          : Local run: "update" "build" "test" (without push)'
	@echo 'check_version: Check the architecture and version id'
	@echo 'check-gh-rate: Check the github ratelimit'
	@echo 'dockerlist   : List the docker images'
	@echo 'help         : This help file'
	@echo 'imageclean   : Remove all local images with the name localhost:5000/ and librarytest'
	@echo 'imageclean_${REPO_NAME}_${IMAGE_NAME} : Remove all local images with the name ${REPO_NAME}/${IMAGE_NAME}'
	@echo 'lint         : Run shellcheck on all .sh files'
	@echo 'push-readme  : Push README.md to Dockerhub'
	@echo 'shfmt        : Format the shell scripts'
	@echo 'test-prepare : Clone official-images repository'
	@echo 'update       : Generate/Update all Dockerfiles'
	@echo '------------------------------------ '
	@echo 'You can check the the command without executing: make -n <target> '
	@echo ' '

.PHONY: help build all update test-prepare test push push-readme manifest \
        check-gh-rate check_version dockerlist lint imageclean imageclean_${REPO_NAME}_${IMAGE_NAME} \
	$(foreach version,$(VERSIONS),' build-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),' build-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach version,$(VERSIONS),' test-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),' test-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach version,$(VERSIONS),' push-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  push-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach version,$(VERSIONS),' manifest-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  manifest-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),' start-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  stop-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  psql-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),' clean-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')

