IMAGE=codeship/migrate
DCR=docker-compose run --rm
.PHONY: clean test build release docker-build docker-push run

GOLANGCI_LINT :=
GOLANGCI_LINT_OPTS ?=
GOLANGCI_LINT_VERSION ?= v1.62.0
# golangci-lint only supports linux, darwin and windows platforms on i386/amd64.
# windows isn't included here because of the path separator being different.
ifeq ($(GOHOSTOS),$(filter $(GOHOSTOS),linux darwin))
	ifeq ($(GOHOSTARCH),$(filter $(GOHOSTARCH),amd64 i386))
		GOLANGCI_LINT := $(GOPATH)/bin/golangci-lint
	endif
endif

all: release

deps:
	dep ensure
	dep prune

clean:
	rm -f migrate

ifdef GOLANGCI_LINT
$(GOLANGCI_LINT):
	mkdir -p $(GOPATH)/bin
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/$(GOLANGCI_LINT_VERSION)/install.sh \
		| sed -e '/install -d/d' \
		| sh -s -- -b $(GOPATH)/bin $(GOLANGCI_LINT_VERSION)
endif

lint: $(GOLANGCI_LINT)
	@echo "--> Running golangci-lint"
	golangci-lint run

test:
	$(DCR) go-test

build:
	$(DCR) go-build

release: test build docker-build docker-push

docker-build:
	docker build --rm -t $(IMAGE) .

docker-push:
	docker push $(IMAGE)
