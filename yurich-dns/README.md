# DNS (Unbound)

DNS (Unbound) - production-ready установщик Unbound для Ubuntu 24.04 LTS. Он поднимает собственный DNS-резолвер для VPN-клиентов, чтобы DNS-запросы шли через ваш сервер и не превращали VPS в открытый публичный resolver.

## Что такое Unbound

Unbound - это быстрый рекурсивный DNS-резолвер с кэшем и DNSSEC validation. В этой конфигурации он:

- слушает `127.0.0.1:53` для самого сервера;
- опционально слушает VPN gateway IP, например `10.0.0.1:53`;
- не слушает `0.0.0.0`;
- разрешает запросы только от localhost и заданных VPN CIDR;
- не логирует все DNS-запросы по умолчанию;
- не использует Google DNS или Cloudflare DNS как upstream.

## Структура

```text
yurich-dns/
├── install-dns.sh
├── uninstall-dns.sh
├── configs/
│   └── unbound-yurich.conf
├── examples/
│   ├── sing-box-dns.json
│   ├── xray-dns.json
│   └── wireguard-client.conf
├── scripts/
│   ├── yurich-dns-status
│   ├── yurich-dns-test
│   └── yurich-dns-restart
└── README.md
```

## Установка

Запускать на сервере под root:

```bash
cd yurich-dns
sudo bash install-dns.sh
```

Скрипт спросит:

- VPN gateway IP, например `10.0.0.1`;
- VPN CIDR, например `10.0.0.0/24`.

Если IP `10.0.0.1` ещё не поднят на сервере, установщик предложит создать безопасный локальный gateway `10.0.0.1/32` на `lo` через `yurich-dns-gateway.service`. Это не открывает DNS наружу: Unbound всё равно слушает только localhost и разрешённые VPN CIDR.

Можно запускать без интерактива:

```bash
sudo YURICH_DNS_GATEWAY=10.0.0.1 YURICH_DNS_CIDRS=10.0.0.0/24 bash install-dns.sh
```

## Что делает installer

- проверяет root;
- выполняет `apt-get update`;
- устанавливает `unbound`, `unbound-anchor`, `dnsutils`, `dns-root-data`, `curl`, `ca-certificates`;
- проверяет порт `53`;
- если порт занят `systemd-resolved`, создаёт `/etc/systemd/resolved.conf.d/no-stub.conf` с `DNSStubListener=no`;
- не меняет `/etc/resolv.conf`;
- при необходимости создаёт локальный gateway IP через `yurich-dns-gateway.service`;
- пишет `/etc/unbound/unbound.conf.d/yurich-dns.conf`;
- делает backup старых файлов с датой;
- добавляет UFW allow только от VPN CIDR на `53/tcp` и `53/udp`;
- ставит команды `yurich-dns-status`, `yurich-dns-test`, `yurich-dns-restart`;
- запускает `unbound-checkconf`, `systemctl restart unbound`, `dig` и DNSSEC-тест.

## Проверка

```bash
yurich-dns-status
yurich-dns-test
```

Ручные проверки:

```bash
sudo unbound-checkconf /etc/unbound/unbound.conf.d/yurich-dns.conf
dig @127.0.0.1 google.com
dig @127.0.0.1 cloudflare.com
dig @127.0.0.1 sigok.verteiltesysteme.net A
dig @127.0.0.1 dnssec-failed.org A
```

Для `dnssec-failed.org` нормальный результат - `SERVFAIL`.

## Подключение к sing-box

Пример находится в `examples/sing-box-dns.json`.

Главная идея:

```json
{
  "dns": {
    "servers": [
      {
        "tag": "yurich-dns",
        "address": "tcp://10.0.0.1:53",
        "detour": "direct"
      }
    ],
    "final": "yurich-dns",
    "strategy": "ipv4_only"
  }
}
```

Для защиты от DNS leak DNS-запросы должны идти на `10.0.0.1` внутри VPN, а не на публичные DNS.

## Подключение к Xray

Пример находится в `examples/xray-dns.json`.

```json
{
  "dns": {
    "queryStrategy": "UseIPv4",
    "servers": ["10.0.0.1"]
  }
}
```

Если у вас сложный routing, добавьте правило для `port: 53`, чтобы DNS шёл через локальный/direct путь внутри туннеля.

## Подключение к WireGuard / Amnezia

В клиентский конфиг добавьте:

```ini
DNS = 10.0.0.1
```

Пример находится в `examples/wireguard-client.conf`.

## Как не сделать open DNS resolver

Важные правила:

- не добавляйте `interface: 0.0.0.0`;
- не добавляйте `access-control: 0.0.0.0/0 allow`;
- не открывайте UFW порт `53` для всего мира;
- используйте только реальный VPN CIDR, например `10.0.0.0/24`, и не используйте сети с маской `/0`;
- проверяйте:

```bash
sudo ss -lntup | grep ':53'
sudo ufw status numbered
```

Снаружи интернет не должен иметь доступ к вашему DNS.

## Удаление

```bash
sudo bash uninstall-dns.sh
```

Скрипт:

- остановит и отключит `unbound`;
- удалит `/etc/unbound/unbound.conf.d/yurich-dns.conf`;
- удалит команды `yurich-dns-*`;
- удалит UFW rules для сохранённых VPN CIDR;
- удалит `no-stub.conf`, если он был создан;
- не удалит системные пакеты без подтверждения;
- не тронет VPN-конфиги.

## Диагностика проблем

Если Unbound не стартует:

```bash
sudo unbound-checkconf /etc/unbound/unbound.conf.d/yurich-dns.conf
sudo journalctl -u unbound -n 80 --no-pager
sudo ss -lntup | grep ':53'
```

Частые причины:

- порт `53` занят другим DNS-сервисом;
- `yurich-dns-gateway.service` не поднял локальный gateway IP;
- указана слишком широкая подсеть с маской `/0`;
- в конфиг вручную добавили повторный `auto-trust-anchor-file`.

На Ubuntu trust anchor уже управляется пакетом Unbound, поэтому DNS (Unbound) не дублирует `auto-trust-anchor-file`.
