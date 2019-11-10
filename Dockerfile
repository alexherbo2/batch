FROM alpine:edge
RUN apk add --update crystal shards libc-dev upx
WORKDIR /app
CMD shards build --release --static --no-debug && \
  strip --strip-all bin/batch && upx --best bin/batch
