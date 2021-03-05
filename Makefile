IMAGE=codeship/migrate
DCR=docker-compose run --rm
.PHONY: clean test build release docker-build docker-push run

all: release

deps:
	dep ensure
	dep prune

clean:
	rm -f migrate

test:
	$(DCR) go-test

build:
	$(DCR) go-build

release: test build docker-build docker-push

docker-build:
	docker build --rm -t $(IMAGE) .

docker-push:
	docker push $(IMAGE)
