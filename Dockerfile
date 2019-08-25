FROM alpine:3.9

LABEL maintainer "Jasper Orschulko <jasper@fancydomain.eu>"

COPY update_db.sh bootstrap.sh ./

ENV CLAMAV 0.101.4

RUN apk add --no-cache --virtual build-dependencies \
        alpine-sdk \
        ncurses-dev \
        zlib-dev \
        bzip2-dev \
        pcre-dev \
        linux-headers \
        fts-dev \
        libxml2-dev \
        libressl-dev \
    && apk add --no-cache \
        curl \
        bash \
        tini \
        libxml2 \
        libbz2 \
        pcre \
        fts \
        libressl \
        tzdata \
        inotify-tools \
    && wget -O - https://www.clamav.net/downloads/production/clamav-${CLAMAV}.tar.gz | tar xfvz - \
    && cd clamav-${CLAMAV} \
    && LIBS=-lfts ./configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --sysconfdir=/etc/clamav \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --without-iconv \
        --disable-llvm \
        --with-user=clamav \
        --with-group=clamav \
        --with-dbdir=/var/lib/clamav \
        --enable-clamdtop \
        --enable-bigstack \
        --with-pcre \
    && make -j$(nproc) \
    && make install \
    && make clean \
    && cd .. && rm -rf clamav-${CLAMAV} \
    && apk del build-dependencies \
    && addgroup -S clamav \
    && adduser -S -D -h /var/lib/clamav -s /sbin/nologin -G clamav -g clamav clamav \
    && adduser clamav tty \
    && mkdir -p /run/clamav /data /infected /clean \
    && chown -R clamav:clamav /run/clamav \
    && chmod +x /update_db.sh bootstrap.sh \
    && set -ex; /bin/bash /update_db.sh \
    && chmod 750 /run/clamav 

VOLUME /data /infected /clean

COPY config/clamd.conf config/freshclam.conf /etc/clamav/

CMD ["/sbin/tini", "-g", "--", "/bootstrap.sh"]
