service-build:
	env GOOS=linux GOARCH=amd64 go build -o service/hello service/hello.go 

docker-build: service-build
	docker build service/ -t go-hello-world:latest -t ${REGISTRY}/go-hello-world:latest
	docker build sidecar/ -t go-hello-world-sidecar:latest -t ${REGISTRY}/go-hello-world-sidecar:latest

docker-push: docker-build
	docker push ${REGISTRY}/go-hello-world:latest
	docker push ${REGISTRY}/go-hello-world-sidecar:latest

kubernetes-apply: docker-push
	cp sidecar-template.yaml /tmp/sidecar.yaml
	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/sidecar.yaml
	kubectl apply -f /tmp/sidecar.yaml
	rm /tmp/sidecar.yaml

kubernetes-delete:
	cp sidecar-template.yaml /tmp/sidecar.yaml
	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/sidecar.yaml
	kubectl delete -f /tmp/sidecar.yaml
	rm /tmp/sidecar.yaml

clean:
	rm -f service/hello /tmp/05_deployment.yaml

simple-load:
	docker run --rm jordi/ab -c 33 -n 1000 http://hello-world-sidecar.${CLUSTER_HOSTNAME}/TestUser

scale-to-one:
	kubectl scale deployment hello-world-sidecar --replicas 1

scale-to-two:
	kubectl scale deployment hello-world-sidecar --replicas 2

scale-to-three:
	kubectl scale deployment hello-world-sidecar --replicas 3

scale-to-four:
	kubectl scale deployment hello-world-sidecar --replicas 4

scale-to-five:
	kubectl scale deployment hello-world-sidecar --replicas 5