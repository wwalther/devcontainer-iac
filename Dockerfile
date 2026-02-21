ARG ALPINE_VERSION
ARG BUILDER_IMAGE_PYTHON_VERSION

ARG UV_VERSION
ARG PRECOMMIT_VERSION

ARG OPENTOFU_VERSION
ARG TERRAGRUNT_VERSION

ARG AWSCLI_VERSION
ARG AZURECLI_VERSION
##############################################################################
FROM docker.io/python:${BUILDER_IMAGE_PYTHON_VERSION}-alpine${ALPINE_VERSION} AS aws-builder

ARG AWSCLI_VERSION

RUN apk add --no-cache \
  curl \
  make \
  cmake \
  gcc \
  g++ \
  libc-dev \
  libffi-dev \
  openssl-dev \
  && curl https://awscli.amazonaws.com/awscli-${AWSCLI_VERSION}.tar.gz | tar -xz \
  && cd awscli-${AWSCLI_VERSION} \
  && ./configure --prefix=/opt/aws-cli/ --with-download-deps \
  && make \
  && make install
##############################################################################
FROM docker.io/python:${BUILDER_IMAGE_PYTHON_VERSION}-alpine${ALPINE_VERSION} AS azure-builder

RUN apk add --no-cache \
  gcc \
  musl-dev \
  python3-dev \
  libffi-dev \
  openssl-dev \
  cargo \
  make

RUN python3 -m venv /opt/azcli \
    && /opt/azcli/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/azcli/bin/pip install --no-cache-dir azure-cli
##############################################################################
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
##############################################################################
FROM ghcr.io/opentofu/opentofu:${OPENTOFU_VERSION}-minimal AS opentofu
##############################################################################
FROM mcr.microsoft.com/devcontainers/base:alpine${ALPINE_VERSION} AS base

ARG TERRAGRUNT_VERSION
ARG PRECOMMIT_VERSION
ARG AZURECLI_VERSION

RUN apk add --no-cache \
  linux-headers \
  groff

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

COPY --from=aws-builder /opt/aws-cli/ /opt/aws-cli/
COPY --from=azure-builder /opt/azcli /opt/azcli
ENV PATH="/opt/azcli/bin:$PATH"

USER vscode
RUN echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc \
  && tofu -install-autocomplete \
  && terragrunt --install-autocomplete \
  && uv tool install pre-commit@${PRECOMMIT_VERSION}
