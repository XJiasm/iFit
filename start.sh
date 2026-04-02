#!/bin/bash

echo "========================================="
echo "   FitMirror 项目启动脚本"
echo "========================================="
echo

# 检查 MySQL
echo "[1/4] 检查 MySQL..."
if ! mysql -u root -p123456 -e "SELECT 1" &>/dev/null; then
    echo "[错误] MySQL 未启动或连接失败"
    echo "请确保 MySQL 正在运行，用户名 root，密码 123456"
    exit 1
fi
echo "[OK] MySQL 连接成功"

# 创建数据库
echo "[2/4] 创建数据库..."
mysql -u root -p123456 -e "CREATE DATABASE IF NOT EXISTS fitmirror DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci" &>/dev/null
echo "[OK] 数据库已就绪"

# 启动后端
echo "[3/4] 启动后端服务..."
cd backend
./mvnw spring-boot:run &
BACKEND_PID=$!
cd ..

# 等待后端启动
echo "[4/4] 等待后端服务就绪..."
sleep 15

# 检查后端健康状态
if curl -s http://localhost:8080/api/health | grep -q "ok"; then
    echo "[OK] 后端服务已就绪"
else
    echo "[警告] 后端服务可能还在启动中"
fi

echo
echo "========================================="
echo "   启动完成！"
echo "========================================="
echo
echo "后端地址: http://localhost:8080/api"
echo "健康检查: http://localhost:8080/api/health"
echo
echo "Flutter 客户端启动命令:"
echo "  cd fitmirror"
echo "  flutter pub get"
echo "  flutter run"
echo
