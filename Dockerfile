FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt-get -y install inetutils-ping inetutils-telnet \ 
    build-essential fish curl git vim sudo python3 golang \
    python3-pip python3-pip-whl tmux fzf curl

RUN curl -o nats-0.0.34-amd64.deb -L https://github.com/nats-io/natscli/releases/download/v0.0.34/nats-0.0.34-amd64.deb &&\
    dpkg -i nats-0.0.34-amd64.deb && rm -f nats-0.0.34-amd64.deb

RUN curl -qfsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > \
    /etc/apt/sources.list.d/kubernetes.list

RUN apt update -y && apt install kubectl

RUN curl -qLo /tmp/k9s_Linux_x86_64.tar.gz https://github.com/derailed/k9s/releases/download/v0.26.4/k9s_Linux_x86_64.tar.gz

RUN cd tmp && tar xzvf k9s_Linux_x86_64.tar.gz && cp ./k9s /usr/local/bin/k9s && \ 
    rm -rf /tmp/k9s_Linux_x86_64* && chmod +x /usr/local/bin/k9s

COPY --chown=root:root files/debug_sudo /etc/sudoers.d/debug_sudo

COPY --chown=root:root files/tmux_chooser /usr/local/bin/tmux_chooser

RUN chmod +x /usr/local/bin/tmux_chooser

RUN useradd -m -G sudo -s /usr/bin/fish debug

USER debug
WORKDIR /home/debug

COPY --chown=debug:debug files/config/ .config

RUN mkdir -p /home/debug/go

RUN pip3 install --user --no-warn-script-location virtualenv poetry pipenv

ENTRYPOINT [ "/usr/local/bin/tmux_chooser" ]
