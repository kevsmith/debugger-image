FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt-get -y install inetutils-ping inetutils-telnet \ 
    build-essential fish curl git vim sudo python3 golang \
    python3-pip python3-pip-whl tmux fzf curl

RUN curl -o nats-0.0.34-amd64.deb -L https://github.com/nats-io/natscli/releases/download/v0.0.34/nats-0.0.34-amd64.deb &&\
    dpkg -i nats-0.0.34-amd64.deb && rm -f nats-0.0.34-amd64.deb

# RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-jammy main" > \
#     /etc/apt/sources.list.d/kubernetes.list

# RUN apt update -y && apt install kubectl

COPY --chown=root:root files/debug_sudo /etc/sudoers.d/debug_sudo

RUN useradd -m -G sudo -s /usr/bin/fish debug

USER debug
WORKDIR /home/debug

COPY --chown=debug:debug files/config/ .config

RUN mkdir -p /home/debug/go

RUN pip3 install --user --no-warn-script-location virtualenv poetry pipenv

RUN go install github.com/kubernetes/kubectl@latest

ENTRYPOINT [ "/usr/bin/tmux" ]
