<p align="center">
  <a href="README.md">Русский</a> · <a href="README_EN.md">English</a> · <a href="ARTICLE_RU.md">Большая статья</a>
</p>

# Yurich Panel

Профессиональный Bash-менеджер для развёртывания и сопровождения приватного прокси-сервиса на Ubuntu VPS.

[![Version](https://img.shields.io/badge/version-5.6.2-D4A017?style=for-the-badge)](https://github.com/ivan-yurich/naiveproxy/releases)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-PolyForm%20Noncommercial%20%2B%20Commercial-58A6FF?style=for-the-badge)](LICENSE)

[![Stars](https://img.shields.io/github/stars/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=D4A017)](https://github.com/ivan-yurich/naiveproxy/stargazers)
[![Issues](https://img.shields.io/github/issues/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=F85149)](https://github.com/ivan-yurich/naiveproxy/issues)
[![Last commit](https://img.shields.io/github/last-commit/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=3FB950)](https://github.com/ivan-yurich/naiveproxy/commits/main)

## Навигация

[Быстрый старт](#быстрый-старт) ·
[Возможности](#возможности) ·
[Команды](#команды) ·
[Telegram-бот](#telegram-бот) ·
[Подписки](#страницы-подписки) ·
[Безопасность](#безопасность) ·
[Диагностика](#диагностика) ·
[Статья](ARTICLE_RU.md) ·
[FAQ](#faq) ·
[Changelog](#changelog)

## О проекте

Yurich Panel — это единый установочный и административный скрипт для VPS. Он автоматизирует подготовку сервера, сборку Caddy 2 с `forwardproxy@naive`, выпуск TLS-сертификата, управление пользователями, настройку firewall, диагностику, мониторинг и Telegram-управление.

Проект рассчитан на администраторов, которым нужен воспроизводимый способ развернуть приватный сервис и дальше обслуживать его без ручного редактирования десятков системных файлов.

Основной стек:

- Caddy 2 с `klzgrad/forwardproxy@naive`;
- NaiveProxy;
- systemd;
- UFW;
- Fail2Ban;
- Telegram Bot API;
- optional: Xray-core, Hysteria 2, Cloudflare WARP proxy mode, unbound DNS.

## Что нового в v5.6.2

Версия `5.6.2` закрепляет единый публичный бренд **Yurich Panel** и сохраняет инструменты v5.6.x: выбор языка SSH-панели, self-update с SHA256, pin версий ключевых компонентов, health-check, safe apply, encrypted backup, export/import и сроки подписок.

| Направление | Что добавлено |
|---|---|
| Brand refresh | Единый публичный бренд проекта: `Yurich Panel` |
| Compatibility | Технические имена протоколов сохранены; legacy-маркер `NaiveProxy Manager` оставлен для self-update старых релизов |
| SSH panel language | Новая команда `language` и пункт меню `28` для выбора Русский / English |
| Config persistence | Выбранный язык сохраняется в `/etc/naiveproxy/naive.conf` |
| Self-update | Проверка `naiveproxy.sh.sha256` перед установкой обновления; строгий режим через `NAIVEPROXY_REQUIRE_SHA=1` |
| Pin versions | По умолчанию закреплены `xcaddy v0.4.6`, `forwardproxy d62c80d`, `Xray v26.3.27`, `Hysteria app/v2.9.2`; можно переопределить через `NAIVEPROXY_*` |
| Health-check | Команда `health` проверяет Caddy, DNS, Telegram bot service, WARP, Xray и Hysteria одним отчётом |
| Safe apply | Команда `safe-apply` валидирует включённые конфиги и откатывает Caddyfile при ошибке |
| Backups | Команда `backup` создаёт encrypted archive `/etc/naiveproxy` и связанных конфигов через OpenSSL |
| Export/import | Команды `export` и `import` переносят пользователей, токены подписок и метаданные сроков |
| Срок пользователя | При создании пользователя можно выбрать 1-12 месяцев; срок отображается в конфиге и на странице подписки |
| Android subscriptions | Имена URI в подписке получают метку срока, чтобы профиль проще отличался в клиентах |
| Bridge builder | Меню 27 сохраняет bridge-профиль “мобилка → первый VPS → второй VPS” и готовит основу для Xray/sing-box chaining |
| Production menu | Новое меню 27: health-check, safe apply, encrypted backup, export/import и bridge builder |
| DNS safety | Запрещена любая маска `/0` для VPN DNS CIDR, чтобы не получить open resolver |
| DNS (Unbound) CLI | `aurum-dns-status` и uninstall читают env только при владельце `root` |
| Watchdog Telegram | Исправлена отправка monitor-уведомлений через `--data-urlencode` |
| Bot install | `bot-install` синхронизирует текущий валидный скрипт в `/usr/local/bin/naiveproxy.sh` |
| Telegram polling | Исправлен `getUpdates`: `allowed_updates` отправляется как JSON-массив, поэтому `/menu` снова обрабатывается |
| Bot service | После настройки Telegram можно сразу установить `naiveproxy-bot.service` по Enter |
| Telegram Menu | `setMyCommands` и `setChatMenuButton`, чтобы кнопка Menu показывала все команды |
| Bot CLI | Новая команда `bot-menu` для ручного обновления Telegram-меню |
| DNS (Unbound) | Отдельный production-ready проект `aurum-dns/` с install/uninstall/examples/scripts |
| Recursive DNS | Unbound работает как собственный recursive resolver без Cloudflare/Google upstream |
| DNSSEC | Trust anchor не дублируется в конфиге, чтобы не ловить `trust anchor presented twice` |
| DNS для VPN | `:53` открывается только для заданных VPN CIDR, без open resolver |
| Bind safety | Unbound слушает `127.0.0.1` и указанный VPN gateway IP, но не `0.0.0.0` |
| Auto gateway | Если `10.0.0.1` отсутствует, скрипт может создать `10.0.0.1/32` на `lo` через systemd |
| Adblock removed | Blocklists/whitelist удалены из основного скрипта |
| Hysteria per-user | При добавлении/удалении/смене пароля пользователя Hysteria 2 пересобирает `userpass` auth |
| Hysteria порт | В меню можно выбрать порт по умолчанию `8443` или указать UDP порт вручную |
| Подписки | Личная страница пользователя теперь включает Naive + Hysteria 2 + Xray, если модули установлены |
| WARP SSH-safe | Full tunnel добавляет split-tunnel exclude для текущего SSH IP и включает аварийный rollback |
| WARP full tunnel | Меню 21 может включить `warp` / `warp+doh`, чтобы весь исходящий трафик VPS шёл через WARP |
| WARP proxy mode | Старый `127.0.0.1:40000` сохранён для приложений и Xray outbound |
| Протоколы WARP | Выбор `auto`, `MASQUE`, `WireGuard`; auto пробует MASQUE, затем WireGuard |
| Диагностика | Отдельная проверка full tunnel без `-x` и local proxy через HTTP/SOCKS5 |
| Xray меню 23 | Новый пункт `Создать Xray пользователя + подписка` |
| Единая выдача | При добавлении Naive-пользователя можно сразу создать Xray/VLESS профиль с тем же логином |
| Подписка | Персональная `/s/<token>/` страница собирает Naive + VLESS/Trojan/REALITY ссылки вместе |
| CLI | Новая команда `xray-add-user USER` |
| Telegram меню | Постоянная русская reply-клавиатура после `/start`, `/help` или `/menu` |
| Быстрые кнопки | Статус, пользователи, QR, подписка, Xray, Hysteria, WARP, диагностика, логи, restart и автофикс |
| Совместимость | Все старые slash-команды продолжают работать без изменений |
| Безопасность | Кнопки обрабатываются только для `TG_CHAT_ID` и дополнительных администраторов |
| Создание пользователя | После добавления сразу выводится клиентский URI, JSON и QR |
| Страница подписки | `/s/<token>/` создаётся автоматически для нового Naive/Xray пользователя |
| Telegram | `/adduser` отправляет URI, QR-картинку и ссылку на страницу подписки |
| Удаление пользователя | При удалении чистится token-файл и web-папка страницы подписки |
| Hysteria 2 | Проверка и перевыпуск пустого/короткого `obfs.salamander.password` |
| Xray mKCP | Удалён устаревший `headerType=wechat-video`; mKCP использует современный config без `header`/`seed` |
| Hysteria 2 | Безопасный генератор паролей без сбоев `pipefail`/`SIGPIPE` |
| WARP proxy | Проверка HTTP proxy и SOCKS5 fallback с обязательным `warp=on` |
| Xray + WARP | При включённом WARP Xray outbound направляется через `127.0.0.1:40000` |
| Xray REALITY | Исправлен парсинг `xray x25519`, где публичный ключ может выводиться как `Password` |
| Страницы подписки | Персональный secret URL `/s/<token>/` для каждого пользователя |
| Raw import | `links.txt` для импорта конфигураций в совместимые клиенты |
| Ротация токенов | `subscription-reset USER` перевыпускает URL и удаляет старую страницу |
| Личная страница | Отдельная приватная страница `/p/<token>/` |
| Telegram v2 | `/sub`, `/subreset`, `/devices`, `/lockuser`, `/unlockuser`, `/xray`, `/xraystatus`, `/diagfix`, `/privatepage` |
| Privacy headers | `X-Robots-Tag` и `Cache-Control: no-store` для `/s/*` и `/p/*` |
| Diagnose fix | Автофикс восстанавливает privacy-файлы и типовые настройки |

## Возможности

### Базовая установка

- установка зависимостей;
- проверка DNS домена;
- установка или обновление Go;
- сборка Caddy с нужным модулем;
- создание Caddyfile;
- выпуск и продление TLS через Caddy;
- создание systemd service;
- настройка UFW;
- включение BBR;
- генерация клиентских конфигов и QR-кодов.

### Пользователи

- добавление и удаление пользователей;
- генерация безопасного пароля;
- вывод URI и JSON-конфига;
- QR-код для мобильного клиента;
- защита от удаления последнего активного пользователя;
- валидация логинов и паролей.

### Страницы подписки

- отдельная страница на каждого пользователя;
- secret URL вместо пути по логину;
- `links.txt` для импорта;
- NaiveProxy URI;
- naive-client JSON;
- Xray/VLESS/Trojan ссылки, если Xray включён;
- подсказки для Windows, Android, iOS/macOS и Linux;
- ротация токена при утечке ссылки.

### Telegram-бот

- 25+ команд;
- русское кнопочное меню;
- мультиадмины;
- управление пользователями;
- QR-коды;
- страницы подписки;
- отчёт по устройствам;
- lock/unlock пользователя;
- Xray config/status;
- диагностика и автофикс;
- перезапуск и обновление сервисов.

### Дополнительные модули

- Xray Modern transports: VLESS, Trojan, REALITY, mKCP, WebSocket, gRPC, HTTPUpgrade, XHTTP;
- Hysteria 2 на отдельном UDP-порту;
- Cloudflare WARP в локальном proxy mode;
- DNS на Unbound для приватного DNS внутри VPN;
- SSH hardening;
- Fail2Ban;
- мониторинг ресурсов и логов.

## Быстрый старт

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/naiveproxy.sh)
```

Во время установки скрипт спросит:

- домен;
- email для TLS;
- логин первого пользователя;
- пароль или генерацию случайного пароля;
- нужно ли обновить систему;
- включать ли SSH hardening;
- включать ли BBR;
- настраивать ли Telegram-бот.

После установки будет показан клиентский URI, JSON-конфиг и QR-код.

## Требования

| Параметр | Минимум | Рекомендуется |
|---|---:|---:|
| ОС | Ubuntu 20.04 | Ubuntu 22.04 / 24.04 |
| Права | root | root |
| RAM | 512 MB | 1 GB+ |
| Диск | 1 GB | 5 GB+ |
| CPU | 1 vCPU | 1+ vCPU |
| Порты | 80/tcp, 443/tcp, 443/udp | плюс отдельный SSH-порт |
| Домен | A-запись на IP сервера | отдельный технический домен |

## Команды

### Основные

```bash
sudo bash naiveproxy.sh install
sudo bash naiveproxy.sh status
sudo bash naiveproxy.sh config
sudo bash naiveproxy.sh config USER
sudo bash naiveproxy.sh users
sudo bash naiveproxy.sh domains
sudo bash naiveproxy.sh monitor
sudo bash naiveproxy.sh logs
sudo bash naiveproxy.sh restart
sudo bash naiveproxy.sh reload
sudo bash naiveproxy.sh update
sudo bash naiveproxy.sh self-update
sudo bash naiveproxy.sh language
sudo bash naiveproxy.sh remove
```

### Production tools

```bash
sudo bash naiveproxy.sh health
sudo bash naiveproxy.sh safe-apply
sudo bash naiveproxy.sh backup
sudo bash naiveproxy.sh export
sudo bash naiveproxy.sh import /path/to/naiveproxy-state.tar.gz
sudo bash naiveproxy.sh bridge
```

### Подписки и web-страницы

```bash
sudo bash naiveproxy.sh subscription USER
sudo bash naiveproxy.sh subscription-reset USER
sudo bash naiveproxy.sh private-page
sudo bash naiveproxy.sh private-page reset
sudo bash naiveproxy.sh camouflage
```

### Лимит устройств

```bash
sudo bash naiveproxy.sh devices
sudo bash naiveproxy.sh devices-scan
sudo bash naiveproxy.sh devices-config
sudo bash naiveproxy.sh devices-disable
sudo bash naiveproxy.sh devices-lock USER
sudo bash naiveproxy.sh devices-unlock USER
```

### Xray

```bash
sudo bash naiveproxy.sh xray
sudo bash naiveproxy.sh xray-install
sudo bash naiveproxy.sh xray-add-user USER 12
sudo bash naiveproxy.sh xray-config USER
sudo bash naiveproxy.sh xray-status
sudo bash naiveproxy.sh xray-logs
sudo bash naiveproxy.sh xray-remove
```

### Hysteria 2

```bash
sudo bash naiveproxy.sh hysteria
sudo bash naiveproxy.sh hysteria-install
sudo bash naiveproxy.sh hysteria-config
sudo bash naiveproxy.sh hysteria-status
sudo bash naiveproxy.sh hysteria-logs
sudo bash naiveproxy.sh hysteria-port
sudo bash naiveproxy.sh hysteria-remove
```

### WARP modes

```bash
sudo bash naiveproxy.sh warp
sudo bash naiveproxy.sh warp-install
sudo bash naiveproxy.sh warp-proxy
sudo bash naiveproxy.sh warp-full
sudo bash naiveproxy.sh warp-protocol
sudo bash naiveproxy.sh warp-config
sudo bash naiveproxy.sh warp-status
sudo bash naiveproxy.sh warp-test
sudo bash naiveproxy.sh warp-full-test
sudo bash naiveproxy.sh warp-logs
sudo bash naiveproxy.sh warp-disable
sudo bash naiveproxy.sh warp-remove
```

`proxy mode` слушает `127.0.0.1:40000` и работает только для приложений, где явно указан SOCKS5/HTTP proxy. Для долгих соединений и фоновых сервисов лучше использовать Xray outbound или full tunnel.

`full tunnel` переводит весь исходящий трафик VPS через WARP. Для осторожного включения используй меню `21` → `2`; откат: `sudo bash naiveproxy.sh warp-disable`.

### DNS (Unbound)

```bash
sudo bash naiveproxy.sh dns
sudo bash naiveproxy.sh dns-install
sudo bash naiveproxy.sh dns-status
sudo bash naiveproxy.sh dns-restart
sudo bash naiveproxy.sh unbound
sudo bash naiveproxy.sh unbound-install
sudo bash naiveproxy.sh unbound-vpn
sudo bash naiveproxy.sh unbound-status
sudo bash naiveproxy.sh aurum-dns
```

DNS (Unbound) поднимает собственный recursive Unbound resolver для сервера и VPN-клиентов:

- без Google/Cloudflare upstream;
- без рекламных blocklists;
- без `0.0.0.0` bind;
- без open resolver;
- с UFW allowlist только для VPN CIDR;
- с отдельным standalone-проектом `aurum-dns/`.

Для VPN-клиентов DNS открывается только по указанным CIDR. Если gateway IP, например `10.0.0.1`, ещё не назначен интерфейсу сервера, скрипт предложит создать безопасный локальный gateway `10.0.0.1/32` на `lo`. Полный sing-box Android VPN/TUN конфиг на странице подписки автоматически получит DNS (Unbound).

### Диагностика и SSH

```bash
sudo bash naiveproxy.sh diagnose
sudo bash naiveproxy.sh diagnose --fix
sudo bash naiveproxy.sh ssh-hardening
sudo bash naiveproxy.sh ssh-rescue
sudo bash naiveproxy.sh ssh-key
sudo bash naiveproxy.sh sysupdate
```

## Telegram-бот

Установка бота как systemd service:

```bash
sudo bash naiveproxy.sh bot-install
systemctl status naiveproxy-bot --no-pager
sudo bash naiveproxy.sh bot-menu
```

Запуск в foreground:

```bash
sudo bash naiveproxy.sh bot
```

Команды:

| Раздел | Команды |
|---|---|
| Меню | `/start`, `/help`, `/menu` |
| Информация | `/status`, `/stats`, `/diagnose`, `/logs`, `/cert`, `/xraystatus`, `/hysteria`, `/warp` |
| Пользователи | `/users`, `/adduser`, `/deluser`, `/qr` |
| Подписки | `/sub`, `/subreset` |
| Лимит устройств | `/devices`, `/lockuser`, `/unlockuser` |
| Xray | `/xray`, `/xrayadduser`, `/xraystatus` |
| Управление | `/restart`, `/update`, `/selfupdate`, `/diagfix`, `/privatepage` |
| Администраторы | `/admins`, `/addadmin`, `/deladmin` |

После `/start` бот показывает постоянные кнопки: статус, пользователи, QR, подписка, Xray, Hysteria, WARP, диагностика, логи, перезапуск Caddy, автофикс и донат.

Кнопка Telegram `Menu` тоже настраивается автоматически через Bot API. Если меню не появилось сразу, выполни:

```bash
sudo bash naiveproxy.sh bot-menu
systemctl restart naiveproxy-bot
```

Telegram-доступ ограничивается `TG_CHAT_ID` и списком дополнительных администраторов.

## Страницы подписки

Создать или показать страницу:

```bash
sudo bash naiveproxy.sh subscription USER
```

Пример формата:

```text
https://<your-domain.example>/s/<secret-token>/
https://<your-domain.example>/s/<secret-token>/links.txt
```

Перевыпустить токен:

```bash
sudo bash naiveproxy.sh subscription-reset USER
```

Старый каталог страницы удаляется. Новый URL создаётся автоматически.

Для приватных web-путей скрипт добавляет:

- `robots.txt`;
- `meta robots="noindex,nofollow,noarchive"`;
- `X-Robots-Tag`;
- `Cache-Control: no-store`.

## Безопасность

Скрипт включает несколько уровней защиты:

- Caddyfile не создаётся без активных пользователей;
- логины и пароли проходят валидацию;
- конфиги и файлы пользователей получают права `600`;
- директории токенов получают права `700`;
- перед `source` конфигурации проверяется владелец файла;
- UFW ограничивает входящий трафик;
- Fail2Ban защищает SSH;
- SSH hardening выполняется только после явного подтверждения;
- Xray config проверяется перед запуском;
- Caddyfile валидируется перед reload/restart;
- есть защита от удаления последнего активного пользователя;
- страницы подписки создаются по случайным токенам.

Важно: secret URL страницы подписки не заменяет полноценную авторизацию. Если ссылка утекла, перевыпустите токен командой `subscription-reset USER`.

## Диагностика

```bash
sudo bash naiveproxy.sh diagnose
```

Проверяются:

- Caddy и модуль forwardproxy;
- Caddyfile;
- TLS;
- DNS домена;
- порты;
- ALPN;
- UFW;
- Fail2Ban;
- RAM, диск, CPU;
- журналы Caddy;
- Xray;
- WARP proxy mode;
- лимит устройств;
- версия скрипта.

Автофикс:

```bash
sudo bash naiveproxy.sh diagnose --fix
```

Он пытается восстановить права файлов, Caddyfile, UFW-правила, cron лимита устройств, Xray restart и privacy-файлы для `/s/` и `/p/`.

## Структура файлов

```text
/usr/local/bin/naiveproxy.sh
/usr/local/bin/caddy
/etc/naiveproxy/naive.conf
/etc/naiveproxy/users.conf
/etc/naiveproxy/users.disabled
/etc/naiveproxy/xray-users.conf
/etc/naiveproxy/xray-users.disabled
/etc/naiveproxy/subscriptions/
/etc/caddy/Caddyfile
/etc/systemd/system/caddy.service
/etc/systemd/system/naiveproxy-bot.service
/var/log/caddy/naive.log
/var/www/html/index.html
/var/www/html/s/<token>/
/var/www/html/p/<token>/
```

## Клиентские конфиги

Naive URI:

```text
naive+https://USER:PASSWORD@<your-domain.example>:443
```

`naive-client` JSON:

```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://USER:PASSWORD@<your-domain.example>:443"
}
```

`sing-box` outbound:

```json
{
  "type": "http",
  "tag": "naiveproxy-out",
  "server": "<your-domain.example>",
  "server_port": 443,
  "username": "USER",
  "password": "PASSWORD",
  "tls": {
    "enabled": true,
    "server_name": "<your-domain.example>"
  }
}
```

## Обновление

Обновить Caddy:

```bash
sudo bash naiveproxy.sh update
```

Обновить сам скрипт:

```bash
sudo bash naiveproxy.sh self-update
```

Проверить версию:

```bash
sudo bash naiveproxy.sh version
```

## Удаление

```bash
sudo bash naiveproxy.sh remove
```

Перед удалением скрипт запрашивает подтверждение.

## Большая статья

Полный обзор проекта, архитектуры, модулей, безопасности и сценариев работы доступен здесь:

[Yurich Panel v5.5.0: большой обзор скрипта](ARTICLE_RU.md)

## FAQ

### Почему Caddy собирается из исходников?

Обычный пакет Caddy не содержит нужный `forwardproxy@naive` модуль. Поэтому скрипт собирает Caddy через `xcaddy` и подбирает версию, требуемую модулем.

### Можно ли обновлять пользователей без полной переустановки?

Да. Пользователи хранятся в `/etc/naiveproxy/users.conf`. После изменения скрипт перегенерирует Caddyfile и делает reload/restart Caddy.

### Что делать, если клиентская ссылка утекла?

Смените пароль пользователя или удалите пользователя и создайте заново. Для страницы подписки выполните:

```bash
sudo bash naiveproxy.sh subscription-reset USER
```

### Что делать после неудачной настройки?

Запустите:

```bash
sudo bash naiveproxy.sh diagnose
sudo bash naiveproxy.sh diagnose --fix
```

После этого проверьте:

```bash
systemctl status caddy --no-pager
caddy validate --config /etc/caddy/Caddyfile
ss -tulpn | grep ':443'
```

### Можно ли использовать несколько доменов?

Да. В скрипте есть раздел управления доменами. При включённом Xray fallback hub мультидоменный режим Caddy переводится в локальный fallback-сценарий.

### Что делать, если SSH hardening меняет доступ?

Перед включением SSH hardening убедитесь, что есть доступ через консоль провайдера. Для восстановления используйте:

```bash
sudo bash naiveproxy.sh ssh-rescue
```

## Changelog

### v5.6.2

- проект переименован в экосистему `Yurich`;
- убрана отдельная архитектура подбрендов, оставлен единый публичный бренд `Yurich Panel`;
- интерфейс, Telegram-сообщения, страницы подписки, DNS-модуль и README приведены к единому неймингу `Yurich Panel`;
- технические названия `NaiveProxy`, `Xray`, `Hysteria 2`, `Caddy`, `Unbound` оставлены там, где они обозначают реальные протоколы и компоненты;
- legacy-маркер `NaiveProxy Manager` оставлен в скрипте, чтобы self-update старых версий мог принять новый файл;
- добавлен выбор языка SSH-панели: русский / English;
- добавлена команда `language` и пункт меню `28`;
- выбранный язык сохраняется в `LANG_UI` внутри `/etc/naiveproxy/naive.conf`;
- переведён основной экран SSH-панели: статусы, заголовки и пункты главного меню.
- лицензия проекта переведена на `PolyForm Noncommercial 1.0.0 + Commercial License`, чтобы коммерческое использование требовало отдельного разрешения автора.

### v5.6.0

- добавлен self-update с SHA256-проверкой `naiveproxy.sh.sha256`;
- `xcaddy`, `forwardproxy`, Xray и Hysteria получили pinned defaults вместо `latest`;
- добавлена команда `health` для проверки Caddy, DNS (Unbound), Telegram bot service, WARP, Xray и Hysteria;
- добавлена команда `safe-apply`: validate включённых конфигов, reload Caddy и rollback при ошибке;
- добавлена команда `backup` для encrypted backup `/etc/naiveproxy` и связанных системных конфигов;
- добавлены команды `export` / `import` для пользователей, токенов подписок и metadata;
- при создании пользователя можно выбрать срок 1-12 месяцев;
- страницы подписки показывают срок пользователя, а URI получают понятные labels с датой;
- добавлено меню 27 `Production tools / Bridge`;
- добавлен bridge builder для профилей “мобилка → первый VPS → второй VPS”.

### v5.5.15

- запрещена любая VPN DNS подсеть с маской `/0`, а не только строка `0.0.0.0/0`;
- standalone `aurum-dns` uninstall/status теперь читают env-файл только при владельце `root` и правах `600`;
- исправлена отправка Telegram watchdog-уведомлений в генерируемом `monitor.sh`;
- `bot-install` синхронизирует текущий валидный скрипт в `/usr/local/bin/naiveproxy.sh`, чтобы systemd-сервис не запускал старую копию.

### v5.5.14

- исправлен Telegram long polling: `allowed_updates` теперь передаётся в формате JSON-массива;
- при настройке Telegram скрипт предлагает сразу установить и запустить `naiveproxy-bot.service`;
- `bot-install` проверяет наличие `/usr/local/bin/naiveproxy.sh` и восстанавливает его перед созданием systemd-сервиса;
- `/start`, `/help`, `/menu` работают только при запущенном `naiveproxy-bot.service`, это теперь явно подсвечивается в настройке.

### v5.5.13

- добавлена настройка Telegram Bot API `setMyCommands`;
- добавлена настройка Telegram `Menu` button через `setChatMenuButton`;
- добавлена CLI-команда `bot-menu` для ручного обновления списка команд;
- бот применяет меню при `bot-install` и при запуске сервиса;
- `/start`, `/help`, `/menu` сохраняют русскую reply-клавиатуру быстрых действий.

### v5.5.12

- добавлен автоматический локальный DNS gateway `10.0.0.1/32` на `lo`;
- добавлен systemd-сервис `aurum-dns-gateway.service`, который поднимает gateway до запуска Unbound;
- меню `17 → 2` больше не падает, если `10.0.0.1` отсутствует, а предлагает создать gateway автоматически;
- полный sing-box Android VPN/TUN конфиг теперь автоматически включает DNS (Unbound) через `tcp://10.0.0.1:53`;
- персональная страница подписки показывает готовый sing-box TUN конфиг с DNS (Unbound).

### v5.5.11

- удалена DNS-блокировка рекламы из основного скрипта;
- добавлен безопасный DNS (Unbound) режим на Unbound для VPN-клиентов;
- исправлена ошибка `trust anchor presented twice`: основной конфиг больше не дублирует `auto-trust-anchor-file`;
- добавлен standalone-проект `aurum-dns/` с install/uninstall/configs/examples/scripts/README;
- добавлены команды `aurum-dns-status`, `aurum-dns-test`, `aurum-dns-restart`;
- установка отключает `systemd-resolved` DNSStubListener через `resolved.conf.d/no-stub.conf` и не меняет `/etc/resolv.conf`;
- добавлен auto gateway `aurum-dns-gateway.service` для клиентских VPN/TUN конфигов.

### v5.5.10

- исправлен запуск Unbound при включении DNS для VPN-клиентов;
- удалён bind на `0.0.0.0:53`, который конфликтовал с `systemd-resolved`;
- VPN DNS теперь слушает конкретные IPv4 адреса интерфейсов сервера;
- статус меню теперь показывает `установлен, не запущен`, если пакет есть, но сервис упал;
- перед рестартом Unbound выполняется `systemctl reset-failed`, чтобы выйти из start-limit после старой ошибки;
- уменьшен `so-rcvbuf`, чтобы убрать шумное предупреждение Unbound на стандартном ядре Ubuntu.

### v5.5.9

- добавлен recursive DNS mode для Unbound без Cloudflare/Google upstream;
- добавлен выбор режима: recursive/forward DoT и adblock on/off;
- добавлен DNSSEC trust anchor и DNSSEC test в статусе;
- добавлен режим DNS для VPN-клиентов через безопасные CIDR allowlist;
- Unbound слушает локально `127.0.0.1:53` и `127.0.0.1:5335`;
- добавлены команды `unbound-mode` и `unbound-vpn`;
- усилена защита от open resolver через `access-control` и UFW rules.

### v5.5.8

- Unbound DNS оформлен как plugin/module со статусом, диагностикой и CLI-алиасами `unbound-*`;
- Hysteria 2 переведён на `auth.type: userpass` для текущих пользователей NaiveProxy;
- добавлен выбор порта Hysteria 2: дефолт `8443` или ручной UDP порт;
- при создании пользователя автоматически создаётся персональный Hysteria 2 профиль и QR;
- страница подписки теперь добавляет Hysteria 2 URI и sing-box outbound;
- при удалении или смене пароля пользователя Hysteria 2 пересобирает userpass auth;
- WARP full tunnel получил SSH-safe режим: exclude route для текущего SSH IP и rollback через `systemd-run`.

### v5.5.7

- добавлен WARP full-tunnel режим для всего исходящего трафика VPS;
- меню 21 разделено на proxy mode и full tunnel;
- добавлены команды `warp-full`, `warp-proxy`, `warp-protocol`, `warp-full-test`;
- добавлен выбор протокола `auto`, `MASQUE`, `WireGuard`;
- диагностика WARP теперь различает proxy и full-tunnel режимы;
- в описании WARP добавлено предупреждение про ограничения Local Proxy для долгих соединений.

### v5.5.6

- в меню 23 добавлен пункт создания Xray пользователя без переустановки Xray;
- новая команда `xray-add-user USER`;
- при создании Naive-пользователя можно сразу добавить Xray/VLESS профиль;
- страница подписки автоматически обновляется и содержит Naive + Xray ссылки;
- Telegram `/adduser` при активном Xray создаёт общий профиль и отправляет Xray ссылки;
- добавлена Telegram-команда `/xrayadduser USER`.

### v5.5.5

- добавлено русское кнопочное меню Telegram;
- бот теперь принимает текст кнопок, а не только сообщения с `/`;
- добавлена команда `/menu`;
- добавлены Telegram-команды `/hysteria` и `/warp`;
- неизвестные команды возвращают меню с кнопками;
- документация обновлена под новый UX бота.

### v5.5.4

- при добавлении Naive пользователя в меню сразу создаётся страница подписки;
- после создания пользователя автоматически выводятся URI, JSON и QR;
- Telegram `/adduser` теперь отправляет URI, QR-картинку и страницу `/s/<token>/`;
- Telegram `/deluser` удаляет пользователя и его страницу подписки;
- при удалении пользователя в меню удаляются token-файл и web-папка подписки;
- Xray install теперь добавляет выбранного Xray пользователя в файл пользователей и создаёт страницу подписки.

### v5.5.3

- добавлена валидация Hysteria 2 password и obfs password перед записью `hysteria.yaml`;
- пустой или короткий `obfs.salamander.password` теперь автоматически перевыпускается;
- пароли Hysteria 2 записываются в YAML в кавычках;
- Xray mKCP обновлён под новые версии Xray-core: удалены legacy `header`/`seed`;
- клиентские mKCP ссылки теперь используют `type=mkcp` без `headerType`.

### v5.5.2

- исправлена автогенерация паролей Hysteria 2 под `set -euo pipefail`;
- добавлен единый безопасный генератор случайных паролей;
- усилена WARP-диагностика: HTTP proxy, SOCKS5 fallback, сравнение direct/proxy trace;
- WARP install теперь требует подтверждённый `warp=on`;
- Xray при включённом WARP получает outbound через локальный WARP HTTP proxy.

### v5.5.1

- исправлен парсинг REALITY-ключей для новых сборок Xray;
- `xray x25519` теперь понимает вывод `Public key` и `Password`;
- добавлена подсказка для ручной проверки генерации ключей.

### v5.5.0

- добавлены страницы подписки пользователей;
- добавлен `links.txt`;
- добавлена ротация токенов;
- добавлена личная фейковая страница;
- расширен Telegram-бот;
- добавлены команды `/sub`, `/subreset`, `/devices`, `/lockuser`, `/unlockuser`, `/xray`, `/xraystatus`, `/diagfix`, `/privatepage`;
- добавлены privacy headers для `/s/*` и `/p/*`;
- `diagnose --fix` восстанавливает privacy-файлы.

### v5.4.0

- лимит устройств учитывает Caddy/Naive и Xray access logs;
- `lock-user` отключает пользователя в Naive и Xray;
- `devices-unlock` возвращает пользователя в обеих подсистемах;
- добавлен `diagnose --fix`;
- автофикс восстанавливает права, Caddyfile, сервисы, UFW-порты, cron лимита и Xray restart.

### v5.3.0

- добавлен Xray-core;
- добавлены VLESS TCP TLS, XTLS Vision, REALITY TCP;
- добавлены mKCP, WebSocket, gRPC, HTTPUpgrade, XHTTP;
- добавлен Trojan WebSocket через fallback;
- добавлен опциональный fallback hub на 443.

### v5.2.0

- добавлен лимит устройств;
- добавлены уникальные пользовательские ссылки;
- добавлены ручные команды lock/unlock.

### v5.1.0

- добавлен Cloudflare WARP proxy mode;
- добавлены команды настройки, проверки и удаления WARP.

### v5.0.0

- добавлен Hysteria 2;
- добавлены конфиги и QR для мобильных клиентов.

## Лицензия

Проект распространяется по модели [PolyForm Noncommercial 1.0.0 + Commercial License](LICENSE).

Разрешено личное, учебное, исследовательское и другое некоммерческое использование.

Коммерческое использование, перепродажа, включение в платные панели, SaaS, хостинг, VPN/proxy-сервисы, managed services и корпоративные продукты требует отдельной письменной коммерческой лицензии от автора.

## Поддержка проекта

- Telegram: [@ivan_it_net](https://t.me/ivan_it_net)
- Website: [ivan-it.net](https://ivan-it.net)
- GitHub: [ivan-yurich/naiveproxy](https://github.com/ivan-yurich/naiveproxy)
- Донат: [DonationAlerts](https://www.donationalerts.com/r/ivan_yurievich)
