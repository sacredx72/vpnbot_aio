#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  VPNBot AIO - All-in-One Installation${NC}"
echo -e "${GREEN}  Branch: qwen (Xray All-in-One)${NC}"
echo -e "${GREEN}========================================${NC}"

# Проверка аргументов
if [ -z "$1" ]; then
    echo -e "${RED}Ошибка: Не указан ключ Telegram бота!${NC}"
    echo "Использование: $0 YOUR_TELEGRAM_BOT_KEY [branch]"
    echo "Пример: $0 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew1F master"
    exit 1
fi

BOT_KEY="$1"
BRANCH="${2:-qwen}"

echo -e "${YELLOW}Ключ бота: ${BOT_KEY:0:10}...${NC}"
echo -e "${YELLOW}Ветка: ${BRANCH}${NC}"

# Обновление пакетов
echo -e "${YELLOW}[1/6] Обновление списков пакетов...${NC}"
apt update || { echo -e "${RED}Ошибка обновления apt${NC}"; exit 1; }

# Установка зависимостей
echo -e "${YELLOW}[2/6] Установка необходимых пакетов...${NC}"
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    make \
    git \
    iptables \
    iproute2 \
    xtables-addons-common \
    xtables-addons-dkms \
    wget || { echo -e "${RED}Ошибка установки пакетов${NC}"; exit 1; }

# Установка Docker
echo -e "${YELLOW}[3/6] Установка Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh || { echo -e "${RED}Ошибка установки Docker${NC}"; exit 1; }
    rm -f get-docker.sh
else
    echo -e "${GREEN}Docker уже установлен${NC}"
fi

# Клонирование репозитория
echo -e "${YELLOW}[4/6] Клонирование репозитория vpnbot_aio (ветка: ${BRANCH})...${NC}"
cd /root || exit 1

# Удаляем старую директорию если существует
if [ -d "vpnbot_aio" ]; then
    echo -e "${YELLOW}Удаление старой директории vpnbot_aio...${NC}"
    rm -rf vpnbot_aio
fi

git clone --branch ${BRANCH} https://github.com/sacredx72/vpnbot_aio.git || {
    echo -e "${RED}Ошибка клонирования репозитория. Проверьте название ветки.${NC}"
    exit 1
}

cd vpnbot_aio || exit 1

# Создание конфигурационного файла
echo -e "${YELLOW}[5/6] Создание конфигурации...${NC}"
cat > ./app/config.php << EOF
<?php

\$c = ['key' => '${BOT_KEY}'];
EOF

echo -e "${GREEN}Конфигурация создана: ./app/config.php${NC}"

# Запуск контейнеров
echo -e "${YELLOW}[6/6] Запуск контейнеров...${NC}"
make u || { echo -e "${RED}Ошибка запуска контейнеров${NC}"; exit 1; }

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Установка завершена успешно!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "1. Запустите Telegram бота и отправьте команду /start"
echo "2. Настройте сервер через меню бота"
echo ""
echo -e "${YELLOW}Полезные команды:${NC}"
echo "  make r          - Перезапуск всех сервисов"
echo "  make d          - Остановка сервисов"
echo "  make ps         - Показать статус контейнеров"
echo "  make logs       - Просмотр логов"
echo "  make php        - Консоль PHP контейнера"
echo "  make tg         - Консоль Telegram бота"
echo ""
echo -e "${YELLOW}Автозагрузка при старте системы:${NC}"
echo "  crontab -e"
echo "  Добавьте строку: @reboot cd /root/vpnbot_aio && make r"
echo ""
echo -e "${GREEN}Репозиторий: https://github.com/sacredx72/vpnbot_aio${NC}"
echo -e "${GREEN}Ветка: ${BRANCH}${NC}"
