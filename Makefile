build:
	docker build -t pw/crudservice:latest ./service/

run: build
	docker run -it --rm --name pwcrudservice -p 8000:8000 -v ./service.cfg:/app/service.cfg pw/crudservice:latest

deploy:
	bash deploy.sh