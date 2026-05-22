<div align="center">

🌐 **Language / Язык:** [🇷🇺 Русский](README.md) · [🇬🇧 English](README_EN.md)

</div>

<div align="center">

# 🛡️ NaiveProxy Manager

```
███╗   ██╗ █████╗ ██╗██╗   ██╗███████╗    ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
████╗  ██║██╔══██╗██║██║   ██║██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██╔██╗ ██║███████║██║██║   ██║█████╗      ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██║╚██╗██║██╔══██║██║╚██╗ ██╔╝██╔══╝      ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║ ╚████║██║  ██║██║ ╚████╔╝ ███████╗    ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
                                                                            MANAGER
```

### 🚀 Профессиональный менеджер защищённого прокси-сервера

**Один скрипт. Голый VPS → защищённый прокси с блокировкой рекламы за 10 минут.**

*Caddy 2 · NaiveProxy · Telegram Bot · DNS блокировка · Диагностика · SSH Hardening*

---

[![Version](https://img.shields.io/badge/version-4.2.4-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivan-yurich/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.shellcheck.net)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![License](https://img.shields.io/badge/License-GPL--3.0-58A6FF?style=for-the-badge)](LICENSE)

[![Stars](https://img.shields.io/github/stars/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=D4A017)](https://github.com/ivan-yurich/naiveproxy/stargazers)
[![Forks](https://img.shields.io/github/forks/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=58A6FF)](https://github.com/ivan-yurich/naiveproxy/network)
[![Issues](https://img.shields.io/github/issues/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=F85149)](https://github.com/ivan-yurich/naiveproxy/issues)
[![Last commit](https://img.shields.io/github/last-commit/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=3FB950)](https://github.com/ivan-yurich/naiveproxy/commits/main)

---

### 💛 Поддержать разработку

[![Donate](https://img.shields.io/badge/💛_Поддержать_проект-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Telegram](https://img.shields.io/badge/📱_Telegram_канал-@ivan__it__net-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/ivan_it_net)
[![Website](https://img.shields.io/badge/🌐_Сайт-ivan--it.net-D4A017?style=for-the-badge&logo=googlechrome&logoColor=white)](https://ivan-it.net)

**🔔 Обновления выходят раз в месяц**

</div>

---

<div align="center">

### 🎯 Навигация

[**⚡ Старт**](#-быстрый-старт) ·
[**✨ Возможности**](#-возможности) ·
[**🤖 Telegram бот**](#-telegram-бот) ·
[**🚫 Блокировка рекламы**](#-dns-блокировка-рекламы) ·
[**🔍 Диагностика**](#-диагностика) ·
[**❓ FAQ**](#-faq) ·
[**💛 Донат**](#-поддержать-проект)

</div>

---

## 🌟 Почему это лучший выбор?

<table>
<tr>
<td align="center" width="33%">

### 🚀 Скорость
**10 минут**
от голого VPS до рабочего прокси с автотлс, баном и блокировкой рекламы

</td>
<td align="center" width="33%">

### 🛡️ Безопасность
**Защита от DPI**
NaiveProxy маскирует трафик под обычный Chrome — невидимо для цензоров

</td>
<td align="center" width="33%">

### 🤖 Удобство
**Управление из Telegram**
16 команд + мультиадмины + QR код прямо в чат

</td>
</tr>
</table>

---

## 🎉 Что нового в v4.2.4

<table>
<tr>
<td width="50%" valign="top">

### 🐛 Исправленные баги

✅ Разломанные кавычки в DNS whitelist
✅ `((var++))` → `var=$((var+1))` (set -e safety)
✅ `/qr` команда — фикс curl conflict
✅ `/adduser` — валидация логина/пароля
✅ Команды бота — очистка от `\r\n`
✅ `set +e` — ошибка не ломает бот
✅ Диагностика — фикс счётчиков
✅ ALPN — `-servername` + `-a` флаг
✅ SSH порт на Ubuntu 22.04+ (`sshd_config.d/`)
✅ Защита от удаления последнего домена
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
🌐 **DNS-over-TLS** — Cloudflare + Google
📦 **Auto-install** зависимостей (qrencode, binutils)

</td>
</tr>
</table>

[👉 Полный Changelog внизу](#-changelog)

---

## 🤔 Что это и как работает?

**NaiveProxy** маскирует трафик под браузер Chrome используя настоящий Chromium network stack. DPI и цензоры видят легитимный HTTPS/2 — и пропускают.

**NaiveProxy Manager** — один bash-скрипт который превращает голый VPS в полноценный защищённый прокси-сервер с блокировкой рекламы и Telegram управлением.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────────────┐     ┌──────────┐
│   Твой      │     │  Цензор/DPI  │     │      Твой VPS             │     │          │
│  телефон    │────▶│              │────▶│  Caddy + NaiveProxy       │────▶│ Интернет │
│  ноутбук    │     │ Видит Chrome │     │  unbound DNS блокировка   │     │          │
└─────────────┘     │  HTTPS/2 ✓   │     │  probe_resistance         │     └──────────┘
  Naive client       └──────────────┘     └───────────────────────────┘
  Chromium stack      Пропускает             реклама заблокирована 🚫
```

### 🎯 Кому это нужно:

- 🌐 **Обход блокировок** — доступ к заблокированным ресурсам
- 🔒 **Приватность** — никто не видит твой трафик
- 🚫 **Без рекламы** — на всех устройствах одновременно
- 👨‍👩‍👧 **Для семьи** — несколько пользователей, разные пароли
- 💼 **Для команды** — мультиадмины, диагностика, мониторинг

---

## ⚡ Быстрый старт

### 🎬 Одна команда — всё готово:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/naiveproxy.sh)
```

### 📊 Процесс установки:

```
[1/5] 🔄  Обновление системы                              ~1 мин
         apt upgrade + unattended-upgrades
         → можно пропустить: нажми n

[2/5] 🔒  SSH Hardening                                   ~2 мин  [ОПЦИОНАЛЬНО]
         ED25519 ключ · авто-сохранение · новый пользователь · Fail2Ban
         → пропусти если SSH уже настроен: нажми n

[3/5] 📦  Сборка Caddy                                    ~5-15 мин
         git clone klzgrad/forwardproxy@naive
         xcaddy build с автоопределением версии

[4/5] ⚙️   Настройка                                       ~1 мин
         Caddyfile (:443, domain) · systemd · UFW · BBR · Telegram

[5/5] ✅  Готово!
         URI + JSON конфиги + QR код для телефона
```

---

## ✨ Возможности

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Безопасность

🛡️ **SSH Hardening**
ED25519 ключ + поддержка `sshd_config.d/` для Ubuntu 22.04+

🔑 **Авто-сохранение SSH ключа**
В `/etc/naiveproxy/ssh_private_key` — скачать через `scp`

🚫 **Fail2Ban 3 уровня**
Брутфорс (7д) · DDoS (7д) · Рецидив (30д)
Использует `iptables-multiport` — быстрее UFW

🔥 **UFW + защита от сканеров**
`deny all incoming` + блокировка популярных сканеров

👻 **probe_resistance**
Без логина+пароля выглядит как обычный сайт

🎭 **Страница-камуфляж**
IT-блог DevStack — для случайных посетителей

🛡️ **Защита от удаления последнего домена**
Скрипт не даст случайно убить сервер

### 📡 Прокси

🔒 **Auto TLS** — Let's Encrypt через Caddy
🌐 **HTTP/2 + HTTP/3** — явно включены
📱 **QR код** — один скан с телефона
👥 **Мультипользователь** — без перезапуска
🌍 **Несколько доменов** — на одном сервере
⚡ **TCP BBR** — опциональное ускорение
♻️ **Auto-restart** — `Restart=on-failure`

</td>
<td width="50%" valign="top">

### 🚫 DNS блокировка рекламы

📊 **~1.5 млн доменов**
Реклама · Трекеры · Малварь

⚡ **unbound** — быстрый локальный резолвер

🔐 **DNS-over-TLS**
Шифрованные запросы к Cloudflare и Google

📦 **3 источника blocklists:**
- StevenBlack/hosts
- AdAway
- Hagezi Pro

✅ **Whitelist** — разрешить нужные домены
🔄 **Автообновление** списков

### 🤖 Telegram бот

⚙️ **16 команд** — полное управление
👥 **Мультиадмины** — несколько управляющих
📱 **QR код картинкой** — прямо в чат
👤 **Управление юзерами** — `/adduser`, `/deluser`
🔍 **Диагностика** — `/diagnose` из чата
📦 **Auto-install** — qrencode, binutils
🚀 **Systemd сервис** — работает 24/7

### 🔍 Диагностика системы

🎯 **7 блоков проверок:**
1. Caddy (статус + naive padding)
2. Конфигурация (Caddyfile)
3. TLS и сеть (DNS, порты, ALPN)
4. Firewall (UFW, Fail2Ban)
5. Ресурсы (RAM, диск, CPU)
6. Логи (анализ ошибок)
7. Версия и обновления

✅ **18+ проверок** — каждая помечена ✅/⚠️/❌
📱 **Отчёт в Telegram** — одним нажатием

</td>
</tr>
</table>

---

## 📋 Требования

| Параметр | Минимум | Рекомендуется |
|----------|---------|---------------|
| **ОС** | Ubuntu 20.04 | Ubuntu 22.04 / 24.04 |
| **Права** | root | root |
| **Домен** | A-запись → IP | + Cloudflare DNS |
| **Порты** | 80 + 443 (tcp/udp) | + порт SSH |
| **RAM** | 512 MB | 1 GB+ |
| **Диск** | 1 GB | 5 GB+ |
| **CPU** | 1 vCPU | 1 vCPU |
| **Трафик** | от 100 GB/мес | unlimited |

---

## 🎮 Главное меню

```
──────────────────────────────────────────────────────
   NaiveProxy Manager v4.2.4  [РУС]
   Статус: ● работает  │  Домен: proxy.example.com
   Telegram: подключён  │  Юзеров: 3  │  SSH: 52847
──────────────────────────────────────────────────────
   1)  📦 Установить NaiveProxy     10) 📄 Логи
   2)  📊 Статус + сертификат       11) 🗑  Удалить NaiveProxy
   3)  📱 Клиентский конфиг + QR    16) 🔍 Диагностика
   4)  👥 Пользователи              17) 🚫 DNS блокировщик
   5)  🌍 Домены                    18) 💛 Поддержать проект
   6)  📈 Мониторинг + статистика   ──────────────────
   7)  🤖 Настройка Telegram + Бот  12) 🔒 SSH Hardening
   8)  🔄 Перезапустить Caddy       13) 🔄 Обновить систему
   9)  ⬆️  Обновить Caddy            14) ⬆️  Обновить скрипт
                                    15) 🎭 Обновить камуфляж
──────────────────────────────────────────────────────
```

### 📟 Все CLI команды:

<details>
<summary><b>Кликни чтобы увидеть полный список (24 команды)</b></summary>

```bash
# === Основные ===
sudo bash naiveproxy.sh install        # Полная установка
sudo bash naiveproxy.sh status         # Статус + сертификат
sudo bash naiveproxy.sh config         # Конфиг + QR код
sudo bash naiveproxy.sh qr             # Только QR код
sudo bash naiveproxy.sh cert           # Только сертификат
sudo bash naiveproxy.sh users          # Пользователи
sudo bash naiveproxy.sh domains        # Домены
sudo bash naiveproxy.sh monitor        # Мониторинг
sudo bash naiveproxy.sh restart        # Перезапустить Caddy
sudo bash naiveproxy.sh update         # Обновить Caddy
sudo bash naiveproxy.sh logs           # Логи

# === Telegram ===
sudo bash naiveproxy.sh tg-stats       # Статистика в Telegram
sudo bash naiveproxy.sh bot            # Запустить Telegram бот
sudo bash naiveproxy.sh bot-install    # Бот как системный сервис

# === DNS блокировщик ===
sudo bash naiveproxy.sh dns            # Меню DNS
sudo bash naiveproxy.sh dns-install    # Установить блокировщик
sudo bash naiveproxy.sh dns-update     # Обновить blocklists
sudo bash naiveproxy.sh dns-status     # Статус блокировщика

# === Диагностика ===
sudo bash naiveproxy.sh diagnose       # Диагностика 7 блоков

# === SSH ===
sudo bash naiveproxy.sh ssh-hardening  # SSH Hardening
sudo bash naiveproxy.sh ssh-key        # Показать SSH ключ

# === Управление ===
sudo bash naiveproxy.sh sysupdate      # Обновить систему
sudo bash naiveproxy.sh self-update    # Обновить скрипт
sudo bash naiveproxy.sh camouflage     # Переустановить камуфляж
sudo bash naiveproxy.sh version        # Версия
sudo bash naiveproxy.sh remove         # Удалить всё
```

</details>

---

## 🤖 Telegram Бот

Полноценное управление сервером прямо из Telegram. Работает 24/7 как системный сервис.

### 🚀 Запуск:

```bash
# Установить как системный сервис (автозапуск):
sudo bash naiveproxy.sh bot-install

# Остановить:
systemctl stop naiveproxy-bot

# Логи:
journalctl -u naiveproxy-bot -f
```

### 📋 Все 16 команд:

<table>
<tr>
<th width="33%">📊 Информация</th>
<th width="33%">👥 Управление</th>
<th width="33%">⚙️ Администрирование</th>
</tr>
<tr>
<td valign="top">

`/help` — Список команд
`/status` — Статус + RAM
`/stats` — Полная статистика
`/diagnose` — Диагностика 7 блоков
`/logs` — Последние 20 логов
`/cert` — Статус TLS 🟢/🟡/🔴

</td>
<td valign="top">

`/users` — Список пользователей
`/adduser login pass` — Добавить
`/deluser login` — Удалить
`/qr login` — QR код картинкой
`/restart` — Перезапустить Caddy
`/update` — Обновить Caddy

</td>
<td valign="top">

`/admins` — Список админов
`/addadmin ID` — Добавить админа
`/deladmin ID` — Удалить админа
`/selfupdate` — Обновить скрипт
`/donate` — Поддержать проект

</td>
</tr>
</table>

### 🔐 Мультиадмины:

```
/addadmin 987654321   ← добавить второго админа
/admins               ← посмотреть список
```

Все команды защищены — чужой получит `⛔ Доступ запрещён`.

---

## 🚫 DNS блокировка рекламы

Блокирует рекламу и трекеры на уровне DNS — работает для **всех устройств** подключённых через прокси.

### ⚡ Установка одной командой:

```bash
sudo bash naiveproxy.sh dns-install
```

### 🔍 Как работает:

```
Телефон → NaiveProxy → unbound (127.0.0.1:5335)
                            │
                            ├─ ads.google.com ───── ❌ REFUSE
                            ├─ doubleclick.net ──── ❌ REFUSE
                            ├─ youtube.com ──────── ✅ Cloudflare DoT
                            └─ github.com ───────── ✅ Cloudflare DoT
```

### 📊 Источники blocklists (~1.5 млн доменов):

| Источник | Размер | Что блокирует |
|----------|--------|---------------|
| 🛡️ **StevenBlack/hosts** | ~150k | Реклама + малварь |
| 📱 **AdAway** | ~30k | Мобильная реклама |
| ⚡ **Hagezi Pro** | ~600k | Агрессивная блокировка |
| **Итого после очистки** | ~1.5M | Уникальных доменов |

### 🛠️ Команды:

```bash
sudo bash naiveproxy.sh dns-install    # Установить
sudo bash naiveproxy.sh dns-update     # Обновить blocklists
sudo bash naiveproxy.sh dns-status     # Статус и тест
sudo bash naiveproxy.sh dns            # Меню
```

### 🆘 Если что-то сломалось — whitelist:

```bash
sudo bash naiveproxy.sh dns
# → 4) Разрешить домен → введи проблемный домен
```

---

## 🔍 Диагностика

```bash
sudo bash naiveproxy.sh diagnose
```

### 📊 Пример вывода:

```
┌─────────────────────────────────────────────────────────┐
│  🔍 Диагностика NaiveProxy Manager v4.2.4               │
│  2026-05-23 14:32:18 · proxy.example.com               │
└─────────────────────────────────────────────────────────┘

[1/7] Caddy
  ✅ Caddy найден: v2.8.4
  ✅ Caddy запущен (с 2026-05-22 03:15)
  ✅ Naive padding модуль подтверждён (5 символов)
  ✅ Модуль forward_proxy загружен

[2/7] Конфигурация
  ✅ Caddyfile найден: /etc/caddy/Caddyfile
  ✅ Правильный формат ':443, domain'
  ✅ order forward_proxy — OK
  ✅ probe_resistance включён
  ✅ Пользователей: 4
  ✅ Caddyfile валиден

[3/7] TLS и сеть
  ✅ DNS: proxy.example.com → 78.17.134.110
  ✅ Порт 80 слушается (ACME)
  ✅ Порт 443 слушается
  ✅ ALPN: h2 ✓ (HTTP/2 работает)
  ✅ TLS сертификат действителен ещё 83 дней

[4/7] Firewall
  ✅ UFW активен (правил: 12)
  ✅ Fail2Ban запущен (банов: 47)

[5/7] Ресурсы системы
  ✅ RAM: 367/1967 MB (18%)
  ✅ Диск: 5.8G/15G (42%)
  ✅ CPU: 0.19 (19% от 1 ядра)

[6/7] Анализ логов
  ✅ Нет серверных ошибок (последние 100 запросов)
  ℹ️  CONNECT туннелей: 96
  ✅ journald: нет критических ошибок

[7/7] Версия и обновления
  ✅ Скрипт актуален: v4.2.4
  ✅ SSH Hardening выполнен

══════════════════════════════════════════════════════════
  📊 ИТОГ ДИАГНОСТИКИ
══════════════════════════════════════════════════════════
  ✅ Пройдено:  18
  ⚠️  Внимание: 0
  ❌ Проблемы: 0

  🎉 Всё работает отлично!
══════════════════════════════════════════════════════════
```

---

## ⚠️ Caddyfile — критически важно

```bash
# ❌ НЕПРАВИЛЬНО — клиенты не подключаются:
your-domain.com:443 { ... }

# ✅ ПРАВИЛЬНО — :443 + блок servers обязательны:
{
    order forward_proxy before file_server
    servers :443 {
        protocols h1 h2 h3
    }
}

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

---

## 🔒 SSH Hardening

```bash
sudo bash naiveproxy.sh ssh-hardening
```

> 💡 **Можно пропустить** нажав `n` при установке.

### 🛡️ 5 шагов защиты:

1. **Новый sudo-пользователь** — root изолирован
2. **ED25519 ключ** — современная криптография + авто-сохранение
3. **Смена порта SSH** — защита от автоматических ботов
4. **sshd_config + sshd_config.d/** — поддержка Ubuntu 22.04+
5. **UFW + Fail2Ban** — защита от брутфорса

### 🔑 Скачать SSH ключ:

```bash
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy
chmod 600 ~/.ssh/id_naiveproxy
ssh -i ~/.ssh/id_naiveproxy -p NEW_PORT user@YOUR_IP
```

### 🚨 Fail2Ban 3 уровня:

| Уровень | Триггер | Бан | Использует |
|---------|---------|-----|------------|
| 🔴 **Брутфорс** | 3 неверных пароля | **7 дней** | iptables-multiport |
| 🟡 **DDoS** | 10 попыток за 1 мин | **7 дней** | iptables-multiport |
| ⚫ **Рецидив** | Повторные нарушения | **30 дней** | recidive jail |

---

## 📱 Клиентские приложения

### 🔗 URI формат:

```
naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

### 📋 JSON для naive-client:

```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://USERNAME:PASSWORD@YOUR_DOMAIN:443",
  "log": "naive.log"
}
```

### 📲 Лучшие клиенты:

<table>
<tr>
<th>📱 Платформа</th>
<th>🥇 Рекомендую</th>
<th>🥈 Альтернатива</th>
</tr>
<tr>
<td><strong>Android</strong></td>
<td>

[**NekoBox**](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) ⭐
Бесплатный · Open Source

</td>
<td>

[Hiddify](https://github.com/hiddify/hiddify-next/releases)
Проще для новичков

</td>
</tr>
<tr>
<td><strong>iOS / iPhone</strong></td>
<td>

[**Hiddify**](https://apps.apple.com/app/hiddify-proxy-vpn/id6596777532) ⭐
Бесплатный в App Store

</td>
<td>

[Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) ($2.99)
Платный, но топовый

</td>
</tr>
<tr>
<td><strong>Windows</strong></td>
<td>

[**Hiddify Next**](https://github.com/hiddify/hiddify-next/releases) ⭐
GUI, легко настроить

</td>
<td>

[NekoRay](https://github.com/MatsuriDayo/nekoray/releases)
Продвинутый GUI

</td>
</tr>
<tr>
<td><strong>macOS</strong></td>
<td>

[**Hiddify Next**](https://github.com/hiddify/hiddify-next/releases) ⭐
Бесплатный

</td>
<td>

[V2BoX](https://apps.apple.com/app/v2box-v2ray-client/id6446814690)
В App Store

</td>
</tr>
<tr>
<td><strong>Linux</strong></td>
<td>

[**NekoRay**](https://github.com/MatsuriDayo/nekoray/releases) ⭐
Qt GUI

</td>
<td>

[naive](https://github.com/klzgrad/naiveproxy/releases) CLI
Для серверов

</td>
</tr>
</table>

> ⚠️ **v2rayNG не поддерживает NaiveProxy.** Используй NekoBox или Hiddify.

---

## 📁 Файловая структура

<details>
<summary><b>Кликни чтобы увидеть всю структуру</b></summary>

```
/usr/local/bin/caddy                           ← Бинарник Caddy с naive
/etc/caddy/Caddyfile                           (chmod 600)
/etc/naiveproxy/
├── naive.conf                                 ← Главный конфиг (chmod 600)
├── users.conf                                 ← Пользователи (chmod 600)
├── ssh_private_key                            ← SSH ключ ED25519
├── ssh_public_key
├── dns_stats                                  ← Статистика DNS
├── monitor.sh
├── .ssh_hardened                              ← Метка SSH hardening
├── .sysupdate_done
└── backups/                                   ← Бэкапы конфигов

/etc/unbound/
├── unbound.conf.d/naiveproxy-dns.conf         ← DNS конфиг
├── blocklist.conf                             ← ~1.5М доменов
└── whitelist.txt                              ← Разрешённые домены

/etc/fail2ban/jail.local                       ← Fail2Ban правила

/etc/systemd/system/
├── caddy.service                              ← Caddy с Restart=on-failure
└── naiveproxy-bot.service                     ← Telegram бот 24/7

/var/www/html/index.html                       ← Страница-камуфляж

/var/log/caddy/
├── access.log                                 ← Все запросы
└── naive.log                                  ← CONNECT туннели

/usr/local/bin/naiveproxy.sh                   ← Сам скрипт
```

</details>

---

## ❓ FAQ

### 🚀 Установка и базовая настройка

<details>
<summary><b>Какой VPS купить? Минимальные требования</b></summary>

**Минимум для работы:**
- 512 MB RAM, 1 vCPU, 10 GB диска
- Любой провайдер с Ubuntu 20.04+

**Рекомендуемые провайдеры:**
- **Hetzner** — Германия, очень быстрый (от €4/мес)
- **DigitalOcean** — Нидерланды, США (от $4/мес)
- **Vultr** — много локаций (от $2.50/мес)
- **AEZA** — Россия, СНГ (от 150₽/мес)

⚠️ Избегай российских хостеров для прокси — могут блокировать.

</details>

<details>
<summary><b>Какой домен купить и где?</b></summary>

**Подойдёт любой домен:**
- `.com`, `.net`, `.org` — стандартные
- `.io`, `.dev`, `.tech` — модные
- `.xyz`, `.online`, `.site` — дешёвые

**Где покупать:**
- **REG.RU** — российские карты, .рф (~700₽/год)
- **Namecheap** — международный, .com от $10/год
- **Cloudflare Registrar** — по себестоимости

**Главное — настроить A-запись:**
```
your-domain.com → IP_СЕРВЕРА
```

</details>

<details>
<summary><b>Установка обрывается на этапе сборки Caddy</b></summary>

```bash
# Проверь свободную RAM (нужно от 512 MB)
free -h

# Если мало — добавь swap
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Запусти установку снова
sudo bash /usr/local/bin/naiveproxy.sh install
```

</details>

<details>
<summary><b>Как обновить скрипт до последней версии</b></summary>

```bash
# Способ 1 — из меню
sudo bash /usr/local/bin/naiveproxy.sh
# → Пункт 14) Обновить скрипт

# Способ 2 — одной командой
curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/naiveproxy.sh \
  -o /usr/local/bin/naiveproxy.sh && chmod +x /usr/local/bin/naiveproxy.sh
```

</details>

### 🔌 Подключение клиентов

<details>
<summary><b>Клиент не подключается — что делать?</b></summary>

**Пошаговая диагностика:**

```bash
# 1. Запусти полную диагностику
sudo bash naiveproxy.sh diagnose

# 2. Проверь Caddyfile
cat /etc/caddy/Caddyfile | grep ":443"
# Должно быть: :443, your-domain.com {

# 3. Проверь ALPN (должен быть h2)
echo | openssl s_client -connect YOUR_DOMAIN:443 -alpn h2 -servername YOUR_DOMAIN 2>/dev/null | grep -a "ALPN protocol"

# 4. Проверь что порт открыт
ss -tlnp | grep :443

# 5. Проверь логи
journalctl -u caddy -n 30 --no-pager
```

</details>

<details>
<summary><b>Какое бесплатное приложение для iPhone?</b></summary>

**Бесплатные варианты:**

1. **Hiddify** ⭐ — лучший бесплатный, в App Store
2. **FoXray** — бесплатный, частичная поддержка
3. **Streisand** — бесплатный, нет в РФ App Store

**Способ подключения:**
1. Скопируй URI: `naive+https://user:pass@domain:443`
2. Открой Hiddify → Import from clipboard

</details>

<details>
<summary><b>Какое приложение для Windows / Mac?</b></summary>

**Windows:**
- **Hiddify Next** — UI клиент, легко настроить
- **NekoRay** — продвинутый GUI

**macOS:**
- **Hiddify Next** — рекомендую
- **V2BoX** — есть в App Store

**Linux:**
- **NekoRay** — GUI на Qt
- **naive** CLI — для серверов

</details>

### 🤖 Telegram бот

<details>
<summary><b>Telegram бот не отвечает на команды</b></summary>

```bash
# 1. Проверь статус
systemctl status naiveproxy-bot

# 2. Посмотри логи
journalctl -u naiveproxy-bot -n 30 --no-pager

# 3. Перезапусти
systemctl restart naiveproxy-bot

# 4. Если не помогло — переустанови
sudo bash naiveproxy.sh bot-install
```

</details>

<details>
<summary><b>Как получить Telegram bot token?</b></summary>

1. Открой [@BotFather](https://t.me/BotFather) в Telegram
2. Отправь `/newbot`
3. Введи имя бота
4. Введи username (должен заканчиваться на `bot`)
5. Скопируй токен вида `123456789:ABCdefGHIjkl`

Введи токен в скрипте:
```bash
sudo bash naiveproxy.sh
# → 7) Настройка Telegram + Бот
```

</details>

<details>
<summary><b>Как узнать свой Telegram Chat ID?</b></summary>

**Способ 1 — через бота:**
1. Напиши своему боту любое сообщение
2. Открой: `https://api.telegram.org/botYOUR_TOKEN/getUpdates`
3. Найди `"chat":{"id":12345}` — это твой ID

**Способ 2 — через @userinfobot:**
1. Напиши [@userinfobot](https://t.me/userinfobot)
2. Он покажет твой ID

</details>

### 🚫 DNS блокировка

<details>
<summary><b>DNS блокировка сломала сайт — как починить</b></summary>

```bash
# Способ 1 — добавить в whitelist
sudo bash naiveproxy.sh dns
# → 4) Разрешить домен → введи домен

# Способ 2 — временно отключить
sudo systemctl stop unbound

# Способ 3 — полностью удалить
sudo bash naiveproxy.sh dns
# → 5) Удалить блокировщик
```

</details>

<details>
<summary><b>YouTube реклама не блокируется полностью</b></summary>

Это **нормально**! YouTube встраивает рекламу в видеопоток с того же домена (`googlevideo.com`), что и само видео.

**Что работает:**
- ✅ Баннеры YouTube (на главной)
- ✅ Pre-roll реклама (иногда)
- ❌ Реклама внутри видео — не блокируется

**Решение для YouTube:** YouTube Premium или NewPipe (Android).

</details>

### 🔒 SSH Hardening

<details>
<summary><b>Заблокировал себя после SSH hardening</b></summary>

**Доступ только через VNC/KVM консоль хостинга:**

```bash
# 1. Открой VNC/KVM в панели хостера
# 2. Выполни:
ufw allow 22/tcp
systemctl restart sshd

# 3. Теперь зайди по SSH на стандартный 22 порт
```

</details>

<details>
<summary><b>Fail2Ban забанил меня — как разбанить</b></summary>

```bash
# Посмотреть кто забанен
fail2ban-client status sshd

# Разбанить свой IP
fail2ban-client unban YOUR_IP

# Разбанить все IP
fail2ban-client unban --all
```

</details>

### 🔧 Управление сервером

<details>
<summary><b>Caddy не запускается — что делать</b></summary>

```bash
# 1. Проверь конфиг
caddy validate --config /etc/caddy/Caddyfile

# 2. Посмотри логи
journalctl -u caddy -n 50 --no-pager

# 3. Частые причины:
# - Порты 80/443 заняты (apache2, nginx)
# - Нет прав на /var/log/caddy
# - DNS не настроен
```

</details>

<details>
<summary><b>Как сделать бэкап и восстановить</b></summary>

```bash
# Создать бэкап
tar -czf naiveproxy-backup-$(date +%Y%m%d).tar.gz \
  /etc/caddy/Caddyfile \
  /etc/naiveproxy/

# Скачать
scp root@YOUR_IP:~/naiveproxy-backup-*.tar.gz ~/Downloads/

# Восстановить
sudo bash naiveproxy.sh install
tar -xzf naiveproxy-backup.tar.gz -C /
systemctl restart caddy
```

</details>

<details>
<summary><b>Как полностью удалить NaiveProxy</b></summary>

```bash
sudo bash naiveproxy.sh remove
# Удалит: Caddy, конфиги, логи, systemd сервисы

# Дополнительно:
apt remove --purge -y caddy fail2ban unbound
rm -rf /etc/caddy /etc/naiveproxy /etc/unbound
```

</details>

---

## 📊 Сравнение с аналогами

<table>
<tr>
<th>Функция</th>
<th align="center">🥇 NaiveProxy Manager</th>
<th align="center">x-ui / 3x-ui</th>
<th align="center">Marzban</th>
</tr>
<tr><td>Без Docker</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>SSH Hardening + sshd_config.d/</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>SSH ключ авто-сохранение</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>QR код</td><td align="center">✅</td><td align="center">❌</td><td align="center">⚠️</td></tr>
<tr><td><strong>DNS блокировка рекламы</strong></td><td align="center">✅ ~1.5M</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td><strong>Telegram бот с командами</strong></td><td align="center">✅ 16 команд</td><td align="center">⚠️ базовый</td><td align="center">⚠️ базовый</td></tr>
<tr><td>Диагностика системы (7 блоков)</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Fail2Ban 3 уровня</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Страница-камуфляж</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Self-Update</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Защита последнего домена</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Auto-restart при сбое</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Правильный Caddyfile</td><td align="center">✅</td><td align="center">—</td><td align="center">—</td></tr>
<tr><td>ShellCheck passing</td><td align="center">✅</td><td align="center">—</td><td align="center">—</td></tr>
</table>

---

## 💛 Поддержать проект

<div align="center">

### Если скрипт помог тебе — поддержи разработку! 🙏

[![Donate](https://img.shields.io/badge/💛_DonationAlerts-Любая_сумма-FF5E3A?style=for-the-badge&logoColor=white)](https://www.donationalerts.com/r/ivan_yurievich)

**👉 https://www.donationalerts.com/r/ivan_yurievich**

</div>

### 🎯 Что даст твой донат:

<table>
<tr>
<td align="center" width="20%">

🚀
**Больше времени**
на разработку

</td>
<td align="center" width="20%">

🐛
**Быстрые фиксы**
багов

</td>
<td align="center" width="20%">

✨
**Новые фичи**
каждый месяц

</td>
<td align="center" width="20%">

📚
**Документация**
и поддержка

</td>
<td align="center" width="20%">

🆕
**Эксклюзив**
для донатеров

</td>
</tr>
</table>

### 🤝 Все способы поддержки:

| Способ | Ссылка | Что даёт |
|--------|--------|----------|
| 💛 **Донат** | [DonationAlerts](https://www.donationalerts.com/r/ivan_yurievich) | Финансовая поддержка |
| ⭐ **GitHub Star** | [Поставить звезду](https://github.com/ivan-yurich/naiveproxy) | Видимость проекта |
| 📱 **Telegram канал** | [@ivan_it_net](https://t.me/ivan_it_net) | Подпишись на обновления |
| 🌐 **Сайт** | [ivan-it.net](https://ivan-it.net) | Загляни в гости |
| 📢 **Поделиться** | — | Расскажи друзьям |
| 🐛 **Сообщить о баге** | [Issues](https://github.com/ivan-yurich/naiveproxy/issues) | Помоги улучшить |
| 💡 **Предложить идею** | [Telegram](https://t.me/ivan_it_net) | Развивай проект |

**Спасибо за поддержку! Каждый донат мотивирует делать проект ещё лучше 💛**

---

## 📜 Changelog

<details>
<summary><b>v4.2.4</b> — Audit Fixes ← ТЕКУЩАЯ</summary>

**🐛 Финальный аудит безопасности:**
- 🔴 Фикс разломанных кавычек `""${var}""` в DNS whitelist (real bug!)
- 🟡 `((var++))` → `var=$((var+1))` в 3 местах (защита от `set -e` exit)
- 🟢 Литеральные `\n` в printf → `\\n`
- ✅ ShellCheck: 0 ошибок, 2 безобидных warning'а
- ✨ Команда `/donate` в Telegram боте
- ✨ Пункт 18 в меню — донат + QR код

</details>

<details>
<summary><b>v4.2.3</b> — ALPN Fix</summary>

- 🐛 Фикс `grep: binary file matches` — флаг `-a`
- ✅ Диагностика корректно показывает `ALPN: h2`

</details>

<details>
<summary><b>v4.2.2</b> — Security Audit (10 фиксов)</summary>

- 🔒 SSH `sshd_config.d/` + `ssh.socket` отключение
- 🛡️ Защита от удаления последнего домена
- 📦 `apt update` перед Fail2Ban
- ⚡ Fail2Ban `iptables-multiport`
- 🌐 UFW `allow 80/tcp` (ACME)
- 🔑 Пароли 20 символов `[a-zA-Z0-9_-]`
- ♻️ Caddy `Restart=on-failure`
- ✅ `/qr` фикс curl
- ✅ `/adduser` валидация
- 🐛 Счётчики диагностики

</details>

<details>
<summary><b>v4.2.1</b> — Banner & Branding</summary>

- ✨ ASCII баннер при запуске
- ✨ Telegram канал + сайт в баннере

</details>

<details>
<summary><b>v4.2.0</b> — DNS Ad Blocker</summary>

- ✨ unbound + ~1.5М доменов
- ✨ DNS-over-TLS (Cloudflare + Google)
- 🆕 CLI: `dns`, `dns-install`, `dns-update`

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

**GPL-3.0** © **Иван Юрьевич (Ivan Yurievich)**

Запрещено коммерческое использование без письменного разрешения автора.

📞 Связь для лицензирования: [Telegram](https://t.me/ivan_it_net) · [ivan-it.net](https://ivan-it.net)

Полный текст лицензии: [LICENSE](LICENSE)

---

<div align="center">

### 💛 Понравилось? Поддержи проект!

[![Donate](https://img.shields.io/badge/💛_Поддержать-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Star](https://img.shields.io/github/stars/ivan-yurich/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivan-yurich/naiveproxy/stargazers)
[![Fork](https://img.shields.io/github/forks/ivan-yurich/naiveproxy?style=for-the-badge&color=58A6FF)](https://github.com/ivan-yurich/naiveproxy/network)

---

📱 [**Telegram**](https://t.me/ivan_it_net) · 🌐 [**ivan-it.net**](https://ivan-it.net) · 💻 [**GitHub**](https://github.com/ivan-yurich/naiveproxy) · 💛 [**Донат**](https://www.donationalerts.com/r/ivan_yurievich)

**NaiveProxy Manager · by Иван Юрьевич**

*Профессиональный менеджер защищённого прокси-сервера*
*Обновления выходят раз в месяц · Сделано с 💛 в России*

</div>
