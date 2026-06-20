# Yurich Panel 5.6.49: что изменилось и что проверять перед публикацией

Этот документ подготовлен для проверки перед публикацией в репозиторий
`ivan-yurich/naiveproxy`.

Цель версии 5.6.49 — привести скрипт к более стабильному production-состоянию:
улучшить мультисерверную работу, подписки, проверку протоколов, Telegram-ботов,
безопасность серверов и подготовить публичную GitHub-версию без личных данных.

## Главное

- Основной скрипт: `yurich-panel.sh`.
- Совместимый alias: `naiveproxy.sh`.
- Версия: `5.6.49`.
- SHA256 обоих скриптов совпадает.
- Публичные дефолтные контакты заменены на placeholders.
- Подготовлены `.gitignore`, `.gitattributes`, `SECURITY.md`.
- Проверка `bash -n` проходит для основного скрипта и DNS-модуля.

## Что исправлено в стабильности

### Protocol benchmark

Раньше мониторинг мог отправлять ложный `SLOW` после одного случайного медленного
TCP/TLS handshake.

Теперь:

- `protocol-benchmark` показывает `BEST`, `AVG`, `MEDIAN`, `P95`, `WORST`;
- добавлен счетчик `slow=N/R`;
- `protocol-benchmark-monitor` делает минимум 3 раунда;
- `SLOW` считается проблемой только если медленных попыток минимум 2 из 3;
- CSV-история получила поля `median_ms`, `p95_ms`, `slow_count`;
- старый CSV автоматически ротируется при несовместимом заголовке.

Команды:

```bash
sudo bash yurich-panel.sh protocol-benchmark USER 3
sudo bash yurich-panel.sh protocol-benchmark-monitor USER 3
sudo bash yurich-panel.sh protocol-benchmark-history 30
```

### Проверка подписок

Усилена практика проверки подписок после изменений:

- `protocol-validate` проверяет наличие и формат файлов подписки;
- `protocol-benchmark` проверяет реальные профили через curl/Xray/Hysteria;
- для GitHub-документации добавлен акцент на `links.txt`, `hiddify.txt`,
  `streisand.txt`, `nekobox.txt`, `v2rayng.txt`.

Команды:

```bash
sudo bash yurich-panel.sh protocol-validate
sudo bash yurich-panel.sh nodes-subscriptions
sudo bash yurich-panel.sh subscription USER
```

## Что сделано по протоколам

В публичной документации закреплена текущая практическая модель профилей:

- HTTPS = Yurich Proxy / Naive-compatible transport;
- Turbo = Hysteria 2;
- Reality = VLESS Reality TCP.

Для production-проверки рекомендуется:

- не судить о скорости по одному замеру;
- сравнивать TCP-профили отдельно от UDP/QUIC;
- смотреть median/P95, а не только avg;
- проверять конкретного пользователя после пересборки подписок.

## Что сделано по мультисерверу

Мультисерверная схема стала центральной частью документации.

Поддерживаемый workflow:

```bash
sudo bash yurich-panel.sh nodes-add
sudo bash yurich-panel.sh nodes-test all
sudo bash yurich-panel.sh nodes-deploy NODE
sudo bash yurich-panel.sh nodes-sync NODE
sudo bash yurich-panel.sh nodes-subscriptions
sudo bash yurich-panel.sh protocol-validate
```

Что улучшено в документации:

- добавлен безопасный rollout-порядок;
- описано отличие master и node;
- описано, что удаление node из реестра требует пересборки подписок;
- добавлен чеклист проверки перед выдачей клиентам;
- добавлена диагностика частых ошибок SSH, TLS, Xray, Hysteria и DNS;
- объяснено, что `nodes` не является DNS-балансировщиком, а добавляет профили
  в подписку.

## Что сделано по HAProxy/SNI

В документации добавлен production-подход:

- Caddy может работать за HAProxy SNI mux;
- VLESS Reality может оставаться на TCP/443;
- Caddy/Naive обслуживает обычный TLS-домен;
- HAProxy stats/logs используются для диагностики направлений трафика.

Команды:

```bash
sudo bash yurich-panel.sh haproxy-status
sudo bash yurich-panel.sh haproxy-logs
sudo bash yurich-panel.sh haproxy-tg
```

## Что сделано по Telegram-ботам

В 5.6.x добавлены и описаны два сценария:

- административный бот для управления сервером;
- sales bot для ручной продажи VPN-подписок с тарифами и подтверждением оплаты.

Перед публикацией из публичного кода убраны реальные бот-ссылки и реальные
каналы. Дефолты теперь placeholders, а production-значения должны задаваться
через конфиг или переменные окружения.

Публичные дефолты:

```bash
YURICH_TELEGRAM_COMMUNITY_URL=https://t.me/your_channel
YURICH_TELEGRAM_BOT_URL=https://t.me/your_notification_bot
YURICH_SUPPORT_EMAIL=support@example.com
YURICH_SALES_BOT_CHANNEL_URL=https://t.me/your_channel
```

## Что сделано по безопасности

### Подготовка к GitHub

Для публичного репозитория добавлены:

- `.gitignore` для секретов, ключей, токенов, state-файлов и generated output;
- `.gitattributes` для LF-переносов в shell-файлах;
- `SECURITY.md` с правилами, что нельзя публиковать в issues.

### Серверная безопасность

В документации закреплен baseline:

- SSH key-only;
- root login disabled;
- UFW deny-by-default;
- Fail2Ban или CrowdSec;
- unattended security updates;
- backup перед изменениями;
- проверка `health`, `security-audit`, `nodes-test`.

## Что добавлено в документацию

- `RELEASE_NOTES_RU.md` — этот файл.
- `SECURITY.md` — правила безопасности для GitHub.
- Расширен `MULTISERVER_GUIDE_RU.md`.
- README обновлен под 5.6.49 и безопасные публичные дефолты.

## Проверка перед публикацией

Минимальный чеклист:

```bash
rg -n -i "TOKEN|PRIVATE KEY|BEGIN OPENSSH|real-domain.example" .
bash -n yurich-panel.sh
bash -n naiveproxy.sh
bash -n yurich-dns/install-dns.sh
bash -n yurich-dns/uninstall-dns.sh
sha256sum yurich-panel.sh naiveproxy.sh
cat yurich-panel.sh.sha256
cat naiveproxy.sh.sha256
```

После публикации:

```bash
curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/yurich-panel.sh -o /tmp/yurich-panel.sh
bash -n /tmp/yurich-panel.sh
bash /tmp/yurich-panel.sh version
```

## Что важно проверить вручную

- Что README не обещает то, что не включено в community-версию.
- Что коммерческая лицензия и контакты оформлены корректно.
- Что ссылки на Android/Windows приложения должны оставаться публичными.
- Что реальные production-домены и Telegram-боты задаются только в конфиге
  установленного сервера, а не в GitHub-коде.

## Статус подготовки

Готово к ручной проверке владельцем проекта.

Публикацию в GitHub нужно делать отдельным шагом после подтверждения.
