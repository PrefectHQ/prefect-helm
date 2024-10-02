# Worker Variables
WORKER_CHART_NAME=prefect-worker
WORKER_CHART_PATH=./charts/prefect-worker
WORKER_RELEASE_NAME=prefect-worker
NAMESPACE=prefect
VALUES_FILE=./charts/prefect-worker/values.yaml
# Server Variables
SERVER_CHART_NAME=prefect-server
SERVER_CHART_PATH=./charts/prefect-server
SERVER_RELEASE_NAME=prefect-server
NAMESPACE=prefect
VALUES_FILE=./charts/prefect-server/values.yaml
# Prometheus Prefect Exporter Variables
PROMETHEUS_PREFECT_EXPORTER_CHART_NAME=prometheus-prefect-exporter
PROMETHEUS_PREFECT_EXPORTER_CHART_PATH=./charts/prometheus-prefect-exporter
WORKER_RELEASE_NAME=prefect-worker
NAMESPACE=prefect
VALUES_FILE=./charts/prometheus-prefect-exporter/values.yaml

.PHONY: all
all: tools

.PHONY: mise
mise:
	@mise install --yes

.git/hooks/pre-commit:
	@pre-commit install

.PHONY: tools
tools: mise .git/hooks/pre-commit

.PHONY: tools-list
tools-list:
	@mise list --current

.PHONY: helmbuildworker
helmbuildworker: ## Build Worker Helm dependencies
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm dependency build $(WORKER_CHART_PATH)

.PHONY: helmbuildserver
helmbuildserver: ## Build Server Helm dependencies
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm dependency build $(SERVER_CHART_PATH)

.PHONY: helmbuildprom
helmbuildprom: ## Build Prometheus Prefect Exporter Helm dependencies
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm dependency build $(PROMETHEUS_PREFECT_EXPORTER_CHART_PATH)

.PHONY: helmbuild
helmbuild: helmbuildworker helmbuildserver helmbuildprom

.PHONY: helmunittest
helmunittest: ## Run Helm unittest
	helm unittest $(WORKER_CHART_PATH)
	helm unittest $(SERVER_CHART_PATH)
	helm unittest $(PROMETHEUS_PREFECT_EXPORTER_CHART_PATH)
