DOCKER_REPO ?= gcr.io/online-bridge-hackathon-2020
VERSION ?= $(shell cat VERSION)
DOCKER_TAG=${DOCKER_REPO}/deal-api:${VERSION}

EXTERNAL_ADDRES ?= deal.hackathon.globalbridge.app

DDS_K8S_NS ?= deal-api
GCP_PROJECT ?= online-bridge-hackathon-2020
GKE_CLUSTER_NAME ?= hackathon-cluster
GKE_ZONE ?= europe-west3-b

release: build push

build:
	docker build -t ${DOCKER_TAG} .

push:
	docker push ${DOCKER_TAG}

deploy: set_gcp_context ensure_ns
	helm upgrade --install deal-api ./chart \
		--set image="${DOCKER_TAG}" \
		--set externalHostname="${EXTERNAL_ADDRES}" \
		--namespace ${DDS_K8S_NS} \
		--history-max=10

uninstall: set_gcp_context
	helm del deal-api --namespace ${DDS_K8S_NS}

set_gcp_context:
	gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GCP_PROJECT}

ensure_ns:
	kubectl create ns ${DDS_K8S_NS} || :
