apply:
	kubectl apply -f sidecar-example.yaml

delete:
	kubectl delete -f sidecar-example.yaml

curl-api:
	curl http://192-168-64-11.nip.io:80/api/

scale-to-one:
	kubectl scale --replicas=1 deployment sidecar-example

scale-to-two:
	kubectl scale --replicas=2 deployment sidecar-example

scale-to-three:
	kubectl scale --replicas=3 deployment sidecar-example

docker-run-sidecar:
	docker run -it -p 80:80 --rm magalixcorp/nginxsidecar

docker-run-app:
	docker run -it -p 5000:5000 --rm magalixcorp/flasksidecar

load:
	docker run --rm jordi/ab -c 100 -n 100000 http://192-168-64-11.nip.io:80/api/
