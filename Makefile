build-simple:
	docker build -f Simple.Dockerfile -t quay.io/bhaveshpatel/robo1:simple .

push-simple:
	docker push quay.io/bhaveshpatel/robo1:simple

run-simple:
	docker run --rm --name robo1 -p 8080:8080 quay.io/bhaveshpatel/robo1:simple

build-instana:
	docker build -f Instana.Dockerfile -t quay.io/bhaveshpatel/robo1:instana .

run-instana:
	docker run --rm --name robo1 -p 8080:8080 quay.io/bhaveshpatel/robo1:instana

push-instana:
	docker push quay.io/bhaveshpatel/robo1:instana

