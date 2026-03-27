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

.PHONY: versioncheck-uv
versioncheck-uv:
	@curl -s https://api.github.com/repos/astral-sh/uv/releases/latest | jq -r '.tag_name'

.PHONY: versioncheck-pre-commit
versioncheck-pre-commit:
	@curl -s https://api.github.com/repos/pre-commit/pre-commit/releases/latest | jq -r '.tag_name'

.PHONY: versioncheck-opentofu
versioncheck-opentofu:
	@curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r '.tag_name'

.PHONY: versioncheck-terragrunt
versioncheck-terragrunt:
	@curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r '.tag_name'

.PHONY: versioncheck-azurecli
versioncheck-azurecli:
	@curl -s https://api.github.com/repos/Azure/azure-cli/releases/latest | jq -r '.tag_name'

.PHONY: versioncheck-awscli
versioncheck-awscli:
	@curl -s "https://api.github.com/repos/aws/aws-cli/tags?per_page=100" | jq -r '[.[] | select(.name | test("^2[.][0-9]+[.][0-9]+$$"))][0].name'

.PHONY: versioncheck
versioncheck:
	@printf "%-20s %s\n" "uv:"         "$$($(MAKE) --no-print-directory versioncheck-uv)"
	@printf "%-20s %s\n" "pre-commit:" "$$($(MAKE) --no-print-directory versioncheck-pre-commit)"
	@printf "%-20s %s\n" "opentofu:"   "$$($(MAKE) --no-print-directory versioncheck-opentofu)"
	@printf "%-20s %s\n" "terragrunt:" "$$($(MAKE) --no-print-directory versioncheck-terragrunt)"
	@printf "%-20s %s\n" "azure-cli:"  "$$($(MAKE) --no-print-directory versioncheck-azurecli)"
	@printf "%-20s %s\n" "aws-cli:"    "$$($(MAKE) --no-print-directory versioncheck-awscli)"
