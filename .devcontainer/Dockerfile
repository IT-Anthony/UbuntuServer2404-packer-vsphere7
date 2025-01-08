FROM alpine:latest

# Retrieve the packer version
ARG PACKER_VERSION

# Install basic packages and genisoimage for mounting Cloud-Init via CD
RUN apk add --no-cache wget unzip git bash zsh curl nano cdrkit

# Create a workspace
WORKDIR /workspaces/packer

# Download and install Packer
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip

# Verification of the installation
RUN echo "Vérification de l'installation de Packer" && \
    which packer && packer --version

# Installation of OhMyZsh (cause it's cool)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Create vscode user
RUN adduser -D vscode

# Create the home for the user vscode, and adjust the permissions
RUN mkdir -p /home/vscode && \
    chown vscode:vscode /home/vscode

# Configure the OhMyZsh (cause it's cool)
USER root
RUN cp -r /root/.oh-my-zsh /home/vscode/ && \
    cp /root/.zshrc /home/vscode/.zshrc && \
    chown -R vscode:vscode /home/vscode/.oh-my-zsh /home/vscode/.zshrc

# Configure the Aussiegeek theme for OhMyZsh (cause it's nice)
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="aussiegeek"/g' /home/vscode/.zshrc

# Change the default shell
RUN sed -i 's#/bin/sh#/bin/zsh#g' /etc/passwd

# Back to user vscode
USER vscode

# Installation of the vSphere plugin for Packer
RUN echo "Installation du plugin vSphere pour Packer" && \
    packer plugins install github.com/hashicorp/vsphere

# Start the ZSH shell
CMD ["zsh"]