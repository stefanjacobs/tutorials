docker-run-ws:
	docker run -p 8080:8080 gcr.io/kubernetes-e2e-test-images/resource-consumer:1.5

docker-consume:
	curl --data "millicores=500&durationSec=600" http://192.168.64.7:8080/ConsumeCPU

k3s-patch-metrics:
	kubectl apply -f patch-metrics.yaml

k3s-apply:
	kubectl apply -f loadgen.yaml

k3s-delete:
	kubectl delete -f loadgen.yaml

k3s-delete-hpa:
	kubectl delete hpa loadgen

k3s-apply-newhpa:
	kubectl apply -f loadgen-newhpa.yaml

consume-50m:
	curl --data "millicores=50&durationSec=300" http://192-168-64-11.nip.io/ConsumeCPU

consume-100m:
	curl --data "millicores=100&durationSec=300" http://192-168-64-11.nip.io/ConsumeCPU

consume-150m:
	curl --data "millicores=150&durationSec=300" http://192-168-64-11.nip.io/ConsumeCPU

consume-200m:
	curl --data "millicores=200&durationSec=300" http://192-168-64-11.nip.io/ConsumeCPU
