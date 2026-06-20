# HAProxy в Yurich Panel: расширенная статья по TCP/SNI routing

> В документе используются только демонстрационные значения:
> `vpn.example.com`, `reality-target.example`, `127.0.0.1:8443`,
> `127.0.0.1:1443`. Перед применением замени их на свои значения.

## Зачем HAProxy нужен в VPN-инфраструктуре

HAProxy в Yurich Panel используется как TCP/SNI-router на публичном порту
`443/tcp`. Он принимает входящее TLS-соединение, не расшифровывает его, читает
только SNI из ClientHello и отправляет поток в нужный локальный backend.

Это полезно, когда на одном сервере нужно держать несколько TCP-профилей:

- HTTPS-профиль Yurich Proxy / Naive-compatible transport;
- VLESS Reality TCP;
- fallback-сценарии Xray;
- будущие TCP-профили, которым нужен общий порт `443`.

HAProxy не заменяет Caddy, Xray или Hysteria2. Он стоит перед ними и аккуратно
разводит TCP-трафик.

## Главная схема

```text
Internet
  |
  | 443/tcp
  v
HAProxy
  |
  |-- SNI = vpn.example.com        -> Caddy / Yurich Proxy
  |
  |-- SNI = reality-target.example -> Xray / VLESS Reality
```

Рекомендуемая модель:

```text
Public ports:
  80/tcp   -> Caddy HTTP/ACME
  443/tcp  -> HAProxy TCP/SNI router
  UDP port -> Hysteria2, если включён

Local-only ports:
  127.0.0.1:8443 -> Caddy HTTPS/Yurich Proxy
  127.0.0.1:1443 -> Xray Reality TCP
```

Важно: HAProxy работает только с TCP. Hysteria2 использует UDP/QUIC, поэтому
через обычный TCP HAProxy его прокидывать не нужно.

## Что HAProxy делает и чего не делает

HAProxy делает:

- принимает TCP-соединения на `443`;
- читает SNI из TLS ClientHello;
- маршрутизирует поток в Caddy или Xray;
- пишет логи по frontend/backend;
- даёт stats endpoint для мониторинга;
- помогает держать несколько TCP-профилей на одном публичном порту.

HAProxy не делает:

- не расшифровывает TLS;
- не выпускает TLS-сертификаты;
- не заменяет Caddy;
- не маршрутизирует UDP/Hysteria2;
- не чинит неправильный SNI в клиенте;
- не должен быть публичным open proxy.

## Когда HAProxy нужен

HAProxy имеет смысл включать, если:

- нужно держать Yurich Proxy и VLESS Reality на одном `443/tcp`;
- есть несколько TCP backend-сервисов;
- требуется аккуратное логирование маршрутизации;
- нужно видеть, сколько трафика идёт в Caddy, а сколько в Xray;
- планируется расширять сервер до edge-узла с несколькими TCP-профилями.

HAProxy можно не использовать, если:

- на сервере работает только Yurich Proxy / NaiveProxy;
- VLESS Reality слушает отдельный порт и это устраивает;
- нет задачи объединять TCP-профили под одним endpoint;
- администратор не готов поддерживать дополнительный слой маршрутизации.

## Базовая установка

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y haproxy
sudo systemctl enable haproxy
```

Проверка версии:

```bash
haproxy -v
```

Проверка сервиса:

```bash
sudo systemctl status haproxy --no-pager
```

## Подготовка backend-сервисов

Перед включением HAProxy backend-сервисы должны слушать локальные порты.

Пример:

```text
Caddy:
  127.0.0.1:8443

Xray Reality:
  127.0.0.1:1443

HAProxy:
  0.0.0.0:443
```

Такой вариант безопаснее, чем открывать Caddy/Xray напрямую наружу.

Проверка локальных портов:

```bash
sudo ss -ltnp | grep -E ':(443|8443|1443)\b'
```

Ожидаемая логика:

- `443` слушает HAProxy;
- `8443` слушает Caddy только на `127.0.0.1`;
- `1443` слушает Xray только на `127.0.0.1`.

## Пример production-конфига HAProxy

Файл:

```bash
/etc/haproxy/haproxy.cfg
```

Пример:

```haproxy
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 50000

defaults
    log global
    mode tcp
    option tcplog
    option dontlognull
    option clitcpka
    option srvtcpka
    timeout connect 5s
    timeout client 30m
    timeout server 30m
    timeout client-fin 30s
    timeout server-fin 30s

frontend fe_tls_443
    bind *:443
    mode tcp

    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    tcp-request content capture req.ssl_sni len 128

    acl sni_yurich_proxy req.ssl_sni -i vpn.example.com
    acl sni_reality req.ssl_sni -i reality-target.example

    use_backend be_xray_reality if sni_reality
    use_backend be_caddy_yurich_proxy if sni_yurich_proxy

    default_backend be_caddy_yurich_proxy

