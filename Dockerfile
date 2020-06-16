# Docker tinsearch with deps
#   - binaryen
#   - wasm-pack
#   - terser
ARG WASM_REPO=https://github.com/mre/wasm-pack.git
ARG WASM_BRANCH=first-class-bins
ARG TINY_REPO=https//github.com/mre/tinysearch
ARG TINY_BRANCH=master

FROM rust:alpine as binary-build

ARG WASM_REPO
ARG WASM_BRANCH
ARG TINY_REPO
ARG TINY_BRANCH

WORKDIR /tmp

RUN apk add --update --no-cache --virtual build-dependencies musl-dev openssl-dev gcc curl git npm gcc ca-certificates libc6-compat

ENV env_var_name=$var_name

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    WASM_REPO="$WASM_REPO" \
    WASM_BRANCH="$WASM_BRANCH" \
    TINY_REPO="$TINY_REPO" \
    TINY_BRANCH="$TINY_BRANCH"

RUN rustup target add asmjs-unknown-emscripten
RUN rustup target add wasm32-unknown-emscripten

RUN set -eux -o pipefail; \
    ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld64.so.1; \
    npm install terser -g; \
    curl -sL https://api.github.com/repos/WebAssembly/binaryen/releases/latest|grep tarball|awk '{print $2}'|sed 's/,//g'|xargs curl -sL |tar zxp ; \
    cp -rp WebAssembly-binaryen*/* /usr/local/bin/.

RUN time cargo install --force --git "$WASM_REPO" --branch "$WASM_BRANCH"
RUN time cargo install --force --git "$TINY_REPO" --branch "$TINY_BRANCH"

RUN wasm-pack --version
RUN tinysearch --version

RUN rm -rf /tmp/*

CMD ["/usr/local/cargo/bin/tinysearch"]
