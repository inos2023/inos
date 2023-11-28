FROM seawolf89/devcontainers-base:latest

# install package
RUN \
  sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
  sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
  apt update && \
    apt install -y --no-install-recommends \
      iputils-ping \
      libncurses-dev \
      python3 \
      cpio \
      qemu-system-x86 \
      qemu-system-arm \
      graphviz python3-matplotlib python3-numpy\
      clang-format \
      gdb-multiarch \
      git-lfs \
    && ln -s /usr/bin/python3 /usr/bin/python

# setup repo
RUN curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo > /bin/repo \
  && chmod a+x /bin/repo

ENV REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'

# Setup rust
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static \
    RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.67.0
RUN set -eux; \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile default --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME;
RUN echo "[source.crates-io]\nregistry = \"https://github.com/rust-lang/crates.io-index\"\nreplace-with = 'ustc'\n[source.ustc]\nregistry = \"git://mirrors.ustc.edu.cn/crates.io-index\"" > $CARGO_HOME/config
# Add rust target
RUN rustup target add x86_64-unknown-linux-gnu
