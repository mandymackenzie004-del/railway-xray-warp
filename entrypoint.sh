#!/bin/bash

sed -i "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json

# 先启动 Xray（确保端口立即可用）
echo "=== 启动 Xray ==="
xray run -c /etc/xray/config.json &

sleep 2

# WARP 放后台，失败了也不影响 Xray
(
  echo "=== 注册 WARP ==="
  mkdir -p /tmp/warp
  cd /tmp/warp
  for i in 1 2 3; do
    wgcf register --accept-tos && break
    echo "重试 $i/3..."
    sleep 3
  done
  wgcf generate || exit 1
  cp wgcf-profile.conf /etc/wireguard/wgcf.conf
  rm -rf /tmp/warp
  cd /

  echo "=== 启动 WARP ==="
  wg-quick up wgcf 2>&1
  echo "=== WARP 出口 IP ==="
  curl -s --connect-timeout 10 https://cloudflare.com/cdn-cgi/trace 2>/dev/null | head -5 || echo "获取 IP 失败"
) &

# 保持容器运行
wait
