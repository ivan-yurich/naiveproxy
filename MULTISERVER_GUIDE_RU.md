# Yurich Panel: мультисерверная схема

Полная инструкция по подключению дополнительных VPS к одной панели Yurich Panel: как подготовить master-сервер, как добавить node-сервера, как синхронизировать пользователей, как пересобрать страницы подписки и как безопасно проверить, что всё работает.

В примерах используются только тестовые домены и IP. Замени их на свои:

- `panel.example.com` — основной сервер, где ты управляешь пользователями;
- `fi-1.example.com` — дополнительный сервер в другой локации;
- `de-1.example.com` — ещё один дополнительный сервер;
- `203.0.113.10`, `203.0.113.20`, `203.0.113.30` — примерные IP из документационного диапазона.

## Что такое master и node

В мультисерверной схеме один VPS становится центральной точкой управления.

**Master** — основной сервер:

- хранит пользователей;
- создаёт личные страницы подписки;
- хранит список дополнительных серверов в `/etc/naiveproxy/nodes.conf`;
- проверяет node-сервера по SSH;
- отправляет на них актуальный `yurich-panel.sh`;
- синхронизирует пользователей;
- добавляет ссылки node-серверов в `links.txt` и на страницу подписки.

**Node** — дополнительный сервер:

- имеет свой домен и свой TLS;
- обслуживает тот же набор пользователей после синхронизации;
- может быть отдельной локацией: Finland, Germany, Netherlands, USA и так далее;
- может работать как обычный edge-сервер, backup-сервер или часть будущей bridge-схемы.

Главная идея: пользователь получает одну личную страницу подписки, а внутри видит несколько профилей. Например:

- `Yurich Proxy panel`;
- `Yurich Proxy fi-1`;
- `Yurich Proxy de-1`;
- `Finland Hysteria2`;
- `Germany VLESS REALITY`.

## Архитектура

```mermaid
flowchart LR
    A["Администратор"] --> B["Master VPS: panel.example.com"]
    B --> C["/etc/naiveproxy/users.conf"]
    B --> D["/etc/naiveproxy/nodes.conf"]
    B --> E["Страницы подписки /s/<token>/"]
    B -- SSH deploy/sync --> F["Node 1: fi-1.example.com"]
    B -- SSH deploy/sync --> G["Node 2: de-1.example.com"]
    E --> H["Клиентское приложение"]
    F --> H
    G --> H
```

Что важно понимать:

- Yurich Panel не делает магический балансировщик на уровне DNS сам по себе.
- Node-ссылки добавляются в подписку, а клиент уже выбирает нужный профиль.
- Для настоящего “моста” вида `мобилка -> первый VPS -> второй VPS` нужен Xray/sing-box outbound на первом VPS. Caddy/Yurich Proxy сам по себе не является chain-router.

## Что умеет меню 29

В SSH-панели пункт:

```text
29) [NODES] Multi-server management
```

Внутри:

```text
1) Список серверов
2) Добавить / изменить сервер
3) Проверить SSH/status
4) Установить / обновить скрипт на node
5) Синхронизировать пользователей на node
6) Пересобрать подписки с node-ссылками
7) Удалить сервер из реестра
0) Назад
```

CLI-команды:

```bash
sudo bash yurich-panel.sh nodes
sudo bash yurich-panel.sh nodes-list
sudo bash yurich-panel.sh nodes-add
sudo bash yurich-panel.sh nodes-test all
sudo bash yurich-panel.sh nodes-test fi-1
sudo bash yurich-panel.sh nodes-deploy fi-1
sudo bash yurich-panel.sh nodes-sync all
sudo bash yurich-panel.sh nodes-sync fi-1
sudo bash yurich-panel.sh nodes-subscriptions
sudo bash yurich-panel.sh nodes-remove fi-1
```

## Требования

На master:

- установлен Yurich Panel;
- есть хотя бы один пользователь;
- есть рабочий домен и TLS;
- есть SSH-доступ к node-серверам по ключу;
- если SSH-пользователь не `root`, у него должен быть `sudo -n`, то есть sudo без пароля для команд панели.

На каждой node:

- Ubuntu/Debian VPS;
- отдельный домен, указывающий на IP node;
- открыты нужные порты: `80/tcp`, `443/tcp`, `443/udp`, дополнительные порты Hysteria/Xray при необходимости;
- установлен или готов к установке Yurich Panel;
- SSH key login с master.

Минимальный набор DNS:

```text
panel.example.com  A  203.0.113.10
fi-1.example.com   A  203.0.113.20
de-1.example.com   A  203.0.113.30
```

