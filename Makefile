# Variables
IMAGE_NAME := custom-linux-base-ansible
DOCKERFILE := molecule/default/Dockerfile
ANSIBLE_HOME := $(CURDIR)/.ansible
XDG_CACHE_HOME := $(CURDIR)/.cache
MOLECULE_ENV := ANSIBLE_HOME="$(ANSIBLE_HOME)" XDG_CACHE_HOME="$(XDG_CACHE_HOME)"
MOLECULE_GLOB_PODMAN := molecule/default/molecule.yml
MOLECULE_GLOB_DOCKER := molecule/docker/molecule.yml

.PHONY: all build reset test test-podman test-docker syntax-podman syntax-docker idempotence-podman idempotence-docker check-podman-deps check-docker-deps clean

all: build reset test clean

build:
	@echo "🔨 Building Podman image from $(DOCKERFILE)..."
	podman build -f $(DOCKERFILE) -t $(IMAGE_NAME)
	@echo "✅ Image $(IMAGE_NAME) built successfully."

reset:
	@echo "♻️ Resetting Molecule state..."
	$(MOLECULE_ENV) molecule reset || echo "⚠️ Molecule reset failed or not needed."

test: check-podman-deps
	@echo "🚀 Running Molecule tests (podman/default)..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule test -s default
	@echo "✅ Molecule tests completed successfully."

test-podman: check-podman-deps
	@echo "🚀 Running Molecule tests..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule test -s default
	@echo "✅ Molecule podman tests completed successfully."

test-docker: check-docker-deps
	@echo "🚀 Running Molecule tests..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_DOCKER)" molecule test -s docker
	@echo "✅ Molecule tests completed successfully."

syntax-podman: check-podman-deps
	@echo "🔍 Running Molecule syntax check (podman/default)..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule syntax -s default
	@echo "✅ Molecule podman syntax check completed successfully."

syntax-docker: check-docker-deps
	@echo "🔍 Running Molecule syntax check (docker)..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_DOCKER)" molecule syntax -s docker
	@echo "✅ Molecule docker syntax check completed successfully."

idempotence-podman: check-podman-deps
	@echo "🔁 Running Molecule idempotence check (podman/default)..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule create -s default
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule converge -s default
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule idempotence -s default
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_PODMAN)" molecule destroy -s default
	@echo "✅ Idempotence verified."

idempotence-docker: check-docker-deps
	@echo "🔁 Running Molecule idempotence check (docker)..."
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_DOCKER)" molecule create -s docker
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_DOCKER)" molecule converge -s docker
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_DOCKER)" molecule idempotence -s docker
	$(MOLECULE_ENV) MOLECULE_GLOB="$(MOLECULE_GLOB_DOCKER)" molecule destroy -s docker
	@echo "✅ Idempotence verified."

check-podman-deps:
	@command -v podman >/dev/null 2>&1 || { \
		echo "❌ Missing podman binary."; \
		echo "   Install with: brew install podman"; \
		exit 1; \
	}
	@python3 -m pip show molecule-podman >/dev/null 2>&1 || { \
		echo "❌ Missing molecule-podman driver plugin."; \
		echo "   Install with: python3 -m pip install molecule-podman"; \
		exit 1; \
	}

check-docker-deps:
	@command -v docker >/dev/null 2>&1 || { \
		echo "❌ Missing docker CLI."; \
		echo "   Install Docker Desktop or docker engine."; \
		exit 1; \
	}
	@python3 -m pip show molecule-docker >/dev/null 2>&1 || { \
		echo "❌ Missing molecule-docker driver plugin."; \
		echo "   Install with: python3 -m pip install molecule-docker"; \
		exit 1; \
	}

clean:
	@echo "🧹 Cleaning up Podman image $(IMAGE_NAME)..."
	@if podman images | grep -q $(IMAGE_NAME); then \
		podman rmi $(IMAGE_NAME) || echo "⚠️ Failed to remove image $(IMAGE_NAME), continuing..."; \
		echo "🗑️ Image $(IMAGE_NAME) removed."; \
	else \
		echo "ℹ️ Image $(IMAGE_NAME) not found, skipping removal."; \
	fi
	@echo "🎉 Cleanup complete."
