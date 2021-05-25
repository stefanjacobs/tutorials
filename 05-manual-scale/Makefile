go-run:
	go run hello.go

go-build:
	env GOOS=linux GOARCH=amd64 go build hello.go

docker-build: go-build
	docker build . -t go-hello-world:latest 

docker-run: docker-build
	docker run -it -p 8080:8080 go-hello-world:latest

docker-push: docker-build
	docker build . -t go-hello-world:latest -t ${REGISTRY}/go-hello-world:latest
	docker push ${REGISTRY}/go-hello-world:latest

kubernetes-apply: docker-push
	cp deployment-template.yaml /tmp/04_deployment.yaml
	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/04_deployment.yaml
	kubectl apply -f /tmp/04_deployment.yaml
	rm /tmp/04_deployment.yaml

kubernetes-delete:
	cp deployment-template.yaml /tmp/04_deployment.yaml
	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/04_deployment.yaml
	kubectl delete -f /tmp/04_deployment.yaml
	rm /tmp/04_deployment.yaml

clean:
	rm -f hello /tmp/04_deployment.yaml
