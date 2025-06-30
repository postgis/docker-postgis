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
ifeq ($(shell git rev-parse --git-dir 2>/dev/null),)
$(warning Warning: Not in a git repository. Using fallback values for IMAGE_VERSION_ID.)
COMMIT_DATE=00000000
COMMIT_HASH=00000000
else
COMMIT_DATE=$(shell git log -1 --format='%cd' --date=format:'%Y%m%d')
COMMIT_HASH=$(shell git log -1 --pretty=format:'%h')
endif
BUILD_WEEK=$(shell date '+%Yw%V')
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
VERSIONS := $(sort $(foreach dir,$(DOCKERFILE_DIRS),$(firstword $(subst /, ,$(dir)))))
VARIANTS := $(sort $(foreach dir,$(DOCKERFILE_DIRS),$(lastword $(subst /, ,$(dir)))))

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
		manifest-tool \
          $(if $(findstring localhost,$(REGISTRY)),--insecure --plain-http) \
	      push from-args \
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


#----------------------------------------------------------
define scan-target
scan-$(1)-$(2):
	$(DOCKER) run \
	  --pull always --rm -v $$(pwd)/trivy_cache:/root/.cache/ \
	  ghcr.io/aquasecurity/trivy:latest image --ignore-unfixed \
	  $(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call scan-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))
# --------------------------------------------------

#----------------------------------------------------------
define dive-target
dive-$(1)-$(2):
	CI=true tools/dive \
	$(REGISTRY)/$(REPO_NAME)/$(IMAGE_NAME):$(shell cat $(1)/$(2)/tags | cut -d' ' -f1)
endef
$(foreach dir,$(DOCKERFILE_DIRS),$(eval $(call dive-target,$(word 1,$(subst /, ,$(dir))),$(word 2,$(subst /, ,$(dir))))))
# --------------------------------------------------


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
	docker images | grep "${REPO_NAME}/${IMAGE_NAME}" || true

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

