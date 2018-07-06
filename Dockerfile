FROM alpine:3.4
LABEL author Alfred Gutierrez <alf.g.jr@gmail.com>

ENV NGINX_VERSION 1.13.9
ENV NGINX_RTMP_VERSION 1.2.1
ENV FFMPEG_VERSION 3.4.2

EXPOSE 1935
EXPOSE 1936

RUN mkdir -p /opt/data && mkdir -p /opt/data/hls

# Build dependencies.
RUN	apk update && apk add	\
  binutils \
  binutils-libs \
  build-base \
  ca-certificates \
  gcc \
  libc-dev \
  libgcc \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev

# Get nginx source.
RUN cd /tmp && \
  wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --with-http_secure_link_module \
  --prefix=/opt/nginx \
  --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --conf-path=/opt/nginx/nginx.conf \
  --error-log-path=/opt/nginx/logs/error.log \
  --http-log-path=/opt/nginx/logs/access.log \
  --with-debug && \
  cd /tmp/nginx-${NGINX_VERSION} && make && make install

RUN apk add --update ffmpeg
# Get FFmpeg source.


# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

# Add NGINX config and static files.
ADD nginx.conf /opt/nginx/nginx.conf
ADD static /static

CMD ["/opt/nginx/sbin/nginx"]