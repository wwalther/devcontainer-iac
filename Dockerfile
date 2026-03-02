ARG UV_VERSION=0.10.4
ARG PRECOMMIT_VERSION=4.5.1

ARG OPENTOFU_VERSION=1.11.5
ARG TERRAGRUNT_VERSION=0.99.4

ARG AWSCLI_VERSION=2.33.27
ARG AZURECLI_VERSION=2.83.0
##############################################################################
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
##############################################################################
FROM ghcr.io/opentofu/opentofu:${OPENTOFU_VERSION}-minimal AS opentofu
##############################################################################
FROM ghcr.io/wwalther/devcontainer-iac-terragrunt:${TERRAGRUNT_VERSION} AS terragrunt
##############################################################################
FROM ghcr.io/wwalther/devcontainer-iac-azurelinux-awscli:${AWSCLI_VERSION}-${AZURECLI_VERSION}-azurelinux3.0 AS awscli
##############################################################################
FROM mcr.microsoft.com/azure-cli:${AZURECLI_VERSION} AS base

ARG PRECOMMIT_VERSION

RUN az config set core.collect_telemetry=no \
  && tdnf install -y \
    gawk \
    git \
    groff \
    tar \
    vi \
  && tdnf autoremove \
  && tdnf clean all

COPY --from=uv /uv /uvx /bin/
COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/terragrunt
COPY --from=awscli /opt/aws-cli/ /opt/aws-cli/
ENV UV_LINK_MODE=copy \
  PATH="/opt/aws-cli/bin:/home/vscode/.local/bin:${PATH}"

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN tdnf install -y \
        shadow-utils \
    && groupadd \
        --gid=$USER_GID \
        $USERNAME \
    && useradd \
        --uid=$USER_UID \
        --gid=$USER_GID \
        --create-home \
        $USERNAME \
    && mkdir /home/$USERNAME/.ssh \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && tdnf autoremove -y \
        shadow-utils \
    && tdnf clean all

USER vscode
RUN echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc \
  && tofu -install-autocomplete \
  && terragrunt --install-autocomplete \
  && uv tool install pre-commit@${PRECOMMIT_VERSION} \
  && uv tool update-shell
