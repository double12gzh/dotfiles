From alpine:latest

COPY ../config/pip /root/.pip
COPY ../config/luarocks /root/.luarocks
COPY ../config/nvim /nvim

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk add --update \
  git \
  alpine-sdk build-base\
  libtool \
  automake \
  m4 \
  autoconf \
  linux-headers \
  unzip \
  ncurses ncurses-dev ncurses-libs ncurses-terminfo \
  python3 \
  python3-dev \
  py3-pip \
  clang \
  go \
  nodejs \
  xz \
  curl \
  make \
  cmake \
  libintl \
  libtermkey \
  libvterm \
  icu-data-full \
  unibilium \
  neovim && \
  pip3 install --user neovim pep8 && \
  # enable lazygit
  go install github.com/jesseduffield/lazygit@latest && \
  mkdir /root/.config && \
  ln -s /nvim /root/.config/nvim && \
  #curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh && \
  #nvim +PackerSync && \
  rm -rf /var/cache/apk/*
