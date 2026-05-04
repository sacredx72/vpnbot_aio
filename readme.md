telegram bot to manage servers (inside the bot)

- VLESS (Reality OR Websocket + All-in-One fallbacks)
- VMess (WebSocket + TCP + H2)
- Trojan (WebSocket + H2)
- Shadowsocks (WebSocket + TCP)
- NaiveProxy
- OpenConnect
- Wireguard
- Amnezia
- AdguardHome
- MTProto
- PAC
- automatic ssl
- Xray All-in-One architecture with Nginx fallbacks

---

environment: ubuntu 22.04/24.04, debian 11/12

## Install (AIO Branch - qwen):

```shell
wget -O- https://raw.githubusercontent.com/sacredx72/vpnbot_aio/qwen/install.sh | bash -s YOUR_TELEGRAM_BOT_KEY qwen
```

## Install (Master Branch):

```shell
wget -O- https://raw.githubusercontent.com/sacredx72/vpnbot_aio/master/scripts/init.sh | sh -s YOUR_TELEGRAM_BOT_KEY master
```

#### Restart:
```shell
make r
```

#### autoload:
```shell
crontab -e
```
add `@reboot cd /root/vpnbot_aio && make r` and save

## Features:

### All-in-One Architecture (qwen branch)
- Multiple protocols through single port 443
- Fallback routing by path and ALPN
- PROXY protocol v2 for real IP transmission
- WebSocket, TCP, H2 transports
- Automatic SSL certificates

### Supported Protocols:
- **VLESS**: `/vlws` (WebSocket), `/vltc` (TCP)
- **VMess**: `/vmws` (WebSocket), `/vmtc` (TCP)
- **Trojan**: `/trojanws` (WebSocket), `/trh2` (H2)
- **Shadowsocks**: `/ssws` (WebSocket), `/sstc` (TCP)

## Management:

All configuration is done through Telegram bot interface:
- Start bot and send `/start`
- Use menu buttons to configure protocols
- Generate subscriptions for clients
- Switch transports via bot commands
