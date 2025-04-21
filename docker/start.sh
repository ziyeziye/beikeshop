#!/bin/bash

# 先手动给此脚本添加执行权限
# chmod +x start.sh

# 构建 PHP 容器
if ! docker images | grep -q "docker-php"; then
  docker compose build php
fi

docker compose down

# 在 PHP 容器中执行 composer install
docker compose run --rm php sh -c "cd /app && composer install"

# 复制 .env.example 到 .env
if [ ! -f ../.env ]; then
  cp ../.env.example ../.env
fi

# 在 Node 容器中执行 npm install 和 npm run dev
cd ../ && docker run --rm -v $(pwd):/app -w /app node:22 sh -c "cd /app && npm install && npm run dev"

cd docker && docker compose up -d

URL="https://${NGROK_DOMAIN}"

echo "服务启动成功！"

echo "请访问: ${URL}"

# 如果 storage/installed 文件不存在,则写入配置到 .env
# sed -i "" "s#APP_URL=.*#APP_URL=${URL}#" ../.env
# sed -i "" "s#ASSET_URL=.*#ASSET_URL=${URL}#" ../.env
# sed -i "" "s#APP_FORCE_HTTPS=.*#APP_FORCE_HTTPS=true#" ../.env

if [ ! -f ../storage/installed ]; then
  echo "首次安装完成需要手动添加 APP_FORCE_HTTPS=true 到.env文件,然后执行此脚本重新启动服务"
fi