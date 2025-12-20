ARG BASE_IMAGE_VARIANT="alpine-3.21"
ARG UV_VERSION="0.9.13"
ARG OPENTOFU_VERSION="1.10.7"

FROM "ghcr.io/astral-sh/uv:${UV_VERSION}" AS uv
FROM "ghcr.io/opentofu/opentofu:${OPENTOFU_VERSION}-minimal" AS opentofu
FROM "mcr.microsoft.com/devcontainers/base:${BASE_IMAGE_VARIANT}" AS base


ARG TERRAGRUNT_VERSION="0.93.11"
ARG PRECOMMIT_VERSION="4.5.0"
ARG PRECOMMIT_VERSION="4.5.0"
ARG AZURECLI_VERSION="2.80.0"
ARG AWSCLI_VERSION="1.43.6"


RUN apk add --no-cache linux-headers

COPY --from=uv /uv /uvx /bin/
ENV UV_LINK_MODE=copy

COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu

RUN BINARY_NAME="terragrunt_linux_amd64" \
  && curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/$BINARY_NAME" -o "$BINARY_NAME" \
  && curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS" -o SHA256SUMS \
  && CHECKSUM="$(sha256sum "$BINARY_NAME" | awk '{print $1}')" \
  && EXPECTED_CHECKSUM="$(awk -v binary="$BINARY_NAME" '$2 == binary {print $1; exit}' SHA256SUMS)" \
  && ([[ $CHECKSUM == $EXPECTED_CHECKSUM ]] && echo "Checksums match." || ( echo "Checksums do not match!" && exit 203 ) ) \
  && rm SHA256SUMS \
  && chmod 755 $BINARY_NAME \
  && mv $BINARY_NAME /usr/local/bin/terragrunt

USER vscode
RUN echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc \
  && tofu -install-autocomplete \
  && terragrunt --install-autocomplete \
  && uv tool install pre-commit@${PRECOMMIT_VERSION} \
  && uv tool install azure-cli@${AZURECLI_VERSION} --prerelease=allow \
  && uv tool install awscli@${AWSCLI_VERSION}
