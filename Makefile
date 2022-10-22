#include .env if exists
-include .env


GOPATH?=$(HOME)/go
FIRST_GOPATH:=$(firstword $(subst :, ,$(GOPATH)))
GOBIN:=$(FIRST_GOPATH)/bin
GIT_TAG:=$(shell git describe --exact-match --abbrev=0 --tags 2> /dev/null)
GIT_HASH:=$(shell git rev-parse --short HEAD 2> /dev/null)
GIT_LOG:=$(shell git log --decorate --oneline -n1 2> /dev/null | base64 | tr -d '\n')
GIT_BRANCH:=$(if $(DRONE_BRANCH),$(DRONE_BRANCH),$(shell git symbolic-ref -q --short HEAD 2> /dev/null ))
GO_VERSION:=$(shell go version)
GO_VERSION_SHORT:=$(shell echo $(GO_VERSION)|sed -E 's/.* go(.*) .*/\1/g')
BUILD_TS:=$(shell date +%FT%T%z)

# App version is git branch or commit.
APP_VERSION:=$(if $(GIT_TAG),$(GIT_TAG),$(if $(GIT_BRANCH),$(GIT_BRANCH),$(GIT_HASH)))

LDFLAGS:=-X 'main.Name=go-platground-dynamodb'\
         -X 'main.Version=$(APP_VERSION)'\
         -X 'main.GoVersion=$(GO_VERSION_SHORT)'\
         -X 'main.BuildDate=$(BUILD_TS)'\
         -X 'main.GitTag=$(GIT_TAG)'\
         -X 'main.GitLog=$(GIT_LOG)'\
         -X 'main.GitHash=$(GIT_HASH)'\
         -X 'main.GitBranch=$(GIT_BRANCH)'

BUILD_ENVPARMS:=GOGC=off CGO_ENABLED=0

LOCAL_BIN:=$(CURDIR)/bin
GOLANGCI_BIN:=$(LOCAL_BIN)/golangci-lint


# default target: test and build
.PHONY: all
all: test build

.PHONY: test
test:
	$(info #Running tests...)
	go test -race -parallel 10 ./...

.PHONY: test-with-coverage
test-with-coverage:
	$(info #Running tests with coverage...)
	go test -race -parallel 10 ./... -coverprofile=./coverage.out

.PHONY: build
build:
	$(info #Building...)
	$(BUILD_ENVPARMS) go build -ldflags "$(LDFLAGS)" -o $(LOCAL_BIN)/go-playground-dynamodb ./cmd/go-playground-dynamodb

.PHONY: run
run:
	$(info #Running...)
	$(BUILD_ENVPARMS) go run -ldflags "$(LDFLAGS)" ./cmd/go-playground-dynamodb

# install golangci-lint binary
.PHONY: install-golangci-lint
install-golangci-lint:
ifeq ($(wildcard $(GOLANGCI_BIN)),)
	$(info #Installing golangci-lint to $(GOLANGCI_BIN))
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(LOCAL_BIN) latest
endif

# force install golangci-lint binary
.PHONY: update-golangci-lint
update-golangci-lint:
	$(info #Updating golangci-lint to $(GOLANGCI_BIN))
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(LOCAL_BIN) latest

# run diff golangci-lint
.PHONY: lint
lint: install-golangci-lint
	$(info #Running golangci-lint...)
	$(GOLANGCI_BIN) run --new-from-rev=origin/main --timeout=3m --config=.golangci.yaml ./...

# run fix golangci-lint
.PHONY: lint-fix
lint-fix: install-golangci-lint
	$(info #Running golangci-lint-fix...)
	$(GOLANGCI_BIN) run --new-from-rev=origin/main --timeout=3m --config=.golangci.yaml --fix ./...

# run full golangci-lint
.PHONY: lint-full
lint-full: install-golangci-lint
	$(info #Running golangci-lint-full...)
	$(GOLANGCI_BIN) run --timeout=3m --config=.golangci.yaml ./...

# prepare dev environment
.PHONY: prepare-dev
prepare-dev:
	./scripts/dev/prepare-env.bash

# clean dev environment
.PHONY: clean-dev
clean-dev:
	./scripts/dev/clean-env.bash