## Нужно ли ставить панель на node вручную

Есть два рабочих варианта.

### Вариант A: проще и надёжнее

Сначала ставишь Yurich Panel на каждую node как обычный отдельный сервер:

```bash
sudo bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/yurich-panel.sh)'
```

На каждой node указываешь свой домен:

```text
fi-1.example.com
de-1.example.com
```

После установки возвращаешься на master и добавляешь эти сервера в меню 29.

Этот вариант удобен тем, что Caddy, TLS, UFW и systemd уже настроены локально на каждой node.

### Вариант B: через master

На master добавляешь node в меню 29, потом выбираешь:

```text
4) Установить / обновить скрипт на node
```

Скрипт отправит текущий `yurich-panel.sh` на node в:

```text
/usr/local/bin/yurich-panel.sh
/usr/local/bin/naiveproxy.sh
```

После этого можно согласиться на интерактивную установку на node прямо из SSH-сессии.

Этот вариант удобен, когда у тебя уже есть SSH key login с master на node.

## Подготовка SSH между master и node

На master проверь, что есть SSH-ключ:

```bash
ls -la ~/.ssh
```

Если ключа нет, создай:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/yurich_nodes -N "" -C "yurich-nodes"
```

Добавь публичный ключ на node:

```bash
ssh-copy-id -i ~/.ssh/yurich_nodes.pub root@203.0.113.20
```

Проверь вход без пароля:

```bash
ssh -i ~/.ssh/yurich_nodes root@203.0.113.20
```

Если используешь не `root`, например `admin`, проверь sudo без пароля:

```bash
ssh admin@203.0.113.20 'sudo -n true && echo OK'
```

Если команда просит пароль, синхронизация из панели не сможет работать автоматически. На node нужно настроить NOPASSWD для этого пользователя.

Пример `/etc/sudoers.d/yurich-panel`:

```text
admin ALL=(ALL) NOPASSWD:ALL
```

Права:

```bash
sudo chmod 440 /etc/sudoers.d/yurich-panel
sudo visudo -cf /etc/sudoers.d/yurich-panel
```

## Добавление node через меню

На master:

```bash
sudo bash yurich-panel.sh
```

Выбираешь:

```text
29) [NODES] Multi-server management
2) Добавить / изменить сервер
```

Пример заполнения:

```text
Node name [eu-1]: fi-1
SSH host/IP: 203.0.113.20
SSH port [22]: 22
SSH user [root]: root
Публичный домен node для ссылок: fi-1.example.com
Role [edge/bridge/exit/backup, Enter=edge]: edge
Weight [100]: 100
Включить node в подписки? [Y/n]: y
```

Второй сервер:

```text
Node name [eu-1]: de-1
SSH host/IP: 203.0.113.30
SSH port [22]: 22
SSH user [root]: root
Публичный домен node для ссылок: de-1.example.com
Role [edge/bridge/exit/backup, Enter=edge]: edge
Weight [100]: 100
Включить node в подписки? [Y/n]: y
```

Реестр хранится на master:

```text
/etc/naiveproxy/nodes.conf
```

Формат:

```text
name|host|ssh_port|ssh_user|domain|role|weight|enabled
```

Пример:

```text
fi-1|203.0.113.20|22|root|fi-1.example.com|edge|100|1
de-1|203.0.113.30|22|root|de-1.example.com|edge|100|1
```

Файл должен быть root-only:

```bash
sudo chmod 600 /etc/naiveproxy/nodes.conf
```

## Проверка node

Через меню:

```text
3) Проверить SSH/status
```

Или CLI:

```bash
sudo bash yurich-panel.sh nodes-test all
sudo bash yurich-panel.sh nodes-test fi-1
```

Панель проверяет:

- SSH-доступ;
- hostname;
- uptime;
- статус `caddy`;
- статус `xray`;
- статус `hysteria`;
- статус `unbound`;
- открытые порты `443`, `8443`, `8444`, `8446`, `8448`.

Если проверка падает:

```bash
ssh root@203.0.113.20 'hostname && uptime'
```

Если ручной SSH тоже не работает, сначала исправляй SSH, а потом возвращайся к панели.

## Установка или обновление скрипта на node

Через меню:

```text
4) Установить / обновить скрипт на node
```

Или CLI:

```bash
sudo bash yurich-panel.sh nodes-deploy fi-1
```

Что происходит:

- master берёт текущий локальный `yurich-panel.sh`;
- отправляет его на node во временный файл;
- устанавливает на node:

```text
/usr/local/bin/yurich-panel.sh
/usr/local/bin/naiveproxy.sh
```

- запускает на node:

```bash
sudo bash /usr/local/bin/yurich-panel.sh version
```

Если выбрать интерактивную установку, откроется установка Yurich Panel на node. Вводи домен именно node-сервера, например:

```text
fi-1.example.com
```

## Синхронизация пользователей

После добавления пользователя на master нужно отправить его на node.

Через меню:

```text
5) Синхронизировать пользователей на node
```

Или CLI:

```bash
sudo bash yurich-panel.sh nodes-sync all
sudo bash yurich-panel.sh nodes-sync fi-1
```

Синхронизируются:

```text
/etc/naiveproxy/users.conf
/etc/naiveproxy/users.disabled
/etc/naiveproxy/users.d/
/etc/naiveproxy/subscriptions/
/etc/naiveproxy/xray-users.conf
/etc/naiveproxy/xray-users.disabled
```

На node перед распаковкой создаётся backup:

```text
/etc/naiveproxy/backups/node-sync-before-YYYYMMDD_HHMMSS.tar.gz
```

После распаковки node выполняет:

```bash
sudo bash /usr/local/bin/yurich-panel.sh safe-apply
sudo bash /usr/local/bin/yurich-panel.sh hysteria-sync
sudo bash /usr/local/bin/yurich-panel.sh xray-rebuild
sudo bash /usr/local/bin/yurich-panel.sh nodes-subscriptions
```

Это важно: Caddy/Xray/Hysteria пересобираются уже на стороне node, с её доменом и локальными сертификатами.

## Пересборка подписок

После добавления node и синхронизации пользователей на master выполни:

```bash
sudo bash yurich-panel.sh nodes-subscriptions
```

Или пункт меню:

```text
6) Пересобрать подписки с node-ссылками
```

После этого личная страница пользователя на master получает дополнительные ссылки.

Пример `links.txt`:

```text
naive+https://user:password@panel.example.com:443#Yurich%20Proxy%20panel
naive+https://user:password@fi-1.example.com:443#Yurich%20Proxy%20fi-1
naive+https://user:password@de-1.example.com:443#Yurich%20Proxy%20de-1
hy2://...
vless://...
```

Если на node включены Hysteria или Xray, master также пытается подтянуть с node дополнительные `hy2://`, `vless://`, `trojan://` ссылки из node-подписки пользователя.

