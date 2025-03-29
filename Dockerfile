FROM alpine:latest

COPY . /source
# Build
RUN apk add --no-cache go nodejs yarn zip && \
    cd /source/assets && \
    rm -rf build && \
    yarn install --frozen-lockfile --network-timeout 1000000 && \
    yarn run build && \
    cd ../ && \
    zip -r - assets/build >assets.zip && \
    mkdir /cloudreve && \
    go build -o /cloudreve/cloudreve && \
    apk del go nodejs yarn zip && \
    rm -rf ~/go ~/.cache/yarn assets/node_modules

# Runtime deps
RUN apk add --no-cache tzdata aria2 icu-data-full vips vips-tools ffmpeg libreoffice \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p /data/aria2 \
    && chmod -R 766 /data/aria2

EXPOSE 5212
VOLUME ["/cloudreve/uploads", "/cloudreve/avatar", "/data"]
WORKDIR /cloudreve
ENTRYPOINT ["./cloudreve"]
