FROM iquirino91/grpc AS builder

ENV NGHTTP2_VERSION 1.46.0
ENV CURL_VERSION 7.80.0
ENV NGINX_VERSION 1.20.2

RUN wget -qO- https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz | tar -zxf - \
  && cd nghttp2-${NGHTTP2_VERSION} \
  && ./configure \
  && make -j2 \
  && make install

RUN wget -qO- https://curl.se/download/curl-${CURL_VERSION}.zip | unzip -qq - \
  && cd curl-${CURL_VERSION} \
  && chmod 777 configure \
  && chmod 777 install-sh \
  && ./configure \
    --with-nghttp2=/usr/local --with-ssl --disable-dependency-tracking \
    --prefix=/usr \
    --enable-ipv6 \
    --enable-unix-sockets \
    --enable-static \
    --with-openssl \
    --without-libidn \
    --without-libidn2 \
    --with-nghttp2 \
    --disable-ldap \
    --with-pic \
    --without-libssh2 \
  && make -j2 \
  && make install

RUN wget  -qO- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zxf - \
  && cd nginx-${NGINX_VERSION} \
  && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/etc/nginx/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_gunzip_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-compat && \
  make -j2 && \
  make install && \
  make clean

RUN mkdir -p /var/log/nginx/ && \
    echo -n > /var/log/nginx/access.log && \
    echo -n > /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGQUIT
EXPOSE 80

CMD ["/etc/nginx/nginx", "-g", "daemon off;"]