# Add new PostgreSQL version support
# Usage: make add-postgres-version PG_VERSION=19 POSTGIS_VERSION=3.5 TYPE=master
# TYPE options: master (latest debian), postgis (all debian+alpine variants), bundle (latest debian)
add-postgres-version:
	@if [ -z "$(PG_VERSION)" ]; then \
		echo "Error: PG_VERSION is required."; \
		echo "Usage: make add-postgres-version PG_VERSION=19 POSTGIS_VERSION=3.5 TYPE=master"; \
		echo "  TYPE options: master (latest debian), postgis (all debian+alpine), bundle (latest debian)"; \
		exit 1; \
	fi
	@if [ -z "$(POSTGIS_VERSION)" ]; then \
		echo "Error: POSTGIS_VERSION is required."; \
		echo "Usage: make add-postgres-version PG_VERSION=19 POSTGIS_VERSION=3.5 TYPE=master"; \
		echo "  TYPE options: master (latest debian), postgis (all debian+alpine), bundle (latest debian)"; \
		exit 1; \
	fi
	@if [ -z "$(TYPE)" ]; then \
		echo "Error: TYPE is required."; \
		echo "Usage: make add-postgres-version PG_VERSION=19 POSTGIS_VERSION=3.5 TYPE=master"; \
		echo "  TYPE options: master (latest debian), postgis (all debian+alpine), bundle (latest debian)"; \
		exit 1; \
	fi
	@echo "Adding PostgreSQL $(PG_VERSION) with PostGIS $(POSTGIS_VERSION) support ($(TYPE) type)..."
	@echo "Step 1: Adding $(PG_VERSION) to tools/versions.sh postgres_versions"
	@if ! grep -q " $(PG_VERSION)" tools/versions.sh; then \
		sed -i 's/postgres_versions="\([^"]*\)"/postgres_versions="\1 $(PG_VERSION)"/' tools/versions.sh; \
		echo "  Added $(PG_VERSION) to postgres_versions"; \
	else \
		echo "  $(PG_VERSION) already exists in postgres_versions"; \
	fi
	@echo "Step 2: Creating directory structure based on type $(TYPE)"
	@DEBIAN_VARIANTS=$$(grep '^debian_variants=' tools/versions.sh | cut -d'"' -f2 | xargs); \
	ALPINE_VARIANTS=$$(grep '^alpine_variants=' tools/versions.sh | cut -d'"' -f2 | xargs); \
	DEBIAN_LATEST=$$(grep '^debian_latest=' tools/versions.sh | cut -d'"' -f2); \
	if [ "$(TYPE)" = "master" ]; then \
		echo "  Creating master variant ($$DEBIAN_LATEST only)"; \
		mkdir -p $(PG_VERSION)-master/$$DEBIAN_LATEST; \
		touch $(PG_VERSION)-master/$$DEBIAN_LATEST/Dockerfile; \
	elif [ "$(TYPE)" = "postgis" ]; then \
		echo "  Creating PostGIS variant (all debian + alpine variants)"; \
		for variant in $$DEBIAN_VARIANTS $$ALPINE_VARIANTS; do \
			echo "    Creating $(PG_VERSION)-$(POSTGIS_VERSION)/$$variant"; \
			mkdir -p $(PG_VERSION)-$(POSTGIS_VERSION)/$$variant; \
			touch $(PG_VERSION)-$(POSTGIS_VERSION)/$$variant/Dockerfile; \
		done; \
	elif [ "$(TYPE)" = "bundle" ]; then \
		echo "  Creating bundle variant ($$DEBIAN_LATEST only)"; \
		mkdir -p $(PG_VERSION)-$(POSTGIS_VERSION)-bundle0/$$DEBIAN_LATEST; \
		touch $(PG_VERSION)-$(POSTGIS_VERSION)-bundle0/$$DEBIAN_LATEST/Dockerfile; \
	else \
		echo "Error: Invalid TYPE. Must be master, postgis, or bundle"; \
		exit 1; \
	fi
	@echo "Step 3: Adding configuration to locked.yml"
	@if [ "$(TYPE)" = "master" ]; then \
		echo "" >> locked.yml; \
		echo "'$(PG_VERSION)-master':" >> locked.yml; \
		echo "  'bookworm':" >> locked.yml; \
		echo "    _comment: \"source: ./locked.yml - PostgreSQL $(PG_VERSION) master testing\"" >> locked.yml; \
		echo "    tags: '$(PG_VERSION)-master-bookworm $(PG_VERSION)-master'" >> locked.yml; \
		echo "    postgis: 'master'" >> locked.yml; \
		echo "    readme_group: 'test'" >> locked.yml; \
		echo "    PG_MAJOR: '$(PG_VERSION)'" >> locked.yml; \
		echo "    PG_DOCKER: '$(PG_VERSION)beta1'" >> locked.yml; \
		echo "    arch: 'amd64 arm64'" >> locked.yml; \
		echo "    template: 'Dockerfile.master.template'" >> locked.yml; \
		echo "    initfile: 'initdb-postgis.sh'" >> locked.yml; \
		echo "    POSTGIS_CHECKOUT: 'master'" >> locked.yml; \
		echo "    POSTGIS_CHECKOUT_SHA1: 'nocheck'" >> locked.yml; \
		echo "    CGAL_CHECKOUT: 'master'" >> locked.yml; \
		echo "    CGAL_CHECKOUT_SHA1: 'nocheck'" >> locked.yml; \
		echo "    SFCGAL_CHECKOUT: 'master'" >> locked.yml; \
		echo "    SFCGAL_CHECKOUT_SHA1: 'nocheck'" >> locked.yml; \
		echo "    PROJ_CHECKOUT: 'master'" >> locked.yml; \
		echo "    PROJ_CHECKOUT_SHA1: 'nocheck'" >> locked.yml; \
		echo "    GDAL_BUILD: 'with_extra'" >> locked.yml; \
		echo "    GDAL_CHECKOUT: 'master'" >> locked.yml; \
		echo "    GDAL_CHECKOUT_SHA1: 'nocheck'" >> locked.yml; \
		echo "    GEOS_CHECKOUT: 'main'" >> locked.yml; \
		echo "    GEOS_CHECKOUT_SHA1: 'nocheck'" >> locked.yml; \
		echo "    BOOST_VERSION: '1.74.0'" >> locked.yml; \
		echo "  Added $(PG_VERSION)-master configuration to locked.yml"; \
	else \
		echo "  For PostGIS/bundle variants, configuration will be auto-generated by update.sh"; \
	fi
	@echo "Step 4: Adding optional pg_hint_plan support to tools/versions.sh"
	@if ! grep -q "get_latest_version_and_hash_optional.*REL$(PG_VERSION)" tools/versions.sh; then \
		sed -i '/get_latest_version_and_hash_optional.*REL18/a get_latest_version_and_hash_optional "https://github.com/ossc-db/pg_hint_plan" "pg_hint_plan" releases REL$(PG_VERSION) ""' tools/versions.sh; \
		echo "  Added REL$(PG_VERSION) pg_hint_plan support"; \
	else \
		echo "  REL$(PG_VERSION) pg_hint_plan support already exists"; \
	fi
	@echo ""
	@echo "✅ Successfully created PostgreSQL $(PG_VERSION) directory structure!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run update script:  ./update.sh"
	@if [ "$(TYPE)" = "master" ]; then \
		echo "  2. Build the image:    make build-$(PG_VERSION)-master-bookworm"; \
		echo "  3. Test the image:     make test-$(PG_VERSION)-master-bookworm"; \
		echo "  4. Start container:    make start-$(PG_VERSION)-master-bookworm"; \
		echo "  5. Connect to DB:      make psql-$(PG_VERSION)-master-bookworm"; \
	elif [ "$(TYPE)" = "postgis" ]; then \
		echo "  2. Build all variants: make build-$(PG_VERSION)-$(POSTGIS_VERSION)"; \
		echo "  3. Test all variants:  make test-$(PG_VERSION)-$(POSTGIS_VERSION)"; \
	elif [ "$(TYPE)" = "bundle" ]; then \
		echo "  2. Build the bundle:   make build-$(PG_VERSION)-$(POSTGIS_VERSION)-bundle0-bookworm"; \
		echo "  3. Test the bundle:    make test-$(PG_VERSION)-$(POSTGIS_VERSION)-bundle0-bookworm"; \
	fi
	@echo ""
	@echo "Created directories:"
	@DEBIAN_VARIANTS=$$(grep '^debian_variants=' tools/versions.sh | cut -d'"' -f2 | xargs); \
	ALPINE_VARIANTS=$$(grep '^alpine_variants=' tools/versions.sh | cut -d'"' -f2 | xargs); \
	DEBIAN_LATEST=$$(grep '^debian_latest=' tools/versions.sh | cut -d'"' -f2); \
	if [ "$(TYPE)" = "master" ]; then \
		echo "  - $(PG_VERSION)-master/$$DEBIAN_LATEST/"; \
	elif [ "$(TYPE)" = "postgis" ]; then \
		for variant in $$DEBIAN_VARIANTS $$ALPINE_VARIANTS; do \
			echo "  - $(PG_VERSION)-$(POSTGIS_VERSION)/$$variant/"; \
		done; \
	elif [ "$(TYPE)" = "bundle" ]; then \
		echo "  - $(PG_VERSION)-$(POSTGIS_VERSION)-bundle0/$$DEBIAN_LATEST/"; \
	fi
	@echo ""
	@echo "Modified files:"
	@echo "  - tools/versions.sh (postgres_versions and pg_hint_plan)"
	@if [ "$(TYPE)" = "master" ]; then \
		echo "  - locked.yml (added $(PG_VERSION)-master configuration)"; \
	fi
	@echo ""
	@echo "Note: versions.json will be auto-generated when you run ./update.sh"

