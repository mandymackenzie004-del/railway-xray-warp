FROM alpine:latest

RUN apk add --no-cache wireguard-tools openresolv bash curl jq

RUN mkdir -p /usr/local/share/xray && \
    cd /tmp && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin/ && \
    rm Xray-linux-64.zip

RUN wget -q https://github.com/ViRb3/wgcf/releases/latest/download/wgcf_2.2.22_linux_amd64 -O /usr/local/bin/wgcf && \
    chmod +x /usr/local/bin/wgcf

RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN wget -q https://github.com/VergeInc/wireguard-go/releases/download/v0.0.20230223/wireguard-go-linux-amd64 -O /usr/local/bin/wireguard-go && \
    chmod +x /usr/local/bin/wireguard-go

ENV UUID=UUID_PLACEHOLDER
ENV TOKEN=
ENV WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go

EXPOSE 8080

CMD ["/entrypoint.sh"]
