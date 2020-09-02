.PHONY: build run
IMAGE_NAME := quay.io/rhscl/rhscl-container-ci
CUR_DIR = `pwd`
JENKINS_CMD :=
build:
	docker build --tag ${IMAGE_NAME} .

run:
	docker run \
	-v ${CUR_DIR}/:/home/rhscl-container-ci \
	-e JENKINS_CMD=${JENKINS_CMD} \
	${IMAGE_NAME}

