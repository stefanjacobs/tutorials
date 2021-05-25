docker-build:
	docker build . -t nginx-demo

docker-run:
	docker docker run -p 80:80 nginx-demo

local-nc-server:
	/usr/bin/nc -k -l 8000

docker-push-local-registry:
	docker build . -t 192.168.64.5:32000/nginx-demo:latest
