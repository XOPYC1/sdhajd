#!/bin/bash

set -Eeuo pipefail

LOG_FILE="/var/log/marzban.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================="
echo "   MARZBAN PANEL INSTALL"
echo "=============================="

# --- ROOT CHECK ---

if [ "$EUID" -ne 0 ]; then
echo "[ERROR] Запусти через sudo/root"
exit 1
fi

# --- OS CHECK ---

if ! command -v apt >/dev/null 2>&1; then
echo "[ERROR] Только Debian/Ubuntu"
exit 1
fi

# --- UPDATE SYSTEM ---

echo "[STEP 1] Обновление системы"
apt update && apt upgrade -y

# --- DEPENDENCIES ---

echo "[STEP 2] Установка зависимостей"
apt install -y curl socat git ca-certificates

# --- INSTALL MARZBAN ---

echo "[STEP 3] Установка Marzban panel"
bash <(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh) @ install

# --- ADMIN CREATION ---

echo "[STEP 4] Создание admin пользователя"
echo "Сейчас нужно создать admin вручную через CLI:"
echo "Команда: marzban cli admin create --sudo"
echo ""

# --- INFO ---

echo "=============================="
echo "[DONE] Marzban установлен"
echo "Лог: $LOG_FILE"
echo "Панель: https://IP:8000 (по умолчанию)"
echo "=============================="
