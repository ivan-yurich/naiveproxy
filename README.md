<p align="center">
  <a href="README.md">Русский</a> · <a href="README_EN.md">English</a> · <a href="ARTICLE_RU.md">Большая статья</a>
</p>

# NaiveProxy Manager

Профессиональный Bash-менеджер для развёртывания и сопровождения приватного прокси-сервиса на Ubuntu VPS.

[![Version](https://img.shields.io/badge/version-5.5.3-D4A017?style=for-the-badge)](https://github.com/ivan-yurich/naiveproxy/releases)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-GPL--3.0-58A6FF?style=for-the-badge)](LICENSE)

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

NaiveProxy Manager — это единый установочный и административный скрипт для VPS. Он автоматизирует подготовку сервера, сборку Caddy 2 с `forwardproxy@naive`, выпуск TLS-сертификата, управление пользователями, настройку firewall, диагностику, мониторинг и Telegram-управление.

Проект рассчитан на администраторов, которым нужен воспроизводимый способ развернуть приватный сервис и дальше обслуживать его без ручного редактирования десятков системных файлов.

Основной стек:

- Caddy 2 с `klzgrad/forwardproxy@naive`;
- NaiveProxy;
- systemd;
- UFW;
- Fail2Ban;
- Telegram Bot API;
- optional: Xray-core, Hysteria 2, Cloudflare WARP proxy mode, unbound DNS.

## Что нового в v5.5.3

Версия `5.5.3` исправляет запуск Hysteria 2 и совместимость mKCP с новыми сборками Xray-core.

| Направление | Что добавлено |
|---|---|
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
- DNS-фильтрация рекламы и трекеров через unbound;
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
sudo bash naiveproxy.sh remove
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
sudo bash naiveproxy.sh hysteria-remove
```

### WARP proxy mode

```bash
sudo bash naiveproxy.sh warp
sudo bash naiveproxy.sh warp-install
sudo bash naiveproxy.sh warp-config
sudo bash naiveproxy.sh warp-status
sudo bash naiveproxy.sh warp-test
sudo bash naiveproxy.sh warp-logs
sudo bash naiveproxy.sh warp-disable
sudo bash naiveproxy.sh warp-remove
```

### DNS-фильтрация

```bash
sudo bash naiveproxy.sh dns
sudo bash naiveproxy.sh dns-install
sudo bash naiveproxy.sh dns-update
sudo bash naiveproxy.sh dns-status
```

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
```

Запуск в foreground:

```bash
sudo bash naiveproxy.sh bot
```

Команды:

| Раздел | Команды |
|---|---|
| Информация | `/status`, `/stats`, `/diagnose`, `/logs`, `/cert`, `/xraystatus` |
| Пользователи | `/users`, `/adduser`, `/deluser`, `/qr` |
| Подписки | `/sub`, `/subreset` |
| Лимит устройств | `/devices`, `/lockuser`, `/unlockuser` |
| Xray | `/xray`, `/xraystatus` |
| Управление | `/restart`, `/update`, `/selfupdate`, `/diagfix`, `/privatepage` |
| Администраторы | `/admins`, `/addadmin`, `/deladmin` |

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

[NaiveProxy Manager v5.5.0: большой обзор скрипта](ARTICLE_RU.md)

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

Проект распространяется под лицензией [GPL-3.0](LICENSE).

Коммерческое использование без разрешения автора запрещено условиями проекта.

## Поддержка проекта

- Telegram: [@ivan_it_net](https://t.me/ivan_it_net)
- Сайт: [ivan-it.net](https://ivan-it.net)
- GitHub: [ivan-yurich/naiveproxy](https://github.com/ivan-yurich/naiveproxy)
- Донат: [DonationAlerts](https://www.donationalerts.com/r/ivan_yurievich)
