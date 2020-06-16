# docker-tinysearch
Docker tinysearch mre Alpine image

Also available at [Docker HUB](https://hub.docker.com/repository/docker/fluential/docker-tinysearch)  
Please check what's required to [host WebAssembly in production](https://rustwasm.github.io/book/reference/deploying-to-production.html) -- you will need to explicitly set mime gzip types
### Usage
## RUN
```
docker pull fluential/docker-tinysearch
```

## BUILD
Available buid args:
 - WASM_REPO
 - WASM_BRANCH
 - TINY_REPO
 - TINY_BRANCH
 - TINY_MAGIC (for a magic number)
```
docker build --build-arg WASM_BRANCH=master -t tinysearch .
```
```
docker build --build-arg TINY_MAGIC=64 -t tinysearch .
```
