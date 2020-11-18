build:
	docker build \
	  --build-arg "BUILD_CUDA_VERSION=11.0" \
	  --build-arg "BUILD_CUNND_VERSION=8" \
	  --build-arg "BUILD_PYTORCH_VERSION=1.7.0" \
	  --build-arg "BUILD_TORCHAUDIO=0.7.0" \
	  -t wekaco/${shell basename "${PWD}" }:${shell git rev-parse --abbrev-ref HEAD | tr '/' '_'} -f ./Dockerfile .

dev:
	docker run -v $(shell pwd):/app --rm -ti wekaco/${shell basename "${PWD}" }:${shell git rev-parse --abbrev-ref HEAD | tr '/' '_'}

push-latest:
	docker tag wekaco/${shell basename "${PWD}" }:${shell git rev-parse --abbrev-ref HEAD | tr '/' '_'} wekaco/${shell basename "${PWD}" }:latest
	docker push wekaco/${shell basename "${PWD}" }:latest
