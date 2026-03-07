.PHONY: all
all: build

.PHONY: build
build:
	docker build . --file Dockerfile --tag devcontainer-iac:local $(shell cat Dockerfile.args | xargs -I {} echo --build-arg {})

.PHONY: lint
lint:
	@tools/lint.sh

.PHONY: dive
dive:
	export CI=true
	dive build . --file Dockerfile --tag devcontainer-iac:local $(shell cat Dockerfile.args | xargs -I {} echo --build-arg {})

.PHONY: dive-ci
dive-ci:
	dive devcontainer-iac:local --ci --json dive.json
