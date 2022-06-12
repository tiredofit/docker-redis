FROM docker.io/tiredofit/alpine:3.16
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ENV REDIS_VERSION=7.0.2 \
    CONTAINER_ENABLE_MESSAGING=FALSE \
    IMAGE_NAME="tiredofit/redis" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-redis/"

## Redis Installation
RUN set -ex && \
    addgroup -S -g 6379 redis && \
    adduser -S -D -H -h /dev/null -s /sbin/nologin -G redis -u 6379 redis && \
    apk add --no-cache 'su-exec>=0.2' && \
	apk update && \
	apk upgrade && \
	apk add -t .redis-build-deps \
				coreutils \
				gcc \
				linux-headers \
				make \
				musl-dev \
				openssl-dev \
				tar \
			    && \
	\
	mkdir -p /usr/src/redis && \
	curl -sSL https://github.com/redis/redis/archive/refs/tags/${REDIS_VERSION}.tar.gz | tar xfz - --strip 1 -C /usr/src/redis && \
	\
	grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /usr/src/redis/src/config.c && \
	sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/redis/src/config.c && \
	grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /usr/src/redis/src/config.c && \
	\
	export BUILD_TLS=yes && \
	make -C /usr/src/redis -j "$(nproc)" all && \
	make -C /usr/src/redis install && \
	\
	serverMd5="$(md5sum /usr/local/bin/redis-server | cut -d' ' -f1)"; export serverMd5 && \
	find /usr/local/bin/redis* -maxdepth 0 \
		-type f -not -name redis-server \
		-exec sh -eux -c ' \
			md5="$(md5sum "$1" | cut -d" " -f1)"; \
			test "$md5" = "$serverMd5"; \
		' -- '{}' ';' \
		-exec ln -svfT 'redis-server' '{}' ';' \
		&& \
	\
    runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" && \
    apk add -t .redis-rundeps $runDeps && \
	apk del .redis-build-deps && \
	rm -r /usr/src/redis && \
    rm -rf /var/cache/apk/* && \
    \
# Workspace and Volume Setup
    mkdir -p /data && \
    chown redis /data

## Networking Configuration
EXPOSE 6379

### Files Addition
ADD install /
