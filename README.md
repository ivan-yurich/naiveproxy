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
Caddy 2 · NaiveProxy · Let's Encrypt · Telegram · SSH Hardening · Self-Update

---

[![Version](https://img.shields.io/badge/version-3.7.0-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivanstudiya-cpu/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.shellcheck.net)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Caddy](https://img.shields.io/badge/Caddy-auto-00ADD8?style=for-the-badge&logo=caddy&logoColor=white)](https://caddyserver.com)
[![License](https://img.shields.io/badge/License-MIT-58A6FF?style=for-the-badge)](LICENSE)

---

[**Быстрый старт**](#-быстрый-старт) • [**Что нового**](#-что-нового-в-v360) • [**Возможности**](#-возможности) • [**SSH Hardening**](#-ssh-hardening) • [**Клиенты**](#-клиентские-приложения) • [**FAQ**](#-faq)

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

Или скачать вручную:

```bash
wget -O naiveproxy.sh https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh
chmod +x naiveproxy.sh && sudo bash naiveproxy.sh
```

### Что происходит при первом запуске:

```
[1/5] 🔄  Обновление системы
         apt upgrade + unattended-upgrades
         → можно пропустить: нажми n

[2/5] 🔒  SSH Hardening                              [ОПЦИОНАЛЬНО]
         ED25519 ключ · новый пользователь · смена порта · Fail2Ban
         → пропусти если SSH уже настроен: нажми n

[3/5] 📦  Сборка Caddy
         git clone klzgrad/forwardproxy@naive
         xcaddy build с автоопределением версии  ~5-15 минут

[4/5] ⚙️   Настройка
         Caddyfile (h1/h2/h3) · systemd · UFW · BBR · Telegram

[5/5] ✅  Готово
         URI + JSON конфиги для всех клиентов
```

---

## 🆕 Что нового в v3.7.0

### 🔴 Критический фикс v3.7.0 — порядок в Caddyfile

**Проблема во всех версиях до v3.7.0:**

NekoBox, Hiddify и другие клиенты не могли подключиться.
В логах был `status:0` и пустой `user_id`.

**Причина:** неправильный порядок домена и порта в Caddyfile:

```
# НЕПРАВИЛЬНО — клиенты не подключаются:
proxy.example.com:443 {
  ...
}

# ПРАВИЛЬНО — работает:
:443, proxy.example.com {
  ...
}
```

Согласно официальному README klzgrad/naiveproxy: **`:443` должен быть первым**.

---

### 🔴 Критический фикс v3.6.0 — сборка Caddy

**Проблема в v3.5.0 и ниже:**

Xcaddy игнорировал `@naive` ветку и подтягивал стандартный `caddyserver/forwardproxy` без naive padding протокола:

```
negotiated padding type: None   ← клиент и сервер не договорились
SSL_ERROR_SYSCALL                ← NekoBox/Hiddify не подключаются
```

**Причина:** xcaddy не мог корректно сделать replace модуля когда `go.mod` объявляет путь как `github.com/caddyserver/forwardproxy` а не `github.com/klzgrad/forwardproxy`.

**Решение в v3.6.0:**

```bash
# Старый способ — НЕ РАБОТАЛ
xcaddy build \
  --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

# Новый способ — РАБОТАЕТ
git clone -b naive --depth 1 https://github.com/klzgrad/forwardproxy.git /tmp/fp
CADDY_VER=$(grep 'caddyserver/caddy/v2' /tmp/fp/go.mod | awk '{print $2}')
xcaddy build "${CADDY_VER}" --with github.com/caddyserver/forwardproxy=/tmp/fp
```

Скрипт теперь:
1. **Клонирует** `klzgrad/forwardproxy` ветку `naive` напрямую через git
2. **Читает** точную версию Caddy из `go.mod` forwardproxy (совместимость гарантирована)
3. **Собирает** именно эту версию Caddy с локальным модулем
4. **Проверяет** наличие `Padding` строк в бинарнике через `strings`

### 🔴 Критический фикс — HTTP/2 в Caddyfile

**Проблема:** Caddy мог не включать HTTP/2 автоматически:
```
HTTP/2 skipped because it requires TLS
ALPN: server accepted http/1.1   ← должно быть h2!
```

**Решение:** Явный `servers` блок в глобальном конфиге:
```
{
    servers :443 {
        protocols h1 h2 h3
    }
}
```

### Все изменения v3.6.0

| Тип | Изменение |
|-----|-----------|
| 🔴 Критический фикс | build_caddy: git clone naive + автоопределение версии Caddy |
| 🔴 Критический фикс | Caddyfile: явное включение `protocols h1 h2 h3` |
| ✅ Улучшение | Проверка naive padding в бинарнике через `strings` |
| ✅ Улучшение | Автоустановка git если не установлен |
| ✅ Улучшение | Очистка временных файлов после сборки |
| ✅ Улучшение | Информативные сообщения во время сборки |

---

## ✨ Возможности

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Безопасность сервера
- SSH Hardening — ED25519 ключ, смена порта, блокировка root
- Fail2Ban — 3 попытки → бан на 24 часа
- UFW — только нужные порты, автовключение
- unattended-upgrades — security-патчи ежедневно
- probe_resistance — выглядит как обычный сайт
- 🎭 Страница-камуфляж — IT-блог DevStack

### 📡 Прокси
- Автоматический TLS — Let's Encrypt через Caddy
- HTTP/2 + HTTP/3 (QUIC) — явно включены
- Мультипользователь — добавление без рестарта
- Несколько доменов — на одном сервере
- TCP BBR — опциональное ускорение

</td>
<td width="50%" valign="top">

### 🤖 Автоматизация
- Telegram-бот — алерты + статистика по команде
- Watchdog — cron каждые 5 минут, автоперезапуск
- Автообновление Caddy — каждое воскресенье 3:00
- Self-update — обновление скрипта с GitHub
- Проверка сертификата — срок + алерт при < 7 дней

### 🛡️ Качество кода
- `set -euo pipefail` — строгий режим
- SHA256-верификация Go бинарника
- `grep -vF` вместо `sed` — нет regex injection
- `--data-urlencode` для Telegram
- `trap` для cleanup временных файлов
- Валидация всех входных данных
- ShellCheck passing — 0 предупреждений

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
| **Доп.** | git (ставится автоматически) |

---

## 🎮 Меню

```
──────────────────────────────────────────────────────
   NaiveProxy Manager v3.7.0
   Статус: ● работает  │  Домен: proxy.example.com
   Telegram: подключён  │  Юзеров: 3  │  SSH: 52847
──────────────────────────────────────────────────────
   1)  Установить NaiveProxy       9)  Обновить Caddy
   2)  Статус + сертификат         10) Логи
   3)  Клиентский конфиг           11) Удалить NaiveProxy
   4)  Пользователи                ──────────────────
   5)  Домены                      12) 🔒 SSH Hardening
   6)  Мониторинг + статистика     13) 🔄 Обновить систему
   7)  Настройка Telegram          14) ⬆️  Обновить скрипт
   8)  Перезапустить Caddy         15) 🎭 Обновить камуфляж
──────────────────────────────────────────────────────
```

### CLI команды:

```bash
sudo bash naiveproxy.sh install        # Полная установка
sudo bash naiveproxy.sh status         # Статус + TLS сертификат
sudo bash naiveproxy.sh config         # Клиентский конфиг
sudo bash naiveproxy.sh cert           # Только сертификат
sudo bash naiveproxy.sh users          # Управление пользователями
sudo bash naiveproxy.sh domains        # Управление доменами
sudo bash naiveproxy.sh monitor        # Мониторинг + статистика
sudo bash naiveproxy.sh restart        # Перезапустить Caddy
sudo bash naiveproxy.sh update         # Обновить Caddy
sudo bash naiveproxy.sh logs           # Логи в реальном времени
sudo bash naiveproxy.sh tg-stats       # Статистика в Telegram
sudo bash naiveproxy.sh ssh-hardening  # SSH Hardening
sudo bash naiveproxy.sh sysupdate      # Обновление системы
sudo bash naiveproxy.sh self-update    # Обновить скрипт с GitHub
sudo bash naiveproxy.sh camouflage     # Переустановить камуфляж
sudo bash naiveproxy.sh version        # Показать версию
sudo bash naiveproxy.sh remove         # Удалить всё
```

---

## 🔒 SSH Hardening

```bash
sudo bash naiveproxy.sh ssh-hardening
```

При первой установке скрипт **спрашивает**:
```
Выполнить SSH Hardening? [Y/n]:
```

> 💡 **Можно пропустить** если SSH уже настроен. Просто нажми `n` — скрипт перейдёт к установке NaiveProxy.

**5 шагов:**

**① Новый sudo-пользователь** — с паролем (или случайным)

**② ED25519 SSH-ключ** — генерируется если нет
```bash
echo "ВСТАВЬ_КЛЮЧ" > ~/.ssh/id_naiveproxy && chmod 600 ~/.ssh/id_naiveproxy
ssh -i ~/.ssh/id_naiveproxy -p НОВЫЙ_ПОРТ user@YOUR_IP
```

**③ Смена SSH порта** — вручную или случайный (49000-65000)

**④ sshd_config**
```ini
PermitRootLogin        no
PasswordAuthentication no
MaxAuthTries           3
LoginGraceTime         30
X11Forwarding          no
```

**⑤ UFW + Fail2Ban** — новый порт открывается ДО закрытия старого, 3 попытки → бан 24ч

---

## 🤖 Telegram-бот

1. [@BotFather](https://t.me/BotFather) → `/newbot` → токен
2. [@userinfobot](https://t.me/userinfobot) → chat_id
3. Меню → **7) Настройка Telegram**

| Событие | Сообщение |
|---------|-----------|
| Установка | ✅ NaiveProxy запущен |
| Caddy упал | 🔴 Упал → автоперезапуск |
| Перезапуск не помог | ❌ Нужно вмешательство |
| Caddy обновлён | 🔄 v2.8 → v2.9 |
| Скрипт обновлён | ⬆️ v3.5 → v3.6 |
| SSH Hardening | 🔒 Порт: 52847 |
| Сертификат < 7 дней | ⚠️ Осталось 5 дней! |
| Статистика | 📊 Полный отчёт |

---

## 📱 Клиентские приложения

### URI:
```
naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

### JSON (naive-client):
```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://USERNAME:PASSWORD@YOUR_DOMAIN:443"
}
```

### JSON (sing-box):
```json
{
  "type": "http",
  "tag": "naiveproxy-out",
  "server": "YOUR_DOMAIN",
  "server_port": 443,
  "username": "USERNAME",
  "password": "PASSWORD",
  "tls": { "enabled": true, "server_name": "YOUR_DOMAIN" }
}
```

### Рекомендуемые клиенты:

| Клиент | Платформа | Примечание |
|--------|-----------|------------|
| [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) | Android | APK с GitHub |
| [Hiddify](https://github.com/hiddify/hiddify-next/releases) | Android / iOS / Windows / macOS | Рекомендуется |
| [sing-box](https://github.com/SagerNet/sing-box) | Все платформы | Универсальный |
| [v2rayN](https://github.com/2dust/v2rayN/releases) | Windows | + naive.exe |
| [naive](https://github.com/klzgrad/naiveproxy/releases) | Linux CLI | Официальный |

> ⚠️ **v2rayNG не поддерживает NaiveProxy.** Используй NekoBox или Hiddify.

### Проверить без клиента:
```bash
curl -v --proxy "https://USER:PASS@YOUR_DOMAIN:443" https://ifconfig.me
```

---

## 🎭 Страница-камуфляж

По умолчанию устанавливается IT-блог **DevStack** — выглядит как реальный технический сайт.

**Путь на сервере:** `/var/www/html/index.html`

```bash
# Заменить своей страницей
scp my_site.html user@YOUR_IP:/var/www/html/index.html

# Восстановить DevStack
sudo bash naiveproxy.sh camouflage
```

> 💡 Хорошие варианты: корпоративный сайт, портфолио, блог, лендинг.

---

## 📁 Файловая структура

```
/usr/local/bin/caddy                       ← бинарник
/etc/caddy/Caddyfile                       ← конфиг (chmod 600)
/etc/naiveproxy/
├── naive.conf                             ← домен, email, TG (chmod 600)
├── users.conf                             ← user:pass (chmod 600)
├── monitor.sh                             ← watchdog
├── .ssh_hardened                          ← маркер SSH
├── .sysupdate_done                        ← маркер обновления
└── backups/Caddyfile.YYYYMMDD_HHMMSS      ← бэкапы
/etc/fail2ban/jail.local
/etc/apt/apt.conf.d/50unattended-upgrades
/var/www/html/index.html                   ← камуфляжная страница
/var/log/caddy/access.log
/var/log/caddy/naive.log
/etc/systemd/system/caddy.service
/usr/local/bin/naiveproxy.sh               ← скрипт (для cron)
```

---

## ❓ FAQ

<details>
<summary><b>Сборка Caddy занимает 15+ минут</b></summary>

Нормально — xcaddy компилирует Go-код + клонирует forwardproxy. На 1 vCPU до 15 минут. Не прерывай.

</details>

<details>
<summary><b>NekoBox / Hiddify не подключается</b></summary>

Убедись что используешь **v3.6.0** — в нём исправлена сборка Caddy. Проверь:
```bash
sudo bash naiveproxy.sh version   # должно быть 3.6.0
openssl s_client -connect YOUR_DOMAIN:443 -alpn h2 2>/dev/null | grep "ALPN protocol"
# должно быть: ALPN protocol: h2
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
<summary><b>v2rayNG не работает</b></summary>

v2rayNG не поддерживает NaiveProxy. Используй **NekoBox** (Android) или **Hiddify** (все платформы).

</details>

---

## 📊 Сравнение

| Функция | **NaiveProxy Manager** | x-ui / 3x-ui | Marzban |
|---------|:---:|:---:|:---:|
| Без Docker | ✅ | ❌ | ❌ |
| SSH Hardening | ✅ | ❌ | ❌ |
| Обновление системы | ✅ | ❌ | ❌ |
| Self-Update скрипта | ✅ | ❌ | ❌ |
| Страница-камуфляж | ✅ | ❌ | ❌ |
| Проверка сертификата | ✅ | ❌ | ❌ |
| Правильная сборка naive | ✅ v3.6 | — | — |
| HTTP/2 явно включён | ✅ v3.6 | — | — |
| ShellCheck passing | ✅ | — | — |
| probe_resistance | ✅ | ❌ | ❌ |
| Telegram алерты | ✅ | ✅ | ✅ |

---

## 📜 Changelog

<details>
<summary><b>v3.7.0</b> — Caddyfile Critical Fix ← ТЕКУЩАЯ</summary>

- 🔴 **Критический фикс:** Caddyfile — правильный порядок `:443, domain` вместо `domain:443`
- 🔴 Без этого фикса NekoBox и все клиенты не могли подключиться
- ✅ Подтверждено: NekoBox Android + naive.exe Windows работают
- ✅ Соответствует официальному README klzgrad/naiveproxy

</details>

<details>
<summary><b>v3.6.0</b> — Critical Build Fix</summary>

- 🔴 **Критический фикс:** build_caddy — git clone `klzgrad/forwardproxy@naive` напрямую
- 🔴 **Критический фикс:** автоопределение совместимой версии Caddy из go.mod
- ✅ Проверка naive padding в бинарнике
- ✅ Автоустановка git

</details>

<details>
<summary><b>v3.5.0</b> — Security Audit</summary>

- 🔒 `rm -rf` защита от пустой переменной
- 🔒 `grep -vF` вместо `sed` (нет regex injection)
- 🔒 Безопасная замена пароля через `while+printf`
- 🔒 `--data-urlencode` для Telegram
- 🔒 `trap` cleanup временных файлов

</details>

<details>
<summary><b>v3.4.0</b> — Camouflage Page</summary>

- ✨ Страница-камуфляж DevStack IT-блог
- 🆕 CLI: `camouflage`

</details>

<details>
<summary><b>v3.3.0</b> — Self-Update + Multi-Domain</summary>

- ✨ Self-update из меню
- ✨ Управление несколькими доменами
- 🆕 CLI: `self-update`, `domains`, `version`

</details>

<details>
<summary><b>v3.2.0</b> — Certificate Monitor</summary>

- ✨ Проверка TLS сертификата
- 🤖 Алерт в Telegram при < 7 дней
- 🆕 CLI: `cert`

</details>

<details>
<summary><b>v3.0-3.1</b> — System Hardening</summary>

- ✨ Обновление системы + unattended-upgrades
- ✨ SSH Hardening — ED25519, Fail2Ban
- 🐛 Фикс отката sshd_config и cron

</details>

<details>
<summary><b>v2.x</b> — Core Features</summary>

- Мультипользователь, Telegram-бот, Watchdog, Мониторинг

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
