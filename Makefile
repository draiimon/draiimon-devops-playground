# ============================================================
# Makefile — DevOps Exam 2026
# Run `make help` to see all available commands
# ============================================================

DOCKER_USERNAME ?= your-dockerhub-username
API_IMAGE       := $(DOCKER_USERNAME)/api-app
UI_IMAGE        := $(DOCKER_USERNAME)/ui-app
TAG             := $(shell git rev-parse --short HEAD 2>/dev/null || echo latest)
NAMESPACE       := devops-exam

.DEFAULT_GOAL := help

# ---- Help -------------------------------------------------------
.PHONY: help
help:  ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

# ---- Docker -----------------------------------------------------
.PHONY: build push build-api build-ui

build: build-api build-ui  ## Build both Docker images

build-api:  ## Build API image
	docker build \
	  --label "org.opencontainers.image.revision=$(TAG)" \
	  --label "org.opencontainers.image.created=$(shell date -u +%Y-%m-%dT%H:%M:%SZ)" \
	  -t $(API_IMAGE):$(TAG) \
	  -t $(API_IMAGE):latest \
	  ./part2-docker/api

build-ui:  ## Build UI image
	docker build \
	  --label "org.opencontainers.image.revision=$(TAG)" \
	  --label "org.opencontainers.image.created=$(shell date -u +%Y-%m-%dT%H:%M:%SZ)" \
	  -t $(UI_IMAGE):$(TAG) \
	  -t $(UI_IMAGE):latest \
	  ./part2-docker/ui

push: build  ## Build and push both images to Docker Hub
	docker push $(API_IMAGE):$(TAG)
	docker push $(API_IMAGE):latest
	docker push $(UI_IMAGE):$(TAG)
	docker push $(UI_IMAGE):latest

# ---- Local dev --------------------------------------------------
.PHONY: up down logs ps

up:  ## Start all services with Docker Compose
	cd part2-docker && docker compose up --build -d

down:  ## Stop all services
	cd part2-docker && docker compose down

logs:  ## Tail all service logs
	cd part2-docker && docker compose logs -f

ps:  ## Show running containers
	cd part2-docker && docker compose ps

# ---- Linux scripts ----------------------------------------------
.PHONY: health backup analyze-logs

health:  ## Run system health check
	bash part1-linux/system_health.sh

backup:  ## Run backup script
	bash part1-linux/backup.sh

analyze-logs:  ## Run log analysis
	bash part1-linux/log_analysis.sh

# ---- Kubernetes / Minikube --------------------------------------
.PHONY: k8s-ns k8s-apply k8s-rollout port-forward

k8s-ns:  ## Create the Kubernetes namespace
	kubectl apply -f part4-ha/k8s/namespace.yaml

k8s-apply: k8s-ns  ## Apply the raw Kubernetes manifests
	kubectl apply -f part4-ha/k8s/

k8s-rollout:  ## Watch rollout status for both deployments
	kubectl rollout status deployment/api-app --namespace $(NAMESPACE)
	kubectl rollout status deployment/ui-app  --namespace $(NAMESPACE)

port-forward:  ## Forward ports for local testing (api:8000, ui:3000)
	kubectl port-forward svc/api-service 8000:80 --namespace $(NAMESPACE) &
	kubectl port-forward svc/ui-service  3000:80 --namespace $(NAMESPACE) &
	@echo "API: http://localhost:8000"
	@echo "UI:  http://localhost:3000"

# ---- Security ---------------------------------------------------
.PHONY: scan sbom sign

scan:  ## Scan images with Trivy (must have built images first)
	trivy image --severity CRITICAL,HIGH $(API_IMAGE):$(TAG)
	trivy image --severity CRITICAL,HIGH $(UI_IMAGE):$(TAG)

sbom:  ## Generate SBOM with Syft
	syft $(API_IMAGE):$(TAG) -o cyclonedx-json > sbom-api.json
	syft $(UI_IMAGE):$(TAG) -o cyclonedx-json > sbom-ui.json
	@echo "SBOMs written to sbom-api.json and sbom-ui.json"

sign:  ## Sign images with Cosign (keyless via OIDC)
	cosign sign --yes $(API_IMAGE):$(TAG)
	cosign sign --yes $(UI_IMAGE):$(TAG)

# ---- Minikube ---------------------------------------------------
.PHONY: minikube-up minikube-hosts

minikube-up:  ## Start Minikube with ingress and metrics-server
	minikube start --nodes 2 --driver=docker --cpus=2 --memory=1800mb
	minikube addons enable ingress
	minikube addons enable metrics-server

minikube-hosts:  ## Add Minikube IP to /etc/hosts
	@echo "$$(minikube ip)  api.myapp.local ui.myapp.local" | sudo tee -a /etc/hosts
	@echo "Added to /etc/hosts"

# ---- Lint & Validate --------------------------------------------
.PHONY: lint validate

validate:  ## Validate k8s manifests with kubeval
	kubeval part4-ha/k8s/*.yaml

# ---- Clean ------------------------------------------------------
.PHONY: clean

clean:  ## Remove local Docker images
	docker rmi $(API_IMAGE):$(TAG) $(API_IMAGE):latest 2>/dev/null || true
	docker rmi $(UI_IMAGE):$(TAG) $(UI_IMAGE):latest 2>/dev/null || true
