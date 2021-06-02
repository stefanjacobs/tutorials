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

simple-load:
	docker run --rm jordi/ab -c 33 -n 1000 http://hello-${CLUSTER_HOSTNAME}/TestUser

scale-to-one:
	kubectl scale deployment hello-world  --replicas 1

scale-to-two:
	kubectl scale deployment hello-world  --replicas 2

scale-to-three:
	kubectl scale deployment hello-world  --replicas 3

scale-to-four:
	kubectl scale deployment hello-world  --replicas 4

scale-to-five:
	kubectl scale deployment hello-world  --replicas 5

clean:
	rm -f hello /tmp/04_deployment.yaml
