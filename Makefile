build: VERSION=$(shell cat VERSION)
build:
	docker build -t scottw/site-watch:$(VERSION) -t scottw/site-watch:latest .

push: VERSION=$(shell cat VERSION)
push:
	docker push scottw/site-watch:$(VERSION)
	docker push scottw/site-watch:latest
