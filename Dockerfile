# https://github.com/WebAssembly/binaryen/releases/download/version_93/binaryen-version_93-x86_64-linux.tar.gz
FROM alpine:3.12 as binaryen-build

WORKDIR /tmp

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.44.0

RUN apk add curl git
RUN curl -sL https://github.com/WebAssembly/binaryen/releases/download/version_93/binaryen-version_93-x86_64-linux.tar.gz |tar zxpvf -

RUN apk add --update --no-cache \
        ca-certificates \
        gcc openssl-dev musl musl-dev npm libc6-compat

RUN set -eux; \
    ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld64.so.1; \
    npm install terser -g; \
    url="https://static.rust-lang.org/rustup/archive/1.21.1/x86_64-unknown-linux-musl/rustup-init"; \
    wget "$url"; \
    echo "0c86d467982bdf5c4b8d844bf8c3f7fc602cc4ac30b29262b8941d6d8b363d7e *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

RUN rustup install $RUST_VERSION
RUN rustup override set $RUST_VERSION
RUN rustup target add asmjs-unknown-emscripten --toolchain $RUST_VERSION
RUN rustup target add wasm32-unknown-emscripten --toolchain $RUST_VERSION
RUN rustup target add x86_64-unknown-linux-musl --toolchain $RUST_VERSION

#RUN git clone https://github.com/mre/wasm-pack && cd wasm-pack && cargo build -vv --target x86_64-unknown-linux-musl --release
#RUN git clone https://github.com/mre/tinysearch && cd tinysearch && cargo build -vv --target x86_64-unknown-linux-musl --release

RUN cargo install wasm-pack
RUN cargo install tinysearch

RUN /usr/local/cargo/bin/wasm-pack --version
RUN /usr/local/cargo/bin/tinysearch --version


RUN curl -s -o index.json https://raw.githubusercontent.com/mre/tinysearch/master/fixtures/index.json
RUN time /usr/local/cargo/bin/tinysearch index.json
RUN rm -rf /tmp/*

CMD ["/bin/sh"]