backend be_caddy_yurich_proxy
    mode tcp
    option tcp-check
    server caddy_local 127.0.0.1:8443 check inter 5s fall 3 rise 2

backend be_xray_reality
    mode tcp
    option tcp-check
    server xray_reality_local 127.0.0.1:1443 check inter 5s fall 3 rise 2

listen stats_local
    bind 127.0.0.1:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats show-legends
```

## Проверка конфига

Перед перезапуском:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```

Если конфиг валидный:

```bash
sudo systemctl reload haproxy
```

Если reload не сработал:

```bash
sudo systemctl restart haproxy
```

Проверка:

```bash
sudo systemctl status haproxy --no-pager
sudo journalctl -u haproxy -n 100 --no-pager
```

## Проверка маршрутизации SNI

Проверить Caddy/Yurich Proxy backend:

```bash
openssl s_client -connect vpn.example.com:443 -servername vpn.example.com </dev/null
```

Проверить Reality SNI routing:

```bash
openssl s_client -connect vpn.example.com:443 -servername reality-target.example </dev/null
```

Важно: `openssl s_client` проверяет TLS routing, но не гарантирует полную
работу VLESS Reality. Для Reality нужна проверка реальным клиентским профилем.

## Проверка через Yurich Panel

После изменения HAProxy полезно запускать:

```bash
sudo bash yurich-panel.sh health
sudo bash yurich-panel.sh protocol-validate
sudo bash yurich-panel.sh protocol-benchmark USER 3
```

Что проверять:

- Caddy активен;
- Xray активен;
- HAProxy слушает `443`;
- подписки генерируются без битых ссылок;
- клиентские профили реально подключаются;
- задержки не выросли после добавления HAProxy.

## HAProxy stats

Stats лучше держать только на `127.0.0.1`.

Локальная проверка:

```bash
curl http://127.0.0.1:8404/stats
```

Через SSH tunnel:

```bash
ssh -L 8404:127.0.0.1:8404 root@server.example
```

После этого открыть:

```text
http://127.0.0.1:8404/stats
```

Не рекомендуется открывать stats наружу без авторизации, firewall и отдельного
доступа только для администратора.

## Логирование SNI

Для диагностики полезно видеть, куда попал трафик: в Caddy или Xray.

Можно использовать capture SNI:

```haproxy
tcp-request content capture req.ssl_sni len 128
```

И расширенный log-format:

```haproxy
log-format "src=%ci:%cp fe=%ft be=%b srv=%s sni=%[capture.req.hdr(0)] bytes=%B time=%Tt"
```

После изменения:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl reload haproxy
```

Логи:

```bash
sudo journalctl -u haproxy -n 100 --no-pager
```

Если используется rsyslog, HAProxy-логи могут быть в:

```bash
/var/log/haproxy.log
/var/log/syslog
```

## Firewall

Снаружи должны быть открыты только нужные публичные порты:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Если включён Hysteria2:

```bash
sudo ufw allow <hysteria-udp-port>/udp
```

Локальные backend-порты не должны быть доступны извне:

```bash
127.0.0.1:8443
127.0.0.1:1443
```

Проверка:

```bash
sudo ufw status verbose
sudo ss -ltnup
```

## Важные настройки для стабильности

### TCP keepalive

В `defaults`:

```haproxy
option clitcpka
option srvtcpka
```

Это помогает удерживать соединения за NAT, на домашнем Wi-Fi и мобильных сетях.

### Длинные timeout

Для VPN-профилей короткие timeout вредят:

```haproxy
timeout client 30m
timeout server 30m
```

Слишком маленькие значения могут давать случайные обрывы.

### Default backend

Лучше отправлять неизвестный SNI в Caddy:

```haproxy
default_backend be_caddy_yurich_proxy
```

Так сервер выглядит естественнее и не отдаёт лишних признаков внутренней схемы.

## Типовые ошибки

### На 443 слушает Caddy, а не HAProxy

Симптом:

```bash
sudo ss -ltnp | grep ':443'
```

Показывает Caddy на `0.0.0.0:443`.

Исправление:

- перевести Caddy на локальный `127.0.0.1:8443`;
- поставить HAProxy на `0.0.0.0:443`;
- проверить Caddyfile;
- перезапустить сервисы в правильном порядке.

### Reality уходит в Caddy

Симптом:

- VLESS Reality не подключается;
- Naive/Yurich Proxy работает;
- в логах HAProxy трафик Reality попадает в `be_caddy_yurich_proxy`.

Причины:

- клиент отправляет неправильный SNI;
- в HAProxy указан другой target;
- приложение переписывает SNI на домен сервера;
- Reality target в Xray не совпадает с клиентским профилем.

Что проверить:

```bash
sudo journalctl -u haproxy -n 100 --no-pager
sudo bash yurich-panel.sh protocol-validate
sudo bash yurich-panel.sh protocol-benchmark USER 3
```

### HAProxy не стартует

Проверить конфиг:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```

