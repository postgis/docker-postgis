VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))

all: build

build: $(VERSIONS)

define postgis-version
$1:
	docker build -t mdillon/postgis:$(shell echo $1 | sed -e 's/\//-/g') $1
endef
$(foreach version,$(VERSIONS),$(eval $(call postgis-version,$(version))))

update:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

.PHONY: all build update $(VERSIONS)
