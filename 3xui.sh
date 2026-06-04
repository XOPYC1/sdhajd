#!/bin/bash

# Убираем pipefail, оставляем -e для критических ошибок, если это необходимо
set -e

LOG_FILE="/var/log/3xui.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================="
echo "   3X-UI FAST INSTALL START"
echo "=============================="

# --- CHECK ROOT ---
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Запусти скрипт через sudo или root"
    exit 1
fi

# --- SYSTEM CHECK ---
if ! command -v apt >/dev/null 2>&1; then
    echo "[ERROR] Поддерживаются только Debian/Ubuntu"
    exit 1
fi

# --- UPDATE INDEXES & INSTALL DEPS ---
echo "[STEP 1] Быстрая подготовка окружения..."
apt update -y && apt install -y wget curl ca-certificates

# --- SILENT INSTALL 3X-UI ---
echo "[STEP 2] Установка 3X-UI в автоматическом режиме..."

# Переменные для оригинального скрипта, чтобы он не задавал вопросов в терминале
export APP_VERSION="last"
export INSTALL_PORT="2053"
export INSTALL_USER="admin"
export INSTALL_PASS="admin_password_change_me"

# Запуск официального установщика в неинтерактивном режиме (если поддерживается)
# либо стандартный проброс ответов по умолчанию через 'yes'
yes n | bash <(curl -fsSL https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

echo "=============================="
echo "[DONE] 3X-UI установлен без лишних вопросов"
echo "Порт по умолчанию: 2053 (Измените вручную!)"
echo "Лог: $LOG_FILE"
echo "=============================="