## Как выглядит пользовательская схема

Для пользователя это выглядит просто:

1. Он открывает свою страницу подписки на master.
2. Копирует URL подписки или скачивает `links.txt`.
3. В приложении видит несколько профилей.
4. Выбирает нужную локацию вручную.

Пример названий профилей:

```text
Yurich Proxy panel
Yurich Proxy fi-1
Yurich Proxy de-1
Finland Hysteria2
Germany VLESS REALITY
```

## Роли node

Сейчас роли больше организационные, чем автоматический балансировщик.

`edge`:

- обычная рабочая node;
- добавляется в подписки;
- принимает пользователей напрямую.

`backup`:

- резервная node;
- можно держать включённой или выключить через `enabled=0`;
- удобно для аварийной замены.

`bridge`:

- сервер, который может участвовать в цепочке;
- для реального bridge нужен Xray/sing-box outbound.

`exit`:

- выходной сервер во второй локации;
- обычно используется как второй VPS в схеме chaining.

## Weight

Поле `weight` уже хранится в реестре, но сейчас не делает автоматическое распределение трафика на уровне панели.

Зачем оно нужно:

- заранее хранить приоритеты серверов;
- использовать в будущем для генерации подписки с сортировкой;
- отделять основной сервер от резервного.

Пример логики:

```text
panel  weight 200
fi-1   weight 100
de-1   weight 100
backup weight 10
```

## Как временно убрать node из подписок

Открой меню:

```bash
sudo bash yurich-panel.sh nodes
```

Выбери:

```text
2) Добавить / изменить сервер
```

Введи то же имя node, но на вопрос:

```text
Включить node в подписки? [Y/n]: n
```

Потом пересобери подписки:

```bash
sudo bash yurich-panel.sh nodes-subscriptions
```

Node останется в реестре, но новые страницы подписки не будут показывать её ссылки.

## Как удалить node из реестра

Через меню:

```text
7) Удалить сервер из реестра
```

Или CLI:

```bash
sudo bash yurich-panel.sh nodes-remove fi-1
sudo bash yurich-panel.sh nodes-subscriptions
```

Это удаляет node только из master-реестра. Сам сервер не удаляется и сервисы на нём не останавливаются.

## Порядок добавления нового сервера

Короткий production-план:

