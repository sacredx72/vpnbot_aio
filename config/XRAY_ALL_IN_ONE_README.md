# Xray All-in-One конфигурация

Этот проект теперь поддерживает интеграцию множественных протоколов через ядро Xray по принципу "все в одном", следуя примеру [XTLS/Xray-examples/All-in-One-fallbacks-Nginx](https://github.com/XTLS/Xray-examples/tree/main/All-in-One-fallbacks-Nginx).

## Поддерживаемые протоколы

### Через TLS (порт 443)
Основной входной порт использует VLESS + TCP + TLS с fallback'ами для маршрутизации трафика:

1. **VLESS + WebSocket** (`/vlws`)
2. **VMess + WebSocket** (`/vmws`)
3. **Trojan + WebSocket** (`/trojanws`)
4. **Shadowsocks + WebSocket** (`/ssws`) - порт 4001
5. **VLESS + TCP + HTTP Obfuscation** (`/vltc`)
6. **VMess + TCP + HTTP Obfuscation** (`/vmtc`)
7. **Shadowsocks + TCP + HTTP Obfuscation** (`/sstc`) - порт 4002
8. **Trojan + H2** (`alpn: h2`)
9. **VLESS + H2** (`/vlh2`)
10. **VMess + H2** (`/vmh2`)
11. **Shadowsocks + H2** (`/ssh2`) - порт 4003
12. **Nginx fallback** - обычный веб-трафик

## Структура конфигурации

### Главный inbound (VLESS-TCP-TLS)
- **Порт**: 443
- **Протокол**: VLESS
- **Безопасность**: TLS
- **Fallbacks**: Маршрутизация на основе пути (path) или ALPN

### Внутренние inbound'ы
Каждый протокол имеет свой собственный inbound, который слушает на:
- Unix сокете (например, `@vless-ws`)
- localhost порту (например, `127.0.0.1:4001`)

## Настройка клиентов

### Генерация UUID
Для каждого клиента необходим уникальный UUID. Сгенерируйте его командой:
```bash
uuidgen
```

### Добавление клиентов в конфигурацию

Откройте `/workspace/config/xray.json` и добавьте клиентов в соответствующие секции:

#### VLESS клиенты
```json
{
    "tag": "Vless-TCP-TLS",
    "settings": {
        "clients": [
            {
                "email": "user1@vless",
                "id": "ВАШ_UUID",
                "flow": "xtls-rprx-vision",
                "level": 0
            }
        ]
    }
}
```

#### VMess клиенты
```json
{
    "listen": "@vmess-ws",
    "settings": {
        "clients": [
            {
                "email": "user1@vmess",
                "id": "ВАШ_UUID",
                "level": 0
            }
        ]
    }
}
```

#### Trojan клиенты
```json
{
    "listen": "@trojan-ws",
    "settings": {
        "clients": [
            {
                "email": "user1@trojan",
                "password": "ВАШ_ПАРОЛЬ",
                "level": 0
            }
        ]
    }
}
```

#### Shadowsocks клиенты
```json
{
    "tag": "shadowsocks-ws",
    "settings": {
        "method": "chacha20-ietf-poly1305",
        "password": "ВАШ_ПАРОЛЬ"
    }
}
```

## URL для подключения клиентов

### VLESS WebSocket
```
vless://{UUID}@DOMAIN:443?encryption=none&security=tls&type=ws&path=%2Fvlws&host=DOMAIN#VLESS-WS
```

### VMess WebSocket
```
vmess://{BASE64(JSON)}
```

### Trojan WebSocket
```
trojan://{PASSWORD}@DOMAIN:443?security=tls&type=ws&path=%2Ftrojanws&host=DOMAIN#Trojan-WS
```

### Shadowsocks WebSocket
```
ss://{BASE64(METHOD:PASSWORD@DOMAIN:443?path=%2Fssws)}#Shadowsocks-WS
```

## Интеграция с Nginx

Nginx используется как fallback для обычного веб-трафика. Конфигурация Nginx должна:
1. Слушать порт 80 и 443
2. Проксировать запросы к PHP backend
3. Обслуживать статические файлы

## Мониторинг и статистика

Конфигурация включает API для мониторинга:
- **API порт**: 62789 (localhost)
- **Сервисы**: HandlerService, LoggerService, StatsService

Для получения статистики используйте gRPC client или совместимые инструменты.

## Расширение конфигурации

### Добавление нового протокола

1. Добавьте новый inbound в секцию `inbounds`:
```json
{
    "listen": "@newprotocol",
    "protocol": "НАЗВАНИЕ_ПРОТОКОЛА",
    "settings": { ... },
    "streamSettings": { ... }
}
```

2. Добавьте fallback в главный inbound:
```json
{
    "path": "/newpath",
    "dest": "@newprotocol",
    "xver": 2
}
```

3. Перезапустите Xray:
```bash
docker restart xray-${VER}
```

## Безопасность

- Используйте сложные пароли и UUID
- Регулярно обновляйте сертификаты TLS
- Включите OCSP Stapling (настроено на 3600 секунд)
- Минимальная версия TLS: 1.2
- Настроенные cipher suites для максимальной безопасности

## Блокировка нежелательного трафика

В конфигурации включены правила для блокировки:
- Частных IP адресов (geoip:private)
- BitTorrent протокола

## Логирование

- **Уровень**: info
- **Расположение**: /logs/xray
- **Доступ**: через Docker volumes

## Пример полной ссылки для VLESS+WS

```
vless://550e8400-e29b-41d4-a716-446655440000@example.com:443?encryption=none&security=tls&type=ws&path=%2Fvlws&host=example.com&sni=example.com#VLESS-WS
```

## Troubleshooting

### Проверка конфигурации
```bash
xray test -config /xray.json
```

### Просмотр логов
```bash
docker logs xray-${VER}
```

### Проверка доступности портов
```bash
netstat -tlnp | grep -E '443|4001|4002|4003'
```

## Ссылки

- [Официальная документация Xray](https://xtls.github.io/)
- [Примеры конфигураций](https://github.com/XTLS/Xray-examples)
- [VLESS протокол](https://github.com/XTLS/VLESS)
- [Trojan протокол](https://trojan-gfw.github.io/trojan/)
