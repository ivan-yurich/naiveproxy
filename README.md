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
[![License](https://img.shields.io/badge/License-GPL--3.0-58A6FF?style=for-the-badge)](LICENSE)

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

### 🚀 Установка и базовая настройка

<details>
<summary><b>Какой VPS купить? Минимальные требования</b></summary>

**Минимум для работы:**
- 512 MB RAM, 1 vCPU, 10 GB диска
- Любой провайдер с Ubuntu 20.04+

**Рекомендуемые провайдеры:**
- **AEZA** — Россия, СНГ, дешёвые тарифы от 150₽/мес
- **VDSina** — отличное соотношение цена/качество
- **Hetzner** — Германия, очень быстрый (от €4/мес)
- **DigitalOcean** — Нидерланды, США (от $4/мес)
- **Vultr** — много локаций (от $2.50/мес)

⚠️ Избегай Российских хостеров для прокси — могут блокировать.

</details>

<details>
<summary><b>Какой домен купить и где?</b></summary>

**Подойдёт любой домен:**
- `.com`, `.net`, `.org` — стандартные
- `.io`, `.dev`, `.tech` — модные
- `.xyz`, `.online`, `.site` — дешёвые

**Где покупать:**
- **REG.RU** — рос. карты, .рф домены (~700₽/год)
- **Namecheap** — международный, .com от $10/год
- **Cloudflare Registrar** — по себестоимости

**Главное — настроить A-запись:**
```
your-domain.com → IP_ВАШЕГО_СЕРВЕРА
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
curl -fsSL https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh \
  -o /usr/local/bin/naiveproxy.sh && chmod +x /usr/local/bin/naiveproxy.sh
```

</details>

---

### 🔌 Подключение клиентов

<details>
<summary><b>Клиент не подключается — что делать?</b></summary>

**Пошаговая диагностика:**

```bash
# 1. Запусти полную диагностику системы
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
<summary><b>Какое приложение лучше для Android?</b></summary>

**Топ-3 для Android:**

1. **NekoBox** ⭐ — лучший, open source, без рекламы
   - [github.com/MatsuriDayo/NekoBoxForAndroid](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases)

2. **Hiddify** — простой, для новичков
   - [github.com/hiddify/hiddify-next](https://github.com/hiddify/hiddify-next/releases)

3. **Husi** — форк NekoBox с улучшениями
   - [github.com/dyhkwong/Exclave](https://github.com/dyhkwong/Exclave/releases)

⚠️ **v2rayNG не работает** с NaiveProxy!

</details>

<details>
<summary><b>Какое бесплатное приложение для iPhone?</b></summary>

**Бесплатные варианты:**

1. **Hiddify** ⭐ — лучший бесплатный, есть в App Store
2. **FoXray** — бесплатный, частичная поддержка
3. **Streisand** — бесплатный, нет в РФ App Store

**Платные (для сравнения):**
- **Shadowrocket** ($2.99) — лучшая поддержка
- **Quantumult X** ($7.99) — для продвинутых

**Способ подключения:**
1. Скопируй URI: `naive+https://user:pass@domain:443`
2. Открой Hiddify → Import from clipboard

</details>

<details>
<summary><b>Какое приложение для Windows / Mac?</b></summary>

**Windows:**
- **Hiddify Next** — UI клиент, легко настроить
- **naive.exe** — официальный CLI клиент от klzgrad
- **NekoRay** — продвинутый GUI

**macOS:**
- **Hiddify Next** — рекомендую
- **V2BoX** — есть в App Store
- **ClashX Pro** — для опытных

**Linux:**
- **NekoRay** — GUI на Qt
- **naive** CLI — для серверов

</details>

<details>
<summary><b>Как импортировать URI быстро?</b></summary>

**Метод 1 — QR код (телефон):**
```bash
sudo bash naiveproxy.sh qr
# Просто отсканируй камерой в приложении
```

**Метод 2 — через Telegram бот:**
```
В боте: /qr username
```

**Метод 3 — копировать URI:**
```bash
sudo bash naiveproxy.sh config
# Скопируй URI → "Import from clipboard" в приложении
```

</details>

---

### 🚫 DNS блокировка рекламы

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

Это **нормально**! YouTube встраивает рекламу в видеопоток с того же домена (`googlevideo.com`), что и само видео. Заблокировать только рекламу невозможно — блокировка домена убьёт и видео.

**Что работает:**
- ✅ Баннеры YouTube (на главной)
- ✅ Pre-roll реклама (иногда)
- ❌ Реклама внутри видео — не блокируется

**Решение для YouTube:** YouTube Premium или приложения типа NewPipe (Android), YouTube Vanced.

</details>

<details>
<summary><b>Как обновить blocklists вручную</b></summary>

```bash
sudo bash naiveproxy.sh dns-update
```

Или через меню:
```bash
sudo bash naiveproxy.sh dns
# → 2) Обновить blocklists
```

</details>

---

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
3. Введи имя бота (любое)
4. Введи username бота (должен заканчиваться на `bot`)
5. Скопируй токен вида `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`

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
2. Открой в браузере: `https://api.telegram.org/botYOUR_TOKEN/getUpdates`
3. Найди `"chat":{"id":12345}` — это твой ID

**Способ 2 — через @userinfobot:**
1. Напиши [@userinfobot](https://t.me/userinfobot)
2. Он покажет твой ID

</details>

<details>
<summary><b>Команда /qr не отправляет картинку</b></summary>

```bash
# Установи qrencode
apt install -y qrencode

# Перезапусти бот
systemctl restart naiveproxy-bot

# Проверь /qr в боте
```

</details>

<details>
<summary><b>Как добавить второго администратора?</b></summary>

В Telegram боте отправь:
```
/addadmin 123456789
```
(где 123456789 — Chat ID второго админа)

Посмотреть список:
```
/admins
```

</details>

---

### 🔒 SSH Hardening и безопасность

<details>
<summary><b>Как скачать SSH ключ на свой компьютер</b></summary>

```bash
# Скачать ключ через scp
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy

# Установить правильные права
chmod 600 ~/.ssh/id_naiveproxy

# Подключиться с ключом
ssh -i ~/.ssh/id_naiveproxy -p NEW_PORT user@YOUR_IP

# Или показать ключ в консоли
sudo bash naiveproxy.sh ssh-key
```

</details>

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

**Если SSH порт изменён но забыл какой:**
```bash
grep -E "^Port " /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
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

# Добавить свой IP в whitelist (навсегда)
echo "ignoreip = 127.0.0.1/8 ::1 YOUR_IP" >> /etc/fail2ban/jail.local
systemctl restart fail2ban
```

</details>

<details>
<summary><b>Как сменить SSH порт ещё раз?</b></summary>

```bash
sudo bash naiveproxy.sh ssh-hardening
# Скрипт спросит новый порт и применит все настройки
```

</details>

---

### 🔧 Управление сервером

<details>
<summary><b>Caddy не запускается — что делать</b></summary>

```bash
# 1. Проверь конфиг
caddy validate --config /etc/caddy/Caddyfile

# 2. Посмотри логи
journalctl -u caddy -n 50 --no-pager

# 3. Запусти в foreground для отладки
caddy run --config /etc/caddy/Caddyfile

# 4. Частые причины:
# - Порты 80/443 заняты (apache2, nginx)
# - Нет прав на /var/log/caddy
# - DNS не настроен (нет A-записи)
```

</details>

<details>
<summary><b>Как сменить пароль пользователю</b></summary>

```bash
sudo bash naiveproxy.sh users
# → 3) Изменить пароль
```

Или через Telegram бот:
```
/deluser username
/adduser username newpassword
```

</details>

<details>
<summary><b>Как добавить второй домен на тот же сервер</b></summary>

```bash
# 1. Создай A-запись для нового домена → тот же IP
# 2. Добавь домен:
sudo bash naiveproxy.sh domains
# → 1) Добавить домен
# 3. Caddy автоматически получит сертификат для нового домена
```

</details>

<details>
<summary><b>Сертификат не получается — Let's Encrypt ошибка</b></summary>

**Частые причины:**

```bash
# 1. DNS не настроен — проверь
dig +short your-domain.com

# 2. Порт 80 заблокирован — открой
ufw allow 80/tcp

# 3. Уже превысил лимит (5 неудачных за час)
# Подожди 1 час и попробуй снова

# 4. CAA-запись блокирует Let's Encrypt
# Проверь у регистратора — должна быть пустая или letsencrypt.org
```

</details>

<details>
<summary><b>Как сделать бэкап и восстановить</b></summary>

```bash
# Создать бэкап
tar -czf naiveproxy-backup-$(date +%Y%m%d).tar.gz \
  /etc/caddy/Caddyfile \
  /etc/naiveproxy/ \
  /var/www/html/index.html

# Скачать на свой компьютер
scp root@YOUR_IP:~/naiveproxy-backup-*.tar.gz ~/Downloads/

# Восстановить на новом сервере
sudo bash naiveproxy.sh install  # сначала установить
tar -xzf naiveproxy-backup.tar.gz -C /
systemctl restart caddy
```

</details>

<details>
<summary><b>Как полностью удалить NaiveProxy</b></summary>

```bash
sudo bash naiveproxy.sh remove
# Удалит: Caddy, конфиги, логи, systemd сервисы

# Дополнительно очистить:
apt remove --purge -y caddy fail2ban unbound
rm -rf /etc/caddy /etc/naiveproxy /etc/unbound /var/log/caddy
```

</details>

---

### 📊 Мониторинг и логи

<details>
<summary><b>Где смотреть логи</b></summary>

```bash
# Логи Caddy (доступы)
tail -f /var/log/caddy/access.log

# Логи NaiveProxy (CONNECT туннели)
tail -f /var/log/caddy/naive.log

# Systemd логи
journalctl -u caddy -f
journalctl -u naiveproxy-bot -f

# Все логи через скрипт
sudo bash naiveproxy.sh logs
```

</details>

<details>
<summary><b>Как посмотреть статистику трафика</b></summary>

```bash
sudo bash naiveproxy.sh monitor
```

Покажет:
- Трафик за сутки/месяц
- Активные пользователи
- Количество подключений
- Топ доменов

</details>

<details>
<summary><b>Сервер тормозит — как найти причину</b></summary>

```bash
# Запусти диагностику
sudo bash naiveproxy.sh diagnose

# Топ процессов по CPU
top -bn1 | head -20

# Использование памяти
free -h

# Активные соединения
ss -ant | wc -l

# Размер логов (могут забить диск)
du -sh /var/log/*
```

</details>

---

### 💛 Поддержка проекта

<details>
<summary><b>Как поддержать разработку</b></summary>

**Варианты поддержки:**

1. 💛 **Донат** на DonationAlerts:
   👉 [donationalerts.com/r/ivan_yurievich](https://www.donationalerts.com/r/ivan_yurievich)

2. ⭐ **Поставь звезду** на GitHub

3. 📢 **Расскажи друзьям** — поделись ссылкой

4. 🐛 **Сообщи о баге** — открой Issue на GitHub

5. 💡 **Предложи идею** — в Telegram канале

Спасибо за поддержку! 🙏

</details>

<details>
<summary><b>Где задать вопрос?</b></summary>

**Контакты для связи:**

- 📱 **Telegram канал** — [t.me/+XVSkY6blCTY0ZDU6](https://t.me/+XVSkY6blCTY0ZDU6)
- 🌐 **Сайт** — [ivan-it.net](https://ivan-it.net)
- 💻 **GitHub Issues** — для багов и предложений

⏱️ Обычно отвечаю в течение суток.

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

GPL-3.0 © **Иван Юрьевич (Ivan Yurievich)**  
Запрещено коммерческое использование без разрешения автора.  
📞 Связь: [Telegram](https://t.me/+XVSkY6blCTY0ZDU6) · [ivan-it.net](https://ivan-it.net)

---

<div align="center">

### 💛 Понравилось? Поддержи проект!

[![Donate](https://img.shields.io/badge/💛_Поддержать-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Star](https://img.shields.io/github/stars/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivanstudiya-cpu/naiveproxy/stargazers)

📱 [Telegram](https://t.me/+XVSkY6blCTY0ZDU6) · 🌐 [ivan-it.net](https://ivan-it.net) · 💻 [GitHub](https://github.com/ivanstudiya-cpu/naiveproxy)

*NaiveProxy Manager · by Иван Юрьевич · Обновления раз в месяц*

</div>
