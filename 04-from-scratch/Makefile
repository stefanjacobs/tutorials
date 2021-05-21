go-run:
	go run hello.go

go-build:
	env GOOS=linux GOARCH=amd64 go build hello.go

docker-build: go-build
	docker build . -t go-hello-world:latest 

docker-run: docker-build
	docker run -it -p 8080:8080 go-hello-world:latest

docker-push: go-build
	docker build . -t go-hello-world:latest -t ${CLUSTER_HOSTNAME}/go-hello-world:latest
	docker push registry-${CLUSTER_HOSTNAME}/go-hello-world:latest

kubernetes-apply: docker-push
	cp deployment-template.yaml /tmp/deployment.yaml
	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/deployment.yaml
	kubectl apply -f /tmp/deployment.yaml
	rm /tmp/deployment.yaml

kubernetes-delete:
	cp deployment-template.yaml /tmp/deployment.yaml
	sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" /tmp/deployment.yaml
	kubectl delete -f deployment.yaml
	rm /tmp/deployment.yaml


