#!/bin/bash

#Compile zip
chmod +x "./tools/build_bundles.sh"
./tools/build_bundles.sh

# 1️⃣ Build Dart Frog (tạo thư mục build)
dart_frog build

# 2️⃣ Copy file docker-compose và init.sql vào build
cp docker-compose.yml build/
cp -r database build/

# 3️⃣ Vào thư mục build
cd build

# 5️⃣ Build & chạy lại container
docker compose down
docker compose up -d --build

# 6️⃣ Chạy migration sau khi container PostgreSQL đã khởi động
sleep 1

chmod +x "./database/migrate_all.sh"
./database/migrate_all.sh