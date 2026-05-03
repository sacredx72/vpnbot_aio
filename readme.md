telegram bot to manage servers (inside the bot)

- VLESS (Reality OR Websocket)
- NaiveProxy
- OpenConnect
- Wireguard
- Amnezia
- AdguardHome
- MTProto
- PAC
- automatic ssl

---
environment: ubuntu 22.04/24.04, debian 11/12

## Install:

### One-line installation:
```shell
wget -O- https://your-server/install.sh | sh -s YOUR_TELEGRAM_BOT_KEY master
```

Or using the script from the repository:
```shell
wget -O- https://raw.githubusercontent.com/mercurykd/vpnbot/master/install.sh | sh -s YOUR_TELEGRAM_BOT_KEY master
```

#### Parameters:
- `YOUR_TELEGRAM_BOT_KEY` - your Telegram bot token (required)
- `master` - branch name (optional, default: master)

#### Commands:
- **Restart:**
  ```shell
  make r
  ```

- **Check status:**
  ```shell
  make ps
  ```

- **View logs:**
  ```shell
  make l
  ```

- **Auto-start on reboot:**
  ```shell
  make cron
  ```

- **Uninstall:**
  ```shell
  make delete
  ```
