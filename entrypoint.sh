#!/bin/bash

sed -i "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json

# 注册 WARP 账号，获取独立 WireGuard 配置
mkdir -p /etc/wireguard

if [ ! -f /etc/wireguard/wgcf.conf ]; then
  echo "=== 注册 WARP (获取新 IP) ==="
  mkdir -p /tmp/warp
  cd /tmp/warp
  for i in 1 2 3; do
    wgcf register --accept-tos && break
    echo "重试 $i/3..."
    sleep 3
  done
  wgcf generate
  cp wgcf-profile.conf /etc/wireguard/wgcf.conf
  rm -rf /tmp/warp
  cd /
fi

# 清理旧隧道 (如有)
wg-quick down wgcf 2>/dev/null || true

# 启动 WARP 隧道
echo "=== 启动 WARP WireGuard 隧道 ==="
wg-quick up wgcf 2>&1
echo "=== WARP 启动完成 ==="

# 验证出口 IP
echo "=== WARP 出口 IP ==="
curl -s --connect-timeout 10 https://cloudflare.com/cdn-cgi/trace 2>/dev/null | head -5 || echo "无法获取 IP"

# 启动 Xray
echo "=== 启动 Xray ==="
xray run -c /etc/xray/config.json &

sleep 2

# 启动 Cloudflare Tunnel
echo "=== 启动 Cloudflare Tunnel ==="
exec cloudflared tunnel --no-autoupdate run --token $TOKEN
