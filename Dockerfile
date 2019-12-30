FROM tiredofit/alpine:3.11
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

ENV REDIS_VERSION=5.0.5 \
    ZABBIX_HOSTNAME=redis-db \
    ENABLE_SMTP=FALSE

## Redis Installation
RUN set -x && \
    addgroup -S -g 6379 redis && \
    adduser -S -D -H -h /dev/null -s /sbin/nologin -G redis -u 6379 redis && \
    \
    apk add --no-cache 'su-exec>=0.2' && \
    set -ex && \
	\
	apk add --no-cache --virtual .redis-build-deps \
                coreutils \
		gcc \
		linux-headers \
		make \
		musl-dev \
		tar \
	    && \
	\
	mkdir -p /usr/src/redis && \
	curl http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz | tar xfz - --strip 1 -C /usr/src/redis && \
	\
	grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h && \
	sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h && \
	grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h && \
	\
	make -C /usr/src/redis -j "$(nproc)" && \
	make -C /usr/src/redis install && \
	\
	rm -r /usr/src/redis && \
	\
    runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" && \
    apk add --virtual .redis-rundeps $runDeps && \
	apk del .redis-build-deps && \
    rm -rf /var/cache/apk/* && \
    \
# Workspace and Volume Setup
    mkdir -p /data && \
    chown redis /data

## Networking Configuration
EXPOSE 6379

### Files Addition
ADD install /
