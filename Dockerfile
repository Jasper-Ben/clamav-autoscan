FROM debian:stretch-slim

LABEL maintainer "Jasper Orschulko <jasper@fancydomain.eu>"

ENV CLAMAV 0.102.2
ENV TINI v0.19.0

COPY bootstrap.sh ./

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        zlib1g-dev \
        libcurl4-openssl-dev \
        libncurses5-dev \
        libzip-dev \
        libpcre2-dev \
        libxml2-dev \
        libssl-dev \
        build-essential \
        libjson-c-dev \
        curl \
        bash \
        wget \
        tzdata \
        dnsutils \
        rsync \
        netcat \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O - https://www.clamav.net/downloads/production/clamav-${CLAMAV}.tar.gz | tar xfvz - \
    && cd clamav-${CLAMAV} \
    && ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sysconfdir=/etc/clamav \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info \
    --disable-llvm \
    --with-user=clamav \
    --with-group=clamav \
    --with-dbdir=/var/lib/clamav \
    --enable-clamdtop \
    --enable-bigstack \
    --with-pcre \
    && make -j "$(nproc)" \
    && make install \
    && make clean \
    && cd .. && rm -rf clamav-${CLAMAV} \
    && apt-get -y --auto-remove purge build-essential \
    && apt-get -y purge zlib1g-dev \
    libncurses5-dev \
    libzip-dev \
    libpcre2-dev \
    libxml2-dev \
    libssl-dev \
    libjson-c-dev \
    && addgroup --system --gid 700 clamav \
    && adduser --system --no-create-home --home /var/lib/clamav --uid 700 --gid 700 --disabled-login clamav \
    && rm -rf /tmp/* /var/tmp/* \
    && curl -sSfL https://github.com/krallin/tini/releases/download/"$TINI"/tini-amd64 -o /sbin/tini \
    && chmod +x /sbin/tini /bootstrap.sh \
    && curl -sSfL https://raw.githubusercontent.com/Cisco-Talos/clamav-devel/clamav-"$CLAMAV"/etc/clamd.conf.sample -o /etc/clamd.conf \
    && curl -sSfL https://raw.githubusercontent.com/Cisco-Talos/clamav-devel/clamav-"$CLAMAV"/etc/freshclam.conf.sample -o /etc/freshclam.conf \

CMD ["/sbin/tini", "-g", "--", "/bootstrap.sh"]
