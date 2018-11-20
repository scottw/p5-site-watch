FROM scottw/alpine-perl:5.26
MAINTAINER scottw

WORKDIR /app

COPY cpanfile cpanfile.snapshot /app/

RUN apk update && apk upgrade && apk add --no-cache \
        libressl \
        libressl-dev \
        zlib-dev \
        && cpanm --notest Type::Tiny@1.004002 \
        && cpanm --installdeps --notest . \
        && rm -rf /var/cache/apk/* \
        /root/.cpanm \
        /app/Type-Tiny-1.004002.tar.gz

COPY docker-entrypoint site-watch /app/
COPY lib /app/lib/

VOLUME /app/etc

ENTRYPOINT ["perl", "docker-entrypoint"]
