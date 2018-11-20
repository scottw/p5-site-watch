build: VERSION=$(shell cat VERSION)
build:
	docker build -t scottw/site-watch:$(VERSION) -t scottw/site-watch:latest .