# Help target
help: check_variant
	@echo ' Available make targets:'
	@echo '------------------------------------ '
	@echo '# build        : Build the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' build-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' build-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo '# test         : Test the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' test-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' test-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo '# push         : Push to the registry the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' push-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' push-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo '# manifest     : Manifest registry the docker image versions and variants'
	@echo $(foreach version,$(VERSIONS),' manifest-$(version)')
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' manifest-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo '# Scan the docker image, using aquasec/trivy'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' scan-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '# Dive the docker image, using wagoodman/dive'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' dive-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '# Start the docker image'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' start-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '# Stop the docker image'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' stop-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '# psql exec the docker image'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' psql-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo '# clean docker image and volume'
	@echo $(foreach dir,$(DOCKERFILE_DIRS),' clean-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')
	@echo ' '
	@echo 'add-postgres-version PG_VERSION=X PG_DOCKER_TAG=Y : Add new PostgreSQL version support'
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

.PHONY: help build all update test-prepare test push push-readme manifest add-postgres-version \
        check-gh-rate check_version dockerlist lint imageclean imageclean_${REPO_NAME}_${IMAGE_NAME} \
	$(foreach version,$(VERSIONS),' build-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),' build-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach version,$(VERSIONS),' test-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),' test-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach version,$(VERSIONS),' push-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  push-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach version,$(VERSIONS),' manifest-$(version)') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  manifest-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  scan-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  dive-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),' start-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  stop-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),'  psql-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))') \
	$(foreach dir,$(DOCKERFILE_DIRS),' clean-$(word 1,$(subst /, ,$(dir)))-$(word 2,$(subst /, ,$(dir)))')

