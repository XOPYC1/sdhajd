#!/bin/bash

set -Eeuo pipefail

LOG_FILE="/var/log/3xui.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================="
echo "   3X-UI INSTALL START"
echo "=============================="

# --- CHECK ROOT ---

if [ "$EUID" -ne 0 ]; then
echo "[ERROR] Запусти скрипт через sudo или root"
exit 1
fi

# --- SYSTEM CHECK ---

echo "[INFO] Проверка системы..."

if ! command -v apt >/dev/null 2>&1; then
echo "[ERROR] Поддерживаются только Debian/Ubuntu"
exit 1
fi

# --- INPUT ---

read -p "Введите домен (или оставь пустым): " DOMEN

# --- UPDATE ---

echo "[STEP 1] Обновление системы"
apt update && apt upgrade -y

# --- DEPENDENCIES ---

echo "[STEP 2] Установка зависимостей"
apt install -y wget curl ca-certificates

# --- INSTALL 3X-UI ---

echo "[STEP 3] Установка 3X-UI"
bash <(curl -fsSL https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# --- OPTIONAL SSL INFO ---

if [ -n "${DOMEN:-}" ]; then
echo "[INFO] Домен указан: $DOMEN"
echo "[INFO] SSL настраивается через меню x-ui"
else
echo "[INFO] Домен не указан, пропускаем SSL"
fi

# --- DONE ---

echo "=============================="
echo "[DONE] 3X-UI установлен"
echo "Лог: $LOG_FILE"
echo "Запуск панели: x-ui"
echo "=============================="
