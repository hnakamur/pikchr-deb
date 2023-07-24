DOCKER_IMAGE_NAME=pikchr-deb
PIKCHR_DEB_VER=0.20230508.0-1hnakamur1ubuntu22.04
NO_CACHE=--no-cache

build:
	docker build $(NO_CACHE) --progress=plain -t $(DOCKER_IMAGE_NAME) . 2>&1 | tee pikchr_$(PIKCHR_DEB_VER)_amd64.build.log
	zstd --rm --force -19 pikchr_$(PIKCHR_DEB_VER)_amd64.build.log
	docker run --rm -v .:/dist --entrypoint=cp $(DOCKER_IMAGE_NAME) /work/install/pikchr_$(PIKCHR_DEB_VER)_amd64.deb /dist/

.PHONY: bulid
