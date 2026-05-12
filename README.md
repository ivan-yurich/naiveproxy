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

### 🚀 Профессиональный менеджер приватного прокси-сервера

**Один скрипт. Голый VPS → защищённый прокси с блокировкой рекламы за 10 минут.**

Caddy 2 · NaiveProxy · Telegram Bot · DNS блокировка · Диагностика · SSH Hardening

---

[![Version](https://img.shields.io/badge/version-4.2.3-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivanstudiya-cpu/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.shellcheck.net)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![License](https://img.shields.io/badge/License-MIT-58A6FF?style=for-the-badge)](LICENSE)

---

### 💛 Поддержать проект

[![Donate](https://img.shields.io/badge/💛_Поддержать-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Telegram](https://img.shields.io/badge/Telegram-Канал-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+XVSkY6blCTY0ZDU6)
[![Website](https://img.shields.io/badge/Сайт-ivan--it.net-D4A017?style=for-the-badge&logo=googlechrome&logoColor=white)](https://ivan-it.net)

**🔔 Обновления выходят раз в месяц**

</div>

---

<div align="center">

[**⚡ Старт**](#-быстрый-старт) • [**✨ Возможности**](#-возможности) • [**🤖 Бот**](#-telegram-бот) • [**🚫 Блокировка**](#-dns-блокировка-рекламы) • [**🔍 Диагностика**](#-диагностика) • [**❓ FAQ**](#-faq) • [**💛 Донат**](#-поддержать-проект-1)

</div>

---

## 🎉 Что нового в v4.2.3

<table>
<tr>
<td width="50%" valign="top">

### 🐛 Исправленные баги

✅ `/qr` команда — фикс curl conflict
✅ `/adduser` — валидация логина и пароля
✅ Команды бота — очистка от `\r\n`
✅ `set +e` — ошибка не ломает бот
✅ Диагностика — счётчики `pass=$((pass+1))`
✅ ALPN — `-servername` + `-a` для бинарного вывода
✅ SSH порт на Ubuntu 22.04+ через `sshd_config.d/`
✅ Защита от удаления последнего домена
✅ `apt update` перед Fail2Ban
✅ Авто-перезапуск Caddy и бота при сбое

</td>
<td width="50%" valign="top">

### ⚡ Новые возможности

🤖 **16 команд бота** + мультиадмины
🚫 **DNS блокировка** ~1.5М доменов + DoT
🔍 **Диагностика** — 7 блоков, 18+ проверок
🔒 **SSH Hardening** — ED25519, `ssh.socket` fix
🛡️ **Fail2Ban** 3 уровня (iptables-multiport)
♻️ **Auto-recovery** — `Restart=on-failure`
🎨 **ASCII баннер** + брендинг
💛 **Донат** через DonationAlerts

</td>
</tr>
</table>

[👉 Полный Changelog](#-changelog)

---

## 🤔 Что это

**NaiveProxy** маскирует трафик под браузер Chrome используя настоящий Chromium network stack. DPI и цензоры видят легитимный HTTPS/2 — и пропускают.

**NaiveProxy Manager** — один bash-скрипт который превращает голый VPS в полноценный защищённый прокси-сервер с блокировкой рекламы и Telegram управлением.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────────────┐     ┌──────────┐
│  Твой       │     │  Цензор/DPI  │     │   Твой VPS                │     │          │
│  телефон    │────▶│              │────▶│   Caddy + NaiveProxy      │────▶│ Интернет │
│  ноутбук    │     │  Видит Chrome│     │   unbound DNS блокировка  │     │          │
└─────────────┘     │  HTTPS/2 ✓   │     │   probe_resistance        │     └──────────┘
 naive-client        └──────────────┘     └───────────────────────────┘
 Chromium stack       Пропускает           реклама заблокирована 🚫
```

---

## ⚡ Быстрый старт

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh)
```

---

## ✨ Возможности

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Безопасность
- SSH Hardening ED25519 + `sshd_config.d/`
- Авто-сохранение SSH ключа
- Fail2Ban 3 уровня (iptables-multiport)
- UFW deny all + защита сканеров
- probe_resistance — выглядит как сайт
- Страница-камуфляж DevStack
- Защита последнего домена

### 📡 Прокси
- Auto TLS — Let's Encrypt
- HTTP/2 + HTTP/3
- QR код — один скан с телефона
- Мультипользователь без рестарта
- Несколько доменов
- TCP BBR
- `Restart=on-failure`

</td>
<td width="50%" valign="top">

### 🚫 DNS блокировка
- ~1.5М доменов рекламы
- unbound + DNS-over-TLS
- 3 источника blocklists
- Whitelist
- Автообновление

### 🤖 Telegram бот
- 16 команд
- Мультиадмины
- QR код картинкой
- Авто-установка зависимостей
- Системный сервис 24/7

### 🔍 Диагностика
- 7 блоков, 18+ проверок
- Цветной отчёт
- Отправка в Telegram

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

---

## 🤖 Telegram Бот

```bash
sudo bash naiveproxy.sh bot-install    # Автозапуск
```

| Команда | Действие |
|---------|----------|
| `/help` `/status` `/stats` | Информация |
| `/diagnose` `/cert` `/logs` | Диагностика |
| `/users` `/adduser` `/deluser` `/qr` | Пользователи |
| `/restart` `/update` `/selfupdate` | Управление |
| `/admins` `/addadmin` `/deladmin` | Администрирование |

---

## 🚫 DNS блокировка рекламы

```bash
sudo bash naiveproxy.sh dns-install
```

| Источник | Что блокирует |
|----------|--------------|
| StevenBlack/hosts | Реклама + малварь |
| AdAway | Мобильная реклама |
| Hagezi Pro | Агрессивная блокировка |

---

## 🔍 Диагностика

```bash
sudo bash naiveproxy.sh diagnose
```

```
[1/7] Caddy          ✅ запущен · ✅ naive padding · ✅ модуль
[2/7] Конфигурация   ✅ :443,domain · ✅ пользователи
[3/7] TLS и сеть     ✅ DNS · ✅ порты · ✅ ALPN h2 · ✅ сертификат
[4/7] Firewall       ✅ UFW · ✅ Fail2Ban активен
[5/7] Ресурсы        ✅ RAM 40% · ✅ Диск 37%
[6/7] Логи           ✅ нет ошибок
[7/7] Версия         ✅ актуальна

📊 ИТОГ: ✅ 18  ⚠️ 0  ❌ 0
```

---

## ⚠️ Caddyfile — критически важно

```
{
    order forward_proxy before file_server
    servers :443 {
        protocols h1 h2 h3
    }
}

:443, your-domain.com {
  tls your@email.com
  forward_proxy {
    basic_auth USER PASS
    hide_ip
    hide_via
    probe_resistance
  }
  file_server { root /var/www/html }
}
```

---

## 📱 Клиенты

```
URI: naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

| Клиент | Платформа |
|--------|-----------|
| [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) | Android |
| [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) | iPhone ($2.99) |
| [Hiddify](https://github.com/hiddify/hiddify-next/releases) | Windows / macOS |

---

## ❓ FAQ

<details>
<summary><b>Клиент не подключается</b></summary>

```bash
sudo bash naiveproxy.sh diagnose
echo | openssl s_client -connect YOUR_DOMAIN:443 -alpn h2 -servername YOUR_DOMAIN 2>/dev/null | grep -a "ALPN protocol"
```

</details>

<details>
<summary><b>DNS блокировка ломает сайт</b></summary>

```bash
sudo bash naiveproxy.sh dns
# → 4) Разрешить домен
```

</details>

<details>
<summary><b>Telegram бот не отвечает</b></summary>

```bash
journalctl -u naiveproxy-bot -n 20 --no-pager
systemctl restart naiveproxy-bot
```

</details>

---

## 💛 Поддержать проект

<div align="center">

### Если скрипт помог тебе — поддержи разработку! 🙏

[![Donate](https://img.shields.io/badge/💛_DonationAlerts-Любая_сумма-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)

**👉 https://www.donationalerts.com/r/ivan_yurievich**

</div>

### Что даст твой донат:
- 🚀 **Больше времени** на разработку
- 🐛 **Быстрые фиксы** багов
- ✨ **Новые фичи** каждый месяц
- 📚 **Документация** и поддержка
- 🆕 **Эксклюзив** для донатеров в Telegram

### Все способы поддержки:

| Способ | Ссылка |
|--------|--------|
| 💛 **Донат** | [donationalerts.com/r/ivan_yurievich](https://www.donationalerts.com/r/ivan_yurievich) |
| ⭐ **GitHub Star** | [Поставить звезду](https://github.com/ivanstudiya-cpu/naiveproxy) |
| 📱 **Telegram канал** | [t.me/+XVSkY6blCTY0ZDU6](https://t.me/+XVSkY6blCTY0ZDU6) |
| 🌐 **Сайт** | [ivan-it.net](https://ivan-it.net) |
| 📢 **Поделиться** | Расскажи друзьям |

**Спасибо за поддержку! Каждый донат мотивирует делать проект ещё лучше 💛**

---

## 📜 Changelog

<details>
<summary><b>v4.2.3</b> — ALPN Fix ← ТЕКУЩАЯ</summary>

- 🐛 Фикс `grep: binary file matches` — флаг `-a`
- ✅ Диагностика корректно показывает `ALPN: h2` на всех серверах

</details>

<details>
<summary><b>v4.2.2</b> — Security Audit (10 фиксов)</summary>

**Критичные:**
- 🔒 SSH `sshd_config.d/` + `ssh.socket` отключение
- 🛡️ Защита от удаления последнего домена
- 📦 `apt update` перед Fail2Ban
- 🔧 `PasswordAuthentication`/`PermitRootLogin` добавление

**Безопасность:**
- ⚡ Fail2Ban `iptables-multiport`
- 🌐 UFW `allow 80/tcp` (ACME)
- 🔑 Пароли 20 символов `[a-zA-Z0-9_-]`
- ♻️ Caddy `Restart=on-failure`

**Бот:**
- ✅ `/qr` фикс curl
- ✅ `/adduser` валидация
- ✅ Очистка `\r\n`
- ✅ `set +e` в обработчике

**Диагностика:**
- 🐛 Счётчики `pass=$((pass+1))`
- 🐛 ALPN `-servername`
- 🐛 Naive padding multi-criteria

</details>

<details>
<summary><b>v4.2.1</b> — Banner & Branding</summary>

- ✨ ASCII баннер + Telegram канал + сайт
- 🐛 Переменные `DIM`, `BLUE`

</details>

<details>
<summary><b>v4.2.0</b> — DNS Ad Blocker</summary>

- ✨ unbound + ~1.5М доменов
- ✨ DNS-over-TLS
- 🆕 `dns`, `dns-install`, `dns-update`

</details>

<details>
<summary><b>v4.1.0</b> — Security Audit</summary>

- 🔒 Валидация бота + санитизация args

</details>

<details>
<summary><b>v4.0.0</b> — Telegram Bot</summary>

- ✨ 16 команд + мультиадмины + QR картинкой

</details>

<details>
<summary><b>v3.9.0</b> — Diagnostics</summary>

- ✨ 7 блоков, 18+ проверок

</details>

<details>
<summary><b>v3.8.0</b> — Security & UX</summary>

- ✨ SSH ключ + QR + Fail2Ban 3 уровня

</details>

<details>
<summary><b>v3.7.0</b> — Critical Caddyfile Fix</summary>

- 🔴 `:443, domain` вместо `domain:443`

</details>

---

## 📄 Лицензия

MIT © [ivanstudiya-cpu](https://github.com/ivanstudiya-cpu)

---

<div align="center">

### 💛 Понравилось? Поддержи проект!

[![Donate](https://img.shields.io/badge/💛_Поддержать-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Star](https://img.shields.io/github/stars/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivanstudiya-cpu/naiveproxy/stargazers)

📱 [Telegram](https://t.me/+XVSkY6blCTY0ZDU6) · 🌐 [ivan-it.net](https://ivan-it.net) · 💻 [GitHub](https://github.com/ivanstudiya-cpu/naiveproxy)

*NaiveProxy Manager · by Иван Юрьевич · Обновления раз в месяц*

</div>
