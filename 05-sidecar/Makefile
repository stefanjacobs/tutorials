service-build:
	env GOOS=linux GOARCH=amd64 go build -o service/hello service/hello.go 

docker-build: service-build
	docker build service/ -t go-hello-world:latest -t ${REGISTRY}/go-hello-world:latest
	docker build sidecar/ -t go-hello-world-sidecar:latest -t ${REGISTRY}/go-hello-world-sidecar:latest

docker-push: docker-build
	docker push ${REGISTRY}/go-hello-world:latest
	docker push ${REGISTRY}/go-hello-world-sidecar:latest

kubernetes-apply: docker-push
	kubectl apply -f sidecar.yaml

kubernetes-delete:
	kubectl delete -f sidecar.yaml


# kubernetes-apply: docker-push
# 	cp deployment-template.yaml /tmp/04_deployment.yaml
# 	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/04_deployment.yaml
# 	kubectl apply -f /tmp/04_deployment.yaml
# 	rm /tmp/04_deployment.yaml

# kubernetes-delete:
# 	cp deployment-template.yaml /tmp/04_deployment.yaml
# 	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/04_deployment.yaml
# 	kubectl delete -f /tmp/04_deployment.yaml
# 	rm /tmp/04_deployment.yaml

clean:
	rm -f service/hello /tmp/05_deployment.yaml
