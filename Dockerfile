FROM alpine:edge

RUN set -x \
  \
  && apk add --no-cache --virtual .build-deps \
    curl-dev openssl-dev make fuse-dev expat-dev zlib-dev \
    bash git  automake autoconf g++ bsd-compat-headers \
  \
## build
  && git clone -b 1.5.2 https://github.com/archiecobbs/s3backer.git /usr/src/s3backer \
  && cd /usr/src/s3backer \
  \
  && ./autogen.sh \
  && CXXFLAGS='-Os' ./configure \
    --prefix=/usr/local \
  && make -j "$(getconf _NPROCESSORS_ONLN)" \
  && make install \
  \
## cleanup
  && cd / \
  && rm -rf /usr/src \
  \
  && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )" \
  && apk add --virtual .rundeps $runDeps \
  && apk del .build-deps


ENTRYPOINT ["s3backer", "-f"]