Проверить занятый порт:

```bash
sudo ss -ltnp | grep ':443'
```

Проверить лог:

```bash
sudo journalctl -u haproxy -n 100 --no-pager
```

### Hysteria2 не проходит через HAProxy

Это нормальное поведение, если используется обычный HAProxy TCP frontend.
Hysteria2 работает поверх UDP/QUIC. Для него нужен отдельный UDP-порт или
отдельная UDP-balancing архитектура.

## Порядок безопасного внедрения

1. Сделать backup конфигов:

```bash
sudo bash yurich-panel.sh backup
```

2. Проверить текущую систему:

```bash
sudo bash yurich-panel.sh health
sudo ss -ltnup
```

3. Перевести Caddy/Xray на локальные backend-порты.

4. Подготовить `/etc/haproxy/haproxy.cfg`.

5. Проверить:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```

6. Перезапустить сервисы:

```bash
sudo systemctl reload haproxy || sudo systemctl restart haproxy
sudo systemctl restart caddy
sudo systemctl restart xray
```

7. Проверить порты:

```bash
sudo ss -ltnup
```

8. Проверить подписки и реальные профили:

```bash
sudo bash yurich-panel.sh protocol-validate
sudo bash yurich-panel.sh protocol-benchmark USER 3
```

9. Проверить приложение на Wi-Fi и мобильной сети.

10. Только после этого считать внедрение завершённым.

## Rollback

Если после включения HAProxy что-то пошло не так:

1. Остановить HAProxy:

```bash
sudo systemctl stop haproxy
```

2. Вернуть Caddy на публичный `443/tcp`.

3. Проверить Caddyfile:

```bash
sudo caddy validate --config /etc/caddy/Caddyfile
```

4. Перезапустить Caddy:

```bash
sudo systemctl restart caddy
```

5. Проверить:

```bash
sudo ss -ltnp | grep ':443'
sudo bash yurich-panel.sh health
```

## Security checklist

Перед production-использованием:

- HAProxy stats слушает только `127.0.0.1`;
- backend-порты Caddy/Xray слушают только `127.0.0.1`;
- наружу открыт только `80/tcp`, `443/tcp` и нужный UDP-порт Hysteria2;
- root SSH закрыт или ограничен;
- SSH key-only включён;
- Fail2Ban или CrowdSec активен;
- логи не содержат токены, пароли и subscription URL;
- перед правками есть backup;
- после правок выполнены `health`, `protocol-validate`, `protocol-benchmark`.

## HAProxy и мультисерверная схема

В мультисерверной архитектуре HAProxy обычно ставится на каждой node отдельно.

```text
Master:
  - хранит пользователей;
  - синхронизирует node;
  - пересобирает подписки.

Node:
  - принимает пользовательский трафик;
  - держит HAProxy на 443;
  - маршрутизирует TCP в Caddy/Xray;
  - отдельно обслуживает Hysteria2 UDP.
```

HAProxy на master не должен пытаться прокидывать весь пользовательский трафик на
другие node без отдельной overlay-сети и продуманной балансировки. Для обычной
мультисерверной схемы лучше выдавать пользователю несколько локаций в подписке.

## HAProxy и будущий Auto Profile

Для будущего Auto Profile HAProxy можно использовать как TCP edge:

```text
auto.example.com:443
  |
  v
HAProxy edge
  |
  |-- node-1 TCP backend
  |-- node-2 TCP backend
  |-- node-3 TCP backend
```

Но для этого нужна отдельная архитектура:

- приватная overlay-сеть между edge и node;
- health checks;
- sticky или deterministic routing;
- защита от loops;
- отдельный дизайн для UDP/Hysteria2;
- понятный fallback, если node недоступна.

Для текущей публичной версии Yurich Panel безопаснее использовать HAProxy как
локальный TCP/SNI-router на каждой node, а не как глобальный балансировщик.

## Итог

HAProxy в Yurich Panel нужен не для усложнения, а для аккуратного объединения
нескольких TCP-профилей под одним публичным `443/tcp`.

Практическая production-модель:

```text
443/tcp -> HAProxy
          -> Caddy / Yurich Proxy
          -> Xray / VLESS Reality

UDP     -> Hysteria2 отдельно
```

Такой подход даёт:

- единый публичный TCP endpoint;
- чистое разделение backend-сервисов;
- возможность держать Yurich Proxy и Reality на одном порту;
- понятную диагностику через логи и stats;
- безопасное развитие будущих TCP-профилей.

Главное правило: сначала backup и проверка конфигов, потом включение HAProxy,
после этого `health`, `protocol-validate` и реальный тест клиентских профилей.
