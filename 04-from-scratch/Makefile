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
	kubectl apply -f deployment.yaml

kubernetes-delete:
	kubectl delete -f deployment.yaml


