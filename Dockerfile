# Docker tinsearch with deps
#   - binaryen
#   - wasm-pack
#   - terser
FROM rustlang/rust:nightly-alpine as binary-build

WORKDIR /tmp

RUN apk add --update --no-cache --virtual build-dependencies musl-dev openssl-dev gcc curl git npm gcc ca-certificates libc6-compat

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \

RUN rustup target add asmjs-unknown-emscripten
RUN rustup target add wasm32-unknown-emscripten

RUN set -eux; \
    ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld64.so.1; \
    npm install terser -g; \
    curl -sL https://api.github.com/repos/WebAssembly/binaryen/releases/latest|grep tarball|awk '{print $2}'|sed 's/,//g'|xargs curl -sL |tar zxp ;
    cp -rp binaryen*/* /usr/local/bin/.

RUN time cargo install --force --git https://github.com/mre/wasm-pack.git --branch first-class-bins
RUN time cargo install --force --git https://github.com/mre/tinysearch

RUN wasm-pack --version
RUN tinysearch --version

RUN rm -rf /tmp/*

CMD ["/usr/local/cargo/bin/tinysearch"]
