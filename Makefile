export LATEST_RELEASE_VERSION=1.0.2
export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_BUILD_OPTS=--no-cache --compress
export DOCKER_MULTI_ARCH=linux/arm,linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/386

build-client:
	docker build ${DOCKER_BUILD_OPTS} -t "rogelioo/ddns-aws-client:${LATEST_RELEASE_VERSION}" -f ./client/Dockerfile ./client

multibuild-context-create:
	docker buildx create --name multibuilder
	 
multibuild-client:
	docker buildx use multibuilder
	docker buildx build ${DOCKER_BUILD_OPTS} -t "rogelioo/ddns-aws-client:${LATEST_RELEASE_VERSION}" --platform=${DOCKER_MULTI_ARCH} -f ./client/Dockerfile ./client --push
	docker buildx imagetools create docker.io/rogelioo/ddns-aws-client:${LATEST_RELEASE_VERSION} --tag rogelioo/ddns-aws-client:latest