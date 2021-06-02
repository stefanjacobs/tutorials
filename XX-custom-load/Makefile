# run:
# 	go run main.go
# 
# local_nginx:
# 	go run main.go -url http://localhost:30726/health -timeout 30 -clientcount 10 -sleep 100
# 
load: main.go
	go build -o load main.go

build: load

sidecar-load: load
	./load -clientcount 5 -maxchar 20 -sleep 100 -timeout 5 -url http://hello-world-sidecar.${CLUSTER_HOSTNAME}/TestUser

