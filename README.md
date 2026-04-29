<div align="center">

🌐 **Язык / Language:** [🇷🇺 Русский](README.md) | [🇬🇧 English](README_EN.md)

</div>

<div align="center">

```
███╗   ██╗ █████╗ ██╗██╗   ██╗███████╗    ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
████╗  ██║██╔══██╗██║██║   ██║██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██╔██╗ ██║███████║██║██║   ██║█████╗      ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██║╚██╗██║██╔══██║██║╚██╗ ██╔╝██╔══╝      ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║ ╚████║██║  ██║██║ ╚████╔╝ ███████╗    ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
                                                                         MANAGER
```

**Профессиональный менеджер приватного прокси-сервера**
Caddy 2 · NaiveProxy · Let's Encrypt · Telegram · SSH Hardening · Диагностика

---

[![Version](https://img.shields.io/badge/version-3.9.0-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivanstudiya-cpu/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.shellcheck.net)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Caddy](https://img.shields.io/badge/Caddy-auto-00ADD8?style=for-the-badge&logo=caddy&logoColor=white)](https://caddyserver.com)
[![License](https://img.shields.io/badge/License-MIT-58A6FF?style=for-the-badge)](LICENSE)

---

[**Быстрый старт**](#-быстрый-старт) • [**Возможности**](#-возможности) • [**Диагностика**](#-диагностика) • [**SSH Hardening**](#-ssh-hardening) • [**Клиенты**](#-клиентские-приложения) • [**FAQ**](#-faq)

</div>

---

## 🤔 Что это

**NaiveProxy** маскирует трафик под браузер Chrome используя настоящий Chromium network stack. DPI и цензоры видят легитимный HTTPS/2 — и пропускают.

**NaiveProxy Manager** — один bash-скрипт который превращает голый VPS в полноценный защищённый прокси-сервер. Без Docker, без GUI панелей, без лишних зависимостей.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────┐     ┌──────────────┐
│  Твой       │     │  Цензор/DPI  │     │   Твой VPS        │     │              │
│  телефон    │────▶│              │────▶│   Caddy +         │────▶│  Интернет    │
│  ноутбук    │     │  Видит Chrome│     │   forwardproxy    │     │              │
└─────────────┘     │  HTTPS/2 ✓   │     │   probe_resist.   │     └──────────────┘
 naive-client        └──────────────┘     └───────────────────┘
 Chromium stack       Пропускает           TLS от Let's Encrypt
```

---

## ⚡ Быстрый старт

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh)
```

### Что происходит при установке:

```
[1/5] 🔄  Обновление системы
         apt upgrade + unattended-upgrades
         → можно пропустить: нажми n

[2/5] 🔒  SSH Hardening                              [ОПЦИОНАЛЬНО]
         ED25519 ключ · авто-сохранение · новый пользователь · Fail2Ban
         → пропусти если SSH уже настроен: нажми n

[3/5] 📦  Сборка Caddy
         git clone klzgrad/forwardproxy@naive
         xcaddy build с автоопределением версии  ~5-15 минут

[4/5] ⚙️   Настройка
         Caddyfile (:443, domain) · systemd · UFW · BBR · Telegram

[5/5] ✅  Готово
         URI + JSON конфиги + QR код для телефона
```

---

## ✨ Возможности

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Безопасность
- **SSH Hardening** — ED25519 ключ, смена порта, блокировка root
- **Авто-сохранение SSH ключа** — в `/etc/naiveproxy/ssh_private_key`
- **Fail2Ban 3 уровня** — брутфорс(7д) / DDoS(7д) / рецидив(30д)
- **UFW** — deny all incoming + блокировка портов сканеров
- **probe_resistance** — выглядит как обычный сайт
- **Страница-камуфляж** — IT-блог DevStack

### 📡 Прокси
- **Автоматический TLS** — Let's Encrypt через Caddy
- **HTTP/2 + HTTP/3** — явно включены
- **QR код** — подключение одним сканом с телефона
- **Мультипользователь** — добавление без рестарта
- **Несколько доменов** — на одном сервере
- **TCP BBR** — опциональное ускорение

</td>
<td width="50%" valign="top">

### 🔍 Диагностика
- **7 блоков проверок** — Caddy, конфиг, TLS, сеть, firewall, ресурсы, логи
- **Цветной отчёт** — ✅ / ⚠️ / ❌ по каждому пункту
- **Анализ логов** — ошибки, CONNECT туннели
- **Отправка в Telegram** — отчёт одной командой

### 🤖 Автоматизация
- **Telegram-бот** — алерты + статистика по команде
- **Watchdog** — cron каждые 5 минут, автоперезапуск
- **Self-update** — обновление скрипта с GitHub
- **Проверка сертификата** — алерт при < 7 дней

</td>
</tr>
</table>

---

## 📋 Требования

| | |
|--|--|
| **ОС** | Ubuntu 20.04 / 22.04 / 24.04 |
| **Права** | root |
| **Домен** | A-запись → IP сервера |
| **Порты** | 80/tcp · 443/tcp · 443/udp |
| **RAM** | от 512 MB |
| **Диск** | от 1 GB |

---

## 🎮 Меню

```
──────────────────────────────────────────────────────
   NaiveProxy Manager v3.9.0
   Статус: ● работает  │  Домен: proxy.example.com
   Telegram: подключён  │  Юзеров: 3  │  SSH: 52847
──────────────────────────────────────────────────────
   1)  Установить NaiveProxy       10) Логи
   2)  Статус + сертификат         11) Удалить NaiveProxy
   3)  Клиентский конфиг + QR      16) 🔍 Диагностика
   4)  Пользователи                ──────────────────
   5)  Домены                      12) 🔒 SSH Hardening
   6)  Мониторинг + статистика     13) 🔄 Обновить систему
   7)  Настройка Telegram          14) ⬆️  Обновить скрипт
   8)  Перезапустить Caddy         15) 🎭 Обновить камуфляж
   9)  Обновить Caddy
──────────────────────────────────────────────────────
```

### CLI команды:

```bash
sudo bash naiveproxy.sh install        # Полная установка
sudo bash naiveproxy.sh diagnose       # Диагностика системы
sudo bash naiveproxy.sh status         # Статус + TLS сертификат
sudo bash naiveproxy.sh config         # Конфиг + QR код
sudo bash naiveproxy.sh qr             # Только QR код
sudo bash naiveproxy.sh cert           # Только сертификат
sudo bash naiveproxy.sh users          # Управление пользователями
sudo bash naiveproxy.sh domains        # Управление доменами
sudo bash naiveproxy.sh monitor        # Мониторинг + статистика
sudo bash naiveproxy.sh restart        # Перезапустить Caddy
sudo bash naiveproxy.sh update         # Обновить Caddy
sudo bash naiveproxy.sh logs           # Логи в реальном времени
sudo bash naiveproxy.sh tg-stats       # Статистика в Telegram
sudo bash naiveproxy.sh ssh-hardening  # SSH Hardening
sudo bash naiveproxy.sh ssh-key        # Показать SSH приватный ключ
sudo bash naiveproxy.sh sysupdate      # Обновление системы
sudo bash naiveproxy.sh self-update    # Обновить скрипт с GitHub
sudo bash naiveproxy.sh camouflage     # Переустановить камуфляж
sudo bash naiveproxy.sh version        # Показать версию
sudo bash naiveproxy.sh remove         # Удалить всё
```

---

## 🔍 Диагностика

```bash
sudo bash naiveproxy.sh diagnose
```

Проверяет **7 блоков** и выводит цветной отчёт:

```
[1/7] Caddy          — найден · запущен · naive padding · модуль
[2/7] Конфигурация   — Caddyfile · формат :443,domain · пользователи
[3/7] TLS и сеть     — DNS · порты · ALPN h2 · сертификат
[4/7] Firewall       — UFW · Fail2Ban · заблокированные порты
[5/7] Ресурсы        — RAM · диск · нагрузка CPU
[6/7] Логи           — ошибки · CONNECT туннели
[7/7] Версия         — актуальность · SSH hardening

📊 ИТОГ: ✅ 18  ⚠️ 0  ❌ 0
🎉 Всё работает отлично!
```

Результат можно отправить в Telegram одним нажатием.

---

## ⚠️ Критически важно — Caddyfile

```bash
# ❌ НЕПРАВИЛЬНО — клиенты не подключаются:
your-domain.com:443 { ... }

# ✅ ПРАВИЛЬНО — :443 должен быть ПЕРВЫМ:
:443, your-domain.com {
  tls your@email.com
  forward_proxy {
    basic_auth USERNAME PASSWORD
    hide_ip
    hide_via
    probe_resistance
  }
  file_server { root /var/www/html }
}
```

Скрипт генерирует правильный конфиг автоматически начиная с v3.7.0.

---

## 🔒 SSH Hardening

```bash
sudo bash naiveproxy.sh ssh-hardening
```

> 💡 **Можно пропустить** если SSH уже настроен. Нажми `n` при установке.

**5 шагов:** новый sudo-пользователь → ED25519 ключ (авто-сохранение) → смена порта → sshd_config → UFW + Fail2Ban

```bash
# Скачать SSH ключ на компьютер:
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy
chmod 600 ~/.ssh/id_naiveproxy
ssh -i ~/.ssh/id_naiveproxy -p NEW_PORT user@YOUR_IP

# Показать ключ в любой момент:
sudo bash naiveproxy.sh ssh-key
```

### Fail2Ban — 3 уровня:

| Уровень | Триггер | Бан |
|---------|---------|-----|
| Брутфорс | 3 неверных пароля | **7 дней** |
| DDoS | 10 попыток за 1 мин | **7 дней** |
| Рецидив | Повторные нарушения | **30 дней** |

---

## 🤖 Telegram-бот

1. [@BotFather](https://t.me/BotFather) → `/newbot` → токен
2. [@userinfobot](https://t.me/userinfobot) → chat_id
3. Меню → **7) Настройка Telegram**

| Событие | Сообщение |
|---------|-----------|
| Установка | ✅ NaiveProxy запущен |
| Caddy упал | 🔴 Упал → автоперезапуск |
| SSH Hardening | 🔒 Порт: 52847 |
| Сертификат < 7 дней | ⚠️ Осталось 5 дней! |
| Диагностика | 🔍 Полный отчёт |
| Статистика | 📊 Трафик · RAM · Диск |

---

## 📱 Клиентские приложения

### URI (вставить в любой клиент):
```
naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

### JSON (naive-client Windows/Linux):
```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://USERNAME:PASSWORD@YOUR_DOMAIN:443",
  "log": "naive.log"
}
```

### Рекомендуемые клиенты:

| Клиент | Платформа | Способ |
|--------|-----------|--------|
| [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) | Android | QR / URI |
| [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) | iPhone | URI |
| [Hiddify](https://github.com/hiddify/hiddify-next/releases) | Windows / macOS | URI |
| [naive](https://github.com/klzgrad/naiveproxy/releases) | Windows / Linux | config.json |
| [sing-box](https://github.com/SagerNet/sing-box) | Все платформы | JSON конфиг |

> ⚠️ **v2rayNG не поддерживает NaiveProxy.** Используй NekoBox или Hiddify.

---

## 🎭 Страница-камуфляж

По умолчанию — IT-блог **DevStack**. Путь: `/var/www/html/index.html`

```bash
# Заменить своей страницей:
scp my_site.html user@YOUR_IP:/var/www/html/index.html

# Восстановить DevStack:
sudo bash naiveproxy.sh camouflage
```

---

## 📁 Файловая структура

```
/usr/local/bin/caddy
/etc/caddy/Caddyfile                       (chmod 600)
/etc/naiveproxy/
├── naive.conf                             (chmod 600)
├── users.conf                             (chmod 600)
├── ssh_private_key                        ← SSH ключ (авто-сохранение)
├── ssh_public_key
├── monitor.sh
├── .ssh_hardened
├── .sysupdate_done
└── backups/
/etc/fail2ban/jail.local
/var/www/html/index.html                   ← камуфляжная страница
/var/log/caddy/access.log
/var/log/caddy/naive.log
```

---

## ❓ FAQ

<details>
<summary><b>Клиент не подключается</b></summary>

Запусти диагностику:
```bash
sudo bash naiveproxy.sh diagnose
```

Или проверь вручную:
```bash
# Caddyfile должен быть: :443, domain {
cat /etc/caddy/Caddyfile | grep ":443"

# ALPN должен быть h2:
openssl s_client -connect YOUR_DOMAIN:443 -alpn h2 2>/dev/null | grep "ALPN protocol"
```

</details>

<details>
<summary><b>Как скачать SSH ключ на компьютер</b></summary>

```bash
# Linux/macOS:
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy
chmod 600 ~/.ssh/id_naiveproxy

# Windows PowerShell:
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key $HOME\.ssh\id_naiveproxy
```

</details>

<details>
<summary><b>Заблокировал себя после SSH hardening</b></summary>

Зайди через консоль хостинга (VNC/KVM):
```bash
ufw allow 22/tcp && systemctl restart sshd
```

</details>

<details>
<summary><b>Caddy не получает TLS сертификат</b></summary>

```bash
dig +short YOUR_DOMAIN        # должен вернуть IP сервера
ss -tlnp | grep :80           # порт 80 должен слушать Caddy
journalctl -u caddy -n 50 | grep -i "acme\|error\|cert"
```

</details>

<details>
<summary><b>Как проверить что IP изменился</b></summary>

```bash
curl.exe --proxy socks5://127.0.0.1:1080 https://ifconfig.me
```

</details>

---

## 📊 Сравнение

| Функция | **NaiveProxy Manager** | x-ui / 3x-ui | Marzban |
|---------|:---:|:---:|:---:|
| Без Docker | ✅ | ❌ | ❌ |
| SSH Hardening | ✅ | ❌ | ❌ |
| SSH ключ авто-сохранение | ✅ | ❌ | ❌ |
| QR код | ✅ | ❌ | ❌ |
| Диагностика системы | ✅ | ❌ | ❌ |
| Fail2Ban 3 уровня | ✅ | ❌ | ❌ |
| Страница-камуфляж | ✅ | ❌ | ❌ |
| Self-Update | ✅ | ❌ | ❌ |
| Проверка сертификата | ✅ | ❌ | ❌ |
| Правильный Caddyfile | ✅ v3.7+ | — | — |
| Telegram алерты | ✅ | ✅ | ✅ |
| ShellCheck passing | ✅ | — | — |

---

## 📜 Changelog

<details>
<summary><b>v3.9.0</b> — System Diagnostics ← ТЕКУЩАЯ</summary>

- ✨ Полная диагностика системы — 7 блоков, 18+ проверок
- ✨ Цветной отчёт ✅/⚠️/❌ с рекомендациями
- ✨ Анализ логов Caddy на ошибки
- ✨ Отправка отчёта диагностики в Telegram
- 🆕 CLI: `diagnose`
- 🆕 Меню: пункт 16

</details>

<details>
<summary><b>v3.8.0</b> — Security & UX</summary>

- ✨ SSH ключ авто-сохранение + scp команда
- ✨ QR код в терминале
- 🛡️ UFW deny all + блокировка портов сканеров
- 🛡️ Fail2Ban 3 уровня защиты
- 🆕 CLI: `qr`, `ssh-key`

</details>

<details>
<summary><b>v3.7.0</b> — Critical Caddyfile Fix</summary>

- 🔴 Критический фикс: `:443, domain` вместо `domain:443`
- ✅ Подтверждено: NekoBox Android + naive.exe Windows работают

</details>

<details>
<summary><b>v3.6.0</b> — Critical Build Fix</summary>

- 🔴 build_caddy: git clone `klzgrad/forwardproxy@naive` напрямую
- 🔴 Автоопределение совместимой версии Caddy из go.mod

</details>

<details>
<summary><b>v3.0–3.5</b> — Core Features</summary>

- Обновление системы, SSH Hardening, Self-update, Домены, Камуфляж, Security Audit

</details>

---

## 📄 Лицензия

MIT © [ivanstudiya-cpu](https://github.com/ivanstudiya-cpu)

---

<div align="center">

**Если скрипт помог — поставь ⭐ звезду**

[![GitHub stars](https://img.shields.io/github/stars/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivanstudiya-cpu/naiveproxy/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=58A6FF)](https://github.com/ivanstudiya-cpu/naiveproxy/network)

*NaiveProxy Manager · Caddy 2 · klzgrad/forwardproxy@naive · Ubuntu*

</div>
