FROM tiredofit/alpine:3.12
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

ENV REDIS_VERSION=6.0.5 \
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
	apk update && \
	apk update && \
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
	curl http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz | tar xfz - --strip 1 -C /usr/src/redis && \
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
