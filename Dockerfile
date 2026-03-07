ARG PYTHON_VERSION=3.11
ARG AZURECLI_VERSION=2.83.0
ARG AWSCLI_VERSION=2.33.27

ARG UV_VERSION=0.10.4
ARG PRECOMMIT_VERSION=4.5.1

ARG OPENTOFU_VERSION=1.11.5
ARG TERRAGRUNT_VERSION=0.99.4

ARG USERNAME=vscode
# =============================================================================
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
# =============================================================================
FROM ghcr.io/opentofu/opentofu:${OPENTOFU_VERSION}-minimal AS opentofu
# =============================================================================
FROM ghcr.io/wwalther/devcontainer-iac-terragrunt:${TERRAGRUNT_VERSION} AS terragrunt
# =============================================================================
FROM ghcr.io/wwalther/devcontainer-iac-alpine-az:${AZURECLI_VERSION} AS az
# =============================================================================
FROM ghcr.io/wwalther/devcontainer-iac-alpine-awscli:${AWSCLI_VERSION} AS aws
# =============================================================================
FROM python:${PYTHON_VERSION}-alpine

ARG USERNAME
ARG PRECOMMIT_VERSION

COPY --from=uv /uv /uvx /bin/
COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/terragrunt
COPY --from=az /opt/az /opt/az
COPY --from=aws /opt/aws-cli/ /opt/aws-cli/
ENV PATH="/opt/az/bin:/opt/aws-cli/bin:/home/vscode/.local/bin:$PATH"

# Minimal runtime dependencies
RUN apk add --no-cache \
  # azure
  libffi \
  openssl \
  ca-certificates \
  # user
  bash \
  bash-completion \
  git \
  gpg \
  gawk

# Suppress internal module noise
ENV AZURE_CORE_COLLECT_TELEMETRY=0 \
  AZURE_CORE_ONLY_SHOW_ERRORS=true
# Non-root user (optional but good practice)
RUN adduser -s /bin/bash -D ${USERNAME}
USER ${USERNAME}

RUN echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc \
  && echo 'eval "$(uvx --generate-shell-completion bash)"' >> ~/.bashrc \
  && uv tool install pre-commit@${PRECOMMIT_VERSION} \
  && tofu -install-autocomplete \
  && terragrunt --install-autocomplete


ENTRYPOINT ["/bin/bash"]
