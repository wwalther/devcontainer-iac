# =============================================================================
# Build args
ARG PYTHON_VERSION=3.11

ARG UV_VERSION=0.10.4
ARG PRECOMMIT_VERSION=4.5.1

ARG OPENTOFU_VERSION=1.11.5
ARG TERRAGRUNT_VERSION=0.99.4

ARG AZURECLI_VERSION=2.83.0
ARG AWSCLI_VERSION=2.33.27

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# =============================================================================
# Stage: uv
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

# =============================================================================
# Stage: opentofu
FROM ghcr.io/opentofu/opentofu:${OPENTOFU_VERSION}-minimal AS opentofu

# =============================================================================
# Stage: terragrunt
FROM ghcr.io/wwalther/devcontainer-iac-alpine-terragrunt:${TERRAGRUNT_VERSION} AS terragrunt

# =============================================================================
# Stage: az
FROM ghcr.io/wwalther/devcontainer-iac-alpine-az:${AZURECLI_VERSION} AS az

# =============================================================================
# Stage: aws
FROM ghcr.io/wwalther/devcontainer-iac-alpine-awscli:${AWSCLI_VERSION} AS aws

# =============================================================================
# Stage: final
FROM python:${PYTHON_VERSION}-alpine

ARG USERNAME
ARG USER_UID
ARG USER_GID
ARG PRECOMMIT_VERSION

COPY --from=uv /uv /uvx /bin/
COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/terragrunt
COPY --from=az /opt/az /opt/az
COPY --from=aws /opt/aws-cli/ /opt/aws-cli/
ENV PATH="/opt/az/bin:/opt/aws-cli/bin:/home/vscode/.local/bin:$PATH"

# DL3018: We want the latest user packages
# hadolint ignore=DL3018
RUN apk add --no-cache \
  # az dependencies
  libffi \
  openssl \
  ca-certificates \
  # aws dependencies
  groff \
  # user tools
  sudo \
  bash \
  bash-completion \
  make \
  git \
  gpg \
  openssh \
  gawk

# Azure CLI: disable telemetry and verbose output
ENV AZURE_CORE_COLLECT_TELEMETRY=0 \
  AZURE_CORE_ONLY_SHOW_ERRORS=true

# Non-root user
RUN addgroup -g ${USER_GID} ${USERNAME} \
  && adduser -s /bin/bash -D -u ${USER_UID} -G ${USERNAME} ${USERNAME} \
  && echo "vscode ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER ${USERNAME}
COPY --chown=${USERNAME}:${USERNAME} config/.bash_profile /home/vscode/.bash_profile

# SC2016: intentional single-quote to defer expansion
# hadolint ignore=SC2016
RUN echo '[[ -f ~/.bash_profile ]] && source ~/.bash_profile' >> ~/.bashrc \
  && echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc \
  && echo 'eval "$(uvx --generate-shell-completion bash)"' >> ~/.bashrc \
  && uv tool install pre-commit@${PRECOMMIT_VERSION} \
  && tofu -install-autocomplete \
  && terragrunt --install-autocomplete

ENTRYPOINT ["/bin/bash"]