1. Купить VPS.
2. Создать DNS A-запись для node.
3. Проверить DNS:

```bash
dig +short fi-1.example.com
```

4. Настроить SSH key login с master на node.
5. Установить Yurich Panel на node.
6. На node проверить:

```bash
sudo bash yurich-panel.sh status
sudo bash yurich-panel.sh diagnose
```

7. На master добавить node:

```bash
sudo bash yurich-panel.sh nodes-add
```

8. Проверить node:

```bash
sudo bash yurich-panel.sh nodes-test fi-1
```

9. Синхронизировать пользователей:

```bash
sudo bash yurich-panel.sh nodes-sync fi-1
```

10. Пересобрать подписки:

```bash
sudo bash yurich-panel.sh nodes-subscriptions
```

11. Открыть страницу пользователя и проверить, что появились ссылки node.

## Что делать при ошибках

### SSH/status failed

Проверь вручную:

```bash
ssh -p 22 root@203.0.113.20 'hostname && uptime'
```

Если используешь не root:

```bash
ssh -p 22 admin@203.0.113.20 'sudo -n true && echo sudo-ok'
```

Если `sudo -n` просит пароль, настрой NOPASSWD.

### Node добавлена, но ссылки не появились

Проверь:

```bash
sudo cat /etc/naiveproxy/nodes.conf
sudo bash yurich-panel.sh nodes-list
sudo bash yurich-panel.sh nodes-subscriptions
```

У node должен быть `enabled=1` и валидный публичный домен.

### Пользователь не работает на node

На master:

```bash
sudo bash yurich-panel.sh nodes-sync fi-1
```

На node:

```bash
sudo bash yurich-panel.sh safe-apply
sudo systemctl status caddy --no-pager
sudo tail -n 50 /var/log/caddy/naive.log
```

### TLS на node не выпустился

Проверь DNS:

```bash
dig +short fi-1.example.com
curl -4 ifconfig.me
```

IP домена должен совпадать с IP node.

Проверь порты:

```bash
sudo ss -tulpn | grep -E ':80|:443'
sudo ufw status numbered
```

### Xray/Hysteria ссылки не подтянулись с node

На node проверь:

```bash
sudo bash yurich-panel.sh xray
sudo bash yurich-panel.sh hysteria
sudo bash yurich-panel.sh subscription USER
```

На master:

```bash
sudo bash yurich-panel.sh nodes-subscriptions
```

Если node недоступна по SSH, master не сможет подтянуть дополнительные ссылки из её `links.txt`.

## Безопасность

Рекомендации:

- используй SSH-ключи, не парольный SSH;
- не храни `nodes.conf` в публичных местах;
- держи `/etc/naiveproxy/nodes.conf` с правами `600`;
- для non-root SSH пользователя включай только нужный sudo-доступ;
- не добавляй node с чужим доменом;
- перед массовой синхронизацией делай backup:

```bash
sudo bash yurich-panel.sh backup
```

- после синхронизации проверяй:

```bash
sudo bash yurich-panel.sh health
sudo bash yurich-panel.sh nodes-test all
```

## Как не потерять доступ

Перед добавлением и синхронизацией нескольких серверов:

1. Держи открытой консоль провайдера.
2. Не включай WARP full tunnel на node без проверки rollback.
3. Не меняй SSH-порт на всех серверах одновременно.
4. Сначала проверь одну node, потом масштабируй на остальные.
5. После каждого шага проверяй `nodes-test`.

## Bridge: что уже есть и что нужно понимать

В меню 27 есть Bridge builder. Он сохраняет профиль:

```text
мобилка -> этот VPS -> второй VPS
```

Но важно: Caddy/Yurich Proxy не умеет сам по себе прокидывать весь трафик в другой upstream как полноценный chain-router.

Для реальной цепочки нужен один из вариантов:

- Xray на первом VPS с outbound на второй VPS;
- sing-box на первом VPS с outbound на второй VPS;
- отдельный локальный SOCKS/HTTP outbound, куда будут направлены нужные протоколы.

То есть `nodes` — это управление несколькими самостоятельными серверами и подписками, а `bridge` — заготовка для цепочки. Это разные задачи.

## Минимальный чеклист

```bash
# master
sudo bash yurich-panel.sh nodes-add
sudo bash yurich-panel.sh nodes-test all
sudo bash yurich-panel.sh nodes-sync all
sudo bash yurich-panel.sh nodes-subscriptions

# проверить пользователя
sudo bash yurich-panel.sh subscription USER

# health
sudo bash yurich-panel.sh health
```

Если все пункты зелёные, мультисерверная выдача работает.

