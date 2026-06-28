#!/bin/bash
# ============================================================
#   Yurich Panel v5.6.52
#   Стек: Caddy 2 + klzgrad/forwardproxy@naive + Hysteria 2 + WARP + Xray Modern
#   ОС: Ubuntu 20.04 / 22.04 / 24.04
#
#   Copyright (C) 2026 Yurich Panel contributors
#   License: PolyForm Noncommercial 1.0.0 + Commercial License
#   Commercial use requires written permission from the author.
#
#   GitHub:   https://github.com/ivan-yurich/naiveproxy
# ============================================================

set -euo pipefail

VERSION="5.6.52"
LANG_UI="${NAIVEPROXY_LANG:-ru}"  # ru или en — export NAIVEPROXY_LANG=en
GITHUB_RAW="https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/yurich-panel.sh"
GITHUB_SHA256_RAW="https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/yurich-panel.sh.sha256"
GITHUB_API="https://api.github.com/repos/ivan-yurich/naiveproxy/releases/latest"
PROJECT_GITHUB_URL="https://github.com/ivan-yurich/naiveproxy"
PROJECT_GITHUB_SHORT="github.com/ivan-yurich/naiveproxy"
PROJECT_WEBSITE_URL="${YURICH_PROJECT_WEBSITE_URL:-$PROJECT_GITHUB_URL}"
PROJECT_DONATION_URL="${YURICH_DONATION_URL:-https://dzen.ru/ivanyurievich?donate=true}"
ANDROID_APP_RELEASES_URL="https://github.com/ivan-yurich/Yurich-Connect-Android/releases"
WINDOWS_APP_RELEASES_URL="https://github.com/ivan-yurich/yurich-connect-windows/releases"
STREISAND_APP_URL="https://apps.apple.com/us/app/streisand/id6450534064"
KARING_APP_URL="https://apps.apple.com/us/app/karing/id6472431552?l=ru"
TELEGRAM_COMMUNITY_URL="${YURICH_TELEGRAM_COMMUNITY_URL:-https://t.me/your_channel}"
TELEGRAM_BOT_URL="${YURICH_TELEGRAM_BOT_URL:-https://t.me/your_notification_bot}"
TELEGRAM_ID_BOT_URL="${YURICH_TELEGRAM_ID_BOT_URL:-https://t.me/getmyid_bot}"
VK_COMMUNITY_URL="${YURICH_VK_COMMUNITY_URL:-https://vk.com/your_community}"
SUPPORT_EMAIL="${YURICH_SUPPORT_EMAIL:-support@example.com}"
SALES_BOT_CHANNEL_URL_DEFAULT="${YURICH_SALES_BOT_CHANNEL_URL:-https://t.me/your_channel}"
SALES_BOT_PLANS_DEFAULT="1d:50,1m:250,3m:700,6m:1300,12m:2400"
SALES_BOT_CURRENCY_DEFAULT="RUB"
SALES_BOT_PAYMENT_TEXT_DEFAULT="Тарифы Yurich Connect: 1 день - 50 руб, 1 месяц - 250 руб, 3 месяца - 700 руб, 6 месяцев - 1300 руб, 12 месяцев - 2400 руб. После оплаты отправь скрин платежа сюда в бот. Администратор проверит оплату и включит подписку."
SALES_BOT_PAYMENT_QR_PATH_DEFAULT="/etc/naiveproxy/sales-bot/payment-qr.jpg"
SALES_BOT_WELCOME_ANIMATION_PATH_DEFAULT="/etc/naiveproxy/sales-bot/welcome.gif"
SALES_BOT_WELCOME_IMAGE_PATH_DEFAULT="/etc/naiveproxy/sales-bot/welcome.jpg"
SALES_BOT_CAPTCHA_TTL_SECONDS_DEFAULT="86400"
EXPIRED_DELETE_GRACE_DAYS_DEFAULT="5"
SCRIPT_PATH="/usr/local/bin/yurich-panel.sh"
LEGACY_SCRIPT_PATH="/usr/local/bin/naiveproxy.sh"
XCADDY_VERSION_PIN="${NAIVEPROXY_XCADDY_VERSION:-v0.4.6}"
FORWARDPROXY_REF_PIN="${NAIVEPROXY_FORWARDPROXY_REF:-d62c80d3dd2c706b6b87579844d2397bddd18317}"
XRAY_VERSION_PIN="${NAIVEPROXY_XRAY_VERSION:-v26.3.27}"
HYSTERIA_VERSION_PIN="${NAIVEPROXY_HYSTERIA_VERSION:-app/v2.9.2}"
PINGTUNNEL_DEFAULT_VERSION="master-2c83808a81b56784d639c952b70baada6601e2d7"
PINGTUNNEL_VERSION_PIN="${NAIVEPROXY_PINGTUNNEL_VERSION:-$PINGTUNNEL_DEFAULT_VERSION}"
PINGTUNNEL_SHA256_AMD64="5d5847a17099b9359c55a959f85a1994232cf8a089642bd632bfa64e5bdfe8af"
PINGTUNNEL_SHA256_ARM64="ccf5ccb1a2b32cbfa6d85207d0d853b799e9df434ba975e67f93e2fbdf6e51d0"

# ─── Цвета ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GOLD='\033[0;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}[✓]${RESET} $*"; }
err()  { echo -e "${RED}[✗]${RESET} $*"; }
info() { echo -e "${CYAN}[i]${RESET} $*"; }
warn() { echo -e "${YELLOW}[!]${RESET} $*"; }
hr()   { echo -e "${CYAN}──────────────────────────────────────────${RESET}"; }

version_gt() {
    local a="${1:-0}" b="${2:-0}"
    [[ "$a" == "$b" ]] && return 1
    [[ "$(printf '%s\n%s\n' "$a" "$b" | sort -V | tail -n1)" == "$a" ]]
}

# ─── Баннер при первом запуске ────────────────────────────────
show_banner() {
    echo -e "${BOLD}${CYAN}"
    echo '  ███╗   ██╗ █████╗ ██╗██╗   ██╗███████╗'
    echo '  ████╗  ██║██╔══██╗██║██║   ██║██╔════╝'
    echo '  ██╔██╗ ██║███████║██║██║   ██║█████╗  '
    echo '  ██║╚██╗██║██╔══██║██║╚██╗ ██╔╝██╔══╝  '
    echo '  ██║ ╚████║██║  ██║██║ ╚████╔╝ ███████╗'
    echo '  ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝'
    echo -e "${RESET}"
    echo -e "  ${BOLD}${GOLD}██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗${RESET}"
    echo -e "  ${BOLD}${GOLD}██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝${RESET}"
    echo -e "  ${BOLD}${GOLD}██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝ ${RESET}"
    echo -e "  ${BOLD}${GOLD}██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝  ${RESET}"
    echo -e "  ${BOLD}${GOLD}██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║   ${RESET}"
    echo -e "  ${BOLD}${GOLD}╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ${RESET}"
    echo
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${BOLD}  Yurich Panel${RESET} ${DIM}v${VERSION}${RESET}"
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${YELLOW}[INFO] Обновления выходят раз в месяц${RESET}"
    echo -e "  ${CYAN}[GH] GitHub:${RESET}    ${PROJECT_GITHUB_SHORT}"
    [[ -n "${PROJECT_WEBSITE_URL:-}" ]] && echo -e "  ${CYAN}[WEB] Сайт:${RESET}     ${PROJECT_WEBSITE_URL}"
    [[ -n "${TELEGRAM_COMMUNITY_URL:-}" ]] && echo -e "  ${CYAN}[TG] Telegram:${RESET} ${TELEGRAM_COMMUNITY_URL}"
    [[ -n "${PROJECT_DONATION_URL:-}" ]] && echo -e "  ${BOLD}${GOLD}[DONATE] Донат:${RESET} ${PROJECT_DONATION_URL}"
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}

# ─── Пути ────────────────────────────────────────────────────
CADDY_BIN="/usr/local/bin/caddy"
CADDY_SERVICE="/etc/systemd/system/caddy.service"
CADDYFILE="/etc/caddy/Caddyfile"
CADDY_DIR="/etc/caddy"
HYSTERIA_BIN="/usr/local/bin/hysteria"
HYSTERIA_SERVICE="/etc/systemd/system/hysteria.service"
HYSTERIA_CONFIG="/etc/naiveproxy/hysteria.yaml"
HYSTERIA_PORT_HOP_SERVICE="/etc/systemd/system/yurich-hysteria-port-hop.service"
HYSTERIA_PORT_HOP_SCRIPT="/usr/local/sbin/yurich-hysteria-port-hop"
HYSTERIA_PORT_HOP_PORTS_DEFAULT="20000-20100"
XRAY_BIN="/usr/local/bin/xray"
XRAY_SERVICE="/etc/systemd/system/xray.service"
XRAY_CONFIG_DIR="/etc/xray"
XRAY_CONFIG="/etc/xray/config.json"
XRAY_ASSETS_DIR="/usr/local/share/xray"
XRAY_ZAPRET_DAT_DEFAULT="${XRAY_ASSETS_DIR}/zapret.dat"
XRAY_ZAPRET_URL_DEFAULT="https://github.com/kutovoys/ru_gov_zapret/releases/latest/download/zapret.dat"
WARP_PROXY_PORT_DEFAULT="40000"
WEBROOT="/var/www/html"
CONFIG_FILE="/etc/naiveproxy/naive.conf"
CONFIG_DIR="/etc/naiveproxy"
USERS_FILE="/etc/naiveproxy/users.conf"
DISABLED_USERS_FILE="/etc/naiveproxy/users.disabled"
XRAY_USERS_FILE="/etc/naiveproxy/xray-users.conf"
XRAY_DISABLED_USERS_FILE="/etc/naiveproxy/xray-users.disabled"
XRAY_COMPAT_USERS_FILE="/etc/naiveproxy/xray-compat-users.conf"
SUBS_DIR="/etc/naiveproxy/subscriptions"
SUBS_WEB_DIR="${WEBROOT}/s"
SUBSCRIPTION_ASSETS_DIR="/etc/naiveproxy/assets"
SUBSCRIPTION_LOGO_PATH_DEFAULT="${SUBSCRIPTION_ASSETS_DIR}/yurich-connect-logo.png"
SUBSCRIPTION_PROJECT_HELP_QR_PATH_DEFAULT="${SUBSCRIPTION_ASSETS_DIR}/project-help-qr.jpg"
SUBS_ALIASES_FILE="/etc/naiveproxy/subscription-aliases.conf"
USER_META_DIR="/etc/naiveproxy/users.d"
PRIVATE_PAGE_TOKEN_FILE="/etc/naiveproxy/private_page.token"
PRIVATE_WEB_DIR="${WEBROOT}/p"
LOG_DIR="/var/log/caddy"
BACKUP_DIR="/etc/naiveproxy/backups"
EXPORT_DIR="/etc/naiveproxy/exports"
BRIDGE_CONFIG="/etc/naiveproxy/bridge.conf"
NODES_FILE="/etc/naiveproxy/nodes.conf"
MONITOR_SCRIPT="/etc/naiveproxy/monitor.sh"
SSH_HARDENING_DONE="/etc/naiveproxy/.ssh_hardened"
SYSUPDATE_DONE="/etc/naiveproxy/.sysupdate_done"
DEVICE_LIMIT_DEFAULT="5"
DEVICE_WINDOW_HOURS_DEFAULT="24"
DEVICE_CRON="/etc/cron.d/naiveproxy-device-limit"
EXPIRY_NOTIFY_CRON="/etc/cron.d/naiveproxy-expiry-notify"
EXPIRY_NOTIFY_LOG="/var/log/naiveproxy-expiry-notify.log"
PROTOCOL_BENCHMARK_CRON="/etc/cron.d/yurich-protocol-benchmark"
PROTOCOL_BENCHMARK_LOG_DEFAULT="/var/log/yurich-protocol-benchmark.csv"
SALES_BOT_SERVICE="/etc/systemd/system/yurich-sales-bot.service"
SALES_BOT_DIR="/etc/naiveproxy/sales-bot"
SALES_BOT_ORDERS_DIR="${SALES_BOT_DIR}/orders"
SALES_BOT_CAPTCHA_DIR="${SALES_BOT_DIR}/captcha"
SALES_BOT_VERIFIED_DIR="${SALES_BOT_DIR}/verified"
XRAY_REALITY_PORT_DEFAULT="8444"
XRAY_MOBILE_ALT_PORT_DEFAULT="8445"
XRAY_MOBILE_ALT_TARGET_DEFAULT="www.cloudflare.com:443"
XRAY_MOBILE_ALT_SERVER_NAME_DEFAULT="www.cloudflare.com"
XRAY_GITHUB_TEST_PORT_DEFAULT="8446"
XRAY_GITHUB_TEST_TARGET_DEFAULT="github.com:443"
XRAY_GITHUB_TEST_SERVER_NAME_DEFAULT="github.com"
XRAY_MKCP_PORT_DEFAULT="8446"
XRAY_VISION_PORT_DEFAULT="8447"
XRAY_XHTTP_PORT_DEFAULT="8448"
XRAY_WS_PORT_DEFAULT="8449"
XRAY_HTTPUPGRADE_PORT_DEFAULT="8450"
XRAY_CADDY_FALLBACK_PORT_DEFAULT="7443"
XRAY_REALITY_PUBLIC_PORT_DEFAULT=""
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"
HAPROXY_STATS_SOCKET="/run/haproxy-admin.sock"
HAPROXY_LOG_FILE="/var/log/haproxy.log"
HAPROXY_RSYSLOG_CONF="/etc/rsyslog.d/49-yurich-haproxy.conf"
HAPROXY_LOGROTATE_CONF="/etc/logrotate.d/yurich-haproxy"
HAPROXY_SYSCTL_CONF="/etc/sysctl.d/99-yurich-haproxy.conf"
XRAY_SYSCTL_CONF="/etc/sysctl.d/99-z-yurich-vless-reality.conf"
EGRESS_GAI_CONF="/etc/gai.conf"
EGRESS_SYSCTL_CONF="/etc/sysctl.d/99-yurich-egress-ipv4.conf"
PINGTUNNEL_DIR="/opt/yurich-pingtunnel"
PINGTUNNEL_BIN="${PINGTUNNEL_DIR}/pingtunnel"
PINGTUNNEL_ENV="/etc/naiveproxy/pingtunnel.env"
PINGTUNNEL_SERVICE="/etc/systemd/system/yurich-pingtunnel.service"
PINGTUNNEL_SYSCTL_CONF="/etc/sysctl.d/99-yurich-pingtunnel.conf"


# ══════════════════════════════════════════════════════════════
#   БЛОК 1: ОБНОВЛЕНИЕ СИСТЕМЫ
# ══════════════════════════════════════════════════════════════

cmd_sysupdate() {
    hr
    echo -e "${BOLD}  Обновление системы${RESET}"
    hr
    # Загружаем конфиг для Telegram (может вызываться до основного load_config)
    load_config 2>/dev/null || true

    info "Обновляю списки пакетов..."
    apt-get update -q

    info "Устанавливаю обновления пакетов..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q         -o Dpkg::Options::="--force-confdef"         -o Dpkg::Options::="--force-confold"

    info "Чищу ненужные пакеты..."
    apt-get autoremove -y -q
    apt-get autoclean -q

    # Ставим и настраиваем автообновления безопасности
    info "Настраиваю автоматические обновления безопасности..."
    apt-get install -y -q unattended-upgrades apt-listchanges

    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Package-Blacklist {};
Unattended-Upgrade::DevRelease "false";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:30";
EOF

    cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

    systemctl enable unattended-upgrades --quiet 2>/dev/null || true
    systemctl restart unattended-upgrades 2>/dev/null || true

    # Проверяем нужен ли ребут
    if [[ -f /var/run/reboot-required ]]; then
        warn "Требуется перезагрузка сервера для применения обновлений ядра!"
        echo -ne "${YELLOW}Перезагрузить сейчас? [y/N]: ${RESET}"
        read -r ans
        if [[ "${ans,,}" == "y" ]]; then
            ok "Перезагружаю через 5 секунд..."
            sleep 5
            reboot
        else
            warn "Не забудь перезагрузить сервер позже: reboot"
        fi
    fi

    # Маркер что обновление выполнено
    mkdir -p "$CONFIG_DIR"
    date '+%Y-%m-%d %H:%M:%S' > "$SYSUPDATE_DONE"

    ok "Система обновлена"
    ok "Автообновления безопасности: включены (ежедневно)"
    tg_send "🔄 <b>Система обновлена</b>
🖥 Сервер: <code>$(hostname)</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')
🛡 Автообновления безопасности: включены"
}

# ══════════════════════════════════════════════════════════════
#   БЛОК 2: SSH HARDENING
# ══════════════════════════════════════════════════════════════

cmd_ssh_hardening() {
    hr
    echo -e "${BOLD}  SSH Hardening${RESET}"
    hr

    local sshd_config="/etc/ssh/sshd_config"
    local current_port
    current_port=$(current_ssh_port)

    echo -e "  Текущий SSH порт: ${CYAN}${current_port}${RESET}"
    echo

    # ── Шаг 1: Создание нового пользователя ──────────────────
    hr
    echo -e "${BOLD}  Шаг 1: Новый sudo-пользователь${RESET}"
    hr

    local new_user=""
    while true; do
        echo -ne "${CYAN}Имя нового пользователя (Enter = пропустить): ${RESET}"
        read -r new_user
        if [[ -z "$new_user" ]]; then
            warn "Пропускаю создание пользователя"
            break
        fi
        if [[ ! "$new_user" =~ ^[a-z][a-z0-9_-]{2,31}$ ]]; then
            err "Только строчные буквы, цифры, _, - (3-32 символа, начинается с буквы)"
            continue
        fi
        if id "$new_user" &>/dev/null; then
            warn "Пользователь $new_user уже существует"
            break
        fi

        # Создаём пользователя
        useradd -m -s /bin/bash "$new_user"
        usermod -aG sudo "$new_user"

        # Пароль
        echo -ne "${CYAN}Пароль для $new_user (Enter = сгенерировать): ${RESET}"
        read -r user_pass
        if [[ -z "$user_pass" ]]; then
            user_pass=$(random_safe_token 20 'a-zA-Z0-9')
            info "Сгенерирован пароль: ${BOLD}${user_pass}${RESET}"
            info "СОХРАНИ ЕГО СЕЙЧАС!"
        fi
        printf "%s:%s" "${new_user}" "${user_pass}" | chpasswd
        ok "Пользователь ${new_user} создан с правами sudo"
        break
    done

    # ── Шаг 2: SSH-ключ ──────────────────────────────────────
    hr
    echo -e "${BOLD}  Шаг 2: SSH-ключ (ED25519)${RESET}"
    hr

    local target_user="${new_user:-root}"
    local target_home
    target_home=$(getent passwd "$target_user" | cut -d: -f6)
    local ssh_dir="${target_home}/.ssh"
    local auth_keys="${ssh_dir}/authorized_keys"

    if [[ -f "$auth_keys" ]] && grep -q "ssh-" "$auth_keys" 2>/dev/null; then
        ok "SSH-ключ уже настроен для ${target_user}"
    else
        info "Генерирую ED25519 ключ для ${target_user}..."
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"

        # Генерируем ключ
        ssh-keygen -t ed25519 -f "${ssh_dir}/id_ed25519_server" -N "" -C "naiveproxy-server-$(date +%Y%m%d)" -q
        cat "${ssh_dir}/id_ed25519_server.pub" >> "$auth_keys"
        chmod 600 "$auth_keys"
        [[ "$target_user" != "root" ]] && chown -R "${target_user}:${target_user}" "$ssh_dir"

        # Авто-сохранение ключа в /etc/naiveproxy/
        mkdir -p "$CONFIG_DIR"
        cp "${ssh_dir}/id_ed25519_server"     "${CONFIG_DIR}/ssh_private_key"
        cp "${ssh_dir}/id_ed25519_server.pub" "${CONFIG_DIR}/ssh_public_key"
        chmod 600 "${CONFIG_DIR}/ssh_private_key"
        ok "SSH ключ авто-сохранён: ${CONFIG_DIR}/ssh_private_key"

        echo
        echo -e "${RED}╔══════════════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}║  ПРИВАТНЫЙ КЛЮЧ — СКОПИРУЙ И СОХРАНИ ПРЯМО СЕЙЧАС  ║${RESET}"
        echo -e "${RED}╚══════════════════════════════════════════════════════╝${RESET}"
        cat "${ssh_dir}/id_ed25519_server"
        echo -e "${RED}══════════════════════════════════════════════════════${RESET}"
        echo

        # Команда для скачивания ключа с сервера
        local server_ip_tmp
        server_ip_tmp=$(curl -s4 --max-time 5 https://ifconfig.me 2>/dev/null || echo YOUR_IP)
        echo -e "  ${BOLD}Скачать ключ на свой компьютер:${RESET}"
        echo -e "  ${CYAN}# Linux/macOS:${RESET}"
        echo -e "  scp root@${server_ip_tmp}:${CONFIG_DIR}/ssh_private_key ~/.ssh/id_naiveproxy"
        echo -e "  chmod 600 ~/.ssh/id_naiveproxy"
        echo
        echo -e "  ${CYAN}# Windows PowerShell:${RESET}"
        echo -e "  scp root@${server_ip_tmp}:${CONFIG_DIR}/ssh_private_key \$HOME\.ssh\id_naiveproxy"
        echo
        warn "Подключение после hardening:"
        echo -e "  ${CYAN}ssh -i ~/.ssh/id_naiveproxy -p [НОВЫЙ_ПОРТ] ${target_user}@${server_ip_tmp}${RESET}"
        echo
        echo -ne "${YELLOW}Ты сохранил/скачал ключ? [yes]: ${RESET}"
        read -r confirm
        if [[ "${confirm,,}" != "yes" && "${confirm,,}" != "y" ]]; then
            warn "Ключ сохранён на сервере: ${CONFIG_DIR}/ssh_private_key"
            warn "Скачай его позже через scp!"
            echo -ne "${YELLOW}Продолжить? [y/N]: ${RESET}"
            read -r force
            [[ "${force,,}" == "y" ]] || return 1
        fi
        ok "SSH-ключ сгенерирован и добавлен в authorized_keys"
    fi

    # ── Шаг 3: Смена SSH порта ────────────────────────────────
    hr
    echo -e "${BOLD}  Шаг 3: Смена SSH порта${RESET}"
    hr

    local new_ssh_port=""
    echo -e "  Текущий порт: ${CYAN}${current_port}${RESET}"
    echo -e "  ${BOLD}1)${RESET} Ввести вручную"
    echo -e "  ${BOLD}2)${RESET} Случайный (49000-65000)"
    echo -e "  ${BOLD}0)${RESET} Оставить ${current_port}"
    echo -ne "${CYAN}Выбор: ${RESET}"
    read -r port_choice

    case "$port_choice" in
        1)
            while true; do
                echo -ne "${CYAN}Новый SSH порт (1024-65535): ${RESET}"
                read -r new_ssh_port
                if [[ "$new_ssh_port" =~ ^[0-9]+$ ]] &&                    [[ "$new_ssh_port" -ge 1024 ]] &&                    [[ "$new_ssh_port" -le 65535 ]]; then
                    break
                fi
                err "Неверный порт. Введи число от 1024 до 65535"
            done
            ;;
        2)
            # Генерируем случайный порт и проверяем что он свободен
            while true; do
                new_ssh_port=$(( RANDOM % 16000 + 49000 ))
                if ! ss -tlnp | grep -E ":${new_ssh_port}([[:space:]]|$)" >/dev/null; then
                    break
                fi
            done
            info "Случайный порт: ${BOLD}${new_ssh_port}${RESET}"
            ;;
        *)
            new_ssh_port="$current_port"
            info "Порт оставляем: $current_port"
            ;;
    esac

    # ── Шаг 4: Применяем sshd_config ─────────────────────────
    hr
    echo -e "${BOLD}  Шаг 4: Настройка sshd_config${RESET}"
    hr

    # Бэкап — сохраняем метку времени для возможного отката
    local sshd_backup
    sshd_backup="${sshd_config}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$sshd_config" "$sshd_backup"
    ok "Бэкап sshd_config создан: $sshd_backup"

    # Безопасные значения по умолчанию: не отключаем текущие способы входа без явного согласия.
    local permit_root="yes"
    local password_auth="yes"

    if [[ "$target_user" != "root" ]]; then
        echo -ne "${YELLOW}Запретить SSH вход root? [y/N]: ${RESET}"
        read -r ans_disable_root
        [[ "${ans_disable_root,,}" == "y" ]] && permit_root="no"
    else
        warn "Hardening выполняется для root — root вход оставляю включённым, чтобы не потерять доступ."
    fi

    if [[ ! -f "$auth_keys" ]] || ! grep -q "ssh-" "$auth_keys" 2>/dev/null; then
        warn "Нет SSH-ключа — пароль оставляем включённым"
    else
        echo -ne "${YELLOW}Отключить SSH вход по паролю? [y/N]: ${RESET}"
        read -r ans_disable_pass
        [[ "${ans_disable_pass,,}" == "y" ]] && password_auth="no"
    fi

    # Меняем настройки
    # Проверяем что строка Port вообще есть
    if grep -qE "^#?Port " "$sshd_config"; then
        sed -i "s/^#*Port .*/Port ${new_ssh_port}/" "$sshd_config"
    else
        echo "Port ${new_ssh_port}" >> "$sshd_config"
    fi
    # На Ubuntu 22.04+ конфиг может быть в /etc/ssh/sshd_config.d/*.conf
    for cfg in /etc/ssh/sshd_config.d/*.conf; do
        [[ ! -f "$cfg" ]] && continue
        if grep -qE "^#?Port " "$cfg"; then
            sed -i "s/^#*Port .*/Port ${new_ssh_port}/" "$cfg"
        fi
    done
    # PermitRootLogin
    if grep -qE "^#?PermitRootLogin " "$sshd_config"; then
        sed -i "s/^#*PermitRootLogin .*/PermitRootLogin ${permit_root}/" "$sshd_config"
    else
        echo "PermitRootLogin ${permit_root}" >> "$sshd_config"
    fi
    # PasswordAuthentication
    if grep -qE "^#?PasswordAuthentication " "$sshd_config"; then
        sed -i "s/^#*PasswordAuthentication .*/PasswordAuthentication ${password_auth}/" "$sshd_config"
    else
        echo "PasswordAuthentication ${password_auth}" >> "$sshd_config"
    fi
    # Также в conf.d файлах (Ubuntu 22.04+)
    for cfg in /etc/ssh/sshd_config.d/*.conf; do
        [[ ! -f "$cfg" ]] && continue
        sed -i "s/^#*PermitRootLogin .*/PermitRootLogin ${permit_root}/" "$cfg" 2>/dev/null || true
        sed -i "s/^#*PasswordAuthentication .*/PasswordAuthentication ${password_auth}/" "$cfg" 2>/dev/null || true
    done
    sed -i "s/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/" "$sshd_config"
    sed -i "s/^#*AuthorizedKeysFile .*/AuthorizedKeysFile .ssh\/authorized_keys/" "$sshd_config"
    sed -i "s/^#*X11Forwarding .*/X11Forwarding no/" "$sshd_config"
    sed -i "s/^#*MaxAuthTries .*/MaxAuthTries 3/" "$sshd_config"
    sed -i "s/^#*LoginGraceTime .*/LoginGraceTime 30/" "$sshd_config"
    sed -i "s/^#*PermitEmptyPasswords .*/PermitEmptyPasswords no/" "$sshd_config"

    # Добавляем если нет
    grep -q "^ClientAliveInterval" "$sshd_config" || echo "ClientAliveInterval 300" >> "$sshd_config"
    grep -q "^ClientAliveCountMax" "$sshd_config" || echo "ClientAliveCountMax 2"  >> "$sshd_config"

    # Проверяем конфиг
    if ! sshd -t 2>/dev/null; then
        err "Ошибка в sshd_config! Откатываю из $sshd_backup..."
        cp "$sshd_backup" "$sshd_config" 2>/dev/null || true
        return 1
    fi

    # ── Шаг 5: UFW + Fail2Ban ─────────────────────────────────
    hr
    echo -e "${BOLD}  Шаг 5: Firewall + Fail2Ban${RESET}"
    hr

    # Убеждаемся что UFW активен
    if ! ufw status | grep -q "Status: active"; then
        warn "UFW неактивен — включаю..."
        ufw --force enable >/dev/null 2>&1 || true
    fi
    # Открываем новый порт ПЕРЕД закрытием старого
    ufw allow "${new_ssh_port}/tcp" comment "SSH hardened" >/dev/null 2>&1 || true

    # Старый порт не закрываем автоматически: это частая причина lockout.
    if [[ "$new_ssh_port" != "$current_port" ]]; then
        warn "Старый SSH порт ${current_port} оставлен открытым в UFW как аварийный запас."
        warn "Закрой его вручную только после проверки входа на порт ${new_ssh_port}."
    fi

    ok "Новый SSH порт ${new_ssh_port} открыт в UFW"

    # Ubuntu 22.04+ может использовать ssh.socket. Переключаемся на ssh.service
    # и сразу перезапускаем SSH, до установки дополнительных пакетов.
    local ssh_socket_was_enabled="no"
    if systemctl is-enabled ssh.socket &>/dev/null; then
        ssh_socket_was_enabled="yes"
        info "Отключаю ssh.socket (Ubuntu 22.04+ override) и включаю ssh.service..."
        systemctl enable ssh --quiet 2>/dev/null || systemctl enable sshd --quiet 2>/dev/null || true
        systemctl disable --now ssh.socket --quiet 2>/dev/null || true
    fi

    if restart_ssh_service; then
        ok "SSH сервис перезапущен с новыми настройками"
    else
        err "Не удалось перезапустить ssh/sshd. Откатываю sshd_config..."
        cp "$sshd_backup" "$sshd_config" 2>/dev/null || true
        if [[ "$ssh_socket_was_enabled" == "yes" ]]; then
            systemctl enable --now ssh.socket --quiet 2>/dev/null || true
        fi
        restart_ssh_service || true
        return 1
    fi

    setup_fail2ban "$new_ssh_port" || return 1

    # Маркер
    mkdir -p "$CONFIG_DIR"
    cat > "$SSH_HARDENING_DONE" << EOF
SSH_PORT=${new_ssh_port}
SSH_USER=${target_user}
HARDENED_AT=$(date '+%Y-%m-%d %H:%M:%S')
EOF

    # ── Итог ─────────────────────────────────────────────────
    local server_ip
    server_ip=$(curl -s4 --max-time 5 https://ifconfig.me 2>/dev/null         || curl -s4 --max-time 5 https://api.ipify.org 2>/dev/null || echo "YOUR_IP")

    hr
    echo -e "${BOLD}${GREEN}  SSH Hardening завершён!${RESET}"
    hr
    echo -e "  ${BOLD}Новый SSH порт:${RESET}  ${CYAN}${new_ssh_port}${RESET}"
    echo -e "  ${BOLD}Пользователь:${RESET}   ${CYAN}${target_user}${RESET}"
    echo -e "  ${BOLD}Root вход:${RESET}      $([ "$permit_root" = "no" ] && echo -e "${RED}запрещён${RESET}" || echo -e "${YELLOW}разрешён${RESET}")"
    echo -e "  ${BOLD}Пароль вход:${RESET}    $([ "$password_auth" = "no" ] && echo -e "${RED}запрещён${RESET}" || echo -e "${YELLOW}разрешён${RESET}")"
    echo -e "  ${BOLD}Fail2Ban:${RESET}       ${GREEN}активен${RESET}"
    echo
    echo -e "  ${BOLD}Подключение:${RESET}"
    echo -e "  ${CYAN}ssh -i ~/.ssh/id_naiveproxy -p ${new_ssh_port} ${target_user}@${server_ip}${RESET}"
    hr

    tg_send "🔒 <b>SSH Hardening выполнен</b>
🖥 Сервер: <code>$(hostname)</code>
🔑 Пользователь: <code>${target_user}</code>
🚪 SSH порт: <code>${new_ssh_port}</code>
🛡 Fail2Ban: включён
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
}

cmd_ssh_rescue() {
    hr
    echo -e "${BOLD}${YELLOW}  SSH Rescue Mode${RESET}"
    hr
    warn "Включаю временный аварийный SSH-доступ на 22 порту."
    warn "После восстановления зайди по SSH и заново настрой hardening."

    mkdir -p /etc/ssh/sshd_config.d
    cat > /etc/ssh/sshd_config.d/99-naiveproxy-rescue.conf <<'EOF'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
EOF

    systemctl disable --now ssh.socket >/dev/null 2>&1 || true
    ufw allow 22/tcp comment "SSH rescue" >/dev/null 2>&1 || true
    ufw allow 80/tcp comment "Yurich Panel ACME" >/dev/null 2>&1 || true
    ufw allow 443/tcp comment "Yurich Panel HTTPS" >/dev/null 2>&1 || true
    ufw allow 443/udp comment "Yurich Panel HTTP3" >/dev/null 2>&1 || true
    systemctl stop fail2ban >/dev/null 2>&1 || true

    local rescue_ttl="${NAIVEPROXY_SSH_RESCUE_TTL_SECONDS:-1800}"
    cat > /usr/local/sbin/yurich-disable-ssh-rescue.sh <<'EOF'
#!/bin/bash
set -euo pipefail
rm -f /etc/ssh/sshd_config.d/99-naiveproxy-rescue.conf
# Do not delete the UFW 22/tcp rule automatically: on some servers it can be a legitimate admin rule.
systemctl start fail2ban >/dev/null 2>&1 || true
if sshd -t; then
    systemctl reload ssh >/dev/null 2>&1 || systemctl reload sshd >/dev/null 2>&1 || systemctl restart ssh >/dev/null 2>&1 || systemctl restart sshd >/dev/null 2>&1 || true
fi
EOF
    chmod 700 /usr/local/sbin/yurich-disable-ssh-rescue.sh
    if command -v systemd-run >/dev/null 2>&1; then
        systemd-run --unit=yurich-ssh-rescue-autodisable --on-active="${rescue_ttl}s" /usr/local/sbin/yurich-disable-ssh-rescue.sh >/dev/null 2>&1 \
            && warn "SSH rescue автоматически отключится через ${rescue_ttl} сек."
    fi

    if sshd -t; then
        restart_ssh_service
        ok "SSH rescue включён: порт 22, root/password временно разрешены"
        warn "Если пароль root неизвестен, задай его командой: passwd root"
        ss -tlnp | grep -E ':(22)\s' || true
    else
        err "sshd_config не прошёл проверку"
        return 1
    fi
}


# ─── МУЛЬТИЯЗЫЧНОСТЬ ──────────────────────────────────────────
# Использование: t "Текст на русском" "English text"
t() {
    if [[ "${LANG_UI}" == "en" ]]; then
        echo "$2"
    else
        echo "$1"
    fi
}

normalize_lang_ui() {
    if [[ -n "${NAIVEPROXY_LANG:-}" ]]; then
        LANG_UI="$NAIVEPROXY_LANG"
    fi
    case "${LANG_UI:-ru}" in
        ru|en) ;;
        *) LANG_UI="ru" ;;
    esac
}

# Установить язык: export NAIVEPROXY_LANG=en
# Set language:   export NAIVEPROXY_LANG=en

# ─── Проверки ────────────────────────────────────────────────
check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "Запускай от root: sudo bash $0"
        exit 1
    fi
}

check_os() {
    if ! grep -qiE "ubuntu|debian" /etc/os-release 2>/dev/null; then
        warn "Скрипт тестировался на Ubuntu/Debian. Продолжаем на свой страх и риск."
    fi
}

check_installed() {
    [[ -f "$CADDY_BIN" && -f "$CADDYFILE" ]]
}

is_valid_domain() {
    [[ "${1:-}" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]
}

is_valid_host_port() {
    local value="${1:-}" host port
    [[ "$value" == *:* ]] || return 1
    host="${value%:*}"
    port="${value##*:}"
    is_valid_domain "$host" || return 1
    [[ "$port" =~ ^[0-9]{1,5}$ ]] || return 1
    (( port >= 1 && port <= 65535 ))
}

public_dns_ipv4() {
    local domain="${1:-}"
    [[ -n "$domain" ]] || return 0
    command -v dig >/dev/null 2>&1 || return 0
    dig @1.1.1.1 +short A "$domain" +time=3 +tries=1 2>/dev/null \
        | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' \
        | head -1 || true
}

domains_for_hosts_audit() {
    local dom node_domain
    {
        [[ -n "${DOMAIN:-}" ]] && printf '%s\n' "$DOMAIN"
        if [[ -n "${DOMAINS:-}" ]]; then
            local IFS=','
            for dom in $DOMAINS; do
                printf '%s\n' "$dom"
            done
        fi
        if [[ -f "${NODES_FILE:-}" ]]; then
            while IFS='|' read -r _ _ _ _ node_domain _; do
                if [[ -n "$node_domain" && "$node_domain" != "-" ]]; then
                    printf '%s\n' "$node_domain"
                fi
            done < <(grep -v '^#\|^[[:space:]]*$' "$NODES_FILE" 2>/dev/null || true)
        fi
    } | while IFS= read -r dom; do
        dom="${dom//[[:space:]]/}"
        dom="${dom%.}"
        dom="${dom,,}"
        if [[ -n "$dom" ]] && is_valid_domain "$dom"; then
            printf '%s\n' "$dom"
        fi
    done | awk '!seen[$0]++'
}

hosts_public_domain_overrides() {
    local hosts_file="${1:-/etc/hosts}" domain
    [[ -r "$hosts_file" ]] || return 0
    domains_for_hosts_audit | while IFS= read -r domain; do
        awk -v domain="$domain" '
            /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
            {
                for (i = 2; i <= NF; i++) {
                    entry = tolower($i)
                    sub(/\.$/, "", entry)
                    if (entry == domain) {
                        print domain "|" FNR ":" $0
                        break
                    }
                }
            }
        ' "$hosts_file"
    done
}

format_hosts_override_domains() {
    awk -F'|' 'NF && !seen[$1]++ { out = out sep $1; sep = ", " } END { print out }'
}

is_valid_proxy_user() {
    [[ "${1:-}" =~ ^[a-zA-Z0-9_-]{2,32}$ ]]
}

is_valid_proxy_pass() {
    [[ "${1:-}" =~ ^[a-zA-Z0-9_-]{8,64}$ ]]
}

current_ssh_port() {
    local port
    port=$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}' || true)
    [[ -n "$port" ]] || port="22"
    printf '%s\n' "$port"
}

restart_ssh_service() {
    if systemctl restart ssh 2>/dev/null; then
        return 0
    fi
    if systemctl restart sshd 2>/dev/null; then
        return 0
    fi
    return 1
}

detect_hysteria_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        armv7l|armv7*) echo "armv7" ;;
        i386|i686) echo "386" ;;
        *) err "Архитектура $arch не поддерживается Hysteria 2 автоустановкой"; return 1 ;;
    esac
}

find_caddy_cert() {
    local domain="${1:-${DOMAIN:-}}"
    [[ -z "$domain" ]] && return 1
    find /root/.local/share/caddy/certificates -type f -path "*/${domain}/${domain}.crt" 2>/dev/null | head -1
}

find_caddy_key() {
    local domain="${1:-${DOMAIN:-}}"
    [[ -z "$domain" ]] && return 1
    find /root/.local/share/caddy/certificates -type f -path "*/${domain}/${domain}.key" 2>/dev/null | head -1
}

is_valid_port() {
    [[ "${1:-}" =~ ^[0-9]+$ ]] && [[ "$1" -ge 1 ]] && [[ "$1" -le 65535 ]]
}

is_valid_local_proxy_port() {
    [[ "${1:-}" =~ ^[0-9]+$ ]] && [[ "$1" -ge 1024 ]] && [[ "$1" -le 65535 ]]
}

warp_cli() {
    warp-cli --accept-tos "$@" 2>/dev/null || warp-cli "$@"
}

random_safe_token() {
    local len="${1:-20}"
    local alphabet="${2:-a-zA-Z0-9_-}"
    local token=""
    local chunk
    local attempts=0

    if ! [[ "$len" =~ ^[0-9]+$ ]] || [[ "$len" -lt 8 || "$len" -gt 128 ]]; then
        err "Некорректная длина токена: $len"
        return 1
    fi

    while [[ ${#token} -lt "$len" ]]; do
        attempts=$((attempts + 1))
        if [[ "$attempts" -gt 20 ]]; then
            err "Не удалось сгенерировать случайный токен через openssl"
            return 1
        fi
        chunk=$(openssl rand -base64 "$((len * 3))" 2>/dev/null \
            | LC_ALL=C tr -dc "$alphabet" \
            | head -c "$len" || true)
        token="${token}${chunk}"
    done

    printf '%s\n' "${token:0:len}"
}

is_valid_hysteria_secret() {
    [[ "${1:-}" =~ ^[A-Za-z0-9_-]{8,64}$ ]]
}

ensure_hysteria_secrets() {
    if ! is_valid_hysteria_secret "${HYSTERIA_PASSWORD:-}"; then
        HYSTERIA_PASSWORD=$(random_safe_token 24)
        info "Сгенерирован новый пароль Hysteria 2"
    fi

    if ! is_valid_hysteria_secret "${HYSTERIA_OBFS_PASSWORD:-}"; then
        HYSTERIA_OBFS_PASSWORD=$(random_safe_token 24)
        info "Сгенерирован новый obfs-пароль Hysteria 2"
    fi

    if ! is_valid_hysteria_secret "${HYSTERIA_PASSWORD:-}" || ! is_valid_hysteria_secret "${HYSTERIA_OBFS_PASSWORD:-}"; then
        err "Не удалось подготовить безопасные пароли Hysteria 2"
        return 1
    fi
}

# ─── Режим входящего 443 ─────────────────────────────────────
normalize_edge_routing_mode() {
    case "${EDGE_ROUTING_MODE:-}" in
        haproxy|sni|sni-mux|sni_mux)
            EDGE_ROUTING_MODE="haproxy"
            ;;
        caddy|caddy-only|caddy_only|"")
            if [[ "${XRAY_REALITY_SNI_MUX_ENABLED:-0}" == "1" ]]; then
                EDGE_ROUTING_MODE="haproxy"
            else
                EDGE_ROUTING_MODE="caddy"
            fi
            ;;
        *)
            warn "Неизвестный EDGE_ROUTING_MODE=${EDGE_ROUTING_MODE}; использую caddy"
            EDGE_ROUTING_MODE="caddy"
            ;;
    esac
}

edge_routing_mode_is_haproxy() {
    [[ "${EDGE_ROUTING_MODE:-}" == "haproxy" || "${XRAY_REALITY_SNI_MUX_ENABLED:-0}" == "1" ]]
}

edge_routing_mode_label() {
    if edge_routing_mode_is_haproxy; then
        printf 'HAProxy SNI mux'
    else
        printf 'Caddy-only'
    fi
}

set_edge_routing_mode() {
    local mode="${1:-caddy}"
    case "$mode" in
        haproxy|sni|sni-mux|sni_mux)
            EDGE_ROUTING_MODE="haproxy"
            XRAY_REALITY_SNI_MUX_ENABLED="1"
            XRAY_FALLBACK_ENABLED="0"
            XRAY_REALITY_PUBLIC_PORT="443"
            XRAY_CADDY_FALLBACK_PORT="${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
            ;;
        caddy|caddy-only|caddy_only)
            EDGE_ROUTING_MODE="caddy"
            XRAY_REALITY_SNI_MUX_ENABLED="0"
            XRAY_FALLBACK_ENABLED="0"
            XRAY_REALITY_PUBLIC_PORT=""
            ;;
        *)
            err "Неверный режим 443: $mode"
            return 1
            ;;
    esac
}

prompt_edge_routing_mode() {
    local ans current mode
    normalize_edge_routing_mode
    current="${EDGE_ROUTING_MODE:-caddy}"
    echo
    echo -e "${BOLD}Режим входящего 443:${RESET}"
    echo -e "  ${BOLD}1)${RESET} Caddy-only — Caddy держит 443, VLESS Reality на отдельном TCP-порту"
    echo -e "  ${BOLD}2)${RESET} HAProxy SNI mux — Naive/Caddy и VLESS Reality вместе на 443"
    echo -ne "${YELLOW}Выбор [${current}]: ${RESET}"
    read -r ans
    case "${ans,,}" in
        "" ) mode="$current" ;;
        1|c|caddy|caddy-only|caddy_only) mode="caddy" ;;
        2|h|haproxy|sni|sni-mux|sni_mux) mode="haproxy" ;;
        *) err "Неверный выбор режима 443"; return 1 ;;
    esac
    set_edge_routing_mode "$mode"
    ok "Режим 443 выбран: $(edge_routing_mode_label)"
}

# ─── Конфиг ──────────────────────────────────────────────────
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # Безопасность: проверяем владельца и права перед source
        local owner perms
        owner=$(stat -c '%U' "$CONFIG_FILE" 2>/dev/null || echo "unknown")
        perms=$(stat -c '%a' "$CONFIG_FILE" 2>/dev/null || echo "000")
        if [[ "$owner" != "root" ]]; then
            err "БЕЗОПАСНОСТЬ: $CONFIG_FILE принадлежит '$owner', ожидается root. Прерываю."
            exit 1
        fi
        [[ "$perms" != "600" ]] && chmod 600 "$CONFIG_FILE"
        # shellcheck source=/dev/null
        # Проверяем владельца перед source
        local _cfg_owner
        _cfg_owner=$(stat -c '%U' "$CONFIG_FILE" 2>/dev/null || echo "unknown")
        if [[ "$_cfg_owner" == "root" ]]; then
            # shellcheck source=/dev/null
            source "$CONFIG_FILE"
            normalize_lang_ui
            normalize_edge_routing_mode
        else
            warn "CONFIG_FILE принадлежит не root — пропускаю source"
        fi
    fi
    normalize_lang_ui
    normalize_edge_routing_mode
}

save_config() {
    mkdir -p "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR" 2>/dev/null || true

    local tmp_config
    tmp_config=$(mktemp "${CONFIG_DIR}/.naive.conf.XXXXXX") || {
        err "Не удалось создать временный конфиг в $CONFIG_DIR"
        return 1
    }
    chmod 600 "$tmp_config"
    normalize_edge_routing_mode

    if ! {
        printf 'LANG_UI=%q\n' "${LANG_UI:-ru}"
        printf 'DOMAIN=%q\n' "${DOMAIN:-}"
        printf 'DOMAINS=%q\n' "${DOMAINS:-${DOMAIN:-}}"
        printf 'EMAIL=%q\n' "${EMAIL:-}"
        printf '# Красивое имя сервера в подписках, например: 🇫🇮 Finland\n'
        printf 'PROFILE_LOCATION_LABEL=%q\n' "${PROFILE_LOCATION_LABEL:-Yurich}"
        printf '# Подписки: 1 = включать локальный сервер в клиентские профили, 0 = только nodes\n'
        printf 'SUBSCRIPTION_LOCAL_ENABLED=%q\n' "${SUBSCRIPTION_LOCAL_ENABLED:-1}"
        printf '# Подписки: first или last, если локальный сервер включён\n'
        printf 'SUBSCRIPTION_LOCAL_POSITION=%q\n' "${SUBSCRIPTION_LOCAL_POSITION:-first}"
        printf '# Новый дизайн страниц подписок: all, * или список пользователей через пробел\n'
        printf 'SUBSCRIPTION_REMWAVE_USERS=%q\n' "${SUBSCRIPTION_REMWAVE_USERS:-all}"
        printf 'SUBSCRIPTION_REMWAVE_PREVIEW_USERS=%q\n' "${SUBSCRIPTION_REMWAVE_PREVIEW_USERS:-all}"
        printf '# Режим входящего 443: caddy = Caddy держит 443; haproxy = HAProxy SNI mux держит 443\n'
        printf 'EDGE_ROUTING_MODE=%q\n' "${EDGE_ROUTING_MODE:-caddy}"
        printf '# Автомониторинг протоколов: тестовый пользователь, повторы, порог средней задержки в мс\n'
        printf 'PROTOCOL_BENCHMARK_USER=%q\n' "${PROTOCOL_BENCHMARK_USER:-}"
        printf 'PROTOCOL_BENCHMARK_ROUNDS=%q\n' "${PROTOCOL_BENCHMARK_ROUNDS:-3}"
        printf 'PROTOCOL_BENCHMARK_MAX_AVG_MS=%q\n' "${PROTOCOL_BENCHMARK_MAX_AVG_MS:-2500}"
        printf 'PROTOCOL_BENCHMARK_LOG=%q\n' "${PROTOCOL_BENCHMARK_LOG:-$PROTOCOL_BENCHMARK_LOG_DEFAULT}"
        printf 'PROTOCOL_BENCHMARK_MONITOR_MIN_ROUNDS=%q\n' "${PROTOCOL_BENCHMARK_MONITOR_MIN_ROUNDS:-3}"
        printf 'PROTOCOL_BENCHMARK_SLOW_MIN_HITS=%q\n' "${PROTOCOL_BENCHMARK_SLOW_MIN_HITS:-2}"
        printf 'PROTOCOL_BENCHMARK_WARN_MIN_OK_HITS=%q\n' "${PROTOCOL_BENCHMARK_WARN_MIN_OK_HITS:-2}"
        printf 'PROTOCOL_BENCHMARK_ALERT_REPEAT=%q\n' "${PROTOCOL_BENCHMARK_ALERT_REPEAT:-2}"
        printf 'PROTOCOL_BENCHMARK_ALERT_COOLDOWN_MINUTES=%q\n' "${PROTOCOL_BENCHMARK_ALERT_COOLDOWN_MINUTES:-60}"
        printf 'PROTOCOL_BENCHMARK_ALERT_STATE=%q\n' "${PROTOCOL_BENCHMARK_ALERT_STATE:-$CONFIG_DIR/protocol-benchmark-alert.state}"
        printf 'PROTOCOL_BENCHMARK_RECOVERY_ALERT=%q\n' "${PROTOCOL_BENCHMARK_RECOVERY_ALERT:-1}"
        printf 'PROTOCOL_MONITOR_ALERT_COOLDOWN_MINUTES=%q\n' "${PROTOCOL_MONITOR_ALERT_COOLDOWN_MINUTES:-60}"
        printf 'PROTOCOL_MONITOR_ALERT_STATE=%q\n' "${PROTOCOL_MONITOR_ALERT_STATE:-$CONFIG_DIR/protocol-health-alert.state}"
        printf 'PROTOCOL_MONITOR_RECOVERY_ALERT=%q\n' "${PROTOCOL_MONITOR_RECOVERY_ALERT:-1}"
        printf 'TG_TOKEN=%q\n' "${TG_TOKEN:-}"
        printf 'TG_CHAT_ID=%q\n' "${TG_CHAT_ID:-}"
        printf '# Доп. администраторы через запятую: id1,id2,id3\n'
        printf 'TG_ADMINS=%q\n' "${TG_ADMINS:-}"
        printf '# Отдельный Telegram бот для продаж и автовыдачи подписок\n'
        printf 'SALES_BOT_TOKEN=%q\n' "${SALES_BOT_TOKEN:-}"
        printf 'SALES_BOT_ADMIN_ID=%q\n' "${SALES_BOT_ADMIN_ID:-${TG_CHAT_ID:-}}"
        printf 'SALES_BOT_ADMINS=%q\n' "${SALES_BOT_ADMINS:-}"
        printf 'SALES_BOT_PLANS=%q\n' "${SALES_BOT_PLANS:-$SALES_BOT_PLANS_DEFAULT}"
        printf 'SALES_BOT_CURRENCY=%q\n' "${SALES_BOT_CURRENCY:-$SALES_BOT_CURRENCY_DEFAULT}"
        printf 'SALES_BOT_CHANNEL_URL=%q\n' "${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}"
        printf 'SALES_BOT_PAYMENT_TEXT=%q\n' "${SALES_BOT_PAYMENT_TEXT:-$SALES_BOT_PAYMENT_TEXT_DEFAULT}"
        printf 'SALES_BOT_PAYMENT_QR_PATH=%q\n' "${SALES_BOT_PAYMENT_QR_PATH:-$SALES_BOT_PAYMENT_QR_PATH_DEFAULT}"
        printf 'SALES_BOT_WELCOME_ANIMATION_PATH=%q\n' "${SALES_BOT_WELCOME_ANIMATION_PATH:-$SALES_BOT_WELCOME_ANIMATION_PATH_DEFAULT}"
        printf 'SALES_BOT_WELCOME_IMAGE_PATH=%q\n' "${SALES_BOT_WELCOME_IMAGE_PATH:-$SALES_BOT_WELCOME_IMAGE_PATH_DEFAULT}"
        printf 'SALES_BOT_CAPTCHA_TTL_SECONDS=%q\n' "${SALES_BOT_CAPTCHA_TTL_SECONDS:-$SALES_BOT_CAPTCHA_TTL_SECONDS_DEFAULT}"
        printf 'HYSTERIA_PORT=%q\n' "${HYSTERIA_PORT:-8443}"
        printf 'HYSTERIA_PASSWORD=%q\n' "${HYSTERIA_PASSWORD:-}"
        printf 'HYSTERIA_OBFS_PASSWORD=%q\n' "${HYSTERIA_OBFS_PASSWORD:-}"
        printf '# 1 = направлять только Hysteria 2 через локальный WARP SOCKS5, не трогая Caddy/Xray\n'
        printf 'HYSTERIA_WARP_ENABLED=%q\n' "${HYSTERIA_WARP_ENABLED:-0}"
        printf '# 1 = добавлять Hysteria 2 Port Hopping профиль и UDP redirect диапазона на Hysteria порт\n'
        printf 'HYSTERIA_PORT_HOP_ENABLED=%q\n' "${HYSTERIA_PORT_HOP_ENABLED:-0}"
        printf 'HYSTERIA_PORT_HOP_PORTS=%q\n' "${HYSTERIA_PORT_HOP_PORTS:-$HYSTERIA_PORT_HOP_PORTS_DEFAULT}"
        printf 'UNBOUND_ENABLED=%q\n' "${UNBOUND_ENABLED:-0}"
        printf 'UNBOUND_MODE=%q\n' "${UNBOUND_MODE:-recursive}"
        printf 'UNBOUND_ADBLOCK=%q\n' "${UNBOUND_ADBLOCK:-0}"
        printf 'UNBOUND_GATEWAY_IP=%q\n' "${UNBOUND_GATEWAY_IP:-}"
        printf 'UNBOUND_MANAGED_GATEWAY=%q\n' "${UNBOUND_MANAGED_GATEWAY:-0}"
        printf 'UNBOUND_VPN_ENABLED=%q\n' "${UNBOUND_VPN_ENABLED:-0}"
        printf 'UNBOUND_VPN_CIDRS=%q\n' "${UNBOUND_VPN_CIDRS:-10.0.0.0/24}"
        printf 'UNBOUND_FILTER_ENABLED=%q\n' "${UNBOUND_FILTER_ENABLED:-1}"
        printf 'UNBOUND_FILTER_URLS=%q\n' "${UNBOUND_FILTER_URLS:-$DNS_FILTER_URLS_DEFAULT}"
        printf 'UNBOUND_FILTER_MAX_DOMAINS=%q\n' "${UNBOUND_FILTER_MAX_DOMAINS:-$DNS_FILTER_MAX_DOMAINS_DEFAULT}"
        printf 'WARP_PROXY_PORT=%q\n' "${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
        printf 'WARP_PROXY_ENABLED=%q\n' "${WARP_PROXY_ENABLED:-0}"
        printf 'WARP_MODE=%q\n' "${WARP_MODE:-off}"
        printf 'WARP_PROTOCOL=%q\n' "${WARP_PROTOCOL:-auto}"
        printf 'WARP_SSH_ALLOW_CIDRS=%q\n' "${WARP_SSH_ALLOW_CIDRS:-}"
        printf 'XRAY_WARP_ENABLED=%q\n' "${XRAY_WARP_ENABLED:-${WARP_PROXY_ENABLED:-0}}"
        printf 'DEVICE_LIMIT_ENABLED=%q\n' "${DEVICE_LIMIT_ENABLED:-0}"
        printf 'DEVICE_LIMIT=%q\n' "${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}"
        printf 'DEVICE_WINDOW_HOURS=%q\n' "${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}"
        printf 'DEVICE_LIMIT_MODE=%q\n' "${DEVICE_LIMIT_MODE:-alert}"
        printf 'EXPIRED_DELETE_GRACE_DAYS=%q\n' "${EXPIRED_DELETE_GRACE_DAYS:-$EXPIRED_DELETE_GRACE_DAYS_DEFAULT}"
        printf 'XRAY_ENABLED=%q\n' "${XRAY_ENABLED:-0}"
        printf 'XRAY_FALLBACK_ENABLED=%q\n' "${XRAY_FALLBACK_ENABLED:-0}"
        printf 'XRAY_REALITY_PORT=%q\n' "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
        printf 'XRAY_REALITY_PUBLIC_PORT=%q\n' "${XRAY_REALITY_PUBLIC_PORT:-${XRAY_REALITY_PUBLIC_PORT_DEFAULT}}"
        printf 'XRAY_REALITY_SNI_MUX_ENABLED=%q\n' "${XRAY_REALITY_SNI_MUX_ENABLED:-0}"
        printf 'XRAY_MKCP_PORT=%q\n' "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}"
        printf 'XRAY_VISION_PORT=%q\n' "${XRAY_VISION_PORT:-$XRAY_VISION_PORT_DEFAULT}"
        printf 'XRAY_XHTTP_PORT=%q\n' "${XRAY_XHTTP_PORT:-$XRAY_XHTTP_PORT_DEFAULT}"
        printf 'XRAY_WS_PORT=%q\n' "${XRAY_WS_PORT:-$XRAY_WS_PORT_DEFAULT}"
        printf 'XRAY_HTTPUPGRADE_PORT=%q\n' "${XRAY_HTTPUPGRADE_PORT:-$XRAY_HTTPUPGRADE_PORT_DEFAULT}"
        printf 'XRAY_CADDY_FALLBACK_PORT=%q\n' "${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
        printf 'XRAY_REALITY_TARGET=%q\n' "${XRAY_REALITY_TARGET:-www.microsoft.com:443}"
        printf 'XRAY_REALITY_SERVER_NAME=%q\n' "${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}"
        printf '# Optional temporary Reality test profile with a separate SNI/target\n'
        printf 'XRAY_GITHUB_TEST_ENABLED=%q\n' "${XRAY_GITHUB_TEST_ENABLED:-0}"
        printf 'XRAY_GITHUB_TEST_USERS=%q\n' "${XRAY_GITHUB_TEST_USERS:-}"
        printf 'XRAY_GITHUB_TEST_PORT=%q\n' "${XRAY_GITHUB_TEST_PORT:-$XRAY_GITHUB_TEST_PORT_DEFAULT}"
        printf 'XRAY_GITHUB_TEST_TARGET=%q\n' "${XRAY_GITHUB_TEST_TARGET:-$XRAY_GITHUB_TEST_TARGET_DEFAULT}"
        printf 'XRAY_GITHUB_TEST_SERVER_NAME=%q\n' "${XRAY_GITHUB_TEST_SERVER_NAME:-$XRAY_GITHUB_TEST_SERVER_NAME_DEFAULT}"
        printf 'XRAY_REALITY_PRIVATE_KEY=%q\n' "${XRAY_REALITY_PRIVATE_KEY:-}"
        printf 'XRAY_REALITY_PUBLIC_KEY=%q\n' "${XRAY_REALITY_PUBLIC_KEY:-}"
        printf 'XRAY_REALITY_SHORT_ID=%q\n' "${XRAY_REALITY_SHORT_ID:-}"
        printf 'XRAY_TROJAN_PASSWORD=%q\n' "${XRAY_TROJAN_PASSWORD:-}"
        printf '# Legacy: zapret.dat blackhole routing disabled; kept only for safe migration/status\n'
        printf 'XRAY_ZAPRET_ENABLED=%q\n' "${XRAY_ZAPRET_ENABLED:-0}"
        printf 'XRAY_ZAPRET_DAT=%q\n' "${XRAY_ZAPRET_DAT:-$XRAY_ZAPRET_DAT_DEFAULT}"
        printf 'XRAY_ZAPRET_URL=%q\n' "${XRAY_ZAPRET_URL:-$XRAY_ZAPRET_URL_DEFAULT}"
        printf 'XCADDY_VERSION_PIN=%q\n' "${XCADDY_VERSION_PIN:-v0.4.6}"
        printf 'FORWARDPROXY_REF_PIN=%q\n' "${FORWARDPROXY_REF_PIN:-d62c80d3dd2c706b6b87579844d2397bddd18317}"
        printf 'XRAY_VERSION_PIN=%q\n' "${XRAY_VERSION_PIN:-v26.3.27}"
        printf 'HYSTERIA_VERSION_PIN=%q\n' "${HYSTERIA_VERSION_PIN:-app/v2.9.2}"
        printf 'BRIDGE_ENABLED=%q\n' "${BRIDGE_ENABLED:-0}"
        printf 'BRIDGE_NAME=%q\n' "${BRIDGE_NAME:-}"
        printf 'BRIDGE_ENTRY_PROTOCOL=%q\n' "${BRIDGE_ENTRY_PROTOCOL:-naive}"
        printf 'BRIDGE_EXIT_PROTOCOL=%q\n' "${BRIDGE_EXIT_PROTOCOL:-vless}"
        printf 'BRIDGE_EXIT_URI=%q\n' "${BRIDGE_EXIT_URI:-}"
        printf 'INSTALLED_AT=%q\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    } > "$tmp_config"; then
        rm -f "$tmp_config"
        err "Не удалось записать временный конфиг"
        return 1
    fi

    chown root:root "$tmp_config" 2>/dev/null || true
    chmod 600 "$tmp_config"
    if ! mv -f "$tmp_config" "$CONFIG_FILE"; then
        rm -f "$tmp_config"
        err "Не удалось обновить $CONFIG_FILE"
        return 1
    fi
}

# ─── Пользователи ────────────────────────────────────────────
load_users() {
    if [[ ! -f "$USERS_FILE" ]]; then
        mkdir -p "$CONFIG_DIR"
        echo "" > "$USERS_FILE"
        chmod 600 "$USERS_FILE"
    fi
}

get_users() {
    grep -v '^#\|^[[:space:]]*$' "$USERS_FILE" 2>/dev/null || true
}

get_active_users() {
    local user pass
    while IFS=: read -r user pass; do
        [[ -z "$user" || -z "$pass" ]] && continue
        if ! user_is_expired "$user"; then
            printf '%s:%s\n' "$user" "$pass"
        fi
    done < <(get_users)
}

get_user_pass() {
    local lookup_user="$1"
    while IFS=: read -r user pass; do
        [[ "$user" == "$lookup_user" ]] && { printf '%s\n' "$pass"; return 0; }
    done < <(get_users)
    return 1
}

get_active_user_pass() {
    local lookup_user="$1"
    if user_is_expired "$lookup_user"; then
        return 1
    fi
    get_user_pass "$lookup_user"
}

active_user_count() {
    get_active_users | wc -l
}

is_valid_user_months() {
    [[ "${1:-}" =~ ^([1-9]|1[0-2])$ ]]
}

is_valid_user_term() {
    [[ "${1:-}" =~ ^1d$ || "${1:-}" =~ ^([1-9]|1[0-2])m$ || "${1:-}" =~ ^([1-9]|1[0-2])$ ]]
}

normalize_user_term() {
    local term="${1:-}"
    case "$term" in
        1d|day|день) printf '1d' ;;
        1|2|3|4|5|6|7|8|9|10|11|12) printf '%sm\n' "$term" ;;
        1m|2m|3m|4m|5m|6m|7m|8m|9m|10m|11m|12m) printf '%s\n' "$term" ;;
        *) return 1 ;;
    esac
}

user_term_label() {
    local term
    term=$(normalize_user_term "${1:-}" 2>/dev/null || true)
    case "$term" in
        1d) printf '1 день' ;;
        1m) printf '1 месяц' ;;
        2m|3m|4m) printf '%s месяца' "${term%m}" ;;
        *m) printf '%s месяцев' "${term%m}" ;;
        *) printf '%s' "${1:-?}" ;;
    esac
}

user_meta_file() {
    local user="$1"
    printf '%s/%s.env\n' "$USER_META_DIR" "$user"
}

set_user_expiry_months() {
    local user="$1" months="$2" expires_at created_at meta_file
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный пользователь для срока: $user"
        return 1
    fi
    if ! is_valid_user_months "$months"; then
        err "Срок пользователя: только 1-12 месяцев"
        return 1
    fi
    mkdir -p "$USER_META_DIR"
    chmod 700 "$USER_META_DIR"
    created_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    expires_at=$(date -u -d "+${months} months" '+%Y-%m-%d' 2>/dev/null || true)
    if [[ ! "$expires_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        err "Не удалось рассчитать срок пользователя"
        return 1
    fi
    meta_file=$(user_meta_file "$user")
    {
        printf 'USER=%q\n' "$user"
        printf 'CREATED_AT=%q\n' "$created_at"
        printf 'TERM_MONTHS=%q\n' "$months"
        printf 'EXPIRES_AT=%q\n' "$expires_at"
    } > "$meta_file"
    chmod 600 "$meta_file"
}

set_user_expiry_extend_months() {
    local user="$1" months="$2" current today base expires_at
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный пользователь для продления: $user"
        return 1
    fi
    if ! is_valid_user_months "$months"; then
        err "Срок пользователя: только 1-12 месяцев"
        return 1
    fi
    today=$(date -u '+%Y-%m-%d')
    current=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ "$current" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && "$current" > "$today" ]]; then
        base="$current"
    else
        base="$today"
    fi
    expires_at=$(date -u -d "${base} +${months} months" '+%Y-%m-%d' 2>/dev/null || true)
    if [[ ! "$expires_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        err "Не удалось рассчитать срок продления"
        return 1
    fi
    user_meta_set "$user" TERM_MONTHS "$months" >/dev/null
    user_meta_set "$user" EXPIRES_AT "$expires_at" >/dev/null
    user_meta_set "$user" UPDATED_AT "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >/dev/null
}

set_user_expiry_extend_term() {
    local user="$1" raw_term="$2" term current today base expires_at months
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный пользователь для продления: $user"
        return 1
    fi
    term=$(normalize_user_term "$raw_term" 2>/dev/null || true)
    if ! is_valid_user_term "$term"; then
        err "Срок пользователя: 1 день или 1-12 месяцев"
        return 1
    fi
    today=$(date -u '+%Y-%m-%d')
    current=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ "$current" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && "$current" > "$today" ]]; then
        base="$current"
    else
        base="$today"
    fi
    case "$term" in
        1d)
            expires_at=$(date -u -d "${base} +1 day" '+%Y-%m-%d' 2>/dev/null || true)
            user_meta_set "$user" TERM_DAYS "1" >/dev/null
            user_meta_set "$user" TERM_MONTHS "" >/dev/null
            ;;
        *m)
            months="${term%m}"
            expires_at=$(date -u -d "${base} +${months} months" '+%Y-%m-%d' 2>/dev/null || true)
            user_meta_set "$user" TERM_MONTHS "$months" >/dev/null
            user_meta_set "$user" TERM_DAYS "" >/dev/null
            ;;
    esac
    if [[ ! "$expires_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        err "Не удалось рассчитать срок продления"
        return 1
    fi
    user_meta_set "$user" TERM "$term" >/dev/null
    user_meta_set "$user" EXPIRES_AT "$expires_at" >/dev/null
    user_meta_set "$user" UPDATED_AT "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >/dev/null
}

get_user_expiry() {
    local user="$1" meta_file expires
    if ! is_valid_proxy_user "$user"; then
        return 1
    fi
    meta_file=$(user_meta_file "$user")
    [[ -f "$meta_file" ]] || return 1
    expires=$(awk -F= '$1=="EXPIRES_AT"{gsub(/'\''|"|[[:space:]]/,"",$2); print $2; exit}' "$meta_file" 2>/dev/null || true)
    [[ "$expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1
    printf '%s\n' "$expires"
}

user_is_expired() {
    local user="$1" expires today
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    [[ -n "$expires" ]] || return 1
    today=$(date -u '+%Y-%m-%d')
    [[ "$expires" < "$today" ]]
}

user_expiry_label() {
    local user="$1" expires today
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ -z "$expires" ]]; then
        printf 'без срока'
        return
    fi
    today=$(date -u '+%Y-%m-%d')
    if [[ "$expires" < "$today" ]]; then
        printf 'истёк %s' "$expires"
    else
        printf 'до %s' "$expires"
    fi
}

user_expiry_tag() {
    local user="$1" expires
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ -z "$expires" ]]; then
        printf 'lifetime'
    else
        printf 'until-%s' "${expires//-/}"
    fi
}

user_expiry_epoch() {
    local user="$1" expires
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    [[ -n "$expires" ]] || return 1
    date -u -d "${expires} 23:59:59" '+%s' 2>/dev/null || return 1
}

user_expired_days() {
    local user="$1" expires today_ts expires_ts
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    [[ "$expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1
    today_ts=$(date -u -d "$(date -u '+%Y-%m-%d')" '+%s' 2>/dev/null || return 1)
    expires_ts=$(date -u -d "$expires" '+%s' 2>/dev/null || return 1)
    if [[ "$today_ts" -le "$expires_ts" ]]; then
        printf '0\n'
    else
        printf '%s\n' $(( (today_ts - expires_ts) / 86400 ))
    fi
}

prompt_user_term_months() {
    local default_months="${1:-12}" ans
    is_valid_user_months "$default_months" || default_months="12"
    if [[ -t 0 ]]; then
        # The function is often called inside command substitution, so keep the
        # prompt on stderr but read from the active stdin. Reading /dev/tty can
        # hang or hide the prompt in some provider serial consoles.
        printf "%b" "${CYAN}Срок пользователя 1-12 месяцев [${default_months}]: ${RESET}" >&2
        read -r ans || ans=""
    else
        ans="$default_months"
    fi
    ans="${ans:-$default_months}"
    if ! is_valid_user_months "$ans"; then
        err "Срок должен быть от 1 до 12 месяцев" >&2
        return 1
    fi
    printf '%s\n' "$ans"
}

cleanup_user_metadata() {
    local user="$1"
    is_valid_proxy_user "$user" || return 0
    rm -f -- "$(user_meta_file "$user")" 2>/dev/null || true
}

user_meta_get() {
    local user="$1" key="$2" meta_file
    is_valid_proxy_user "$user" || return 1
    [[ "$key" =~ ^[A-Z0-9_]+$ ]] || return 1
    meta_file=$(user_meta_file "$user")
    [[ -f "$meta_file" ]] || return 1
    awk -F= -v k="$key" '$1 == k {
        sub(/^[^=]*=/, "")
        gsub(/^'\''|'\''$/, "")
        gsub(/^"|"$/, "")
        print
        exit
    }' "$meta_file" 2>/dev/null || true
}

user_meta_set() {
    local user="$1" key="$2" value="$3" meta_file tmp
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный пользователь: $user"
        return 1
    fi
    if [[ ! "$key" =~ ^[A-Z0-9_]+$ ]]; then
        err "Некорректный ключ metadata: $key"
        return 1
    fi
    mkdir -p "$USER_META_DIR"
    chmod 700 "$USER_META_DIR"
    meta_file=$(user_meta_file "$user")
    tmp=$(mktemp)
    if [[ -f "$meta_file" ]]; then
        awk -F= -v k="$key" '$1 != k {print}' "$meta_file" > "$tmp"
    else
        : > "$tmp"
    fi
    if ! grep -q '^USER=' "$tmp" 2>/dev/null; then
        printf 'USER=%q\n' "$user" >> "$tmp"
    fi
    if ! grep -q '^CREATED_AT=' "$tmp" 2>/dev/null; then
        printf 'CREATED_AT=%q\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$tmp"
    fi
    printf '%s=%q\n' "$key" "$value" >> "$tmp"
    install -m 600 "$tmp" "$meta_file"
    rm -f "$tmp"
}

user_meta_unset() {
    local user="$1" key="$2" meta_file tmp
    is_valid_proxy_user "$user" || return 1
    [[ "$key" =~ ^[A-Z0-9_]+$ ]] || return 1
    meta_file=$(user_meta_file "$user")
    [[ -f "$meta_file" ]] || return 0
    tmp=$(mktemp)
    awk -F= -v k="$key" '$1 != k {print}' "$meta_file" > "$tmp"
    install -m 600 "$tmp" "$meta_file"
    rm -f "$tmp"
}

is_valid_tg_chat_id() {
    [[ "${1:-}" =~ ^-?[0-9]{5,20}$ ]]
}

tg_api_with_token() {
    local token="$1" method="$2"
    shift 2
    [[ -n "$token" && -n "$method" ]] || return 1

    local cfg rc
    cfg=$(mktemp /tmp/yurich_tg_api_XXXXXX) || return 1
    chmod 600 "$cfg" 2>/dev/null || true
    printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$token" "$method" > "$cfg"

    curl --config "$cfg" "$@"
    rc=$?
    rm -f "$cfg" 2>/dev/null || true
    return "$rc"
}

tg_api() {
    local method="$1"
    shift
    [[ -z "${TG_TOKEN:-}" ]] && return 1
    tg_api_with_token "$TG_TOKEN" "$method" "$@"
}

list_subscription_users() {
    {
        get_users | awk -F: '{print $1}'
        [[ -s "$XRAY_USERS_FILE" ]] && awk -F: '{print $1}' "$XRAY_USERS_FILE"
    } | awk 'NF && !seen[$0]++'
}

days_until_expiry() {
    local expires="$1" exp_ts today_ts
    [[ "$expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1
    exp_ts=$(date -u -d "$expires" '+%s' 2>/dev/null || true)
    today_ts=$(date -u -d "$(date -u '+%Y-%m-%d')" '+%s' 2>/dev/null || true)
    [[ -n "$exp_ts" && -n "$today_ts" ]] || return 1
    printf '%s\n' $(( (exp_ts - today_ts) / 86400 ))
}

expiry_days_text() {
    local days="${1:-0}"
    if (( days < 0 )); then
        printf 'срок уже истёк'
    elif (( days == 0 )); then
        printf 'сегодня последний день'
    elif (( days == 1 )); then
        printf 'остался 1 день'
    elif (( days >= 2 && days <= 4 )); then
        printf 'осталось %s дня' "$days"
    else
        printf 'осталось %s дней' "$days"
    fi
}

tg_send_to_chat() {
    local chat_id="$1" message="$2" resp
    [[ -z "${TG_TOKEN:-}" ]] && return 1
    is_valid_tg_chat_id "$chat_id" || return 1
    resp=$(tg_api "sendMessage" -s --max-time 12 --retry 2 --retry-delay 2 \
        -X POST \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true" \
        --data-urlencode "text=${message}" \
        2>/dev/null || true)
    echo "$resp" | grep -q '"ok":true'
}

sales_bot_renew_url() {
    local username resp
    if [[ -n "${SALES_BOT_PUBLIC_URL:-}" ]]; then
        printf '%s\n' "$SALES_BOT_PUBLIC_URL"
        return 0
    fi
    if [[ -n "${SALES_BOT_USERNAME:-}" ]]; then
        printf 'https://t.me/%s?start=renew\n' "${SALES_BOT_USERNAME#@}"
        return 0
    fi
    [[ -n "${SALES_BOT_TOKEN:-}" ]] || return 1
    resp=$(tg_api_with_token "$SALES_BOT_TOKEN" "getMe" -s --max-time 12 2>/dev/null || true)
    username=$(printf '%s\n' "$resp" | grep -o '"username":"[^"]*"' | head -1 | cut -d'"' -f4)
    [[ -n "$username" ]] || return 1
    printf 'https://t.me/%s?start=renew\n' "$username"
}

tg_send_to_chat_with_renew_button() {
    local chat_id="$1" message="$2" renew_url="$3" resp reply_markup
    [[ -z "${TG_TOKEN:-}" ]] && return 1
    is_valid_tg_chat_id "$chat_id" || return 1
    [[ -n "$renew_url" ]] || return 1
    reply_markup=$(printf '{"inline_keyboard":[[{"text":"Продлить подписку","url":"%s"}]]}' "$renew_url")
    resp=$(tg_api "sendMessage" -s --max-time 12 --retry 2 --retry-delay 2 \
        -X POST \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true" \
        --data-urlencode "text=${message}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        2>/dev/null || true)
    echo "$resp" | grep -q '"ok":true'
}

telegram_expiry_message() {
    local user="$1" expires="$2" days="$3" pretty safe_user safe_domain days_text
    pretty=$(profile_expiry_date_dmy "$expires")
    safe_user=$(html_escape_text "$user")
    safe_domain=$(html_escape_text "${DOMAIN:-Yurich Connect}")
    days_text=$(expiry_days_text "$days")
    cat <<EOF
🔔 <b>Yurich Connect</b>

Подписка скоро закончится.

👤 Профиль: <code>${safe_user}</code>
🌐 Сервер: <code>${safe_domain}</code>
📅 Активна до: <b>${pretty}</b>
⏳ <b>${days_text}</b>

Чтобы подключение не прерывалось, продли подписку заранее.
EOF
}

telegram_bind_message() {
    local user="$1" expires="$2" pretty safe_user safe_domain
    pretty=$(profile_expiry_date_dmy "$expires")
    safe_user=$(html_escape_text "$user")
    safe_domain=$(html_escape_text "${DOMAIN:-Yurich Connect}")
    cat <<EOF
✅ <b>Yurich Connect</b>

Уведомления подключены.

👤 Профиль: <code>${safe_user}</code>
🌐 Сервер: <code>${safe_domain}</code>
📅 Активна до: <b>${pretty:-без срока}</b>

Я напомню примерно за 5 дней до окончания подписки.
EOF
}

notify_user_expiry() {
    local user="$1" force="${2:-0}" expires days chat_id last_key notify_key message now_at renew_url
    if ! is_valid_proxy_user "$user"; then
        printf 'invalid_user\n'
        return 1
    fi
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ -z "$expires" ]]; then
        printf 'no_expiry\n'
        return 0
    fi
    days=$(days_until_expiry "$expires" 2>/dev/null || true)
    if [[ -z "$days" ]]; then
        printf 'bad_expiry\n'
        return 1
    fi
    chat_id=$(user_meta_get "$user" TELEGRAM_CHAT_ID 2>/dev/null || true)
    if [[ -z "$chat_id" ]]; then
        printf 'no_contact\n'
        return 0
    fi
    if ! is_valid_tg_chat_id "$chat_id"; then
        printf 'bad_contact\n'
        return 1
    fi
    if [[ "$force" != "1" && "$days" -gt 5 ]]; then
        printf 'not_due\n'
        return 0
    fi
    notify_key="${expires}:window5"
    last_key=$(user_meta_get "$user" LAST_EXPIRY_NOTIFY_KEY 2>/dev/null || true)
    if [[ "$force" != "1" && "$last_key" == "$notify_key" ]]; then
        printf 'already_sent\n'
        return 0
    fi
    message=$(telegram_expiry_message "$user" "$expires" "$days")
    renew_url=$(sales_bot_renew_url 2>/dev/null || true)
    if { [[ -n "$renew_url" ]] && tg_send_to_chat_with_renew_button "$chat_id" "$message" "$renew_url"; } || tg_send_to_chat "$chat_id" "$message"; then
        if [[ "$force" != "1" ]]; then
            now_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
            user_meta_set "$user" LAST_EXPIRY_NOTIFY_KEY "$notify_key" >/dev/null 2>&1 || true
            user_meta_set "$user" LAST_EXPIRY_NOTIFY_AT "$now_at" >/dev/null 2>&1 || true
        fi
        printf 'sent\n'
        return 0
    fi
    printf 'failed\n'
    return 1
}

cmd_notify_bind_tg() {
    local user="${1:-}" chat_id="${2:-}" expires message
    load_config; load_users
    if [[ -z "$user" || -z "$chat_id" ]]; then
        err "Использование: notify-bind-tg USER TELEGRAM_ID"
        return 1
    fi
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный пользователь: $user"
        return 1
    fi
    if ! subscription_user_exists "$user"; then
        err "Пользователь $user не найден"
        return 1
    fi
    if ! is_valid_tg_chat_id "$chat_id"; then
        err "Некорректный Telegram ID"
        return 1
    fi
    user_meta_set "$user" TELEGRAM_CHAT_ID "$chat_id"
    ok "Telegram уведомления привязаны к пользователю $user"
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ -n "${TG_TOKEN:-}" && -n "$expires" ]]; then
        message=$(telegram_bind_message "$user" "$expires")
        if tg_send_to_chat "$chat_id" "$message"; then
            ok "Проверочное сообщение отправлено"
        else
            warn "Не удалось отправить проверочное сообщение. Пользователь должен открыть бота и нажать Start."
        fi
    fi
}

cmd_notify_unbind_tg() {
    local user="${1:-}"
    load_config; load_users
    if [[ -z "$user" ]]; then
        err "Использование: notify-unbind-tg USER"
        return 1
    fi
    user_meta_unset "$user" TELEGRAM_CHAT_ID
    ok "Telegram уведомления отключены для $user"
}

cmd_notify_expiry_list() {
    local user expires days chat status pretty
    load_config; load_users
    printf '%-24s %-12s %-10s %s\n' "USER" "EXPIRES" "DAYS" "TELEGRAM"
    printf '%-24s %-12s %-10s %s\n' "----" "-------" "----" "--------"
    while IFS= read -r user; do
        [[ -z "$user" ]] && continue
        expires=$(get_user_expiry "$user" 2>/dev/null || true)
        [[ -z "$expires" ]] && expires="без срока"
        if [[ "$expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            days=$(days_until_expiry "$expires" 2>/dev/null || echo "-")
            pretty=$(profile_expiry_date_dmy "$expires")
        else
            days="-"
            pretty="$expires"
        fi
        chat=$(user_meta_get "$user" TELEGRAM_CHAT_ID 2>/dev/null || true)
        if [[ -n "$chat" ]]; then
            status="ok"
        else
            status="нет id"
        fi
        printf '%-24s %-12s %-10s %s\n' "$user" "$pretty" "$days" "$status"
    done < <(list_subscription_users)
}

cmd_notify_expiry_run() {
    local user status total=0 sent=0 no_contact=0 skipped=0 failed=0
    load_config; load_users
    while IFS= read -r user; do
        [[ -z "$user" ]] && continue
        total=$((total+1))
        if ! status=$(notify_user_expiry "$user" 0 2>/dev/null); then
            status="${status:-failed}"
        fi
        status=$(printf '%s\n' "$status" | tail -n1)
        case "$status" in
            sent) sent=$((sent+1)) ;;
            no_contact) no_contact=$((no_contact+1)) ;;
            failed|bad_contact|bad_expiry|invalid_user) failed=$((failed+1)) ;;
            *) skipped=$((skipped+1)) ;;
        esac
    done < <(list_subscription_users)
    cmd_enforce_expired_users || failed=$((failed+1))
    printf 'expiry notify: total=%s sent=%s no_contact=%s skipped=%s failed=%s\n' "$total" "$sent" "$no_contact" "$skipped" "$failed"
    [[ "$failed" -eq 0 ]]
}

cmd_enforce_expired_users() {
    local user expired=0 deleted=0 kept=0 failed=0 days grace
    load_config; load_users
    grace="${EXPIRED_DELETE_GRACE_DAYS:-$EXPIRED_DELETE_GRACE_DAYS_DEFAULT}"
    if ! [[ "$grace" =~ ^[0-9]+$ ]]; then grace="$EXPIRED_DELETE_GRACE_DAYS_DEFAULT"; fi

    while IFS= read -r user; do
        [[ -z "$user" ]] && continue
        if user_is_expired "$user"; then
            expired=$((expired + 1))
            days=$(user_expired_days "$user" 2>/dev/null || echo 0)
            if [[ "$days" -ge "$grace" ]]; then
                if delete_subscription_user_everywhere "$user" >/dev/null 2>&1; then
                    deleted=$((deleted + 1))
                else
                    failed=$((failed + 1))
                fi
            else
                kept=$((kept + 1))
            fi
        fi
    done < <(list_subscription_users)

    if [[ "$expired" -lt 1 ]]; then
        printf 'expiry enforce: expired=0\n'
        return 0
    fi

    if [[ -x "$CADDY_BIN" && -f "$CADDYFILE" ]]; then
        safe_apply_caddy_current >/dev/null 2>&1 || warn "Не удалось применить Caddy после истечения подписок"
    fi
    sync_hysteria_users_if_active >/dev/null 2>&1 || true
    if [[ -x "$XRAY_BIN" && -s "$XRAY_USERS_FILE" ]]; then
        cmd_xray_rebuild >/dev/null 2>&1 || warn "Не удалось пересобрать Xray после истечения подписок"
    fi
    printf 'expiry enforce: expired=%s kept=%s deleted=%s grace_days=%s failed=%s\n' "$expired" "$kept" "$deleted" "$grace" "$failed"
    [[ "$failed" -eq 0 ]]
}

cmd_notify_expiry_test() {
    local user="${1:-}" status
    load_config; load_users
    if [[ -z "$user" ]]; then
        err "Использование: notify-expiry-test USER"
        return 1
    fi
    if ! status=$(notify_user_expiry "$user" 1 2>/dev/null); then
        status="${status:-failed}"
    fi
    status=$(printf '%s\n' "$status" | tail -n1)
    if [[ "$status" == "sent" ]]; then
        ok "Тестовое уведомление отправлено пользователю $user"
    else
        err "Тестовое уведомление не отправлено: $status"
        return 1
    fi
}

telegram_news_message() {
    local body="$1" safe_body safe_domain
    body="${body//$'\r'/}"
    safe_body=$(html_escape_text "$body")
    safe_domain=$(html_escape_text "${DOMAIN:-Yurich Connect}")
    cat <<EOF
🔔 <b>Yurich Connect</b>

${safe_body}

🌐 Сервис: <code>${safe_domain}</code>
💬 По вопросам напиши Ивану Юрьевичу.
EOF
}

cmd_notify_news_test() {
    local body="${1:-}" target_chat_id="${2:-${TG_CHAT_ID:-}}" message
    load_config
    if [[ -z "$body" ]]; then
        err "Использование: notify-news-test ТЕКСТ"
        return 1
    fi
    if ! is_valid_tg_chat_id "$target_chat_id"; then
        err "Некорректный Telegram ID для теста"
        return 1
    fi
    message=$(telegram_news_message "$body")
    if tg_send_to_chat "$target_chat_id" "$message"; then
        ok "Тестовая новость отправлена"
        return 0
    fi
    err "Тестовая новость не отправлена. Проверь, что админ открыл бота и нажал Start."
    return 1
}

cmd_notify_news_broadcast() {
    local body="${1:-}" user chat_id message seen_file total=0 contacts=0 sent=0 failed=0 skipped=0 duplicate=0 bad=0
    load_config; load_users
    if [[ -z "$body" ]]; then
        err "Использование: notify-news ТЕКСТ"
        return 1
    fi
    message=$(telegram_news_message "$body")
    seen_file=$(mktemp)
    chmod 600 "$seen_file" 2>/dev/null || true
    while IFS= read -r user; do
        [[ -z "$user" ]] && continue
        total=$((total + 1))
        chat_id=$(user_meta_get "$user" TELEGRAM_CHAT_ID 2>/dev/null || true)
        if [[ -z "$chat_id" ]]; then
            skipped=$((skipped + 1))
            continue
        fi
        if ! is_valid_tg_chat_id "$chat_id"; then
            bad=$((bad + 1))
            continue
        fi
        if grep -Fxq -- "$chat_id" "$seen_file" 2>/dev/null; then
            duplicate=$((duplicate + 1))
            continue
        fi
        printf '%s\n' "$chat_id" >> "$seen_file"
        contacts=$((contacts + 1))
        if tg_send_to_chat "$chat_id" "$message"; then
            sent=$((sent + 1))
        else
            failed=$((failed + 1))
        fi
        sleep 0.25
    done < <(list_subscription_users)
    rm -f "$seen_file"
    printf 'news broadcast: users=%s contacts=%s sent=%s no_contact=%s duplicate=%s bad_contact=%s failed=%s\n' \
        "$total" "$contacts" "$sent" "$skipped" "$duplicate" "$bad" "$failed"
    [[ "$failed" -eq 0 && "$sent" -gt 0 ]]
}

cmd_notify_expiry_install() {
    local script_path="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}"
    load_config; load_users
    mkdir -p "$(dirname "$EXPIRY_NOTIFY_CRON")" "$(dirname "$EXPIRY_NOTIFY_LOG")"
    cat > "$EXPIRY_NOTIFY_CRON" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
17 10 * * * root /bin/bash ${script_path} notify-expiry-run >> ${EXPIRY_NOTIFY_LOG} 2>&1
EOF
    chmod 644 "$EXPIRY_NOTIFY_CRON"
    touch "$EXPIRY_NOTIFY_LOG"
    chmod 600 "$EXPIRY_NOTIFY_LOG"
    ok "Ежедневные Telegram-уведомления включены: $EXPIRY_NOTIFY_CRON"
}

# ─── Telegram ────────────────────────────────────────────────
tg_send() {
    local message="$1"
    [[ -z "${TG_TOKEN:-}" || -z "${TG_CHAT_ID:-}" ]] && return 0
    # Используем --data-urlencode для безопасной передачи спецсимволов
    tg_api "sendMessage" -s --max-time 10 --retry 2 --retry-delay 3 \
        -X POST \
        --data-urlencode "chat_id=${TG_CHAT_ID}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "text=${message}" \
        >/dev/null 2>&1 || true
}

tg_alert_up() {
    tg_send "✅ <b>Yurich Panel запущен</b>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')
📡 Сервер: $(hostname)"
}

tg_alert_down() {
    tg_send "🔴 <b>Yurich Panel упал!</b>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')
📡 Сервер: $(hostname)
⚠️ Требуется вмешательство!"
}

tg_alert_updated() {
    local old_ver="$1" new_ver="$2"
    tg_send "🔄 <b>Caddy обновлён</b>
📦 Было: <code>${old_ver}</code>
📦 Стало: <code>${new_ver}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
}

tg_send_stats() {
    if ! check_installed; then
        tg_send "❌ Yurich Panel не установлен"
        return
    fi

    local status="🔴 Остановлен"
    systemctl is-active --quiet caddy 2>/dev/null && status="🟢 Работает"

    local uptime_str
    uptime_str=$(systemctl show caddy --property=ActiveEnterTimestamp 2>/dev/null \
        | cut -d= -f2 | xargs -I{} date -d "{}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "н/д")

    local caddy_ver
    caddy_ver=$("$CADDY_BIN" version 2>/dev/null | head -1 | awk '{print $1}' || echo "н/д")

    local iface rx tx
    iface=$(ip route | awk '/default/{print $5}' | head -1)
    rx=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)
    tx=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null || echo 0)
    rx=$(numfmt --to=iec "$rx" 2>/dev/null || echo "н/д")
    tx=$(numfmt --to=iec "$tx" 2>/dev/null || echo "н/д")

    local users_count
    users_count=$(get_users | wc -l)

    tg_send "📊 <b>Статистика Yurich Panel</b>

🌐 Домен: <code>${DOMAIN:-н/д}</code>
📡 Статус: ${status}
🕐 Запущен: ${uptime_str}
📦 Caddy: <code>${caddy_ver}</code>
👥 Пользователей: ${users_count}

📈 <b>Трафик (с ребута):</b>
⬇️ Входящий: <code>${rx}</code>
⬆️ Исходящий: <code>${tx}</code>

🖥 Сервер: <code>$(hostname)</code>
💾 RAM: $(free -h | awk '/Mem:/{print $3"/"$2}')
💿 Диск: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')

🔐 <b>Сертификат:</b>
$(
cert_days=""
cert_info=$(echo | timeout 5 openssl s_client -connect "${DOMAIN:-localhost}:443" -servername "${DOMAIN:-localhost}" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "")
if [[ -n "$cert_info" ]]; then
    not_after=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
    expire_ts=$(date -d "$not_after" +%s 2>/dev/null || echo 0)
    now_ts=$(date +%s)
    cert_days=$(( (expire_ts - now_ts) / 86400 ))
    echo "📅 Истекает: ${not_after}"
    echo "⏳ Осталось: ${cert_days} дней"
else
    echo "N/A"
fi
)"
}

# ─── Настройка Telegram ───────────────────────────────────────
setup_telegram() {
    hr
    echo -e "${BOLD}  Настройка Telegram-бота${RESET}"
    hr
    echo
    info "Нужен токен бота и твой chat_id."
    info "Создать бота: @BotFather → /newbot"
    info "Узнать chat_id: напиши боту @userinfobot"
    echo

    echo -ne "${CYAN}Bot Token (Enter чтобы пропустить): ${RESET}"
    read -r input_token
    [[ -z "$input_token" ]] && { warn "Telegram пропущен"; return; }

    echo -ne "${CYAN}Chat ID: ${RESET}"
    read -r input_chat_id
    [[ -z "$input_chat_id" ]] && { warn "Telegram пропущен"; return; }

    info "Проверяю токен..."
    local response
        response=$(tg_api_with_token "$input_token" "getMe" -s 2>/dev/null || echo "{}")
    if echo "$response" | grep -q '"ok":true'; then
        local bot_name
        bot_name=$(echo "$response" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        ok "Бот найден: @${bot_name}"
    else
        err "Токен неверный или бот недоступен"
        return
    fi

    TG_TOKEN="$input_token"
    TG_CHAT_ID="$input_chat_id"
    save_config
    tg_apply_bot_menu || warn "Команды Telegram Menu можно применить позже: sudo bash yurich-panel.sh bot-menu"

    tg_send "🤖 <b>Yurich Panel подключён!</b>
✅ Telegram-уведомления настроены
📡 Сервер: <code>$(hostname)</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<b>Доступные команды в скрипте:</b>
• статус — bash yurich-panel.sh tg-stats
• мониторинг — каждые 5 минут автоматически"
    ok "Тестовое сообщение отправлено"

    echo
    warn "Чтобы бот отвечал на /start, /menu и кнопки, нужен systemd сервис naiveproxy-bot."
    echo -ne "${YELLOW}Установить и запустить Telegram bot service сейчас? [Y/n]: ${RESET}"
    read -r bot_service_answer
    if [[ ! "${bot_service_answer}" =~ ^[Nn]$ ]]; then
        install_bot_service
    else
        warn "Бот-меню применено, но ответы на /menu заработают после: sudo bash ${SCRIPT_PATH} bot-install"
    fi
}

# ─── Watchdog (cron) ─────────────────────────────────────────
install_monitor() {
    cat > "$MONITOR_SCRIPT" <<'MONITOR'
#!/bin/bash
CONFIG_FILE="/etc/naiveproxy/naive.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    _owner=$(stat -c '%U' "$CONFIG_FILE" 2>/dev/null || echo "unknown")
    _perms=$(stat -c '%a' "$CONFIG_FILE" 2>/dev/null || echo "000")
    [[ "$_owner" == "root" && "$_perms" == "600" ]] && source "$CONFIG_FILE"
fi

tg_api() {
    local method="$1"
    shift
    [[ -z "${TG_TOKEN:-}" || -z "$method" ]] && return 1
    local cfg rc
    cfg=$(mktemp /tmp/yurich_tg_api_XXXXXX) || return 1
    chmod 600 "$cfg" 2>/dev/null || true
    printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$TG_TOKEN" "$method" > "$cfg"
    curl --config "$cfg" "$@"
    rc=$?
    rm -f "$cfg" 2>/dev/null || true
    return "$rc"
}

tg_send() {
    local msg="$1"
    [[ -z "${TG_TOKEN:-}" || -z "${TG_CHAT_ID:-}" ]] && return
    tg_api "sendMessage" -s --max-time 10 --retry 2 \
        -X POST \
        --data-urlencode "chat_id=${TG_CHAT_ID}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "text=${msg}" \
        >/dev/null 2>&1 || true
}

FLAG="/run/naiveproxy_was_down"

if ! systemctl is-active --quiet caddy 2>/dev/null; then
    if [[ ! -f "$FLAG" ]]; then
        touch "$FLAG"
        tg_send "🔴 <b>Yurich Panel упал!</b>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')
🔄 Пытаюсь перезапустить..."
        systemctl restart caddy 2>/dev/null || true
        sleep 5
        if systemctl is-active --quiet caddy; then
            tg_send "✅ <b>Перезапущен успешно</b>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
            rm -f "$FLAG"
        else
            tg_send "❌ <b>Перезапуск не помог!</b> Нужно ручное вмешательство."
        fi
    fi
else
    rm -f "$FLAG"
fi
MONITOR

    chmod +x "$MONITOR_SCRIPT"

    local script_path
    # Если запущен через bash <(curl), $0 будет /dev/fd/xx — используем фиксированный путь
    script_path=$(realpath "$0" 2>/dev/null || echo "")
    if [[ -z "$script_path" || "$script_path" == /dev/fd/* || "$script_path" == /proc/* ]]; then
        script_path="${SCRIPT_PATH}"
        # Копируем себя в постоянное место если ещё не там
        [[ -f "$script_path" ]] || cp "$0" "$script_path" 2>/dev/null || true
        [[ -f "$script_path" ]] && chmod +x "$script_path"
    fi

    # Очищаем старые naive-cron записи, добавляем новые
    ( crontab -l 2>/dev/null | grep -v "naiveproxy\|monitor\.sh" || true
      echo "*/5 * * * * /bin/bash $MONITOR_SCRIPT"
      echo "0 3 * * 0 /bin/bash ${script_path} update >> ${LOG_DIR}/autoupdate.log 2>&1"
    ) | crontab -

    ok "Watchdog: каждые 5 минут"
    ok "Автообновление Caddy: воскресенье 3:00"
}

# ─── Проверка домена ─────────────────────────────────────────
check_domain() {
    local domain="$1"
    info "Проверяю DNS для $domain..."

    local server_ip domain_ip public_domain_ip hosts_overrides hosts_domains ans
    server_ip=$(curl -s4 --max-time 5 https://ifconfig.me 2>/dev/null         || curl -s4 --max-time 5 https://api.ipify.org 2>/dev/null         || curl -s4 --max-time 5 https://checkip.amazonaws.com 2>/dev/null         || echo "")
    public_domain_ip=$(public_dns_ipv4 "$domain")
    domain_ip=$(getent ahostsv4 "$domain" 2>/dev/null | awk '{print $1; exit}' || echo "")
    [[ -n "$domain_ip" ]] || domain_ip=$(getent hosts "$domain" 2>/dev/null | awk '$1 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ {print $1; exit}' || echo "")
    [[ -n "$domain_ip" ]] || domain_ip="$public_domain_ip"

    hosts_overrides=$(hosts_public_domain_overrides | awk -F'|' -v d="${domain,,}" '$1 == d {print}' | head -5 || true)
    if [[ -n "$hosts_overrides" ]]; then
        hosts_domains=$(printf '%s\n' "$hosts_overrides" | format_hosts_override_domains)
        warn "/etc/hosts содержит публичный домен (${hosts_domains}). Это может ломать TLS/SNI и проверки между серверами."
    fi

    if [[ -z "$domain_ip" ]]; then
        err "Домен $domain не резолвится. Проверь DNS."
        exit 1
    fi

    if [[ -n "$public_domain_ip" ]]; then
        domain_ip="$public_domain_ip"
    fi

    if [[ -n "$server_ip" && "$server_ip" != "$domain_ip" ]]; then
        warn "IP сервера: $server_ip  |  IP домена: $domain_ip"
        warn "Не совпадают! Let's Encrypt может отказать в сертификате."
        echo -ne "${YELLOW}Продолжить всё равно? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || exit 1
    elif [[ -z "$server_ip" ]]; then
        warn "Не смог определить публичный IPv4 сервера, DNS домена: $domain_ip"
    else
        ok "DNS OK: $domain → $domain_ip"
    fi
}

# ─── Зависимости ─────────────────────────────────────────────
install_deps() {
    info "Обновляю пакеты и ставлю зависимости..."
    apt-get update -qq
    apt-get install -y -qq curl wget unzip tar ufw openssl dnsutils 2>/dev/null || true

    export PATH="/usr/local/go/bin:$PATH"
    local go_ver go_major go_minor
    go_ver=$(go version 2>/dev/null | grep -oP 'go\K[\d.]+' || echo "0.0")
    go_major=$(echo "$go_ver" | cut -d. -f1)
    go_minor=$(echo "$go_ver" | cut -d. -f2)

    if [[ "$go_major" -lt 1 ]] || [[ "$go_major" -eq 1 && "$go_minor" -lt 21 ]]; then
        warn "Go $go_ver устарел, ставлю свежий..."
        local arch
        arch=$(dpkg --print-architecture)
        [[ "$arch" == "arm64" ]] || arch="amd64"
        local go_ver_pin="1.22.4"
        local go_url="https://go.dev/dl/go${go_ver_pin}.linux-${arch}.tar.gz"
        local go_sha256_amd64="ba79d4526102575196273416239cca418a651e049c2b099f3159db85e7bade7d"
        local go_sha256_arm64="a8e177c354d2e4a1b61020aca3c6f61bfba9a2e8f52c8dcef2b87abe86bd8fc0"
        local expected_sha go_tmp
        [[ "$arch" == "arm64" ]] && expected_sha="$go_sha256_arm64" || expected_sha="$go_sha256_amd64"

        go_tmp=$(mktemp /tmp/go_XXXXXX.tar.gz)
        if ! wget -q "$go_url" -O "$go_tmp"; then
            rm -f "$go_tmp"
            err "Не удалось скачать Go: $go_url"
            exit 1
        fi
        local actual_sha
        actual_sha=$(sha256sum "$go_tmp" | awk '{print $1}')
        if [[ "$actual_sha" != "$expected_sha" ]]; then
            err "SHA256 Go не совпадает! Возможная атака на цепочку поставок. Прерываю."
            rm -f "$go_tmp"
            exit 1
        fi
        ok "SHA256 Go подтверждён"
        rm -rf /usr/local/go
        tar -C /usr/local -xzf "$go_tmp"
        rm -f "$go_tmp"
        printf 'export PATH="/usr/local/go/bin:$PATH"\n' > /etc/profile.d/go.sh
    fi

    export PATH="/usr/local/go/bin:$PATH"
    ok "Зависимости готовы"
}

# ─── Сборка Caddy ────────────────────────────────────────────
build_caddy() {
    info "Собираю Caddy с forwardproxy (naive)..."
    info "Занимает 5-15 минут, не прерывай..."
    local output_bin="${1:-$CADDY_BIN}"

    export PATH="/usr/local/go/bin:$PATH"
    export GOPATH="/root/go"
    export GOCACHE="/root/.cache/go-build"

    # Ставим git если нет
    command -v git &>/dev/null || apt-get install -y -q git

    info "Ставлю xcaddy ${XCADDY_VERSION_PIN:-v0.4.6}..."
    go install "github.com/caddyserver/xcaddy/cmd/xcaddy@${XCADDY_VERSION_PIN:-v0.4.6}"

    # Клонируем naive ветку напрямую — единственный надёжный способ
    local fp_dir
    fp_dir=$(mktemp -d /tmp/naiveproxy_forwardproxy_XXXXXX)
    trap 'rm -rf "${fp_dir:-}" 2>/dev/null' RETURN
    info "Клонирую klzgrad/forwardproxy@${FORWARDPROXY_REF_PIN:-naive}..."
    if ! git clone -b naive --depth 1         https://github.com/klzgrad/forwardproxy.git "$fp_dir" 2>/dev/null; then
        err "Не удалось клонировать forwardproxy. Проверь интернет."
        exit 1
    fi
    if [[ "${FORWARDPROXY_REF_PIN:-naive}" != "naive" ]]; then
        local current_fp_commit
        current_fp_commit=$(git -C "$fp_dir" rev-parse HEAD 2>/dev/null || true)
        if [[ "$current_fp_commit" == "${FORWARDPROXY_REF_PIN}" ]]; then
            git -C "$fp_dir" checkout --detach HEAD >/dev/null 2>&1 || true
        elif ! git -C "$fp_dir" fetch --depth 1 origin "${FORWARDPROXY_REF_PIN}" >/dev/null 2>&1 \
            || ! git -C "$fp_dir" checkout --detach FETCH_HEAD >/dev/null 2>&1; then
            err "Не удалось закрепить forwardproxy на ${FORWARDPROXY_REF_PIN}"
            return 1
        fi
    fi
    info "Forwardproxy ref: $(git -C "$fp_dir" rev-parse --short HEAD 2>/dev/null || echo unknown)"

    # Читаем точную версию Caddy из go.mod forwardproxy
    local caddy_ver
    caddy_ver=$(grep 'github.com/caddyserver/caddy/v2 ' "$fp_dir/go.mod"         | awk '{print $2}' | head -1)
    info "Forwardproxy требует Caddy: $caddy_ver"

    # Собираем именно эту версию Caddy с локальным forwardproxy
    "$GOPATH/bin/xcaddy" build "${caddy_ver}" \
        --with github.com/caddyserver/forwardproxy="$fp_dir" \
        --output "$output_bin"

    chmod +x "$output_bin"

    # Проверяем наличие naive padding в бинарнике
    if command -v strings &>/dev/null; then
        local _pc
        _pc=$(strings "$output_bin" 2>/dev/null | grep -cE "^(Padding|SetPadding|WithPadding)$" || true)
        _pc="${_pc//[^0-9]/}"; _pc="${_pc:-0}"
        if [[ "${_pc}" -ge 2 ]]; then
            ok "Naive padding модуль подтверждён ✓"
        else
            warn "Padding не найден — возможна проблема совместимости"
        fi
    fi

    ok "Caddy собран: $("$output_bin" version 2>/dev/null | head -1)"
}


# ── Мультидомен: генерация Caddyfile ─────────────────────────
write_caddyfile_multi() {
    mkdir -p "$CADDY_DIR" "$WEBROOT" "$LOG_DIR"

    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        warn "Xray fallback hub включён: мультидомен Caddy отключён, Caddy будет локальным fallback."
        write_caddyfile
        return $?
    fi

    install_camouflage_page

    # Собираем auth блоки
    local auth_blocks=""
    local auth_count=0
    while IFS=: read -r u p; do
        [[ -z "$u" ]] && continue
        if ! is_valid_proxy_user "$u" || ! is_valid_proxy_pass "$p"; then
            err "Небезопасная запись пользователя в $USERS_FILE: $u"
            err "Логин: 2-32 символа [A-Za-z0-9_-], пароль: 8-64 символа [A-Za-z0-9_-]"
            return 1
        fi
        auth_blocks+="        basic_auth ${u} ${p}"$'\n'
        auth_count=$((auth_count+1))
    done < <(get_active_users)
    if [[ "$auth_count" -lt 1 ]]; then
        local disabled_pass
        disabled_pass=$(random_safe_token 32)
        auth_blocks+="        basic_auth __disabled__ ${disabled_pass}"$'\n'
        auth_count=1
        warn "Нет активных пользователей. Caddy proxy закрыт placeholder-auth."
    fi
    local caddy_upstream=""
    if [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]]; then
        caddy_upstream="    upstream socks5://127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"$'\n'
    fi
    local caddy_protocols="h1 h2"
    if [[ "${HYSTERIA_PORT:-8443}" == "443" ]]; then
        caddy_protocols="h1 h2"
    fi

    # Глобальный блок
    cat > "$CADDYFILE" <<EOF
{
  order forward_proxy before file_server
  servers :443 {
      protocols ${caddy_protocols}
  }
  log {
    output file ${LOG_DIR}/access.log {
      roll_size 50mb
      roll_keep 3
    }
  }
}

EOF

    # Блок для каждого домена
    local domains_list
    IFS=',' read -ra domains_list <<< "${DOMAINS:-${DOMAIN:-}}"

    for dom in "${domains_list[@]}"; do
        dom="${dom// /}"  # убираем пробелы
        [[ -z "$dom" ]] && continue
        if ! is_valid_domain "$dom"; then
            err "Неверный домен в конфиге: $dom"
            return 1
        fi
        cat >> "$CADDYFILE" <<EOF
${dom}:443 {
    tls ${EMAIL}

  forward_proxy {
${auth_blocks}${caddy_upstream}    hide_ip
    hide_via
    probe_resistance
  }

  header /s/* {
    X-Robots-Tag "noindex, nofollow, noarchive"
    Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
    Profile-Title "Yurich Connect"
    profile-update-interval "12"
    support-url "${TELEGRAM_COMMUNITY_URL}"
    Referrer-Policy "no-referrer"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
    Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), serial=(), usb=()"
    Content-Security-Policy "default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests"
  }

  header /p/* {
    X-Robots-Tag "noindex, nofollow, noarchive"
    Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
    Referrer-Policy "no-referrer"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
    Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), serial=(), usb=()"
    Content-Security-Policy "default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests"
  }

  file_server {
    root ${WEBROOT}
  }

    log {
        output file ${LOG_DIR}/naive_${dom//./_}.log {
            roll_size 20mb
            roll_keep 5
        }
    }
}

EOF
    done

    chmod 600 "$CADDYFILE"
    if [[ -x "$CADDY_BIN" ]]; then
        "$CADDY_BIN" fmt --overwrite "$CADDYFILE" >/dev/null 2>&1 || true
        "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1 || {
            err "Сгенерированный Caddyfile не прошёл validate"
            "$CADDY_BIN" validate --config "$CADDYFILE" || true
            return 1
        }
    fi
    local dom_count
    dom_count=$(echo "${DOMAINS:-${DOMAIN:-}}" | tr ',' '\n' | grep -c '[a-z]' || echo 1)
    ok "Caddyfile обновлён (доменов: ${dom_count}, активных пользователей: $(active_user_count))"
}


# ─── КАМУФЛЯЖНАЯ СТРАНИЦА ────────────────────────────────────────
install_camouflage_page() {
    mkdir -p "$WEBROOT"

    cat > "$WEBROOT/index.html" << 'CAMOUFLAGE_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="Yurich Panel — Technical notes on Linux, networking, security and open source infrastructure.">
<title>Yurich Panel — Linux & Infrastructure Notes</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&family=Syne:wght@400;600;800&display=swap" rel="stylesheet">
<style>
:root{--bg:#080B0F;--bg2:#0D1117;--bg3:#161B22;--border:#21262D;--gold:#D4A017;--gold2:#F0C040;--text:#E6EDF3;--text-dim:#7D8590;--text-muted:#484F58;--green:#3FB950;--blue:#58A6FF;--red:#F85149;--tag-bg:#1F2937}
*{margin:0;padding:0;box-sizing:border-box}html{scroll-behavior:smooth}
body{background:var(--bg);color:var(--text);font-family:'Syne',sans-serif;font-size:16px;line-height:1.6;min-height:100vh}
body::before{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,0,0,.03) 2px,rgba(0,0,0,.03) 4px);pointer-events:none;z-index:9999}
code,pre,.mono{font-family:'JetBrains Mono',monospace}
a{color:var(--blue);text-decoration:none}a:hover{color:var(--gold2)}
header{border-bottom:1px solid var(--border);background:var(--bg2);position:sticky;top:0;z-index:100;backdrop-filter:blur(8px)}
.header-inner{max-width:1100px;margin:0 auto;padding:0 24px;height:60px;display:flex;align-items:center;justify-content:space-between}
.logo{display:flex;align-items:center;gap:10px;text-decoration:none}
.logo-icon{width:32px;height:32px;background:var(--gold);border-radius:6px;display:flex;align-items:center;justify-content:center;font-family:'JetBrains Mono',monospace;font-weight:700;font-size:14px;color:#000}
.logo-text{font-size:18px;font-weight:800;color:var(--text);letter-spacing:-.5px}
.logo-text span{color:var(--gold)}
nav{display:flex;gap:28px;align-items:center}
nav a{font-size:14px;font-weight:600;color:var(--text-dim);letter-spacing:.3px;transition:color .2s}
nav a:hover{color:var(--text)}
.nav-rss{display:flex;align-items:center;gap:6px;padding:6px 14px;border:1px solid var(--border);border-radius:6px;font-size:13px;color:var(--text-dim)!important;transition:border-color .2s,color .2s!important}
.nav-rss:hover{border-color:var(--gold)!important;color:var(--gold)!important}
.hero{border-bottom:1px solid var(--border);padding:64px 24px 48px;position:relative;overflow:hidden}
.hero::after{content:'';position:absolute;top:-80px;right:-80px;width:400px;height:400px;background:radial-gradient(circle,rgba(212,160,23,.06) 0%,transparent 70%);pointer-events:none}
.hero-inner{max-width:1100px;margin:0 auto}
.hero-eyebrow{display:inline-flex;align-items:center;gap:8px;font-family:'JetBrains Mono',monospace;font-size:12px;color:var(--gold);margin-bottom:20px;letter-spacing:1px}
.hero-eyebrow::before{content:'';display:inline-block;width:24px;height:1px;background:var(--gold)}
.hero h1{font-size:clamp(32px,5vw,52px);font-weight:800;line-height:1.1;letter-spacing:-1.5px;max-width:700px;margin-bottom:20px}
.hero h1 em{font-style:normal;color:var(--gold)}
.hero p{font-size:17px;color:var(--text-dim);max-width:540px;line-height:1.7}
.main{max-width:1100px;margin:0 auto;padding:48px 24px;display:grid;grid-template-columns:1fr 300px;gap:48px}
.featured{border:1px solid var(--border);border-radius:12px;overflow:hidden;margin-bottom:32px;background:var(--bg2);transition:border-color .2s}
.featured:hover{border-color:var(--gold)}
.featured-img{height:220px;background:linear-gradient(135deg,rgba(212,160,23,.15) 0%,transparent 60%),linear-gradient(225deg,rgba(88,166,255,.08) 0%,transparent 50%),var(--bg3);display:flex;align-items:center;justify-content:center;font-size:72px;position:relative;overflow:hidden}
.featured-img::before{content:'';position:absolute;inset:0;background:repeating-linear-gradient(45deg,transparent,transparent 20px,rgba(212,160,23,.02) 20px,rgba(212,160,23,.02) 40px)}
.featured-badge{position:absolute;top:16px;left:16px;background:var(--gold);color:#000;font-size:11px;font-weight:700;padding:4px 10px;border-radius:4px;letter-spacing:1px;font-family:'JetBrains Mono',monospace}
.featured-body{padding:28px}
.post-meta{display:flex;align-items:center;gap:12px;margin-bottom:12px;flex-wrap:wrap}
.tag{background:var(--tag-bg);color:var(--text-dim);font-size:11px;font-family:'JetBrains Mono',monospace;padding:3px 8px;border-radius:4px;border:1px solid var(--border)}
.tag.linux{color:var(--green);border-color:#3fb95040}
.tag.security{color:var(--red);border-color:#f8514940}
.tag.networking{color:var(--blue);border-color:#58a6ff40}
.tag.caddy{color:var(--gold);border-color:#d4a01740}
.post-date{font-size:12px;font-family:'JetBrains Mono',monospace;color:var(--text-muted);margin-left:auto}
.featured-body h2{font-size:24px;font-weight:800;letter-spacing:-.5px;margin-bottom:10px;line-height:1.25}
.featured-body h2 a{color:var(--text)}
.featured-body h2 a:hover{color:var(--gold)}
.featured-body p{color:var(--text-dim);font-size:15px;line-height:1.7;margin-bottom:20px}
.read-more{display:inline-flex;align-items:center;gap:8px;font-size:13px;font-weight:600;color:var(--gold);font-family:'JetBrains Mono',monospace;transition:all .2s}
.read-more:hover{color:var(--gold2);gap:12px}
.posts-label{font-size:11px;font-family:'JetBrains Mono',monospace;color:var(--text-muted);letter-spacing:2px;margin-bottom:16px;display:flex;align-items:center;gap:12px}
.posts-label::after{content:'';flex:1;height:1px;background:var(--border)}
.post-card{border:1px solid var(--border);border-radius:10px;padding:20px 22px;margin-bottom:12px;background:var(--bg2);display:grid;grid-template-columns:1fr auto;gap:12px;align-items:start;transition:border-color .2s,background .2s;cursor:pointer}
.post-card:hover{background:var(--bg3)}
.post-card h3{font-size:16px;font-weight:600;letter-spacing:-.3px;margin-bottom:6px;line-height:1.3}
.post-card h3 a{color:var(--text)}
.post-card h3 a:hover{color:var(--gold)}
.post-card p{font-size:13px;color:var(--text-dim);line-height:1.55}
.post-card-right{text-align:right;white-space:nowrap}
.read-time{font-size:11px;font-family:'JetBrains Mono',monospace;color:var(--text-muted);display:block;margin-top:8px}
.sidebar{display:flex;flex-direction:column;gap:24px}
.widget{border:1px solid var(--border);border-radius:10px;background:var(--bg2);overflow:hidden}
.widget-header{padding:14px 18px;border-bottom:1px solid var(--border);font-size:11px;font-family:'JetBrains Mono',monospace;color:var(--text-muted);letter-spacing:2px;display:flex;align-items:center;gap:8px}
.widget-header::before{content:'';width:6px;height:6px;background:var(--gold);border-radius:50%}
.widget-body{padding:18px}
.about-avatar{width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,var(--gold) 0%,#8B5E00 100%);display:flex;align-items:center;justify-content:center;font-size:22px;margin-bottom:14px;border:2px solid var(--border)}
.about-name{font-size:15px;font-weight:700;margin-bottom:4px}
.about-bio{font-size:13px;color:var(--text-dim);line-height:1.6;margin-bottom:14px}
.about-links{display:flex;gap:10px;flex-wrap:wrap}
.about-link{display:inline-flex;align-items:center;gap:5px;font-size:12px;font-family:'JetBrains Mono',monospace;color:var(--text-dim);border:1px solid var(--border);padding:5px 10px;border-radius:6px;transition:border-color .2s,color .2s}
.about-link:hover{border-color:var(--gold);color:var(--gold)}
.tags-cloud{display:flex;flex-wrap:wrap;gap:8px}
.tag-link{font-size:12px;font-family:'JetBrains Mono',monospace;padding:5px 10px;border-radius:6px;border:1px solid var(--border);color:var(--text-dim);transition:all .2s}
.tag-link:hover{border-color:var(--gold);color:var(--gold);background:rgba(212,160,23,.05)}
.terminal{background:var(--bg);border-radius:8px;overflow:hidden;font-family:'JetBrains Mono',monospace;font-size:12px}
.terminal-bar{background:var(--bg3);padding:8px 12px;display:flex;align-items:center;gap:6px;border-bottom:1px solid var(--border)}
.terminal-dot{width:10px;height:10px;border-radius:50%}
.terminal-body{padding:14px;color:var(--text-dim);line-height:1.9}
.terminal-body .prompt{color:var(--green)}
.terminal-body .cmd{color:var(--text)}
.terminal-body .out{color:var(--text-muted)}
.terminal-body .hl{color:var(--gold)}
.stats-bar{border-top:1px solid var(--border);border-bottom:1px solid var(--border);background:var(--bg2);padding:16px 24px}
.stats-inner{max-width:1100px;margin:0 auto;display:flex;gap:40px;flex-wrap:wrap}
.stat{display:flex;align-items:center;gap:10px}
.stat-num{font-size:22px;font-weight:800;color:var(--gold);letter-spacing:-1px;font-family:'JetBrains Mono',monospace}
.stat-label{font-size:12px;color:var(--text-muted);line-height:1.3}
footer{border-top:1px solid var(--border);padding:32px 24px;background:var(--bg2)}
.footer-inner{max-width:1100px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px}
.footer-left{font-size:13px;color:var(--text-muted);font-family:'JetBrains Mono',monospace}
.footer-left span{color:var(--gold)}
.footer-links{display:flex;gap:20px}
.footer-links a{font-size:13px;color:var(--text-muted);transition:color .2s}
.footer-links a:hover{color:var(--gold)}
@keyframes fadeUp{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)}}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
.cursor{display:inline-block;width:8px;height:14px;background:var(--green);vertical-align:middle;animation:blink 1s step-end infinite;border-radius:1px}
.hero{animation:fadeUp .5s ease both}
.featured{animation:fadeUp .5s .1s ease both}
@media(max-width:768px){.main{grid-template-columns:1fr}.sidebar{display:none}nav a:not(.nav-rss){display:none}}
</style>
</head>
<body>
<header>
  <div class="header-inner">
    <a href="/" class="logo"><div class="logo-icon">&gt;_</div><span class="logo-text">Dev<span>Stack</span></span></a>
    <nav>
      <a href="#">Linux</a><a href="#">Security</a><a href="#">Networking</a><a href="#">Tools</a>
      <a href="#" class="nav-rss">RSS</a>
    </nav>
  </div>
</header>
<section class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">TECHNICAL NOTES</div>
    <h1>Linux, Networking<br>&amp; <em>Infrastructure</em></h1>
    <p>Practical notes on server administration, open source tooling, and building reliable systems. No fluff — just working code and real-world configs.</p>
  </div>
</section>
<div class="stats-bar">
  <div class="stats-inner">
    <div class="stat"><span class="stat-num">47</span><span class="stat-label">articles<br>published</span></div>
    <div class="stat"><span class="stat-num">12k</span><span class="stat-label">monthly<br>readers</span></div>
    <div class="stat"><span class="stat-num">3y</span><span class="stat-label">writing<br>about Linux</span></div>
    <div class="stat"><span class="stat-num mono">100%</span><span class="stat-label">self-hosted<br>infrastructure</span></div>
  </div>
</div>
<div class="main">
  <main>
    <article class="featured">
      <div class="featured-img">🔐<span class="featured-badge">FEATURED</span></div>
      <div class="featured-body">
        <div class="post-meta"><span class="tag security">security</span><span class="tag linux">linux</span><span class="tag networking">networking</span><span class="post-date mono">Apr 21, 2026</span></div>
        <h2><a href="#">Hardening a Fresh Ubuntu VPS in 2026: The Complete Checklist</a></h2>
        <p>Every time I spin up a new VPS it gets thousands of SSH brute-force attempts within hours. Here's the exact sequence I run — from changing the SSH port and setting up Fail2Ban to configuring unattended security updates and locking down UFW.</p>
        <a href="#" class="read-more">Read article →</a>
      </div>
    </article>
    <div class="posts-label">RECENT POSTS</div>
    <article class="post-card">
      <div><div class="post-meta"><span class="tag caddy">caddy</span><span class="tag networking">networking</span></div><h3><a href="#">Caddy 2 as a Reverse Proxy: Automatic TLS, HTTP/3 and Zero Config</a></h3><p>Forget manually managing Let's Encrypt certificates. Caddy does it all — including HTTP/3 via QUIC — with a ten-line config.</p></div>
      <div class="post-card-right"><span class="post-date mono">Apr 14</span><span class="read-time">7 min</span></div>
    </article>
    <article class="post-card">
      <div><div class="post-meta"><span class="tag linux">linux</span><span class="tag security">security</span></div><h3><a href="#">ED25519 vs RSA: Why You Should Migrate Your SSH Keys Today</a></h3><p>RSA-4096 is not broken, but ED25519 is smaller, faster, and safer against side-channel attacks. Here's how to migrate without locking yourself out.</p></div>
      <div class="post-card-right"><span class="post-date mono">Apr 08</span><span class="read-time">5 min</span></div>
    </article>
    <article class="post-card">
      <div><div class="post-meta"><span class="tag linux">linux</span></div><h3><a href="#">Systemd Timers vs Cron: A Practical Comparison for 2026</a></h3><p>Cron is simple and it works. Systemd timers are more powerful. I compared both for a production automation task — here's what I found.</p></div>
      <div class="post-card-right"><span class="post-date mono">Mar 30</span><span class="read-time">6 min</span></div>
    </article>
    <article class="post-card">
      <div><div class="post-meta"><span class="tag networking">networking</span><span class="tag security">security</span></div><h3><a href="#">UFW Deep Dive: Rules, Logging and Common Mistakes</a></h3><p>UFW is friendly but hides complexity. I cover rule ordering, default policies, logging levels, and the three mistakes that get people locked out of their own servers.</p></div>
      <div class="post-card-right"><span class="post-date mono">Mar 22</span><span class="read-time">9 min</span></div>
    </article>
    <article class="post-card">
      <div><div class="post-meta"><span class="tag linux">linux</span><span class="tag caddy">caddy</span></div><h3><a href="#">Building a Minimal Self-Hosted Stack: No Docker, No Kubernetes</a></h3><p>Not every project needs containers. A plain Ubuntu server with Caddy, systemd and a deploy script can run production workloads reliably with far less overhead.</p></div>
      <div class="post-card-right"><span class="post-date mono">Mar 15</span><span class="read-time">11 min</span></div>
    </article>
  </main>
  <aside class="sidebar">
    <div class="widget">
      <div class="widget-header">ABOUT</div>
      <div class="widget-body">
        <div class="about-avatar">👨‍💻</div>
        <div class="about-name">Project maintainer</div>
        <p class="about-bio">Sysadmin and open source enthusiast. Writing about Linux, networking and the infrastructure behind the web since 2021.</p>
        <div class="about-links"><a href="#" class="about-link">⌂ GitHub</a><a href="#" class="about-link">✉ Contact</a></div>
      </div>
    </div>
    <div class="widget">
      <div class="widget-header">UPTIME</div>
      <div class="widget-body" style="padding:0">
        <div class="terminal">
          <div class="terminal-bar"><div class="terminal-dot" style="background:#f85149"></div><div class="terminal-dot" style="background:#d4a017"></div><div class="terminal-dot" style="background:#3fb950"></div></div>
          <div class="terminal-body">
            <div><span class="prompt">$</span> <span class="cmd">uptime -p</span></div>
            <div class="out">up <span class="hl">47 days</span>, 3 hours</div>
            <div style="margin-top:8px"><span class="prompt">$</span> <span class="cmd">systemctl is-active caddy</span></div>
            <div class="out" style="color:#3fb950">active</div>
            <div style="margin-top:8px"><span class="prompt">$</span> <span class="cursor"></span></div>
          </div>
        </div>
      </div>
    </div>
    <div class="widget">
      <div class="widget-header">TOPICS</div>
      <div class="widget-body">
        <div class="tags-cloud">
          <a href="#" class="tag-link">linux</a><a href="#" class="tag-link">security</a><a href="#" class="tag-link">caddy</a><a href="#" class="tag-link">ssh</a><a href="#" class="tag-link">ufw</a><a href="#" class="tag-link">fail2ban</a><a href="#" class="tag-link">networking</a><a href="#" class="tag-link">systemd</a><a href="#" class="tag-link">tls</a><a href="#" class="tag-link">selfhosted</a><a href="#" class="tag-link">ubuntu</a><a href="#" class="tag-link">bash</a>
        </div>
      </div>
    </div>
  </aside>
</div>
<footer>
  <div class="footer-inner">
    <div class="footer-left"><span>&gt;_ Yurich Panel</span> · Built with Caddy · © 2026</div>
    <div class="footer-links"><a href="#">Archive</a><a href="#">RSS</a><a href="#">Privacy</a><a href="#">Contact</a></div>
  </div>
</footer>
</body>
</html>
CAMOUFLAGE_EOF

    chmod 644 "$WEBROOT/index.html"
    ok "Камуфляжная страница установлена → $WEBROOT/index.html"
}

# ─── Caddyfile ───────────────────────────────────────────────
write_caddyfile() {
    mkdir -p "$CADDY_DIR" "$WEBROOT" "$LOG_DIR"

    install_camouflage_page
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Неверный домен в конфиге: ${DOMAIN:-}"
        return 1
    fi

    # Собираем блоки basic_auth
    local auth_blocks=""
    local auth_count=0
    while IFS=: read -r u p; do
        [[ -z "$u" ]] && continue
        if ! is_valid_proxy_user "$u" || ! is_valid_proxy_pass "$p"; then
            err "Небезопасная запись пользователя в $USERS_FILE: $u"
            err "Логин: 2-32 символа [A-Za-z0-9_-], пароль: 8-64 символа [A-Za-z0-9_-]"
            return 1
        fi
        auth_blocks+="        basic_auth ${u} ${p}"$'\n'
        auth_count=$((auth_count+1))
    done < <(get_active_users)
    if [[ "$auth_count" -lt 1 ]]; then
        local disabled_pass
        disabled_pass=$(random_safe_token 32)
        auth_blocks+="        basic_auth __disabled__ ${disabled_pass}"$'\n'
        auth_count=1
        warn "Нет активных пользователей. Caddy proxy закрыт placeholder-auth."
    fi
    local caddy_upstream=""
    if [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]]; then
        caddy_upstream="        upstream socks5://127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"$'\n'
    fi
    local caddy_protocols="h1 h2"
    local caddy_server_port="443"
    if [[ "${HYSTERIA_PORT:-8443}" == "443" ]]; then
        caddy_protocols="h1 h2"
    fi

    # Naive forward proxy CONNECT requests carry the target host in :authority.
    # Keep :443 catch-all here, and protect multi-node setups with /etc/hosts audit.
    local site_label=":443, ${DOMAIN}"
    local tls_line="  tls ${EMAIL}"
    if [[ "${XRAY_REALITY_SNI_MUX_ENABLED:-0}" == "1" ]]; then
        caddy_server_port="${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
        site_label=":${caddy_server_port}, ${DOMAIN}:${caddy_server_port}"
        info "Caddy переключён за SNI mux: ${site_label}"
    elif [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        site_label="http://127.0.0.1:${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
        tls_line=""
        info "Caddy переключён в Xray fallback mode: ${site_label}"
    fi

    cat > "$CADDYFILE" <<EOF
{
    order forward_proxy before file_server
    servers :${caddy_server_port} {
        protocols ${caddy_protocols}
    }
    log {
        output file ${LOG_DIR}/access.log {
            roll_size 50mb
            roll_keep 3
        }
    }
}

${site_label} {
${tls_line}

    forward_proxy {
${auth_blocks}${caddy_upstream}        hide_ip
        hide_via
        probe_resistance
    }

    header /s/* {
        X-Robots-Tag "noindex, nofollow, noarchive"
        Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
        Profile-Title "Yurich Connect"
        profile-update-interval "12"
        support-url "${TELEGRAM_COMMUNITY_URL}"
        Referrer-Policy "no-referrer"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), serial=(), usb=()"
        Content-Security-Policy "default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests"
    }

    header /p/* {
        X-Robots-Tag "noindex, nofollow, noarchive"
        Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
        Referrer-Policy "no-referrer"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), serial=(), usb=()"
        Content-Security-Policy "default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests"
    }

    file_server {
        root ${WEBROOT}
    }

    log {
        output file ${LOG_DIR}/naive.log {
            roll_size 20mb
            roll_keep 5
        }
    }
}
EOF

    chmod 600 "$CADDYFILE"
    if [[ -x "$CADDY_BIN" ]]; then
        "$CADDY_BIN" fmt --overwrite "$CADDYFILE" >/dev/null 2>&1 || true
        "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1 || {
            err "Сгенерированный Caddyfile не прошёл validate"
            "$CADDY_BIN" validate --config "$CADDYFILE" || true
            return 1
        }
    fi
    ok "Caddyfile обновлён (активных пользователей: $(active_user_count))"
}

rewrite_caddyfile_current() {
    if [[ "${DOMAINS:-}" == *,* ]]; then
        write_caddyfile_multi
    else
        write_caddyfile
    fi
}

# ─── systemd ─────────────────────────────────────────────────
write_service() {
    cat > "$CADDY_SERVICE" <<'EOF'
[Unit]
Description=Yurich Panel Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target
StartLimitBurst=5
StartLimitIntervalSec=60

[Service]
Type=notify
User=root
Group=root
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/local/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

# Авто-перезапуск при сбое
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable caddy --quiet
    ok "systemd сервис Caddy настроен (Restart=on-failure)"
}

# ─── UFW ─────────────────────────────────────────────────────
setup_firewall() {
    command -v ufw &>/dev/null || apt-get install -y -q ufw
    info "Настраиваю UFW..."

    local ssh_port
    ssh_port=$(current_ssh_port)
    if [[ ! "$ssh_port" =~ ^[0-9]+$ ]]; then
        ssh_port="22"
    fi

    # SSH открываем ДО включения default deny. Иначе новая SSH-сессия может не зайти,
    # даже если SSH Hardening был пропущен.
    ufw allow "${ssh_port}/tcp" comment "SSH access" >/dev/null 2>&1 || true

    # Включаем UFW если не активен
    if ! ufw status | grep -q "Status: active"; then
        # Дефолтная политика: блокируем всё входящее
        ufw default deny incoming  >/dev/null 2>&1 || true
        ufw default allow outgoing >/dev/null 2>&1 || true
        ufw --force enable >/dev/null 2>&1 || true
        ok "UFW включён (дефолт: блокировать всё входящее)"
    fi

    # Базовые порты Yurich Panel
    ufw delete allow 80/tcp >/dev/null 2>&1 || true
    ufw limit 80/tcp comment "Yurich Panel ACME limited" >/dev/null 2>&1 \
        || ufw allow 80/tcp comment "Yurich Panel ACME" >/dev/null 2>&1 \
        || true
    ufw allow 443/tcp comment "Yurich Panel HTTPS" >/dev/null 2>&1 || true
    ufw allow 443/udp comment "Yurich Panel HTTP3" >/dev/null 2>&1 || true

    # Блокируем типичные порты для сканеров
    for port in 3306 5432 6379 27017 8080 8888 9200; do
        ufw deny "${port}/tcp" comment "Block scanners" >/dev/null 2>&1 || true
    done

    ok "UFW: открыт SSH порт ${ssh_port}/tcp"
    ok "UFW: открыты 80, 443/tcp, 443/udp"
    ok "UFW: заблокированы порты БД и типичные цели сканеров"
    ok "UFW: limit на 80/tcp для снижения шума сканеров"
}

setup_fail2ban() {
    local ssh_port="${1:-}"
    [[ "$ssh_port" =~ ^[0-9]+$ ]] || ssh_port=$(current_ssh_port)
    [[ "$ssh_port" =~ ^[0-9]+$ ]] || ssh_port="22"

    info "Настраиваю Fail2Ban..."
    apt-get update -qq 2>/dev/null || true
    apt-get install -y -q fail2ban

    mkdir -p /etc/fail2ban/jail.d /etc/fail2ban/filter.d /etc/fail2ban/action.d "$LOG_DIR"
    touch "$LOG_DIR/naive.log" "$LOG_DIR/access.log" 2>/dev/null || true

    if [[ -f /etc/fail2ban/jail.local ]] && grep -Eq "Глобальные настройки|SSH DDoS|Рецидивисты" /etc/fail2ban/jail.local; then
        cp -a /etc/fail2ban/jail.local "/etc/fail2ban/jail.local.bak.$(date '+%Y%m%d-%H%M%S')" 2>/dev/null || true
        rm -f /etc/fail2ban/jail.local
    fi

    cat > /etc/fail2ban/action.d/yurich-ufw.conf <<'EOF'
[Definition]
actionstart =
actionstop  =
actioncheck =
actionban   = ufw insert 1 deny from <ip> to any
actionunban = ufw delete deny from <ip> to any
EOF

    cat > /etc/fail2ban/filter.d/yurich-caddy-auth.conf <<'EOF'
[Definition]
failregex = ^.*"remote_ip":"<HOST>".*"status":(?:401|407).*
            ^.*"client_ip":"<HOST>".*"status":(?:401|407).*
ignoreregex =
EOF

    cat > /etc/fail2ban/jail.d/yurich-panel.local <<EOF
[DEFAULT]
ignoreip  = 127.0.0.1/8 ::1
bantime   = 86400
findtime  = 600
maxretry  = 3
backend   = systemd
banaction = yurich-ufw

[sshd]
enabled   = true
filter    = sshd
port      = ${ssh_port}
logpath   = %(sshd_log)s
maxretry  = 3
bantime   = 604800

[sshd-ddos]
enabled   = true
filter    = sshd
port      = ${ssh_port}
logpath   = %(sshd_log)s
maxretry  = 10
findtime  = 60
bantime   = 604800

[yurich-caddy-auth]
enabled   = true
filter    = yurich-caddy-auth
port      = http,https
logpath   = ${LOG_DIR}/*.log
maxretry  = 8
findtime  = 600
bantime   = 86400

[recidive]
enabled   = true
logpath   = /var/log/fail2ban.log
banaction = yurich-ufw
bantime   = 2592000
findtime  = 86400
maxretry  = 3
EOF

    if ! fail2ban-client -t >/dev/null 2>&1; then
        err "Fail2Ban config не прошёл проверку:"
        fail2ban-client -t || true
        return 1
    fi

    systemctl enable fail2ban --quiet
    systemctl restart fail2ban
    ok "Fail2Ban настроен:"
    ok "  SSH брутфорс: 3 попытки → бан 7 дней"
    ok "  SSH DDoS: 10 попыток за 1 мин → бан 7 дней"
    ok "  Caddy/Yurich Proxy auth: 8 ошибок → бан 24 часа"
    ok "  Рецидивисты: → бан 30 дней"
}

# ─── BBR ─────────────────────────────────────────────────────
enable_bbr() {
    local current
    current=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
    [[ "$current" == "bbr" ]] && { ok "BBR уже включён"; return; }

    echo -ne "${YELLOW}Включить TCP BBR для ускорения? [y/N]: ${RESET}"
    read -r ans
    if [[ "${ans,,}" == "y" ]]; then
        cat > /etc/sysctl.d/99-bbr.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
        sysctl -p /etc/sysctl.d/99-bbr.conf >/dev/null 2>&1
        ok "BBR включён"
    fi
}

# ─── Бэкап ───────────────────────────────────────────────────
backup_config() {
    [[ -f "$CADDYFILE" ]] || return
    mkdir -p "$BACKUP_DIR"
    local ts; ts=$(date +%Y%m%d_%H%M%S)
    cp "$CADDYFILE" "$BACKUP_DIR/Caddyfile.$ts"
    ok "Бэкап → $BACKUP_DIR/Caddyfile.$ts"
}

validate_enabled_configs() {
    local failed=0

    if [[ -x "$CADDY_BIN" && -f "$CADDYFILE" ]]; then
        if "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1; then
            ok "Caddyfile валиден"
        else
            err "Caddyfile не прошёл validate"
            "$CADDY_BIN" validate --config "$CADDYFILE" || true
            failed=1
        fi
    else
        warn "Caddy validate пропущен: бинарник или Caddyfile не найден"
    fi

    if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        if "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1; then
            ok "Xray config валиден"
        else
            err "Xray config не прошёл проверку"
            "$XRAY_BIN" run -test -config "$XRAY_CONFIG" || true
            failed=1
        fi
    fi

    if command -v unbound-checkconf >/dev/null 2>&1 && command -v unbound >/dev/null 2>&1; then
        if unbound-checkconf >/dev/null 2>&1; then
            ok "Unbound config валиден"
        else
            err "Unbound config не прошёл проверку"
            unbound-checkconf || true
            failed=1
        fi
    fi

    if [[ -x "$HYSTERIA_BIN" && -f "$HYSTERIA_CONFIG" ]]; then
        if validate_hysteria_config "$HYSTERIA_CONFIG" >/dev/null 2>&1; then
            ok "Hysteria config валиден"
        else
            err "Hysteria config не прошёл проверку"
            validate_hysteria_config "$HYSTERIA_CONFIG" || true
            failed=1
        fi
    fi

    return "$failed"
}

safe_apply_caddy_current() {
    load_config
    load_users
    mkdir -p "$BACKUP_DIR"
    local ts backup_file
    ts=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/Caddyfile.safe-apply.${ts}"
    [[ -f "$CADDYFILE" ]] && cp "$CADDYFILE" "$backup_file"

    if ! rewrite_caddyfile_current; then
        err "Не удалось сгенерировать Caddyfile"
        [[ -f "$backup_file" ]] && cp "$backup_file" "$CADDYFILE"
        return 1
    fi
    if [[ -x "$CADDY_BIN" ]] && ! "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1; then
        err "Новый Caddyfile невалиден, откатываю"
        [[ -f "$backup_file" ]] && cp "$backup_file" "$CADDYFILE"
        "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1 || true
        return 1
    fi
    if ! systemctl reload caddy 2>/dev/null; then
        warn "Reload Caddy не прошёл, пробую restart"
        if ! systemctl restart caddy 2>/dev/null; then
            err "Restart Caddy не прошёл, откатываю Caddyfile"
            [[ -f "$backup_file" ]] && cp "$backup_file" "$CADDYFILE"
            systemctl restart caddy 2>/dev/null || true
            return 1
        fi
    fi
    ok "Safe apply Caddy выполнен"
    [[ -f "$backup_file" ]] && info "Rollback backup: $backup_file"
}

cmd_safe_apply() {
    hr
    echo -e "${BOLD}  Safe apply${RESET}"
    hr
    validate_enabled_configs || return 1
    safe_apply_caddy_current
}

health_line() {
    local name="$1" status="$2" detail="${3:-}"
    case "$status" in
        ok)   ok "$name${detail:+ — $detail}" ;;
        warn) warn "$name${detail:+ — $detail}" ;;
        fail) err "$name${detail:+ — $detail}" ;;
    esac
}

ufw_has_port_rule() {
    local rule="$1"
    command -v ufw >/dev/null 2>&1 || return 1
    ufw status 2>/dev/null | grep -Eiq "(^|[[:space:]])${rule//\//\\/}([[:space:]]|[[:space:]].*ALLOW|.*ALLOW|.*LIMIT)"
}

cmd_health_check() {
    load_config 2>/dev/null || true
    load_users 2>/dev/null || true
    hr
    echo -e "${BOLD}  Health-check Yurich Panel${RESET}"
    hr

    [[ -x "$CADDY_BIN" ]] && health_line "Caddy binary" ok "$("$CADDY_BIN" version 2>/dev/null | head -1)" || health_line "Caddy binary" fail "не найден"
    systemctl is-active --quiet caddy 2>/dev/null && health_line "Caddy service" ok "active" || health_line "Caddy service" warn "не active"
    [[ -f "$CADDYFILE" ]] && "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1 && health_line "Caddyfile" ok "valid" || health_line "Caddyfile" warn "нет validate"
    ss -tulpn 2>/dev/null | grep -E ':443([[:space:]]|$)' >/dev/null && health_line "Port 443" ok "listening" || health_line "Port 443" warn "не слушается"
    if edge_routing_mode_is_haproxy; then
        systemctl is-active --quiet haproxy 2>/dev/null && health_line "HAProxy service" ok "active" || health_line "HAProxy service" warn "не active"
        [[ -S "$HAPROXY_STATS_SOCKET" ]] && health_line "HAProxy stats socket" ok "$HAPROXY_STATS_SOCKET" || health_line "HAProxy stats socket" warn "не найден"
        [[ -f "$HAPROXY_CFG" ]] && haproxy -c -f "$HAPROXY_CFG" >/dev/null 2>&1 && health_line "HAProxy config" ok "valid" || health_line "HAProxy config" warn "нет validate"
    fi

    local hosts_overrides hosts_domains
    hosts_overrides=$(hosts_public_domain_overrides | head -5 || true)
    if [[ -n "$hosts_overrides" ]]; then
        hosts_domains=$(printf '%s\n' "$hosts_overrides" | format_hosts_override_domains)
        health_line "Public domain /etc/hosts" warn "${hosts_domains}: убери публичные домены из /etc/hosts"
    else
        health_line "Public domain /etc/hosts" ok "clean"
    fi

    if command -v ufw >/dev/null 2>&1; then
        if ufw status 2>/dev/null | grep -q "Status: active"; then
            health_line "UFW" ok "active"
        else
            health_line "UFW" warn "не active"
        fi
        local ssh_port
        ssh_port=$(current_ssh_port)
        [[ "$ssh_port" =~ ^[0-9]+$ ]] || ssh_port="22"
        ufw_has_port_rule "${ssh_port}/tcp" && health_line "UFW SSH ${ssh_port}/tcp" ok "open" || health_line "UFW SSH ${ssh_port}/tcp" warn "нет правила"
        ufw_has_port_rule "80/tcp" && health_line "UFW 80/tcp" ok "open/limit" || health_line "UFW 80/tcp" warn "нет правила"
        ufw_has_port_rule "443/tcp" && health_line "UFW 443/tcp" ok "open" || health_line "UFW 443/tcp" warn "нет правила"
        ufw_has_port_rule "443/udp" && health_line "UFW 443/udp" ok "open" || health_line "UFW 443/udp" warn "нет правила"
        if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
            ufw_has_port_rule "${HYSTERIA_PORT:-8443}/udp" && health_line "UFW Hysteria ${HYSTERIA_PORT:-8443}/udp" ok "open" || health_line "UFW Hysteria ${HYSTERIA_PORT:-8443}/udp" warn "нет правила"
        fi
        if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
            ufw_has_port_rule "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" && health_line "UFW Xray REALITY" ok "open" || health_line "UFW Xray REALITY" warn "нет правила"
        fi
        if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" ]]; then
            ufw_has_port_rule "53/udp" && ufw_has_port_rule "53/tcp" && health_line "UFW DNS 53" ok "VPN-only rules present" || health_line "UFW DNS 53" warn "проверь VPN CIDR rules"
        fi
    else
        health_line "UFW" warn "не установлен"
    fi

    if command -v fail2ban-client >/dev/null 2>&1; then
        if systemctl is-active --quiet fail2ban 2>/dev/null; then
            health_line "Fail2Ban" ok "active"
            fail2ban-client status sshd >/dev/null 2>&1 && health_line "Fail2Ban sshd" ok "jail active" || health_line "Fail2Ban sshd" warn "jail не найден"
            fail2ban-client status yurich-caddy-auth >/dev/null 2>&1 && health_line "Fail2Ban Caddy auth" ok "jail active" || health_line "Fail2Ban Caddy auth" warn "jail не найден"
        else
            health_line "Fail2Ban" warn "не active"
        fi
    else
        health_line "Fail2Ban" warn "не установлен"
    fi

    if command -v unbound >/dev/null 2>&1; then
        systemctl is-active --quiet unbound 2>/dev/null && health_line "DNS (Unbound)" ok "active" || health_line "DNS (Unbound)" warn "не active"
        command -v dig >/dev/null 2>&1 && dig @127.0.0.1 google.com +time=3 +tries=1 >/dev/null 2>&1 && health_line "DNS test" ok "127.0.0.1 отвечает" || health_line "DNS test" warn "dig не прошёл"
    else
        health_line "DNS (Unbound)" warn "не установлен"
    fi

    if systemctl list-unit-files 2>/dev/null | grep -q '^naiveproxy-bot\.service'; then
        systemctl is-active --quiet naiveproxy-bot 2>/dev/null && health_line "Telegram bot service" ok "active" || health_line "Telegram bot service" warn "не active"
    else
        health_line "Telegram bot service" warn "не установлен"
    fi

    if command -v warp-cli >/dev/null 2>&1; then
        local warp_health_label="${WARP_MODE:-off}"
        [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]] && warp_health_label="proxy"
        [[ "${HYSTERIA_WARP_ENABLED:-0}" == "1" ]] && warp_health_label="proxy для Hysteria"
        if warp-cli --accept-tos status >/dev/null 2>&1 || warp-cli status >/dev/null 2>&1; then
            health_line "WARP" ok "$warp_health_label"
        else
            health_line "WARP" warn "warp-cli без статуса"
        fi
    else
        health_line "WARP" warn "не установлен"
    fi

    if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
        [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]] && "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1 && health_line "Xray config" ok "valid" || health_line "Xray config" fail "ошибка"
        systemctl is-active --quiet xray 2>/dev/null && health_line "Xray service" ok "active" || health_line "Xray service" warn "не active"
    else
        health_line "Xray" warn "не установлен"
    fi

    if [[ -x "$HYSTERIA_BIN" || -f "$HYSTERIA_CONFIG" ]]; then
        [[ -f "$HYSTERIA_CONFIG" ]] && health_line "Hysteria config" ok "$HYSTERIA_CONFIG" || health_line "Hysteria config" warn "не найден"
        systemctl is-active --quiet hysteria 2>/dev/null && health_line "Hysteria service" ok "active" || health_line "Hysteria service" warn "не active"
    else
        health_line "Hysteria 2" warn "не установлен"
    fi

    hr
}

ensure_haproxy_packages() {
    if command -v haproxy >/dev/null 2>&1 && command -v rsyslogd >/dev/null 2>&1; then
        return 0
    fi
    info "Устанавливаю HAProxy/rsyslog..."
    apt-get update -qq >/dev/null 2>&1 || true
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q haproxy rsyslog >/dev/null
}

haproxy_optimal_nbthread() {
    local cpu_count
    cpu_count=$(nproc 2>/dev/null || echo 1)
    [[ "$cpu_count" =~ ^[0-9]+$ ]] || cpu_count=1
    (( cpu_count > 4 )) && cpu_count=4
    if (( cpu_count > 1 )); then
        printf '%s\n' "$cpu_count"
    fi
}

apply_haproxy_kernel_tuning() {
    cat > "$HAPROXY_SYSCTL_CONF" <<'EOF'
# Yurich Panel HAProxy TCP passthrough tuning.
# Keeps the TLS SNI mux responsive during connection bursts.
net.core.somaxconn = 8192
net.core.default_qdisc = fq
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 10240 65535
net.ipv4.tcp_tw_reuse = 2
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_slow_start_after_idle = 0
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 4
EOF
    chmod 644 "$HAPROXY_SYSCTL_CONF"
    sysctl --system >/dev/null 2>&1 || sysctl -p "$HAPROXY_SYSCTL_CONF" >/dev/null 2>&1 || true
}

apply_vless_tcp_tuning() {
    cat > "$XRAY_SYSCTL_CONF" <<'EOF'
# Yurich Panel VLESS Reality TCP stability tuning.
# Conservative values for mobile networks, CGNAT and long-lived TCP tunnels.
net.core.default_qdisc = fq
net.core.somaxconn = 8192
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 4
EOF
    chmod 644 "$XRAY_SYSCTL_CONF"
    sysctl --system >/dev/null 2>&1 || sysctl -p "$XRAY_SYSCTL_CONF" >/dev/null 2>&1 || true
    ok "VLESS TCP tuning применён: $XRAY_SYSCTL_CONF"
}

cmd_egress_prefer_ipv4() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  Force IPv4 egress${RESET}"
    hr

    local backup_dir="${BACKUP_DIR}/egress-ipv4-before-$(date '+%Y%m%d_%H%M%S')" svc failed=0
    install -d -m 700 "$backup_dir"
    [[ -f "$EGRESS_GAI_CONF" ]] && cp -a "$EGRESS_GAI_CONF" "$backup_dir/" 2>/dev/null || true
    [[ -f "$EGRESS_SYSCTL_CONF" ]] && cp -a "$EGRESS_SYSCTL_CONF" "$backup_dir/" 2>/dev/null || true
    info "Backup: $backup_dir"

    touch "$EGRESS_GAI_CONF"
    sed -i '/^[#[:space:]]*precedence[[:space:]][[:space:]]*::ffff:0:0\/96[[:space:]][[:space:]]*100[[:space:]]*$/d' "$EGRESS_GAI_CONF"
    cat >> "$EGRESS_GAI_CONF" <<'EOF'

# Yurich Panel: prefer IPv4 for outbound proxy egress.
# Keeps geo/IP checks consistent when provider IPv6 geolocation differs.
precedence ::ffff:0:0/96  100
EOF
    chmod 644 "$EGRESS_GAI_CONF"
    ok "IPv4 preference записан в $EGRESS_GAI_CONF"

    cat > "$EGRESS_SYSCTL_CONF" <<'EOF'
# Yurich Panel: force IPv4 egress for proxy services.
# Use `yurich-panel.sh egress-dualstack` to revert.
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    chmod 644 "$EGRESS_SYSCTL_CONF"
    sysctl -p "$EGRESS_SYSCTL_CONF" >/dev/null 2>&1 || true
    for path in /proc/sys/net/ipv6/conf/*/disable_ipv6; do
        [[ -w "$path" ]] && printf '1' > "$path" 2>/dev/null || true
    done
    ok "IPv6 отключён для egress-теста: $EGRESS_SYSCTL_CONF"

    for svc in caddy xray hysteria; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            info "Перезапускаю $svc для применения resolver policy..."
            if systemctl restart "$svc"; then
                ok "$svc restarted"
            else
                err "$svc restart failed"
                journalctl -u "$svc" -n 50 --no-pager 2>/dev/null || true
                failed=1
            fi
        fi
    done

    if command -v getent >/dev/null 2>&1; then
        info "Проверка порядка адресов для ifconfig.co:"
        getent ahosts ifconfig.co 2>/dev/null | sed -n '1,6p' || true
    fi
    [[ "$failed" -eq 0 ]]
}

cmd_egress_dualstack() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  Restore dual-stack egress${RESET}"
    hr

    local backup_dir="${BACKUP_DIR}/egress-dualstack-before-$(date '+%Y%m%d_%H%M%S')" svc failed=0
    install -d -m 700 "$backup_dir"
    [[ -f "$EGRESS_GAI_CONF" ]] && cp -a "$EGRESS_GAI_CONF" "$backup_dir/" 2>/dev/null || true
    [[ -f "$EGRESS_SYSCTL_CONF" ]] && cp -a "$EGRESS_SYSCTL_CONF" "$backup_dir/" 2>/dev/null || true
    info "Backup: $backup_dir"

    rm -f "$EGRESS_SYSCTL_CONF"
    sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1 || true
    sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1 || true
    for path in /proc/sys/net/ipv6/conf/*/disable_ipv6; do
        [[ -w "$path" ]] && printf '0' > "$path" 2>/dev/null || true
    done

    if [[ -f "$EGRESS_GAI_CONF" ]]; then
        sed -i '/^# Yurich Panel: prefer IPv4 for outbound proxy egress\.$/,+2d' "$EGRESS_GAI_CONF"
    fi
    ok "Dual-stack egress восстановлен"

    for svc in caddy xray hysteria; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            info "Перезапускаю $svc..."
            if systemctl restart "$svc"; then
                ok "$svc restarted"
            else
                err "$svc restart failed"
                failed=1
            fi
        fi
    done
    [[ "$failed" -eq 0 ]]
}

detect_pingtunnel_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) printf 'amd64\n' ;;
        i386|i686) printf '386\n' ;;
        aarch64|arm64) printf 'arm64\n' ;;
        armv7l|armv6l|armv7*) printf 'arm\n' ;;
        riscv64) printf 'riscv64\n' ;;
        ppc64) printf 'ppc64\n' ;;
        ppc64le) printf 'ppc64le\n' ;;
        *) err "Архитектура $arch не поддерживается PingTunnel автоустановкой"; return 1 ;;
    esac
}

random_pingtunnel_key() {
    local raw
    raw=$(od -An -N4 -tu4 /dev/urandom 2>/dev/null | tr -d '[:space:]')
    [[ "$raw" =~ ^[0-9]+$ ]] || raw=$((RANDOM * RANDOM + 1))
    printf '%s\n' "$((raw % 2147483646 + 1))"
}

write_pingtunnel_env() {
    local force="${1:-0}" key secret encrypt
    install -d -m 700 "$CONFIG_DIR"
    if [[ "$force" != "1" && -f "$PINGTUNNEL_ENV" ]]; then
        return 0
    fi

    key=$(random_pingtunnel_key)
    secret=$(openssl rand -base64 32 | tr -d '\n')
    encrypt="chacha20"
    umask 077
    cat > "$PINGTUNNEL_ENV" <<EOF
PINGTUNNEL_KEY=${key}
PINGTUNNEL_ENCRYPT=${encrypt}
PINGTUNNEL_ENCRYPT_KEY=${secret}
EOF
    chmod 600 "$PINGTUNNEL_ENV"
    ok "PingTunnel ключи записаны: $PINGTUNNEL_ENV"
}

download_pingtunnel_binary() {
    local arch version url tmp zip extracted expected_sha actual_sha
    arch=$(detect_pingtunnel_arch) || return 1
    version="${PINGTUNNEL_VERSION:-$PINGTUNNEL_VERSION_PIN}"
    if [[ "$version" == "latest" ]]; then
        if [[ "${YURICH_ALLOW_UNVERIFIED_DOWNLOADS:-0}" != "1" ]]; then
            err "PingTunnel latest запрещён без явного YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
            err "Используй NAIVEPROXY_PINGTUNNEL_VERSION=<tag> и NAIVEPROXY_PINGTUNNEL_SHA256=<sha256>"
            return 1
        fi
        url=$(curl -fsSL https://api.github.com/repos/esrrhs/pingtunnel/releases/latest \
            | awk -v asset="pingtunnel_linux_${arch}.zip" '
                $0 ~ "\"name\": \"" asset "\"" {found=1}
                found && /browser_download_url/ {
                    gsub(/.*"browser_download_url": "|".*/, "")
                    print
                    exit
                }')
    else
        url="https://github.com/esrrhs/pingtunnel/releases/download/${version}/pingtunnel_linux_${arch}.zip"
    fi
    [[ -n "${url:-}" ]] || { err "Не найден download URL для PingTunnel (${version}, ${arch})"; return 1; }
    tmp=$(mktemp -d)
    zip="${tmp}/pingtunnel.zip"
    install -d -m 755 "$PINGTUNNEL_DIR"
    info "Скачиваю PingTunnel ${version}: ${url}"
    curl -fsSL -o "$zip" "$url" || { rm -rf "$tmp"; err "Не удалось скачать PingTunnel"; return 1; }
    expected_sha="${NAIVEPROXY_PINGTUNNEL_SHA256:-}"
    if [[ -z "$expected_sha" && "$version" == "$PINGTUNNEL_DEFAULT_VERSION" ]]; then
        case "$arch" in
            amd64) expected_sha="$PINGTUNNEL_SHA256_AMD64" ;;
            arm64) expected_sha="$PINGTUNNEL_SHA256_ARM64" ;;
        esac
    fi
    if [[ -n "$expected_sha" ]]; then
        actual_sha=$(sha256sum "$zip" | awk '{print $1}')
        if [[ "$actual_sha" != "$expected_sha" ]]; then
            rm -rf "$tmp"
            err "PingTunnel SHA256 mismatch: expected=${expected_sha}, actual=${actual_sha}"
            return 1
        fi
        ok "PingTunnel SHA256 проверен"
    elif [[ "${YURICH_ALLOW_UNVERIFIED_DOWNLOADS:-0}" == "1" ]]; then
        warn "PingTunnel SHA256 не задан, продолжаю из-за YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
    else
        rm -rf "$tmp"
        err "Нет SHA256 для PingTunnel ${version}/${arch}"
        err "Задай NAIVEPROXY_PINGTUNNEL_SHA256=<sha256> или YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
        return 1
    fi
    unzip -q "$zip" -d "$tmp/unpack" || { rm -rf "$tmp"; err "Не удалось распаковать PingTunnel"; return 1; }
    extracted=$(find "$tmp/unpack" -type f -name 'pingtunnel' -perm /111 2>/dev/null | head -1)
    [[ -n "$extracted" ]] || extracted=$(find "$tmp/unpack" -type f -name 'pingtunnel' 2>/dev/null | head -1)
    [[ -n "$extracted" ]] || { rm -rf "$tmp"; err "Бинарник pingtunnel не найден в архиве"; return 1; }
    install -m 755 "$extracted" "$PINGTUNNEL_BIN"
    rm -rf "$tmp"
    ok "PingTunnel установлен: $PINGTUNNEL_BIN"
}

wait_apt_locks() {
    local i
    for i in $(seq 1 60); do
        if fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
            || fuser /var/lib/dpkg/lock >/dev/null 2>&1 \
            || fuser /var/cache/apt/archives/lock >/dev/null 2>&1; then
            info "Жду apt/dpkg lock (${i}/60)..."
            sleep 5
        else
            return 0
        fi
    done
    err "apt/dpkg lock не освободился"
    return 1
}

write_pingtunnel_service() {
    cat > "$PINGTUNNEL_SERVICE" <<EOF
[Unit]
Description=Yurich PingTunnel ICMP fallback
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=${PINGTUNNEL_ENV}
ExecStartPre=/usr/sbin/sysctl -w net.ipv4.icmp_echo_ignore_all=1
ExecStart=${PINGTUNNEL_BIN} -type server -key \${PINGTUNNEL_KEY} -encrypt \${PINGTUNNEL_ENCRYPT} -encrypt-key \${PINGTUNNEL_ENCRYPT_KEY}
Restart=always
RestartSec=3
NoNewPrivileges=true
CapabilityBoundingSet=CAP_NET_RAW
AmbientCapabilities=CAP_NET_RAW
ProtectSystem=full
ProtectHome=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$PINGTUNNEL_SERVICE"

    cat > "$PINGTUNNEL_SYSCTL_CONF" <<'EOF'
# Yurich Panel PingTunnel server mode.
# Prevents the kernel ICMP echo handler from racing with PingTunnel raw socket replies.
net.ipv4.icmp_echo_ignore_all = 1
EOF
    chmod 644 "$PINGTUNNEL_SYSCTL_CONF"
    sysctl -p "$PINGTUNNEL_SYSCTL_CONF" >/dev/null 2>&1 || true
}

cmd_pingtunnel_install() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  PingTunnel ICMP fallback install${RESET}"
    hr

    wait_apt_locks || return 1
    apt-get update
    wait_apt_locks || return 1
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip ca-certificates openssl >/dev/null
    download_pingtunnel_binary || return 1
    write_pingtunnel_env 0 || return 1
    write_pingtunnel_service || return 1
    systemctl daemon-reload
    systemctl enable --now yurich-pingtunnel
    sleep 2
    systemctl is-active --quiet yurich-pingtunnel || { journalctl -u yurich-pingtunnel -n 80 --no-pager; return 1; }
    ok "PingTunnel active"
    cmd_pingtunnel_status
}

cmd_pingtunnel_status() {
    hr
    echo -e "${BOLD}  PingTunnel status${RESET}"
    hr
    [[ -x "$PINGTUNNEL_BIN" ]] && "$PINGTUNNEL_BIN" -h 2>&1 | head -1 || warn "PingTunnel binary не найден"
    if systemctl is-active --quiet yurich-pingtunnel 2>/dev/null; then
        ok "Service active: yurich-pingtunnel"
    else
        warn "Service не active: yurich-pingtunnel"
    fi
    systemctl show yurich-pingtunnel \
        -p ActiveState -p SubState -p MainPID -p ExecMainStatus -p NRestarts \
        --no-pager 2>/dev/null || true
    if [[ -f "$PINGTUNNEL_ENV" ]]; then
        awk -F= '
            $1=="PINGTUNNEL_KEY" {print "key_id="$2}
            $1=="PINGTUNNEL_ENCRYPT" {print "encrypt="$2}
            $1=="PINGTUNNEL_ENCRYPT_KEY" {print "encrypt_key=***stored in /etc/naiveproxy/pingtunnel.env***"}
        ' "$PINGTUNNEL_ENV"
    fi
    journalctl -u yurich-pingtunnel -n 12 --no-pager 2>/dev/null \
        | sed -E 's/(-encrypt-key )[A-Za-z0-9+\/=._-]+/\1***REDACTED***/g' || true
    sysctl net.ipv4.icmp_echo_ignore_all 2>/dev/null || true
}

cmd_pingtunnel_config() {
    if [[ ! -f "$PINGTUNNEL_ENV" ]]; then
        err "PingTunnel env не найден: $PINGTUNNEL_ENV"
        return 1
    fi
    if [[ "${1:-}" == "--show-secrets" || "${YURICH_SHOW_SECRETS:-0}" == "1" ]]; then
        cat "$PINGTUNNEL_ENV"
    else
        sed -E \
            -e 's/^(PINGTUNNEL_KEY=).+/\1***REDACTED***/' \
            -e 's/^(PINGTUNNEL_ENCRYPT_KEY=).+/\1***REDACTED***/' \
            "$PINGTUNNEL_ENV"
        warn "Секреты скрыты. Для полного вывода: pingtunnel-config --show-secrets или YURICH_SHOW_SECRETS=1"
    fi
}

write_pingtunnel_subscription_file() {
    local out_file="$1" domain="$2" user="$3" key encrypt encrypt_key
    [[ -n "$out_file" && -n "$domain" && -f "$PINGTUNNEL_ENV" ]] || return 1
    # shellcheck source=/dev/null
    source "$PINGTUNNEL_ENV"
    key="${PINGTUNNEL_KEY:-}"
    encrypt="${PINGTUNNEL_ENCRYPT:-chacha20}"
    encrypt_key="${PINGTUNNEL_ENCRYPT_KEY:-}"
    [[ -n "$key" && -n "$encrypt_key" ]] || return 1
    cat > "$out_file" <<EOF
Yurich Connect PingTunnel / ICMP fallback

Profile: ${user}
Server: ${domain}
Mode: SOCKS5 over ICMP
Local SOCKS5: 127.0.0.1:10888

Linux / macOS:
sudo ./pingtunnel -type client -l 127.0.0.1:10888 -s ${domain} -sock5 1 -key ${key} -encrypt ${encrypt} -encrypt-key ${encrypt_key}

Windows PowerShell (run as Administrator):
.\pingtunnel.exe -type client -l 127.0.0.1:10888 -s ${domain} -sock5 1 -key ${key} -encrypt ${encrypt} -encrypt-key ${encrypt_key}

Test:
curl --socks5-hostname 127.0.0.1:10888 https://www.cloudflare.com/cdn-cgi/trace

Note:
PingTunnel is not a standard subscription URI. Hiddify, v2rayNG, NekoBox and Streisand will not import it directly. Use it as a manual fallback tunnel when TCP/UDP profiles are blocked.
EOF
    chmod 600 "$out_file"
}

cmd_pingtunnel_rotate() {
    hr
    echo -e "${BOLD}  PingTunnel key rotate${RESET}"
    hr
    write_pingtunnel_env 1 || return 1
    systemctl restart yurich-pingtunnel
    systemctl is-active --quiet yurich-pingtunnel || { journalctl -u yurich-pingtunnel -n 80 --no-pager; return 1; }
    ok "PingTunnel ключи обновлены и сервис перезапущен"
}

cmd_pingtunnel_remove() {
    hr
    echo -e "${BOLD}  PingTunnel remove${RESET}"
    hr
    systemctl disable --now yurich-pingtunnel 2>/dev/null || true
    rm -f "$PINGTUNNEL_SERVICE" "$PINGTUNNEL_SYSCTL_CONF"
    sysctl -w net.ipv4.icmp_echo_ignore_all=0 >/dev/null 2>&1 || true
    systemctl daemon-reload
    ok "PingTunnel service удалён. Конфиг и ключи оставлены: $PINGTUNNEL_ENV"
}

write_haproxy_logging_config() {
    cat > "$HAPROXY_RSYSLOG_CONF" <<'EOF'
local0.*    /var/log/haproxy.log
& stop
EOF
    chmod 644 "$HAPROXY_RSYSLOG_CONF"
    touch "$HAPROXY_LOG_FILE"
    chmod 640 "$HAPROXY_LOG_FILE" 2>/dev/null || true
    if id syslog >/dev/null 2>&1; then
        chown syslog:adm "$HAPROXY_LOG_FILE" 2>/dev/null || chown syslog:syslog "$HAPROXY_LOG_FILE" 2>/dev/null || true
    fi

    if [[ -f /etc/logrotate.d/haproxy ]] && grep -Eq '(^|[[:space:]])/var/log/haproxy\.log([[:space:]]|\{|$)' /etc/logrotate.d/haproxy; then
        rm -f "$HAPROXY_LOGROTATE_CONF" 2>/dev/null || true
    else
        cat > "$HAPROXY_LOGROTATE_CONF" <<EOF
${HAPROXY_LOG_FILE} {
    daily
    rotate 7
    size 50M
    missingok
    notifempty
    compress
    delaycompress
    create 0640 syslog adm
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate >/dev/null 2>&1 || systemctl reload rsyslog >/dev/null 2>&1 || true
    endscript
}
EOF
        chmod 644 "$HAPROXY_LOGROTATE_CONF"
    fi
    systemctl enable rsyslog --quiet 2>/dev/null || true
    systemctl restart rsyslog 2>/dev/null || systemctl reload rsyslog 2>/dev/null || true
}

write_haproxy_sni_mux_config() {
    load_config
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен: ${DOMAIN:-}"
        return 1
    fi

    local domain="${DOMAIN}"
    local caddy_port="${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
    local reality_port="${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
    local mobile_alt_port="${XRAY_MOBILE_ALT_PORT:-$XRAY_MOBILE_ALT_PORT_DEFAULT}"
    local mobile_alt_sni="${XRAY_MOBILE_ALT_SERVER_NAME:-$XRAY_MOBILE_ALT_SERVER_NAME_DEFAULT}"
    local github_test_port="${XRAY_GITHUB_TEST_PORT:-$XRAY_GITHUB_TEST_PORT_DEFAULT}"
    local github_test_sni="${XRAY_GITHUB_TEST_SERVER_NAME:-$XRAY_GITHUB_TEST_SERVER_NAME_DEFAULT}"
    local backup_file="" nbthread_value="" nbthread_block="" mobile_alt_acl="" mobile_alt_backend="" github_test_acl="" github_test_backend=""

    mkdir -p /etc/haproxy "$BACKUP_DIR"
    if [[ -f "$HAPROXY_CFG" ]]; then
        backup_file="${BACKUP_DIR}/haproxy-before-sni-mux-$(date '+%Y%m%d_%H%M%S').cfg"
        cp -p "$HAPROXY_CFG" "$backup_file"
    fi
    apply_haproxy_kernel_tuning
    nbthread_value=$(haproxy_optimal_nbthread)
    if [[ -n "$nbthread_value" ]]; then
        nbthread_block="    nbthread ${nbthread_value}"$'\n'
    fi
    if [[ -s "$XRAY_COMPAT_USERS_FILE" ]]; then
        mobile_alt_acl="    use_backend xray_reality_mobile_alt if { req.ssl_sni -i ${mobile_alt_sni} }"$'\n'
        mobile_alt_backend=$'\n'"backend xray_reality_mobile_alt"$'\n'"    mode tcp"$'\n'"    server xray_mobile_alt 127.0.0.1:${mobile_alt_port} check inter 2s fall 3 rise 2"$'\n'
    fi
    if [[ "${XRAY_GITHUB_TEST_ENABLED:-0}" == "1" ]]; then
        if ! is_valid_domain "$github_test_sni"; then
            err "Некорректный XRAY_GITHUB_TEST_SERVER_NAME: $github_test_sni"
            return 1
        fi
        github_test_acl="    use_backend xray_reality_github_test if { req.ssl_sni -i ${github_test_sni} }"$'\n'
        github_test_backend=$'\n'"backend xray_reality_github_test"$'\n'"    mode tcp"$'\n'"    option tcp-check"$'\n'"    server xray_github 127.0.0.1:${github_test_port} check inter 2s fall 3 rise 2"$'\n'
    fi

    cat > "$HAPROXY_CFG" <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon
    maxconn 10000
${nbthread_block}    tune.maxaccept 256
    hard-stop-after 30s
    stats socket ${HAPROXY_STATS_SOCKET} mode 660 level admin expose-fd listeners

defaults
    log global
    mode tcp
    option dontlognull
    option log-separate-errors
    option tcp-smart-accept
    option tcp-smart-connect
    option clitcpka
    option srvtcpka
    timeout connect 3s
    timeout client  30m
    timeout server  30m
    timeout client-fin 30s
    timeout server-fin 30s

frontend yurich_tls_443
    bind *:443 backlog 8192
    mode tcp
    tcp-request inspect-delay 1s
    tcp-request content set-var(sess.ssl_sni) req.ssl_sni if { req.ssl_hello_type 1 }
    tcp-request content accept if { req.ssl_hello_type 1 }
    log-format "client=hidden ts=%t frontend=%ft backend=%b server=%s sni=%[var(sess.ssl_sni),lower] bytes=%B term=%ts conn=%ac/%fc/%bc/%sc/%rc timers=%Tw/%Tc/%Tt queues=%sq/%bq"
${github_test_acl}
${mobile_alt_acl}    use_backend caddy_tls if { req.ssl_sni -i ${domain} }
    default_backend xray_reality

backend caddy_tls
    mode tcp
    server caddy 127.0.0.1:${caddy_port} check inter 2s fall 3 rise 2

backend xray_reality
    mode tcp
    server xray 127.0.0.1:${reality_port} check inter 2s fall 3 rise 2
${mobile_alt_backend}
${github_test_backend}
EOF

    if ! haproxy -c -f "$HAPROXY_CFG"; then
        err "HAProxy config не прошёл проверку"
        if [[ -n "$backup_file" && -f "$backup_file" ]]; then
            cp -p "$backup_file" "$HAPROXY_CFG"
            warn "Вернул старый HAProxy config: $backup_file"
        fi
        return 1
    fi
    [[ -n "$backup_file" ]] && info "Backup HAProxy config: $backup_file"
}

haproxy_socket_cmd() {
    local command_text="${1:-show info}"
    [[ -S "$HAPROXY_STATS_SOCKET" ]] || return 1
    command -v python3 >/dev/null 2>&1 || return 1
    HAPROXY_SOCKET="$HAPROXY_STATS_SOCKET" HAPROXY_COMMAND="$command_text" python3 - <<'PY'
import os, socket, sys

path = os.environ.get("HAPROXY_SOCKET", "")
command = os.environ.get("HAPROXY_COMMAND", "show info").strip() + "\n"
try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(3)
    sock.connect(path)
    sock.sendall(command.encode("utf-8"))
    chunks = []
    while True:
        try:
            data = sock.recv(65536)
        except socket.timeout:
            break
        if not data:
            break
        chunks.append(data)
    sock.close()
    sys.stdout.write(b"".join(chunks).decode("utf-8", "replace"))
except Exception as exc:
    sys.stderr.write(str(exc) + "\n")
    sys.exit(1)
PY
}

haproxy_recent_sni_summary() {
    [[ -f "$HAPROXY_LOG_FILE" ]] || return 0
    tail -n 2000 "$HAPROXY_LOG_FILE" 2>/dev/null \
        | awk '
/sni=/ {
    be="-"; sni="-";
    for (i=1; i<=NF; i++) {
        if ($i ~ /^backend=/) { be=substr($i,9) }
        if ($i ~ /^sni=/) { sni=substr($i,5) }
    }
    if (sni == "") sni="-";
    count[be " " sni]++;
}
END {
    for (k in count) print count[k] " " k;
}' \
        | sort -rn 2>/dev/null \
        | head -8 \
        | awk '{c=$1; $1=""; sub(/^ /,""); printf "  %sx %s\n", c, $0}'
}

haproxy_stats_text() {
    if ! command -v haproxy >/dev/null 2>&1; then
        echo "HAProxy: не установлен"
        return 1
    fi
    if ! systemctl is-active --quiet haproxy 2>/dev/null; then
        echo "HAProxy: service не active"
        return 1
    fi
    if [[ ! -S "$HAPROXY_STATS_SOCKET" ]]; then
        echo "HAProxy: stats socket не найден: $HAPROXY_STATS_SOCKET"
        return 1
    fi

    local info_file stat_file
    info_file=$(mktemp)
    stat_file=$(mktemp)
    if ! haproxy_socket_cmd "show info" > "$info_file" 2>/dev/null; then
        rm -f "$info_file" "$stat_file"
        echo "HAProxy: не удалось прочитать show info"
        return 1
    fi
    if ! haproxy_socket_cmd "show stat" > "$stat_file" 2>/dev/null; then
        rm -f "$info_file" "$stat_file"
        echo "HAProxy: не удалось прочитать show stat"
        return 1
    fi

    python3 - "$info_file" "$stat_file" <<'PY'
import csv
import sys

info_path, stat_path = sys.argv[1], sys.argv[2]

info = {}
with open(info_path, "r", encoding="utf-8", errors="replace") as fh:
    for line in fh:
        if ":" in line:
            key, value = line.split(":", 1)
            info[key.strip()] = value.strip()

rows = []
with open(stat_path, "r", encoding="utf-8", errors="replace", newline="") as fh:
    raw = fh.read().splitlines()
if raw:
    raw[0] = raw[0].lstrip("# ")
    rows = list(csv.DictReader(raw))

def pick(px, sv=None):
    for row in rows:
        if row.get("pxname") == px and (sv is None or row.get("svname") == sv):
            return row
    return {}

def val(row, key, default="0"):
    value = (row.get(key) or default).strip()
    return value or default

def human_bytes(value):
    try:
        n = float(value or 0)
    except Exception:
        n = 0.0
    units = ["B", "KiB", "MiB", "GiB", "TiB"]
    for unit in units:
        if n < 1024 or unit == units[-1]:
            return f"{n:.1f}{unit}" if unit != "B" else f"{int(n)}B"
        n /= 1024

frontend = pick("yurich_tls_443", "FRONTEND")
caddy = pick("caddy_tls", "caddy")
xray = pick("xray_reality", "xray")
caddy_backend = pick("caddy_tls", "BACKEND")
xray_backend = pick("xray_reality", "BACKEND")

print("HAProxy: active")
print(f"Uptime: {info.get('Uptime', 'n/a')}")
print(f"Connections: {info.get('CurrConns', '0')} / {info.get('Maxconn', 'n/a')} max")
print(f"Frontend 443: current={val(frontend, 'scur')} total={val(frontend, 'stot')} in={human_bytes(val(frontend, 'bin'))} out={human_bytes(val(frontend, 'bout'))}")
print("Routes:")
print(f"  Naive/Caddy: status={val(caddy, 'status', 'n/a')} current={val(caddy_backend, 'scur')} total={val(caddy_backend, 'stot')} in={human_bytes(val(caddy_backend, 'bin'))} out={human_bytes(val(caddy_backend, 'bout'))}")
print(f"  Reality/Xray: status={val(xray, 'status', 'n/a')} current={val(xray_backend, 'scur')} total={val(xray_backend, 'stot')} in={human_bytes(val(xray_backend, 'bin'))} out={human_bytes(val(xray_backend, 'bout'))}")
PY
    rm -f "$info_file" "$stat_file"

    local recent
    recent=$(haproxy_recent_sni_summary || true)
    if [[ -n "$recent" ]]; then
        echo "Recent SNI routes:"
        printf '%s\n' "$recent"
    else
        echo "Recent SNI routes: пока нет данных в $HAPROXY_LOG_FILE"
    fi
}

haproxy_backends_healthy() {
    command -v haproxy >/dev/null 2>&1 || { echo "HAProxy binary not found"; return 1; }
    systemctl is-active --quiet haproxy 2>/dev/null || { echo "HAProxy service is not active"; return 1; }
    [[ -S "$HAPROXY_STATS_SOCKET" ]] || { echo "HAProxy stats socket not found: $HAPROXY_STATS_SOCKET"; return 1; }

    local stat_file rc=0
    stat_file=$(mktemp)
    if ! haproxy_socket_cmd "show stat" > "$stat_file" 2>/dev/null; then
        rm -f "$stat_file"
        echo "HAProxy show stat failed"
        return 1
    fi

    python3 - "$stat_file" <<'PY'
import csv
import sys

path = sys.argv[1]
raw = open(path, "r", encoding="utf-8", errors="replace").read().splitlines()
if not raw:
    print("HAProxy stats are empty")
    sys.exit(1)
raw[0] = raw[0].lstrip("# ")
rows = list(csv.DictReader(raw))

def status(px, sv):
    for row in rows:
        if row.get("pxname") == px and row.get("svname") == sv:
            return (row.get("status") or "").strip()
    return ""

failed = []
for px, sv, label in [
    ("caddy_tls", "caddy", "Naive/Caddy"),
    ("xray_reality", "xray", "Reality/Xray"),
]:
    st = status(px, sv)
    if st != "UP":
        failed.append(f"{label}: {st or 'missing'}")

if failed:
    print("\n".join(failed))
    sys.exit(1)
print("HAProxy backends UP: Naive/Caddy, Reality/Xray")
PY
    rc=$?
    rm -f "$stat_file"
    return "$rc"
}

cmd_haproxy_status() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  HAProxy SNI mux status${RESET}"
    hr
    local hap_ver
    hap_ver=$(haproxy -v 2>/dev/null | head -1 || true)
    [[ -n "$hap_ver" ]] && echo "$hap_ver" || warn "haproxy не установлен"
    echo
    haproxy_stats_text || true
    echo
    echo -e "  Config: ${CYAN}${HAPROXY_CFG}${RESET}"
    echo -e "  Socket: ${CYAN}${HAPROXY_STATS_SOCKET}${RESET}"
    echo -e "  Log:    ${CYAN}${HAPROXY_LOG_FILE}${RESET}"
    hr
}

cmd_haproxy_tg() {
    load_config 2>/dev/null || true
    local tmp safe_text
    tmp=$(mktemp /tmp/yurich-haproxy-tg-XXXXXX.out)
    cmd_haproxy_status > "$tmp" 2>&1 || true
    safe_text=$(html_escape_text "$(tail -n 45 "$tmp")")
    tg_send "📊 <b>Yurich Connect HAProxy</b>
📡 Сервер: <code>$(hostname)</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<pre>${safe_text}</pre>"
    cat "$tmp"
    rm -f "$tmp"
    ok "HAProxy stats отправлены в Telegram"
}

cmd_haproxy_logs() {
    hr
    echo -e "${BOLD}  HAProxy SNI logs${RESET}"
    hr
    if [[ -f "$HAPROXY_LOG_FILE" ]]; then
        tail -n 80 "$HAPROXY_LOG_FILE" 2>/dev/null | sed -E 's/client=[^ ]+/client=hidden/g'
    else
        warn "Лог не найден: $HAPROXY_LOG_FILE"
        journalctl -u haproxy -n 80 --no-pager 2>/dev/null || true
    fi
    hr
}

apply_haproxy_sni_mux_runtime() {
    load_config
    check_installed || { err "Сначала установи Yurich Panel"; return 1; }
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен: ${DOMAIN:-}"
        return 1
    fi

    ensure_haproxy_packages || return 1
    write_haproxy_logging_config

    set_edge_routing_mode "haproxy" || return 1
    save_config

    info "Пересобираю Caddy для внутреннего TLS порта ${XRAY_CADDY_FALLBACK_PORT}"
    rewrite_caddyfile_current || return 1
    if ! systemctl reload caddy 2>/dev/null && ! systemctl restart caddy; then
        err "Caddy не применил fallback-конфиг для HAProxy"
        return 1
    fi

    if [[ -x "$XRAY_BIN" && -s "$XRAY_USERS_FILE" ]]; then
        info "Проверяю Xray Reality на TCP/${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
        write_xray_config || return 1
        write_xray_service
        systemctl restart xray || return 1
    else
        warn "Xray не установлен или нет пользователей. HAProxy применится, но Reality backend будет DOWN до настройки Xray."
    fi

    write_haproxy_sni_mux_config || return 1
    systemctl enable haproxy --quiet
    systemctl reload haproxy 2>/dev/null || systemctl restart haproxy
    sleep 1
    if ! systemctl is-active --quiet haproxy; then
        err "HAProxy не запустился"
        journalctl -u haproxy -n 50 --no-pager
        return 1
    fi

    apply_xray_reality_firewall
    ok "HAProxy SNI mux применён: ${DOMAIN}:443 -> Caddy, default SNI -> Xray Reality"
}

apply_caddy_only_runtime() {
    load_config
    check_installed || { err "Сначала установи Yurich Panel"; return 1; }

    set_edge_routing_mode "caddy" || return 1
    save_config

    info "Останавливаю HAProxy, чтобы освободить TCP/443 для Caddy"
    systemctl disable --now haproxy >/dev/null 2>&1 || true
    systemctl stop haproxy >/dev/null 2>&1 || true
    pkill -x haproxy >/dev/null 2>&1 || true

    info "Пересобираю Caddyfile для прямого Caddy-only режима на 443"
    rewrite_caddyfile_current || return 1
    if ! systemctl reload caddy 2>/dev/null && ! systemctl restart caddy; then
        err "Caddy не применил Caddy-only конфиг"
        return 1
    fi

    if [[ -x "$XRAY_BIN" && -s "$XRAY_USERS_FILE" ]]; then
        info "Пересобираю Xray Reality для прямого TCP-порта ${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
        write_xray_config || return 1
        write_xray_service
        systemctl restart xray || return 1
    fi

    apply_xray_reality_firewall
    ok "Caddy-only применён: Caddy держит 443, Reality использует отдельный TCP-порт"
}

refresh_haproxy_if_enabled() {
    load_config
    edge_routing_mode_is_haproxy || return 0
    command -v haproxy >/dev/null 2>&1 || return 0
    write_haproxy_sni_mux_config || return 1
    systemctl reload haproxy 2>/dev/null || systemctl restart haproxy
}

cmd_edge_routing_mode() {
    load_config
    local mode="${1:-}"
    if [[ -z "$mode" ]]; then
        prompt_edge_routing_mode || return 1
        mode="${EDGE_ROUTING_MODE:-caddy}"
    else
        set_edge_routing_mode "$mode" || return 1
    fi

    if [[ "$mode" == "haproxy" ]]; then
        apply_haproxy_sni_mux_runtime || return 1
        cmd_haproxy_status
    else
        apply_caddy_only_runtime || return 1
        cmd_health_check
    fi
}

cmd_haproxy_apply() {
    load_config
    check_installed || { err "Сначала установи Yurich Panel"; return 1; }
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен: ${DOMAIN:-}"
        return 1
    fi

    hr
    echo -e "${BOLD}  Применение HAProxy SNI mux${RESET}"
    hr

    apply_haproxy_sni_mux_runtime || return 1
    cmd_haproxy_status
}

cmd_haproxy_menu() {
    while true; do
        load_config
        hr
        echo -e "${BOLD}  Routing mode / HAProxy SNI mux${RESET}"
        hr
        echo -e "  Текущий режим: ${CYAN}$(edge_routing_mode_label)${RESET}"
        echo -e "  ${BOLD}1)${RESET} Статус и маршруты"
        echo -e "  ${BOLD}2)${RESET} Применить / пересобрать SNI mux"
        echo -e "  ${BOLD}3)${RESET} Последние SNI-логи"
        echo -e "  ${BOLD}4)${RESET} Переключить на Caddy-only"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_haproxy_status ;;
            2) cmd_haproxy_apply ;;
            3) cmd_haproxy_logs ;;
            4) cmd_edge_routing_mode caddy ;;
            0|"") return ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
}

cmd_security_audit() {
    load_config 2>/dev/null || true
    local failed=0 warn_count=0 value owner perms ports
    hr
    echo -e "${BOLD}  Security audit${RESET}"
    hr

    if command -v ufw >/dev/null 2>&1; then
        if ufw status 2>/dev/null | grep -qi '^Status: active'; then
            ok "UFW active"
        else
            err "UFW не active"
            failed=$((failed + 1))
        fi
    else
        warn "UFW не установлен"
        warn_count=$((warn_count + 1))
    fi

    if command -v sshd >/dev/null 2>&1; then
        value=$(sshd -T 2>/dev/null | awk '/^passwordauthentication /{print $2; exit}' || true)
        [[ "$value" == "no" ]] && ok "SSH password login disabled" || { err "SSH passwordauthentication=${value:-unknown}"; failed=$((failed + 1)); }
        value=$(sshd -T 2>/dev/null | awk '/^permitrootlogin /{print $2; exit}' || true)
        case "$value" in
            no|prohibit-password|without-password|forced-commands-only) ok "SSH root login restricted: ${value}" ;;
            *) err "SSH permitrootlogin=${value:-unknown}"; failed=$((failed + 1)) ;;
        esac
    else
        warn "sshd не найден"
        warn_count=$((warn_count + 1))
    fi

    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        ok "Fail2Ban active"
    else
        warn "Fail2Ban не active"
        warn_count=$((warn_count + 1))
    fi
    if systemctl is-active --quiet crowdsec 2>/dev/null; then
        ok "CrowdSec active"
    else
        warn "CrowdSec не active"
        warn_count=$((warn_count + 1))
    fi

    if [[ -f "$CONFIG_FILE" ]]; then
        owner=$(stat -c '%U' "$CONFIG_FILE" 2>/dev/null || echo unknown)
        perms=$(stat -c '%a' "$CONFIG_FILE" 2>/dev/null || echo 000)
        [[ "$owner" == "root" && "$perms" == "600" ]] && ok "$CONFIG_FILE permissions OK" || { err "$CONFIG_FILE owner=$owner perms=$perms"; failed=$((failed + 1)); }
    else
        err "$CONFIG_FILE не найден"
        failed=$((failed + 1))
    fi

    ports=$(ss -tulpen 2>/dev/null | awk 'NR>1{print $5}' | sed -E 's/.*:([0-9]+)$/\1/' | sort -n | uniq | tr '\n' ' ' || true)
    echo "Open ports: ${ports:-n/a}"
    if ss -H -tulpen 2>/dev/null | awk '
        {
            port=$5
            sub(/.*:/, "", port)
            if (port ~ /^(23|25|3306|5432|6379|9200)$/) found=1
        }
        END { exit(found ? 0 : 1) }
    '; then
        err "Найдены потенциально лишние публичные порты"
        failed=$((failed + 1))
    else
        ok "Критичных лишних портов не видно"
    fi

    if [[ -f "${WEBROOT}/robots.txt" ]] && grep -qi 'Disallow: /s/' "${WEBROOT}/robots.txt" 2>/dev/null; then
        ok "Subscription pages закрыты от индексации robots.txt"
    else
        warn "robots.txt не закрывает /s/"
        warn_count=$((warn_count + 1))
    fi

    [[ -d "$BACKUP_DIR" ]] && ok "Backup dir exists: $BACKUP_DIR" || { warn "Backup dir отсутствует: $BACKUP_DIR"; warn_count=$((warn_count + 1)); }
    [[ -f "$PROTOCOL_BENCHMARK_CRON" ]] && ok "Protocol benchmark cron installed" || warn "Protocol benchmark cron не установлен"
    [[ -f "$EXPIRY_NOTIFY_CRON" ]] && ok "Expiry notify cron installed" || warn "Expiry notify cron не установлен"

    hr
    echo "security audit: failed=${failed} warnings=${warn_count}"
    [[ "$failed" -eq 0 ]]
}

cmd_backup_encrypted() {
    load_config 2>/dev/null || true
    command -v openssl >/dev/null 2>&1 || { err "openssl не найден"; return 1; }
    command -v tar >/dev/null 2>&1 || { err "tar не найден"; return 1; }
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"

    local pass pass_file ts backup_file item includes=()
    if [[ -n "${NAIVEPROXY_BACKUP_PASSPHRASE:-}" ]]; then
        pass="$NAIVEPROXY_BACKUP_PASSPHRASE"
    else
        echo -ne "${CYAN}Пароль для encrypted backup: ${RESET}"
        read -r -s pass
        echo
    fi
    [[ -n "$pass" ]] || { err "Пароль пустой"; return 1; }

    for item in "$CONFIG_DIR" "$CADDYFILE" "$CADDY_SERVICE" "$XRAY_CONFIG_DIR" "$XRAY_SERVICE" "$HYSTERIA_SERVICE" "$SUBS_WEB_DIR" "$PRIVATE_WEB_DIR"; do
        [[ -e "$item" ]] && includes+=("$item")
    done
    [[ "${#includes[@]}" -gt 0 ]] || { err "Нечего бэкапить"; return 1; }

    pass_file=$(mktemp /tmp/naiveproxy_backup_pass_XXXXXX)
    chmod 600 "$pass_file"
    printf '%s' "$pass" > "$pass_file"
    ts=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/naiveproxy-full-${ts}.tar.gz.enc"
    if tar -czf - "${includes[@]}" 2>/dev/null | openssl enc -aes-256-cbc -pbkdf2 -salt -out "$backup_file" -pass "file:$pass_file"; then
        chmod 600 "$backup_file"
        ok "Encrypted backup создан: $backup_file"
    else
        rm -f "$backup_file" 2>/dev/null || true
        err "Encrypted backup не создан"
        rm -f "$pass_file"
        return 1
    fi
    rm -f "$pass_file"
}

cmd_export_state() {
    mkdir -p "$EXPORT_DIR"
    chmod 700 "$EXPORT_DIR"
    local ts out items=()
    ts=$(date +%Y%m%d_%H%M%S)
    out="$EXPORT_DIR/naiveproxy-state-${ts}.tar.gz"
    for item in naive.conf users.conf users.d subscriptions subscription-aliases.conf xray-users.conf xray-compat-users.conf xray-users.disabled users.disabled bridge.conf nodes.conf; do
        [[ -e "$CONFIG_DIR/$item" ]] && items+=("$item")
    done
    [[ "${#items[@]}" -gt 0 ]] || { err "Нет данных для export"; return 1; }
    tar -C "$CONFIG_DIR" -czf "$out" "${items[@]}"
    chmod 600 "$out"
    ok "Export создан: $out"
}

cmd_import_state() {
    local archive="${1:-}" tmp name
    [[ -n "$archive" ]] || { echo -ne "${CYAN}Путь к export .tar.gz: ${RESET}"; read -r archive; }
    [[ -f "$archive" ]] || { err "Файл не найден: $archive"; return 1; }
    if tar -tzf "$archive" | grep -Eq '(^/|(^|/)\.\.(/|$))'; then
        err "Архив содержит небезопасные пути"
        return 1
    fi
    if tar -tzf "$archive" | grep -Ev '^(naive\.conf|users\.conf|users\.disabled|xray-users\.conf|xray-compat-users\.conf|xray-users\.disabled|bridge\.conf|nodes\.conf|subscription-aliases\.conf|users\.d/|users\.d/[A-Za-z0-9_-]+\.env|subscriptions/|subscriptions/[A-Za-z0-9_-]+\.token)$' >/dev/null; then
        err "Архив содержит неизвестные файлы. Импорт остановлен."
        return 1
    fi
    if tar -tvzf "$archive" | awk '{ t=substr($1,1,1); if (t != "-" && t != "d") bad=1 } END { exit bad ? 0 : 1 }'; then
        err "Архив содержит symlink/hardlink/special-файлы. Импорт остановлен."
        return 1
    fi
    echo -ne "${YELLOW}Импорт перезапишет users/subscriptions/config. Продолжить? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] || return 0
    info "Делаю export текущего состояния перед import..."
    cmd_export_state >/dev/null 2>&1 || warn "Не удалось создать pre-import export, продолжаю по подтверждению"

    tmp=$(mktemp -d /tmp/naiveproxy_import_XXXXXX)
    tar --no-same-owner --no-same-permissions -xzf "$archive" -C "$tmp"
    mkdir -p "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR"
    for name in naive.conf users.conf users.disabled xray-users.conf xray-compat-users.conf xray-users.disabled bridge.conf nodes.conf subscription-aliases.conf; do
        [[ -f "$tmp/$name" ]] && install -m 600 "$tmp/$name" "$CONFIG_DIR/$name"
    done
    if [[ -d "$tmp/users.d" ]]; then
        mkdir -p "$USER_META_DIR"
        chmod 700 "$USER_META_DIR"
        find "$tmp/users.d" -maxdepth 1 -type f -name '*.env' -print0 2>/dev/null \
            | while IFS= read -r -d '' meta_file; do
                install -m 600 "$meta_file" "$USER_META_DIR/$(basename "$meta_file")"
            done
    fi
    if [[ -d "$tmp/subscriptions" ]]; then
        mkdir -p "$SUBS_DIR"
        chmod 700 "$SUBS_DIR"
        find "$tmp/subscriptions" -maxdepth 1 -type f -name '*.token' -print0 2>/dev/null \
            | while IFS= read -r -d '' token_file; do
                install -m 600 "$token_file" "$SUBS_DIR/$(basename "$token_file")"
            done
    fi
    rm -rf "$tmp"
    ok "Import завершён"
    warn "После импорта запусти: sudo bash yurich-panel.sh safe-apply"
}

cmd_bridge_configure() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  Bridge builder${RESET}"
    hr
    echo -e "  Схема: мобилка → этот VPS (${DOMAIN:-domain}) → второй VPS"
    echo -ne "${CYAN}Название bridge [ru-to-eu]: ${RESET}"
    read -r BRIDGE_NAME
    BRIDGE_NAME="${BRIDGE_NAME:-ru-to-eu}"
    echo -ne "${CYAN}Входной протокол на этом VPS [naive]: ${RESET}"
    read -r BRIDGE_ENTRY_PROTOCOL
    BRIDGE_ENTRY_PROTOCOL="${BRIDGE_ENTRY_PROTOCOL:-naive}"
    echo -ne "${CYAN}Выходной протокол второго VPS [vless]: ${RESET}"
    read -r BRIDGE_EXIT_PROTOCOL
    BRIDGE_EXIT_PROTOCOL="${BRIDGE_EXIT_PROTOCOL:-vless}"
    echo -ne "${CYAN}URI второго VPS (vless://, trojan://, hysteria2://, socks://, http://): ${RESET}"
    read -r BRIDGE_EXIT_URI
    if [[ ! "$BRIDGE_EXIT_URI" =~ ^(vless|trojan|hysteria2|hy2|socks|socks5|http|https):// ]]; then
        err "Нужен корректный URI второго VPS"
        return 1
    fi
    BRIDGE_ENABLED="1"
    save_config
    install -d -m 700 "$CONFIG_DIR"
    {
        printf 'BRIDGE_ENABLED=%q\n' "$BRIDGE_ENABLED"
        printf 'BRIDGE_NAME=%q\n' "$BRIDGE_NAME"
        printf 'BRIDGE_ENTRY_PROTOCOL=%q\n' "$BRIDGE_ENTRY_PROTOCOL"
        printf 'BRIDGE_EXIT_PROTOCOL=%q\n' "$BRIDGE_EXIT_PROTOCOL"
        printf 'BRIDGE_EXIT_URI=%q\n' "$BRIDGE_EXIT_URI"
        printf 'UPDATED_AT=%q\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    } > "$BRIDGE_CONFIG"
    chmod 600 "$BRIDGE_CONFIG"
    ok "Bridge profile сохранён: $BRIDGE_CONFIG"
    cmd_bridge_show
}

cmd_bridge_show() {
    load_config 2>/dev/null || true
    if [[ -f "$BRIDGE_CONFIG" ]]; then
        local bridge_owner
        bridge_owner=$(stat -c '%U' "$BRIDGE_CONFIG" 2>/dev/null || echo unknown)
        if [[ "$bridge_owner" == "root" ]]; then
            chmod 600 "$BRIDGE_CONFIG" 2>/dev/null || true
            # shellcheck source=/dev/null
            source "$BRIDGE_CONFIG" 2>/dev/null || true
        else
            warn "$BRIDGE_CONFIG принадлежит не root — не загружаю"
        fi
    fi
    hr
    echo -e "${BOLD}  Bridge profile${RESET}"
    hr
    if [[ "${BRIDGE_ENABLED:-0}" != "1" ]]; then
        warn "Bridge не настроен"
        return 0
    fi
    echo -e "  Name:   ${CYAN}${BRIDGE_NAME:-bridge}${RESET}"
    echo -e "  Entry:  ${CYAN}${BRIDGE_ENTRY_PROTOCOL:-naive}${RESET} на этом VPS"
    echo -e "  Exit:   ${CYAN}${BRIDGE_EXIT_PROTOCOL:-vless}${RESET} на втором VPS"
    echo -e "  URI:    ${DIM}${BRIDGE_EXIT_URI:-не задан}${RESET}"
    echo
    warn "Caddy/Naive сам по себе не умеет upstream chaining. Для полного bridge используй Xray/sing-box outbound на первом VPS."
    echo -e "${CYAN}  Следующий шаг:${RESET} включить Xray на этом VPS и добавить outbound на второй VPS по URI выше."
    hr
}

cmd_bridge_remove() {
    rm -f "$BRIDGE_CONFIG" 2>/dev/null || true
    BRIDGE_ENABLED="0"
    BRIDGE_EXIT_URI=""
    save_config
    ok "Bridge profile удалён"
}

cmd_bridge_menu() {
    while true; do
        hr
        echo -e "${BOLD}  Bridge builder${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Создать / изменить bridge profile"
        echo -e "  ${BOLD}2)${RESET} Показать bridge profile"
        echo -e "  ${BOLD}3)${RESET} Удалить bridge profile"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_bridge_configure ;;
            2) cmd_bridge_show ;;
            3) cmd_bridge_remove ;;
            0) break ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${YELLOW}Enter для продолжения...${RESET}"
        read -r
    done
}

# ─── MULTI-SERVER NODES ───────────────────────────────────────
is_valid_node_name() {
    [[ "${1:-}" =~ ^[a-zA-Z0-9_-]{2,32}$ ]]
}

is_valid_ssh_user() {
    [[ "${1:-}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,31}$ ]]
}

is_valid_node_host() {
    local host="${1:-}"
    [[ -n "$host" && "$host" != *"|"* ]] || return 1
    if is_valid_domain "$host"; then
        return 0
    fi
    [[ "$host" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    local IFS=. part
    for part in $host; do
        [[ "$part" =~ ^[0-9]+$ && "$part" -ge 0 && "$part" -le 255 ]] || return 1
    done
}

is_valid_node_role() {
    case "${1:-}" in
        edge|bridge|exit|backup) return 0 ;;
        *) return 1 ;;
    esac
}

is_valid_node_weight() {
    [[ "${1:-}" =~ ^[0-9]+$ ]] && [[ "$1" -ge 1 ]] && [[ "$1" -le 999 ]]
}

nodes_ensure_file() {
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$NODES_FILE" ]]; then
        {
            echo "# Yurich Panel nodes"
            echo "# format: name|host|ssh_port|ssh_user|domain|role|weight|enabled"
        } > "$NODES_FILE"
        chmod 600 "$NODES_FILE"
    fi
}

nodes_list_lines() {
    [[ -f "$NODES_FILE" ]] || return 0
    grep -v '^#\|^[[:space:]]*$' "$NODES_FILE" 2>/dev/null || true
}

nodes_count() {
    nodes_list_lines | wc -l
}

nodes_get_line() {
    local lookup="${1:-}"
    local line
    is_valid_node_name "$lookup" || return 1
    line=$(nodes_list_lines | awk -F'|' -v name="$lookup" '$1 == name {print; exit}')
    [[ -n "$line" ]] || return 1
    printf '%s\n' "$line"
}

nodes_validate_line() {
    local line="$1"
    local name host port ssh_user node_domain role weight enabled
    IFS='|' read -r name host port ssh_user node_domain role weight enabled <<< "$line"
    is_valid_node_name "$name" || return 1
    is_valid_node_host "$host" || return 1
    is_valid_port "$port" || return 1
    is_valid_ssh_user "$ssh_user" || return 1
    if [[ -n "$node_domain" && "$node_domain" != "-" ]]; then
        is_valid_domain "$node_domain" || return 1
    fi
    is_valid_node_role "$role" || return 1
    is_valid_node_weight "$weight" || return 1
    [[ "$enabled" == "1" || "$enabled" == "0" ]] || return 1
}

nodes_upsert_line() {
    local line="$1"
    local name tmp
    nodes_validate_line "$line" || { err "Некорректная запись node"; return 1; }
    name="${line%%|*}"
    nodes_ensure_file
    tmp=$(mktemp)
    awk -F'|' -v name="$name" 'BEGIN{OFS=FS} /^#/ || /^[[:space:]]*$/ {print; next} $1 != name {print}' "$NODES_FILE" > "$tmp"
    printf '%s\n' "$line" >> "$tmp"
    install -m 600 "$tmp" "$NODES_FILE"
    rm -f "$tmp"
}

nodes_remove_line() {
    local name="${1:-}" tmp
    is_valid_node_name "$name" || { err "Некорректное имя node"; return 1; }
    nodes_ensure_file
    tmp=$(mktemp)
    awk -F'|' -v name="$name" 'BEGIN{OFS=FS} /^#/ || /^[[:space:]]*$/ {print; next} $1 != name {print}' "$NODES_FILE" > "$tmp"
    install -m 600 "$tmp" "$NODES_FILE"
    rm -f "$tmp"
}

nodes_prompt_name() {
    local provided="${1:-}" name
    if [[ -n "$provided" ]]; then
        is_valid_node_name "$provided" || return 1
        printf '%s\n' "$provided"
        return 0
    fi
    cmd_nodes_list >&2
    echo -ne "${CYAN}Node name: ${RESET}" >&2
    read -r name
    is_valid_node_name "$name" || return 1
    printf '%s\n' "$name"
}

nodes_ssh() {
    local line="$1" remote_cmd="$2"
    local node_name node_host node_port node_user node_domain node_role node_weight node_enabled
    IFS='|' read -r node_name node_host node_port node_user node_domain node_role node_weight node_enabled <<< "$line"
    ssh \
        -n \
        -o BatchMode=yes \
        -o ConnectTimeout=8 \
        -o ServerAliveInterval=5 \
        -o ServerAliveCountMax=2 \
        -o StrictHostKeyChecking=accept-new \
        -p "$node_port" \
        "${node_user}@${node_host}" \
        "$remote_cmd"
}

nodes_scp_to() {
    local line="$1" src="$2" dest="$3"
    local node_name node_host node_port node_user node_domain node_role node_weight node_enabled
    IFS='|' read -r node_name node_host node_port node_user node_domain node_role node_weight node_enabled <<< "$line"
    scp \
        -P "$node_port" \
        -o BatchMode=yes \
        -o ConnectTimeout=8 \
        -o StrictHostKeyChecking=accept-new \
        -- "$src" "${node_user}@${node_host}:${dest}"
}

nodes_remote_sudo_prefix() {
    local ssh_user="${1:-root}"
    if [[ "$ssh_user" == "root" ]]; then
        printf ''
    else
        printf 'sudo -n '
    fi
}

nodes_local_script_source() {
    if [[ -r "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != /dev/fd/* ]]; then
        printf '%s\n' "${BASH_SOURCE[0]}"
        return 0
    fi
    if [[ -r "$SCRIPT_PATH" ]]; then
        printf '%s\n' "$SCRIPT_PATH"
        return 0
    fi
    err "Не найден локальный файл скрипта для отправки на node"
    return 1
}

cmd_nodes_list() {
    nodes_ensure_file
    hr
    echo -e "${BOLD}  Multi-server nodes${RESET}"
    hr
    if [[ "$(nodes_count)" -eq 0 ]]; then
        warn "Ноды не добавлены"
        echo -e "  Файл: ${NODES_FILE}"
        return 0
    fi
    printf '  %-14s %-22s %-7s %-10s %-24s %-8s %-6s %s\n' "NAME" "HOST" "SSH" "USER" "DOMAIN" "ROLE" "WEIGHT" "ON"
    nodes_list_lines | while IFS='|' read -r name host port ssh_user node_domain role weight enabled; do
        [[ "$enabled" == "1" ]] && enabled="yes" || enabled="no"
        [[ -z "$node_domain" || "$node_domain" == "-" ]] && node_domain="-"
        printf '  %-14s %-22s %-7s %-10s %-24s %-8s %-6s %s\n' "$name" "$host" "$port" "$ssh_user" "$node_domain" "$role" "$weight" "$enabled"
    done
}

cmd_nodes_add() {
    nodes_ensure_file
    local name host port ssh_user node_domain role weight enabled ans line
    hr
    echo -e "${BOLD}  Добавить / изменить node${RESET}"
    hr
    echo -ne "${CYAN}Node name [eu-1]: ${RESET}"
    read -r name
    name="${name:-eu-1}"
    echo -ne "${CYAN}SSH host/IP: ${RESET}"
    read -r host
    echo -ne "${CYAN}SSH port [22]: ${RESET}"
    read -r port
    port="${port:-22}"
    echo -ne "${CYAN}SSH user [root]: ${RESET}"
    read -r ssh_user
    ssh_user="${ssh_user:-root}"
    echo -ne "${CYAN}Публичный домен node для ссылок (Enter = host если это домен): ${RESET}"
    read -r node_domain
    if [[ -z "$node_domain" && "$host" =~ [a-zA-Z] ]]; then
        node_domain="$host"
    fi
    [[ -z "$node_domain" ]] && node_domain="-"
    echo -ne "${CYAN}Role [edge/bridge/exit/backup, Enter=edge]: ${RESET}"
    read -r role
    role="${role:-edge}"
    echo -ne "${CYAN}Weight [100]: ${RESET}"
    read -r weight
    weight="${weight:-100}"
    echo -ne "${CYAN}Включить node в подписки? [Y/n]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "n" ]] && enabled="0" || enabled="1"

    if ! is_valid_node_name "$name"; then err "Node name: 2-32 символа A-Z a-z 0-9 _ -"; return 1; fi
    if ! is_valid_node_host "$host"; then err "Некорректный host/IP"; return 1; fi
    if ! is_valid_port "$port"; then err "Некорректный SSH порт"; return 1; fi
    if ! is_valid_ssh_user "$ssh_user"; then err "Некорректный SSH user"; return 1; fi
    if [[ "$node_domain" != "-" ]] && ! is_valid_domain "$node_domain"; then err "Некорректный домен node"; return 1; fi
    if ! is_valid_node_role "$role"; then err "Role должен быть edge, bridge, exit или backup"; return 1; fi
    if ! is_valid_node_weight "$weight"; then err "Weight: 1-999"; return 1; fi

    line="${name}|${host}|${port}|${ssh_user}|${node_domain}|${role}|${weight}|${enabled}"
    nodes_upsert_line "$line"
    ok "Node сохранена: ${name}"
    warn "Для управления node нужен SSH key login и, если user не root, NOPASSWD sudo."
}

cmd_nodes_remove() {
    local name
    name=$(nodes_prompt_name "${1:-}") || { err "Node не выбрана"; return 1; }
    nodes_remove_line "$name"
    ok "Node удалена из реестра: $name"
}

cmd_nodes_test() {
    local name="${1:-}" line failed=0
    nodes_ensure_file
    if [[ -n "$name" && "$name" != "all" ]]; then
        line=$(nodes_get_line "$name") || { err "Node не найдена: $name"; return 1; }
        set -- "$line"
    else
        mapfile -t _nodes_to_check < <(nodes_list_lines)
        if [[ "${#_nodes_to_check[@]}" -eq 0 ]]; then
            warn "Ноды не добавлены"
            return 0
        fi
        set -- "${_nodes_to_check[@]}"
    fi
    for line in "$@"; do
        local node_name node_host node_port node_user node_domain node_role node_weight node_enabled
        IFS='|' read -r node_name node_host node_port node_user node_domain node_role node_weight node_enabled <<< "$line"
        hr
        echo -e "${BOLD}  Node status: ${node_name}${RESET} (${node_user}@${node_host}:${node_port})"
        hr
        if nodes_ssh "$line" 'printf "host=%s\n" "$(hostname)"; printf "time=%s\n" "$(date "+%Y-%m-%d %H:%M:%S")"; uptime; printf "caddy="; systemctl is-active caddy 2>/dev/null || true; printf "xray="; systemctl is-active xray 2>/dev/null || true; printf "hysteria="; systemctl is-active hysteria 2>/dev/null || true; printf "unbound="; systemctl is-active unbound 2>/dev/null || true; ss -tulpn 2>/dev/null | grep -E ":(443|8443|8444)([[:space:]]|$)" || true'; then
            ok "SSH/status OK: ${node_name}"
        else
            err "SSH/status failed: ${node_name}"
            failed=1
        fi
    done
    return "$failed"
}

cmd_nodes_deploy_script() {
    local name line src remote_tmp node_name node_host node_port node_user node_domain node_role node_weight node_enabled sudo_cmd
    name=$(nodes_prompt_name "${1:-}") || { err "Node не выбрана"; return 1; }
    line=$(nodes_get_line "$name") || { err "Node не найдена: $name"; return 1; }
    IFS='|' read -r node_name node_host node_port node_user node_domain node_role node_weight node_enabled <<< "$line"
    src=$(nodes_local_script_source) || return 1
    remote_tmp="/tmp/yurich-panel-node-${RANDOM}-$$.sh"
    sudo_cmd=$(nodes_remote_sudo_prefix "$node_user")
    info "Отправляю текущий скрипт на ${node_name}..."
    nodes_scp_to "$line" "$src" "$remote_tmp" || return 1
    nodes_ssh "$line" "${sudo_cmd}install -m 755 ${remote_tmp} ${SCRIPT_PATH} && ${sudo_cmd}install -m 755 ${remote_tmp} ${LEGACY_SCRIPT_PATH} && ${sudo_cmd}rm -f ${remote_tmp} && ${sudo_cmd}bash ${SCRIPT_PATH} version" || return 1
    ok "Скрипт установлен/обновлён на node: ${node_name}"
    echo -ne "${CYAN}Запустить интерактивную установку Yurich Panel на node сейчас? [y/N]: ${RESET}"
    read -r ans
    if [[ "${ans,,}" == "y" ]]; then
        ssh -tt \
            -o BatchMode=yes \
            -o ConnectTimeout=8 \
            -o StrictHostKeyChecking=accept-new \
            -p "$node_port" \
            "${node_user}@${node_host}" \
            "${sudo_cmd}bash ${SCRIPT_PATH} install"
    fi
}

cmd_nodes_sync_users() {
    local target="${1:-}" archive remote_tmp failed=0 lines=() items=()
    load_config
    load_users
    nodes_ensure_file
    [[ -s "$USERS_FILE" ]] || { err "users.conf пустой, нечего синхронизировать"; return 1; }
    for item in users.conf users.d subscriptions subscription-aliases.conf xray-users.conf xray-compat-users.conf xray-users.disabled users.disabled; do
        [[ -e "$CONFIG_DIR/$item" ]] && items+=("$item")
    done
    [[ "${#items[@]}" -gt 0 ]] || { err "Нет файлов состояния для sync"; return 1; }
    archive=$(mktemp /tmp/yurich-panel-node-sync-XXXXXX.tar.gz)
    tar -C "$CONFIG_DIR" -czf "$archive" "${items[@]}"

    if [[ -n "$target" && "$target" != "all" ]]; then
        local selected
        selected=$(nodes_get_line "$target") || { rm -f "$archive"; err "Node не найдена: $target"; return 1; }
        lines+=("$selected")
    else
        mapfile -t lines < <(nodes_list_lines)
    fi
    if [[ "${#lines[@]}" -eq 0 ]]; then
        rm -f "$archive"
        warn "Ноды не добавлены"
        return 0
    fi

    for line in "${lines[@]}"; do
        local node_name node_host node_port node_user node_domain node_role node_weight node_enabled sudo_cmd
        IFS='|' read -r node_name node_host node_port node_user node_domain node_role node_weight node_enabled <<< "$line"
        [[ "$node_enabled" == "1" ]] || { warn "Node ${node_name} выключена, пропускаю"; continue; }
        remote_tmp="/tmp/yurich-panel-node-sync-${RANDOM}-$$.tar.gz"
        sudo_cmd=$(nodes_remote_sudo_prefix "$node_user")
        info "Синхронизирую пользователей на ${node_name}..."
        if ! nodes_scp_to "$line" "$archive" "$remote_tmp"; then
            err "Не удалось отправить архив на ${node_name}"
            failed=1
            continue
        fi
        if nodes_ssh "$line" "${sudo_cmd}mkdir -p ${CONFIG_DIR} ${BACKUP_DIR} ${USER_META_DIR} ${SUBS_DIR} && ${sudo_cmd}tar -C ${CONFIG_DIR} -czf ${BACKUP_DIR}/node-sync-before-\$(date +%Y%m%d_%H%M%S).tar.gz users.conf users.d subscriptions subscription-aliases.conf xray-users.conf xray-compat-users.conf xray-users.disabled users.disabled 2>/dev/null || true; ${sudo_cmd}tar -C ${CONFIG_DIR} -xzf ${remote_tmp}; ${sudo_cmd}chmod 700 ${CONFIG_DIR} ${USER_META_DIR} ${SUBS_DIR} 2>/dev/null || true; ${sudo_cmd}chmod 600 ${USERS_FILE} ${DISABLED_USERS_FILE} ${XRAY_USERS_FILE} ${XRAY_COMPAT_USERS_FILE} ${XRAY_DISABLED_USERS_FILE} ${SUBS_ALIASES_FILE} ${USER_META_DIR}/*.env ${SUBS_DIR}/*.token 2>/dev/null || true; sync_status=0; if [ -x ${SCRIPT_PATH} ]; then if [ -x ${CADDY_BIN} ] && [ -f ${CADDYFILE} ]; then ${sudo_cmd}bash ${SCRIPT_PATH} safe-apply || sync_status=20; fi; ${sudo_cmd}bash ${SCRIPT_PATH} hysteria-sync >/dev/null 2>&1 || true; ${sudo_cmd}bash ${SCRIPT_PATH} xray-rebuild >/dev/null 2>&1 || true; ${sudo_cmd}bash ${SCRIPT_PATH} nodes-subscriptions >/dev/null 2>&1 || true; fi; ${sudo_cmd}rm -f ${remote_tmp}; exit \$sync_status"; then
            ok "Users synced: ${node_name}"
        else
            err "Sync failed: ${node_name}"
            failed=1
        fi
    done
    rm -f "$archive"
    return "$failed"
}

node_links_for_user() {
    local user="$1" pass="$2" expiry_tag="${3:-active}"
    [[ -n "$pass" ]] || return 0
    [[ -f "$NODES_FILE" ]] || return 0
    nodes_list_lines | while IFS='|' read -r name host port ssh_user node_domain role weight enabled; do
        [[ "$enabled" == "1" ]] || continue
        [[ "${role:-edge}" == "edge" ]] || continue
        [[ -n "$node_domain" && "$node_domain" != "-" ]] || continue
        is_valid_domain "$node_domain" || continue
        printf 'naive+https://%s:%s@%s:443#%s\n' "$user" "$pass" "$node_domain" \
            "$(uri_fragment_encode "$(pretty_profile_name "$user" "HTTPS" "$name")")"
    done
}

node_app_links_for_user() {
    local user="$1"
    [[ -n "$user" ]] || return 0
    [[ -f "$NODES_FILE" ]] || return 0
    nodes_list_lines | while IFS='|' read -r name host port ssh_user node_domain role weight enabled; do
        [[ "$enabled" == "1" ]] || continue
        [[ -n "$node_domain" && "$node_domain" != "-" ]] || continue
        is_valid_domain "$node_domain" || continue

        local line sudo_cmd remote_cmd
        line="${name}|${host}|${port}|${ssh_user}|${node_domain}|${role}|${weight}|${enabled}"
        sudo_cmd=$(nodes_remote_sudo_prefix "$ssh_user")
        remote_cmd="${sudo_cmd}bash -lc 'u=\"${user}\"; token_file=\"/etc/naiveproxy/subscriptions/\${u}.token\"; token=\$(cat \"\$token_file\" 2>/dev/null || true); links=\"/var/www/html/s/\${token}/links.txt\"; if { [ -z \"\$token\" ] || [ ! -s \"\$links\" ]; } && [ -x /usr/local/bin/yurich-panel.sh ]; then bash /usr/local/bin/yurich-panel.sh nodes-subscriptions >/dev/null 2>&1 || true; token=\$(cat \"\$token_file\" 2>/dev/null || true); links=\"/var/www/html/s/\${token}/links.txt\"; fi; if [ -s \"\$links\" ]; then if systemctl is-active --quiet hysteria 2>/dev/null; then awk '\''/^(hy2:\\/\\/|hysteria2:\\/\\/)/ && \$0 !~ /[Hh]op/ {print}'\'' \"\$links\" || true; fi; if systemctl is-active --quiet xray 2>/dev/null; then awk '\''/^vless:\\/\\// && \$0 ~ /security=reality/ && \$0 ~ /type=tcp/ && \$0 ~ /^vless:\\/\\/[^@]+@[^/?#]+:[0-9]+\\?/ {print}'\'' \"\$links\" || true; fi; fi'"
        local output attempt
        for attempt in 1 2 3; do
            if output=$(nodes_ssh "$line" "$remote_cmd" 2>/dev/null); then
                [[ -n "$output" ]] && printf '%s\n' "$output"
                break
            fi
            sleep 2
        done
    done
}

node_mobile_test_links_for_user() {
    local user="$1"
    [[ -n "$user" ]] || return 0
    [[ -f "$NODES_FILE" ]] || return 0
    nodes_list_lines | while IFS='|' read -r name host port ssh_user node_domain role weight enabled; do
        [[ "$enabled" == "1" ]] || continue
        [[ -n "$node_domain" && "$node_domain" != "-" ]] || continue
        is_valid_domain "$node_domain" || continue

        local line sudo_cmd remote_cmd
        line="${name}|${host}|${port}|${ssh_user}|${node_domain}|${role}|${weight}|${enabled}"
        sudo_cmd=$(nodes_remote_sudo_prefix "$ssh_user")
        remote_cmd="${sudo_cmd}bash -lc 'u=\"${user}\"; token_file=\"/etc/naiveproxy/subscriptions/\${u}.token\"; token=\$(cat \"\$token_file\" 2>/dev/null || true); links=\"/var/www/html/s/\${token}/mobile-test.txt\"; if { [ -z \"\$token\" ] || [ ! -s \"\$links\" ]; } && [ -x /usr/local/bin/yurich-panel.sh ]; then bash /usr/local/bin/yurich-panel.sh nodes-subscriptions >/dev/null 2>&1 || true; token=\$(cat \"\$token_file\" 2>/dev/null || true); links=\"/var/www/html/s/\${token}/mobile-test.txt\"; fi; if [ -s \"\$links\" ]; then awk '\''/^vless:\\/\\// && \$0 ~ /security=reality/ && \$0 ~ /mobile-alt/ {print}'\'' \"\$links\" || true; fi'"
        local output attempt
        for attempt in 1 2 3; do
            if output=$(nodes_ssh "$line" "$remote_cmd" 2>/dev/null); then
                [[ -n "$output" ]] && printf '%s\n' "$output"
                break
            fi
            sleep 2
        done
    done
}

subscription_filter_published_links() {
    awk '
        /Reality GitHub TEST/ { next }
        /spx=%2Fgithub-test-/ { next }
        NF && !seen[$0]++ { print }
    '
}

cmd_nodes_rebuild_subscriptions() {
    load_config
    load_users
    cleanup_orphan_subscription_pages
    local count=0 user
    while IFS= read -r user; do
        [[ -z "$user" ]] && continue
        if user_is_expired "$user"; then
            cleanup_subscription_page "$user"
            continue
        fi
        if generate_subscription_page "$user" >/dev/null 2>&1; then
            count=$((count + 1))
        fi
    done < <(list_subscription_users)
    apply_subscription_aliases >/dev/null 2>&1 || true
    ok "Пересобраны страницы подписки: ${count}"
}

cmd_subscription_rebuild_clean() {
    load_config
    load_users
    local forbidden="${1:-}" failed=0 item matches
    cmd_nodes_rebuild_subscriptions || failed=1
    cleanup_orphan_subscription_pages
    if [[ -n "$forbidden" ]]; then
        forbidden="${forbidden//,/ }"
        for item in $forbidden; do
            [[ -z "$item" ]] && continue
            matches=$(grep -R -n --exclude='*.png' -- "$item" "$SUBS_WEB_DIR" 2>/dev/null | head -n 20 || true)
            if [[ -n "$matches" ]]; then
                printf '%s\n' "$matches"
                err "Запрещённый домен всё ещё найден в подписках: $item"
                failed=1
            else
                ok "Запрещённый домен не найден: $item"
            fi
        done
    fi
    cmd_protocol_validate || failed=1
    [[ "$failed" -eq 0 ]]
}

protocol_line_allowed() {
    local line="${1:-}"
    [[ -z "$line" || "$line" == \#* ]] && return 0
    case "$line" in
        naive+https://*) return 0 ;;
        hy2://*|hysteria2://*)
            [[ "$line" != *"Hop"* && "$line" != *"Hysteria2%20Hop"* ]]
            return
        ;;
        vless://*)
            [[ "$line" == *"security=reality"* && "$line" == *"type=tcp"* && "$line" =~ ^vless://[^@]+@[^/?#]+:[0-9]{1,5}\? ]]
            return
            ;;
    esac
    return 1
}

protocol_line_forbidden() {
    local line="${1:-}"
    [[ -z "$line" || "$line" == \#* ]] && return 1
    [[ "$line" == *"type=ws"* ]] && return 0
    [[ "$line" == *"type=httpupgrade"* ]] && return 0
    [[ "$line" == *"type=xhttp"* ]] && return 0
    [[ "$line" == *"type=kcp"* ]] && return 0
    [[ "$line" == *"security=tls"* ]] && return 0
    [[ "$line" == *"VLESS%20Vision"* ]] && return 0
    [[ "$line" == *"VLESS%20WebSocket"* ]] && return 0
    [[ "$line" == *"VLESS%20HTTPUpgrade"* ]] && return 0
    [[ "$line" == *"VLESS%20XHTTP"* ]] && return 0
    [[ "$line" == *"VLESS%20mKCP"* ]] && return 0
    [[ "$line" == *"Hysteria2%20Hop"* || "$line" == *"Hop%20"* ]] && return 0
    [[ "$line" == vless://* && ! "$line" =~ ^vless://[^@]+@[^/?#]+:[0-9]{1,5}\? ]] && return 0
    return 1
}

cmd_protocol_validate() {
    load_config
    load_users
    local failed=0 checked=0 user token file line count bad files
    files="links.txt hiddify.txt streisand.txt happ.txt nekobox.txt v2rayng.txt"
    while IFS= read -r user; do
        [[ -z "$user" ]] && continue
        if user_is_expired "$user"; then
            printf 'SKIP %-24s expired\n' "$user"
            continue
        fi
        token=$(cat "${SUBS_DIR}/${user}.token" 2>/dev/null || true)
        if [[ -z "$token" ]]; then
            printf 'FAIL %-24s no_token\n' "$user"
            failed=$((failed + 1))
            continue
        fi
        for file in $files; do
            local path="${SUBS_WEB_DIR}/${token}/${file}"
            if [[ ! -s "$path" ]]; then
                printf 'FAIL %-24s %s missing\n' "$user" "$file"
                failed=$((failed + 1))
                continue
            fi
            count=0
            bad=0
            while IFS= read -r line || [[ -n "$line" ]]; do
                [[ -z "$line" || "$line" == \#* ]] && continue
                count=$((count + 1))
                if protocol_line_forbidden "$line" || ! protocol_line_allowed "$line"; then
                    bad=$((bad + 1))
                fi
            done < "$path"
            checked=$((checked + 1))
            if [[ "$bad" -gt 0 ]]; then
                printf 'FAIL %-24s %s lines=%s bad=%s\n' "$user" "$file" "$count" "$bad"
                failed=$((failed + 1))
            else
                printf 'OK   %-24s %s lines=%s\n' "$user" "$file" "$count"
            fi
        done
    done < <(list_subscription_users)
    printf 'protocol validate: checked=%s failed=%s\n' "$checked" "$failed"
    [[ "$failed" -eq 0 ]]
}

cmd_protocol_benchmark() {
    load_config
    load_users
    local user="${1:-}" rounds="${2:-1}" token links_file tmp_py
    if [[ -z "$user" ]]; then
        echo -ne "${CYAN}Пользователь: ${RESET}"
        read -r user
    fi
    if ! is_valid_proxy_user "$user" || ! subscription_user_exists "$user"; then
        err "Пользователь не найден: ${user:-empty}"
        return 1
    fi
    [[ "$rounds" =~ ^[0-9]+$ ]] || rounds=1
    (( rounds < 1 )) && rounds=1
    (( rounds > 5 )) && rounds=5

    generate_subscription_page "$user" >/dev/null 2>&1 || true
    token=$(cat "${SUBS_DIR}/${user}.token" 2>/dev/null || true)
    links_file="${SUBS_WEB_DIR}/${token}/links.txt"
    if [[ -z "$token" || ! -s "$links_file" ]]; then
        err "links.txt не найден для пользователя: $user"
        return 1
    fi

    tmp_py=$(mktemp /tmp/yurich-protocol-benchmark-XXXXXX.py)
    cat > "$tmp_py" <<'PY'
import csv
import datetime as dt
import json
import os
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlsplit

links_path = Path(sys.argv[1])
rounds = int(sys.argv[2])
lines = [x.strip() for x in links_path.read_text(encoding="utf-8", errors="replace").splitlines() if x.strip() and not x.startswith("#")]
csv_path = os.environ.get("YURICH_BENCHMARK_CSV", "").strip()
csv_user = os.environ.get("YURICH_BENCHMARK_USER", "").strip()
try:
    slow_threshold_ms = int(os.environ.get("YURICH_BENCHMARK_MAX_AVG_MS", "2500"))
except Exception:
    slow_threshold_ms = 2500
if slow_threshold_ms < 1:
    slow_threshold_ms = 2500
profiles = []
for line in lines:
    u = urlsplit(line)
    qs = parse_qs(u.query, keep_blank_values=True)
    profiles.append({
        "scheme": u.scheme.lower(),
        "host": u.hostname or "",
        "port": u.port or 443,
        "name": unquote(u.fragment or ""),
        "username": unquote(u.username or ""),
        "password": unquote(u.password or ""),
        "qs": {k: v[0] for k, v in qs.items()},
    })

def wait_port(port, timeout=5.0):
    end = time.time() + timeout
    while time.time() < end:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                return True
        except Exception:
            time.sleep(0.1)
    return False

def run_curl(cmd, timeout=18):
    try:
        r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=timeout)
        text = (r.stdout or "").strip()
        ok = r.returncode == 0 and "code=200" in text
        total = None
        for item in text.split():
            if item.startswith("total="):
                try:
                    total = float(item.split("=", 1)[1])
                except Exception:
                    pass
        return ok, total, (r.stderr or "").strip()[-120:]
    except Exception as exc:
        return False, None, repr(exc)[-120:]

def curl_socks(port):
    return run_curl([
        "curl", "-sS", "--max-time", "15",
        "--socks5-hostname", f"127.0.0.1:{port}",
        "-o", "/dev/null",
        "-w", "code=%{http_code} total=%{time_total}",
        "https://www.cloudflare.com/cdn-cgi/trace",
    ])

def curl_naive(profile):
    auth = profile["username"] + (( ":" + profile["password"]) if profile["password"] else "")
    return run_curl([
        "curl", "-k", "--proxy-insecure", "-sS", "--max-time", "15",
        "--proxy", f"https://{profile['host']}:{profile['port']}",
        "--proxy-user", auth,
        "-o", "/dev/null",
        "-w", "code=%{http_code} total=%{time_total}",
        "https://www.cloudflare.com/cdn-cgi/trace",
    ])

def percentile(values, pct):
    if not values:
        return None
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    pos = (len(ordered) - 1) * pct
    lower = int(pos)
    upper = min(lower + 1, len(ordered) - 1)
    weight = pos - lower
    return ordered[lower] * (1 - weight) + ordered[upper] * weight

def fmt_seconds(value):
    return f"{value:.3f}s" if value is not None else "-"

def bench_profile(index, profile):
    scheme = profile["scheme"]
    proc = None
    cfg = None
    log_path = f"/tmp/yurich-benchmark-{os.getpid()}-{index}.log"
    socks_port = 19600 + index
    try:
        if scheme == "naive+https":
            values = []
            errors = []
            for _ in range(rounds):
                ok, total, err = curl_naive(profile)
                if ok and total is not None:
                    values.append(total)
                elif err:
                    errors.append(err)
            return values, errors

        if scheme in ("hy2", "hysteria2"):
            qs = profile["qs"]
            auth = profile["username"] + (( ":" + profile["password"]) if profile["password"] else "")
            auth = auth or qs.get("auth", "")
            text = (
                f"server: {profile['host']}:{profile['port']}\n"
                f"auth: {auth}\n"
                "tls:\n"
                f"  sni: {qs.get('sni', profile['host'])}\n"
                "  insecure: false\n"
                "obfs:\n"
                f"  type: {qs.get('obfs', 'salamander')}\n"
                "  salamander:\n"
                f"    password: {qs.get('obfs-password', '')}\n"
                "socks5:\n"
                f"  listen: 127.0.0.1:{socks_port}\n"
            )
            fd, cfg = tempfile.mkstemp(prefix="hy2_benchmark_", suffix=".yaml")
            os.close(fd)
            Path(cfg).write_text(text, encoding="utf-8")
            proc = subprocess.Popen(["hysteria", "client", "-c", cfg], stdout=open(log_path, "w"), stderr=subprocess.STDOUT)
        elif scheme == "vless":
            qs = profile["qs"]
            user = {"id": profile["username"], "encryption": "none"}
            if qs.get("flow"):
                user["flow"] = qs.get("flow")
            conf = {
                "log": {"loglevel": "warning"},
                "inbounds": [{"listen": "127.0.0.1", "port": socks_port, "protocol": "socks", "settings": {"udp": True}}],
                "outbounds": [{
                    "protocol": "vless",
                    "settings": {"vnext": [{"address": profile["host"], "port": profile["port"], "users": [user]}]},
                    "streamSettings": {
                        "network": qs.get("type", "tcp"),
                        "security": "reality",
                        "realitySettings": {
                            "serverName": qs.get("sni", ""),
                            "fingerprint": qs.get("fp", "chrome"),
                            "publicKey": qs.get("pbk", ""),
                            "shortId": qs.get("sid", ""),
                            "spiderX": qs.get("spx", "/"),
                        },
                    },
                }],
            }
            fd, cfg = tempfile.mkstemp(prefix="xray_benchmark_", suffix=".json")
            os.close(fd)
            Path(cfg).write_text(json.dumps(conf), encoding="utf-8")
            proc = subprocess.Popen(["xray", "run", "-config", cfg], stdout=open(log_path, "w"), stderr=subprocess.STDOUT)
        else:
            return [], [f"unsupported scheme {scheme}"]

        if not wait_port(socks_port):
            return [], ["local socks not ready"]
        values = []
        errors = []
        for _ in range(rounds):
            ok, total, err = curl_socks(socks_port)
            if ok and total is not None:
                values.append(total)
            elif err:
                errors.append(err)
        return values, errors
    finally:
        if proc:
            try:
                proc.terminate()
                proc.wait(timeout=2)
            except Exception:
                try:
                    proc.kill()
                except Exception:
                    pass
        if cfg:
            try:
                os.remove(cfg)
            except Exception:
                pass
        try:
            os.remove(log_path)
        except Exception:
            pass

print(f"{'STATUS':<6} {'PROTO':<12} {'HOST':<22} {'OK':<5} {'BEST':>8} {'AVG':>8} {'MEDIAN':>8} {'P95':>8} {'WORST':>8} {'SLOW':>7}  NAME")
print("-" * 128)
failed = 0
csv_rows = []
now_iso = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()
for index, profile in enumerate(profiles):
    values, errors = bench_profile(index, profile)
    ok_count = len(values)
    status = "OK" if ok_count == rounds else ("WARN" if ok_count else "FAIL")
    if status == "FAIL":
        failed += 1
    best_value = min(values) if values else None
    avg_value = (sum(values) / len(values)) if values else None
    median_value = percentile(values, 0.50) if values else None
    p95_value = percentile(values, 0.95) if values else None
    worst_value = max(values) if values else None
    slow_count = sum(1 for value in values if int(value * 1000) > slow_threshold_ms)
    slow_label = f"slow={slow_count}/{ok_count}" if values else f"slow=0/{rounds}"
    best = fmt_seconds(best_value)
    avg = fmt_seconds(avg_value)
    median = fmt_seconds(median_value)
    p95 = fmt_seconds(p95_value)
    worst = fmt_seconds(worst_value)
    name = profile["name"][:48]
    print(f"{status:<6} {profile['scheme']:<12} {profile['host']:<22} {ok_count}/{rounds:<3} {best:>8} {avg:>8} {median:>8} {p95:>8} {worst:>8} {slow_label:>7}  {name}")
    csv_rows.append({
        "ts": now_iso,
        "user": csv_user,
        "status": status,
        "scheme": profile["scheme"],
        "host": profile["host"],
        "ok": ok_count,
        "rounds": rounds,
        "best_ms": int(best_value * 1000) if best_value is not None else "",
        "avg_ms": int(avg_value * 1000) if avg_value is not None else "",
        "median_ms": int(median_value * 1000) if median_value is not None else "",
        "p95_ms": int(p95_value * 1000) if p95_value is not None else "",
        "worst_ms": int(worst_value * 1000) if worst_value is not None else "",
        "slow_threshold_ms": slow_threshold_ms,
        "slow_count": slow_count if values else "",
        "slow_total": ok_count if values else "",
        "name": profile["name"],
    })
    if not values and errors:
        print(f"       error: {errors[-1]}")
if csv_path and csv_rows:
    path = Path(csv_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(csv_rows[0].keys())
    new_file = not path.exists() or path.stat().st_size == 0
    if not new_file:
        try:
            with path.open("r", newline="", encoding="utf-8", errors="replace") as f:
                header = next(csv.reader(f), [])
            if header != fieldnames:
                backup = path.with_name(f"{path.name}.{dt.datetime.now().strftime('%Y%m%d%H%M%S')}.bak")
                path.replace(backup)
                new_file = True
        except Exception:
            new_file = True
    with path.open("a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        if new_file:
            writer.writeheader()
        writer.writerows(csv_rows)
print("-" * 128)
print(f"protocol benchmark: checked={len(profiles)} failed={failed} rounds={rounds}")
sys.exit(0 if failed == 0 else 1)
PY

    echo -e "${BOLD}Protocol benchmark:${RESET} user=${user} rounds=${rounds}"
    local rc=0
    python3 "$tmp_py" "$links_file" "$rounds" || rc=$?
    rm -f "$tmp_py" 2>/dev/null || true
    return "$rc"
}

protocol_benchmark_default_user() {
    local configured="${PROTOCOL_BENCHMARK_USER:-}" first_user
    if [[ -n "$configured" ]] && is_valid_proxy_user "$configured" && subscription_user_exists "$configured"; then
        printf '%s\n' "$configured"
        return 0
    fi
    first_user=$(list_subscription_users | head -n1 || true)
    [[ -n "$first_user" ]] || return 1
    printf '%s\n' "$first_user"
}

cmd_protocol_benchmark_monitor() {
    load_config
    load_users
    local user="${1:-}" rounds="${2:-${PROTOCOL_BENCHMARK_ROUNDS:-3}}" max_ms="${PROTOCOL_BENCHMARK_MAX_AVG_MS:-2500}"
    local min_rounds="${PROTOCOL_BENCHMARK_MONITOR_MIN_ROUNDS:-3}" slow_min_hits="${PROTOCOL_BENCHMARK_SLOW_MIN_HITS:-2}"
    local warn_min_ok="${PROTOCOL_BENCHMARK_WARN_MIN_OK_HITS:-2}"
    local alert_repeat="${PROTOCOL_BENCHMARK_ALERT_REPEAT:-2}"
    local alert_cooldown_minutes="${PROTOCOL_BENCHMARK_ALERT_COOLDOWN_MINUTES:-60}"
    local alert_state="${PROTOCOL_BENCHMARK_ALERT_STATE:-$CONFIG_DIR/protocol-benchmark-alert.state}"
    local recovery_alert="${PROTOCOL_BENCHMARK_RECOVERY_ALERT:-1}"
    local log_file="${PROTOCOL_BENCHMARK_LOG:-$PROTOCOL_BENCHMARK_LOG_DEFAULT}" tmp rc=0 issues safe_issues safe_tail safe_alert_note
    local alert_class prev_class="" prev_count=0 prev_sent=0 prev_fingerprint="" prev_recovered=0 issue_count=1 now_ts cooldown_sec should_alert=0 hard_alert=0 last_sent=0
    local fingerprint state_line state_a state_b state_c state_d state_e state_f issue_changed=0
    if [[ -z "$user" ]]; then
        user=$(protocol_benchmark_default_user) || { err "Нет пользователя для benchmark monitor"; return 1; }
    fi
    [[ "$rounds" =~ ^[0-9]+$ ]] || rounds=1
    (( rounds < 1 )) && rounds=1
    (( rounds > 5 )) && rounds=5
    [[ "$min_rounds" =~ ^[0-9]+$ ]] || min_rounds=3
    (( min_rounds < 1 )) && min_rounds=3
    (( min_rounds > 5 )) && min_rounds=5
    (( rounds < min_rounds )) && rounds="$min_rounds"
    [[ "$max_ms" =~ ^[0-9]+$ ]] || max_ms=2500
    [[ "$slow_min_hits" =~ ^[0-9]+$ ]] || slow_min_hits=2
    (( slow_min_hits < 1 )) && slow_min_hits=1
    (( slow_min_hits > 5 )) && slow_min_hits=5
    (( slow_min_hits > rounds )) && slow_min_hits="$rounds"
    [[ "$warn_min_ok" =~ ^[0-9]+$ ]] || warn_min_ok=2
    (( warn_min_ok < 1 )) && warn_min_ok=1
    (( warn_min_ok > rounds )) && warn_min_ok="$rounds"
    [[ "$alert_repeat" =~ ^[0-9]+$ ]] || alert_repeat=2
    (( alert_repeat < 1 )) && alert_repeat=1
    (( alert_repeat > 10 )) && alert_repeat=10
    [[ "$alert_cooldown_minutes" =~ ^[0-9]+$ ]] || alert_cooldown_minutes=60
    (( alert_cooldown_minutes < 5 )) && alert_cooldown_minutes=5
    (( alert_cooldown_minutes > 1440 )) && alert_cooldown_minutes=1440

    tmp=$(mktemp /tmp/yurich-protocol-benchmark-monitor-XXXXXX.out)
    if YURICH_BENCHMARK_CSV="$log_file" YURICH_BENCHMARK_USER="$user" YURICH_BENCHMARK_MAX_AVG_MS="$max_ms" cmd_protocol_benchmark "$user" "$rounds" > "$tmp" 2>&1; then
        rc=0
    else
        rc=$?
    fi
    cat "$tmp"
    issues=$(awk -v max="$max_ms" -v min_hits="$slow_min_hits" -v warn_min_ok="$warn_min_ok" '
        /^(OK|WARN|FAIL)[[:space:]]/ {
            status=$1; proto=$2; host=$3; avg=$6; gsub(/s/, "", avg)
            ok_seen=0; ok_total=0
            if ($4 ~ /^[0-9]+\/[0-9]+$/) {
                split($4, ok_parts, "/")
                ok_seen=ok_parts[1] + 0
                ok_total=ok_parts[2] + 0
            }
            ms=(avg == "-" ? 0 : int(avg * 1000))
            slow_seen=-1; slow_total=0
            for (i=1; i<=NF; i++) {
                if ($i ~ /^slow=[0-9]+\/[0-9]+$/) {
                    split(substr($i, 6), parts, "/")
                    slow_seen=parts[1] + 0
                    slow_total=parts[2] + 0
                }
            }
            if (status == "FAIL" || (status == "WARN" && ok_seen < warn_min_ok)) {
                printf "%s %s %s ok=%s/%s\n", status, proto, host, ok_seen, ok_total
            } else if (slow_seen >= min_hits) {
                printf "SLOW %s %s slow=%s/%s threshold=%sms avg=%sms\n", proto, host, slow_seen, slow_total, max, ms
            } else if (slow_seen < 0 && ms > max) {
                printf "SLOW %s %s avg=%sms\n", proto, host, ms
            }
        }
    ' "$tmp" || true)

    if [[ "$rc" -ne 0 || -n "$issues" ]]; then
        [[ "$rc" -ne 0 ]] && hard_alert=1
        if grep -q '^FAIL[[:space:]]' <<<"${issues:-}"; then
            hard_alert=1
        fi
        alert_class="SOFT"
        [[ "$hard_alert" -eq 1 ]] && alert_class="HARD"
        fingerprint=$(printf 'rc=%s\n%s\n' "$rc" "${issues:-benchmark failed}" | sed '/^[[:space:]]*$/d' | LC_ALL=C sort | sha256sum | awk '{print $1}')
        if [[ -s "$alert_state" ]]; then
            state_line=$(head -n1 "$alert_state" 2>/dev/null || true)
            IFS='|' read -r state_a state_b state_c state_d state_e state_f <<< "$state_line" || true
            if [[ "$state_a" == "PROTOBM1" ]]; then
                prev_class="$state_b"
                prev_count="$state_c"
                prev_sent="$state_d"
                prev_fingerprint="$state_e"
                prev_recovered="$state_f"
            else
                prev_class="$state_a"
                prev_count="$state_b"
                prev_sent="$state_c"
                prev_fingerprint=""
                prev_recovered=0
            fi
        fi
        [[ "$prev_count" =~ ^[0-9]+$ ]] || prev_count=0
        [[ "$prev_sent" =~ ^[0-9]+$ ]] || prev_sent=0
        [[ "$prev_recovered" =~ ^[0-9]+$ ]] || prev_recovered=0
        if [[ "$prev_fingerprint" != "$fingerprint" ]]; then
            issue_changed=1
        fi
        if [[ "$prev_class" == "$alert_class" && "$prev_fingerprint" == "$fingerprint" ]]; then
            issue_count=$((prev_count + 1))
        else
            issue_count=1
        fi
        now_ts=$(date +%s)
        cooldown_sec=$((alert_cooldown_minutes * 60))
        if [[ "$hard_alert" -eq 1 ]]; then
            if (( issue_changed == 1 || issue_count == 1 || now_ts - prev_sent >= cooldown_sec )); then
                should_alert=1
            fi
        elif (( issue_count >= alert_repeat && (issue_changed == 1 || now_ts - prev_sent >= cooldown_sec) )); then
            should_alert=1
        fi
        last_sent="$prev_sent"
        if [[ "$should_alert" -eq 1 ]]; then
            last_sent="$now_ts"
        fi
        mkdir -p "$CONFIG_DIR" 2>/dev/null || true
        { printf 'PROTOBM1|%s|%s|%s|%s|0\n' "$alert_class" "$issue_count" "$last_sent" "$fingerprint" > "$alert_state" && chmod 600 "$alert_state"; } 2>/dev/null || true

        if [[ "$should_alert" -ne 1 ]]; then
            if [[ "$hard_alert" -eq 1 ]]; then
                info "Benchmark alert suppressed: hard repeat=${issue_count}, same_issue=$((1 - issue_changed)), cooldown=${alert_cooldown_minutes}m"
            else
                info "Benchmark alert suppressed: soft repeat=${issue_count}/${alert_repeat}, same_issue=$((1 - issue_changed)), cooldown=${alert_cooldown_minutes}m"
            fi
            rm -f "$tmp"
            return "$rc"
        fi
        safe_issues=$(html_escape_text "${issues:-benchmark failed}")
        safe_tail=$(html_escape_text "$(tail -n 18 "$tmp")")
        safe_alert_note=$(html_escape_text "Антиспам: ${alert_class}, повтор ${issue_count}, cooldown ${alert_cooldown_minutes} мин.")
        tg_send "⚠️ <b>Yurich Connect protocol benchmark</b>
📡 Сервер: <code>$(hostname)</code>
👤 Пользователь: <code>$(html_escape_text "$user")</code>
📈 Порог: <code>${max_ms} ms, ${slow_min_hits}/${rounds} медленных попыток</code>
🔕 <code>${safe_alert_note}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<b>Проблемы:</b>
<pre>${safe_issues}</pre>

<b>Последний тест:</b>
<pre>${safe_tail}</pre>"
    else
        if [[ -s "$alert_state" && "$recovery_alert" == "1" ]]; then
            state_line=$(head -n1 "$alert_state" 2>/dev/null || true)
            IFS='|' read -r state_a state_b state_c state_d state_e state_f <<< "$state_line" || true
            if [[ "$state_a" == "PROTOBM1" ]]; then
                prev_class="$state_b"; prev_count="$state_c"; prev_sent="$state_d"
            else
                prev_class="$state_a"; prev_count="$state_b"; prev_sent="$state_c"
            fi
            [[ "$prev_sent" =~ ^[0-9]+$ ]] || prev_sent=0
            if (( prev_sent > 0 )); then
                tg_send "✅ <b>Yurich Connect protocol benchmark восстановлен</b>
📡 Сервер: <code>$(hostname)</code>
👤 Пользователь: <code>$(html_escape_text "$user")</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<pre>Проблемы больше не повторяются. Последний тест прошёл без FAIL/SLOW по заданным порогам.</pre>"
            fi
        fi
        rm -f "$alert_state" 2>/dev/null || true
    fi
    rm -f "$tmp"
    return "$rc"
}

cmd_protocol_benchmark_history() {
    load_config 2>/dev/null || true
    local log_file="${PROTOCOL_BENCHMARK_LOG:-$PROTOCOL_BENCHMARK_LOG_DEFAULT}" rows="${1:-30}"
    [[ "$rows" =~ ^[0-9]+$ ]] || rows=30
    (( rows < 1 )) && rows=30
    (( rows > 200 )) && rows=200
    if [[ ! -s "$log_file" ]]; then
        warn "История benchmark пока пуста: $log_file"
        return 0
    fi
    python3 - "$log_file" "$rows" <<'PY'
import csv
import sys
from collections import defaultdict

path, limit = sys.argv[1], int(sys.argv[2])
with open(path, "r", encoding="utf-8", errors="replace") as f:
    rows = list(csv.DictReader(f))
rows = rows[-limit:]
print(f"{'TIME':<20} {'STATUS':<6} {'PROTO':<12} {'HOST':<22} {'AVG':>7} {'MEDIAN':>7} {'P95':>7} {'SLOW':>9}  NAME")
print("-" * 120)
for r in rows:
    ts = (r.get("ts") or "")[:19].replace("T", " ")
    avg = (r.get("avg_ms") or "-")
    avg = f"{avg}ms" if avg != "-" else "-"
    median = (r.get("median_ms") or "-")
    median = f"{median}ms" if median != "-" else "-"
    p95 = (r.get("p95_ms") or "-")
    p95 = f"{p95}ms" if p95 != "-" else "-"
    slow_count = r.get("slow_count") or ""
    slow_total = r.get("slow_total") or r.get("ok") or r.get("rounds") or ""
    slow = f"{slow_count}/{slow_total}" if slow_count and slow_total else "-"
    print(f"{ts:<20} {r.get('status',''):<6} {r.get('scheme',''):<12} {r.get('host',''):<22} {avg:>7} {median:>7} {p95:>7} {slow:>9}  {(r.get('name') or '')[:38]}")

stats = defaultdict(lambda: {"total": 0, "fail": 0, "avg_sum": 0, "avg_count": 0})
for r in rows:
    key = (r.get("scheme", ""), r.get("host", ""))
    item = stats[key]
    item["total"] += 1
    if r.get("status") == "FAIL":
        item["fail"] += 1
    try:
        item["avg_sum"] += int(r.get("avg_ms") or 0)
        item["avg_count"] += 1
    except Exception:
        pass
if stats:
    print("-" * 120)
    print("Summary:")
    for (scheme, host), item in sorted(stats.items(), key=lambda x: (x[1]["fail"], (x[1]["avg_sum"] / max(x[1]["avg_count"], 1)))):
        avg = int(item["avg_sum"] / max(item["avg_count"], 1)) if item["avg_count"] else 0
        print(f"{scheme:<12} {host:<22} fail={item['fail']}/{item['total']} avg={avg}ms")
PY
}

cmd_protocol_benchmark_install() {
    load_config
    load_users
    local user="${1:-${PROTOCOL_BENCHMARK_USER:-}}" rounds="${2:-${PROTOCOL_BENCHMARK_ROUNDS:-3}}" script_path="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}"
    if [[ -z "$user" ]]; then
        user=$(protocol_benchmark_default_user) || { err "Нет пользователя для benchmark monitor"; return 1; }
    fi
    if ! is_valid_proxy_user "$user" || ! subscription_user_exists "$user"; then
        err "Пользователь не найден: $user"
        return 1
    fi
    [[ "$rounds" =~ ^[0-9]+$ ]] || rounds=1
    (( rounds < 1 )) && rounds=1
    (( rounds < 3 )) && rounds=3
    (( rounds > 5 )) && rounds=5
    PROTOCOL_BENCHMARK_USER="$user"
    PROTOCOL_BENCHMARK_ROUNDS="$rounds"
    PROTOCOL_BENCHMARK_LOG="${PROTOCOL_BENCHMARK_LOG:-$PROTOCOL_BENCHMARK_LOG_DEFAULT}"
    save_config
    cat > "$PROTOCOL_BENCHMARK_CRON" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/15 * * * * root /bin/bash ${script_path} protocol-benchmark-monitor ${user} ${rounds} >> /var/log/yurich-protocol-benchmark-monitor.log 2>&1
EOF
    chmod 644 "$PROTOCOL_BENCHMARK_CRON"
    touch /var/log/yurich-protocol-benchmark-monitor.log "$PROTOCOL_BENCHMARK_LOG"
    chmod 600 /var/log/yurich-protocol-benchmark-monitor.log "$PROTOCOL_BENCHMARK_LOG"
    ok "Benchmark monitor включён: $PROTOCOL_BENCHMARK_CRON"
    ok "История: $PROTOCOL_BENCHMARK_LOG"
}

cmd_protocol_health() {
    load_config
    load_users
    local failed=0 reality_target="${XRAY_REALITY_TARGET:-www.microsoft.com:443}"

    systemctl is-active --quiet caddy 2>/dev/null && ok "HTTPS/Caddy active" || { err "HTTPS/Caddy не active"; failed=$((failed + 1)); }
    if [[ -x "$CADDY_BIN" && -f "$CADDYFILE" ]]; then
        "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1 && ok "Caddyfile valid" || { err "Caddyfile invalid"; failed=$((failed + 1)); }
    fi

    if [[ -x "$HYSTERIA_BIN" && -f "$HYSTERIA_CONFIG" ]]; then
        validate_hysteria_config "$HYSTERIA_CONFIG" >/dev/null 2>&1 && ok "Turbo/Hysteria config valid" || { err "Turbo/Hysteria config invalid"; failed=$((failed + 1)); }
        systemctl is-active --quiet hysteria 2>/dev/null && ok "Turbo/Hysteria active" || { err "Turbo/Hysteria не active"; failed=$((failed + 1)); }
    else
        warn "Turbo/Hysteria не установлен"
    fi

    if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1 && ok "Reality/Xray config valid" || { err "Reality/Xray config invalid"; failed=$((failed + 1)); }
        systemctl is-active --quiet xray 2>/dev/null && ok "Reality/Xray active" || { err "Reality/Xray не active"; failed=$((failed + 1)); }
        if grep -Eq 'vless-(vision|ws|httpupgrade|xhttp|mkcp)|"network": "(ws|httpupgrade|xhttp|kcp)"|"security": "tls"' "$XRAY_CONFIG" 2>/dev/null; then
            err "Reality/Xray содержит удалённые транспорты"
            failed=$((failed + 1))
        else
            ok "Reality/Xray только REALITY"
        fi
        if test_reality_target_tls "$reality_target" >/dev/null 2>&1; then
            ok "Reality target reachable: $reality_target"
        else
            warn "Reality target не прошёл TLS test: $reality_target"
        fi
    else
        warn "Reality/Xray не установлен"
    fi

    if edge_routing_mode_is_haproxy; then
        systemctl is-active --quiet haproxy 2>/dev/null && ok "HAProxy active" || { err "HAProxy не active"; failed=$((failed + 1)); }
        [[ -f "$HAPROXY_CFG" ]] && haproxy -c -f "$HAPROXY_CFG" >/dev/null 2>&1 && ok "HAProxy config valid" || { err "HAProxy config invalid"; failed=$((failed + 1)); }
        if haproxy_backends_healthy >/tmp/yurich_haproxy_backend_health.out 2>&1; then
            ok "$(cat /tmp/yurich_haproxy_backend_health.out)"
        else
            err "HAProxy backend problem"
            cat /tmp/yurich_haproxy_backend_health.out 2>/dev/null || true
            failed=$((failed + 1))
        fi
        rm -f /tmp/yurich_haproxy_backend_health.out
    fi

    if [[ "${HYSTERIA_WARP_ENABLED:-0}" == "1" || "${WARP_PROXY_ENABLED:-0}" == "1" || "${WARP_MODE:-off}" != "off" ]]; then
        if cmd_warp_test >/tmp/yurich_warp_health.out 2>&1; then
            ok "WARP health OK"
        else
            err "WARP health failed"
            cat /tmp/yurich_warp_health.out 2>/dev/null || true
            failed=$((failed + 1))
        fi
        rm -f /tmp/yurich_warp_health.out
    fi

    if cmd_protocol_validate >/tmp/yurich_protocol_validate.out 2>&1; then
        ok "Подписки содержат только HTTPS/Turbo/Reality"
    else
        err "Подписки содержат ошибки"
        cat /tmp/yurich_protocol_validate.out 2>/dev/null || true
        failed=$((failed + 1))
    fi
    rm -f /tmp/yurich_protocol_validate.out
    [[ "$failed" -eq 0 ]]
}

cmd_protocol_monitor() {
    load_config
    local tmp rc alert_state="${PROTOCOL_MONITOR_ALERT_STATE:-$CONFIG_DIR/protocol-health-alert.state}"
    local alert_cooldown_minutes="${PROTOCOL_MONITOR_ALERT_COOLDOWN_MINUTES:-60}" recovery_alert="${PROTOCOL_MONITOR_RECOVERY_ALERT:-1}"
    local cooldown_sec now_ts fingerprint state_line state_a state_b state_c state_d state_e
    local prev_count=0 prev_sent=0 prev_fingerprint="" issue_count=1 issue_changed=0 should_alert=0 last_sent=0
    [[ "$alert_cooldown_minutes" =~ ^[0-9]+$ ]] || alert_cooldown_minutes=60
    (( alert_cooldown_minutes < 5 )) && alert_cooldown_minutes=5
    (( alert_cooldown_minutes > 1440 )) && alert_cooldown_minutes=1440
    tmp=$(mktemp)
    if cmd_protocol_health > "$tmp" 2>&1; then
        rc=0
    else
        rc=$?
    fi
    if [[ "$rc" -ne 0 ]]; then
        fingerprint=$(sed '/^[[:space:]]*$/d' "$tmp" | LC_ALL=C sort | sha256sum | awk '{print $1}')
        if [[ -s "$alert_state" ]]; then
            state_line=$(head -n1 "$alert_state" 2>/dev/null || true)
            IFS='|' read -r state_a state_b state_c state_d state_e <<< "$state_line" || true
            if [[ "$state_a" == "PROTOHEALTH1" ]]; then
                prev_count="$state_b"
                prev_sent="$state_c"
                prev_fingerprint="$state_d"
            else
                prev_count="$state_b"
                prev_sent="$state_c"
                prev_fingerprint=""
            fi
        fi
        [[ "$prev_count" =~ ^[0-9]+$ ]] || prev_count=0
        [[ "$prev_sent" =~ ^[0-9]+$ ]] || prev_sent=0
        if [[ "$prev_fingerprint" != "$fingerprint" ]]; then
            issue_changed=1
        fi
        if [[ "$prev_fingerprint" == "$fingerprint" ]]; then
            issue_count=$((prev_count + 1))
        else
            issue_count=1
        fi
        now_ts=$(date +%s)
        cooldown_sec=$((alert_cooldown_minutes * 60))
        if (( issue_changed == 1 || issue_count == 1 || now_ts - prev_sent >= cooldown_sec )); then
            should_alert=1
        fi
        last_sent="$prev_sent"
        [[ "$should_alert" -eq 1 ]] && last_sent="$now_ts"
        mkdir -p "$CONFIG_DIR" 2>/dev/null || true
        { printf 'PROTOHEALTH1|%s|%s|%s|0\n' "$issue_count" "$last_sent" "$fingerprint" > "$alert_state" && chmod 600 "$alert_state"; } 2>/dev/null || true
        if [[ "$should_alert" -eq 1 ]]; then
            tg_send "⚠️ <b>Yurich Connect protocol health</b>
📡 Сервер: <code>$(hostname)</code>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🔕 <code>Антиспам: повтор ${issue_count}, cooldown ${alert_cooldown_minutes} мин.</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<pre>$(tail -n 30 "$tmp" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</pre>"
        else
            info "Protocol health alert suppressed: repeat=${issue_count}, same_issue=$((1 - issue_changed)), cooldown=${alert_cooldown_minutes}m"
        fi
    else
        if [[ -s "$alert_state" && "$recovery_alert" == "1" ]]; then
            state_line=$(head -n1 "$alert_state" 2>/dev/null || true)
            IFS='|' read -r state_a state_b state_c state_d state_e <<< "$state_line" || true
            if [[ "$state_a" == "PROTOHEALTH1" ]]; then
                prev_sent="$state_c"
            else
                prev_sent="$state_c"
            fi
            [[ "$prev_sent" =~ ^[0-9]+$ ]] || prev_sent=0
            if (( prev_sent > 0 )); then
                tg_send "✅ <b>Yurich Connect protocol health восстановлен</b>
📡 Сервер: <code>$(hostname)</code>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<pre>Health-check снова проходит без ошибок.</pre>"
            fi
        fi
        rm -f "$alert_state" 2>/dev/null || true
    fi
    cat "$tmp"
    rm -f "$tmp"
    return "$rc"
}

cmd_protocol_monitor_install() {
    local script_path="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}" cron_file="/etc/cron.d/yurich-protocol-monitor" log_file="/var/log/yurich-protocol-monitor.log"
    cat > "$cron_file" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/15 * * * * root /bin/bash ${script_path} protocol-monitor >> ${log_file} 2>&1
EOF
    chmod 644 "$cron_file"
    touch "$log_file"
    chmod 600 "$log_file"
    ok "Protocol monitor включён: $cron_file"
}

cmd_nodes_menu() {
    while true; do
        hr
        echo -e "${BOLD}  Multi-server nodes${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Список серверов"
        echo -e "  ${BOLD}2)${RESET} Добавить / изменить сервер"
        echo -e "  ${BOLD}3)${RESET} Проверить SSH/status"
        echo -e "  ${BOLD}4)${RESET} Установить / обновить скрипт на node"
        echo -e "  ${BOLD}5)${RESET} Синхронизировать пользователей на node"
        echo -e "  ${BOLD}6)${RESET} Пересобрать подписки с node-ссылками"
        echo -e "  ${BOLD}7)${RESET} Удалить сервер из реестра"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -e "  Registry: ${NODES_FILE} | Nodes: $(nodes_count)"
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_nodes_list ;;
            2) cmd_nodes_add ;;
            3) echo -ne "${CYAN}Node name (Enter = all): ${RESET}"; read -r n; cmd_nodes_test "${n:-all}" ;;
            4) cmd_nodes_deploy_script ;;
            5) echo -ne "${CYAN}Node name (Enter = all): ${RESET}"; read -r n; cmd_nodes_sync_users "${n:-all}" ;;
            6) cmd_nodes_rebuild_subscriptions ;;
            7) cmd_nodes_remove ;;
            0) break ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${YELLOW}Enter для продолжения...${RESET}"
        read -r
    done
}

cmd_production_tools_menu() {
    while true; do
        hr
        echo -e "${BOLD}  Production tools${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Health-check всего стека"
        echo -e "  ${BOLD}2)${RESET} Safe apply configs"
        echo -e "  ${BOLD}3)${RESET} Encrypted backup /etc/naiveproxy"
        echo -e "  ${BOLD}4)${RESET} Export users + subscriptions"
        echo -e "  ${BOLD}5)${RESET} Import users + subscriptions"
        echo -e "  ${BOLD}6)${RESET} Bridge builder"
        echo -e "  ${BOLD}7)${RESET} Setup / refresh Fail2Ban"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_health_check ;;
            2) cmd_safe_apply ;;
            3) cmd_backup_encrypted ;;
            4) cmd_export_state ;;
            5) cmd_import_state ;;
            6) cmd_bridge_menu ;;
            7) setup_fail2ban "$(current_ssh_port)" ;;
            0) break ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${YELLOW}Enter для продолжения...${RESET}"
        read -r
    done
}

# ─── Клиентский конфиг ───────────────────────────────────────
yurich_dns_client_ip() {
    if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" && -n "${UNBOUND_GATEWAY_IP:-}" ]]; then
        printf '%s\n' "$UNBOUND_GATEWAY_IP"
    fi
}

uri_fragment_encode() {
    local value="${1:-}"
    if command -v python3 >/dev/null 2>&1; then
        VALUE="$value" python3 - <<'PY'
import os
import urllib.parse

print(urllib.parse.quote(os.environ.get("VALUE", "").strip(), safe="-._~"))
PY
    else
        printf '%s' "$value" | tr ' ' '-' | sed 's/[^A-Za-z0-9._~-]/-/g'
    fi
}

uri_query_encode() {
    local value="${1:-}"
    if command -v python3 >/dev/null 2>&1; then
        VALUE="$value" python3 - <<'PY'
import os
import urllib.parse

print(urllib.parse.quote(os.environ.get("VALUE", "").strip(), safe="-._~"))
PY
    else
        printf '%s' "$value" | sed 's/%/%25/g; s/:/%3A/g; s/ /%20/g; s/#/%23/g; s/&/%26/g; s/?/%3F/g; s/=/%3D/g'
    fi
}

profile_location_label() {
    local label="${PROFILE_LOCATION_LABEL:-Yurich}"
    label="${label//$'\r'/ }"
    label="${label//$'\n'/ }"
    label="${label//$'\t'/ }"
    label=$(printf '%s' "$label" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')
    [[ -z "$label" ]] && label="Yurich"
    printf '%s\n' "$label"
}

profile_flag_for_label() {
    local label="${1:-}" lowered
    lowered=$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]')
    case "$lowered" in
        *finland*|*helsinki*|*suomi*) printf '🇫🇮' ;;
        swe|*sweden*|*stockholm*) printf '🇸🇪' ;;
        *germany*|*deutschland*|*berlin*|*frankfurt*) printf '🇩🇪' ;;
        *netherlands*|*holland*|*amsterdam*) printf '🇳🇱' ;;
        *united\ states*|*america*|*california*|*fremont*|*new\ york*) printf '🇺🇸' ;;
        *united\ kingdom*|*london*|*britain*) printf '🇬🇧' ;;
        *france*|*paris*) printf '🇫🇷' ;;
        *poland*|*warsaw*) printf '🇵🇱' ;;
        *russia*|*moscow*) printf '🇷🇺' ;;
        *) printf '🌐' ;;
    esac
}

node_location_label() {
    local node="${1:-}" lowered
    lowered=$(printf '%s' "$node" | tr '[:upper:]' '[:lower:]')
    case "$lowered" in
        germany|de|main) printf 'Germany' ;;
        finland|fi) printf 'Finland' ;;
        finland2|finland-2|helsinki|n8n) printf 'Finland 2' ;;
        swe|sweden|finland3|finland-3) printf 'SWE' ;;
        netit|net-it|netherlands|nl) printf 'Netherlands' ;;
        usa|us|america|california|fremont) printf 'USA California' ;;
        poland|pl|warsaw) printf 'Poland' ;;
        poland2|pl2|usa2|test-go-it|test) printf 'Poland 2' ;;
        *) printf '%s' "$node" ;;
    esac
}

profile_expiry_date_dmy() {
    local ymd="${1:-}"
    if [[ "$ymd" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
        printf '%s.%s.%s' "${BASH_REMATCH[3]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}"
    else
        printf '%s' "$ymd"
    fi
}

profile_expiry_label_for_name() {
    local user="$1" expires today formatted
    expires=$(get_user_expiry "$user" 2>/dev/null || true)
    if [[ -z "$expires" ]]; then
        printf 'без срока'
        return
    fi
    formatted=$(profile_expiry_date_dmy "$expires")
    today=$(date -u '+%Y-%m-%d')
    if [[ "$expires" < "$today" ]]; then
        printf 'истёк %s' "$formatted"
    else
        printf 'до %s' "$formatted"
    fi
}

pretty_profile_name() {
    local user="$1" protocol="$2" node="${3:-}" label flag expiry
    if [[ -n "$node" ]]; then
        label=$(node_location_label "$node")
        flag=$(profile_flag_for_label "$label" "")
    else
        label=$(profile_location_label)
        flag=$(profile_flag_for_label "$label")
    fi
    expiry=$(profile_expiry_label_for_name "$user")
    printf '%s %s • %s • %s • %s\n' "$flag" "$label" "$expiry" "$protocol" "$user"
}

happ_location_code() {
    local label="${1:-}" lowered
    lowered=$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]')
    case "$lowered" in
        *swe*|*sweden*|*stockholm*|*swe.go-it*) printf 'SWE' ;;
        *finland\ 2*|*finland2*|*n8n*) printf 'FI2' ;;
        *finland*|*helsinki*|*suomi*|*dns-ai*) printf 'FI' ;;
        *germany*|*deutschland*|*berlin*|*frankfurt*|*plus-dns*) printf 'DE' ;;
        *netherlands*|*holland*|*amsterdam*|*net-it*) printf 'NL' ;;
        *usa*|*united\ states*|*america*|*california*|*fremont*) printf 'US' ;;
        *poland*|*warsaw*|*polska*|*poland.dns-ai*) printf 'PL' ;;
        *) printf 'VPN' ;;
    esac
}

happ_profile_name() {
    local protocol="$1" node="${2:-}" label code
    if [[ -n "$node" ]]; then
        label=$(node_location_label "$node")
    else
        label=$(profile_location_label)
    fi
    code=$(happ_location_code "$label")
    printf '%s %s\n' "$code" "$protocol"
}

happ_compat_links() {
    if ! command -v python3 >/dev/null 2>&1; then
        cat
        return 0
    fi
    local tmp_input
    tmp_input=$(mktemp /tmp/yurich_happ_links_XXXXXX.txt) || return 1
    cat > "$tmp_input"
    python3 - "$tmp_input" <<'PY'
import sys
import urllib.parse

def loc_code(host, label):
    text = f"{host} {label}".lower()
    if "swe.go-it" in text or "sweden" in text or "stockholm" in text or "swe •" in text:
        return "SWE"
    if "finland 2" in text or "finland2" in text or "n8n" in text:
        return "FI2"
    if "poland" in text or "warsaw" in text or "polska" in text:
        return "PL"
    if "usa" in text or "america" in text or "california" in text:
        return "US"
    if "russia" in text or "russian" in text or "moscow" in text or "rus.go-it" in text or "ru " in text:
        return "RU"
    if "finland" in text or "helsinki" in text or "suomi" in text or "dns-ai" in text:
        return "FI"
    if "germany" in text or "deutschland" in text or "frankfurt" in text or "plus-dns" in text:
        return "DE"
    if "netherlands" in text or "amsterdam" in text or "net-it" in text:
        return "NL"
    return "VPN"

def clean_label(host, old_label, proto):
    return urllib.parse.quote(f"{loc_code(host, old_label)} {proto}", safe="-._~")

def one(line):
    raw = line.strip()
    if not raw:
        return ""
    split = urllib.parse.urlsplit(raw)
    old_label = urllib.parse.unquote(split.fragment or "")
    scheme = split.scheme.lower()
    if scheme in ("hy2", "hysteria2"):
        query = urllib.parse.parse_qs(split.query, keep_blank_values=True)
        auth = ""
        if "auth" in query and query["auth"]:
            auth = query["auth"][0]
        elif split.username:
            auth = urllib.parse.unquote(split.username)
            if split.password is not None:
                auth += ":" + urllib.parse.unquote(split.password)
        host = split.hostname or ""
        port = split.port or 443
        sni = (query.get("sni") or [host])[0]
        obfs = (query.get("obfs") or ["salamander"])[0]
        obfs_password = (query.get("obfs-password") or query.get("obfs_password") or [""])[0]
        pairs = [
            ("auth", auth),
            ("sni", sni),
            ("obfs", obfs),
            ("obfs-password", obfs_password),
        ]
        for key, values in query.items():
            if key in {"auth", "sni", "obfs", "obfs-password", "obfs_password"}:
                continue
            for value in values:
                pairs.append((key, value))
        q = urllib.parse.urlencode(pairs)
        return f"hy2://{host}:{port}/?{q}#{clean_label(host, old_label, 'Turbo')}"
    if scheme == "vless":
        host = split.hostname or ""
        port_num = split.port or 443
        port = f":{port_num}" if split.port else ""
        user = split.username or ""
        netloc = f"{user}@{host}{port}" if user else f"{host}{port}"
        return urllib.parse.urlunsplit((split.scheme, netloc, split.path, split.query, clean_label(host, old_label, f"Reality {port_num}")))
    return raw

with open(sys.argv[1], "r", encoding="utf-8", errors="replace") as fh:
    for line in fh:
        out = one(line)
        if out:
            print(out)
PY
    rm -f "$tmp_input" 2>/dev/null || true
}

hiddify_compat_links() {
    if ! command -v python3 >/dev/null 2>&1; then
        cat
        return 0
    fi
    local tmp_input
    tmp_input=$(mktemp /tmp/yurich_hiddify_links_XXXXXX.txt) || return 1
    cat > "$tmp_input"
    python3 - "$tmp_input" <<'PY'
import sys
import urllib.parse

def loc_code(host, label):
    text = f"{host} {label}".lower()
    if "swe.go-it" in text or "sweden" in text or "stockholm" in text or "swe •" in text:
        return "SWE"
    if "finland 2" in text or "finland2" in text or "n8n" in text:
        return "FI2"
    if "poland" in text or "warsaw" in text or "polska" in text:
        return "PL"
    if "usa" in text or "america" in text or "california" in text:
        return "US"
    if "russia" in text or "russian" in text or "moscow" in text or "rus.go-it" in text or "ru " in text:
        return "RU"
    if "finland" in text or "helsinki" in text or "suomi" in text or "dns-ai" in text:
        return "FI"
    if "germany" in text or "deutschland" in text or "frankfurt" in text or "plus-dns" in text:
        return "DE"
    if "netherlands" in text or "amsterdam" in text or "net-it" in text:
        return "NL"
    return "VPN"

def clean_label(host, old_label, proto):
    return urllib.parse.quote(f"{loc_code(host, old_label)} {proto}", safe="-._~")

def first(query, key, default=""):
    values = query.get(key)
    return values[0] if values else default

def one(line):
    raw = line.strip()
    if not raw:
        return ""
    split = urllib.parse.urlsplit(raw)
    old_label = urllib.parse.unquote(split.fragment or "")
    scheme = split.scheme.lower()
    if scheme in ("hy2", "hysteria2"):
        query = urllib.parse.parse_qs(split.query, keep_blank_values=True)
        auth = first(query, "auth")
        if not auth and split.username:
            auth = urllib.parse.unquote(split.username)
            if split.password is not None:
                auth += ":" + urllib.parse.unquote(split.password)
        host = split.hostname or ""
        port = split.port or 443
        sni = first(query, "sni", host)
        obfs = first(query, "obfs", "salamander")
        obfs_password = first(query, "obfs-password") or first(query, "obfs_password")
        pairs = [
            ("sni", sni),
            ("obfs", obfs),
            ("obfs-password", obfs_password),
        ]
        for key, values in query.items():
            if key in {"auth", "sni", "obfs", "obfs-password", "obfs_password"}:
                continue
            for value in values:
                pairs.append((key, value))
        q = urllib.parse.urlencode([(k, v) for k, v in pairs if v != ""])
        userinfo = urllib.parse.quote(auth, safe="") + "@" if auth else ""
        return f"hysteria2://{userinfo}{host}:{port}/?{q}#{clean_label(host, old_label, 'Turbo')}"
    if scheme == "vless":
        host = split.hostname or ""
        port_num = split.port or 443
        port = f":{port_num}" if split.port else ""
        user = split.username or ""
        netloc = f"{user}@{host}{port}" if user else f"{host}{port}"
        drop = {"headerType", "packetEncoding"}
        pairs = [(k, v) for k, v in urllib.parse.parse_qsl(split.query, keep_blank_values=True) if k not in drop]
        query = urllib.parse.urlencode(pairs)
        return urllib.parse.urlunsplit((split.scheme, netloc, split.path, query, clean_label(host, old_label, "Reality")))
    return raw

with open(sys.argv[1], "r", encoding="utf-8", errors="replace") as fh:
    for line in fh:
        out = one(line)
        if out:
            print(out)
PY
    rm -f "$tmp_input" 2>/dev/null || true
}

subscription_profile_name() {
    local protocol="$1" node="${2:-}" label
    label=$(profile_location_label)
    if [[ -n "$node" ]]; then
        printf '%s %s %s\n' "$label" "$node" "$protocol"
    else
        printf '%s %s\n' "$label" "$protocol"
    fi
}

uri_with_profile_name() {
    local uri="$1" name="$2"
    [[ -n "$uri" ]] || return 0
    printf '%s#%s\n' "${uri%%#*}" "$(uri_fragment_encode "$name")"
}

xray_reality_public_port() {
    local public_port="${XRAY_REALITY_PUBLIC_PORT:-}"
    if [[ -z "$public_port" && "${XRAY_REALITY_SNI_MUX_ENABLED:-0}" == "1" ]]; then
        public_port="443"
    fi
    if [[ -z "$public_port" ]]; then
        public_port="${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
    fi
    if [[ "$public_port" =~ ^[0-9]+$ ]]; then
        printf '%s\n' "$public_port"
    else
        printf '%s\n' "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
    fi
}

yurich_proxy_uri() {
    local user="$1" pass="$2" tag="${3:-}"
    printf 'yurich://proxy?transport=naive&server=%s&port=443&username=%s&password=%s' "$DOMAIN" "$user" "$pass"
    [[ -n "$tag" ]] && printf '#%s' "$(uri_fragment_encode "$tag")"
    printf '\n'
}

singbox_naive_tun_json() {
    local user="$1" pass="$2" dns_ip
    dns_ip=$(yurich_dns_client_ip)
    if [[ -n "$dns_ip" ]]; then
        cat <<EOF
{
  "dns": {
    "servers": [
      {
        "tag": "yurich-dns",
        "address": "tcp://${dns_ip}:53",
        "detour": "naiveproxy-out"
      }
    ],
    "final": "yurich-dns",
    "strategy": "ipv4_only"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": "172.19.0.1/30",
      "auto_route": true,
      "strict_route": true
    }
  ],
  "outbounds": [
    {
      "type": "naive",
      "tag": "naiveproxy-out",
      "server": "${DOMAIN}",
      "server_port": 443,
      "username": "${user}",
      "password": "${pass}",
      "tls": { "enabled": true, "server_name": "${DOMAIN}" }
    },
    { "type": "direct", "tag": "direct" }
  ],
  "route": {
    "rules": [
      { "protocol": "dns", "outbound": "naiveproxy-out" }
    ],
    "final": "naiveproxy-out",
    "auto_detect_interface": true
  }
}
EOF
    else
        cat <<EOF
{
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": "172.19.0.1/30",
      "auto_route": true,
      "strict_route": true
    }
  ],
  "outbounds": [
    {
      "type": "naive",
      "tag": "naiveproxy-out",
      "server": "${DOMAIN}",
      "server_port": 443,
      "username": "${user}",
      "password": "${pass}",
      "tls": { "enabled": true, "server_name": "${DOMAIN}" }
    },
    { "type": "direct", "tag": "direct" }
  ],
  "route": { "final": "naiveproxy-out" }
}
EOF
    fi
}

print_client_config() {
    load_config
    hr
    echo -e "${BOLD}${GREEN}  Клиентский конфиг Yurich Proxy${RESET}"
    hr

    local first_user first_pass selected_user
    selected_user="${1:-}"
    if [[ -n "$selected_user" ]]; then
        if ! is_valid_proxy_user "$selected_user" || ! get_user_pass "$selected_user" >/dev/null; then
            err "Пользователь $selected_user не найден"
            return 1
        fi
        first_user="$selected_user"
        first_pass=$(get_user_pass "$selected_user")
    else
        first_user=$(get_users | head -1 | cut -d: -f1)
        first_pass=$(get_users | head -1 | cut -d: -f2)
    fi

    if [[ -z "${first_user:-}" ]]; then
        warn "Нет пользователей. Добавь через меню → Пользователи."
        return
    fi

    echo -e "${CYAN}  Стек сервера:${RESET}"
    echo -e "  Yurich Proxy (Naive-compatible transport) + Caddy 2 + klzgrad/forwardproxy@naive"
    echo -e "  Пользователь: ${BOLD}${first_user}${RESET} | срок: ${CYAN}$(user_expiry_label "$first_user")${RESET}"
    echo
    echo -e "${YELLOW}  Важно для приложений:${RESET}"
    echo -e "  Yurich Proxy сейчас использует совместимый transport ${BOLD}naive${RESET}."
    echo -e "  В обычных приложениях выбирай тип ${BOLD}NaiveProxy / naive${RESET}, а не VLESS/Trojan/Shadowsocks."
    echo -e "  Фирменная ссылка ${BOLD}yurich://...${RESET} — задел под будущий Yurich-клиент."
    echo -e "  Если в приложении нет native naive support, используй HTTPS proxy fallback ниже."
    echo -e "  Для телефона включай VPN/TUN mode, иначе не весь трафик пойдёт через прокси."
    echo
    echo -e "${CYAN}  Yurich link (для будущего Yurich-клиента):${RESET}"
    echo -e "  $(yurich_proxy_uri "$first_user" "$first_pass" "${first_user}-yurich")"
    echo
    echo -e "${CYAN}  Совместимый URI (naive, для текущих клиентов):${RESET}"
    echo -e "  naive+https://${first_user}:${first_pass}@${DOMAIN}:443"
    echo
    echo -e "${CYAN}  JSON (naive-client):${RESET}"
    cat <<EOF
  {
    "listen": "socks://127.0.0.1:1080",
    "proxy": "https://${first_user}:${first_pass}@${DOMAIN}:443"
  }
EOF
    echo
    echo -e "${CYAN}  JSON (sing-box outbound, native naive):${RESET}"
    cat <<EOF
  {
    "type": "naive",
    "tag": "naiveproxy-out",
    "server": "${DOMAIN}",
    "server_port": 443,
    "username": "${first_user}",
    "password": "${first_pass}",
    "tls": { "enabled": true, "server_name": "${DOMAIN}" }
  }
EOF
    echo
    echo -e "${CYAN}  JSON (sing-box полный пример, Android VPN/TUN):${RESET}"
    if [[ -n "$(yurich_dns_client_ip)" ]]; then
        echo -e "${GREEN}  DNS (Unbound) включён:${RESET} DNS в этом примере идёт через ${CYAN}tcp://$(yurich_dns_client_ip):53${RESET}"
    else
        echo -e "${YELLOW}  DNS (Unbound) для клиентов выключен:${RESET} меню 17 → 2 включит DNS в этот пример."
    fi
    singbox_naive_tun_json "$first_user" "$first_pass" | sed 's/^/  /'
    echo
    echo -e "${CYAN}  Fallback HTTPS proxy (если приложение не умеет native NaiveProxy):${RESET}"
    cat <<EOF
  {
    "type": "http",
    "tag": "https-connect-fallback",
    "server": "${DOMAIN}",
    "server_port": 443,
    "username": "${first_user}",
    "password": "${first_pass}",
    "tls": { "enabled": true, "server_name": "${DOMAIN}" }
  }
EOF

    if [[ ( -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ) && -n "${HYSTERIA_OBFS_PASSWORD:-}" ]]; then
        local hy2_uri hy2_auth
        hy2_uri=$(hysteria_uri_for_user "$first_user" 2>/dev/null || true)
        hy2_auth=$(hysteria_user_auth "$first_user" 2>/dev/null || true)
        if [[ -n "$hy2_uri" && -n "$hy2_auth" ]]; then
            echo
            echo -e "${CYAN}  Hysteria 2 (персональный UDP/QUIC):${RESET}"
            echo -e "  ${hy2_uri}"
            echo
            echo -e "${CYAN}  JSON (sing-box outbound, Hysteria 2):${RESET}"
            cat <<EOF
  {
    "type": "hysteria2",
    "tag": "hysteria2-out",
    "server": "${DOMAIN}",
    "server_port": ${HYSTERIA_PORT:-8443},
    "password": "${hy2_auth}",
    "obfs": {
      "type": "salamander",
      "password": "${HYSTERIA_OBFS_PASSWORD}"
    },
    "tls": { "enabled": true, "server_name": "${DOMAIN}" }
  }
EOF
        fi
    fi

    local count; count=$(get_users | wc -l)
    if [[ -z "$selected_user" && $count -gt 1 ]]; then
        echo
        info "Все пользователи ($count):"
        while IFS=: read -r u p; do
            echo -e "  [USER] ${BOLD}$u${RESET} : Yurich $(yurich_proxy_uri "$u" "$p" "${u}-yurich")"
            echo -e "     native: naive+https://${u}:${p}@${DOMAIN}:443"
        done < <(get_users)
    fi
    # QR код для быстрого подключения
    echo
    info "QR код для быстрого подключения с телефона:"
    local uri="naive+https://${first_user}:${first_pass}@${DOMAIN}:443"
    if command -v qrencode &>/dev/null; then
        echo
        qrencode -t ANSIUTF8 "$uri"
        echo
    else
        info "Устанавливаю qrencode для QR кода..."
        apt-get install -y -q qrencode 2>/dev/null &&         echo && qrencode -t ANSIUTF8 "$uri" && echo ||         warn "qrencode недоступен — установи вручную: apt install qrencode"
    fi
    ok "QR содержит совместимый naive+https URI для NekoBox / Shadowrocket / Hiddify"
    hr
}

# ─── HYSTERIA 2 ───────────────────────────────────────────────
install_hysteria_bin() {
    local arch asset url tmp_bin tmp_hash expected actual
    arch=$(detect_hysteria_arch) || return 1
    asset="hysteria-linux-${arch}"
    if [[ -x "$HYSTERIA_BIN" ]]; then
        if "$HYSTERIA_BIN" version >/dev/null 2>&1; then
            ok "Hysteria 2 уже установлен: $("$HYSTERIA_BIN" version 2>/dev/null | head -1 || echo "$HYSTERIA_BIN")"
            return 0
        fi
        warn "Найден Hysteria 2 binary, но он не запускается. Переустанавливаю."
    fi
    if [[ "${HYSTERIA_VERSION_PIN:-latest}" == "latest" ]]; then
        url="https://github.com/apernet/hysteria/releases/latest/download/${asset}"
    else
        url="https://github.com/apernet/hysteria/releases/download/${HYSTERIA_VERSION_PIN}/${asset}"
    fi
    tmp_bin=$(mktemp /tmp/hysteria_XXXXXX)
    tmp_hash=$(mktemp /tmp/hysteria_hashes_XXXXXX)
    trap 'rm -f "${tmp_bin:-}" "${tmp_hash:-}" 2>/dev/null; trap - RETURN' RETURN

    info "Скачиваю Hysteria 2 (${asset})..."
    if ! curl -fsSL --retry 3 --connect-timeout 15 --max-time 180 "$url" -o "$tmp_bin"; then
        err "Не удалось скачать Hysteria 2: $url"
        return 1
    fi

    if curl -fsSL --connect-timeout 10 --max-time 30 \
        "${url%/${asset}}/hashes.txt" -o "$tmp_hash" 2>/dev/null; then
        expected=$(grep -F "$asset" "$tmp_hash" | awk '{for(i=1;i<=NF;i++) if($i ~ /^[a-fA-F0-9]{64}$/){print tolower($i); exit}}' | head -1)
        if [[ -n "$expected" ]]; then
            actual=$(sha256sum "$tmp_bin" | awk '{print $1}')
            if [[ "$actual" != "$expected" ]]; then
                err "SHA256 Hysteria 2 не совпадает. Установка остановлена."
                return 1
            fi
            ok "SHA256 Hysteria 2 подтверждён"
        else
            if [[ "${YURICH_ALLOW_UNVERIFIED_DOWNLOADS:-0}" == "1" ]]; then
                warn "Не нашёл SHA256 для ${asset} в hashes.txt, продолжаю из-за YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
            else
                err "Не нашёл SHA256 для ${asset} в hashes.txt. Установка остановлена."
                return 1
            fi
        fi
    else
        if [[ "${YURICH_ALLOW_UNVERIFIED_DOWNLOADS:-0}" == "1" ]]; then
            warn "Не удалось скачать hashes.txt, продолжаю из-за YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
        else
            err "Не удалось скачать hashes.txt. Установка Hysteria 2 остановлена."
            return 1
        fi
    fi

    install -m 755 "$tmp_bin" "$HYSTERIA_BIN"
    ok "Hysteria 2 установлен: $("$HYSTERIA_BIN" version 2>/dev/null | head -1 || echo "$HYSTERIA_BIN")"
    info "Hysteria release pin: ${HYSTERIA_VERSION_PIN:-latest}"
}

write_hysteria_config() {
    load_config
    load_users
    local cert_file key_file users_for_hysteria hy_warp_enabled=0 hysteria_config_backup=""
    ensure_hysteria_secrets || return 1
    save_config
    cert_file=$(find_caddy_cert "${DOMAIN:-}" || true)
    key_file=$(find_caddy_key "${DOMAIN:-}" || true)
    users_for_hysteria=$(get_active_users 2>/dev/null || true)
    if [[ "${HYSTERIA_WARP_ENABLED:-0}" == "1" || "${WARP_PROXY_ENABLED:-0}" == "1" ]]; then
        hy_warp_enabled=1
    fi

    if [[ -z "$cert_file" || -z "$key_file" ]]; then
        err "Не нашёл TLS сертификат Caddy для ${DOMAIN:-не задан}"
        err "Сначала запусти Yurich Panel и дождись TLS: sudo bash yurich-panel.sh install"
        return 1
    fi
    if [[ -z "$users_for_hysteria" ]]; then
        users_for_hysteria="__disabled__:$(random_safe_token 32)"
        warn "Нет активных пользователей. Hysteria 2 закрыт placeholder-auth."
    fi

    mkdir -p "$CONFIG_DIR"
    if [[ -f "$HYSTERIA_CONFIG" ]]; then
        hysteria_config_backup=$(mktemp /tmp/yurich_hysteria_backup_XXXXXX.yaml)
        cp "$HYSTERIA_CONFIG" "$hysteria_config_backup" 2>/dev/null || hysteria_config_backup=""
    fi
    cat > "$HYSTERIA_CONFIG" <<EOF
# Hysteria 2 работает отдельно от Caddy:
# TCP/443 -> Caddy NaiveProxy, UDP/${HYSTERIA_PORT:-8443} -> Hysteria 2
listen: :${HYSTERIA_PORT:-8443}

tls:
  cert: ${cert_file}
  key: ${key_file}
  sniGuard: strict

auth:
EOF
    cat >> "$HYSTERIA_CONFIG" <<EOF
  type: userpass
  userpass:
EOF
    while IFS=: read -r h_user h_pass; do
        [[ -z "$h_user" || -z "$h_pass" ]] && continue
        printf '    "%s": "%s"\n' "$h_user" "$h_pass" >> "$HYSTERIA_CONFIG"
    done <<< "$users_for_hysteria"

    cat >> "$HYSTERIA_CONFIG" <<EOF

obfs:
  type: salamander
  salamander:
    password: "${HYSTERIA_OBFS_PASSWORD}"

masquerade:
  type: proxy
  proxy:
    url: https://${DOMAIN}/
    rewriteHost: true

quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520
  maxIdleTimeout: 30s
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false

sniff:
  enable: true
  timeout: 2s
  rewriteDomain: false
  tcpPorts: 80,443
  udpPorts: all
EOF
    if [[ "$hy_warp_enabled" == "1" ]]; then
        cat >> "$HYSTERIA_CONFIG" <<EOF

# WARP local proxy outbound.
# Without ACL Hysteria routes all server-side exits through the first outbound.
outbounds:
  - name: warp-socks5
    type: socks5
    socks5:
      addr: 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}
  - name: direct
    type: direct
EOF
    fi
    chmod 600 "$HYSTERIA_CONFIG"

    if ! validate_hysteria_config "$HYSTERIA_CONFIG"; then
        if [[ -n "$hysteria_config_backup" && -s "$hysteria_config_backup" ]]; then
            mv -f "$hysteria_config_backup" "$HYSTERIA_CONFIG"
            chmod 600 "$HYSTERIA_CONFIG" 2>/dev/null || true
            warn "Рабочий Hysteria config восстановлен из бэкапа"
        else
            rm -f "$HYSTERIA_CONFIG" 2>/dev/null || true
            warn "Новый нерабочий Hysteria config удалён"
        fi
        return 1
    fi
    [[ -n "$hysteria_config_backup" ]] && rm -f "$hysteria_config_backup" 2>/dev/null || true

    ok "Hysteria 2 конфиг записан: $HYSTERIA_CONFIG"
    if [[ "$hy_warp_enabled" == "1" ]]; then
        ok "Hysteria 2 outbound направлен через WARP SOCKS5: 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    fi
}

write_hysteria_service() {
    cat > "$HYSTERIA_SERVICE" <<EOF
[Unit]
Description=Hysteria 2 Proxy
Documentation=https://v2.hysteria.network/
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=${HYSTERIA_BIN} server -c ${HYSTERIA_CONFIG}
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable hysteria --quiet
    ok "systemd сервис Hysteria 2 настроен"
}

hysteria_user_auth() {
    local selected_user="${1:-}" selected_pass first_user first_pass
    load_users

    if [[ -n "$selected_user" ]]; then
        if ! is_valid_proxy_user "$selected_user" || ! selected_pass=$(get_active_user_pass "$selected_user" 2>/dev/null); then
            err "Пользователь $selected_user не найден для Hysteria"
            return 1
        fi
        printf '%s:%s\n' "$selected_user" "$selected_pass"
        return 0
    fi

    first_user=$(get_active_users | head -1 | cut -d: -f1)
    first_pass=$(get_active_users | head -1 | cut -d: -f2)
    if [[ -n "$first_user" && -n "$first_pass" ]]; then
        printf '%s:%s\n' "$first_user" "$first_pass"
        return 0
    fi

    err "Нет активных пользователей для Hysteria"
    return 1
}

hysteria_uri_for_user() {
    local selected_user="${1:-}" server_ports="${2:-${HYSTERIA_PORT:-8443}}" auth
    auth=$(hysteria_user_auth "$selected_user") || return 1
    [[ -z "$auth" ]] && return 1
    printf 'hy2://%s@%s:%s/?sni=%s&obfs=salamander&obfs-password=%s' \
        "$auth" "${DOMAIN}" "$server_ports" "${DOMAIN}" "${HYSTERIA_OBFS_PASSWORD}"
    if [[ -n "$selected_user" ]]; then
        printf '#%s-hy2' "$selected_user"
    fi
    printf '\n'
}

hysteria_happ_uri_for_user() {
    local selected_user="${1:-}" server_ports="${2:-${HYSTERIA_PORT:-8443}}" auth
    auth=$(hysteria_user_auth "$selected_user") || return 1
    [[ -z "$auth" ]] && return 1
    printf 'hy2://%s:%s/?auth=%s&sni=%s&obfs=salamander&obfs-password=%s\n' \
        "${DOMAIN}" "$server_ports" "$(uri_query_encode "$auth")" "$(uri_query_encode "$DOMAIN")" "$(uri_query_encode "$HYSTERIA_OBFS_PASSWORD")"
}

validate_hysteria_config() {
    local config="${1:-$HYSTERIA_CONFIG}" test_config test_log test_port rc line

    if [[ ! -s "$config" ]]; then
        err "Hysteria config не найден или пустой: $config"
        return 1
    fi
    grep -q '^listen:' "$config" || { err "Hysteria config: нет listen"; return 1; }
    grep -q '^tls:' "$config" || { err "Hysteria config: нет tls"; return 1; }
    grep -q '^auth:' "$config" || { err "Hysteria config: нет auth"; return 1; }
    grep -q 'type: userpass' "$config" || { err "Hysteria config: auth не userpass"; return 1; }
    grep -q '^obfs:' "$config" || { err "Hysteria config: нет obfs"; return 1; }

    if [[ ! -x "$HYSTERIA_BIN" ]]; then
        warn "Hysteria binary не найден, выполняю только структурную проверку config"
        return 0
    fi
    command -v timeout >/dev/null 2>&1 || {
        warn "timeout не найден, выполняю только структурную проверку Hysteria config"
        return 0
    }

    test_config=$(mktemp /tmp/yurich_hysteria_check_XXXXXX.yaml) || return 1
    test_log=$(mktemp /tmp/yurich_hysteria_check_XXXXXX.log) || {
        rm -f "$test_config" 2>/dev/null || true
        return 1
    }

    for _ in {1..25}; do
        test_port=$((40000 + RANDOM % 20000))
        if ! ss -lun 2>/dev/null | awk '{print $5}' | grep -Eq "[:.]${test_port}$"; then
            break
        fi
        test_port=""
    done
    if [[ -z "$test_port" ]]; then
        rm -f "$test_config" "$test_log" 2>/dev/null || true
        err "Не удалось подобрать временный UDP порт для проверки Hysteria"
        return 1
    fi

    sed -E "0,/^listen:/s#^listen:.*#listen: 127.0.0.1:${test_port}#" "$config" > "$test_config"
    if timeout 3s "$HYSTERIA_BIN" server -c "$test_config" >"$test_log" 2>&1; then
        rc=0
    else
        rc=$?
    fi

    case "$rc" in
        0|124)
            rm -f "$test_config" "$test_log" 2>/dev/null || true
            return 0
            ;;
        *)
            err "Hysteria config не прошёл runtime-проверку"
            sed -n '1,20p' "$test_log" 2>/dev/null || true
            rm -f "$test_config" "$test_log" 2>/dev/null || true
            return 1
            ;;
    esac
}

hysteria_port_hop_range() {
    local range="${HYSTERIA_PORT_HOP_PORTS:-$HYSTERIA_PORT_HOP_PORTS_DEFAULT}" start end
    [[ "$range" =~ ^[0-9]{2,5}-[0-9]{2,5}$ ]] || range="$HYSTERIA_PORT_HOP_PORTS_DEFAULT"
    start="${range%-*}"
    end="${range#*-}"
    if (( start < 1024 || end > 65535 || start >= end )); then
        range="$HYSTERIA_PORT_HOP_PORTS_DEFAULT"
    fi
    printf '%s\n' "$range"
}

hysteria_port_hop_enabled() {
    [[ "${HYSTERIA_PORT_HOP_ENABLED:-0}" == "1" ]] || return 1
    hysteria_port_hop_range >/dev/null
}

hysteria_port_hop_server_ports() {
    local main_port="${HYSTERIA_PORT:-8443}" hop_range
    hop_range=$(hysteria_port_hop_range)
    printf '%s,%s\n' "$main_port" "$hop_range"
}

hysteria_port_hop_uri_for_user() {
    local selected_user="${1:-}" server_ports
    hysteria_port_hop_enabled || return 1
    server_ports=$(hysteria_port_hop_server_ports)
    hysteria_uri_for_user "$selected_user" "$server_ports"
}

remove_hysteria_port_hop_rules() {
    if [[ -x "$HYSTERIA_PORT_HOP_SCRIPT" ]]; then
        "$HYSTERIA_PORT_HOP_SCRIPT" stop >/dev/null 2>&1 || true
    fi
    systemctl disable --now yurich-hysteria-port-hop >/dev/null 2>&1 || true
}

apply_hysteria_port_hop() {
    load_config
    if ! hysteria_port_hop_enabled; then
        remove_hysteria_port_hop_rules
        return 0
    fi

    local range start end target ufw_range
    range=$(hysteria_port_hop_range)
    start="${range%-*}"
    end="${range#*-}"
    target="${HYSTERIA_PORT:-8443}"
    ufw_range="${start}:${end}"

    if ! command -v iptables >/dev/null 2>&1; then
        err "iptables не найден: Hysteria 2 port hopping не сможет поставить UDP redirect"
        err "Установи iptables или выключи port hopping"
        return 1
    fi

    mkdir -p "$(dirname "$HYSTERIA_PORT_HOP_SCRIPT")"
    cat > "$HYSTERIA_PORT_HOP_SCRIPT" <<EOF
#!/bin/bash
set -euo pipefail
ACTION="\${1:-start}"
START="${start}"
END="${end}"
TARGET="${target}"
RANGE="\${START}:\${END}"
COMMENT="Yurich Hysteria2 port hopping"

have_iptables() { command -v iptables >/dev/null 2>&1; }

public_ipv4_list() {
    ip -o -4 addr show scope global 2>/dev/null \\
        | awk '{split(\$4,a,"/"); print a[1]}' \\
        | grep -Ev '^(10\\.|127\\.|169\\.254\\.|172\\.(1[6-9]|2[0-9]|3[0-1])\\.|192\\.168\\.)' || true
}

add_rule() {
    have_iptables || return 0
    iptables -t nat -C PREROUTING -p udp --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null \\
        || iptables -t nat -A PREROUTING -p udp --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null || true
    local ip
    for ip in \$(public_ipv4_list); do
        iptables -t nat -C OUTPUT -p udp -d "\${ip}" --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null \\
            || iptables -t nat -A OUTPUT -p udp -d "\${ip}" --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null || true
    done
}

del_rule() {
    have_iptables || return 0
    while iptables -t nat -C PREROUTING -p udp --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null; do
        iptables -t nat -D PREROUTING -p udp --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null || break
    done
    local ip
    for ip in \$(public_ipv4_list); do
        while iptables -t nat -C OUTPUT -p udp -d "\${ip}" --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null; do
            iptables -t nat -D OUTPUT -p udp -d "\${ip}" --dport "\${RANGE}" -m comment --comment "\${COMMENT}" -j REDIRECT --to-ports "\${TARGET}" 2>/dev/null || break
        done
    done
}

case "\${ACTION}" in
    start|reload|restart)
        del_rule
        add_rule
        ;;
    stop)
        del_rule
        ;;
    *)
        echo "usage: \$0 {start|stop|reload}" >&2
        exit 2
        ;;
esac
EOF
    chmod 755 "$HYSTERIA_PORT_HOP_SCRIPT"

    cat > "$HYSTERIA_PORT_HOP_SERVICE" <<EOF
[Unit]
Description=Yurich Hysteria 2 UDP port hopping redirect
Documentation=https://v2.hysteria.network/docs/advanced/Port-Hopping/
After=network-online.target
Before=hysteria.service
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${HYSTERIA_PORT_HOP_SCRIPT} start
ExecReload=${HYSTERIA_PORT_HOP_SCRIPT} reload
ExecStop=${HYSTERIA_PORT_HOP_SCRIPT} stop

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    if command -v ufw >/dev/null 2>&1; then
        ufw allow "${ufw_range}/udp" comment "Hysteria2 Port Hopping" >/dev/null 2>&1 || true
    fi
    systemctl enable yurich-hysteria-port-hop >/dev/null 2>&1 || true
    systemctl restart yurich-hysteria-port-hop >/dev/null 2>&1 || "$HYSTERIA_PORT_HOP_SCRIPT" start
    if ! iptables -t nat -C PREROUTING -p udp --dport "${ufw_range}" -m comment --comment "Yurich Hysteria2 port hopping" -j REDIRECT --to-ports "${target}" 2>/dev/null; then
        err "Hysteria 2 port hopping rule не применился: UDP/${range} -> UDP/${target}"
        journalctl -u yurich-hysteria-port-hop -n 20 --no-pager 2>/dev/null || true
        return 1
    fi
    ok "Hysteria 2 port hopping: UDP/${range} -> UDP/${target}"
}

sync_hysteria_users_if_active() {
    load_config
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        info "Обновляю Hysteria 2 userpass по текущим пользователям..."
        if write_hysteria_config && apply_hysteria_port_hop && systemctl restart hysteria 2>/dev/null; then
            ok "Hysteria 2 обновлён для пользователей"
            return 0
        fi
        warn "Hysteria 2 не удалось обновить автоматически. Проверь: sudo bash yurich-panel.sh hysteria-status"
        return 1
    fi
    return 0
}

print_hysteria_client_config() {
    load_config
    local selected_user="${1:-}"
    if [[ -z "${DOMAIN:-}" || -z "${HYSTERIA_OBFS_PASSWORD:-}" ]]; then
        warn "Hysteria 2 ещё не настроен. Запусти: sudo bash yurich-panel.sh hysteria"
        return 1
    fi

    local hy2_uri hy2_auth auth_label
    hy2_auth=$(hysteria_user_auth "$selected_user") || return 1
    if [[ -z "$hy2_auth" ]]; then
        warn "Нет Hysteria auth. Добавь пользователя или переустанови Hysteria 2."
        return 1
    fi
    hy2_uri=$(hysteria_uri_for_user "$selected_user") || return 1
    if [[ "$hy2_auth" == *:* ]]; then
        auth_label="userpass (${hy2_auth%%:*})"
    else
        auth_label="общий password"
    fi
    hr
    echo -e "${BOLD}${GREEN}  Клиентский конфиг Hysteria 2${RESET}"
    hr
    echo -e "${CYAN}  Стек:${RESET} Hysteria 2 / QUIC / UDP ${HYSTERIA_PORT:-8443}"
    echo -e "${CYAN}  Auth:${RESET} ${auth_label}"
    echo -e "${YELLOW}  Не конфликтует с NaiveProxy:${RESET} Caddy остаётся на TCP/443, Hysteria 2 на UDP/${HYSTERIA_PORT:-8443}"
    echo
    echo -e "${CYAN}  URI:${RESET}"
    echo -e "  ${hy2_uri}"
    echo
    echo -e "${CYAN}  sing-box outbound:${RESET}"
    cat <<EOF
  {
    "type": "hysteria2",
    "tag": "hysteria2-out",
    "server": "${DOMAIN}",
    "server_port": ${HYSTERIA_PORT:-8443},
    "password": "${hy2_auth}",
    "obfs": {
      "type": "salamander",
      "password": "${HYSTERIA_OBFS_PASSWORD}"
    },
    "tls": {
      "enabled": true,
      "server_name": "${DOMAIN}"
    }
  }
EOF
    if [[ -n "$(yurich_dns_client_ip)" ]]; then
        echo
        echo -e "${CYAN}  DNS (Unbound) для full TUN/sing-box:${RESET}"
        echo -e "  DNS server: ${GREEN}tcp://$(yurich_dns_client_ip):53${RESET}"
        echo -e "  detour: ${GREEN}hysteria2-out${RESET}"
    fi
    echo
    if command -v qrencode &>/dev/null; then
        qrencode -t ANSIUTF8 "$hy2_uri"
    else
        info "Для QR установи: apt install qrencode"
    fi
    hr
}

choose_hysteria_port() {
    local requested_port="${1:-}" current_port="${HYSTERIA_PORT:-8443}" choice custom_port next_port ans

    if [[ -n "$requested_port" ]]; then
        if ! is_valid_port "$requested_port"; then
            err "Неверный порт: $requested_port"
            return 1
        fi
        next_port="$requested_port"
        if [[ "$next_port" != "$current_port" ]] && ss -ulpn 2>/dev/null | grep -E ":${next_port}([[:space:]]|$)" >/dev/null; then
            warn "UDP порт ${next_port} уже слушается. Продолжаю, потому что это неинтерактивный режим."
        fi
        HYSTERIA_PORT="$next_port"
        ok "Hysteria 2 порт: UDP/${HYSTERIA_PORT}"
        return 0
    fi

    echo -e "${CYAN}Порт Hysteria 2:${RESET}"
    echo -e "  ${BOLD}1)${RESET} По умолчанию UDP/8443 ${DIM}(рекомендуется)${RESET}"
    echo -e "  ${BOLD}2)${RESET} Указать вручную"
    echo -ne "${CYAN}Выбор [1/2] (Enter = 1): ${RESET}"
    read -r choice

    case "$choice" in
        1|"")
            next_port="8443"
            ;;
        2|m|M|manual|Manual|ручной)
            echo -ne "${CYAN}UDP порт Hysteria 2 [${current_port}]: ${RESET}"
            read -r custom_port
            next_port="${custom_port:-$current_port}"
            ;;
        *)
            err "Неверный выбор"
            return 1
            ;;
    esac

    if ! is_valid_port "$next_port"; then
        err "Неверный порт: $next_port"
        return 1
    fi

    if [[ "$next_port" == "443" ]]; then
        warn "UDP/443 может конфликтовать с Caddy HTTP/3. Рекомендую 8443."
        echo -ne "${YELLOW}Оставить UDP/443? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || next_port="8443"
    fi

    if [[ "$next_port" != "$current_port" ]] && ss -ulpn 2>/dev/null | grep -E ":${next_port}([[:space:]]|$)" >/dev/null; then
        warn "UDP порт ${next_port} уже слушается. Проверь: ss -ulpn | grep ':${next_port}'"
        echo -ne "${YELLOW}Продолжить всё равно? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || return 1
    fi

    HYSTERIA_PORT="$next_port"
    ok "Hysteria 2 порт: UDP/${HYSTERIA_PORT}"
}

cmd_hysteria_install() {
    load_config
    if [[ -z "${DOMAIN:-}" ]]; then
        err "Домен не настроен. Сначала установи Yurich Panel."
        return 1
    fi

    hr
    echo -e "${BOLD}  Установка Hysteria 2${RESET}"
    hr
    echo -e "  NaiveProxy остаётся: ${CYAN}TCP/443${RESET}"
    echo -e "  Hysteria 2 будет:   ${CYAN}UDP/${HYSTERIA_PORT:-8443}${RESET} или ручной порт"
    echo

    choose_hysteria_port || return 1

    ensure_hysteria_secrets || return 1
    save_config

    install_hysteria_bin || return 1
    write_hysteria_config || return 1
    write_hysteria_service || return 1
    ufw allow "${HYSTERIA_PORT}/udp" comment "Hysteria2 QUIC" >/dev/null 2>&1 || true
    apply_hysteria_port_hop || return 1
    save_config

    info "Запускаю Hysteria 2..."
    if systemctl restart hysteria && sleep 2 && systemctl is-active --quiet hysteria; then
        ok "Hysteria 2 запущен на UDP/${HYSTERIA_PORT}"
        print_hysteria_client_config
    else
        err "Hysteria 2 не запустился. Лог:"
        journalctl -u hysteria -n 30 --no-pager
        return 1
    fi
}

cmd_hysteria_change_port() {
    load_config
    local requested_port="${1:-}"
    local old_port="${HYSTERIA_PORT:-8443}"
    hr
    echo -e "${BOLD}  Смена UDP порта Hysteria 2${RESET}"
    hr
    echo -e "  Текущий порт: ${CYAN}UDP/${old_port}${RESET}"
    echo

    choose_hysteria_port "$requested_port" || return 1
    if [[ "$old_port" == "${HYSTERIA_PORT}" ]]; then
        ok "Порт не изменился"
        save_config
        return 0
    fi

    save_config
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        write_hysteria_config || return 1
        ufw delete allow "${old_port}/udp" >/dev/null 2>&1 || true
        ufw allow "${HYSTERIA_PORT}/udp" comment "Hysteria2 QUIC" >/dev/null 2>&1 || true
        apply_hysteria_port_hop || return 1
        if systemctl restart hysteria && sleep 2 && systemctl is-active --quiet hysteria; then
            ok "Hysteria 2 перезапущен на UDP/${HYSTERIA_PORT}"
        else
            err "Hysteria 2 не запустился после смены порта. Лог:"
            journalctl -u hysteria -n 30 --no-pager
            return 1
        fi
    fi
}

cmd_hysteria_hop_enable() {
    load_config
    local range="${1:-${HYSTERIA_PORT_HOP_PORTS:-$HYSTERIA_PORT_HOP_PORTS_DEFAULT}}"
    HYSTERIA_PORT_HOP_PORTS="$range"
    HYSTERIA_PORT_HOP_ENABLED="1"
    HYSTERIA_PORT_HOP_PORTS="$(hysteria_port_hop_range)"
    save_config
    apply_hysteria_port_hop || return 1
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        write_hysteria_config || return 1
        systemctl restart hysteria || return 1
        sleep 1
        systemctl is-active --quiet hysteria || return 1
    fi
    ok "Hysteria 2 Port Hopping включён: UDP/$(hysteria_port_hop_range) -> UDP/${HYSTERIA_PORT:-8443}"
}

cmd_hysteria_hop_disable() {
    load_config
    local hop_range hop_ufw_range
    hop_range=$(hysteria_port_hop_range)
    hop_ufw_range="${hop_range/-/:}"
    HYSTERIA_PORT_HOP_ENABLED="0"
    save_config
    remove_hysteria_port_hop_rules
    if command -v ufw >/dev/null 2>&1; then
        ufw delete allow "${hop_ufw_range}/udp" >/dev/null 2>&1 || true
    fi
    ok "Hysteria 2 Port Hopping выключен"
}

cmd_hysteria_status() {
    load_config
    local hop_range hop_ufw_range
    hop_range=$(hysteria_port_hop_range)
    hop_ufw_range="${hop_range/-/:}"
    hr
    echo -e "${BOLD}  Hysteria 2 статус${RESET}"
    hr
    if [[ -x "$HYSTERIA_BIN" ]]; then
        ok "Бинарь: $("$HYSTERIA_BIN" version 2>/dev/null | head -1 || echo "$HYSTERIA_BIN")"
    else
        warn "Бинарь не установлен: $HYSTERIA_BIN"
    fi
    [[ -f "$HYSTERIA_CONFIG" ]] && ok "Конфиг: $HYSTERIA_CONFIG" || warn "Конфиг не найден"
    if [[ -f "$HYSTERIA_CONFIG" ]]; then
        if grep -q 'type: userpass' "$HYSTERIA_CONFIG"; then
            ok "Auth: userpass ($(grep -c '^    \".*\":' "$HYSTERIA_CONFIG" 2>/dev/null || echo 0) пользователей)"
        else
            warn "Auth: общий password"
        fi
        if grep -q 'name: warp-socks5' "$HYSTERIA_CONFIG"; then
            ok "Outbound: WARP SOCKS5 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
        else
            ok "Outbound: direct VPS"
        fi
        if hysteria_port_hop_enabled; then
            ok "Port hopping: UDP/$(hysteria_port_hop_range) -> UDP/${HYSTERIA_PORT:-8443}"
        else
            warn "Port hopping: выключен"
        fi
    fi
    systemctl is-active --quiet hysteria 2>/dev/null && ok "Сервис: работает" || warn "Сервис: не работает"
    ss -ulpn 2>/dev/null | grep -E ":${HYSTERIA_PORT:-8443}([[:space:]]|$)" || warn "UDP/${HYSTERIA_PORT:-8443} не слушается"
    ufw status 2>/dev/null | grep -E "${HYSTERIA_PORT:-8443}/udp|${hop_ufw_range}/udp|Status" || true
    hr
}

cmd_hysteria_logs() {
    echo -e "${BOLD}Лог Hysteria 2 (Ctrl+C для выхода):${RESET}"
    journalctl -u hysteria -n 50 -f
}

cmd_hysteria_remove() {
    echo -ne "${RED}Удалить Hysteria 2? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] || return
    load_config
    systemctl stop hysteria 2>/dev/null || true
    systemctl disable hysteria 2>/dev/null || true
    remove_hysteria_port_hop_rules
    rm -f "$HYSTERIA_SERVICE" "$HYSTERIA_BIN" "$HYSTERIA_CONFIG"
    ufw delete allow "${HYSTERIA_PORT:-8443}/udp" >/dev/null 2>&1 || true
    HYSTERIA_PORT=""
    HYSTERIA_PASSWORD=""
    HYSTERIA_OBFS_PASSWORD=""
    HYSTERIA_PORT_HOP_ENABLED="0"
    save_config
    systemctl daemon-reload
    ok "Hysteria 2 удалён"
}

cmd_hysteria_warp_enable() {
    load_config
    local port="${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    hr
    echo -e "${BOLD}  Hysteria 2 через WARP proxy${RESET}"
    hr
    info "Проверяю WARP local proxy: 127.0.0.1:${port}"
    if ! test_warp_proxy "$port"; then
        err "WARP proxy не готов. Сначала включи: sudo bash yurich-panel.sh warp-proxy"
        return 1
    fi

    HYSTERIA_WARP_ENABLED="1"
    save_config
    write_hysteria_config || return 1
    if systemctl restart hysteria && sleep 2 && systemctl is-active --quiet hysteria; then
        ok "Hysteria 2 теперь направляет исходящий трафик через WARP proxy"
    else
        err "Hysteria 2 не запустился после включения WARP. Лог:"
        journalctl -u hysteria -n 30 --no-pager
        return 1
    fi
}

cmd_hysteria_warp_disable() {
    load_config
    hr
    echo -e "${BOLD}  Отключение WARP только для Hysteria 2${RESET}"
    hr
    HYSTERIA_WARP_ENABLED="0"
    save_config
    write_hysteria_config || return 1
    if systemctl restart hysteria && sleep 2 && systemctl is-active --quiet hysteria; then
        ok "Hysteria 2 снова работает без отдельного WARP outbound"
    else
        err "Hysteria 2 не запустился после отключения WARP. Лог:"
        journalctl -u hysteria -n 30 --no-pager
        return 1
    fi
}

cmd_hysteria_menu() {
    load_config
    while true; do
        hr
        echo -e "${BOLD}  Hysteria 2${RESET}"
        hr
        echo -e "  Текущий порт: ${CYAN}UDP/${HYSTERIA_PORT:-8443}${RESET}"
        echo
        echo -e "  ${BOLD}1)${RESET} Установить / переустановить"
        echo -e "  ${BOLD}2)${RESET} Клиентский конфиг + QR"
        echo -e "  ${BOLD}3)${RESET} Статус"
        echo -e "  ${BOLD}4)${RESET} Логи"
        echo -e "  ${BOLD}5)${RESET} Удалить Hysteria 2"
        echo -e "  ${BOLD}6)${RESET} Изменить UDP порт"
        echo -e "  ${BOLD}7)${RESET} Включить Port Hopping"
        echo -e "  ${BOLD}8)${RESET} Выключить Port Hopping"
        echo -e "  ${BOLD}9)${RESET} Включить WARP только для Hysteria 2"
        echo -e "  ${BOLD}10)${RESET} Выключить WARP только для Hysteria 2"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_hysteria_install ;;
            2)
                echo -ne "${CYAN}Пользователь (Enter = первый/общий): ${RESET}"
                read -r hy_user
                print_hysteria_client_config "$hy_user"
                ;;
            3) cmd_hysteria_status ;;
            4) cmd_hysteria_logs ;;
            5) cmd_hysteria_remove ;;
            6) cmd_hysteria_change_port ;;
            7)
                echo -ne "${CYAN}Диапазон UDP [${HYSTERIA_PORT_HOP_PORTS:-$HYSTERIA_PORT_HOP_PORTS_DEFAULT}]: ${RESET}"
                read -r hop_range
                cmd_hysteria_hop_enable "${hop_range:-${HYSTERIA_PORT_HOP_PORTS:-$HYSTERIA_PORT_HOP_PORTS_DEFAULT}}"
                ;;
            8) cmd_hysteria_hop_disable ;;
            9) cmd_hysteria_warp_enable ;;
            10) cmd_hysteria_warp_disable ;;
            0) return ;;
            *) err "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
}

cmd_hysteria_sync_cli() {
    load_config
    load_users
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        sync_hysteria_users_if_active
    else
        warn "Hysteria 2 не установлен — sync пропущен"
    fi
}

# ─── XRAY MODERN: VLESS / TROJAN / REALITY / FALLBACK ─────────
detect_xray_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) echo "64" ;;
        aarch64|arm64) echo "arm64-v8a" ;;
        armv7l|armv7*) echo "arm32-v7a" ;;
        i386|i686) echo "32" ;;
        *) err "Архитектура $arch не поддерживается Xray автоустановкой"; return 1 ;;
    esac
}

install_xray_bin() {
    if [[ -x "$XRAY_BIN" ]]; then
        ok "Xray уже установлен: $("$XRAY_BIN" version 2>/dev/null | head -1 || echo "$XRAY_BIN")"
        return 0
    fi

    local arch url tmp tmp_dgst zip_dir expected actual bad_member
    arch=$(detect_xray_arch) || return 1
    if [[ "${XRAY_VERSION_PIN:-latest}" == "latest" ]]; then
        url="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${arch}.zip"
    else
        url="https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION_PIN}/Xray-linux-${arch}.zip"
    fi
    tmp=$(mktemp /tmp/xray_XXXXXX.zip)
    tmp_dgst=$(mktemp /tmp/xray_dgst_XXXXXX)
    zip_dir=$(mktemp -d /tmp/xray_unzip_XXXXXX)
    trap 'rm -f "${tmp:-}" "${tmp_dgst:-}" 2>/dev/null; rm -rf "${zip_dir:-}" 2>/dev/null; trap - RETURN' RETURN

    info "Скачиваю Xray-core (${arch})..."
    if ! curl -fsSL --retry 3 --connect-timeout 15 --max-time 180 "$url" -o "$tmp"; then
        err "Не удалось скачать Xray: $url"
        return 1
    fi
    info "Xray release pin: ${XRAY_VERSION_PIN:-latest}"

    command -v unzip &>/dev/null || apt-get install -y -q unzip
    if curl -fsSL --connect-timeout 10 --max-time 30 "${url}.dgst" -o "$tmp_dgst" 2>/dev/null; then
        expected=$(awk '{for(i=1;i<=NF;i++) if($i ~ /^[a-fA-F0-9]{64}$/){print tolower($i); exit}}' "$tmp_dgst" | head -1)
        if [[ -n "$expected" ]]; then
            actual=$(sha256sum "$tmp" | awk '{print $1}')
            if [[ "$actual" != "$expected" ]]; then
                err "SHA256 Xray не совпадает. Установка остановлена."
                return 1
            fi
            ok "SHA256 Xray подтверждён"
        elif [[ "${YURICH_ALLOW_UNVERIFIED_DOWNLOADS:-0}" == "1" ]]; then
            warn "Не нашёл SHA256 в ${url}.dgst, продолжаю из-за YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
        else
            err "Не нашёл SHA256 в ${url}.dgst. Установка Xray остановлена."
            return 1
        fi
    elif [[ "${YURICH_ALLOW_UNVERIFIED_DOWNLOADS:-0}" == "1" ]]; then
        warn "Не удалось скачать ${url}.dgst, продолжаю из-за YURICH_ALLOW_UNVERIFIED_DOWNLOADS=1"
    else
        err "Не удалось скачать ${url}.dgst. Установка Xray остановлена."
        return 1
    fi
    bad_member=$(unzip -Z1 "$tmp" 2>/dev/null | grep -E '(^/|(^|/)\.\.(/|$))' | head -1 || true)
    if [[ -n "$bad_member" ]]; then
        err "Xray zip содержит небезопасный путь: $bad_member"
        return 1
    fi
    if ! unzip -Z1 "$tmp" 2>/dev/null | grep -qx 'xray'; then
        err "Xray zip не содержит ожидаемый бинарник xray"
        return 1
    fi
    unzip -q "$tmp" -d "$zip_dir"
    install -m 755 "$zip_dir/xray" "$XRAY_BIN"
    mkdir -p /usr/local/share/xray
    [[ -f "$zip_dir/geoip.dat" ]] && install -m 644 "$zip_dir/geoip.dat" /usr/local/share/xray/geoip.dat
    [[ -f "$zip_dir/geosite.dat" ]] && install -m 644 "$zip_dir/geosite.dat" /usr/local/share/xray/geosite.dat
    ok "Xray установлен: $("$XRAY_BIN" version 2>/dev/null | head -1 || echo "$XRAY_BIN")"
}

load_xray_users() {
    mkdir -p "$CONFIG_DIR"
    local default_user
    default_user="${1:-xray}"
    if [[ ! -s "$XRAY_USERS_FILE" ]]; then
        xray_ensure_user "$default_user" >/dev/null || return 1
    elif is_valid_proxy_user "$default_user"; then
        xray_ensure_user "$default_user" >/dev/null || return 1
    fi
}

get_xray_user_uuid() {
    local lookup_user="$1"
    local uuid
    [[ -f "$XRAY_USERS_FILE" ]] || return 1
    uuid=$(awk -F: -v user="$lookup_user" '$1 == user {print $2; exit}' "$XRAY_USERS_FILE")
    [[ -n "$uuid" ]] || return 1
    printf '%s\n' "$uuid"
}

get_xray_compat_user_uuid() {
    local lookup_user="$1"
    local uuid
    [[ -f "$XRAY_COMPAT_USERS_FILE" ]] || return 1
    uuid=$(awk -F: -v user="$lookup_user" '$1 == user {print $2; exit}' "$XRAY_COMPAT_USERS_FILE")
    [[ "$uuid" =~ ^[0-9a-fA-F-]{36}$ ]] || return 1
    printf '%s\n' "$uuid"
}

xray_generate_uuid() {
    local uuid raw
    uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || true)
    if [[ ! "$uuid" =~ ^[0-9a-fA-F-]{36}$ && -x "$XRAY_BIN" ]]; then
        uuid=$("$XRAY_BIN" uuid 2>/dev/null | head -1 || true)
    fi
    if [[ ! "$uuid" =~ ^[0-9a-fA-F-]{36}$ ]]; then
        raw=$(openssl rand -hex 16)
        uuid="${raw:0:8}-${raw:8:4}-${raw:12:4}-${raw:16:4}-${raw:20:12}"
    fi
    printf '%s\n' "$uuid"
}

xray_ensure_user() {
    local user="$1"
    local uuid
    if ! is_valid_proxy_user "$user"; then
        err "Логин Xray: 2-32 символа, только A-Z a-z 0-9 _ -"
        return 1
    fi
    mkdir -p "$CONFIG_DIR"
    touch "$XRAY_USERS_FILE"
    chmod 600 "$XRAY_USERS_FILE"
    if uuid=$(get_xray_user_uuid "$user" 2>/dev/null); then
        printf '%s\n' "$uuid"
        return 0
    fi
    uuid=$(xray_generate_uuid)
    printf '%s:%s\n' "$user" "$uuid" >> "$XRAY_USERS_FILE"
    chmod 600 "$XRAY_USERS_FILE"
    printf '%s\n' "$uuid"
}

xray_ensure_compat_user() {
    local user="$1"
    local uuid
    if ! is_valid_proxy_user "$user"; then
        err "Логин Xray: 2-32 символа, только A-Z a-z 0-9 _ -"
        return 1
    fi
    mkdir -p "$CONFIG_DIR"
    touch "$XRAY_COMPAT_USERS_FILE"
    chmod 600 "$XRAY_COMPAT_USERS_FILE"
    if uuid=$(get_xray_compat_user_uuid "$user" 2>/dev/null); then
        printf '%s\n' "$uuid"
        return 0
    fi
    uuid=$(xray_generate_uuid)
    printf '%s:%s\n' "$user" "$uuid" >> "$XRAY_COMPAT_USERS_FILE"
    chmod 600 "$XRAY_COMPAT_USERS_FILE"
    printf '%s\n' "$uuid"
}

xray_active_user_count() {
    local count=0 user uuid
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" ]] && continue
        if ! user_is_expired "$user"; then
            count=$((count + 1))
        fi
    done < <(grep -v '^#\|^[[:space:]]*$' "$XRAY_USERS_FILE" 2>/dev/null || true)
    printf '%s\n' "$count"
}

xray_clients_json() {
    local first=1 user uuid
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" ]] && continue
        user_is_expired "$user" && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s", "flow": "xtls-rprx-vision" }' "$uuid" "$user"
    done < "$XRAY_USERS_FILE"
}

xray_clients_json_no_flow() {
    local first=1 user uuid
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" ]] && continue
        user_is_expired "$user" && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s" }' "$uuid" "$user"
    done < "$XRAY_USERS_FILE"
}

xray_clients_json_reality() {
    local first=1 user uuid
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" || "$user" == \#* ]] && continue
        user_is_expired "$user" && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s", "flow": "xtls-rprx-vision" }' "$uuid" "$user"
    done < "$XRAY_USERS_FILE"

    [[ -f "$XRAY_COMPAT_USERS_FILE" ]] || return 0
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" || "$user" == \#* ]] && continue
        [[ "$uuid" =~ ^[0-9a-fA-F-]{36}$ ]] || continue
        user_is_expired "$user" && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s-compat" }' "$uuid" "$user"
    done < "$XRAY_COMPAT_USERS_FILE"
}

xray_clients_json_compat_only() {
    local first=1 user uuid
    [[ -f "$XRAY_COMPAT_USERS_FILE" ]] || return 0
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" || "$user" == \#* ]] && continue
        [[ "$uuid" =~ ^[0-9a-fA-F-]{36}$ ]] || continue
        user_is_expired "$user" && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s-mobile-alt" }' "$uuid" "$user"
    done < "$XRAY_COMPAT_USERS_FILE"
}

xray_reality_key_valid() {
    [[ "${1:-}" =~ ^[A-Za-z0-9_-]{20,100}$ ]]
}

xray_extract_reality_key() {
    local kind="$1" output="$2" value=""
    case "$kind" in
        private)
            value=$(printf '%s\n' "$output" | awk -F':' '
                {
                    label=tolower($1);
                    if (label ~ /private/) {
                        value=$0;
                        sub(/^[^:]*:[[:space:]]*/, "", value);
                        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value);
                        print value;
                        exit;
                    }
                }
            ')
            ;;
        public)
            value=$(printf '%s\n' "$output" | awk -F':' '
                {
                    label=tolower($1);
                    if (label ~ /public/ || label ~ /password/) {
                        value=$0;
                        sub(/^[^:]*:[[:space:]]*/, "", value);
                        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value);
                        print value;
                        exit;
                    }
                }
            ')
            ;;
    esac
    if xray_reality_key_valid "$value"; then
        printf '%s\n' "$value"
        return 0
    fi

    # Last-resort parser for compact outputs where labels changed.
    local -a tokens
    mapfile -t tokens < <(printf '%s\n' "$output" | grep -Eo '[A-Za-z0-9_-]{30,100}' || true)
    if [[ "$kind" == "private" && "${#tokens[@]}" -ge 1 ]] && xray_reality_key_valid "${tokens[0]}"; then
        printf '%s\n' "${tokens[0]}"
        return 0
    fi
    if [[ "$kind" == "public" && "${#tokens[@]}" -ge 2 ]] && xray_reality_key_valid "${tokens[1]}"; then
        printf '%s\n' "${tokens[1]}"
        return 0
    fi
    return 1
}

ensure_xray_reality_keys() {
    XRAY_REALITY_SHORT_ID="${XRAY_REALITY_SHORT_ID:-$(openssl rand -hex 8)}"
    if ! xray_reality_key_valid "${XRAY_REALITY_PRIVATE_KEY:-}" || ! xray_reality_key_valid "${XRAY_REALITY_PUBLIC_KEY:-}"; then
        local key_out
        key_out=$("$XRAY_BIN" x25519 2>&1 || true)
        XRAY_REALITY_PRIVATE_KEY=$(xray_extract_reality_key private "$key_out" 2>/dev/null || true)
        XRAY_REALITY_PUBLIC_KEY=$(xray_extract_reality_key public "$key_out" 2>/dev/null || true)
        if ! xray_reality_key_valid "${XRAY_REALITY_PRIVATE_KEY:-}" || ! xray_reality_key_valid "${XRAY_REALITY_PUBLIC_KEY:-}"; then
            warn "xray x25519 вывел неожиданный формат:"
            printf '%s\n' "$key_out" | sed -n '1,12p'
        fi
    fi
    if ! xray_reality_key_valid "${XRAY_REALITY_PRIVATE_KEY:-}" || ! xray_reality_key_valid "${XRAY_REALITY_PUBLIC_KEY:-}"; then
        err "Не смог сгенерировать REALITY ключи: xray x25519"
        warn "Проверь вручную: ${XRAY_BIN} x25519"
        return 1
    fi
}

xray_reality_target_presets() {
    cat <<'EOF'
RU|ya.ru:443|Yandex short
RU|www.yandex.ru:443|Yandex
RU|www.ozon.ru:443|Ozon
RU|www.wildberries.ru:443|Wildberries
RU|www.avito.ru:443|Avito
RU|www.rbc.ru:443|RBC
RU|www.drom.ru:443|Drom
RU|www.vk.com:443|VK
GLOBAL|www.microsoft.com:443|Microsoft
GLOBAL|www.apple.com:443|Apple
GLOBAL|www.cloudflare.com:443|Cloudflare
GLOBAL|www.ubuntu.com:443|Ubuntu
GLOBAL|www.debian.org:443|Debian
GLOBAL|www.mozilla.org:443|Mozilla
GLOBAL|www.python.org:443|Python
GLOBAL|www.wikipedia.org:443|Wikipedia
EOF
}

normalize_reality_target() {
    local raw="${1:-}" host port
    raw="${raw#https://}"
    raw="${raw#http://}"
    raw="${raw%%/*}"
    raw="${raw//[[:space:]]/}"
    [[ -n "$raw" ]] || return 1
    if [[ "$raw" == *:* ]]; then
        host="${raw%%:*}"
        port="${raw##*:}"
    else
        host="$raw"
        port="443"
    fi
    is_valid_domain "$host" || return 1
    is_valid_port "$port" || return 1
    printf '%s:%s\n' "$host" "$port"
}

test_reality_target_tls() {
    local target="$1" host port out
    target=$(normalize_reality_target "$target") || return 2
    host="${target%%:*}"
    port="${target##*:}"
    command -v openssl >/dev/null 2>&1 || return 3
    out=$(echo | timeout 8 openssl s_client \
        -connect "${host}:${port}" \
        -servername "$host" \
        -alpn h2,http/1.1 \
        -brief 2>&1 || true)
    if printf '%s\n' "$out" | grep -Eq 'CONNECTION ESTABLISHED|Protocol version|Ciphersuite'; then
        return 0
    fi
    return 1
}

prompt_xray_reality_target() {
    local current="${XRAY_REALITY_TARGET:-www.microsoft.com:443}" choice target label group desc i ans
    current=$(normalize_reality_target "$current" 2>/dev/null || printf 'www.microsoft.com:443')

    echo
    echo -e "${BOLD}REALITY target presets${RESET}"
    echo -e "${DIM}Это кандидаты для TLS/SNI target. Доступность меняется, поэтому скрипт проверит выбранный домен с сервера.${RESET}"
    echo -e "${DIM}Enter = оставить текущий: ${current}${RESET}"
    echo
    i=1
    while IFS='|' read -r group target desc; do
        printf '  %2d) [%s] %-28s %s\n' "$i" "$group" "$target" "$desc"
        i=$((i + 1))
    done < <(xray_reality_target_presets)
    echo "   c) свой домен:порт"
    echo
    echo -ne "${CYAN}REALITY target choice [Enter = ${current}]: ${RESET}"
    read -r choice

    if [[ -z "$choice" ]]; then
        target="$current"
    elif [[ "${choice,,}" == "c" || "${choice,,}" == "custom" ]]; then
        echo -ne "${CYAN}Custom REALITY target [domain:443]: ${RESET}"
        read -r target
    elif [[ "$choice" =~ ^[0-9]+$ ]]; then
        target=$(xray_reality_target_presets | awk -F'|' -v n="$choice" 'NR==n {print $2; exit}')
        if [[ -z "$target" ]]; then
            warn "Нет такого номера, оставляю текущий target: $current"
            target="$current"
        fi
    else
        target="$choice"
    fi

    target=$(normalize_reality_target "$target" 2>/dev/null || true)
    if [[ -z "$target" ]]; then
        err "REALITY target должен быть domain:port, например www.microsoft.com:443"
        return 1
    fi

    info "Проверяю TLS/SNI для ${target}..."
    if test_reality_target_tls "$target"; then
        ok "REALITY target отвечает по TLS: ${target}"
    else
        warn "TLS-проверка ${target} не прошла с этого сервера."
        warn "Это не всегда значит, что target плохой, но лучше выбрать другой кандидат."
        echo -ne "${YELLOW}Использовать всё равно? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || return 1
    fi

    XRAY_REALITY_TARGET="$target"
    XRAY_REALITY_SERVER_NAME="${target%%:*}"
    ok "REALITY target выбран: ${XRAY_REALITY_TARGET}"
}

write_xray_service() {
    cat > "$XRAY_SERVICE" <<EOF
[Unit]
Description=Xray Modern Proxy
Documentation=https://xtls.github.io/
After=network-online.target nss-lookup.target
Wants=network-online.target

[Service]
User=root
ExecStart=${XRAY_BIN} run -config ${XRAY_CONFIG}
Restart=always
RestartSec=2s
TimeoutStopSec=15s
LimitNOFILE=1048576
LimitNPROC=4096
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable xray --quiet
}

ensure_xray_zapret_assets() {
    local dat="${XRAY_ZAPRET_DAT:-$XRAY_ZAPRET_DAT_DEFAULT}"
    local url="${XRAY_ZAPRET_URL:-$XRAY_ZAPRET_URL_DEFAULT}"
    local tmp

    [[ "${XRAY_ZAPRET_ENABLED:-0}" == "1" ]] || return 1
    mkdir -p "$(dirname "$dat")"

    if [[ -s "$dat" ]]; then
        return 0
    fi

    tmp="${dat}.tmp.$$"
    rm -f "$tmp"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --connect-timeout 10 --max-time 60 "$url" -o "$tmp" 2>/dev/null || true
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$tmp" "$url" 2>/dev/null || true
    fi

    if [[ -s "$tmp" ]]; then
        mv -f "$tmp" "$dat"
        chmod 644 "$dat" 2>/dev/null || true
        ok "Xray zapret.dat готов: $dat"
        return 0
    fi

    rm -f "$tmp"
    warn "zapret.dat не скачался, Xray routing будет собран без zapret-правила"
    return 1
}

write_xray_config() {
    load_config
    local seed_user="${1:-}"
    if [[ -n "$seed_user" ]]; then
        load_xray_users "$seed_user"
    elif [[ ! -s "$XRAY_USERS_FILE" ]]; then
        load_xray_users "xray"
    fi
    ensure_xray_reality_keys || return 1

    local cert key fallback_enabled fallback_port reality_port reality_listen mobile_alt_port mobile_alt_target mobile_alt_sni github_test_port github_test_target github_test_sni trojan_pass reality_target reality_sni zapret_enabled xray_config_backup xray_warp_enabled
    fallback_enabled="${XRAY_FALLBACK_ENABLED:-0}"
    fallback_port="${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
    reality_port="${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
    mobile_alt_port="${XRAY_MOBILE_ALT_PORT:-$XRAY_MOBILE_ALT_PORT_DEFAULT}"
    github_test_port="${XRAY_GITHUB_TEST_PORT:-$XRAY_GITHUB_TEST_PORT_DEFAULT}"
    reality_listen="0.0.0.0"
    if [[ "${XRAY_REALITY_SNI_MUX_ENABLED:-0}" == "1" ]]; then
        reality_listen="127.0.0.1"
    fi
    trojan_pass="${XRAY_TROJAN_PASSWORD:-$(random_safe_token 24)}"
    XRAY_TROJAN_PASSWORD="$trojan_pass"
    reality_target="${XRAY_REALITY_TARGET:-www.microsoft.com:443}"
    reality_sni="${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}"
    mobile_alt_target="${XRAY_MOBILE_ALT_TARGET:-$XRAY_MOBILE_ALT_TARGET_DEFAULT}"
    mobile_alt_sni="${XRAY_MOBILE_ALT_SERVER_NAME:-$XRAY_MOBILE_ALT_SERVER_NAME_DEFAULT}"
    github_test_target="${XRAY_GITHUB_TEST_TARGET:-$XRAY_GITHUB_TEST_TARGET_DEFAULT}"
    github_test_sni="${XRAY_GITHUB_TEST_SERVER_NAME:-$XRAY_GITHUB_TEST_SERVER_NAME_DEFAULT}"
    zapret_enabled="0"
    xray_warp_enabled="${XRAY_WARP_ENABLED:-${WARP_PROXY_ENABLED:-0}}"
    [[ "$xray_warp_enabled" == "1" ]] || xray_warp_enabled="0"
    if [[ "${XRAY_GITHUB_TEST_ENABLED:-0}" == "1" ]]; then
        if ! is_valid_domain "$github_test_sni"; then
            err "Некорректный XRAY_GITHUB_TEST_SERVER_NAME: $github_test_sni"
            return 1
        fi
        if ! is_valid_host_port "$github_test_target"; then
            err "Некорректный XRAY_GITHUB_TEST_TARGET: $github_test_target"
            return 1
        fi
    fi

    cert=""
    key=""
    if [[ "$fallback_enabled" == "1" ]]; then
        cert=$(find_caddy_cert "${DOMAIN:-}") || true
        key=$(find_caddy_key "${DOMAIN:-}") || true
        if [[ -z "$cert" || -z "$key" ]]; then
            err "Для Xray TLS/fallback нужен TLS сертификат Caddy. Сначала запусти Yurich Panel и дождись сертификата."
            return 1
        fi
    fi

    mkdir -p "$XRAY_CONFIG_DIR" /var/log/xray
    xray_config_backup=""
    if [[ -s "$XRAY_CONFIG" ]]; then
        xray_config_backup=$(mktemp)
        cp -p "$XRAY_CONFIG" "$xray_config_backup" 2>/dev/null || xray_config_backup=""
    fi
    if [[ "${XRAY_ZAPRET_ENABLED:-0}" == "1" ]]; then
        warn "Xray zapret blackhole routing отключён: этот режим ломал Instagram/Facebook. Флаг будет сброшен."
        XRAY_ZAPRET_ENABLED="0"
    fi

    cat > "$XRAY_CONFIG" <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "policy": {
    "levels": {
      "0": {
        "handshake": 8,
        "connIdle": 600,
        "uplinkOnly": 2,
        "downlinkOnly": 5,
        "bufferSize": 512
      }
    }
  },
EOF

    if [[ "$zapret_enabled" == "1" || "$xray_warp_enabled" == "1" ]]; then
        cat >> "$XRAY_CONFIG" <<EOF
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
EOF
        if [[ "$xray_warp_enabled" == "1" ]]; then
            cat >> "$XRAY_CONFIG" <<EOF
      { "type": "field", "network": "tcp,udp", "outboundTag": "warp-proxy" }
EOF
        fi
        cat >> "$XRAY_CONFIG" <<EOF
    ]
  },
EOF
    fi

    cat >> "$XRAY_CONFIG" <<EOF
  "inbounds": [
EOF

    if [[ "$fallback_enabled" == "1" ]]; then
        cat >> "$XRAY_CONFIG" <<EOF
    {
      "tag": "vless-tls-fallback-443",
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
$(xray_clients_json)
        ],
        "decryption": "none",
        "fallbacks": [
          { "dest": "127.0.0.1:${fallback_port}" }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "${DOMAIN}",
          "alpn": ["http/1.1"],
          "certificates": [
            { "certificateFile": "${cert}", "keyFile": "${key}" }
          ]
        }
      }
    },
EOF
    fi

    cat >> "$XRAY_CONFIG" <<EOF
    {
      "tag": "vless-reality",
      "listen": "${reality_listen}",
      "port": ${reality_port},
      "protocol": "vless",
      "settings": {
        "clients": [
$(xray_clients_json_reality)
        ],
        "decryption": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"],
        "routeOnly": false
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "sockopt": {
          "tcpKeepAliveIdle": 60,
          "tcpKeepAliveInterval": 15,
          "tcpUserTimeout": 30000
        },
        "realitySettings": {
          "show": false,
          "dest": "${reality_target}",
          "serverNames": ["${reality_sni}"],
          "privateKey": "${XRAY_REALITY_PRIVATE_KEY}",
          "shortIds": ["${XRAY_REALITY_SHORT_ID}"]
        }
      }
    }
EOF

    if [[ -s "$XRAY_COMPAT_USERS_FILE" ]]; then
        cat >> "$XRAY_CONFIG" <<EOF
    ,
    {
      "tag": "vless-reality-mobile-alt",
      "listen": "${reality_listen}",
      "port": ${mobile_alt_port},
      "protocol": "vless",
      "settings": {
        "clients": [
$(xray_clients_json_compat_only)
        ],
        "decryption": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"],
        "routeOnly": false
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "sockopt": {
          "tcpKeepAliveIdle": 60,
          "tcpKeepAliveInterval": 15,
          "tcpUserTimeout": 30000
        },
        "realitySettings": {
          "show": false,
          "dest": "${mobile_alt_target}",
          "serverNames": ["${mobile_alt_sni}"],
          "privateKey": "${XRAY_REALITY_PRIVATE_KEY}",
          "shortIds": ["${XRAY_REALITY_SHORT_ID}"]
        }
      }
    }
EOF
    fi

    if [[ "${XRAY_GITHUB_TEST_ENABLED:-0}" == "1" ]]; then
        cat >> "$XRAY_CONFIG" <<EOF
    ,
    {
      "tag": "vless-reality-github-test",
      "listen": "${reality_listen}",
      "port": ${github_test_port},
      "protocol": "vless",
      "settings": {
        "clients": [
$(xray_clients_json_reality)
        ],
        "decryption": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"],
        "routeOnly": false
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "sockopt": {
          "tcpKeepAliveIdle": 60,
          "tcpKeepAliveInterval": 15,
          "tcpUserTimeout": 30000
        },
        "realitySettings": {
          "show": false,
          "dest": "${github_test_target}",
          "serverNames": ["${github_test_sni}"],
          "privateKey": "${XRAY_REALITY_PRIVATE_KEY}",
          "shortIds": ["${XRAY_REALITY_SHORT_ID}"]
        }
      }
    }
EOF
    fi

    cat >> "$XRAY_CONFIG" <<EOF
  ],
  "outbounds": [
EOF

    if [[ "$xray_warp_enabled" == "1" ]]; then
        cat >> "$XRAY_CONFIG" <<EOF
    {
      "protocol": "socks",
      "tag": "warp-proxy",
      "settings": {
        "servers": [
          { "address": "127.0.0.1", "port": ${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT} }
        ]
      }
    },
    { "protocol": "freedom", "tag": "direct", "settings": { "domainStrategy": "UseIPv4" } },
    { "protocol": "blackhole", "tag": "block" }
EOF
    else
        cat >> "$XRAY_CONFIG" <<EOF
    { "protocol": "freedom", "tag": "direct", "settings": { "domainStrategy": "UseIPv4" } },
    { "protocol": "blackhole", "tag": "block" }
EOF
    fi

    cat >> "$XRAY_CONFIG" <<EOF
  ]
}
EOF

    chmod 600 "$XRAY_CONFIG"
    if ! "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1; then
        err "Xray config не прошёл проверку"
        "$XRAY_BIN" run -test -config "$XRAY_CONFIG" || true
        if [[ -n "$xray_config_backup" && -s "$xray_config_backup" ]]; then
            mv -f "$xray_config_backup" "$XRAY_CONFIG"
            chmod 600 "$XRAY_CONFIG" 2>/dev/null || true
            warn "Рабочий Xray config восстановлен из бэкапа"
        else
            rm -f "$XRAY_CONFIG" 2>/dev/null || true
            warn "Новый нерабочий Xray config удалён"
        fi
        return 1
    fi
    [[ -n "$xray_config_backup" ]] && rm -f "$xray_config_backup" 2>/dev/null || true
    save_config
    ok "Xray config создан: $XRAY_CONFIG"
    if [[ "$xray_warp_enabled" == "1" ]]; then
        ok "Xray outbound направлен через WARP proxy: 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    else
        ok "Xray outbound: direct VPS"
    fi
}

print_xray_client_config() {
    load_config
    [[ -s "$XRAY_USERS_FILE" ]] || load_xray_users "xray"
    local user="${1:-}"
    local uuid
    if [[ -z "$user" ]]; then
        while IFS=: read -r candidate _; do
            [[ -z "$candidate" ]] && continue
            if ! user_is_expired "$candidate"; then
                user="$candidate"
                break
            fi
        done < "$XRAY_USERS_FILE"
    fi
    if user_is_expired "$user"; then
        err "Xray пользователь $user истёк: $(user_expiry_label "$user")"
        return 1
    fi
    uuid=$(awk -F: -v u="$user" '$1 == u {print $2; exit}' "$XRAY_USERS_FILE")
    [[ -z "$uuid" ]] && { err "Xray пользователь $user не найден"; return 1; }
    reality_public_port=$(xray_reality_public_port)

    hr
    echo -e "${BOLD}${GREEN}  Xray Modern client config${RESET}"
    hr
    echo -e "  User: ${BOLD}${user}${RESET}"
    echo
    echo -e "${CYAN}  VLESS REALITY TCP:${RESET}"
    echo "  vless://${uuid}@${DOMAIN}:${reality_public_port}?encryption=none&security=reality&type=tcp&flow=xtls-rprx-vision&sni=${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}&spx=%2F#${user}-reality"
    if [[ -n "$(yurich_dns_client_ip)" ]]; then
        echo
        echo -e "${CYAN}  DNS (Unbound) для full TUN/sing-box:${RESET}"
        echo -e "  DNS server: ${GREEN}tcp://$(yurich_dns_client_ip):53${RESET}"
        echo -e "  detour: ${GREEN}xray-out${RESET} (или тег твоего Xray outbound в клиенте)"
    fi
    hr
}

# ─── ПОДПИСКИ И ПЕРСОНАЛЬНЫЕ WEB-СТРАНИЦЫ ─────────────────────
html_escape_text() {
    printf '%s' "${1:-}" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
}

uri_fragment_decode() {
    local value="${1:-}"
    if command -v python3 >/dev/null 2>&1; then
        VALUE="$value" python3 - <<'PY'
import os
import urllib.parse

print(urllib.parse.unquote(os.environ.get("VALUE", "")).strip())
PY
    else
        printf '%s' "$value" | sed 's/%20/ /g; s/%E2%80%A2/•/g'
    fi
}

subscription_human_bytes() {
    local bytes="${1:-0}"
    bytes="${bytes//[^0-9]/}"
    bytes="${bytes:-0}"
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec --suffix=B "$bytes" 2>/dev/null || printf '%s B\n' "$bytes"
    else
        printf '%s B\n' "$bytes"
    fi
}

subscription_traffic_cache_path() {
    printf '%s\n' "${SUBSCRIPTION_TRAFFIC_CACHE_FILE:-/tmp/yurich-subscription-traffic-cache.tsv}"
}

subscription_traffic_cache_fresh() {
    local cache="$1" max_age now mtime age
    max_age="${SUBSCRIPTION_TRAFFIC_REFRESH_SECONDS:-300}"
    [[ "$max_age" =~ ^[0-9]+$ ]] || max_age=300
    [[ -s "$cache" ]] || return 1
    now=$(date +%s 2>/dev/null || echo 0)
    mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
    [[ "$now" =~ ^[0-9]+$ && "$mtime" =~ ^[0-9]+$ ]] || return 1
    age=$((now - mtime))
    [[ "$age" -ge 0 && "$age" -le "$max_age" ]]
}

subscription_build_traffic_cache() {
    local cache tmp logs=()
    cache=$(subscription_traffic_cache_path)
    subscription_traffic_cache_fresh "$cache" && return 0
    mapfile -t logs < <(device_log_files)
    [[ "${#logs[@]}" -gt 0 ]] || return 1
    tmp=$(mktemp)
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$tmp" "${logs[@]}" <<'PY'
import gzip
import json
import sys
from collections import defaultdict

out_path = sys.argv[1]
paths = sys.argv[2:]
totals = defaultdict(int)

def open_log(path):
    if path.endswith(".gz"):
        return gzip.open(path, "rt", encoding="utf-8", errors="ignore")
    return open(path, "rt", encoding="utf-8", errors="ignore")

for path in paths:
    try:
        fh = open_log(path)
    except OSError:
        continue
    with fh:
        for line in fh:
            line = line.strip()
            if not line or '"user_id"' not in line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            user = str(row.get("user_id") or "")
            if not user:
                continue
            total = 0
            for key in ("bytes_read", "size"):
                value = row.get(key, 0)
                if isinstance(value, (int, float)) and value > 0:
                    total += int(value)
            if total > 0:
                totals[user] += total

with open(out_path, "w", encoding="utf-8") as out:
    for user in sorted(totals):
        out.write(f"{user}\t{totals[user]}\n")
PY
    else
        awk '
            /"user_id":/ {
                user=""; br=0; sz=0;
                tmp=$0; sub(/^.*"user_id":"/, "", tmp); sub(/".*$/, "", tmp); user=tmp;
                if (user == "") next;
                tmp=$0; if (tmp ~ /"bytes_read":[0-9]+/) { sub(/^.*"bytes_read":/, "", tmp); sub(/[^0-9].*$/, "", tmp); br=tmp+0; }
                tmp=$0; if (tmp ~ /"size":[0-9]+/) { sub(/^.*"size":/, "", tmp); sub(/[^0-9].*$/, "", tmp); sz=tmp+0; }
                if (br + sz > 0) totals[user] += br + sz;
            }
            END { for (u in totals) print u "\t" totals[u]; }
        ' "${logs[@]}" > "$tmp"
    fi
    install -m 600 "$tmp" "$cache" 2>/dev/null || cp "$tmp" "$cache"
    rm -f "$tmp"
    [[ -s "$cache" ]]
}

subscription_refresh_traffic_meta() {
    local user="$1" cache bytes
    is_valid_proxy_user "$user" || return 1
    subscription_build_traffic_cache || return 1
    cache=$(subscription_traffic_cache_path)
    bytes=$(awk -F'\t' -v u="$user" '$1 == u {print $2; exit}' "$cache" 2>/dev/null || true)
    [[ "$bytes" =~ ^[0-9]+$ ]] || return 1
    user_meta_set "$user" TRAFFIC_USED_BYTES "$bytes" >/dev/null 2>&1 || return 1
    user_meta_set "$user" TRAFFIC_UPDATED_AT "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >/dev/null 2>&1 || true
}

subscription_traffic_summary() {
    local user="$1" used_bytes user_used updated_at

    used_bytes=$(user_meta_get "$user" TRAFFIC_USED_BYTES 2>/dev/null || true)
    if [[ "$used_bytes" =~ ^[0-9]+$ && "$used_bytes" -gt 0 ]]; then
        user_used=$(subscription_human_bytes "$used_bytes")
        updated_at=$(user_meta_get "$user" TRAFFIC_UPDATED_AT 2>/dev/null || true)
        if [[ -n "$updated_at" ]]; then
            printf 'По доступным логам Naive HTTPS: %s. Обновлено: %s.' "$user_used" "$updated_at"
        else
            printf 'По доступным логам Naive HTTPS: %s.' "$user_used"
        fi
    else
        printf 'По доступным логам Naive HTTPS активность пока не найдена. VLESS/Turbo требуют отдельного stats-сборщика.'
    fi
}

subscription_remnawave_page_enabled() {
    local user="${1:-}" list="${SUBSCRIPTION_REMWAVE_USERS:-all}" item
    [[ -n "$user" ]] || return 1
    for item in $list; do
        case "$item" in
            "*"|"all"|"$user") return 0 ;;
        esac
    done
    return 1
}

subscription_remnawave_preview_page_enabled() {
    local user="${1:-}" list="${SUBSCRIPTION_REMWAVE_PREVIEW_USERS:-all}" item
    [[ -n "$user" ]] || return 1
    for item in $list; do
        case "$item" in
            "*"|"all"|"$user") return 0 ;;
        esac
    done
    return 1
}

subscription_premium_v2_page_enabled() {
    local user="${1:-}" list="${SUBSCRIPTION_PREMIUM_V2_USERS:-ivan}" item
    [[ -n "$user" ]] || return 1
    for item in $list; do
        case "$item" in
            "*"|"all"|"$user") return 0 ;;
        esac
    done
    return 1
}

subscription_profile_protocol() {
    local uri="${1:-}"
    case "$uri" in
        naive+https://*) printf 'HTTPS' ;;
        hy2://*|hysteria2://*) printf 'Turbo' ;;
        vless://*)
            if [[ "$uri" == *"security=reality"* ]]; then
                printf 'Reality'
            elif [[ "$uri" == *"type=xhttp"* ]]; then
                printf 'VLESS XHTTP'
            elif [[ "$uri" == *"type=kcp"* ]]; then
                printf 'VLESS mKCP'
            elif [[ "$uri" == *"flow=xtls-rprx-vision"* ]]; then
                printf 'Reality'
            else
                printf 'VLESS'
            fi
            ;;
        yurich://*) printf 'Yurich Connect' ;;
        *) printf 'Профиль' ;;
    esac
}

subscription_profile_host() {
    local uri="${1:-}" rest host
    rest="${uri#*://}"
    rest="${rest#*@}"
    host="${rest%%/*}"
    host="${host%%\?*}"
    host="${host%%#*}"
    [[ -z "$host" || "$host" == "$uri" ]] && host="${DOMAIN:-сервер}"
    printf '%s\n' "$host"
}

subscription_profile_name_from_uri() {
    local uri="${1:-}" fragment protocol host
    if [[ "$uri" == *"#"* ]]; then
        fragment="${uri##*#}"
        uri_fragment_decode "$fragment"
        return
    fi
    protocol=$(subscription_profile_protocol "$uri")
    host=$(subscription_profile_host "$uri")
    printf '%s • %s\n' "$host" "$protocol"
}

subscription_active_locations_label() {
    local links="${1:-}" line name location host text
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        name=$(subscription_profile_name_from_uri "$line")
        host=$(subscription_profile_host "$line")
        location="${name%% • *}"
        [[ -z "$location" || "$location" == "$name" ]] && continue
        text="$(printf '%s %s' "$host" "$location" | tr '[:upper:]' '[:lower:]')"
        case "$text" in
            *swe*|*sweden*|*stockholm*|*swe.go-it*) location="🇸🇪 SWE" ;;
            *n8n-cloud*|*finland\ 2*|*finland2*|*fi2*) location="🇫🇮 Finland 2" ;;
            *poland*|*warsaw*|*polska*) location="🇵🇱 Poland" ;;
            *finland*|*helsinki*|*suomi*) location="🇫🇮 Finland" ;;
            *plus-dns*|*germany*|*deutschland*|*frankfurt*) location="🇩🇪 Germany" ;;
            *net-it*|*netherlands*|*amsterdam*) location="🇳🇱 Netherlands" ;;
        esac
        printf '%s\n' "$location"
    done <<< "$links" | awk 'NF && !seen[$0]++ { out = out ? out " / " $0 : $0 } END { print out }'
}

subscription_profile_cards_html() {
    local links="${1:-}" line protocol host name safe_line safe_protocol safe_host safe_name count=0

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        count=$((count + 1))
        protocol=$(subscription_profile_protocol "$line")
        host=$(subscription_profile_host "$line")
        name=$(subscription_profile_name_from_uri "$line")
        safe_line=$(html_escape_text "$line")
        safe_protocol=$(html_escape_text "$protocol")
        safe_host=$(html_escape_text "$host")
        safe_name=$(html_escape_text "$name")
        cat <<EOF
      <article class="profile-card">
        <div class="profile-top">
          <span class="profile-type">${safe_protocol}</span>
          <span class="profile-host">${safe_host}</span>
        </div>
        <div class="profile-name">${safe_name}</div>
        <div class="profile-actions">
          <button class="btn copy profile-copy" data-copy="${safe_line}">Скопировать</button>
        </div>
      </article>
EOF
    done <<< "$links"

    if [[ "$count" -eq 0 ]]; then
        cat <<'EOF'
      <div class="empty-state">Активные профили не настроены</div>
EOF
    fi
}

subscription_recommendations_html() {
    local links="${1:-}" log_file="${PROTOCOL_BENCHMARK_LOG:-$PROTOCOL_BENCHMARK_LOG_DEFAULT}"
    if command -v python3 >/dev/null 2>&1 && [[ -s "$log_file" ]]; then
        LINKS="$links" LOG_FILE="$log_file" python3 - <<'PY'
import csv
import html
import os
from urllib.parse import unquote, urlsplit

links = [x.strip() for x in os.environ.get("LINKS", "").splitlines() if x.strip()]
log_file = os.environ.get("LOG_FILE", "")
profiles = []
for line in links:
    u = urlsplit(line)
    profiles.append({
        "scheme": u.scheme.lower(),
        "host": u.hostname or "",
        "name": unquote(u.fragment or f"{u.hostname or ''} {u.scheme}"),
    })

rows = []
try:
    with open(log_file, "r", encoding="utf-8", errors="replace") as f:
        rows = list(csv.DictReader(f))[-500:]
except Exception:
    rows = []

scores = {}
for r in rows:
    key = (r.get("scheme", ""), r.get("host", ""))
    item = scores.setdefault(key, {"ok": 0, "fail": 0, "avg": []})
    if r.get("status") == "OK":
        item["ok"] += 1
        try:
            item["avg"].append(int(r.get("avg_ms") or 0))
        except Exception:
            pass
    elif r.get("status") == "FAIL":
        item["fail"] += 1

def avg_for(p):
    item = scores.get((p["scheme"], p["host"]), {})
    vals = item.get("avg") or []
    return int(sum(vals) / len(vals)) if vals else None

def proto_label(scheme):
    if scheme.startswith("naive"):
        return "HTTPS"
    if scheme in ("hy2", "hysteria2"):
        return "Turbo"
    if scheme == "vless":
        return "Reality"
    return scheme

ranked = []
for p in profiles:
    avg = avg_for(p)
    if avg is not None:
        item = scores.get((p["scheme"], p["host"]), {})
        ranked.append((avg, item.get("fail", 0), p))

cards = []
if ranked:
    best = sorted(ranked, key=lambda x: (x[0], x[1]))[0]
    cards.append(("Рекомендуемый сейчас", best[2], f"avg {best[0]} ms"))
    turbo = [x for x in ranked if x[2]["scheme"] in ("hy2", "hysteria2")]
    if turbo:
        t = sorted(turbo, key=lambda x: (x[0], x[1]))[0]
        cards.append(("Самый быстрый Turbo", t[2], f"avg {t[0]} ms"))
https = [p for p in profiles if p["scheme"].startswith("naive")]
if https:
    p = https[0]
    avg = avg_for(p)
    cards.append(("Резервный совместимый", p, f"avg {avg} ms" if avg is not None else "HTTPS fallback"))

seen = set()
out = []
for title, p, metric in cards:
    key = (title, p["scheme"], p["host"])
    if key in seen:
        continue
    seen.add(key)
    out.append(f'''      <article class="recommend-card">
        <div class="recommend-title">{html.escape(title)}</div>
        <div class="recommend-name">{html.escape(p["name"])}</div>
        <div class="recommend-meta">{html.escape(proto_label(p["scheme"]))} / {html.escape(p["host"])} / {html.escape(metric)}</div>
      </article>''')
if not out:
    out.append('''      <article class="recommend-card">
        <div class="recommend-title">Рейтинг появится после теста</div>
        <div class="recommend-name">Запусти benchmark на сервере</div>
        <div class="recommend-meta">sudo yurich-panel.sh protocol-benchmark-monitor</div>
      </article>''')
print("\n".join(out))
PY
    else
        cat <<'EOF'
      <article class="recommend-card">
        <div class="recommend-title">Рейтинг появится после теста</div>
        <div class="recommend-name">Запусти benchmark на сервере</div>
        <div class="recommend-meta">sudo yurich-panel.sh protocol-benchmark-monitor</div>
      </article>
EOF
    fi
}

subscription_all_recommendations_html() {
    local links="${1:-}" log_file="${PROTOCOL_BENCHMARK_LOG:-$PROTOCOL_BENCHMARK_LOG_DEFAULT}"
    if command -v python3 >/dev/null 2>&1; then
        LINKS="$links" LOG_FILE="$log_file" python3 - <<'PY'
import csv
import html
import os
from urllib.parse import unquote, urlsplit

links = [x.strip() for x in os.environ.get("LINKS", "").splitlines() if x.strip()]
log_file = os.environ.get("LOG_FILE", "")

rows = []
try:
    if log_file and os.path.exists(log_file):
        with open(log_file, "r", encoding="utf-8", errors="replace") as f:
            rows = list(csv.DictReader(f))[-700:]
except Exception:
    rows = []

scores = {}
for r in rows:
    key = (r.get("scheme", ""), r.get("host", ""))
    item = scores.setdefault(key, {"ok": 0, "fail": 0, "avg": []})
    if r.get("status") == "OK":
        item["ok"] += 1
        try:
            item["avg"].append(int(r.get("avg_ms") or 0))
        except Exception:
            pass
    elif r.get("status") == "FAIL":
        item["fail"] += 1

def proto_label(scheme: str) -> str:
    if scheme.startswith("naive"):
        return "HTTPS"
    if scheme in ("hy2", "hysteria2"):
        return "Turbo"
    if scheme == "vless":
        return "Reality"
    return scheme or "Профиль"

def display_host(u):
    host = u.hostname or ""
    try:
        port = u.port
    except ValueError:
        port = None
    if port:
        return f"{host}:{port}"
    return host

out = []
seen = set()
for line in links:
    try:
        u = urlsplit(line)
    except Exception:
        continue
    scheme = (u.scheme or "").lower()
    host = u.hostname or ""
    key = (scheme, host, u.fragment, u.netloc)
    if key in seen:
        continue
    seen.add(key)
    proto = proto_label(scheme)
    name = unquote(u.fragment or f"{display_host(u)} • {proto}")
    score = scores.get((scheme, host), {})
    vals = score.get("avg") or []
    if vals:
        metric = f"avg {int(sum(vals) / len(vals))} ms"
        if score.get("fail", 0):
            metric += f" / warn {score.get('fail', 0)}"
    else:
        metric = "ожидает benchmark"
    out.append(f'''      <article class="recommend-card">
        <div>
          <div class="recommend-title">{html.escape(proto)}</div>
          <div class="recommend-name">{html.escape(name)}</div>
          <div class="recommend-meta">{html.escape(display_host(u))} / {html.escape(metric)}</div>
        </div>
        <button class="btn copy recommend-copy" data-copy="{html.escape(line, quote=True)}">Скопировать</button>
      </article>''')

if not out:
    out.append('''      <article class="recommend-card">
        <div class="recommend-title">Профили не найдены</div>
        <div class="recommend-name">Активные подключения пока не настроены</div>
        <div class="recommend-meta">Проверь подписку и список серверов</div>
      </article>''')
print("\n".join(out))
PY
        return
    fi

    local line protocol host name safe_line safe_protocol safe_host safe_name count=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        count=$((count + 1))
        protocol=$(subscription_profile_protocol "$line")
        host=$(subscription_profile_host "$line")
        name=$(subscription_profile_name_from_uri "$line")
        safe_line=$(html_escape_text "$line")
        safe_protocol=$(html_escape_text "$protocol")
        safe_host=$(html_escape_text "$host")
        safe_name=$(html_escape_text "$name")
        cat <<EOF
      <article class="recommend-card">
        <div>
          <div class="recommend-title">${safe_protocol}</div>
          <div class="recommend-name">${safe_name}</div>
          <div class="recommend-meta">${safe_host} / ожидает benchmark</div>
        </div>
        <button class="btn copy recommend-copy" data-copy="${safe_line}">Скопировать</button>
      </article>
EOF
    done <<< "$links"

    if [[ "$count" -eq 0 ]]; then
        cat <<'EOF'
      <article class="recommend-card">
        <div class="recommend-title">Профили не найдены</div>
        <div class="recommend-name">Активные подключения пока не настроены</div>
        <div class="recommend-meta">Проверь подписку и список серверов</div>
      </article>
EOF
    fi
}

ensure_qrencode_for_subscriptions() {
    command -v qrencode >/dev/null 2>&1 && return 0
    if [[ "${EUID:-$(id -u)}" -eq 0 ]] && command -v apt-get >/dev/null 2>&1; then
        DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null 2>&1 || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q qrencode >/dev/null 2>&1 || true
    fi
    command -v qrencode >/dev/null 2>&1
}

write_subscription_qr() {
    local value="${1:-}" output="${2:-}"
    [[ -n "$value" && -n "$output" ]] || return 1
    ensure_qrencode_for_subscriptions || return 1
    qrencode -o "$output" -s 8 -m 2 -- "$value" 2>/dev/null || return 1
    chmod 644 "$output" 2>/dev/null || true
}

subscription_qr_cards_html() {
    local label image_file url hint image_name safe_label safe_image safe_url safe_hint count=0

    while IFS='|' read -r label image_file url hint; do
        [[ -n "$label" && -n "$image_file" && -n "$url" ]] || continue
        [[ -s "$image_file" ]] || continue
        count=$((count + 1))
        image_name="${image_file##*/}"
        safe_label=$(html_escape_text "$label")
        safe_image=$(html_escape_text "$image_name")
        safe_url=$(html_escape_text "$url")
        safe_hint=$(html_escape_text "$hint")
        cat <<EOF
      <article class="qr-item">
        <div class="qr-glow"></div>
        <img src="${safe_image}" alt="QR ${safe_label}" loading="lazy">
        <div class="qr-title">${safe_label}</div>
        <div class="qr-hint">${safe_hint}</div>
        <button class="btn copy qr-copy" data-copy="${safe_url}">Скопировать ссылку</button>
      </article>
EOF
    done

    if [[ "$count" -eq 0 ]]; then
        cat <<'EOF'
      <div class="empty-state">QR-коды пока недоступны. Используй кнопки копирования выше.</div>
EOF
    fi
}

ensure_web_privacy_files() {
    mkdir -p "$WEBROOT" "$SUBS_WEB_DIR" "$PRIVATE_WEB_DIR"
    cat > "${WEBROOT}/robots.txt" <<'EOF'
User-agent: *
Disallow: /s/
Disallow: /p/
EOF
    chmod 644 "${WEBROOT}/robots.txt"

    cat > "${SUBS_WEB_DIR}/index.html" <<'EOF'
<!doctype html><html lang="ru"><head><meta charset="utf-8"><meta name="robots" content="noindex,nofollow"><title>404</title></head><body>404</body></html>
EOF
    cat > "${PRIVATE_WEB_DIR}/index.html" <<'EOF'
<!doctype html><html lang="ru"><head><meta charset="utf-8"><meta name="robots" content="noindex,nofollow"><title>404</title></head><body>404</body></html>
EOF
    chmod 644 "${SUBS_WEB_DIR}/index.html" "${PRIVATE_WEB_DIR}/index.html"
}

get_or_create_token_file() {
    local token_file="$1"
    local token=""
    mkdir -p "$(dirname "$token_file")"
    chmod 700 "$(dirname "$token_file")" 2>/dev/null || true
    if [[ -s "$token_file" ]]; then
        token=$(tr -dc 'a-fA-F0-9' < "$token_file" | head -c 48 || true)
    fi
    if [[ ! "$token" =~ ^[a-fA-F0-9]{32,64}$ ]]; then
        token=$(openssl rand -hex 24)
        printf '%s\n' "$token" > "$token_file"
        chmod 600 "$token_file"
    fi
    printf '%s\n' "$token"
}

reset_token_file() {
    local token_file="$1"
    mkdir -p "$(dirname "$token_file")"
    chmod 700 "$(dirname "$token_file")" 2>/dev/null || true
    openssl rand -hex 24 > "$token_file"
    chmod 600 "$token_file"
}

remove_web_token_dir() {
    local base_dir="$1"
    local token="$2"
    if [[ ! "$token" =~ ^[a-fA-F0-9]{32,64}$ ]]; then
        return 0
    fi
    case "$base_dir" in
        "$SUBS_WEB_DIR"|"$PRIVATE_WEB_DIR") ;;
        *)
            warn "Отказываюсь удалять неожиданный web path: ${base_dir}"
            return 1
            ;;
    esac
    if [[ -z "${WEBROOT:-}" || "$base_dir" != "${WEBROOT}/"* ]]; then
        warn "Отказываюсь удалять path вне WEBROOT: ${base_dir}"
        return 1
    fi
    rm -rf -- "${base_dir}/${token}" 2>/dev/null || true
}

cleanup_subscription_page() {
    local user="$1"
    local token_file old_token

    if ! is_valid_proxy_user "$user"; then
        return 0
    fi

    token_file="${SUBS_DIR}/${user}.token"
    old_token=""
    if [[ -s "$token_file" ]]; then
        old_token=$(tr -dc 'a-fA-F0-9' < "$token_file" | head -c 48 || true)
    fi
    if [[ "$old_token" =~ ^[a-fA-F0-9]{32,64}$ ]]; then
        remove_web_token_dir "$SUBS_WEB_DIR" "$old_token"
    fi
    rm -f -- "$token_file" 2>/dev/null || true
}

subscription_user_exists() {
    local user="$1"
    get_user_pass "$user" >/dev/null 2>&1 && return 0
    [[ -n "$(get_xray_user_uuid "$user" 2>/dev/null || true)" ]] && return 0
    return 1
}

remove_user_from_colon_file() {
    local file="$1" user="$2" tmp
    [[ -f "$file" ]] || return 1
    if ! awk -F: -v user="$user" '$1 == user {found=1} END {exit found ? 0 : 1}' "$file"; then
        return 1
    fi
    tmp=$(mktemp)
    awk -F: -v user="$user" '$1 != user' "$file" > "$tmp" && cat "$tmp" > "$file"
    rm -f "$tmp"
    chmod 600 "$file" 2>/dev/null || true
    return 0
}

cleanup_orphan_subscription_pages() {
    load_config
    load_users
    mkdir -p "$SUBS_DIR" "$SUBS_WEB_DIR"

    local token_file user token
    shopt -s nullglob
    for token_file in "$SUBS_DIR"/*.token; do
        user=$(basename "$token_file" .token)
        if ! subscription_user_exists "$user"; then
            cleanup_subscription_page "$user"
        fi
    done
    shopt -u nullglob

    local keep_file dir name
    keep_file=$(mktemp)
    shopt -s nullglob
    for token_file in "$SUBS_DIR"/*.token; do
        token=$(tr -dc 'a-fA-F0-9' < "$token_file" | head -c 48 || true)
        [[ "$token" =~ ^[a-fA-F0-9]{32,64}$ ]] && printf '%s\n' "$token" >> "$keep_file"
    done
    if [[ -f "$SUBS_ALIASES_FILE" ]]; then
        awk '
            /^[[:space:]]*#/ || NF < 2 { next }
            $1 ~ /^[A-Fa-f0-9]{32,64}$/ { print $1 }
        ' "$SUBS_ALIASES_FILE" >> "$keep_file" 2>/dev/null || true
    fi
    for dir in "$SUBS_WEB_DIR"/*; do
        [[ -d "$dir" ]] || continue
        name=$(basename "$dir")
        [[ "$name" =~ ^[a-fA-F0-9]{32,64}$ ]] || continue
        if ! grep -qx "$name" "$keep_file" 2>/dev/null; then
            remove_web_token_dir "$SUBS_WEB_DIR" "$name"
        fi
    done
    shopt -u nullglob
    rm -f "$keep_file"
}

apply_subscription_aliases() {
    load_config
    mkdir -p "$SUBS_WEB_DIR"
    [[ -f "$SUBS_ALIASES_FILE" ]] || return 0

    local alias target user alias_dir target_dir primary_tokens token_file
    primary_tokens=$(mktemp)
    shopt -s nullglob
    for token_file in "$SUBS_DIR"/*.token; do
        tr -dc 'a-fA-F0-9\n' < "$token_file" | head -n1 >> "$primary_tokens" 2>/dev/null || true
    done
    shopt -u nullglob

    while read -r alias target user _; do
        [[ "$alias" =~ ^[A-Fa-f0-9]{32,64}$ && "$target" =~ ^[A-Fa-f0-9]{32,64}$ ]] || continue
        [[ "$alias" == "$target" ]] && continue
        target_dir="${SUBS_WEB_DIR}/${target}"
        alias_dir="${SUBS_WEB_DIR}/${alias}"
        [[ -d "$target_dir" ]] || continue
        if grep -qx "$alias" "$primary_tokens" 2>/dev/null; then
            continue
        fi
        if [[ -e "$alias_dir" || -L "$alias_dir" ]]; then
            remove_web_token_dir "$SUBS_WEB_DIR" "$alias" || continue
        fi
        mkdir -p "$alias_dir" || continue
        cp -a "$target_dir/." "$alias_dir/" 2>/dev/null || { rm -rf "$alias_dir"; continue; }
        chmod 755 "$SUBS_WEB_DIR" "$alias_dir" 2>/dev/null || true
        chmod 644 "$alias_dir"/* 2>/dev/null || true
    done < <(awk 'NF >= 2 && $1 !~ /^#/ {print $0}' "$SUBS_ALIASES_FILE" 2>/dev/null || true)
    rm -f "$primary_tokens"
}

delete_subscription_user_everywhere() {
    load_config
    load_users

    local target="$1" has_naive=0 has_xray=0 found=0 naive_changed=0 xray_changed=0 disabled_changed=0
    if ! is_valid_proxy_user "$target"; then
        err "Некорректный логин"
        return 1
    fi

    get_user_pass "$target" >/dev/null 2>&1 && { has_naive=1; found=1; }
    [[ -n "$(get_xray_user_uuid "$target" 2>/dev/null || true)" ]] && { has_xray=1; found=1; }
    [[ -n "$(get_xray_compat_user_uuid "$target" 2>/dev/null || true)" ]] && { has_xray=1; found=1; }
    awk -F: -v user="$target" '$1 == user {found=1} END {exit found ? 0 : 1}' "$DISABLED_USERS_FILE" 2>/dev/null && found=1
    awk -F: -v user="$target" '$1 == user {found=1} END {exit found ? 0 : 1}' "$XRAY_DISABLED_USERS_FILE" 2>/dev/null && found=1

    if [[ "$found" -eq 0 ]]; then
        cleanup_subscription_page "$target"
        cleanup_user_metadata "$target"
        err "Пользователь $target не найден, возможные остатки подписки очищены"
        return 1
    fi
    if [[ "$has_naive" -eq 1 ]] && ! user_is_expired "$target" && [[ "$(active_user_count)" -le 1 ]]; then
        err "Нельзя удалить последнего активного Naive пользователя — иначе прокси может остаться без auth."
        return 1
    fi
    if [[ "$has_xray" -eq 1 ]] && ! user_is_expired "$target" && [[ "$(xray_active_user_count)" -le 1 ]]; then
        err "Нельзя удалить последнего активного Xray пользователя — иначе Xray может пересоздать дефолтный профиль."
        return 1
    fi

    backup_config

    remove_user_from_colon_file "$USERS_FILE" "$target" && naive_changed=1
    remove_user_from_colon_file "$DISABLED_USERS_FILE" "$target" && disabled_changed=1
    remove_user_from_colon_file "$XRAY_USERS_FILE" "$target" && xray_changed=1
    remove_user_from_colon_file "$XRAY_COMPAT_USERS_FILE" "$target" && xray_changed=1
    remove_user_from_colon_file "$XRAY_DISABLED_USERS_FILE" "$target" && disabled_changed=1

    cleanup_user_metadata "$target"
    cleanup_subscription_page "$target"
    cleanup_orphan_subscription_pages

    if [[ "$naive_changed" -eq 1 ]]; then
        rewrite_caddyfile_current || return 1
        systemctl reload caddy 2>/dev/null || systemctl restart caddy
        sync_hysteria_users_if_active >/dev/null 2>&1 || true
    fi
    if [[ "$xray_changed" -eq 1 && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        write_xray_config >/dev/null || return 1
        systemctl restart xray || return 1
    fi

    cmd_nodes_rebuild_subscriptions >/dev/null 2>&1 || true
    if [[ "$(nodes_count 2>/dev/null || echo 0)" -gt 0 ]]; then
        cmd_nodes_sync_users all >/dev/null 2>&1 || warn "Не удалось синхронизировать удаление $target на все nodes"
    fi

    ok "Пользователь $target удалён из Naive/Xray/disabled/metainfo"
    ok "Подписка $target и публичные ссылки удалены"
}

generate_subscription_page() {
    load_config
    load_users

    local user="$1"
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный логин"
        return 1
    fi
    if ! subscription_user_exists "$user"; then
        err "Пользователь $user не найден в Naive/Xray"
        return 1
    fi
    if user_is_expired "$user"; then
        err "Подписка пользователя $user истекла: $(user_expiry_label "$user")"
        return 1
    fi
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен"
        return 1
    fi

    ensure_web_privacy_files

    local token token_file page_dir links_file hiddify_file streisand_file happ_file nekobox_file v2rayng_file pingtunnel_file naive_pass naive_uri naive_json naive_singbox_tun_json hy2_uri hy2_json expiry_label expiry_tag node_links node_app_links active_links app_links happ_links v2rayng_links
    token_file="${SUBS_DIR}/${user}.token"
    token=$(get_or_create_token_file "$token_file")
    page_dir="${SUBS_WEB_DIR}/${token}"
    links_file="${page_dir}/links.txt"
    hiddify_file="${page_dir}/hiddify.txt"
    streisand_file="${page_dir}/streisand.txt"
    happ_file="${page_dir}/happ.txt"
    nekobox_file="${page_dir}/nekobox.txt"
    v2rayng_file="${page_dir}/v2rayng.txt"
    pingtunnel_file="${page_dir}/pingtunnel.txt"
    mkdir -p "$page_dir"
    chmod 755 "$page_dir"
    expiry_label=$(user_expiry_label "$user")
    expiry_tag=$(user_expiry_tag "$user")

    naive_pass=$(get_active_user_pass "$user" 2>/dev/null || true)
    naive_uri=""
    yurich_uri=""
    naive_json=""
    naive_singbox_tun_json=""
    if [[ -n "$naive_pass" ]]; then
        naive_uri=$(uri_with_profile_name "naive+https://${user}:${naive_pass}@${DOMAIN}:443" "$(pretty_profile_name "$user" "HTTPS")")
        yurich_uri=$(yurich_proxy_uri "$user" "$naive_pass" "$(pretty_profile_name "$user" "HTTPS")")
        naive_json=$(cat <<EOF
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://${user}:${naive_pass}@${DOMAIN}:443"
}
EOF
)
        naive_singbox_tun_json=$(singbox_naive_tun_json "$user" "$naive_pass")
    fi

    hy2_uri=""
    hy2_json=""
    if [[ -n "$naive_pass" && -n "${HYSTERIA_OBFS_PASSWORD:-}" && ( -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ) ]]; then
        hy2_uri=$(hysteria_uri_for_user "$user" 2>/dev/null || true)
        if [[ -n "$hy2_uri" ]]; then
            hy2_uri=$(uri_with_profile_name "$hy2_uri" "$(pretty_profile_name "$user" "Turbo")")
            hy2_json=$(cat <<EOF
{
  "type": "hysteria2",
  "tag": "hysteria2-out",
  "server": "${DOMAIN}",
  "server_port": ${HYSTERIA_PORT:-8443},
  "password": "${user}:${naive_pass}",
  "obfs": {
    "type": "salamander",
    "password": "${HYSTERIA_OBFS_PASSWORD}"
  },
  "tls": {
    "enabled": true,
    "server_name": "${DOMAIN}"
  }
}
EOF
)
        fi
    fi

    local uuid compat_uuid reality_link compat_link mobile_alt_link github_test_link reality_direct_link reality_links reality_test_links trojan_link reality_public_port reality_direct_port reality_public_label reality_direct_label github_test_users_norm github_test_sni
    reality_public_port=$(xray_reality_public_port)
    reality_direct_port="${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
    uuid=$(get_xray_user_uuid "$user" 2>/dev/null || true)
    compat_uuid=$(get_xray_compat_user_uuid "$user" 2>/dev/null || true)
    reality_link=""
    compat_link=""
    mobile_alt_link=""
    github_test_link=""
    reality_direct_link=""
    reality_links=""
    reality_test_links=""
    trojan_link=""
    if [[ -n "$uuid" ]]; then
        reality_public_label="Reality"
        reality_direct_label="Reality"
        reality_link=$(uri_with_profile_name "vless://${uuid}@${DOMAIN}:${reality_public_port}?encryption=none&security=reality&type=tcp&flow=xtls-rprx-vision&sni=${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}&spx=%2F" "$(pretty_profile_name "$user" "$reality_public_label")")
        if [[ "${XRAY_GITHUB_TEST_ENABLED:-0}" == "1" ]]; then
            github_test_users_norm=",${XRAY_GITHUB_TEST_USERS//[[:space:]]/},"
            if [[ -z "${XRAY_GITHUB_TEST_USERS:-}" || "$github_test_users_norm" == *",$user,"* ]]; then
                github_test_sni="${XRAY_GITHUB_TEST_SERVER_NAME:-$XRAY_GITHUB_TEST_SERVER_NAME_DEFAULT}"
                github_test_link=$(uri_with_profile_name "vless://${uuid}@${DOMAIN}:${reality_public_port}?encryption=none&security=reality&type=tcp&flow=xtls-rprx-vision&sni=${github_test_sni}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}&spx=%2Fgithub-test-${user}" "$(pretty_profile_name "$user" "Reality GitHub TEST")")
            fi
        fi
    fi
    if [[ -n "$compat_uuid" ]]; then
        compat_link=$(uri_with_profile_name "vless://${compat_uuid}@${DOMAIN}:${reality_public_port}?encryption=none&security=reality&type=tcp&headerType=none&packetEncoding=xudp&sni=${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}&spx=%2Fcompat-${user}" "$(pretty_profile_name "$user" "Reality MOBILE TEST")")
        mobile_alt_link=$(uri_with_profile_name "vless://${compat_uuid}@${DOMAIN}:${reality_public_port}?encryption=none&security=reality&type=tcp&headerType=none&packetEncoding=xudp&sni=${XRAY_MOBILE_ALT_SERVER_NAME:-$XRAY_MOBILE_ALT_SERVER_NAME_DEFAULT}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}&spx=%2Fmobile-alt-${user}" "$(pretty_profile_name "$user" "Reality ALT MOBILE TEST")")
    fi
    reality_links=$({
        [[ -n "$reality_link" ]] && printf '%s\n' "$reality_link"
        [[ -n "$github_test_link" ]] && printf '%s\n' "$github_test_link"
    } | awk 'NF')
    reality_test_links=$({
        [[ -n "$compat_link" ]] && printf '%s\n' "$compat_link"
        [[ -n "$mobile_alt_link" ]] && printf '%s\n' "$mobile_alt_link"
    } | awk 'NF')
    node_links=$(node_links_for_user "$user" "$naive_pass" "$expiry_tag" 2>/dev/null || true)
    node_app_links=$(node_app_links_for_user "$user" 2>/dev/null || true)
    local subscription_local_enabled subscription_local_position local_links local_app_links
    subscription_local_enabled="${SUBSCRIPTION_LOCAL_ENABLED:-1}"
    [[ "$subscription_local_enabled" == "0" ]] || subscription_local_enabled="1"
    subscription_local_position="${SUBSCRIPTION_LOCAL_POSITION:-first}"
    case "$subscription_local_position" in
        first|last) ;;
        *) subscription_local_position="first" ;;
    esac
    local_links=$({
        [[ -n "$naive_uri" ]] && printf '%s\n' "$naive_uri"
        [[ -n "$hy2_uri" ]] && printf '%s\n' "$hy2_uri"
        [[ -n "$reality_links" ]] && printf '%s\n' "$reality_links"
    } | awk 'NF')
    local_app_links=$({
        [[ -n "$hy2_uri" ]] && printf '%s\n' "$hy2_uri"
        [[ -n "$reality_links" ]] && printf '%s\n' "$reality_links"
    } | awk 'NF')
    if [[ "$subscription_local_enabled" == "0" ]]; then
        active_links=$({
            [[ -n "$node_links" ]] && printf '%s\n' "$node_links"
            [[ -n "$node_app_links" ]] && printf '%s\n' "$node_app_links"
        } | awk 'NF')
        app_links=$(printf '%s\n' "$node_app_links" | awk 'NF')
    elif [[ "$subscription_local_position" == "last" ]]; then
        active_links=$({
            [[ -n "$node_links" ]] && printf '%s\n' "$node_links"
            [[ -n "$node_app_links" ]] && printf '%s\n' "$node_app_links"
            [[ -n "$local_links" ]] && printf '%s\n' "$local_links"
        } | awk 'NF')
        app_links=$({
            [[ -n "$node_app_links" ]] && printf '%s\n' "$node_app_links"
            [[ -n "$local_app_links" ]] && printf '%s\n' "$local_app_links"
        } | awk 'NF')
    else
        active_links=$({
            [[ -n "$local_links" ]] && printf '%s\n' "$local_links"
            [[ -n "$node_links" ]] && printf '%s\n' "$node_links"
            [[ -n "$node_app_links" ]] && printf '%s\n' "$node_app_links"
        } | awk 'NF')
        app_links=$({
            [[ -n "$local_app_links" ]] && printf '%s\n' "$local_app_links"
            [[ -n "$node_app_links" ]] && printf '%s\n' "$node_app_links"
        } | awk 'NF')
    fi
    active_links=$(printf '%s\n' "$active_links" | subscription_filter_published_links)
    app_links=$(printf '%s\n' "$app_links" | subscription_filter_published_links)
    v2rayng_links=$(printf '%s\n' "$app_links" | awk 'NF && /^vless:\/\// && /security=reality/ && /type=tcp/ { if (!seen[$0]++) print }')
    happ_links=$(printf '%s\n' "$v2rayng_links" | happ_compat_links)
    printf '%s\n' "$active_links" > "$links_file"
    printf '%s\n' "$app_links" > "$nekobox_file"
    printf '%s\n' "$v2rayng_links" > "$v2rayng_file"
    {
        printf '#routing-enable: 0\n'
        printf '#server-address-resolve-enable: 1\n'
        printf '#server-address-resolve-dns-domain: https://common.dot.dns.yandex.net/dns-query\n'
        printf '#server-address-resolve-dns-ip: 77.88.8.8\n'
        printf '#ping-type proxy\n'
        printf '#check-url-via-proxy: https://cp.cloudflare.com/generate_204\n'
        printf '#subscription-ping-onopen-enabled: 1\n'
        printf '#subscription-auto-update-enable: 1\n'
        printf '%s\n' "$happ_links"
    } > "$happ_file"
    rm -f "${page_dir}/qr-happ.png" "${page_dir}/mobile-test.txt" "${page_dir}/qr-mobile-test.png" 2>/dev/null || true
    chmod 644 "$links_file" "$happ_file" "$nekobox_file" "$v2rayng_file"
    if [[ -f "$PINGTUNNEL_ENV" && -x "$PINGTUNNEL_BIN" ]]; then
        write_pingtunnel_subscription_file "$pingtunnel_file" "$DOMAIN" "$user" || rm -f "$pingtunnel_file"
    else
        rm -f "$pingtunnel_file"
    fi

    local sub_url links_url hiddify_url streisand_url happ_url nekobox_url v2rayng_url pingtunnel_url hiddify_open_url hiddify_expire_epoch hiddify_used_bytes hiddify_used_human hiddify_links title display_profile_label active_locations safe_active_locations safe_user safe_domain safe_expiry_label safe_days_left safe_hiddify_used_human safe_profile_label safe_naive_uri safe_naive_json safe_naive_singbox_tun_json safe_hy2_uri safe_hy2_json safe_node_links
    local safe_android_url safe_windows_url safe_streisand_url safe_karing_url safe_telegram_url safe_donation_url safe_tg_bot_url safe_tg_id_bot_url safe_vk_url safe_support_email safe_support_mailto
    local traffic_summary safe_traffic_summary profile_cards_html profile_count qr_cards_html recommendations_html recommendations_all_html
    local subscription_logo_source subscription_logo_name subscription_logo_html subscription_header_logo_html
    local project_help_qr_source project_help_qr_name project_help_qr_html
    local qr_links_png qr_hiddify_png qr_streisand_png qr_happ_png qr_nekobox_png qr_v2rayng_png
    sub_url="https://${DOMAIN}/s/${token}/"
    links_url="${sub_url}links.txt"
    hiddify_url="${sub_url}hiddify.txt"
    streisand_url="${sub_url}streisand.txt"
    happ_url="${sub_url}happ.txt"
    nekobox_url="${sub_url}nekobox.txt"
    v2rayng_url="${sub_url}v2rayng.txt"
    pingtunnel_url="${sub_url}pingtunnel.txt"
    hiddify_open_url="hiddify://import/${hiddify_url}#$(uri_fragment_encode "Yurich Connect ${user}")"
    hiddify_expire_epoch=$(user_expiry_epoch "$user" 2>/dev/null || true)
    subscription_refresh_traffic_meta "$user" >/dev/null 2>&1 || true
    hiddify_used_bytes=$(user_meta_get "$user" TRAFFIC_USED_BYTES 2>/dev/null || true)
    [[ "$hiddify_used_bytes" =~ ^[0-9]+$ ]] || hiddify_used_bytes="0"
    hiddify_used_human=$(subscription_human_bytes "$hiddify_used_bytes")
    {
        printf '#profile-title: Yurich Connect %s\n' "$user"
        printf '#profile-update-interval: 12\n'
        if [[ -n "$hiddify_expire_epoch" ]]; then
            printf '#subscription-userinfo: upload=0; download=%s; total=0; expire=%s\n' "$hiddify_used_bytes" "$hiddify_expire_epoch"
        fi
        printf '#support-url: %s\n' "$TELEGRAM_COMMUNITY_URL"
        printf '#profile-web-page-url: %s\n' "$sub_url"
        hiddify_links=$(printf '%s\n' "$app_links" | awk 'NF && !seen[$0]++' | hiddify_compat_links)
        printf '%s\n' "$hiddify_links"
    } > "$hiddify_file"
    {
        printf '#profile-title: Yurich Connect %s iOS\n' "$user"
        printf '#profile-update-interval: 12\n'
        if [[ -n "$hiddify_expire_epoch" ]]; then
            printf '#subscription-userinfo: upload=0; download=%s; total=0; expire=%s\n' "$hiddify_used_bytes" "$hiddify_expire_epoch"
        fi
        printf '#support-url: %s\n' "$TELEGRAM_COMMUNITY_URL"
        printf '#profile-web-page-url: %s\n' "$sub_url"
        printf '%s\n' "$hiddify_links"
    } > "$streisand_file"
    chmod 644 "$hiddify_file" "$streisand_file"
    qr_links_png="${page_dir}/qr-links.png"
    qr_hiddify_png="${page_dir}/qr-hiddify.png"
    qr_streisand_png="${page_dir}/qr-streisand.png"
    qr_happ_png="${page_dir}/qr-happ.png"
    qr_nekobox_png="${page_dir}/qr-nekobox.png"
    qr_v2rayng_png="${page_dir}/qr-v2rayng.png"
    write_subscription_qr "$links_url" "$qr_links_png" || rm -f "$qr_links_png"
    write_subscription_qr "$hiddify_url" "$qr_hiddify_png" || rm -f "$qr_hiddify_png"
    write_subscription_qr "$streisand_url" "$qr_streisand_png" || rm -f "$qr_streisand_png"
    rm -f "$qr_happ_png"
    write_subscription_qr "$nekobox_url" "$qr_nekobox_png" || rm -f "$qr_nekobox_png"
    write_subscription_qr "$v2rayng_url" "$qr_v2rayng_png" || rm -f "$qr_v2rayng_png"
    subscription_logo_source="${SUBSCRIPTION_LOGO_PATH:-$SUBSCRIPTION_LOGO_PATH_DEFAULT}"
    subscription_logo_name="yurich-connect-logo.png"
    if [[ -s "$subscription_logo_source" ]]; then
        cp -f "$subscription_logo_source" "${page_dir}/${subscription_logo_name}" 2>/dev/null || true
        chmod 644 "${page_dir}/${subscription_logo_name}" 2>/dev/null || true
    fi
    if [[ -s "${page_dir}/${subscription_logo_name}" ]]; then
        subscription_header_logo_html="<img src=\"${subscription_logo_name}\" alt=\"Yurich Connect\" loading=\"lazy\">"
        subscription_logo_html="<img src=\"${subscription_logo_name}\" alt=\"Yurich Connect\" loading=\"lazy\">"
    else
        subscription_header_logo_html="<span>YC</span>"
        subscription_logo_html="<span>YC</span>"
    fi
    project_help_qr_source="${SUBSCRIPTION_PROJECT_HELP_QR_PATH:-$SUBSCRIPTION_PROJECT_HELP_QR_PATH_DEFAULT}"
    project_help_qr_name="project-help-qr.jpg"
    if [[ -s "$project_help_qr_source" ]]; then
        cp -f "$project_help_qr_source" "${page_dir}/${project_help_qr_name}" 2>/dev/null || true
        chmod 644 "${page_dir}/${project_help_qr_name}" 2>/dev/null || true
    fi
    if [[ -s "${page_dir}/${project_help_qr_name}" ]]; then
        project_help_qr_html="<div class=\"help-qr-card\"><img class=\"help-qr\" src=\"${project_help_qr_name}\" alt=\"QR для помощи проекту\" loading=\"lazy\"><span>QR для помощи проекту</span></div>"
    else
        project_help_qr_html=""
    fi
    title="Yurich Connect: подписка ${user}"
    safe_user=$(html_escape_text "$user")
    safe_domain=$(html_escape_text "$DOMAIN")
    safe_expiry_label=$(html_escape_text "$expiry_label")
    if [[ -n "$(get_user_expiry "$user" 2>/dev/null || true)" ]]; then
        safe_days_left=$(html_escape_text "$(days_until_expiry "$(get_user_expiry "$user")" 2>/dev/null || printf '0')")
    else
        safe_days_left="∞"
    fi
    safe_hiddify_used_human=$(html_escape_text "$hiddify_used_human")
    display_profile_label=$(subscription_active_locations_label "$active_links")
    [[ -n "$display_profile_label" ]] || display_profile_label=$(profile_location_label)
    safe_profile_label=$(html_escape_text "$display_profile_label")
    safe_naive_uri=$(html_escape_text "$naive_uri")
    safe_naive_json=$(html_escape_text "$naive_json")
    safe_naive_singbox_tun_json=$(html_escape_text "$naive_singbox_tun_json")
    safe_hy2_uri=$(html_escape_text "$hy2_uri")
    safe_hy2_json=$(html_escape_text "$hy2_json")
    safe_node_links=$(html_escape_text "$active_links")
    safe_android_url=$(html_escape_text "$ANDROID_APP_RELEASES_URL")
    safe_windows_url=$(html_escape_text "$WINDOWS_APP_RELEASES_URL")
    safe_streisand_url=$(html_escape_text "$STREISAND_APP_URL")
    safe_karing_url=$(html_escape_text "$KARING_APP_URL")
    safe_telegram_url=$(html_escape_text "$TELEGRAM_COMMUNITY_URL")
    safe_donation_url=$(html_escape_text "$PROJECT_DONATION_URL")
    safe_tg_bot_url=$(html_escape_text "$TELEGRAM_BOT_URL")
    safe_tg_id_bot_url=$(html_escape_text "$TELEGRAM_ID_BOT_URL")
    safe_vk_url=$(html_escape_text "$VK_COMMUNITY_URL")
    safe_support_email=$(html_escape_text "$SUPPORT_EMAIL")
    safe_support_mailto=$(html_escape_text "mailto:${SUPPORT_EMAIL}")
    traffic_summary=$(subscription_traffic_summary "$user")
    safe_traffic_summary=$(html_escape_text "$traffic_summary")
    active_locations=$(subscription_active_locations_label "$active_links")
    [[ -n "$active_locations" ]] || active_locations="$display_profile_label"
    safe_active_locations=$(html_escape_text "$active_locations")
    profile_cards_html=$(subscription_profile_cards_html "$active_links")
    recommendations_html=$(subscription_recommendations_html "$active_links")
    recommendations_all_html=$(subscription_all_recommendations_html "$active_links")
    profile_count=$(printf '%s\n' "$active_links" | awk 'NF{c++} END{print c+0}')
    qr_cards_html=$(printf '%s\n' \
        "Основная|${qr_links_png}|${links_url}|Для Yurich Connect, v2rayN и универсального импорта" \
        "Hiddify|${qr_hiddify_png}|${hiddify_url}|Сканируй внутри Hiddify: это обычный URL подписки" \
        "Streisand iOS|${qr_streisand_png}|${streisand_url}|Отдельный iOS-набор для Streisand и совместимых клиентов" \
        "NekoBox|${qr_nekobox_png}|${nekobox_url}|Для NekoBox и совместимых клиентов" \
        "v2rayNG|${qr_v2rayng_png}|${v2rayng_url}|Только VLESS Reality через TCP/${reality_public_port}" | subscription_qr_cards_html)

    local safe_reality safe_trojan safe_links_url safe_hiddify_url safe_streisand_sub_url safe_happ_url safe_hiddify_open_url safe_nekobox_url safe_v2rayng_url safe_pingtunnel_url pingtunnel_panel_html
    safe_reality=$(html_escape_text "$reality_link")
    safe_trojan=$(html_escape_text "$trojan_link")
    safe_links_url=$(html_escape_text "$links_url")
    safe_hiddify_url=$(html_escape_text "$hiddify_url")
    safe_streisand_sub_url=$(html_escape_text "$streisand_url")
    safe_happ_url=$(html_escape_text "$happ_url")
    safe_hiddify_open_url=$(html_escape_text "$hiddify_open_url")
    safe_nekobox_url=$(html_escape_text "$nekobox_url")
    safe_v2rayng_url=$(html_escape_text "$v2rayng_url")
    safe_pingtunnel_url=$(html_escape_text "$pingtunnel_url")
    pingtunnel_panel_html=""
    if [[ -s "$pingtunnel_file" ]]; then
        pingtunnel_panel_html=$(cat <<EOF
    <section class="panel notice">
      <h2>PingTunnel / ICMP fallback</h2>
      <p class="lead">Ручной резервный туннель через ICMP. Он не импортируется напрямую в Hiddify, v2rayNG, NekoBox или Streisand: сначала запускается локальный SOCKS5-клиент, потом приложение или браузер направляется на <code>127.0.0.1:10888</code>.</p>
      <div class="steps">
        <div class="step"><b>1. Скачать</b>Скачай PingTunnel под свою ОС и запусти от администратора/root.</div>
        <div class="step"><b>2. Запустить</b>Открой файл <code>pingtunnel.txt</code> и выполни команду клиента.</div>
        <div class="step"><b>3. Проверить</b>Проверь выход через SOCKS5: <code>127.0.0.1:10888</code>.</div>
      </div>
      <a class="btn gold" href="${safe_pingtunnel_url}">Открыть pingtunnel.txt</a>
      <button class="btn copy" data-copy="${safe_pingtunnel_url}">Скопировать PingTunnel URL</button>
    </section>
EOF
)
    fi

    if subscription_premium_v2_page_enabled "$user"; then
        cat > "${page_dir}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex,nofollow,noarchive">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests">
<title>${title}</title>
<style>
:root{--bg:#080a0f;--panel:#101720;--panel2:#151f2b;--ink:#f7fbff;--muted:#93a4b6;--soft:#d9e6f2;--line:#263747;--line2:#3d566b;--cyan:#36e2cf;--blue:#76a9ff;--green:#77dd9a;--gold:#ffc766;--rose:#ff7d8e;--shadow:0 22px 58px rgba(0,0,0,.32)}
*{box-sizing:border-box;min-width:0}
html,body{margin:0;max-width:100%;overflow-x:hidden}
body{min-height:100vh;background:linear-gradient(180deg,#090b10 0%,#111720 46%,#090b10 100%);color:var(--ink);font-family:Inter,Arial,sans-serif;font-size:16px;line-height:1.55;letter-spacing:0}
body:before{content:"";position:fixed;inset:0;z-index:-1;background:linear-gradient(120deg,rgba(54,226,207,.18),transparent 30%),linear-gradient(240deg,rgba(118,169,255,.15),transparent 34%),linear-gradient(180deg,rgba(255,199,102,.08),transparent 42%)}
a{color:inherit}
.page{width:min(1180px,100%);margin:0 auto;padding:22px 16px 52px}
.topbar{display:flex;align-items:center;justify-content:space-between;gap:14px;margin-bottom:18px}
.brand{display:flex;align-items:center;gap:10px;font-weight:950}
.brand-logo{width:48px;height:48px;border-radius:8px;background:linear-gradient(135deg,rgba(54,226,207,.18),rgba(118,169,255,.18));border:1px solid rgba(255,255,255,.14);display:grid;place-items:center;overflow:hidden;box-shadow:0 18px 40px rgba(0,0,0,.22)}
.brand-logo img{display:block;width:100%;height:100%;object-fit:contain;padding:4px}
.brand-logo span{color:var(--cyan);font-size:13px;font-weight:950}
.brand-text b{display:block;font-size:18px}.brand-text span{display:block;color:var(--muted);font-size:12px;font-weight:850}
.top-actions{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:42px;padding:10px 15px;border-radius:8px;border:1px solid rgba(255,255,255,.13);background:#141e2a;color:var(--ink);font-size:14px;font-weight:950;text-decoration:none;cursor:pointer;white-space:nowrap;transition:transform .16s ease,border-color .16s ease,background .16s ease}
.btn:hover{transform:translateY(-1px);border-color:rgba(54,226,207,.58);background:#1a2735}
.btn.primary{background:linear-gradient(135deg,#3ce6d2,#81b2ff);border-color:rgba(54,226,207,.72);color:#041015}
.btn.gold{background:linear-gradient(135deg,#ffd27a,#ff9c5a);border-color:rgba(255,199,102,.72);color:#170d03}
.hero{position:relative;overflow:hidden;border:1px solid rgba(255,255,255,.12);border-radius:8px;background:linear-gradient(135deg,rgba(19,30,42,.96),rgba(10,14,20,.98));box-shadow:var(--shadow);padding:30px;margin-bottom:12px}
.hero:before{content:"";position:absolute;left:0;right:0;top:0;height:4px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold),var(--rose))}
.hero:after{content:"YC";position:absolute;right:28px;bottom:-24px;color:rgba(255,255,255,.035);font-size:168px;line-height:1;font-weight:950;pointer-events:none}
.hero-grid{display:grid;grid-template-columns:minmax(0,1fr) 350px;gap:24px;align-items:stretch}
.eyebrow{display:inline-flex;align-items:center;gap:8px;color:#bffff7;background:rgba(54,226,207,.10);border:1px solid rgba(54,226,207,.24);border-radius:999px;padding:6px 10px;font-size:12px;font-weight:950;text-transform:uppercase;letter-spacing:.06em}
h1{font-size:58px;line-height:1;margin:14px 0 12px;letter-spacing:0}
.lead{margin:0;max-width:740px;color:#d2deea;font-size:18px}
.chips{display:flex;flex-wrap:wrap;gap:8px;margin-top:16px}
.chip{display:inline-flex;align-items:center;gap:7px;padding:8px 11px;border-radius:999px;background:rgba(255,255,255,.065);border:1px solid rgba(255,255,255,.13);font-size:13px;font-weight:900}
.chip:nth-child(1){border-color:rgba(54,226,207,.36);background:rgba(54,226,207,.10)}.chip:nth-child(2){border-color:rgba(255,199,102,.36);background:rgba(255,199,102,.10)}.chip:nth-child(3){border-color:rgba(118,169,255,.36);background:rgba(118,169,255,.10)}
.account-card{position:relative;border:1px solid rgba(255,255,255,.14);border-radius:8px;background:linear-gradient(160deg,rgba(255,255,255,.10),rgba(255,255,255,.035));padding:16px;backdrop-filter:blur(14px);box-shadow:inset 0 1px 0 rgba(255,255,255,.08)}
.account-card:before{content:"ACCESS PASS";display:block;color:#bffff7;font-size:11px;font-weight:950;letter-spacing:.12em;margin-bottom:6px}
.account-row{display:grid;grid-template-columns:98px minmax(0,1fr);gap:12px;padding:9px 0;border-bottom:1px solid rgba(255,255,255,.09)}
.account-row:last-child{border-bottom:0}.account-row span{color:var(--muted);font-size:11px;text-transform:uppercase;letter-spacing:.05em;font-weight:900}.account-row b{text-align:right;overflow-wrap:anywhere}
.metrics{display:grid;grid-template-columns:1.35fr 1fr 1fr;gap:10px;margin-bottom:14px;padding:10px;border:1px solid rgba(255,255,255,.10);border-radius:8px;background:rgba(255,255,255,.045)}
.card{border:1px solid rgba(255,255,255,.10);border-radius:8px;background:rgba(16,23,34,.86);box-shadow:0 16px 42px rgba(0,0,0,.18)}
.metric{padding:13px 14px;min-height:104px;display:flex;flex-direction:column;justify-content:space-between;position:relative;overflow:hidden;background:rgba(9,13,19,.50)}
.metric:before{content:"";position:absolute;left:0;right:0;top:0;height:2px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold))}
.metric small{color:var(--muted);font-size:10px;font-weight:950;text-transform:uppercase;letter-spacing:.08em}.metric strong{font-size:30px;line-height:1.05;overflow-wrap:anywhere}.metric p{margin:7px 0 0;color:var(--muted);font-size:12px}
.section{margin-top:14px}.section-head{display:flex;justify-content:space-between;gap:12px;align-items:flex-end;margin-bottom:10px}.section h2{font-size:21px;line-height:1.15;margin:0}.muted{color:var(--muted)}
.install{padding:18px}.install-grid{display:grid;grid-template-columns:minmax(0,1fr) 300px;gap:12px}
.app-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}
.app-card{display:flex;flex-direction:column;justify-content:space-between;gap:12px;min-height:150px;padding:16px;border-radius:8px;border:1px solid rgba(255,255,255,.10);background:linear-gradient(180deg,rgba(255,255,255,.060),rgba(255,255,255,.026))}
.app-card.featured{border-color:rgba(54,226,207,.38);background:linear-gradient(180deg,rgba(26,78,73,.40),rgba(255,255,255,.035))}
.app-title{font-size:16px;font-weight:950}.app-text{color:var(--muted);font-size:13px;margin-top:4px}
.side{padding:15px;border-radius:8px;background:rgba(255,255,255,.045);border:1px solid rgba(255,255,255,.10)}
.file-row{display:grid;grid-template-columns:1fr;gap:8px;margin-top:10px}.file-row .btn{width:100%;min-height:36px}
.recommend-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
.recommend-card{display:flex;flex-direction:column;justify-content:space-between;gap:10px;border:1px solid rgba(255,255,255,.10);border-radius:8px;background:linear-gradient(180deg,rgba(20,32,45,.90),rgba(10,15,22,.94));padding:14px;min-height:132px}
.recommend-title{color:var(--gold);font-size:12px;text-transform:uppercase;letter-spacing:.05em;font-weight:950}.recommend-name{font-size:15px;font-weight:950;overflow-wrap:anywhere}.recommend-meta{color:var(--muted);font-size:12px;overflow-wrap:anywhere}.recommend-copy{width:100%;min-height:36px}
.qr-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:12px}
.qr-item{border:1px solid rgba(255,255,255,.10);border-radius:8px;background:linear-gradient(180deg,rgba(20,32,45,.92),rgba(10,15,22,.96));padding:13px;text-align:center;overflow:hidden}
.qr-glow{height:3px;margin:-12px -12px 12px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold))}
.qr-item img{display:block;width:100%;max-width:164px;aspect-ratio:1/1;margin:0 auto 10px;background:#fff;border-radius:8px;padding:8px}
.qr-title{font-size:14px;font-weight:950;overflow-wrap:anywhere}.qr-hint{color:var(--muted);font-size:12px;min-height:50px;margin:5px 0 9px}.qr-copy{width:100%}
.project-help{position:relative;overflow:hidden;padding:18px;border-color:rgba(54,226,207,.26);background:linear-gradient(135deg,rgba(54,226,207,.10),rgba(118,169,255,.08),rgba(255,199,102,.08)),rgba(16,23,34,.94)}
.help-layout{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:14px;align-items:center}.project-help h2{font-size:21px;margin:0 0 6px}.help-text{margin:0;color:#c8d5e3;max-width:780px}.help-actions{display:flex;gap:10px;align-items:center;justify-content:flex-end;flex-wrap:wrap}
.help-qr-card{display:flex;flex-direction:column;align-items:center;gap:6px;color:#c8d5e3;font-size:12px;font-weight:900}.help-qr{display:block;width:132px;max-width:100%;height:auto;background:#fff;border-radius:8px;padding:5px}
.notice{padding:16px;border-color:rgba(255,191,91,.26);background:linear-gradient(135deg,rgba(255,191,91,.10),rgba(95,157,255,.06)),rgba(16,23,34,.94)}
.steps{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:12px}.step{border:1px solid rgba(255,255,255,.09);border-radius:8px;background:#111a27;padding:12px}.step b{display:block;color:var(--gold);margin-bottom:4px}.mini{display:inline-block;margin-top:5px;color:var(--cyan);font-weight:900;text-decoration:none}
.profiles-details{padding:14px}.profiles-details summary{cursor:pointer;font-weight:950;color:#eaf5ff}.profile-list{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:12px}
.profile-card{padding:12px;border-radius:8px;background:#111a27;border:1px solid rgba(255,255,255,.09)}.profile-top{display:flex;justify-content:space-between;gap:8px;margin-bottom:8px}.profile-type{color:var(--cyan);font-size:11px;font-weight:950;text-transform:uppercase}.profile-host{color:var(--muted);font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.profile-name{font-size:15px;font-weight:950;margin-bottom:10px;overflow-wrap:anywhere}.profile-copy{width:100%}
code{color:#dffbff}.empty-state{border:1px dashed rgba(255,255,255,.16);border-radius:8px;padding:14px;color:var(--muted)}
@media(max-width:1040px){.hero-grid,.install-grid,.metrics{grid-template-columns:1fr}.recommend-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.qr-grid{grid-template-columns:repeat(3,minmax(0,1fr))}.profile-list{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media(max-width:680px){body{font-size:15px}.page{padding:12px 10px 34px}.topbar{display:block}.brand{margin-bottom:10px}.top-actions{display:grid;grid-template-columns:1fr}.btn{width:100%;white-space:normal}.hero{padding:18px}.hero:after{right:8px;bottom:18px;font-size:78px}.hero-grid{gap:16px}h1{font-size:38px}.lead{font-size:16px}.chips{display:grid;grid-template-columns:1fr}.account-row{grid-template-columns:1fr;gap:4px}.account-row b{text-align:left}.metrics{grid-template-columns:1fr;padding:0;background:transparent;border:0}.metric{min-height:96px}.section-head{display:block}.app-grid,.recommend-grid,.qr-grid,.steps,.profile-list{grid-template-columns:1fr}.qr-hint{min-height:auto}.help-layout{grid-template-columns:1fr}.help-actions{display:grid;grid-template-columns:1fr}.help-qr-card{justify-self:center;width:100%;max-width:220px}.help-qr{width:min(210px,100%)}}
</style>
</head>
<body>
<main class="page">
  <header class="topbar">
    <div class="brand">
      <div class="brand-logo">${subscription_header_logo_html}</div>
      <div class="brand-text"><b>Yurich Connect</b><span>Личная страница подписки</span></div>
    </div>
    <div class="top-actions">
      <button class="btn primary copy" data-copy="${safe_links_url}">Скопировать подписку</button>
      <a class="btn" href="${safe_telegram_url}" target="_blank" rel="noopener noreferrer">Telegram</a>
    </div>
  </header>

  <section class="hero">
    <div class="hero-grid">
      <div>
        <div class="eyebrow">Профиль ${safe_user} • активна</div>
        <h1>Yurich Connect VPN</h1>
        <p class="lead">Современная страница подключения для телефона и компьютера: одна подписка, быстрый импорт в приложения, QR-коды и рекомендации по рабочим локациям.</p>
        <div class="chips">
          <span class="chip">HTTPS</span>
          <span class="chip">Turbo</span>
          <span class="chip">Reality</span>
          <span class="chip">${safe_active_locations}</span>
        </div>
      </div>
      <aside class="account-card">
        <div class="account-row"><span>Статус</span><b>Активна</b></div>
        <div class="account-row"><span>Срок</span><b>${safe_expiry_label}</b></div>
        <div class="account-row"><span>Осталось</span><b>${safe_days_left} дней</b></div>
        <div class="account-row"><span>Профилей</span><b>${profile_count}</b></div>
        <div class="account-row"><span>Домен</span><b>${safe_domain}</b></div>
      </aside>
    </div>
  </section>

  <section class="metrics">
    <article class="card metric"><small>Использовано трафика</small><strong>${safe_hiddify_used_human}</strong><p>${safe_traffic_summary}</p></article>
    <article class="card metric"><small>Дней осталось</small><strong>${safe_days_left}</strong><p>${safe_expiry_label}</p></article>
    <article class="card metric"><small>Активные профили</small><strong>${profile_count}</strong><p>${safe_active_locations}</p></article>
  </section>

  <section class="section card install">
    <div class="section-head">
      <div><h2>Подключение</h2><div class="muted">Выбери приложение и добавь подписку без ручной настройки.</div></div>
    </div>
    <div class="install-grid">
      <div class="app-grid">
        <article class="app-card featured">
          <div><div class="app-title">Yurich Connect</div><div class="app-text">Основной вариант для Android и Windows.</div></div>
          <button class="btn primary copy" data-copy="${safe_links_url}">Скопировать URL</button>
        </article>
        <article class="app-card featured">
          <div><div class="app-title">Hiddify</div><div class="app-text">Используй hiddify.txt или QR с обычным URL подписки.</div></div>
          <a class="btn gold" href="${safe_hiddify_open_url}">Открыть Hiddify</a>
        </article>
        <article class="app-card">
          <div><div class="app-title">iPhone</div><div class="app-text">Streisand или Karing для iOS.</div></div>
          <button class="btn copy" data-copy="${safe_streisand_sub_url}">Скопировать iOS</button>
        </article>
        <article class="app-card">
          <div><div class="app-title">NekoBox / v2rayNG</div><div class="app-text">Отдельные совместимые файлы для ручного импорта.</div></div>
          <button class="btn copy" data-copy="${safe_nekobox_url}">Скопировать NekoBox</button>
        </article>
      </div>
      <aside class="side">
        <h2>Приложения</h2>
        <p class="muted">Скачай клиент и добавь подписку с этой страницы.</p>
        <div class="file-row">
          <a class="btn primary" href="${safe_android_url}" target="_blank" rel="noopener noreferrer">Android</a>
          <a class="btn" href="${safe_windows_url}" target="_blank" rel="noopener noreferrer">Windows</a>
          <a class="btn" href="${safe_streisand_url}" target="_blank" rel="noopener noreferrer">Streisand iOS</a>
          <a class="btn" href="${safe_karing_url}" target="_blank" rel="noopener noreferrer">Karing iOS</a>
        </div>
      </aside>
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div><h2>Рекомендации по подключению</h2><div class="muted">Все активные серверы и протоколы. Если один профиль временно медленный, попробуй соседний.</div></div>
    </div>
    <div class="recommend-grid">
${recommendations_all_html}
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div><h2>QR-коды</h2><div class="muted">Сканируй внутри приложения. Для Hiddify лучше использовать QR hiddify.txt.</div></div>
    </div>
    <div class="qr-grid">
${qr_cards_html}
    </div>
  </section>

${pingtunnel_panel_html}

  <section class="section card project-help">
    <div class="help-layout">
      <div>
        <h2>Помощь проекту</h2>
        <p class="help-text">Собираем помощь для развития Yurich Connect и разработки приложений для Android и iPhone. Поддержка помогает быстрее выпускать обновления, улучшать стабильность серверов и делать подключение проще.</p>
      </div>
      <div class="help-actions">
        ${project_help_qr_html}
        <a class="btn primary" href="${safe_donation_url}" target="_blank" rel="noopener noreferrer">Поддержать проект</a>
      </div>
    </div>
  </section>

  <section class="section card notice">
    <h2>Уведомления о подписке</h2>
    <p class="muted">Чтобы получать напоминания об окончании подписки и новости, отправь разработчику свой Telegram ID.</p>
    <div class="steps">
      <div class="step"><b>1. Получи ID</b>Открой <a class="mini" href="${safe_tg_id_bot_url}" target="_blank" rel="noopener noreferrer">@getmyid_bot</a> и нажми Start.</div>
      <div class="step"><b>2. Отправь ID</b>Отправь цифры Telegram ID вместе с именем профиля: <code>${safe_user}</code>.</div>
      <div class="step"><b>3. Включи бота</b>Открой <a class="mini" href="${safe_tg_bot_url}" target="_blank" rel="noopener noreferrer">бота уведомлений</a> и нажми Start.</div>
    </div>
  </section>

  <details class="section card profiles-details">
    <summary>Отдельные профили для ручного копирования</summary>
    <div class="profile-list">
${profile_cards_html}
    </div>
  </details>
</main>
<script>
document.querySelectorAll('.copy').forEach(function(btn){
  var originalText = btn.textContent;
  btn.addEventListener('click', function(){
    var value = btn.getAttribute('data-copy') || '';
    function reset(text){btn.textContent=text;setTimeout(function(){btn.textContent=originalText},1600)}
    function fallback(){
      var ta=document.createElement('textarea');
      ta.value=value;ta.setAttribute('readonly','');ta.style.position='fixed';ta.style.left='-9999px';
      document.body.appendChild(ta);ta.select();
      try{document.execCommand('copy')?reset('Скопировано'):reset('Скопируй вручную')}catch(e){reset('Скопируй вручную')}
      document.body.removeChild(ta);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(value).then(function(){reset('Скопировано')}).catch(fallback);
    } else {
      fallback();
    }
  });
});
</script>
</body>
</html>
EOF
        chmod 644 "${page_dir}/index.html"
        printf '%s\n' "$sub_url"
        return 0
    fi

    if subscription_remnawave_preview_page_enabled "$user"; then
        cat > "${page_dir}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex,nofollow,noarchive">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests">
<title>${title}</title>
<style>
:root{--bg:#090d14;--bg2:#0d141d;--surface:#111923;--surface2:#151f2b;--surface3:#192634;--line:#243445;--line2:#31475d;--text:#f6fbff;--muted:#8fa2b6;--cyan:#19e6d0;--cyan2:#0fa9c0;--green:#66d58d;--gold:#e58a36;--red:#d85c5c;--blue:#5a8dff;--shadow:0 24px 70px rgba(0,0,0,.38)}
*{box-sizing:border-box;min-width:0}
html,body{margin:0;max-width:100%;overflow-x:hidden}
body{min-height:100vh;background:radial-gradient(circle at 20% 0%,rgba(25,230,208,.12),transparent 34%),radial-gradient(circle at 84% 16%,rgba(90,141,255,.10),transparent 30%),linear-gradient(180deg,#090d14 0%,#0b111a 48%,#080b11 100%);color:var(--text);font-family:Inter,Arial,sans-serif;font-size:16px;line-height:1.58;letter-spacing:0}
a{color:inherit}
.rw-page{width:min(1180px,100%);margin:0 auto;padding:22px 16px 56px;display:block}
.rw-main{display:flex;flex-direction:column;gap:14px}
.rw-header{display:flex;align-items:center;justify-content:space-between;gap:12px;border-bottom:1px solid rgba(255,255,255,.05);padding:4px 0 14px}
.rw-title{display:flex;align-items:center;gap:9px;color:var(--cyan);font-weight:950;font-size:17px}
.rw-title-mark{width:42px;height:42px;border-radius:12px;background:linear-gradient(135deg,rgba(25,230,208,.12),rgba(90,141,255,.16));border:1px solid rgba(25,230,208,.24);box-shadow:0 0 18px rgba(25,230,208,.16);display:grid;place-items:center;overflow:hidden;flex:0 0 auto}
.rw-title-mark img{display:block;width:100%;height:100%;object-fit:contain;padding:3px}
.rw-title-mark span{font-size:12px;font-weight:950;color:var(--cyan)}
.rw-actions{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end}
.icon-btn{display:inline-flex;align-items:center;justify-content:center;min-width:38px;min-height:36px;border:1px solid rgba(255,255,255,.10);border-radius:8px;background:#111a24;color:#dffbff;font-size:13px;font-weight:950;text-decoration:none;cursor:pointer}
.icon-btn:hover{border-color:rgba(25,230,208,.62);background:#172332}
.panel{border:1px solid rgba(255,255,255,.08);border-radius:8px;background:linear-gradient(180deg,rgba(17,25,35,.94),rgba(10,15,22,.96));box-shadow:0 18px 46px rgba(0,0,0,.24)}
.account{padding:18px}
.account-head{display:flex;justify-content:space-between;gap:14px;align-items:flex-start;margin-bottom:13px}
.account-name{display:flex;align-items:center;gap:10px}
.account-logo{width:54px;height:54px;border-radius:14px;display:grid;place-items:center;background:linear-gradient(135deg,rgba(25,230,208,.10),rgba(90,141,255,.12));border:1px solid rgba(25,230,208,.28);color:var(--gold);font-weight:950;overflow:hidden;flex:0 0 auto}
.account-logo img{display:block;width:100%;height:100%;object-fit:contain;padding:4px}
.account-logo span{font-size:13px;font-weight:950;color:var(--cyan)}
.account-name b{display:block;font-size:18px}
.account-name span{display:block;color:var(--gold);font-size:13px;font-weight:900}
.status-pill{display:inline-flex;align-items:center;gap:7px;border:1px solid rgba(102,213,141,.28);background:rgba(102,213,141,.12);color:#ceffd9;border-radius:999px;padding:7px 10px;font-size:13px;font-weight:950}
.status-dot{width:7px;height:7px;border-radius:50%;background:var(--green);box-shadow:0 0 16px rgba(102,213,141,.72)}
.account-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px}
.account-cell{border:1px solid rgba(255,255,255,.07);border-radius:8px;padding:11px 12px;background:#131e29;min-height:70px}
.account-cell:nth-child(1){background:linear-gradient(135deg,rgba(90,141,255,.14),rgba(19,30,41,.96))}
.account-cell:nth-child(2){background:linear-gradient(135deg,rgba(102,213,141,.14),rgba(19,30,41,.96))}
.account-cell:nth-child(3){background:linear-gradient(135deg,rgba(216,92,92,.15),rgba(19,30,41,.96))}
.account-cell:nth-child(4){background:linear-gradient(135deg,rgba(229,138,54,.15),rgba(19,30,41,.96))}
.cell-label{display:block;color:#9fb1c5;font-size:11px;font-weight:950;text-transform:uppercase;letter-spacing:.05em}
.cell-value{display:block;color:#fff;font-size:16px;font-weight:950;margin-top:5px;overflow-wrap:anywhere}
.cell-note{display:block;color:var(--muted);font-size:12px;margin-top:2px}
.traffic-meter{margin-top:12px;display:grid;grid-template-columns:minmax(0,1fr) 260px;gap:14px;align-items:stretch;border:1px solid rgba(25,230,208,.18);border-radius:8px;background:linear-gradient(135deg,rgba(25,230,208,.10),rgba(90,141,255,.08) 45%,rgba(229,138,54,.10));padding:16px;overflow:hidden}
.traffic-title{color:#bdf9f2;font-size:13px;font-weight:950;text-transform:uppercase;letter-spacing:.08em}
.traffic-value{font-size:58px;line-height:1;font-weight:950;color:#fff;text-shadow:0 0 32px rgba(25,230,208,.22);margin:8px 0}
.traffic-note{color:#b8c8d9;font-size:14px;max-width:720px}
.traffic-visual{display:flex;flex-direction:column;justify-content:center;gap:10px}
.traffic-ring{height:86px;border-radius:8px;background:conic-gradient(from 210deg,var(--cyan),var(--blue),var(--gold),var(--cyan));padding:1px;box-shadow:0 0 40px rgba(25,230,208,.10)}
.traffic-ring-inner{height:100%;border-radius:7px;background:linear-gradient(180deg,#101923,#0b1119);display:grid;place-items:center;color:#dffefa;font-weight:950}
.traffic-bar{height:10px;border-radius:999px;background:#0c1520;border:1px solid rgba(255,255,255,.08);overflow:hidden}
.traffic-bar span{display:block;width:68%;height:100%;border-radius:999px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold));box-shadow:0 0 22px rgba(25,230,208,.36)}
.install{padding:18px}
.section-head{display:flex;justify-content:space-between;gap:12px;align-items:flex-start;margin-bottom:13px}
.section-head h2{font-size:20px;line-height:1.15;margin:0}
.muted{color:var(--muted)}
.tabs{display:flex;gap:8px;flex-wrap:wrap}
.tab{border:1px solid rgba(255,255,255,.10);border-radius:8px;background:#121d29;color:#d7eaff;font-size:13px;font-weight:950;padding:8px 11px;text-decoration:none}
.tab.active{border-color:rgba(25,230,208,.54);background:rgba(25,230,208,.12);color:#dffdfa}
.platform{border:1px solid rgba(255,255,255,.10);border-radius:8px;background:#121d29;padding:8px 11px;color:#dcecff;font-size:13px;font-weight:950}
.install-flow{display:grid;gap:10px}
.flow-card{display:grid;grid-template-columns:42px minmax(0,1fr) auto;gap:12px;align-items:center;border:1px solid rgba(255,255,255,.08);border-radius:8px;background:#101923;padding:13px}
.flow-icon{width:40px;height:40px;border-radius:11px;background:rgba(25,230,208,.12);display:grid;place-items:center;color:var(--cyan);font-size:18px;font-weight:950;flex:0 0 auto}
.flow-icon svg{width:21px;height:21px;stroke:currentColor;stroke-width:2.4;fill:none;stroke-linecap:round;stroke-linejoin:round}
.flow-title{font-size:16px;font-weight:950}
.flow-text{color:var(--muted);font-size:13px;margin-top:3px}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:40px;padding:10px 14px;border-radius:8px;border:1px solid rgba(255,255,255,.12);background:#132033;color:#f7fbff;font-size:14px;font-weight:950;text-decoration:none;cursor:pointer;white-space:nowrap}
.btn:hover{border-color:rgba(25,230,208,.62);background:#17283c}
.btn.primary{background:linear-gradient(135deg,#18ded0,#48b6ff);border-color:rgba(25,230,208,.72);color:#031014}
.btn.gold{background:linear-gradient(135deg,#ffc65b,#ff9b4d);border-color:rgba(229,138,54,.72);color:#160c04}
.file-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(118px,1fr));gap:8px;width:100%;justify-self:stretch}
.section{display:flex;flex-direction:column;gap:12px}
.recommend-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
.recommend-card{display:flex;flex-direction:column;justify-content:space-between;gap:12px;border:1px solid rgba(255,255,255,.08);border-radius:8px;background:linear-gradient(180deg,rgba(17,27,38,.94),rgba(10,15,22,.96));padding:14px;min-height:132px}
.recommend-title{color:var(--gold);font-size:12px;text-transform:uppercase;letter-spacing:.05em;font-weight:950;margin-bottom:7px}
.recommend-name{font-size:16px;line-height:1.34;font-weight:950;overflow-wrap:anywhere}
.recommend-meta{color:var(--muted);font-size:13px;margin-top:7px;overflow-wrap:anywhere}
.recommend-copy{width:100%;min-height:36px}
.qr-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.qr-item{border:1px solid rgba(255,255,255,.08);border-radius:8px;background:linear-gradient(180deg,rgba(17,27,38,.94),rgba(10,15,22,.96));padding:12px;text-align:center}
.qr-glow{height:3px;margin:-12px -12px 12px;border-radius:8px 8px 0 0;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold))}
.qr-item img{display:block;width:100%;max-width:142px;aspect-ratio:1/1;margin:0 auto 9px;background:#fff;border-radius:8px;padding:7px}
.qr-title{font-size:15px;font-weight:950;overflow-wrap:anywhere}
.qr-hint{color:var(--muted);font-size:13px;min-height:48px;margin:5px 0 9px}
.qr-copy{width:100%}
.project-help{position:relative;overflow:hidden;padding:18px;border-color:rgba(25,230,208,.30);background:linear-gradient(135deg,rgba(25,230,208,.10),rgba(90,141,255,.08) 52%,rgba(229,138,54,.10)),rgba(17,25,35,.94)}
.project-help:before{content:"";position:absolute;left:0;right:0;top:0;height:3px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold))}
.help-layout{display:grid;grid-template-columns:50px minmax(0,1fr) auto;gap:14px;align-items:center}
.help-icon{width:48px;height:48px;border-radius:14px;background:rgba(25,230,208,.13);border:1px solid rgba(25,230,208,.28);display:grid;place-items:center;color:var(--cyan);box-shadow:0 0 28px rgba(25,230,208,.10)}
.help-icon svg{width:25px;height:25px;stroke:currentColor;stroke-width:2.2;fill:none;stroke-linecap:round;stroke-linejoin:round}
.project-help h2{font-size:21px;line-height:1.15;margin:0 0 6px}
.help-text{margin:0;color:#c6d4e3;font-size:15px;line-height:1.62;max-width:760px}
.help-actions{display:flex;align-items:center;gap:10px;flex-wrap:wrap;justify-content:flex-end}
.help-qr-card{display:flex;flex-direction:column;align-items:center;gap:6px;min-width:142px;color:#c6d4e3;font-size:12px;font-weight:900;text-align:center}
.help-qr{display:block;width:150px;max-width:100%;height:auto;background:#fff;border-radius:8px;padding:5px;border:1px solid rgba(255,255,255,.16);box-shadow:0 16px 36px rgba(0,0,0,.22)}
.notice{padding:16px;border-color:rgba(229,138,54,.30);background:linear-gradient(135deg,rgba(229,138,54,.10),rgba(25,230,208,.06)),rgba(17,25,35,.94)}
.steps{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:10px}
.step{border:1px solid rgba(255,255,255,.08);border-radius:8px;background:#101923;padding:12px}
.step b{display:block;color:#ffd38a;margin-bottom:4px}
.mini{display:inline-block;margin-top:5px;color:var(--cyan);font-weight:900;text-decoration:none}
code{color:#dffbff}
.empty-state{border:1px dashed rgba(255,255,255,.16);border-radius:8px;padding:14px;color:var(--muted)}
@media(max-width:1040px){.account-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.traffic-meter{grid-template-columns:1fr}.recommend-grid,.qr-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media(max-width:680px){body{font-size:15px}.rw-page{width:100%;max-width:100%;padding:12px 10px 34px;overflow:hidden}.rw-main{gap:12px}.rw-header{align-items:flex-start;flex-direction:column}.rw-actions{width:100%;display:grid;grid-template-columns:1fr 1fr}.icon-btn{width:100%;min-height:38px}.panel,.recommend-card,.qr-item,.step{width:100%;max-width:100%;overflow:hidden}.account,.install,.notice,.project-help{padding:14px}.account-head{display:grid;grid-template-columns:minmax(0,1fr) auto;align-items:center;gap:10px}.account-name{align-items:center}.account-logo{width:58px;height:58px}.status-pill{margin-top:0;justify-self:end}.account-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.account-cell{min-height:112px;padding:13px 12px}.cell-label{font-size:10px}.cell-value{font-size:18px}.cell-note{font-size:12px;line-height:1.35}.recommend-grid,.qr-grid,.steps{grid-template-columns:1fr}.traffic-meter{grid-template-columns:1fr;padding:14px}.traffic-value{font-size:42px}.traffic-visual{display:none}.section-head{display:block}.section-head h2{font-size:22px}.tabs{display:grid;grid-template-columns:1fr 1fr}.tab,.platform{width:100%;text-align:center}.flow-card{grid-template-columns:40px minmax(0,1fr);align-items:flex-start;padding:12px}.flow-card .btn{grid-column:1 / -1;width:100%}.btn{width:100%;white-space:normal}.file-row{grid-column:1 / -1;display:grid;grid-template-columns:1fr}.recommend-card{min-height:auto}.qr-hint{min-height:auto}.help-layout{grid-template-columns:46px minmax(0,1fr);align-items:flex-start}.help-icon{width:44px;height:44px}.help-actions{grid-column:1 / -1;display:grid;grid-template-columns:1fr;justify-content:stretch}.help-qr-card{justify-self:center;width:100%;max-width:240px}.help-qr{width:min(220px,100%)}.help-text{font-size:14px}}
@media(max-width:360px){.account-head{grid-template-columns:1fr}.status-pill{justify-self:start}.account-grid{grid-template-columns:1fr}}
</style>
</head>
<body>
<main class="rw-page">
  <section class="rw-main">
    <header class="rw-header">
      <div class="rw-title"><span class="rw-title-mark">${subscription_header_logo_html}</span><span>Подписка</span></div>
      <div class="rw-actions">
        <button class="icon-btn copy" data-copy="${safe_links_url}" title="Скопировать ссылку подписки">Ссылка</button>
        <a class="icon-btn" href="${safe_telegram_url}" target="_blank" rel="noopener noreferrer" title="Telegram">TG</a>
      </div>
    </header>

    <section class="panel account">
      <div class="account-head">
        <div class="account-name">
          <div class="account-logo">${subscription_logo_html}</div>
          <div><b>Yurich Connect</b><span>Осталось ${safe_days_left} дней</span></div>
        </div>
        <div class="status-pill"><span class="status-dot"></span>Активна</div>
      </div>
      <div class="account-grid">
        <div class="account-cell"><span class="cell-label">Пользователь</span><span class="cell-value">${safe_user}</span><span class="cell-note">${safe_domain}</span></div>
        <div class="account-cell"><span class="cell-label">Статус</span><span class="cell-value">Активна</span><span class="cell-note">Подписка включена</span></div>
        <div class="account-cell"><span class="cell-label">Срок</span><span class="cell-value">${safe_expiry_label}</span><span class="cell-note">Осталось ${safe_days_left} дней</span></div>
        <div class="account-cell"><span class="cell-label">Подключения</span><span class="cell-value">${profile_count}</span><span class="cell-note">Доступные локации и протоколы</span></div>
      </div>
      <div class="traffic-meter">
        <div>
          <div class="traffic-title">Персональный счетчик трафика</div>
          <div class="traffic-value">${safe_hiddify_used_human}</div>
          <div class="traffic-note">${safe_traffic_summary}</div>
        </div>
        <div class="traffic-visual">
          <div class="traffic-ring"><div class="traffic-ring-inner">Naive HTTPS</div></div>
          <div class="traffic-bar"><span></span></div>
        </div>
      </div>
    </section>

    <section class="panel install">
      <div class="section-head">
        <div>
          <h2>Установка</h2>
          <div class="muted">Установи приложение и добавь подписку одной кнопкой.</div>
        </div>
        <div class="platform">Android / iOS / Windows</div>
      </div>
      <div class="tabs">
        <a class="tab active" href="${safe_hiddify_open_url}">Hiddify</a>
        <button class="tab copy" data-copy="${safe_streisand_sub_url}">Streisand</button>
        <button class="tab copy" data-copy="${safe_nekobox_url}">NekoBox</button>
        <button class="tab copy" data-copy="${safe_v2rayng_url}">v2rayNG</button>
      </div>
      <div class="install-flow">
        <article class="flow-card">
          <div class="flow-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 3v12"></path><path d="m7 10 5 5 5-5"></path><path d="M5 21h14"></path></svg></div>
          <div><div class="flow-title">Установи приложение</div><div class="flow-text">Скачай приложение для Android или Windows. Для iPhone используй Streisand или Karing.</div></div>
          <div class="file-row">
            <a class="btn primary" href="${safe_android_url}" target="_blank" rel="noopener noreferrer">Android</a>
            <a class="btn" href="${safe_windows_url}" target="_blank" rel="noopener noreferrer">Windows</a>
            <a class="btn" href="${safe_streisand_url}" target="_blank" rel="noopener noreferrer">Streisand iOS</a>
            <a class="btn" href="${safe_karing_url}" target="_blank" rel="noopener noreferrer">Karing iOS</a>
          </div>
        </article>
        <article class="flow-card">
          <div class="flow-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 5v14"></path><path d="M5 12h14"></path></svg></div>
          <div><div class="flow-title">Добавь подписку</div><div class="flow-text">Основная ссылка подходит для Yurich Connect, Hiddify, NekoBox, v2rayNG и совместимых клиентов.</div></div>
          <button class="btn gold copy" data-copy="${safe_links_url}">Скопировать URL</button>
        </article>
        <article class="flow-card">
          <div class="flow-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 4h6v6H4z"></path><path d="M14 4h6v6h-6z"></path><path d="M4 14h6v6H4z"></path><path d="M14 14h2"></path><path d="M20 14v2"></path><path d="M14 20h2"></path><path d="M18 18h2"></path><path d="M18 20v-4"></path></svg></div>
          <div><div class="flow-title">Импорт по QR</div><div class="flow-text">Для Hiddify сканируй QR с обычным URL подписки, чтобы не создавался пустой профиль.</div></div>
          <a class="btn" href="${safe_hiddify_url}">hiddify.txt</a>
        </article>
      </div>
    </section>

    <section class="section">
      <div class="section-head">
        <div><h2>Рекомендации</h2><div class="muted">Все доступные подключения по активным локациям. Начинай с Turbo для скорости, HTTPS для совместимости, Reality для стабильного TCP-подключения.</div></div>
      </div>
      <div class="recommend-grid">
${recommendations_all_html}
      </div>
    </section>

    <section class="section">
      <div class="section-head">
        <div><h2>QR-коды</h2><div class="muted">Отдельные QR для разных приложений и сценариев импорта.</div></div>
      </div>
      <div class="qr-grid">
${qr_cards_html}
      </div>
    </section>

${pingtunnel_panel_html}

    <section class="panel project-help">
      <div class="help-layout">
        <div class="help-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 21s-7-4.35-9.2-8.1C1.1 10 2 6.5 5.1 5.4c1.9-.7 3.8.1 4.9 1.5 1.1-1.4 3-2.2 4.9-1.5C18 6.5 18.9 10 17.2 12.9 15 16.65 12 21 12 21Z"></path><path d="M12 8v5"></path><path d="M9.5 10.5h5"></path></svg></div>
        <div>
          <h2>Помощь проекту</h2>
          <p class="help-text">Собираем помощь для развития проекта Yurich Connect и разработки приложений для Android и iPhone. Каждый вклад помогает быстрее выпускать обновления, улучшать стабильность подключений и делать приложение удобнее.</p>
        </div>
        <div class="help-actions">
          ${project_help_qr_html}
          <a class="btn primary" href="${safe_donation_url}" target="_blank" rel="noopener noreferrer">Поддержать проект</a>
        </div>
      </div>
    </section>

    <section class="panel notice">
      <h2>Telegram-уведомления</h2>
      <div class="muted">Чтобы получать напоминания об окончании подписки и важные новости, отправь разработчику свой Telegram ID.</div>
      <div class="steps">
        <div class="step"><b>1. Получи ID</b>Открой <a class="mini" href="${safe_tg_id_bot_url}" target="_blank" rel="noopener noreferrer">@getmyid_bot</a> и нажми Start.</div>
        <div class="step"><b>2. Отправь ID</b>Отправь цифры Telegram ID вместе с именем профиля: <code>${safe_user}</code>.</div>
        <div class="step"><b>3. Включи бота</b>Открой <a class="mini" href="${safe_tg_bot_url}" target="_blank" rel="noopener noreferrer">бота уведомлений</a> и нажми Start.</div>
      </div>
    </section>

  </section>
</main>
<script>
document.querySelectorAll('.copy').forEach(function(btn){
  var originalText = btn.textContent;
  btn.addEventListener('click', function(){
    var value = btn.getAttribute('data-copy') || '';
    function reset(text){btn.textContent=text;setTimeout(function(){btn.textContent=originalText},1600)}
    function fallback(){
      var ta=document.createElement('textarea');
      ta.value=value;ta.setAttribute('readonly','');ta.style.position='fixed';ta.style.left='-9999px';
      document.body.appendChild(ta);ta.select();
      try{document.execCommand('copy')?reset('Скопировано'):reset('Скопируй вручную')}catch(e){reset('Скопируй вручную')}
      document.body.removeChild(ta);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(value).then(function(){reset('Скопировано')}).catch(fallback);
    } else {
      fallback();
    }
  });
});
</script>
</body>
</html>
EOF
        chmod 644 "${page_dir}/index.html"
        printf '%s\n' "$sub_url"
        return 0
    fi

    if subscription_remnawave_page_enabled "$user"; then
        cat > "${page_dir}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex,nofollow,noarchive">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests">
<title>${title}</title>
<style>
:root{--bg:#05070b;--panel:#0d131b;--panel2:#111a24;--soft:#172332;--line:#273546;--text:#f7fbff;--muted:#98a7b8;--cyan:#2de8c8;--blue:#69a7ff;--gold:#ffd166;--green:#77f29b;--red:#ff6f91;--shadow:0 24px 70px rgba(0,0,0,.42)}
*{box-sizing:border-box;min-width:0}
html,body{margin:0;max-width:100%;overflow-x:hidden}
body{min-height:100vh;background:radial-gradient(circle at 50% -20%,rgba(45,232,200,.13),transparent 34%),linear-gradient(180deg,#05070b 0%,#08111a 52%,#05070b 100%);color:var(--text);font-family:Inter,Arial,sans-serif;line-height:1.55;letter-spacing:0}
a{color:inherit}
.page{width:min(1120px,100%);margin:0 auto;padding:22px 16px 56px}
.topbar{display:flex;justify-content:space-between;gap:12px;align-items:center;margin-bottom:16px}
.brand{display:flex;align-items:center;gap:10px;font-weight:950}
.brand-mark{display:grid;place-items:center;width:36px;height:36px;border-radius:8px;background:linear-gradient(135deg,var(--cyan),var(--blue));color:#041014;font-weight:950}
.brand-text{display:flex;flex-direction:column;line-height:1.1}
.brand-text small{color:var(--muted);font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em}
.top-actions{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:40px;padding:9px 13px;border-radius:8px;border:1px solid rgba(255,255,255,.12);background:#101b28;color:var(--text);font-weight:900;font-size:13px;text-decoration:none;cursor:pointer}
.btn:hover{border-color:rgba(45,232,200,.66);background:#162538}
.btn.primary{background:linear-gradient(135deg,var(--cyan),var(--blue));border-color:rgba(45,232,200,.72);color:#031014}
.btn.gold{background:linear-gradient(135deg,var(--gold),#ff9f68);border-color:rgba(255,209,102,.72);color:#170d04}
.hero{position:relative;overflow:hidden;border:1px solid rgba(255,255,255,.10);border-radius:8px;background:linear-gradient(135deg,rgba(13,19,27,.96),rgba(13,31,37,.96) 58%,rgba(21,20,31,.96));box-shadow:var(--shadow);padding:24px}
.hero:before{content:"";position:absolute;left:0;right:0;top:0;height:4px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold),var(--red))}
.hero-grid{display:grid;grid-template-columns:minmax(0,1fr) 320px;gap:18px;align-items:stretch}
.eyebrow{color:var(--cyan);font-size:12px;font-weight:950;text-transform:uppercase;letter-spacing:.1em}
h1{font-size:42px;line-height:1.05;margin:8px 0 12px;letter-spacing:0}
.lead{max-width:720px;color:#c1ccd8;font-size:16px;margin:0}
.chips{display:flex;gap:8px;flex-wrap:wrap;margin-top:18px}
.chip{display:inline-flex;align-items:center;gap:7px;padding:7px 10px;border-radius:8px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);font-size:13px;font-weight:900}
.chip:nth-child(1){border-color:rgba(45,232,200,.35);background:rgba(45,232,200,.09)}
.chip:nth-child(2){border-color:rgba(255,209,102,.35);background:rgba(255,209,102,.09)}
.chip:nth-child(3){border-color:rgba(105,167,255,.35);background:rgba(105,167,255,.09)}
.account-card{background:rgba(5,7,11,.68);border:1px solid rgba(255,255,255,.11);border-radius:8px;padding:14px}
.account-row{display:grid;grid-template-columns:95px minmax(0,1fr);gap:12px;padding:9px 0;border-bottom:1px solid rgba(255,255,255,.08)}
.account-row:last-child{border-bottom:0}
.account-row span{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.05em;font-weight:900}
.account-row b{overflow-wrap:anywhere;text-align:right}
.grid{display:grid;gap:14px}
.metrics{grid-template-columns:repeat(3,minmax(0,1fr));margin-top:14px}
.card{background:linear-gradient(180deg,rgba(17,26,36,.94),rgba(8,12,18,.96));border:1px solid rgba(255,255,255,.10);border-radius:8px;box-shadow:0 16px 44px rgba(0,0,0,.22)}
.metric{padding:16px;min-height:126px;display:flex;flex-direction:column;justify-content:space-between}
.metric small{color:var(--muted);font-size:11px;font-weight:950;text-transform:uppercase;letter-spacing:.08em}
.metric strong{font-size:31px;line-height:1.05;overflow-wrap:anywhere}
.metric p{margin:7px 0 0;color:var(--muted);font-size:12px}
.section{margin-top:16px}
.section-head{display:flex;justify-content:space-between;gap:14px;align-items:flex-end;margin-bottom:10px}
.section h2{font-size:20px;margin:0}
.muted{color:var(--muted)}
.install{padding:16px}
.install-grid{display:grid;grid-template-columns:minmax(0,1fr) 300px;gap:14px}
.app-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.app-card{display:flex;flex-direction:column;justify-content:space-between;gap:14px;min-height:142px;padding:14px;border-radius:8px;border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.035)}
.app-card.featured{border-color:rgba(45,232,200,.42);background:linear-gradient(180deg,rgba(17,49,47,.58),rgba(255,255,255,.035))}
.app-title{font-weight:950;font-size:16px}
.app-text{color:var(--muted);font-size:13px;margin-top:5px}
.side-panel{padding:14px;border-radius:8px;background:rgba(5,7,11,.55);border:1px solid rgba(255,255,255,.10)}
.side-panel h3{margin:0 0 9px;font-size:15px}
.file-row{display:flex;flex-wrap:wrap;gap:8px;margin-top:10px}
.file-row .btn{min-height:34px;padding:7px 10px}
.recommend-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.recommend-card{min-height:104px;padding:13px;border-radius:8px;background:linear-gradient(180deg,rgba(18,28,38,.96),rgba(9,14,20,.96));border:1px solid rgba(255,255,255,.10)}
.recommend-title{color:var(--gold);font-size:12px;text-transform:uppercase;letter-spacing:.05em;font-weight:950;margin-bottom:7px}
.recommend-name{font-weight:950;overflow-wrap:anywhere}
.recommend-meta{color:var(--muted);font-size:12px;margin-top:7px}
.qr-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:10px}
.qr-item{padding:12px;text-align:center;border-radius:8px;background:linear-gradient(180deg,rgba(15,24,34,.96),rgba(8,12,18,.96));border:1px solid rgba(255,255,255,.10)}
.qr-item:nth-child(2){border-color:rgba(45,232,200,.44)}
.qr-glow{height:3px;margin:-12px -12px 12px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold))}
.qr-item img{display:block;width:100%;max-width:150px;aspect-ratio:1/1;margin:0 auto 10px;background:#fff;border-radius:8px;padding:7px}
.qr-title{font-weight:950;font-size:14px;overflow-wrap:anywhere}
.qr-hint{color:var(--muted);font-size:12px;min-height:52px;margin:5px 0 10px}
.qr-copy{width:100%;margin:0}
.profile-list{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.profile-card{padding:13px;border-radius:8px;background:linear-gradient(180deg,rgba(15,24,34,.96),rgba(8,12,18,.96));border:1px solid rgba(255,255,255,.10)}
.profile-top{display:flex;justify-content:space-between;gap:10px;align-items:center;margin-bottom:8px}
.profile-type{color:var(--cyan);font-size:11px;font-weight:950;text-transform:uppercase;letter-spacing:.04em}
.profile-host{max-width:150px;color:var(--muted);font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.profile-name{font-size:15px;font-weight:950;margin-bottom:10px;overflow-wrap:anywhere}
.profile-copy{width:100%;margin:0}
.notice{padding:16px;border-color:rgba(255,209,102,.24);background:linear-gradient(180deg,rgba(30,26,18,.88),rgba(11,15,20,.94))}
.steps{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin:12px 0}
.step{padding:12px;border-radius:8px;background:rgba(5,8,13,.58);border:1px solid rgba(255,255,255,.10)}
.step b{display:block;color:var(--gold);margin-bottom:4px}
.mini{display:inline-block;margin-top:5px;color:var(--cyan);font-weight:900;text-decoration:none}
code{color:#d9fbff}
.empty-state{border:1px dashed rgba(255,255,255,.16);border-radius:8px;padding:14px;color:var(--muted)}
@media(max-width:980px){.hero-grid,.install-grid,.metrics,.recommend-grid{grid-template-columns:1fr}.app-grid,.qr-grid,.profile-list,.steps{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media(max-width:680px){.page{padding:12px 10px 34px}.topbar{flex-direction:column;align-items:stretch}.top-actions{width:100%;display:grid;grid-template-columns:1fr;justify-content:stretch}.top-actions .btn{width:100%}.hero{padding:17px}.hero-grid{grid-template-columns:1fr}h1{font-size:30px}.chips{display:grid;grid-template-columns:1fr}.account-row{grid-template-columns:1fr;gap:4px}.account-row b{text-align:left}.section-head{display:block}.app-grid,.qr-grid,.profile-list,.steps{grid-template-columns:1fr}.btn{width:100%;margin-right:0}.qr-hint{min-height:auto}}
</style>
</head>
<body>
<main class="page">
  <div class="topbar">
    <div class="brand">
      <div class="brand-mark">Y</div>
      <div class="brand-text"><b>Yurich Connect</b><small>Subscription</small></div>
    </div>
    <div class="top-actions">
      <button class="btn copy" data-copy="${safe_links_url}">Скопировать URL</button>
      <a class="btn" href="${safe_android_url}" target="_blank" rel="noopener noreferrer">Android</a>
      <a class="btn" href="${safe_windows_url}" target="_blank" rel="noopener noreferrer">Windows</a>
    </div>
  </div>

  <section class="hero">
    <div class="hero-grid">
      <div>
        <div class="eyebrow">Private access</div>
        <h1>Подписка ${safe_user}</h1>
        <p class="lead">Единая страница для установки приложения, импорта подписки и копирования отдельных профилей. Ссылка скрыта от индексации, но доступна всем, у кого есть этот URL.</p>
        <div class="chips">
          <span class="chip">HTTPS</span>
          <span class="chip">Turbo</span>
          <span class="chip">Reality</span>
          <span class="chip">${safe_active_locations}</span>
        </div>
      </div>
      <aside class="account-card">
        <div class="account-row"><span>Пользователь</span><b>${safe_user}</b></div>
        <div class="account-row"><span>Статус</span><b>Активна</b></div>
        <div class="account-row"><span>Срок</span><b>${safe_expiry_label}</b></div>
        <div class="account-row"><span>Осталось</span><b>${safe_days_left} дней</b></div>
        <div class="account-row"><span>Профилей</span><b>${profile_count}</b></div>
      </aside>
    </div>
  </section>

  <section class="grid metrics">
    <div class="card metric"><small>Трафик</small><strong>${safe_hiddify_used_human}</strong><p>${safe_traffic_summary}</p></div>
    <div class="card metric"><small>Локации</small><strong>${profile_count}</strong><p>Активные профили по доступным серверам.</p></div>
    <div class="card metric"><small>Обновлено</small><strong>$(date '+%H:%M')</strong><p>$(date '+%Y-%m-%d') по времени сервера.</p></div>
  </section>

  <section class="section card install">
    <div class="section-head">
      <div>
        <h2>Installation</h2>
        <div class="muted">Выбери клиент и добавь подписку одной кнопкой.</div>
      </div>
    </div>
    <div class="install-grid">
      <div class="app-grid">
        <article class="app-card featured">
          <div><div class="app-title">Yurich Connect</div><div class="app-text">Основная подписка для Android, Windows и совместимых клиентов.</div></div>
          <button class="btn primary copy" data-copy="${safe_links_url}">Добавить подписку</button>
        </article>
        <article class="app-card featured">
          <div><div class="app-title">Hiddify</div><div class="app-text">Обычный URL подписки и deeplink для быстрого импорта.</div></div>
          <a class="btn gold" href="${safe_hiddify_open_url}">Открыть Hiddify</a>
        </article>
        <article class="app-card">
          <div><div class="app-title">Streisand iOS</div><div class="app-text">Подписка для iPhone и iPad.</div></div>
          <button class="btn copy" data-copy="${safe_streisand_sub_url}">Скопировать iOS</button>
        </article>
        <article class="app-card">
          <div><div class="app-title">NekoBox</div><div class="app-text">Отдельная совместимая подписка.</div></div>
          <button class="btn copy" data-copy="${safe_nekobox_url}">Скопировать NekoBox</button>
        </article>
        <article class="app-card">
          <div><div class="app-title">v2rayNG</div><div class="app-text">Только VLESS Reality через TCP/${reality_public_port}.</div></div>
          <button class="btn copy" data-copy="${safe_v2rayng_url}">Скопировать v2rayNG</button>
        </article>
      </div>
      <aside class="side-panel">
        <h3>Файлы подписки</h3>
        <div class="muted">Для ручного импорта и диагностики.</div>
        <div class="file-row">
          <a class="btn" href="${safe_links_url}">links.txt</a>
          <a class="btn" href="${safe_hiddify_url}">hiddify.txt</a>
          <a class="btn" href="${safe_streisand_sub_url}">streisand.txt</a>
          <a class="btn" href="${safe_nekobox_url}">nekobox.txt</a>
          <a class="btn" href="${safe_v2rayng_url}">v2rayng.txt</a>
        </div>
      </aside>
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div><h2>Рекомендации</h2><div class="muted">Что лучше пробовать первым на текущих серверах.</div></div>
    </div>
    <div class="recommend-grid">
${recommendations_html}
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div><h2>QR-коды</h2><div class="muted">Сканируй QR внутри клиента или копируй ссылку.</div></div>
    </div>
    <div class="qr-grid">
${qr_cards_html}
    </div>
  </section>

${pingtunnel_panel_html}

  <section class="section card notice">
    <h2>Telegram-уведомления</h2>
    <p class="muted">Чтобы получать напоминания об окончании подписки и важные новости, отправь разработчику свой Telegram ID.</p>
    <div class="steps">
      <div class="step"><b>1. Получи ID</b>Открой <a class="mini" href="${safe_tg_id_bot_url}" target="_blank" rel="noopener noreferrer">@getmyid_bot</a> и нажми Start.</div>
      <div class="step"><b>2. Отправь ID</b>Отправь цифры Telegram ID вместе с именем профиля: <code>${safe_user}</code>.</div>
      <div class="step"><b>3. Включи бота</b>Открой <a class="mini" href="${safe_tg_bot_url}" target="_blank" rel="noopener noreferrer">бота уведомлений</a> и нажми Start.</div>
    </div>
    <a class="btn" href="${safe_tg_id_bot_url}" target="_blank" rel="noopener noreferrer">Получить Telegram ID</a>
    <a class="btn" href="${safe_tg_bot_url}" target="_blank" rel="noopener noreferrer">Открыть бота уведомлений</a>
  </section>

  <section class="section">
    <div class="section-head">
      <div><h2>Активные профили</h2><div class="muted">Каждый профиль можно скопировать отдельно.</div></div>
    </div>
    <div class="profile-list">
${profile_cards_html}
    </div>
  </section>
</main>
<script>
document.querySelectorAll('.copy').forEach(function(btn){
  var originalText = btn.textContent;
  btn.addEventListener('click', function(){
    var value = btn.getAttribute('data-copy') || '';
    function reset(text){btn.textContent=text;setTimeout(function(){btn.textContent=originalText},1600)}
    function fallback(){
      var ta=document.createElement('textarea');
      ta.value=value;ta.setAttribute('readonly','');ta.style.position='fixed';ta.style.left='-9999px';
      document.body.appendChild(ta);ta.select();
      try{document.execCommand('copy')?reset('Скопировано'):reset('Скопируй вручную')}catch(e){reset('Скопируй вручную')}
      document.body.removeChild(ta);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(value).then(function(){reset('Скопировано')}).catch(fallback);
    } else {
      fallback();
    }
  });
});
</script>
</body>
</html>
EOF
        chmod 644 "${page_dir}/index.html"
        printf '%s\n' "$sub_url"
        return 0
    fi

    cat > "${page_dir}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex,nofollow,noarchive">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests">
<title>${title}</title>
<style>
:root{--bg:#070b12;--panel:#0f1724;--panel2:#141f31;--panel3:#19283d;--line:#2b3a52;--text:#f4f8ff;--muted:#a6b5c8;--cyan:#3ee7d1;--blue:#65a8ff;--green:#6ee787;--gold:#ffd166;--rose:#ff6b9a;--shadow:0 22px 60px rgba(0,0,0,.34)}
*{box-sizing:border-box}
body{margin:0;min-height:100vh;background:linear-gradient(145deg,#070b12 0%,#0b1422 42%,#10141c 100%);color:var(--text);font-family:Inter,Arial,sans-serif;line-height:1.55}
body:before{content:"";position:fixed;inset:0;pointer-events:none;opacity:.22;background:linear-gradient(90deg,rgba(62,231,209,.12) 1px,transparent 1px),linear-gradient(0deg,rgba(101,168,255,.10) 1px,transparent 1px);background-size:44px 44px;mask-image:linear-gradient(to bottom,#000,transparent 82%)}
.wrap{max-width:1180px;margin:0 auto;padding:26px 18px 52px;position:relative}
.hero{position:relative;overflow:hidden;border:1px solid rgba(101,168,255,.28);border-radius:8px;background:linear-gradient(135deg,rgba(20,31,49,.92),rgba(15,23,36,.96));box-shadow:var(--shadow);padding:24px}
.hero:before{content:"";position:absolute;inset:0 0 auto;height:3px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--rose),var(--gold));animation:scan 4s linear infinite}
.hero-layout{display:grid;grid-template-columns:minmax(0,1fr) 320px;gap:20px;align-items:stretch}
.brand{font-size:12px;color:var(--cyan);letter-spacing:.12em;text-transform:uppercase;font-weight:800}
.h1{font-size:34px;line-height:1.12;font-weight:900;margin:8px 0 10px}
.muted{color:var(--muted)}
.hero-copy{max-width:760px}
.status-card{background:rgba(7,11,18,.62);border:1px solid var(--line);border-radius:8px;padding:14px}
.status-row{display:flex;justify-content:space-between;gap:14px;border-bottom:1px solid rgba(166,181,200,.14);padding:8px 0}
.status-row:last-child{border-bottom:0}
.status-row span{color:var(--muted)}
.status-row b{text-align:right}
.chip-row{display:flex;flex-wrap:wrap;gap:8px;margin-top:16px}
.chip{border:1px solid rgba(62,231,209,.36);background:rgba(62,231,209,.1);color:#d9fffa;border-radius:999px;padding:7px 10px;font-size:13px;font-weight:800}
.section{margin-top:18px}
.section-head{display:flex;justify-content:space-between;gap:16px;align-items:end;margin:0 0 10px}
.section h2{font-size:18px;margin:0}
.panel{background:rgba(15,23,36,.82);border:1px solid var(--line);border-radius:8px;padding:16px;box-shadow:0 14px 38px rgba(0,0,0,.18)}
.dashboard{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px}
.traffic-value{font-size:19px;font-weight:900;color:var(--green);overflow-wrap:anywhere}
.traffic-note{color:var(--muted);font-size:13px;margin-top:6px}
.stat-number{font-size:40px;line-height:1;font-weight:950;color:var(--gold)}
.metric-card{position:relative;overflow:hidden;min-height:150px;display:flex;flex-direction:column;justify-content:space-between}
.metric-card:before{content:"";position:absolute;left:0;right:0;top:0;height:3px;background:linear-gradient(90deg,var(--cyan),var(--gold))}
.metric-kicker{color:var(--muted);font-size:12px;font-weight:900;text-transform:uppercase;letter-spacing:.08em}
.metric-big{font-size:34px;line-height:1.05;font-weight:950;color:#fff;overflow-wrap:anywhere}
.metric-caption{color:var(--muted);font-size:13px}
.quick-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:10px}
.action-tile{position:relative;overflow:hidden;border:1px solid var(--line);border-radius:8px;background:linear-gradient(180deg,rgba(25,40,61,.9),rgba(13,20,32,.9));padding:13px;min-height:128px;display:flex;flex-direction:column;justify-content:space-between}
.action-tile:before{content:"";position:absolute;inset:0 0 auto;height:2px;background:linear-gradient(90deg,var(--cyan),var(--blue));opacity:.8}
.action-title{font-weight:900;margin-bottom:4px}
.action-text{color:var(--muted);font-size:13px;margin-bottom:10px}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;background:#17263a;border:1px solid rgba(101,168,255,.34);color:var(--text);border-radius:7px;padding:9px 12px;text-decoration:none;font-weight:850;margin:4px 6px 4px 0;min-height:38px}
.btn:hover{border-color:var(--cyan);background:#1c3048}
.btn.primary{background:linear-gradient(135deg,#1f8fdd,#17bba9);border-color:rgba(62,231,209,.82);color:#031119}
.btn.gold{background:linear-gradient(135deg,#ffd166,#ff9f1c);border-color:rgba(255,209,102,.9);color:#161002}
.copy{cursor:pointer}
.qr-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin-top:12px}
.qr-item{position:relative;overflow:hidden;background:rgba(8,13,22,.78);border:1px solid var(--line);border-radius:8px;padding:13px;text-align:center}
.qr-item:nth-child(3){border-color:rgba(62,231,209,.72);box-shadow:0 0 0 1px rgba(62,231,209,.18) inset}
.qr-glow{height:3px;margin:-13px -13px 12px;background:linear-gradient(90deg,var(--blue),var(--cyan),var(--gold))}
.qr-item img{display:block;width:100%;max-width:178px;aspect-ratio:1/1;margin:0 auto 10px;background:#fff;border-radius:8px;padding:8px}
.qr-title{font-weight:950;margin-bottom:5px;overflow-wrap:anywhere}
.qr-hint{min-height:38px;color:var(--muted);font-size:12px;margin-bottom:10px}
.qr-copy{width:100%;margin:0}
.notice{border-color:rgba(255,209,102,.52);background:linear-gradient(135deg,rgba(255,209,102,.12),rgba(255,107,154,.08)),rgba(15,23,36,.86)}
.notice .lead{font-size:15px;color:#fff4d8}
.steps{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin:14px 0}
.step{background:rgba(7,11,18,.72);border:1px solid var(--line);border-radius:8px;padding:12px}
.step b{display:block;color:var(--gold);margin-bottom:4px}
.recommend-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.recommend-card{background:linear-gradient(180deg,rgba(18,34,43,.94),rgba(8,13,17,.96));border:1px solid rgba(50,230,199,.28);border-radius:8px;padding:13px;min-height:112px}
.recommend-title{color:var(--gold);font-size:12px;text-transform:uppercase;letter-spacing:.05em;font-weight:950;margin-bottom:7px}
.recommend-name{font-weight:950;overflow-wrap:anywhere}
.recommend-meta{color:var(--muted);font-size:12px;margin-top:7px}
.profile-list{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:12px}
.profile-card{background:rgba(8,13,22,.78);border:1px solid var(--line);border-radius:8px;padding:12px;transition:transform .18s ease,border-color .18s ease}
.profile-card:hover{transform:translateY(-2px);border-color:rgba(62,231,209,.55)}
.profile-top{display:flex;justify-content:space-between;gap:10px;align-items:center;margin-bottom:8px}
.profile-type{color:var(--cyan);font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.04em}
.profile-host{color:var(--muted);font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.profile-name{font-size:15px;font-weight:900;margin-bottom:10px;overflow-wrap:anywhere}
.profile-actions{display:flex;gap:8px}
.profile-copy{width:100%;margin:0}
.empty-state{border:1px dashed var(--line);border-radius:8px;padding:14px;color:var(--muted)}
.os{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-top:14px}
.os div{background:rgba(20,31,49,.86);border:1px solid var(--line);border-radius:8px;padding:12px}
.mini{display:inline-block;margin-top:8px;color:var(--cyan);text-decoration:none;font-weight:800}
.mini:hover{text-decoration:underline}
code{color:#d5f7ff}
/* Premium client page skin */
:root{--bg:#070908;--panel:#101820;--panel2:#16232a;--panel3:#1c2b30;--line:#31414a;--text:#f7fbf6;--muted:#b5c1bb;--cyan:#32e6c7;--blue:#76a9ff;--green:#7cf29a;--gold:#ffd36a;--rose:#ff6f91;--shadow:0 22px 58px rgba(0,0,0,.38)}
body{background:#070908;color:var(--text);font-family:Inter,Arial,sans-serif}
body:before{opacity:.3;background:linear-gradient(135deg,rgba(255,211,106,.13) 0 1px,transparent 1px),linear-gradient(90deg,rgba(50,230,199,.08) 1px,transparent 1px);background-size:28px 28px,56px 56px;mask-image:linear-gradient(to bottom,#000 0%,rgba(0,0,0,.72) 42%,transparent 88%)}
.wrap{max-width:1120px;padding:20px 16px 48px}
.hero{border-color:rgba(255,211,106,.38);background:linear-gradient(135deg,rgba(13,34,31,.98),rgba(15,20,25,.98) 48%,rgba(42,27,35,.96));box-shadow:0 24px 70px rgba(0,0,0,.46)}
.hero:before{height:4px;background:linear-gradient(90deg,var(--gold),var(--cyan),var(--rose),var(--blue))}
.hero-layout{grid-template-columns:minmax(0,1fr) 300px}
.brand{color:var(--gold)}
.h1{font-size:38px;margin:9px 0 12px}
.hero-copy .muted{font-size:16px;max-width:720px}
.status-card{background:rgba(6,10,12,.72);border-color:rgba(255,211,106,.24);box-shadow:inset 0 1px 0 rgba(255,255,255,.04)}
.status-row{padding:9px 0}
.status-row b{color:#fff;overflow-wrap:anywhere}
.chip{border-color:rgba(255,211,106,.42);background:rgba(255,211,106,.11);color:#fff3cf;border-radius:7px}
.chip:nth-child(2){border-color:rgba(50,230,199,.42);background:rgba(50,230,199,.1);color:#dcfff9}
.chip:nth-child(3){border-color:rgba(255,111,145,.42);background:rgba(255,111,145,.1);color:#ffe2e9}
.chip.locations{max-width:100%;overflow-wrap:anywhere}
.panel{background:linear-gradient(180deg,rgba(16,24,32,.92),rgba(10,15,19,.92));border-color:rgba(181,193,187,.18);box-shadow:0 16px 44px rgba(0,0,0,.24)}
.dashboard{grid-template-columns:repeat(3,minmax(0,1fr))}
.traffic-value{color:#dfffca;font-size:20px}
.stat-number{color:var(--gold);text-shadow:0 0 28px rgba(255,211,106,.24)}
.metric-card:nth-child(1):before{background:linear-gradient(90deg,var(--gold),var(--cyan))}
.metric-card:nth-child(2):before{background:linear-gradient(90deg,var(--green),var(--cyan))}
.metric-card:nth-child(3):before{background:linear-gradient(90deg,var(--rose),var(--blue))}
.quick-grid{grid-template-columns:repeat(3,minmax(0,1fr))}
.action-tile{border-color:rgba(181,193,187,.18);background:linear-gradient(180deg,rgba(25,37,45,.95),rgba(10,15,19,.95));min-height:142px;box-shadow:inset 0 1px 0 rgba(255,255,255,.04)}
.action-tile:before{height:3px;background:linear-gradient(90deg,var(--gold),var(--cyan))}
.action-tile.featured-action{border-color:rgba(50,230,199,.48);background:linear-gradient(180deg,rgba(20,48,44,.95),rgba(11,18,20,.96))}
.action-title{font-size:16px}
.action-text{font-size:13px}
.btn{border-color:rgba(181,193,187,.24);background:#132028;border-radius:8px}
.btn.primary{background:linear-gradient(135deg,#37efd1,#ffd36a);border-color:rgba(255,211,106,.8);color:#07100d}
.btn.gold{background:linear-gradient(135deg,#ffd36a,#ff8d6e);border-color:rgba(255,211,106,.82);color:#180d05}
.qr-grid{grid-template-columns:repeat(5,minmax(0,1fr))}
.qr-item{background:linear-gradient(180deg,rgba(17,26,34,.94),rgba(9,13,17,.96));border-color:rgba(181,193,187,.2)}
.qr-item:nth-child(2){border-color:rgba(50,230,199,.72);box-shadow:0 0 0 1px rgba(50,230,199,.16) inset,0 18px 48px rgba(50,230,199,.08)}
.qr-item:nth-child(3){border-color:rgba(181,193,187,.2);box-shadow:none}
.qr-glow{background:linear-gradient(90deg,var(--gold),var(--cyan),var(--rose))}
.notice{border-color:rgba(255,211,106,.45);background:linear-gradient(135deg,rgba(255,211,106,.11),rgba(50,230,199,.07)),rgba(12,17,20,.94)}
.profile-list{grid-template-columns:repeat(4,minmax(0,1fr))}
.profile-card{position:relative;background:linear-gradient(180deg,rgba(17,26,34,.94),rgba(9,13,17,.96));border-color:rgba(181,193,187,.2)}
.profile-card:before{content:"";position:absolute;left:0;top:0;bottom:0;width:3px;background:linear-gradient(180deg,var(--cyan),var(--gold));border-radius:8px 0 0 8px}
.profile-type{color:var(--gold)}
.profile-host{max-width:130px}
.os div{background:rgba(17,26,34,.94);border-color:rgba(181,193,187,.2)}
.mini{color:var(--cyan)}
@keyframes scan{0%{transform:translateX(-40%)}100%{transform:translateX(40%)}}
@media(max-width:980px){.hero-layout,.dashboard{grid-template-columns:1fr}.quick-grid,.qr-grid,.os,.recommend-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.profile-list{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media(max-width:680px){.wrap{padding:12px 10px 34px}.hero{padding:16px}.h1{font-size:28px}.section-head{display:block}.quick-grid,.qr-grid,.os,.steps,.recommend-grid,.profile-list{grid-template-columns:1fr}.stat-number{font-size:32px}.btn{width:100%;margin-right:0}.status-card{padding:12px}.profile-host{max-width:180px}}
@media(prefers-reduced-motion:reduce){.hero:before{animation:none}.profile-card{transition:none}}
/* Yurich subscription redesign */
:root{--bg:#06080d;--surface:#0d141d;--surface2:#111c27;--surface3:#172534;--line:#263548;--text:#f8fafc;--muted:#a9b4c2;--cyan:#2ce5c7;--blue:#6ea8ff;--gold:#ffd06a;--rose:#ff6e8f;--green:#78f29b;--shadow:0 22px 60px rgba(0,0,0,.34)}
html,body{max-width:100%;overflow-x:hidden}
body{background:linear-gradient(180deg,#05070b 0%,#08111a 48%,#06080d 100%);color:var(--text);font-family:Inter,Arial,sans-serif;line-height:1.55}
*{min-width:0}
body:before{display:none}
.wrap{max-width:1160px;display:flex;flex-direction:column;gap:16px;padding:28px 18px 58px}
.section{margin-top:0}
.hero{border:1px solid rgba(110,168,255,.28);border-radius:8px;background:linear-gradient(135deg,rgba(13,20,29,.96),rgba(14,29,38,.96) 52%,rgba(18,18,27,.96));box-shadow:var(--shadow);padding:26px}
.hero:before{height:4px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold));animation:none}
.hero-layout{grid-template-columns:minmax(0,1.1fr) minmax(280px,.55fr);gap:18px}
.brand{color:var(--cyan);font-size:12px;font-weight:950;letter-spacing:.08em}
.h1{font-size:36px;letter-spacing:0;margin:8px 0 12px}
.hero-copy .muted{max-width:720px;font-size:15px;color:#c1ccd8}
.chip-row{gap:7px;margin-top:18px}
.chip{border-radius:8px;border-color:rgba(255,255,255,.12);background:rgba(255,255,255,.06);color:#eff7ff;padding:7px 10px;overflow-wrap:anywhere}
.chip:first-child{border-color:rgba(44,229,199,.45);background:rgba(44,229,199,.10)}
.chip:nth-child(2){border-color:rgba(255,208,106,.45);background:rgba(255,208,106,.10)}
.chip:nth-child(3){border-color:rgba(110,168,255,.45);background:rgba(110,168,255,.10)}
.status-card{background:rgba(5,8,13,.72);border-color:rgba(255,255,255,.12);border-radius:8px;padding:12px}
.status-row{padding:9px 0;border-color:rgba(255,255,255,.08)}
.status-row span{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.04em}
.status-row b{font-size:13px;color:#fff;overflow-wrap:anywhere}
.panel{border-radius:8px;background:linear-gradient(180deg,rgba(17,28,39,.92),rgba(9,14,20,.94));border-color:rgba(255,255,255,.10);box-shadow:0 16px 44px rgba(0,0,0,.22)}
.dashboard{grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
.metric-card{min-height:132px;padding:16px}
.metric-card:before{height:3px;background:linear-gradient(90deg,var(--cyan),var(--blue))}
.metric-kicker{font-size:11px;color:#93a4b7}
.metric-big{font-size:30px}
.metric-caption{font-size:12px;color:var(--muted)}
.section-head{align-items:flex-start;margin-bottom:10px}
.section h2{font-size:19px}
.quick-grid{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:12px}
.action-tile{grid-column:span 2;min-height:148px;border-radius:8px;background:linear-gradient(180deg,rgba(20,32,44,.94),rgba(10,15,22,.95));border-color:rgba(255,255,255,.11);padding:15px;box-shadow:inset 0 1px 0 rgba(255,255,255,.04)}
.action-tile:before{height:3px;background:linear-gradient(90deg,var(--blue),var(--cyan))}
.action-tile.featured-action{grid-column:span 3;min-height:168px;background:linear-gradient(180deg,rgba(18,50,48,.94),rgba(9,17,22,.96));border-color:rgba(44,229,199,.34)}
.action-title{font-size:17px;font-weight:950}
.action-text{font-size:13px;color:#aeb9c6}
.btn{border-radius:8px;border-color:rgba(255,255,255,.14);background:#122033;color:#f8fafc;font-size:13px;font-weight:900;min-height:40px}
.btn:hover{border-color:rgba(44,229,199,.7);background:#17283d}
.btn.primary{background:linear-gradient(135deg,#29e6c5,#72a8ff);border-color:rgba(44,229,199,.75);color:#041014}
.btn.gold{background:linear-gradient(135deg,#ffd06a,#ff9d66);border-color:rgba(255,208,106,.72);color:#170d04}
.recommend-grid{grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
.recommend-card{min-height:104px;border-radius:8px;background:linear-gradient(180deg,rgba(18,28,38,.96),rgba(9,14,20,.96));border-color:rgba(255,208,106,.18)}
.recommend-title{color:var(--gold)}
.qr-grid{grid-template-columns:repeat(5,minmax(0,1fr));gap:12px}
.qr-item{border-radius:8px;background:linear-gradient(180deg,rgba(15,24,34,.96),rgba(8,12,18,.96));border-color:rgba(255,255,255,.11);padding:12px}
.qr-item:nth-child(2){border-color:rgba(44,229,199,.42);box-shadow:0 0 0 1px rgba(44,229,199,.12) inset}
.qr-item img{max-width:150px;border-radius:8px;padding:7px}
.qr-glow{height:3px;background:linear-gradient(90deg,var(--cyan),var(--blue),var(--gold))}
.qr-title{font-size:14px}
.qr-hint{font-size:12px;min-height:54px}
.notice{border-color:rgba(255,208,106,.24);background:linear-gradient(180deg,rgba(30,26,18,.88),rgba(11,15,20,.94))}
.steps{grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.step{border-radius:8px;background:rgba(5,8,13,.58);border-color:rgba(255,255,255,.10)}
.profile-list{grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
.profile-card{border-radius:8px;background:linear-gradient(180deg,rgba(15,24,34,.96),rgba(8,12,18,.96));border-color:rgba(255,255,255,.11);padding:14px}
.profile-card:before{display:none}
.profile-card:hover{transform:none;border-color:rgba(44,229,199,.42)}
.profile-type{color:var(--cyan)}
.profile-host{max-width:150px}
.hero-copy,.hero-copy .muted,.hero-copy .muted b,.status-card,.status-row,.status-row b,.chip,.recommend-name,.profile-name,.qr-title{overflow-wrap:anywhere;word-break:break-word}
@media(max-width:980px){.hero-layout,.dashboard,.recommend-grid{grid-template-columns:1fr}.quick-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.action-tile,.action-tile.featured-action{grid-column:auto}.qr-grid,.profile-list,.steps{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media(max-width:680px){.wrap{display:block;width:100vw;max-width:100vw;padding:12px 10px 34px;overflow:hidden}.hero,.panel,.status-card,.action-tile,.qr-item,.profile-card,.recommend-card{width:calc(100vw - 20px);max-width:calc(100vw - 20px);overflow:hidden}.section{margin-top:12px}.hero{padding:17px}.hero-layout{grid-template-columns:minmax(0,1fr)}.hero-copy .muted{display:block;max-width:100%;white-space:normal}.h1{font-size:28px}.chip-row{display:grid;grid-template-columns:1fr;gap:7px}.chip{display:block;width:100%;text-align:center}.chip.locations{display:block;width:100%;font-size:12px;line-height:1.45;text-align:left;white-space:normal}.quick-grid,.qr-grid,.profile-list,.steps{grid-template-columns:1fr}.dashboard{display:grid;grid-template-columns:1fr}.metric-big{font-size:28px}.status-row{display:grid;grid-template-columns:1fr;gap:4px}.status-row b{text-align:left;white-space:normal}.btn{width:100%;margin-right:0}.qr-hint{min-height:auto}.profile-host{max-width:190px}}
</style>
</head>
<body>
<main class="wrap">
  <section class="hero">
    <div class="hero-layout">
      <div class="hero-copy">
        <div class="brand">Yurich Connect</div>
        <div class="h1">Подписка ${safe_user}</div>
        <div class="muted">Личная ссылка Yurich Connect.<br>Не публикуй её в открытом доступе.</div>
        <div class="chip-row">
          <span class="chip">HTTPS</span>
          <span class="chip">Turbo</span>
          <span class="chip">Reality</span>
        </div>
      </div>
      <aside class="status-card">
        <div class="status-row"><span>Домен</span><b>${safe_domain}</b></div>
        <div class="status-row"><span>Срок</span><b>${safe_expiry_label}</b></div>
        <div class="status-row"><span>Локации</span><b>см. профили ниже</b></div>
        <div class="status-row"><span>Профилей</span><b>${profile_count}</b></div>
        <div class="status-row"><span>Обновлено</span><b>$(date '+%Y-%m-%d %H:%M')</b></div>
      </aside>
    </div>
  </section>

  <section class="section dashboard">
    <div class="panel metric-card">
      <div class="metric-kicker">Срок подписки</div>
      <div class="metric-big">${safe_days_left} дней</div>
      <div class="metric-caption">${safe_expiry_label}</div>
    </div>
    <div class="panel metric-card">
      <div class="metric-kicker">Трафик клиента</div>
      <div class="metric-big">${safe_hiddify_used_human}</div>
      <div class="metric-caption">${safe_traffic_summary} Счетчик персональный, общий трафик сервера здесь не показывается.</div>
    </div>
    <div class="panel metric-card">
      <div class="metric-kicker">Активные профили</div>
      <div class="metric-big">${profile_count}</div>
      <div class="metric-caption">HTTPS, Turbo и Reality по доступным локациям.</div>
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div>
        <h2>Рекомендации по стабильности</h2>
        <div class="muted">Рейтинг строится из последних серверных benchmark-проверок. Если сеть провайдера режет один протокол, пробуй резервный.</div>
      </div>
    </div>
    <div class="recommend-grid">
${recommendations_html}
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div>
        <h2>Быстрый импорт</h2>
        <div class="muted">Выбери приложение или скопируй URL подписки.</div>
      </div>
    </div>
    <div class="quick-grid">
      <article class="action-tile featured-action">
        <div><div class="action-title">Yurich Connect</div><div class="action-text">Основная подписка для твоего приложения и совместимых клиентов.</div></div>
        <button class="btn primary copy" data-copy="${safe_links_url}">Скопировать URL</button>
      </article>
      <article class="action-tile featured-action">
        <div><div class="action-title">Hiddify</div><div class="action-text">Сканируй QR внутри Hiddify или открой deeplink с телефона.</div></div>
        <a class="btn gold" href="${safe_hiddify_open_url}">Открыть Hiddify</a>
      </article>
      <article class="action-tile">
        <div><div class="action-title">Streisand</div><div class="action-text">Приложение для iPhone и iPad. Импортируй iOS-подписку или открой App Store.</div></div>
        <div>
          <a class="btn" href="${safe_streisand_url}" target="_blank" rel="noopener noreferrer">App Store</a>
          <button class="btn copy" data-copy="${safe_streisand_sub_url}">Скопировать iOS</button>
        </div>
      </article>
      <article class="action-tile">
        <div><div class="action-title">NekoBox</div><div class="action-text">Отдельная ссылка для NekoBox и похожих клиентов.</div></div>
        <button class="btn copy" data-copy="${safe_nekobox_url}">Скопировать NekoBox</button>
      </article>
      <article class="action-tile">
        <div><div class="action-title">v2rayNG</div><div class="action-text">Отдельная подписка только с VLESS Reality через TCP/${reality_public_port}.</div></div>
        <button class="btn copy" data-copy="${safe_v2rayng_url}">Скопировать v2rayNG</button>
      </article>
    </div>
    <div class="panel" style="margin-top:10px">
      <a class="btn" href="${safe_links_url}">links.txt</a>
      <a class="btn" href="${safe_hiddify_url}">hiddify.txt</a>
      <a class="btn" href="${safe_streisand_sub_url}">streisand.txt</a>
      <a class="btn" href="${safe_nekobox_url}">nekobox.txt</a>
      <a class="btn" href="${safe_v2rayng_url}">v2rayng.txt</a>
      <a class="btn" href="${safe_android_url}" target="_blank" rel="noopener noreferrer">Android</a>
      <a class="btn" href="${safe_windows_url}" target="_blank" rel="noopener noreferrer">Windows</a>
      <a class="btn" href="${safe_streisand_url}" target="_blank" rel="noopener noreferrer">Streisand iOS</a>
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <div>
        <h2>QR-коды</h2>
        <div class="muted">QR-коды содержат обычные URL подписок для популярных клиентов.</div>
      </div>
    </div>
    <div class="qr-grid">
${qr_cards_html}
    </div>
  </section>

${pingtunnel_panel_html}

  <section class="section panel notice">
    <h2>Telegram-уведомления</h2>
    <p class="lead">Чтобы получать напоминания об окончании подписки и важные новости, отправь разработчику свой Telegram ID.</p>
    <div class="steps">
      <div class="step"><b>1. Получи ID</b>Открой бота <a class="mini" href="${safe_tg_id_bot_url}" target="_blank" rel="noopener noreferrer">@getmyid_bot</a> и нажми Start.</div>
      <div class="step"><b>2. Отправь ID</b>Скопируй цифры Telegram ID и отправь их разработчику вместе с именем профиля: <code>${safe_user}</code>.</div>
      <div class="step"><b>3. Включи уведомления</b>Открой <a class="mini" href="${safe_tg_bot_url}" target="_blank" rel="noopener noreferrer">бота уведомлений</a> и нажми Start, чтобы бот мог присылать сообщения.</div>
    </div>
    <a class="btn" href="${safe_tg_id_bot_url}" target="_blank" rel="noopener noreferrer">Получить Telegram ID</a>
    <a class="btn" href="${safe_tg_bot_url}" target="_blank" rel="noopener noreferrer">Открыть бота уведомлений</a>
  </section>

  <section class="section">
    <div class="section-head">
      <div>
        <h2>Активные профили</h2>
        <div class="muted">Каждый профиль можно скопировать отдельно.</div>
      </div>
    </div>
    <div class="profile-list">
${profile_cards_html}
    </div>
  </section>

</main>
<script>
document.querySelectorAll('.copy').forEach(function(btn){
  var originalText = btn.textContent;
  btn.addEventListener('click', function(){
    var value = btn.getAttribute('data-copy') || '';
    function reset(text){btn.textContent=text;setTimeout(function(){btn.textContent=originalText},1600)}
    function fallback(){
      var ta=document.createElement('textarea');
      ta.value=value;ta.setAttribute('readonly','');ta.style.position='fixed';ta.style.left='-9999px';
      document.body.appendChild(ta);ta.select();
      try{document.execCommand('copy')?reset('Скопировано'):reset('Скопируй вручную')}catch(e){reset('Скопируй вручную')}
      document.body.removeChild(ta);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(value).then(function(){reset('Скопировано')}).catch(fallback);
    } else {
      fallback();
    }
  });
});
</script>
</body>
</html>
EOF
    chmod 644 "${page_dir}/index.html"
    printf '%s\n' "$sub_url"
}

cmd_subscription_user() {
    local user="${1:-}"
    if [[ -z "$user" ]]; then
        echo -ne "${CYAN}Пользователь: ${RESET}"
        read -r user
    fi
    local url
    url=$(generate_subscription_page "$user") || return 1
    ok "Страница подписки создана:"
    echo "  ${url}"
    echo "  links.txt: ${url}links.txt"
    echo "  v2rayng.txt: ${url}v2rayng.txt"
}

cmd_subscription_reset() {
    load_config
    local user="${1:-}"
    if [[ -z "$user" ]]; then
        echo -ne "${CYAN}Пользователь: ${RESET}"
        read -r user
    fi
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный логин"
        return 1
    fi
    local old_token=""
    if [[ -s "${SUBS_DIR}/${user}.token" ]]; then
        old_token=$(tr -dc 'a-fA-F0-9' < "${SUBS_DIR}/${user}.token" | head -c 48 || true)
    fi
    reset_token_file "${SUBS_DIR}/${user}.token"
    if [[ "$old_token" =~ ^[a-fA-F0-9]{32,64}$ ]]; then
        remove_web_token_dir "$SUBS_WEB_DIR" "$old_token"
    fi
    cmd_subscription_user "$user"
}

install_private_camouflage_page() {
    load_config
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен"
        return 1
    fi
    ensure_web_privacy_files
    local mode="${1:-}"
    local old_token=""
    if [[ "$mode" == "reset" && -s "$PRIVATE_PAGE_TOKEN_FILE" ]]; then
        old_token=$(tr -dc 'a-fA-F0-9' < "$PRIVATE_PAGE_TOKEN_FILE" | head -c 48 || true)
    fi
    [[ "$mode" == "reset" ]] && reset_token_file "$PRIVATE_PAGE_TOKEN_FILE"
    if [[ "$old_token" =~ ^[a-fA-F0-9]{32,64}$ ]]; then
        remove_web_token_dir "$PRIVATE_WEB_DIR" "$old_token"
    fi
    local token page_dir url
    token=$(get_or_create_token_file "$PRIVATE_PAGE_TOKEN_FILE")
    page_dir="${PRIVATE_WEB_DIR}/${token}"
    url="https://${DOMAIN}/p/${token}/"
    mkdir -p "$page_dir"
    chmod 755 "$page_dir"
    cat > "${page_dir}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex,nofollow,noarchive">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'none'; upgrade-insecure-requests">
<title>Yurich Panel Lab</title>
<style>
:root{--bg:#0a0e13;--panel:#111923;--line:#263241;--text:#edf2f7;--muted:#9ca9b7;--accent:#d4a017;--blue:#58a6ff;--green:#4ade80}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font-family:Inter,Arial,sans-serif}.wrap{max-width:980px;margin:0 auto;padding:34px 18px}.top{border-bottom:1px solid var(--line);padding-bottom:22px}.eyebrow{color:var(--accent);font-size:12px;text-transform:uppercase;letter-spacing:.12em}.h1{font-size:36px;font-weight:850;margin:8px 0}.muted{color:var(--muted);line-height:1.65}.grid{display:grid;grid-template-columns:2fr 1fr;gap:14px;margin-top:20px}.card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:18px}.row{display:flex;justify-content:space-between;border-bottom:1px solid var(--line);padding:10px 0}.row:last-child{border-bottom:0}.ok{color:var(--green)}code{color:var(--blue)}@media(max-width:760px){.grid{grid-template-columns:1fr}.h1{font-size:28px}}
</style>
</head>
<body>
<main class="wrap">
  <section class="top">
    <div class="eyebrow">Private technical notebook</div>
    <div class="h1">Yurich Panel Lab</div>
    <p class="muted">Личная страница для заметок по инфраструктуре, релизам и тестовым окружениям. Публичная часть сайта остаётся обычным техническим блогом, эта страница живёт только по секретному адресу.</p>
  </section>
  <section class="grid">
    <div class="card">
      <h2>Рабочие заметки</h2>
      <p class="muted">План на неделю: проверить резервные копии, обновить список зависимостей, прогнать диагностику TLS/HTTP3, сверить правила firewall и журнал systemd.</p>
      <p class="muted">Последняя проверка: <code>$(date '+%Y-%m-%d %H:%M')</code></p>
    </div>
    <div class="card">
      <h2>Статус</h2>
      <div class="row"><span>Docs</span><span class="ok">online</span></div>
      <div class="row"><span>Build notes</span><span class="ok">synced</span></div>
      <div class="row"><span>Monitoring</span><span class="ok">active</span></div>
    </div>
  </section>
</main>
</body>
</html>
EOF
    chmod 644 "${page_dir}/index.html"
    ok "Персональная фейковая страница создана:"
    echo "  ${url}"
}

cleanup_xray_legacy_transports() {
    if command -v ufw >/dev/null 2>&1; then
        ufw delete allow "${XRAY_VISION_PORT:-$XRAY_VISION_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
        ufw delete allow "${XRAY_WS_PORT:-$XRAY_WS_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
        ufw delete allow "${XRAY_HTTPUPGRADE_PORT:-$XRAY_HTTPUPGRADE_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
        ufw delete allow "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}/udp" >/dev/null 2>&1 || true
        ufw delete allow "${XRAY_XHTTP_PORT:-$XRAY_XHTTP_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
    fi
}

apply_xray_reality_firewall() {
    command -v ufw >/dev/null 2>&1 || return 0
    if [[ "${XRAY_REALITY_SNI_MUX_ENABLED:-0}" == "1" ]]; then
        ufw allow 443/tcp comment "HAProxy TLS SNI mux" >/dev/null 2>&1 || true
        ufw delete allow "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
    else
        ufw allow "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" comment "Xray REALITY" >/dev/null 2>&1 || true
    fi
}

cmd_xray_install() {
    load_config
    check_installed || { err "Сначала установи Yurich Panel и получи TLS сертификат"; return 1; }
    hr
    echo -e "${BOLD}  Xray Modern transports${RESET}"
    hr
    normalize_edge_routing_mode
    if edge_routing_mode_is_haproxy; then
        warn "Режим 443: HAProxy SNI mux. Reality будет доступен на ${DOMAIN}:443 через HAProxy."
        XRAY_FALLBACK_ENABLED="0"
        XRAY_REALITY_SNI_MUX_ENABLED="1"
        XRAY_REALITY_PUBLIC_PORT="443"
    else
        warn "Режим 443: Caddy-only. Caddy остаётся на 443, Reality будет на отдельном TCP-порту ${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}."
        warn "Legacy fallback hub переключает 443 с Caddy на Xray. Используй только если точно нужен старый режим."
        echo -ne "${YELLOW}Включить legacy Xray fallback hub на 443? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] && XRAY_FALLBACK_ENABLED="1" || XRAY_FALLBACK_ENABLED="0"
    fi

    echo -ne "${CYAN}Xray пользователь [xray]: ${RESET}"
    read -r xuser
    xuser="${xuser:-xray}"
    if ! is_valid_proxy_user "$xuser"; then
        err "Логин: 2-32 символа, только A-Z a-z 0-9 _ -"
        return 1
    fi
    local x_months
    x_months=$(prompt_user_term_months 12) || return 1
    set_user_expiry_months "$xuser" "$x_months" || true

    prompt_xray_reality_target || return 1

    install_xray_bin || return 1
    write_xray_config "$xuser" || return 1
    write_xray_service

    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        rewrite_caddyfile_current || return 1
        systemctl restart caddy
    fi

    apply_xray_reality_firewall
    cleanup_xray_legacy_transports
    systemctl restart xray
    XRAY_ENABLED="1"
    save_config
    refresh_haproxy_if_enabled || return 1
    ok "Xray запущен"
    local sub_url
    sub_url=$(generate_subscription_page "$xuser" 2>/dev/null || true)
    if [[ -n "$sub_url" ]]; then
        ok "Страница подписки Xray пользователя создана: $sub_url"
        echo -e "  links.txt: ${sub_url}links.txt"
    fi
    print_xray_client_config "$xuser"
}

provision_xray_user() {
    load_config
    local xuser="$1"
    local backup_file="" existed=0 uuid

    if ! is_valid_proxy_user "$xuser"; then
        err "Логин Xray: 2-32 символа, только A-Z a-z 0-9 _ -"
        return 1
    fi
    if [[ ! -x "$XRAY_BIN" ]]; then
        err "Xray не установлен. Открой меню 23 → 1."
        return 1
    fi
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен"
        return 1
    fi

    if get_xray_user_uuid "$xuser" >/dev/null 2>&1; then
        existed=1
    fi
    if [[ -f "$XRAY_USERS_FILE" ]]; then
        backup_file=$(mktemp)
        cp "$XRAY_USERS_FILE" "$backup_file"
    fi

    uuid=$(xray_ensure_user "$xuser") || return 1
    if [[ "$existed" -eq 1 ]]; then
        ok "Xray пользователь уже существует: ${xuser}"
    else
        ok "Xray пользователь создан: ${xuser} (${uuid})"
    fi

    if ! write_xray_config "$xuser"; then
        if [[ -n "$backup_file" && -f "$backup_file" ]]; then
            mv "$backup_file" "$XRAY_USERS_FILE"
            chmod 600 "$XRAY_USERS_FILE"
        else
            rm -f "$XRAY_USERS_FILE"
        fi
        err "Xray config не прошёл проверку, пользователь ${xuser} не применён"
        return 1
    fi
    rm -f "$backup_file" 2>/dev/null || true

    write_xray_service
    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        rewrite_caddyfile_current || return 1
        systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null || true
    fi
    apply_xray_reality_firewall
    cleanup_xray_legacy_transports
    systemctl restart xray || return 1
    XRAY_ENABLED="1"
    save_config
    refresh_haproxy_if_enabled || return 1
}

cmd_xray_add_user() {
    load_config
    local xuser="${1:-}"
    local months_arg="${2:-}"
    if [[ -z "$xuser" ]]; then
        echo -ne "${CYAN}Новый Xray пользователь: ${RESET}"
        read -r xuser
    fi
    local x_months
    if is_valid_user_months "$months_arg"; then
        x_months="$months_arg"
    elif [[ -t 0 ]]; then
        x_months=$(prompt_user_term_months 12) || return 1
    else
        x_months="12"
    fi
    if ! provision_xray_user "$xuser"; then
        return 1
    fi
    set_user_expiry_months "$xuser" "$x_months" || true

    local sub_url
    sub_url=$(generate_subscription_page "$xuser" 2>/dev/null || true)
    if [[ -n "$sub_url" ]]; then
        ok "Личная страница подписки создана:"
        echo "  ${sub_url}"
        echo "  links.txt: ${sub_url}links.txt"
    else
        warn "Страница подписки не создана автоматически. Проверь: sudo bash yurich-panel.sh subscription ${xuser}"
    fi

    print_xray_client_config "$xuser"
}

cmd_xray_add_compat_user() {
    load_config
    local xuser="${1:-}"
    local backup_file="" existed=0 uuid sub_url
    if [[ -z "$xuser" ]]; then
        echo -ne "${CYAN}Xray Reality TEST пользователь: ${RESET}"
        read -r xuser
    fi
    if ! is_valid_proxy_user "$xuser"; then
        err "Логин Xray: 2-32 символа, только A-Z a-z 0-9 _ -"
        return 1
    fi
    if [[ ! -x "$XRAY_BIN" ]]; then
        err "Xray не установлен. Открой меню 23 → 1."
        return 1
    fi
    if ! get_xray_user_uuid "$xuser" >/dev/null 2>&1; then
        err "Основной Xray Reality пользователь не найден: ${xuser}"
        return 1
    fi
    if get_xray_compat_user_uuid "$xuser" >/dev/null 2>&1; then
        existed=1
    fi
    if [[ -f "$XRAY_COMPAT_USERS_FILE" ]]; then
        backup_file=$(mktemp)
        cp "$XRAY_COMPAT_USERS_FILE" "$backup_file"
    fi

    uuid=$(xray_ensure_compat_user "$xuser") || return 1
    if [[ "$existed" -eq 1 ]]; then
        ok "Reality TEST пользователь уже существует: ${xuser}"
    else
        ok "Reality TEST пользователь создан: ${xuser} (${uuid})"
    fi

    if ! write_xray_config; then
        if [[ -n "$backup_file" && -f "$backup_file" ]]; then
            mv "$backup_file" "$XRAY_COMPAT_USERS_FILE"
            chmod 600 "$XRAY_COMPAT_USERS_FILE"
        else
            rm -f "$XRAY_COMPAT_USERS_FILE"
        fi
        err "Xray config не прошёл проверку, Reality TEST для ${xuser} не применён"
        return 1
    fi
    rm -f "$backup_file" 2>/dev/null || true

    write_xray_service
    systemctl restart xray || return 1
    save_config
    refresh_haproxy_if_enabled || return 1
    sub_url=$(generate_subscription_page "$xuser" 2>/dev/null || true)
    [[ -n "$sub_url" ]] && ok "Подписка обновлена: ${sub_url}"
}

cmd_xray_rebuild() {
    load_config
    if [[ ! -x "$XRAY_BIN" ]]; then
        warn "Xray не установлен — rebuild пропущен"
        return 0
    fi
    if [[ ! -s "$XRAY_USERS_FILE" ]]; then
        warn "xray-users.conf пустой — rebuild пропущен"
        return 0
    fi
    write_xray_config || return 1
    write_xray_service
    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        rewrite_caddyfile_current || return 1
        systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null || true
    fi
    apply_xray_reality_firewall
    cleanup_xray_legacy_transports
    systemctl restart xray || return 1
    XRAY_ENABLED="1"
    save_config
    refresh_haproxy_if_enabled || return 1
    ok "Xray config пересобран"
}

cmd_xray_status() {
    load_config
    hr
    echo -e "${BOLD}  Xray статус${RESET}"
    hr
    [[ -x "$XRAY_BIN" ]] && "$XRAY_BIN" version | head -1 || warn "Xray не установлен"
    systemctl status xray --no-pager -l 2>/dev/null || true
    ss -tulpn | grep -E ":(443|${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT})([[:space:]]|$)" || true
    [[ -f "$XRAY_CONFIG" ]] && "$XRAY_BIN" run -test -config "$XRAY_CONFIG" || true
    hr
}

cmd_vless_tune() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  VLESS Reality stability tuning${RESET}"
    hr

    local backup_dir="${BACKUP_DIR}/vless-tune-before-$(date '+%Y%m%d_%H%M%S')"
    install -d -m 700 "$backup_dir"
    for item in "$XRAY_CONFIG" "$XRAY_SERVICE" "$HAPROXY_CFG" "$HAPROXY_SYSCTL_CONF" "$XRAY_SYSCTL_CONF"; do
        [[ -e "$item" ]] && cp -a "$item" "$backup_dir/" 2>/dev/null || true
    done
    info "Backup: $backup_dir"

    apply_vless_tcp_tuning

    if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        info "Пересобираю Xray с policy/sockopt tuning..."
        write_xray_config || return 1
        write_xray_service
        if ! "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1; then
            err "Xray config не прошёл проверку после tuning"
            "$XRAY_BIN" run -test -config "$XRAY_CONFIG" || true
            return 1
        fi
        systemctl daemon-reload
        systemctl restart xray || { journalctl -u xray -n 60 --no-pager; return 1; }
        systemctl is-active --quiet xray || { journalctl -u xray -n 60 --no-pager; return 1; }
        ok "Xray перезапущен с VLESS tuning"
    else
        warn "Xray не установлен или config отсутствует — применён только Linux TCP tuning"
    fi

    if edge_routing_mode_is_haproxy; then
        info "Обновляю HAProxy TCP keepalive/SNI mux..."
        ensure_haproxy_packages || return 1
        write_haproxy_logging_config
        write_haproxy_sni_mux_config || return 1
        systemctl enable haproxy --quiet
        systemctl reload haproxy 2>/dev/null || systemctl restart haproxy
        systemctl is-active --quiet haproxy || { journalctl -u haproxy -n 60 --no-pager; return 1; }
        sleep 3
        if ! haproxy_backends_healthy >/tmp/yurich-haproxy-health.out 2>&1; then
            warn "HAProxy запущен, но health-check требует внимания:"
            sed -n '1,80p' /tmp/yurich-haproxy-health.out || true
        else
            ok "HAProxy backend health OK"
        fi
    else
        info "HAProxy режим не включён — VLESS работает напрямую через Xray/Caddy-only порт"
    fi

    ok "VLESS tuning завершён"
}

cmd_xray_reality_target() {
    load_config
    prompt_xray_reality_target || return 1
    save_config

    if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        write_xray_config || return 1
        systemctl restart xray || return 1
        ok "Xray config пересобран с REALITY target: ${XRAY_REALITY_TARGET}"
    else
        ok "REALITY target сохранён: ${XRAY_REALITY_TARGET}"
        warn "Xray ещё не установлен. Target применится при установке Xray."
    fi
}

cmd_xray_zapret() {
    load_config
    local action="${1:-enable}"
    local dat="${XRAY_ZAPRET_DAT:-$XRAY_ZAPRET_DAT_DEFAULT}"

    case "${action,,}" in
        enable|on|"")
            XRAY_ZAPRET_ENABLED="0"
            save_config
            warn "Xray zapret больше не включает block-routing: он ломал Instagram/Facebook. Оставил режим выключенным."
            ;;
        update|refresh)
            rm -f "$dat" 2>/dev/null || true
            XRAY_ZAPRET_ENABLED="0"
            save_config
            XRAY_ZAPRET_ENABLED=1 ensure_xray_zapret_assets || return 1
            ;;
        disable|off)
            XRAY_ZAPRET_ENABLED="0"
            save_config
            ;;
        status)
            echo -e "  Enabled: ${CYAN}0${RESET} (blackhole routing disabled)"
            echo -e "  File:    ${CYAN}${dat}${RESET}"
            [[ -s "$dat" ]] && ls -lh "$dat" || warn "zapret.dat не найден"
            return 0
            ;;
        *)
            err "Используй: xray-zapret [update|disable|status]. enable оставлен только для совместимости и не включает блокировку."
            return 1
            ;;
    esac

    if [[ -x "$XRAY_BIN" && -s "$XRAY_USERS_FILE" ]]; then
        if ! cmd_xray_rebuild; then
            if [[ "${action,,}" == "enable" || "${action,,}" == "on" || -z "${action:-}" || "${action,,}" == "update" || "${action,,}" == "refresh" ]]; then
                XRAY_ZAPRET_ENABLED="0"
                save_config
                warn "zapret.dat отключён на этом сервере: Xray не прошёл тест с текущими ресурсами"
                cmd_xray_rebuild || true
            fi
            return 1
        fi
    else
        warn "Xray ещё не установлен или нет пользователей. Настройка сохранена и применится при следующей сборке Xray."
    fi
}

cmd_xray_logs() {
    echo -e "${BOLD}Лог Xray (Ctrl+C для выхода):${RESET}"
    journalctl -u xray -n 80 -f
}

cmd_xray_remove() {
    echo -ne "${RED}Удалить Xray и вернуть Caddy на 443? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] || return
    systemctl disable --now xray >/dev/null 2>&1 || true
    rm -f "$XRAY_SERVICE" "$XRAY_CONFIG" "$XRAY_BIN"
    ufw delete allow "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
    ufw delete allow "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}/udp" >/dev/null 2>&1 || true
    ufw delete allow 8447/tcp >/dev/null 2>&1 || true
    ufw delete allow "${XRAY_XHTTP_PORT:-$XRAY_XHTTP_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
    XRAY_ENABLED="0"
    XRAY_FALLBACK_ENABLED="0"
    save_config
    systemctl daemon-reload
    rewrite_caddyfile_current || true
    systemctl restart caddy 2>/dev/null || true
    ok "Xray удалён из конфигурации, Caddy возвращён на 443"
}

cmd_xray_menu() {
    while true; do
        load_config
        hr
        echo -e "${BOLD}  Xray Modern transports & fallback${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Установить / пересобрать Xray config"
        echo -e "  ${BOLD}2)${RESET} Показать клиентские ссылки"
        echo -e "  ${BOLD}3)${RESET} Статус"
        echo -e "  ${BOLD}4)${RESET} Логи"
        echo -e "  ${BOLD}5)${RESET} Удалить Xray / вернуть Caddy"
        echo -e "  ${BOLD}6)${RESET} Создать Xray пользователя + подписка"
        echo -e "  ${BOLD}7)${RESET} REALITY target presets / test"
        echo -e "  ${BOLD}8)${RESET} Zapret RU GOV routing"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -e "  Fallback 443: ${CYAN}${XRAY_FALLBACK_ENABLED:-0}${RESET} | REALITY: ${CYAN}${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}${RESET} | Target: ${CYAN}${XRAY_REALITY_TARGET:-www.microsoft.com:443}${RESET} | Zapret: ${CYAN}${XRAY_ZAPRET_ENABLED:-0}${RESET}"
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_xray_install ;;
            2)
                echo -ne "${CYAN}Пользователь [первый]: ${RESET}"; read -r u
                print_xray_client_config "$u"
                ;;
            3) cmd_xray_status ;;
            4) cmd_xray_logs ;;
            5) cmd_xray_remove ;;
            6) cmd_xray_add_user ;;
            7) cmd_xray_reality_target ;;
            8)
                echo -ne "${CYAN}Действие [enable/update/disable/status]: ${RESET}"; read -r zact
                cmd_xray_zapret "${zact:-enable}"
                ;;
            0) return ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
}

# ─── CLOUDFLARE WARP PROXY MODE ───────────────────────────────
install_warp_client() {
    if command -v warp-cli &>/dev/null; then
        ok "cloudflare-warp уже установлен: $(warp-cli --version 2>/dev/null | head -1 || echo warp-cli)"
        return 0
    fi

    local codename
    codename=$(lsb_release -cs 2>/dev/null || true)
    if [[ -z "$codename" && -f /etc/os-release ]]; then
        codename=$(awk -F= '$1=="VERSION_CODENAME"{gsub(/"/,"",$2); print $2; exit}' /etc/os-release 2>/dev/null || true)
    fi

    if [[ -z "$codename" ]]; then
        err "Не смог определить codename дистрибутива для репозитория Cloudflare WARP"
        return 1
    fi

    case "$codename" in
        focal|jammy|noble|bullseye|bookworm|trixie) ;;
        *)
            warn "Cloudflare официально поддерживает не все релизы. Codename: $codename"
            echo -ne "${YELLOW}Продолжить установку WARP repo для ${codename}? [y/N]: ${RESET}"
            read -r ans
            [[ "${ans,,}" == "y" ]] || return 1
            ;;
    esac

    info "Добавляю официальный репозиторий Cloudflare WARP..."
    apt-get update -qq
    apt-get install -y -q curl ca-certificates gnupg lsb-release
    mkdir -p /usr/share/keyrings /etc/apt/sources.list.d
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg \
        | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ ${codename} main" \
        > /etc/apt/sources.list.d/cloudflare-client.list

    info "Устанавливаю cloudflare-warp..."
    apt-get update -qq
    apt-get install -y -q cloudflare-warp
    ok "cloudflare-warp установлен"
}

warp_registration_new() {
    if warp_cli registration show >/dev/null 2>&1 || warp_cli account >/dev/null 2>&1; then
        ok "WARP регистрация уже есть"
        return 0
    fi

    info "Регистрирую WARP клиент..."
    if warp_cli registration new >/dev/null 2>&1 || warp_cli register >/dev/null 2>&1; then
        ok "WARP клиент зарегистрирован"
        return 0
    fi

    err "Не удалось зарегистрировать WARP. Попробуй вручную: warp-cli registration new"
    return 1
}

warp_set_proxy_port() {
    local port="$1"
    if warp_cli proxy port "$port" >/dev/null 2>&1; then
        return 0
    fi
    if warp_cli set-proxy-port "$port" >/dev/null 2>&1; then
        return 0
    fi

    if [[ "$port" == "$WARP_PROXY_PORT_DEFAULT" ]]; then
        warn "Не смог явно выставить порт, оставляю дефолт WARP proxy: ${WARP_PROXY_PORT_DEFAULT}"
        return 0
    fi

    err "Эта версия warp-cli не дала сменить proxy port. Используй ${WARP_PROXY_PORT_DEFAULT} или проверь: warp-cli --help"
    return 1
}

warp_set_proxy_mode() {
    # Современный WARP local proxy mode требует MASQUE; если команда недоступна, не считаем это фатальным.
    warp_cli tunnel protocol set MASQUE >/dev/null 2>&1 || true

    if warp_cli mode proxy >/dev/null 2>&1; then
        return 0
    fi
    if warp_cli set-mode proxy >/dev/null 2>&1; then
        return 0
    fi

    err "Не удалось включить WARP proxy mode. Проверь: warp-cli mode --help"
    return 1
}

warp_set_mode() {
    local mode="$1"
    if warp_cli mode "$mode" >/dev/null 2>&1; then
        return 0
    fi
    if warp_cli set-mode "$mode" >/dev/null 2>&1; then
        return 0
    fi
    err "Не удалось переключить WARP mode: ${mode}. Проверь: warp-cli mode --help"
    return 1
}

warp_set_tunnel_protocol() {
    local proto="$1"
    case "$proto" in
        MASQUE|WireGuard) ;;
        auto|"") return 0 ;;
        *)
            err "Протокол WARP должен быть auto, MASQUE или WireGuard"
            return 1
            ;;
    esac
    if warp_cli tunnel protocol set "$proto" >/dev/null 2>&1; then
        WARP_PROTOCOL="$proto"
        ok "WARP protocol: ${proto}"
        return 0
    fi
    warn "Не удалось выставить WARP protocol=${proto}. Проверь: warp-cli tunnel protocol set ${proto}"
    return 1
}

warp_wait_connected() {
    local i status
    for i in {1..30}; do
        status=$(warp_cli status 2>/dev/null || true)
        if echo "$status" | grep -Eiq "connected|соедин"; then
            return 0
        fi
        sleep 1
    done
    warn "WARP не подтвердил Connected за 30 секунд"
    warp_cli status 2>/dev/null || true
    return 1
}

warp_current_ssh_client_ip() {
    local ip=""
    if [[ -n "${SSH_CLIENT:-}" ]]; then
        ip=$(awk '{print $1}' <<< "$SSH_CLIENT")
    elif [[ -n "${SSH_CONNECTION:-}" ]]; then
        ip=$(awk '{print $1}' <<< "$SSH_CONNECTION")
    fi
    if [[ -z "$ip" ]]; then
        ip=$(who -m 2>/dev/null | sed -n 's/.*(\([^)]*\)).*/\1/p' | head -1 || true)
    fi
    printf '%s\n' "$ip"
}

warp_route_cidr_for_ip() {
    local ip="$1"
    [[ -z "$ip" ]] && return 1
    if [[ "$ip" == *:* ]]; then
        printf '%s/128\n' "$ip"
    else
        printf '%s/32\n' "$ip"
    fi
}

warp_add_excluded_route() {
    local cidr="$1"
    [[ -z "$cidr" ]] && return 1

    if warp_cli tunnel ip add-range "$cidr" >/dev/null 2>&1; then
        ok "WARP exclude route добавлен: ${cidr}"
        return 0
    fi
    if warp_cli tunnel ip add "$cidr" >/dev/null 2>&1; then
        ok "WARP exclude route добавлен: ${cidr}"
        return 0
    fi
    if warp_cli add-excluded-route "$cidr" >/dev/null 2>&1; then
        ok "WARP exclude route добавлен: ${cidr}"
        return 0
    fi
    if warp_cli tunnel exclude-routes "$cidr" >/dev/null 2>&1; then
        ok "WARP exclude route добавлен: ${cidr}"
        return 0
    fi

    warn "Не удалось автоматически добавить WARP exclude route: ${cidr}"
    warn "Если SSH отвалится, используй консоль провайдера: sudo bash yurich-panel.sh warp-disable"
    return 1
}

warp_prepare_ssh_safety() {
    local ssh_ip ssh_cidr public_ip public_cidr route
    ssh_ip=$(warp_current_ssh_client_ip)
    if [[ -n "$ssh_ip" ]]; then
        ssh_cidr=$(warp_route_cidr_for_ip "$ssh_ip" || true)
        [[ -n "$ssh_cidr" ]] && warp_add_excluded_route "$ssh_cidr" || true
    else
        warn "Не смог определить IP текущей SSH-сессии через SSH_CLIENT/SSH_CONNECTION"
    fi

    for route in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16; do
        warp_add_excluded_route "$route" >/dev/null 2>&1 || true
    done

    public_ip=$(curl -4 -fsSL --connect-timeout 5 --max-time 8 https://api.ipify.org 2>/dev/null || true)
    if [[ "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        public_cidr="${public_ip}/32"
        warp_add_excluded_route "$public_cidr" >/dev/null 2>&1 || true
    fi
    warp_apply_saved_ssh_excludes
}

normalize_warp_ssh_cidrs() {
    local raw="$1" item out="" normalized
    local -a cidrs
    raw="${raw// /}"
    IFS=',' read -ra cidrs <<< "$raw"
    for item in "${cidrs[@]}"; do
        [[ -z "$item" ]] && continue
        if [[ "$item" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            normalized="${item}/32"
        else
            normalized="$item"
        fi
        if ! is_valid_cidr4 "$normalized"; then
            err "Некорректный SSH allow CIDR: $item"
            return 1
        fi
        if [[ "${normalized#*/}" == "0" ]]; then
            err "Нельзя добавлять /0 в WARP SSH allowlist"
            return 1
        fi
        case ",$out," in
            *,"$normalized",*) ;;
            *) out="${out:+$out,}${normalized}" ;;
        esac
    done
    printf '%s\n' "$out"
}

warp_merge_ssh_allow_cidrs() {
    local old="$1" extra="$2" merged
    merged=$(normalize_warp_ssh_cidrs "${old:+$old,}${extra}") || return 1
    printf '%s\n' "$merged"
}

warp_apply_saved_ssh_excludes() {
    local cidr
    local -a _warp_saved_cidrs
    [[ -z "${WARP_SSH_ALLOW_CIDRS:-}" ]] && return 0
    IFS=',' read -ra _warp_saved_cidrs <<< "${WARP_SSH_ALLOW_CIDRS}"
    for cidr in "${_warp_saved_cidrs[@]}"; do
        [[ -z "$cidr" ]] && continue
        warp_add_excluded_route "$cidr" >/dev/null 2>&1 || true
    done
}

cmd_warp_ssh_allow() {
    load_config
    local current_ip current_cidr extra normalized merged
    current_ip=$(warp_current_ssh_client_ip)
    [[ -n "$current_ip" ]] && current_cidr=$(warp_route_cidr_for_ip "$current_ip" || true)

    hr
    echo -e "${BOLD}  WARP full tunnel SSH allowlist${RESET}"
    hr
    echo -e "  Сейчас сохранено: ${CYAN}${WARP_SSH_ALLOW_CIDRS:-нет}${RESET}"
    [[ -n "${current_cidr:-}" ]] && echo -e "  Текущая SSH-сессия: ${CYAN}${current_cidr}${RESET}"
    echo
    warn "Добавь IP/CIDR, с которых будешь заходить по SSH: домашний, мобильный, офисный."
    warn "Если IP динамический и заранее неизвестен, full tunnel всё равно может отрезать SSH."
    echo -ne "${CYAN}CIDR/IP через запятую [${current_cidr:-пусто}]: ${RESET}"
    read -r extra
    extra="${extra:-${current_cidr:-}}"
    normalized=$(normalize_warp_ssh_cidrs "$extra") || return 1
    [[ -z "$normalized" ]] && { warn "Ничего не добавлено"; return 0; }
    merged=$(warp_merge_ssh_allow_cidrs "${WARP_SSH_ALLOW_CIDRS:-}" "$normalized") || return 1
    WARP_SSH_ALLOW_CIDRS="$merged"
    save_config
    if command -v warp-cli >/dev/null 2>&1; then
        warp_apply_saved_ssh_excludes
    fi
    ok "WARP SSH allowlist обновлён: ${WARP_SSH_ALLOW_CIDRS}"
}

warp_arm_rollback() {
    local marker="/run/naiveproxy-warp-full-pending" unit_name
    unit_name="naiveproxy-warp-rollback-$(date +%s)"
    echo "$(date '+%F %T')" > "$marker" 2>/dev/null || true
    if command -v systemd-run >/dev/null 2>&1; then
        systemd-run --unit="$unit_name" --on-active=2m \
            /bin/bash -lc 'if [[ -f /run/naiveproxy-warp-full-pending ]]; then warp-cli disconnect >/dev/null 2>&1 || true; rm -f /run/naiveproxy-warp-full-pending; logger -t naiveproxy "WARP full tunnel rollback: disconnected after missing confirmation"; fi' \
            >/dev/null 2>&1 || true
        warn "Аварийный rollback WARP включён на 2 минуты. Подтверди доступ после подключения."
    else
        warn "systemd-run не найден — автоматический rollback WARP недоступен"
    fi
}

warp_disarm_rollback() {
    rm -f /run/naiveproxy-warp-full-pending 2>/dev/null || true
}

warp_confirm_access_or_keep_rollback() {
    echo
    warn "Проверка безопасности: если SSH/панель живы, нажми Enter в течение 90 секунд."
    warn "Если доступ уже пропал, ничего не нажимай — через 2 минуты WARP отключится rollback-сервисом."
    if read -r -t 90 _; then
        warp_disarm_rollback
        ok "Доступ подтверждён, rollback снят"
        return 0
    fi
    warn "Подтверждения нет. Rollback оставлен активным, WARP будет отключён автоматически."
    return 1
}

warp_wait_proxy_ready() {
    local port="${1:-${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}}"
    local i status settings

    for i in {1..20}; do
        status=$(warp_cli status 2>/dev/null || true)
        settings=$(warp_cli settings 2>/dev/null || true)

        if ss -tlnp 2>/dev/null | grep -Eq "(127\.0\.0\.1|\*):${port}[[:space:]]|:${port}[[:space:]]"; then
            if echo "$settings" | grep -Eiq "WarpProxy|proxy"; then
                return 0
            fi
        fi

        if echo "$status" | grep -Eiq "connected|соедин"; then
            ss -tlnp 2>/dev/null | grep -Eq "(127\.0\.0\.1|\*):${port}[[:space:]]|:${port}[[:space:]]" && return 0
        fi
        sleep 1
    done

    warn "WARP proxy порт ${port} не подтвердился за 20 секунд"
    warp_cli status 2>/dev/null || true
    warp_cli settings 2>/dev/null | sed -n '1,30p' || true
    return 1
}

test_warp_proxy() {
    local port="${1:-${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}}"
    local trace direct_trace tmp direct_ip proxy_ip proxy_warp method
    tmp=$(mktemp /tmp/warp_trace_XXXXXX)
    trap 'rm -f "${tmp:-}" 2>/dev/null; trap - RETURN' RETURN

    direct_trace=$(curl -fsSL --connect-timeout 5 --max-time 9 \
        https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null || true)
    direct_ip=$(printf '%s\n' "$direct_trace" | awk -F= '$1=="ip"{print $2; exit}')

    if curl -fsSL --connect-timeout 5 --max-time 9 -x "http://127.0.0.1:${port}" \
        https://www.cloudflare.com/cdn-cgi/trace -o "$tmp" 2>/dev/null; then
        trace=$(cat "$tmp")
        method="HTTP"
    elif curl -fsSL --connect-timeout 5 --max-time 9 --socks5-hostname "127.0.0.1:${port}" \
        https://www.cloudflare.com/cdn-cgi/trace -o "$tmp" 2>/dev/null; then
        trace=$(cat "$tmp")
        method="SOCKS5"
    else
        err "Не удалось пройти через WARP proxy 127.0.0.1:${port}"
        warn "Проверь: warp-cli status; warp-cli settings; ss -tlnp | grep ${port}"
        return 1
    fi

    proxy_ip=$(printf '%s\n' "$trace" | awk -F= '$1=="ip"{print $2; exit}')
    proxy_warp=$(printf '%s\n' "$trace" | awk -F= '$1=="warp"{print $2; exit}')
    [[ -n "$direct_ip" ]] && echo "  direct_ip=${direct_ip}"
    echo "  proxy_method=${method}"
    echo "$trace" | sed -n 's/^ip=/  ip=/p; s/^colo=/  colo=/p; s/^warp=/  warp=/p; s/^gateway=/  gateway=/p'

    if [[ "$proxy_warp" == "on" ]]; then
        ok "WARP proxy mode работает"
        if [[ -n "$direct_ip" && "$direct_ip" == "$proxy_ip" ]]; then
            warn "IP direct и proxy совпали. Для некоторых VPS это возможно, но проверь повторно."
        fi
        return 0
    else
        warn "Proxy отвечает, но trace не показал warp=on."
        warn "Без -x/--proxy общий IP VPS не изменится: WARP local proxy работает только для явно направленного трафика."
        warn "Если нужен выход через WARP для Naive/Xray/Hysteria, включи WARP proxy и дай скрипту пересобрать Caddy/Xray/Hysteria."
        warn "Для bridge на второй VPS всё равно нужен Xray/sing-box outbound: Caddy/Naive не заменяет полноценный chain-router."
        return 1
    fi
}

test_warp_full() {
    local trace direct_ip warp_state colo gateway tmp
    tmp=$(mktemp /tmp/warp_full_trace_XXXXXX)
    trap 'rm -f "${tmp:-}" 2>/dev/null; trap - RETURN' RETURN

    if ! curl -fsSL --connect-timeout 8 --max-time 15 \
        https://www.cloudflare.com/cdn-cgi/trace -o "$tmp" 2>/dev/null; then
        err "Не удалось проверить full-tunnel WARP через прямой curl"
        warn "Проверь: warp-cli status; warp-cli settings; journalctl -u warp-svc -n 30"
        return 1
    fi

    trace=$(cat "$tmp")
    direct_ip=$(printf '%s\n' "$trace" | awk -F= '$1=="ip"{print $2; exit}')
    warp_state=$(printf '%s\n' "$trace" | awk -F= '$1=="warp"{print $2; exit}')
    colo=$(printf '%s\n' "$trace" | awk -F= '$1=="colo"{print $2; exit}')
    gateway=$(printf '%s\n' "$trace" | awk -F= '$1=="gateway"{print $2; exit}')

    echo "  mode=full-tunnel"
    echo "  ip=${direct_ip:-unknown}"
    echo "  colo=${colo:-unknown}"
    echo "  warp=${warp_state:-unknown}"
    echo "  gateway=${gateway:-unknown}"

    if [[ "$warp_state" == "on" ]]; then
        ok "Full-tunnel WARP работает: весь исходящий трафик сервера идёт через WARP"
        return 0
    fi

    warn "Full-tunnel включён не полностью: trace не показал warp=on"
    return 1
}

refresh_services_after_warp_change() {
    load_config
    if [[ -f "$CADDYFILE" && -n "${DOMAIN:-}" && -s "$USERS_FILE" ]]; then
        info "Перегенерирую Caddyfile под текущий WARP mode..."
        if rewrite_caddyfile_current; then
            systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null || true
        else
            warn "Caddyfile не удалось пересобрать после смены WARP"
        fi
    fi
    if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        info "Перегенерирую Xray config под текущий WARP mode..."
        if write_xray_config && systemctl restart xray; then
            ok "Xray перезапущен"
        else
            warn "Xray не удалось пересобрать автоматически. Запусти: sudo bash yurich-panel.sh xray-install"
        fi
    fi
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        info "Перегенерирую Hysteria 2 config под текущий WARP mode..."
        if write_hysteria_config && apply_hysteria_port_hop && systemctl restart hysteria; then
            ok "Hysteria 2 перезапущена"
        else
            warn "Hysteria 2 не удалось пересобрать автоматически. Запусти: sudo bash yurich-panel.sh hysteria-install"
        fi
    fi
}

cmd_warp_install() {
    load_config
    hr
    echo -e "${BOLD}  Cloudflare WARP proxy mode${RESET}"
    hr
    warn "Это local proxy mode: слушает 127.0.0.1 и не меняет общий маршрут VPS."
    warn "Внешние порты в UFW не открываются, SSH не должен пропасть."
    echo

    echo -ne "${CYAN}Локальный порт WARP proxy [${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}]: ${RESET}"
    read -r ans_port
    WARP_PROXY_PORT="${ans_port:-${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}}"
    if ! is_valid_local_proxy_port "$WARP_PROXY_PORT"; then
        err "Порт должен быть числом 1024-65535"
        return 1
    fi

    if ss -tlnp 2>/dev/null | grep -E "127\\.0\\.0\\.1:${WARP_PROXY_PORT}([[:space:]]|$)" >/dev/null; then
        warn "127.0.0.1:${WARP_PROXY_PORT} уже слушается"
        echo -ne "${YELLOW}Продолжить всё равно? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || return 1
    fi

    install_warp_client || return 1
    systemctl enable --now warp-svc >/dev/null 2>&1 || systemctl enable --now cloudflare-warp >/dev/null 2>&1 || true
    warp_registration_new || return 1
    warp_set_proxy_mode || return 1
    warp_set_proxy_port "$WARP_PROXY_PORT" || return 1

    info "Подключаю WARP..."
    warp_cli connect >/dev/null 2>&1 || true
    warp_wait_proxy_ready "$WARP_PROXY_PORT" || true

    if test_warp_proxy "$WARP_PROXY_PORT"; then
        WARP_PROXY_ENABLED="1"
        WARP_MODE="proxy"
        WARP_PROTOCOL="MASQUE"
    else
        WARP_PROXY_ENABLED="0"
        WARP_MODE="off"
        save_config
        return 1
    fi
    save_config

    refresh_services_after_warp_change

    cmd_warp_status
}

cmd_warp_full_install() {
    load_config
    hr
    echo -e "${BOLD}  Cloudflare WARP full tunnel${RESET}"
    hr
    warn "Full tunnel меняет исходящий маршрут всего VPS через WARP."
    warn "Входящие порты Caddy/SSH обычно остаются входящими, но на VPS проверяй через консоль провайдера."
    warn "Если что-то пошло не так: sudo bash yurich-panel.sh warp-disable"
    echo

    echo -ne "${CYAN}DNS тоже через WARP DoH? [Y/n]: ${RESET}"
    read -r dns_ans
    local full_mode="warp+doh"
    [[ "${dns_ans,,}" == "n" ]] && full_mode="warp"

    echo -ne "${CYAN}Протокол [auto/MASQUE/WireGuard] (Enter = auto/RU): ${RESET}"
    read -r proto_ans
    proto_ans="${proto_ans:-auto}"
    case "$proto_ans" in
        auto|MASQUE|WireGuard) ;;
        masque) proto_ans="MASQUE" ;;
        wireguard|wg) proto_ans="WireGuard" ;;
        *) err "Неверный протокол"; return 1 ;;
    esac

    local current_ssh_ip current_ssh_cidr extra_ssh_cidrs normalized_extra
    current_ssh_ip=$(warp_current_ssh_client_ip)
    [[ -n "$current_ssh_ip" ]] && current_ssh_cidr=$(warp_route_cidr_for_ip "$current_ssh_ip" || true)
    echo
    echo -e "${CYAN}SSH safety:${RESET} текущий IP будет исключён из WARP автоматически: ${current_ssh_cidr:-не определён}"
    echo -ne "${CYAN}Доп. SSH IP/CIDR через запятую (дом/моб), Enter = пропустить: ${RESET}"
    read -r extra_ssh_cidrs
    if [[ -n "$extra_ssh_cidrs" ]]; then
        normalized_extra=$(normalize_warp_ssh_cidrs "$extra_ssh_cidrs") || return 1
        WARP_SSH_ALLOW_CIDRS=$(warp_merge_ssh_allow_cidrs "${WARP_SSH_ALLOW_CIDRS:-}" "$normalized_extra") || return 1
        save_config
    fi

    install_warp_client || return 1
    systemctl enable --now warp-svc >/dev/null 2>&1 || systemctl enable --now cloudflare-warp >/dev/null 2>&1 || true
    warp_registration_new || return 1
    warp_prepare_ssh_safety
    warp_arm_rollback

    local tried="" proto
    if [[ "$proto_ans" == "auto" ]]; then
        for proto in MASQUE WireGuard; do
            info "Пробую WARP full tunnel: ${full_mode}, protocol=${proto}"
            warp_set_tunnel_protocol "$proto" || true
            warp_set_mode "$full_mode" || return 1
            warp_cli connect >/dev/null 2>&1 || true
            warp_wait_connected || true
            if test_warp_full; then
                WARP_MODE="$full_mode"
                WARP_PROTOCOL="$proto"
                WARP_PROXY_ENABLED="0"
                tried="ok"
                break
            fi
            warn "protocol=${proto} не подтвердил warp=on"
        done
        [[ "$tried" == "ok" ]] || { err "Full-tunnel WARP не заработал ни на MASQUE, ни на WireGuard"; warp_cli disconnect >/dev/null 2>&1 || true; warp_disarm_rollback; return 1; }
    else
        warp_set_tunnel_protocol "$proto_ans" || return 1
        warp_set_mode "$full_mode" || return 1
        warp_cli connect >/dev/null 2>&1 || true
        warp_wait_connected || true
        test_warp_full || { warp_cli disconnect >/dev/null 2>&1 || true; warp_disarm_rollback; return 1; }
        WARP_MODE="$full_mode"
        WARP_PROTOCOL="$proto_ans"
        WARP_PROXY_ENABLED="0"
    fi

    if ! warp_confirm_access_or_keep_rollback; then
        WARP_MODE="off"
        WARP_PROXY_ENABLED="0"
        save_config
        refresh_services_after_warp_change
        return 1
    fi
    save_config
    refresh_services_after_warp_change
}

print_warp_proxy_config() {
    load_config
    local port="${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    hr
    echo -e "${BOLD}${GREEN}  WARP modes config${RESET}"
    hr
    echo -e "  ${BOLD}Текущий режим:${RESET} ${WARP_MODE:-off}"
    echo -e "  ${BOLD}Текущий протокол:${RESET} ${WARP_PROTOCOL:-auto}"
    echo
    echo -e "  ${BOLD}SOCKS5:${RESET} socks5h://127.0.0.1:${port}"
    echo -e "  ${BOLD}HTTP:${RESET}   http://127.0.0.1:${port}"
    echo
    echo -e "  ${YELLOW}Важно:${RESET} WARP local proxy подходит для приложений с SOCKS5/HTTP proxy."
    echo -e "          У Cloudflare Local Proxy есть ограничения для долгих запросов."
    echo -e "          В proxy mode Caddy/Naive добавляет upstream socks5://127.0.0.1:${port}."
    echo -e "          Xray и Hysteria после пересборки используют WARP SOCKS5 outbound."
    echo -e "          Full tunnel: весь исходящий трафик VPS через WARP, проверка без -x."
    echo
    echo -e "${CYAN}  Проверка:${RESET}"
    echo -e "  curl -x http://127.0.0.1:${port} https://www.cloudflare.com/cdn-cgi/trace"
    echo -e "  curl --socks5-hostname 127.0.0.1:${port} https://www.cloudflare.com/cdn-cgi/trace"
    echo -e "  curl https://www.cloudflare.com/cdn-cgi/trace"
    echo
    echo -e "${CYAN}  Для временного использования в shell:${RESET}"
    echo -e "  export ALL_PROXY=socks5h://127.0.0.1:${port}"
    echo -e "  export HTTPS_PROXY=http://127.0.0.1:${port}"
    hr
}

cmd_warp_status() {
    load_config
    local port="${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    hr
    echo -e "${BOLD}  WARP статус${RESET}"
    hr
    echo -e "  Config mode: ${CYAN}${WARP_MODE:-off}${RESET}"
    echo -e "  Protocol:    ${CYAN}${WARP_PROTOCOL:-auto}${RESET}"
    echo -e "  SSH allow:   ${CYAN}${WARP_SSH_ALLOW_CIDRS:-нет}${RESET}"
    if command -v warp-cli &>/dev/null; then
        ok "warp-cli: $(warp-cli --version 2>/dev/null | head -1 || echo установлен)"
        warp-cli status 2>/dev/null || true
        warp-cli settings 2>/dev/null | sed -n '1,20p' || true
    else
        warn "cloudflare-warp не установлен"
    fi
    if [[ "${WARP_MODE:-off}" == "warp" || "${WARP_MODE:-off}" == "warp+doh" ]]; then
        info "Full tunnel активен: local proxy порт ${port} может не слушаться, это нормально."
    else
        ss -tlnp 2>/dev/null | grep -E "(127\.0\.0\.1|\*):${port}[[:space:]]|:${port}[[:space:]]" || warn "Локальный порт ${port} не слушается"
    fi
    hr
}

cmd_warp_test() {
    load_config
    if [[ "${WARP_MODE:-}" == "warp" || "${WARP_MODE:-}" == "warp+doh" ]]; then
        test_warp_full
    else
        test_warp_proxy "${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    fi
}

cmd_warp_test_full() {
    load_config
    test_warp_full
}

cmd_warp_health() {
    load_config
    local failed=0 port="${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    hr
    echo -e "${BOLD}  WARP health${RESET}"
    hr
    echo -e "  Mode:     ${CYAN}${WARP_MODE:-off}${RESET}"
    echo -e "  Protocol: ${CYAN}${WARP_PROTOCOL:-auto}${RESET}"
    if command -v warp-cli >/dev/null 2>&1; then
        warp-cli --accept-tos status 2>/dev/null || warp-cli status 2>/dev/null || true
    else
        warn "warp-cli не установлен"
        failed=$((failed + 1))
    fi
    if [[ "${WARP_MODE:-off}" == "warp" || "${WARP_MODE:-off}" == "warp+doh" ]]; then
        test_warp_full || failed=$((failed + 1))
    else
        ss -tlnp 2>/dev/null | grep -qE "(127\.0\.0\.1|\*):${port}[[:space:]]|:${port}[[:space:]]" || { err "WARP proxy порт ${port} не слушается"; failed=$((failed + 1)); }
        test_warp_proxy "$port" || failed=$((failed + 1))
    fi
    [[ "$failed" -eq 0 ]]
}

cmd_warp_protocol() {
    load_config
    echo -e "${BOLD}  WARP tunnel protocol${RESET}"
    echo -e "  1) auto"
    echo -e "  2) MASQUE"
    echo -e "  3) WireGuard"
    echo -ne "${CYAN}Выбор [1-3]: ${RESET}"
    read -r choice
    case "$choice" in
        1|"") WARP_PROTOCOL="auto"; ok "Protocol: auto" ;;
        2) warp_set_tunnel_protocol MASQUE || return 1 ;;
        3) warp_set_tunnel_protocol WireGuard || return 1 ;;
        *) warn "Неверный выбор"; return 1 ;;
    esac
    save_config
}

cmd_warp_logs() {
    echo -e "${BOLD}Лог WARP (Ctrl+C для выхода):${RESET}"
    journalctl -u warp-svc -n 80 -f 2>/dev/null || journalctl -u cloudflare-warp -n 80 -f
}

cmd_warp_disable() {
    load_config
    warp_disarm_rollback
    warp_cli disconnect >/dev/null 2>&1 || true
    WARP_PROXY_ENABLED="0"
    WARP_MODE="off"
    save_config
    refresh_services_after_warp_change
    ok "WARP отключён. Пакет оставлен установленным."
}

cmd_warp_remove() {
    echo -ne "${RED}Удалить cloudflare-warp полностью? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] || return
    load_config
    warp_cli disconnect >/dev/null 2>&1 || true
    systemctl stop warp-svc cloudflare-warp >/dev/null 2>&1 || true
    apt-get purge -y -q cloudflare-warp || true
    rm -f /etc/apt/sources.list.d/cloudflare-client.list
    WARP_PROXY_ENABLED="0"
    WARP_PROXY_PORT="$WARP_PROXY_PORT_DEFAULT"
    WARP_MODE="off"
    WARP_PROTOCOL="auto"
    save_config
    refresh_services_after_warp_change
    ok "cloudflare-warp удалён"
}

cmd_warp_menu() {
    while true; do
        load_config
        hr
        echo -e "${BOLD}  Cloudflare WARP modes${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Включить local proxy mode (127.0.0.1)"
        echo -e "  ${BOLD}2)${RESET} Включить full tunnel для всего VPS"
        echo -e "  ${BOLD}3)${RESET} Выбрать протокол (auto/MASQUE/WireGuard)"
        echo -e "  ${BOLD}4)${RESET} Показать config"
        echo -e "  ${BOLD}5)${RESET} Статус"
        echo -e "  ${BOLD}6)${RESET} Проверить local proxy"
        echo -e "  ${BOLD}7)${RESET} Проверить full tunnel"
        echo -e "  ${BOLD}8)${RESET} Логи"
        echo -e "  ${BOLD}9)${RESET} Отключить WARP"
        echo -e "  ${BOLD}10)${RESET} Удалить WARP"
        echo -e "  ${BOLD}11)${RESET} SSH allowlist для full tunnel"
        echo -e "  ${BOLD}0)${RESET} Назад"
        echo
        echo -e "  Mode: ${CYAN}${WARP_MODE:-off}${RESET} | Protocol: ${CYAN}${WARP_PROTOCOL:-auto}${RESET} | Proxy: ${CYAN}127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}${RESET}"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_warp_install ;;
            2) cmd_warp_full_install ;;
            3) cmd_warp_protocol ;;
            4) print_warp_proxy_config ;;
            5) cmd_warp_status ;;
            6) test_warp_proxy "${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}" ;;
            7) cmd_warp_test_full ;;
            8) cmd_warp_logs ;;
            9) cmd_warp_disable ;;
            10) cmd_warp_remove ;;
            11) cmd_warp_ssh_allow ;;
            0) return ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
}

# ─── Ввод параметров ─────────────────────────────────────────
prompt_params() {
    echo
    echo -e "${BOLD}Настройка Yurich Panel:${RESET}"
    echo

    while true; do
        echo -ne "${CYAN}Домен (например, proxy.example.com): ${RESET}"
        read -r DOMAIN
        if is_valid_domain "$DOMAIN"; then
            break
        fi
        err "Неверный формат домена. Только буквы, цифры, дефис, точка."
    done

    while true; do
        echo -ne "${CYAN}Email для TLS (Let's Encrypt): ${RESET}"
        read -r EMAIL
        [[ "$EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]] && break
        err "Введи корректный email"
    done

    echo -ne "${CYAN}Имя сервера в подписках (Enter = Yurich, пример: Finland): ${RESET}"
    read -r PROFILE_LOCATION_LABEL
    PROFILE_LOCATION_LABEL="${PROFILE_LOCATION_LABEL:-Yurich}"

    while true; do
        echo -ne "${CYAN}Логин первого пользователя (Enter = naive): ${RESET}"
        read -r first_user
        first_user="${first_user:-naive}"
        is_valid_proxy_user "$first_user" && break
        err "Логин: 2-32 символа, только A-Z a-z 0-9 _ -"
    done

    while true; do
        echo -ne "${CYAN}Пароль (Enter = случайный): ${RESET}"
        read -r first_pass
        if [[ -z "$first_pass" ]]; then
            first_pass=$(random_safe_token 20)
            info "Сгенерирован пароль: $first_pass"
        fi
        is_valid_proxy_pass "$first_pass" && break
        err "Пароль: 8-64 символа, только A-Z a-z 0-9 _ -"
    done

    local first_months
    first_months=$(prompt_user_term_months 12) || return 1

    load_users
    echo "${first_user}:${first_pass}" > "$USERS_FILE"
    chmod 600 "$USERS_FILE"
    set_user_expiry_months "$first_user" "$first_months" || true
}


# ─── УПРАВЛЕНИЕ ДОМЕНАМИ ─────────────────────────────────────
cmd_domains() {
    load_config

    while true; do
        hr
        echo -e "${BOLD}  Управление доменами${RESET}"
        hr

        local current_domains="${DOMAINS:-${DOMAIN:-}}"
        echo -e "  ${BOLD}Текущие домены:${RESET}"
        local i=1
        IFS=',' read -ra dlist <<< "$current_domains"
        for d in "${dlist[@]}"; do
            d="${d// /}"
            [[ -n "$d" ]] && echo -e "  ${i}. ${CYAN}${d}${RESET}" && i=$((i+1))
        done
        echo
        echo -e "  ${BOLD}1)${RESET} Добавить домен"
        echo -e "  ${BOLD}2)${RESET} Удалить домен"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice; echo

        case "$choice" in
            1)
                echo -ne "${CYAN}Новый домен: ${RESET}"
                read -r new_dom
                if [[ ! "$new_dom" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
                    err "Неверный формат домена"
                    continue
                fi
                check_domain "$new_dom"
                if [[ -z "$DOMAINS" ]]; then
                    DOMAINS="${DOMAIN:-}"
                fi
                DOMAINS="${DOMAINS},${new_dom}"
                # Убираем ведущую запятую
                DOMAINS="${DOMAINS#,}"
                save_config
                backup_config
                write_caddyfile_multi
                systemctl reload caddy 2>/dev/null || systemctl restart caddy
                ok "Домен $new_dom добавлен"
                tg_send "🌐 <b>Добавлен домен</b>: <code>${new_dom}</code>"
                ;;
            2)
                # Защита: считаем сколько доменов
                local _dom_total
                _dom_total=$(echo "$current_domains" | tr ',' '\n' | grep -c '\S' || echo 0)
                if [[ ${_dom_total} -le 1 ]]; then
                    err "Нельзя удалить последний домен!"
                    err "Сервер перестанет работать без домена."
                    err "Сначала добавь новый домен (вариант 1), потом удаляй старый."
                    echo -ne "${YELLOW}Enter для продолжения...${RESET}"; read -r
                    continue
                fi
                echo -ne "${CYAN}Номер домена для удаления: ${RESET}"
                read -r del_idx
                local new_domains=""
                local j=1
                IFS=',' read -ra dlist2 <<< "$current_domains"
                for d in "${dlist2[@]}"; do
                    d="${d// /}"
                    [[ -z "$d" ]] && continue
                    if [[ "$j" != "$del_idx" ]]; then
                        new_domains="${new_domains},${d}"
                    fi
                    j=$((j+1))
                done
                DOMAINS="${new_domains#,}"
                DOMAIN=$(echo "$DOMAINS" | cut -d',' -f1)
                save_config
                backup_config
                write_caddyfile_multi
                systemctl reload caddy 2>/dev/null || systemctl restart caddy
                ok "Домен удалён"
                ;;
            0) break ;;
            *) warn "Неверный выбор" ;;
        esac

        echo -ne "${YELLOW}Enter для продолжения...${RESET}"; read -r
    done
}

# ─── УПРАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯМИ ────────────────────────────────
cmd_users() {
    load_users

    while true; do
        hr
        echo -e "${BOLD}  Управление пользователями${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Список пользователей"
        echo -e "  ${BOLD}2)${RESET} Добавить пользователя"
        echo -e "  ${BOLD}3)${RESET} Удалить пользователя"
        echo -e "  ${BOLD}4)${RESET} Сменить пароль"
        echo -e "  ${BOLD}5)${RESET} Показать ссылку пользователя"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice; echo

        case "$choice" in
            1)
                local count=0
                while IFS=: read -r u p; do
                    count=$((count+1))
                    echo -e "  ${count}. ${BOLD}${u}${RESET} : $p  ${DIM}срок: $(user_expiry_label "$u")${RESET}"
                done < <(get_users)
                [[ $count -eq 0 ]] && warn "Нет пользователей"
                echo -e "  Итого: $count"
                ;;
            2)
                echo -ne "${CYAN}Новый логин: ${RESET}"; read -r new_user
                [[ -z "$new_user" ]] && { err "Логин не может быть пустым"; continue; }
                # Валидация: только буквы, цифры, дефис, подчёркивание (защита от sed-инъекции)
                if ! is_valid_proxy_user "$new_user"; then
                    err "Логин: 2-32 символа, только A-Z a-z 0-9 _ -"
                    continue
                fi
                if get_user_pass "$new_user" >/dev/null; then
                    err "Пользователь $new_user уже существует"
                    continue
                fi
                echo -ne "${CYAN}Пароль (Enter = случайный): ${RESET}"; read -r new_pass
                if [[ -z "$new_pass" ]]; then
                    new_pass=$(random_safe_token 20)
                    info "Сгенерирован пароль: $new_pass"
                fi
                if ! is_valid_proxy_pass "$new_pass"; then
                    err "Пароль: 8-64 символа, только A-Z a-z 0-9 _ -"
                    continue
                fi
                local new_months
                new_months=$(prompt_user_term_months 12) || continue
                local users_backup
                users_backup=$(mktemp)
                cp "$USERS_FILE" "$users_backup"
                printf '%s:%s\n' "${new_user}" "${new_pass}" >> "$USERS_FILE"
                set_user_expiry_months "$new_user" "$new_months" || true
                backup_config
                if ! rewrite_caddyfile_current; then
                    mv "$users_backup" "$USERS_FILE"
                    cleanup_user_metadata "$new_user"
                    err "Caddyfile не собрался, пользователь $new_user отменён"
                    continue
                fi
                if ! systemctl reload caddy 2>/dev/null && ! systemctl restart caddy 2>/dev/null; then
                    mv "$users_backup" "$USERS_FILE"
                    cleanup_user_metadata "$new_user"
                    rewrite_caddyfile_current >/dev/null 2>&1 || true
                    err "Caddy не перезагрузился, пользователь $new_user отменён"
                    continue
                fi
                rm -f "$users_backup"
                ok "Пользователь $new_user добавлен"
                local hy_added=0
                if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
                    if sync_hysteria_users_if_active; then
                        hy_added=1
                    fi
                fi
                local xray_added=0
                if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
                    echo -ne "${CYAN}Создать Xray/VLESS конфиги для ${new_user} тоже? [Y/n]: ${RESET}"
                    read -r add_xray_ans
                    if [[ "${add_xray_ans,,}" != "n" ]]; then
                        if provision_xray_user "$new_user"; then
                            xray_added=1
                            ok "Xray/VLESS конфиги для ${new_user} готовы"
                        else
                            warn "Naive пользователь создан, но Xray профиль не применён"
                        fi
                    fi
                fi
                local sub_url
                sub_url=$(generate_subscription_page "$new_user" 2>/dev/null || true)
                if [[ -n "$sub_url" ]]; then
                    ok "Страница подписки создана: $sub_url"
                    echo -e "  links.txt: ${sub_url}links.txt"
                else
                    warn "Страница подписки не создана автоматически. Проверь: sudo bash yurich-panel.sh subscription ${new_user}"
                fi
                print_client_config "$new_user"
                if [[ "$hy_added" -eq 1 ]]; then
                    print_hysteria_client_config "$new_user"
                fi
                if [[ "$xray_added" -eq 1 ]]; then
                    print_xray_client_config "$new_user"
                fi
                tg_send "👤 <b>Новый пользователь Yurich Panel</b>
🔑 Логин: <code>${new_user}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
                ;;
            3)
                echo -ne "${CYAN}Логин для удаления: ${RESET}"; read -r del_user
                if ! delete_subscription_user_everywhere "$del_user"; then
                    warn "Удаление $del_user не выполнено"
                    continue
                fi
                tg_send "🗑 <b>Пользователь удалён полностью: ${del_user}</b>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
                ;;
            4)
                echo -ne "${CYAN}Логин: ${RESET}"; read -r chg_user
                if ! is_valid_proxy_user "$chg_user" || ! get_user_pass "$chg_user" >/dev/null; then
                    err "Пользователь $chg_user не найден"; continue
                fi
                echo -ne "${CYAN}Новый пароль (Enter = случайный): ${RESET}"; read -r chg_pass
                if [[ -z "$chg_pass" ]]; then
                    chg_pass=$(random_safe_token 20)
                    info "Сгенерирован пароль: $chg_pass"
                fi
                if ! is_valid_proxy_pass "$chg_pass"; then
                    err "Пароль: 8-64 символа, только A-Z a-z 0-9 _ -"; continue
                fi
                backup_config
                # Безопасная замена без sed regex
                local tmp_users
                tmp_users=$(mktemp)
                trap 'rm -f "${tmp_users:-}" 2>/dev/null' RETURN
                while IFS=: read -r u p; do
                    if [[ "$u" == "$chg_user" ]]; then
                        printf '%s:%s
' "$u" "$chg_pass"
                    else
                        printf '%s:%s
' "$u" "$p"
                    fi
                done < "$USERS_FILE" > "$tmp_users" && mv "$tmp_users" "$USERS_FILE"
                rewrite_caddyfile_current
                systemctl reload caddy 2>/dev/null || systemctl restart caddy
                sync_hysteria_users_if_active >/dev/null 2>&1 || true
                cleanup_subscription_page "$chg_user"
                generate_subscription_page "$chg_user" >/dev/null 2>&1 || true
                ok "Пароль $chg_user изменён"
                ;;
            5)
                echo -ne "${CYAN}Логин: ${RESET}"; read -r show_user
                print_client_config "$show_user"
                ;;
            0) break ;;
            *) warn "Неверный выбор" ;;
        esac

        echo -ne "${YELLOW}Enter для продолжения...${RESET}"; read -r
    done
}

# ─── ЛИМИТ УСТРОЙСТВ / АНТИ-ШАРИНГ ────────────────────────────
device_log_files() {
    local f
    for f in "${LOG_DIR}/naive.log" "${LOG_DIR}"/naive.log.* "${LOG_DIR}"/naive_*.log "${LOG_DIR}"/naive_*.log.*; do
        [[ -f "$f" ]] && printf '%s\n' "$f"
    done
}

xray_log_files() {
    local f
    for f in /var/log/xray/access.log /var/log/xray/access.log.*; do
        [[ -f "$f" ]] && printf '%s\n' "$f"
    done
}

device_usage_report() {
    local window="${1:-${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}}"
    local since since_text pair_file
    since=$(date -d "${window} hours ago" +%s 2>/dev/null || echo 0)
    since_text=$(date -d "${window} hours ago" '+%Y/%m/%d %H:%M:%S' 2>/dev/null || echo "")
    [[ "$since" =~ ^[0-9]+$ ]] || since=0
    pair_file=$(mktemp)
    trap 'rm -f "${pair_file:-}" 2>/dev/null; trap - RETURN' RETURN

    local logs=()
    mapfile -t logs < <(device_log_files)
    if [[ "${#logs[@]}" -gt 0 ]]; then
        awk -v since="$since" '
            {
                ts=0; user=""; ip="";
                if ($0 !~ /"user_id":/ || $0 !~ /"remote_ip":/) next;

                tmp=$0;
                sub(/^.*"ts":/, "", tmp);
                sub(/[,}].*$/, "", tmp);
                ts=tmp+0;
                if (ts < since) next;

                tmp=$0;
                sub(/^.*"user_id":"/, "", tmp);
                sub(/".*$/, "", tmp);
                user=tmp;

                tmp=$0;
                sub(/^.*"remote_ip":"/, "", tmp);
                sub(/".*$/, "", tmp);
                ip=tmp;

                if (user != "" && ip != "") print user "\t" ip;
            }
        ' "${logs[@]}" >> "$pair_file"
    fi

    local xlogs=()
    mapfile -t xlogs < <(xray_log_files)
    if [[ "${#xlogs[@]}" -gt 0 && -f "$XRAY_USERS_FILE" ]]; then
        awk -v since_text="$since_text" -v users_file="$XRAY_USERS_FILE" '
            BEGIN {
                while ((getline line < users_file) > 0) {
                    split(line, a, ":");
                    if (a[1] != "") users[a[1]]=1;
                }
            }
            {
                if (since_text != "" && substr($0, 1, 19) < since_text) next;
                user=""; ip="";
                for (u in users) {
                    if ($0 ~ ("email[:= ]+" u) || $0 ~ ("\\[" u "\\]") || $0 ~ (" " u "$")) {
                        user=u;
                        break;
                    }
                }
                if (user == "") next;
                if (match($0, /(tcp|udp):[0-9][0-9.]*:[0-9]+/)) {
                    ip=substr($0, RSTART, RLENGTH);
                    sub(/^(tcp|udp):/, "", ip);
                    sub(/:[0-9]+$/, "", ip);
                } else if (match($0, / [0-9][0-9.]*:[0-9]+ accepted/)) {
                    ip=substr($0, RSTART + 1, RLENGTH - 10);
                    sub(/:[0-9]+$/, "", ip);
                }
                if (ip != "") print user "\t" ip;
            }
        ' "${xlogs[@]}" >> "$pair_file"
    fi

    [[ -s "$pair_file" ]] || return 1
    awk -F'\t' '
        { if ($1 != "" && $2 != "") seen[$1 SUBSEP $2]=1; }
        END {
            for (k in seen) {
                split(k, a, SUBSEP);
                counts[a[1]]++;
                ips[a[1]]=ips[a[1]] " " a[2];
            }
            for (u in counts) {
                out=ips[u];
                sub(/^ /, "", out);
                print u "\t" counts[u] "\t" out;
            }
        }
    ' "$pair_file" | sort -k2,2nr -k1,1
}

write_device_cron() {
    if [[ "${DEVICE_LIMIT_ENABLED:-0}" == "1" ]]; then
        cat > "$DEVICE_CRON" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
*/15 * * * * root ${SCRIPT_PATH} devices-scan >/dev/null 2>&1
EOF
        chmod 644 "$DEVICE_CRON"
        ok "Автопроверка устройств включена: каждые 15 минут"
    else
        rm -f "$DEVICE_CRON"
        ok "Автопроверка устройств отключена"
    fi
}

device_disable_user() {
    local target="$1"
    local has_naive=0 has_xray=0 changed=0
    if ! is_valid_proxy_user "$target"; then
        err "Некорректный логин"
        return 1
    fi
    get_user_pass "$target" >/dev/null && has_naive=1
    [[ -n "$(get_xray_user_uuid "$target" 2>/dev/null || true)" ]] && has_xray=1
    if [[ "$has_naive" -eq 0 && "$has_xray" -eq 0 ]]; then
        err "Пользователь $target не найден"
        return 1
    fi

    local pass backup tmp
    if [[ "$has_naive" -eq 1 ]]; then
        if [[ "$(active_user_count)" -le 1 ]]; then
            warn "Naive: нельзя отключить последнего активного пользователя"
        else
            pass=$(get_user_pass "$target")
            backup=$(mktemp)
            tmp=$(mktemp)
            cp "$USERS_FILE" "$backup"
            mkdir -p "$CONFIG_DIR"
            touch "$DISABLED_USERS_FILE"
            chmod 600 "$DISABLED_USERS_FILE"
            printf '%s:%s\t# disabled by device-limit at %s\n' "$target" "$pass" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$DISABLED_USERS_FILE"
            awk -F: -v user="$target" '$1 != user' "$USERS_FILE" > "$tmp" && mv "$tmp" "$USERS_FILE"
            chmod 600 "$USERS_FILE"
            if ! rewrite_caddyfile_current; then
                mv "$backup" "$USERS_FILE"
                rewrite_caddyfile_current >/dev/null 2>&1 || true
                rm -f "$tmp" "$backup"
                err "Не смог обновить Caddyfile, Naive пользователь $target возвращён"
                return 1
            fi
            rm -f "$tmp" "$backup"
            systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null || true
            changed=1
            ok "Naive пользователь $target отключён"
        fi
    fi

    if [[ "$has_xray" -eq 1 ]]; then
        if [[ "$(xray_active_user_count)" -le 1 ]]; then
            warn "Xray: нельзя отключить последнего активного пользователя"
        else
            local uuid xray_tmp xray_backup
            uuid=$(get_xray_user_uuid "$target")
            xray_backup=$(mktemp)
            cp "$XRAY_USERS_FILE" "$xray_backup"
            touch "$XRAY_DISABLED_USERS_FILE"
            chmod 600 "$XRAY_DISABLED_USERS_FILE"
            printf '%s:%s\t# disabled by device-limit at %s\n' "$target" "$uuid" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$XRAY_DISABLED_USERS_FILE"
            xray_tmp=$(mktemp)
            awk -F: -v user="$target" '$1 != user' "$XRAY_USERS_FILE" > "$xray_tmp" && mv "$xray_tmp" "$XRAY_USERS_FILE"
            chmod 600 "$XRAY_USERS_FILE"
            if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
                if ! write_xray_config >/dev/null 2>&1; then
                    mv "$xray_backup" "$XRAY_USERS_FILE"
                    write_xray_config >/dev/null 2>&1 || true
                    warn "Xray config не пересобран, пользователь $target возвращён"
                    return 1
                fi
                systemctl restart xray 2>/dev/null || true
            fi
            rm -f "$xray_backup"
            changed=1
            ok "Xray пользователь $target отключён"
        fi
    fi

    [[ "$changed" -eq 1 ]] || return 1
    cleanup_subscription_page "$target"
    ok "Страница подписки $target отозвана"
}

device_enable_user() {
    local target="$1"
    if ! is_valid_proxy_user "$target"; then
        err "Некорректный логин"
        return 1
    fi
    local restored=0
    if get_user_pass "$target" >/dev/null; then
        warn "Пользователь $target уже активен"
        restored=1
    fi

    local line pass tmp
    if [[ -f "$DISABLED_USERS_FILE" ]]; then
        line=$(awk -F: -v user="$target" '$1 == user {print; exit}' "$DISABLED_USERS_FILE")
        if [[ -n "$line" ]]; then
            pass=$(printf '%s\n' "$line" | cut -d: -f2 | awk '{print $1}')
            if is_valid_proxy_pass "$pass"; then
                printf '%s:%s\n' "$target" "$pass" >> "$USERS_FILE"
                tmp=$(mktemp)
                awk -F: -v user="$target" '$1 != user' "$DISABLED_USERS_FILE" > "$tmp" && mv "$tmp" "$DISABLED_USERS_FILE"
                chmod 600 "$USERS_FILE" "$DISABLED_USERS_FILE"
                rewrite_caddyfile_current
                systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null || true
                restored=1
                ok "Naive пользователь $target снова активен"
            else
                warn "Naive пароль отключенного пользователя повреждён"
            fi
        fi
    fi

    if [[ -f "$XRAY_DISABLED_USERS_FILE" ]]; then
        line=$(awk -F: -v user="$target" '$1 == user {print; exit}' "$XRAY_DISABLED_USERS_FILE")
        if [[ -n "$line" ]]; then
            local uuid xray_tmp
            uuid=$(printf '%s\n' "$line" | cut -d: -f2 | awk '{print $1}')
            if [[ "$uuid" =~ ^[0-9a-fA-F-]{36}$ ]]; then
                printf '%s:%s\n' "$target" "$uuid" >> "$XRAY_USERS_FILE"
                xray_tmp=$(mktemp)
                awk -F: -v user="$target" '$1 != user' "$XRAY_DISABLED_USERS_FILE" > "$xray_tmp" && mv "$xray_tmp" "$XRAY_DISABLED_USERS_FILE"
                chmod 600 "$XRAY_USERS_FILE" "$XRAY_DISABLED_USERS_FILE"
                if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
                    write_xray_config >/dev/null 2>&1 && systemctl restart xray 2>/dev/null || warn "Xray config не пересобран после возврата $target"
                fi
                restored=1
                ok "Xray пользователь $target снова активен"
            else
                warn "Xray UUID отключенного пользователя повреждён"
            fi
        fi
    fi

    [[ "$restored" -eq 1 ]] || { err "Пользователь $target не найден в отключенных"; return 1; }
    if user_is_expired "$target"; then
        warn "Пользователь $target восстановлен, но срок истёк: $(user_expiry_label "$target")"
    else
        generate_subscription_page "$target" >/dev/null 2>&1 || true
    fi
}

cmd_devices_scan() {
    load_config
    load_users

    local limit="${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}"
    local window="${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}"
    local mode="${DEVICE_LIMIT_MODE:-alert}"
    local enabled="${DEVICE_LIMIT_ENABLED:-0}"

    if ! [[ "$limit" =~ ^[0-9]+$ ]] || [[ "$limit" -lt 1 ]]; then limit="$DEVICE_LIMIT_DEFAULT"; fi
    if ! [[ "$window" =~ ^[0-9]+$ ]] || [[ "$window" -lt 1 ]]; then window="$DEVICE_WINDOW_HOURS_DEFAULT"; fi
    [[ "$mode" == "lock-user" ]] || mode="alert"

    local report_file
    report_file=$(mktemp)
    trap 'rm -f "${report_file:-}" 2>/dev/null; trap - RETURN' RETURN

    if ! device_usage_report "$window" > "$report_file"; then
        warn "Логи Yurich Panel не найдены: ${LOG_DIR}/naive.log"
        return 1
    fi

    hr
    echo -e "${BOLD}  Лимит устройств подписка${RESET}"
    hr
    echo -e "  Лимит: ${CYAN}${limit}${RESET} уникальных IP за ${CYAN}${window}${RESET} ч"
    echo -e "  Режим: ${CYAN}${mode}${RESET}  |  Авто: ${CYAN}${enabled}${RESET}"
    echo
    printf '  %-24s %-8s %s\n' "Пользователь" "IP" "Адреса"
    printf '  %-24s %-8s %s\n' "------------" "--" "------"

    local user count ips exceeded=0
    if [[ ! -s "$report_file" ]]; then
        warn "В окне ${window} ч нет CONNECT-записей с user_id"
        return 0
    fi

    while IFS=$'\t' read -r user count ips; do
        printf '  %-24s %-8s %s\n' "$user" "$count" "$ips"
        if [[ "$count" =~ ^[0-9]+$ ]] && [[ "$count" -gt "$limit" ]]; then
            exceeded=$((exceeded+1))
            warn "Превышение: $user использует $count IP при лимите $limit"
            tg_send "⚠️ <b>подписка: превышен лимит устройств</b>
👤 Пользователь: <code>${user}</code>
📱 IP за ${window} ч: <b>${count}</b> / лимит <b>${limit}</b>
🔒 Режим: <code>${mode}</code>"
            if [[ "$enabled" == "1" && "$mode" == "lock-user" ]]; then
                device_disable_user "$user" || true
            fi
        fi
    done < "$report_file"

    echo
    if [[ "$exceeded" -eq 0 ]]; then
        ok "Превышений нет"
    elif [[ "$enabled" != "1" ]]; then
        warn "Автолимит выключен. Это только отчёт."
    fi
}

cmd_devices_config() {
    load_config
    hr
    echo -e "${BOLD}  Настройка лимита устройств${RESET}"
    hr
    echo -e "  Текущий лимит: ${CYAN}${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}${RESET}"
    echo -e "  Окно анализа: ${CYAN}${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}${RESET} ч"
    echo -e "  Режим:        ${CYAN}${DEVICE_LIMIT_MODE:-alert}${RESET}"
    echo

    local ans
    echo -ne "${CYAN}Лимит IP на пользователя [${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}]: ${RESET}"
    read -r ans
    DEVICE_LIMIT="${ans:-${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}}"
    if ! [[ "$DEVICE_LIMIT" =~ ^[0-9]+$ ]] || [[ "$DEVICE_LIMIT" -lt 1 ]] || [[ "$DEVICE_LIMIT" -gt 50 ]]; then
        err "Лимит должен быть числом 1-50"
        return 1
    fi

    echo -ne "${CYAN}Окно анализа, часов [${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}]: ${RESET}"
    read -r ans
    DEVICE_WINDOW_HOURS="${ans:-${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}}"
    if ! [[ "$DEVICE_WINDOW_HOURS" =~ ^[0-9]+$ ]] || [[ "$DEVICE_WINDOW_HOURS" -lt 1 ]] || [[ "$DEVICE_WINDOW_HOURS" -gt 168 ]]; then
        err "Окно должно быть числом 1-168 часов"
        return 1
    fi

    echo -e "${CYAN}Режим:${RESET}"
    echo -e "  1) alert — только предупреждать"
    echo -e "  2) lock-user — отключать пользователя при превышении"
    echo -ne "${CYAN}Выбор [1]: ${RESET}"
    read -r ans
    case "${ans:-1}" in
        1) DEVICE_LIMIT_MODE="alert" ;;
        2) DEVICE_LIMIT_MODE="lock-user" ;;
        *) err "Неверный режим"; return 1 ;;
    esac

    DEVICE_LIMIT_ENABLED="1"
    save_config
    write_device_cron
    ok "Лимит устройств включён"
}

cmd_devices_disable() {
    load_config
    DEVICE_LIMIT_ENABLED="0"
    save_config
    write_device_cron
}

cmd_devices_unlock_all() {
    load_config
    load_users
    local users_file restored=0 user tmp
    tmp=$(mktemp)
    for users_file in "$DISABLED_USERS_FILE" "$XRAY_DISABLED_USERS_FILE"; do
        [[ -s "$users_file" ]] || continue
        awk -F: 'NF && $1 !~ /^#/ {print $1}' "$users_file" >> "$tmp"
    done
    if [[ ! -s "$tmp" ]]; then
        rm -f "$tmp"
        ok "Отключенных пользователей нет"
        return 0
    fi
    sort -u "$tmp" | while IFS= read -r user; do
        [[ -n "$user" ]] || continue
        device_enable_user "$user" && restored=$((restored + 1)) || true
    done
    rm -f "$tmp"
    sync_hysteria_users_if_active >/dev/null 2>&1 || true
    cmd_nodes_rebuild_subscriptions >/dev/null 2>&1 || true
    ok "Восстановление отключенных пользователей завершено"
}

cmd_devices_menu() {
    while true; do
        load_config
        hr
        echo -e "${BOLD}  Лимит устройств / анти-шаринг${RESET}"
        hr
        echo -e "  ${BOLD}1)${RESET} Отчёт и проверка сейчас"
        echo -e "  ${BOLD}2)${RESET} Настроить и включить"
        echo -e "  ${BOLD}3)${RESET} Отключить автолимит"
        echo -e "  ${BOLD}4)${RESET} Отключить пользователя вручную"
        echo -e "  ${BOLD}5)${RESET} Вернуть отключенного пользователя"
        echo -e "  ${BOLD}6)${RESET} Список отключенных"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -e "  Авто: ${CYAN}${DEVICE_LIMIT_ENABLED:-0}${RESET} | Лимит: ${CYAN}${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}${RESET} | Окно: ${CYAN}${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}ч${RESET} | Режим: ${CYAN}${DEVICE_LIMIT_MODE:-alert}${RESET}"
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice
        case "$choice" in
            1) cmd_devices_scan ;;
            2) cmd_devices_config ;;
            3) cmd_devices_disable ;;
            4)
                echo -ne "${CYAN}Логин: ${RESET}"; read -r u
                device_disable_user "$u"
                ;;
            5)
                echo -ne "${CYAN}Логин: ${RESET}"; read -r u
                device_enable_user "$u"
                ;;
            6)
                local shown=0
                if [[ -s "$DISABLED_USERS_FILE" ]]; then
                    echo -e "  ${BOLD}Naive:${RESET}"
                    awk -F: '{print "  • " $1}' "$DISABLED_USERS_FILE"
                    shown=1
                fi
                if [[ -s "$XRAY_DISABLED_USERS_FILE" ]]; then
                    echo -e "  ${BOLD}Xray:${RESET}"
                    awk -F: '{print "  • " $1}' "$XRAY_DISABLED_USERS_FILE"
                    shown=1
                fi
                [[ "$shown" -eq 0 ]] && warn "Отключенных пользователей нет"
                ;;
            0) return ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
}

# ─── МОНИТОРИНГ ──────────────────────────────────────────────
cmd_monitor() {
    hr
    echo -e "${BOLD}  Мониторинг и статистика${RESET}"
    hr

    if systemctl is-active --quiet caddy 2>/dev/null; then
        echo -e "  Caddy:     ${GREEN}● работает${RESET}"
    else
        echo -e "  Caddy:     ${RED}● остановлен${RESET}"
    fi

    local uptime_str
    uptime_str=$(systemctl show caddy --property=ActiveEnterTimestamp 2>/dev/null \
        | cut -d= -f2 | xargs -I{} date -d "{}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "н/д")
    echo -e "  Запущен:   $uptime_str"
    echo -e "  Caddy:     $("$CADDY_BIN" version 2>/dev/null | head -1 | awk '{print $1}' || echo н/д)"
    echo -e "  Юзеров:    $(get_users | wc -l)"

    local iface
    iface=$(ip route | awk '/default/{print $5}' | head -1)
    if [[ -n "$iface" ]]; then
        local rx tx
        rx=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)
        tx=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null || echo 0)
        echo
        echo -e "  ${BOLD}Трафик ($iface, с ребута):${RESET}"
        echo -e "  ⬇ Входящий:  $(numfmt --to=iec "$rx" 2>/dev/null || echo $rx)"
        echo -e "  TX: $(numfmt --to=iec "$tx" 2>/dev/null || echo $tx)"
    fi

    echo
    echo -e "  ${BOLD}Ресурсы:${RESET}"
    echo -e "  RAM:    $(free -h | awk '/Mem:/{print $3" / "$2}')"
    echo -e "  Диск:   $(df -h / | awk 'NR==2{print $3" / "$2" ("$5")"}')"
    echo -e "  Uptime: $(uptime -p)"

    if edge_routing_mode_is_haproxy; then
        echo
        echo -e "  ${BOLD}HAProxy SNI mux:${RESET}"
        haproxy_stats_text | sed 's/^/  /' || true
    fi

    load_config
    if [[ -n "${DOMAIN:-}" ]]; then
        echo
        info "Проверяю доступность https://${DOMAIN}..."
        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://${DOMAIN}" 2>/dev/null || echo "000")
        if [[ "$http_code" =~ ^[23] ]]; then
            ok "https://${DOMAIN} доступен (HTTP $http_code)"
        else
            warn "https://${DOMAIN} — HTTP $http_code"
        fi
        check_cert "${DOMAIN:-}"
    fi

    echo
    echo -ne "${YELLOW}Отправить статистику в Telegram? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] && tg_send_stats && ok "Отправлено в Telegram"
    hr
}

# ─── УСТАНОВКА ───────────────────────────────────────────────
cmd_install() {
    hr
    echo -e "${BOLD}  Установка Yurich Panel v${VERSION}${RESET}"
    hr

    if check_installed; then
        warn "Yurich Panel уже установлен."
        echo -ne "${YELLOW}Переустановить? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || return
    fi

    # ── Шаг 0: Обновление системы ────────────────────────────
    if [[ ! -f "$SYSUPDATE_DONE" ]]; then
        echo -ne "${YELLOW}Обновить систему перед установкой? [Y/n]: ${RESET}"
        read -r ans
        [[ "${ans,,}" != "n" ]] && cmd_sysupdate
    else
        info "Система уже обновлялась: $(cat "$SYSUPDATE_DONE")"
    fi

    # ── Шаг 1: SSH Hardening ─────────────────────────────────
    if [[ ! -f "$SSH_HARDENING_DONE" ]]; then
        warn "SSH Hardening может сменить порт и правила входа. По умолчанию пропускаю, чтобы не потерять SSH."
        echo -ne "${YELLOW}Выполнить SSH Hardening сейчас? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] && cmd_ssh_hardening
    else
        info "SSH уже настроен: $(grep SSH_PORT "$SSH_HARDENING_DONE" | cut -d= -f2)"
    fi

    prompt_params
    prompt_edge_routing_mode || return 1
    check_domain "$DOMAIN"
    install_deps
    build_caddy
    write_caddyfile
    write_service
    setup_firewall
    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        setup_fail2ban "$(current_ssh_port)" || warn "Fail2Ban уже установлен, но автонастройка не прошла"
    else
        echo -ne "${YELLOW}Включить Fail2Ban защиту SSH + Caddy auth? [Y/n]: ${RESET}"
        read -r ans
        [[ "${ans,,}" != "n" ]] && setup_fail2ban "$(current_ssh_port)"
    fi
    enable_bbr

    echo
    echo -ne "${YELLOW}Настроить Telegram-уведомления? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] && setup_telegram

    save_config
    install_monitor

    info "Запускаю Caddy..."
    systemctl restart caddy
    sleep 3

    if systemctl is-active --quiet caddy; then
        ok "Caddy запущен успешно"
        tg_alert_up
    else
        err "Caddy не запустился. Лог:"
        journalctl -u caddy -n 30 --no-pager
        exit 1
    fi

    if edge_routing_mode_is_haproxy; then
        apply_haproxy_sni_mux_runtime || exit 1
    fi

    print_client_config
    cmd_health_check
}


# ─── ПРОВЕРКА СЕРТИФИКАТА ─────────────────────────────────────
check_cert() {
    local domain="${1:-${DOMAIN:-}}"
    [[ -z "$domain" ]] && return

    echo
    echo -e "  ${BOLD}TLS Сертификат:${RESET}"

    local cert_info
    cert_info=$(echo | timeout 5 openssl s_client -connect "${domain}:443"         -servername "$domain" 2>/dev/null | openssl x509 -noout         -dates -issuer -subject 2>/dev/null || echo "")

    if [[ -z "$cert_info" ]]; then
        warn "Не удалось получить данные сертификата"
        return
    fi

    local not_after issuer
    not_after=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
    issuer=$(echo "$cert_info" | grep "issuer" | grep -oP "O=\K[^,]+" || echo "н/д")

    # Считаем дней до истечения
    local expire_ts now_ts days_left
    expire_ts=$(date -d "$not_after" +%s 2>/dev/null || echo 0)
    now_ts=$(date +%s)
    days_left=$(( (expire_ts - now_ts) / 86400 ))

    # Цвет в зависимости от срока
    local days_color
    if [[ $days_left -gt 30 ]]; then
        days_color="${GREEN}"
    elif [[ $days_left -gt 7 ]]; then
        days_color="${YELLOW}"
    else
        days_color="${RED}"
    fi

    echo -e "  Домен:     ${CYAN}${domain}${RESET}"
    echo -e "  Истекает:  ${not_after}"
    echo -e "  Осталось:  ${days_color}${days_left} дней${RESET}"
    echo -e "  Выдан:     ${issuer}"

    if [[ $days_left -le 7 ]]; then
        err "СЕРТИФИКАТ ИСТЕКАЕТ МЕНЕЕ ЧЕМ ЧЕРЕЗ 7 ДНЕЙ!"
        tg_send "⚠️ <b>Сертификат истекает!</b>
🌐 Домен: <code>${domain}</code>
📅 Осталось: <b>${days_left} дней</b>
🕐 $(date '+%Y-%m-%d %H:%M:%S')
🔧 Caddy обновит автоматически — проверь что он запущен!"
    elif [[ $days_left -le 30 ]]; then
        warn "Сертификат истекает через ${days_left} дней — Caddy обновит автоматически"
    else
        ok "Сертификат действителен ещё ${days_left} дней"
    fi
}


# ══════════════════════════════════════════════════════════════
#   SELF-UPDATE СКРИПТА
# ══════════════════════════════════════════════════════════════

cmd_self_update() {
    hr
    echo -e "${BOLD}  Обновление скрипта Yurich Panel${RESET}"
    hr

    info "Текущая версия: ${BOLD}v${VERSION}${RESET}"
    info "Проверяю последнюю версию на GitHub..."

    # Получаем последнюю версию из GitHub Releases и raw-файла.
    # Raw важен, потому что проект часто обновляется обычным push в main без release.
    local latest_ver api_ver raw_ver
    api_ver=$(curl -s --max-time 10 "$GITHUB_API" 2>/dev/null         | grep '"tag_name"'         | grep -oP '"\K[^"]+'         | head -1         | tr -d 'v' || echo "")
    raw_ver=$(curl -s --max-time 10 "$GITHUB_RAW" 2>/dev/null             | grep '^VERSION='             | grep -oP '"\K[^"]+' || echo "")

    latest_ver="$api_ver"
    if [[ -n "$raw_ver" ]]; then
        if [[ -z "$latest_ver" ]] || version_gt "$raw_ver" "$latest_ver"; then
            latest_ver="$raw_ver"
        fi
    fi

    if [[ -z "$latest_ver" ]]; then
        err "Не удалось получить версию с GitHub. Проверь интернет."
        return 1
    fi

    info "Последняя версия: ${BOLD}v${latest_ver}${RESET}"

    if [[ "$latest_ver" == "$VERSION" ]]; then
        ok "У тебя уже последняя версия v${VERSION}"
        return 0
    fi

    echo
    echo -e "  ${YELLOW}Доступно обновление: v${VERSION} → v${latest_ver}${RESET}"
    echo -ne "${CYAN}Обновить? [Y/n]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "n" ]] && return 0

    # Скачиваем новую версию во временный файл
    local tmp_script tmp_sha expected_sha actual_sha
    tmp_script=$(mktemp /tmp/naiveproxy_update_XXXXXX.sh)
    tmp_sha=$(mktemp /tmp/naiveproxy_update_sha_XXXXXX)
    # Cleanup при любом выходе из функции
    trap 'rm -f "${tmp_script:-}" "${tmp_sha:-}" 2>/dev/null' RETURN

    info "Скачиваю v${latest_ver}..."
    if ! curl -fsSL --max-time 60 "$GITHUB_RAW" -o "$tmp_script" 2>/dev/null; then
        err "Ошибка загрузки скрипта"
        rm -f "$tmp_script"
        return 1
    fi

    info "Проверяю SHA256 релиза..."
    if curl -fsSL --max-time 20 "$GITHUB_SHA256_RAW" -o "$tmp_sha" 2>/dev/null; then
        expected_sha=$(awk '{print $1; exit}' "$tmp_sha" | tr -d '\r\n')
        actual_sha=$(sha256sum "$tmp_script" | awk '{print $1}')
        if [[ ! "$expected_sha" =~ ^[a-fA-F0-9]{64}$ ]]; then
            warn "Файл SHA256 найден, но формат некорректный"
            [[ "${NAIVEPROXY_REQUIRE_SHA:-1}" == "1" ]] && return 1
        elif [[ "$actual_sha" != "$expected_sha" ]]; then
            err "SHA256 не совпадает. Обновление остановлено."
            echo "  expected: $expected_sha"
            echo "  actual:   $actual_sha"
            return 1
        else
            ok "SHA256 релиза подтверждён"
        fi
    else
        warn "SHA256 файл релиза не найден. Для аварийного обхода: NAIVEPROXY_REQUIRE_SHA=0"
        [[ "${NAIVEPROXY_REQUIRE_SHA:-1}" == "1" ]] && return 1
    fi

    # Проверяем что скачали валидный bash скрипт
    if ! bash -n "$tmp_script" 2>/dev/null; then
        err "Скачанный скрипт содержит ошибки синтаксиса! Отменяю обновление."
        rm -f "$tmp_script"
        return 1
    fi

    # Проверяем что это действительно наш скрипт; второй маркер нужен только для совместимости старых self-update.
    if ! grep -Eq "Yurich Panel|NaiveProxy Manager" "$tmp_script" 2>/dev/null; then
        err "Скачанный файл не является Yurich Panel. Отменяю."
        rm -f "$tmp_script"
        return 1
    fi

    # Определяем куда установлен скрипт
    local current_script
    current_script=$(realpath "$0" 2>/dev/null || echo "")
    if [[ -z "$current_script" || "$current_script" == /dev/fd/* || "$current_script" == /proc/* ]]; then
        current_script="$SCRIPT_PATH"
    fi

    # Бэкап текущей версии
    local backup_path="${current_script}.v${VERSION}.bak"
    cp "$current_script" "$backup_path" 2>/dev/null || true
    ok "Бэкап текущей версии: $backup_path"

    # Устанавливаем новую версию
    chmod +x "$tmp_script"
    mv "$tmp_script" "$current_script"
    chmod +x "$current_script"

    # Обновляем основной путь и legacy alias, чтобы старые установки не ломались.
    if [[ "$current_script" != "$SCRIPT_PATH" ]]; then
        cp "$current_script" "$SCRIPT_PATH" 2>/dev/null || true
        chmod +x "$SCRIPT_PATH" 2>/dev/null || true
    fi
    if [[ -n "${LEGACY_SCRIPT_PATH:-}" && "$current_script" != "$LEGACY_SCRIPT_PATH" ]]; then
        cp "$current_script" "$LEGACY_SCRIPT_PATH" 2>/dev/null || true
        chmod +x "$LEGACY_SCRIPT_PATH" 2>/dev/null || true
    fi

    ok "Скрипт обновлён: v${VERSION} → v${latest_ver}"
    tg_send "🔄 <b>Yurich Panel обновлён</b>
📦 Было: <code>v${VERSION}</code>
📦 Стало: <code>v${latest_ver}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"

    echo
    info "Перезапускаю обновлённый скрипт..."
    sleep 1
    local restart_script="$current_script"
    if [[ -n "${LEGACY_SCRIPT_PATH:-}" && "$current_script" == "$LEGACY_SCRIPT_PATH" ]]; then
        restart_script="$SCRIPT_PATH"
    fi
    exec bash "$restart_script"
}

# ── Тихая проверка обновлений при запуске ─────────────────────
check_update_available() {
    # Запускаем в фоне чтобы не тормозить старт
    (
        local latest_ver
        latest_ver=$(curl -s --max-time 5 "$GITHUB_RAW" 2>/dev/null             | grep '^VERSION='             | grep -oP '"\K[^"]+' || echo "")
        if [[ -n "$latest_ver" && "$latest_ver" != "$VERSION" ]]; then
            echo -e "\n  ${YELLOW}[UPDATE] Доступно обновление скрипта: v${VERSION} → v${latest_ver}${RESET}"
            echo -e "  ${YELLOW}   Меню → 14) Обновить скрипт${RESET}\n"
        fi
    ) &
}


# ─── ДИАГНОСТИКА СИСТЕМЫ ──────────────────────────────────────
cmd_diagnose_fix() {
    load_config 2>/dev/null || true
    load_users 2>/dev/null || true
    hr
    echo -e "${BOLD}  [FIX] Автофикс Yurich Panel${RESET}"
    hr

    local changed=0

    mkdir -p "$CONFIG_DIR" "$CADDY_DIR" "$LOG_DIR" "$WEBROOT" 2>/dev/null || true
    ensure_web_privacy_files 2>/dev/null || true
    [[ -f "$CONFIG_FILE" ]] && chown root:root "$CONFIG_FILE" 2>/dev/null || true
    [[ -f "$CONFIG_FILE" ]] && chmod 600 "$CONFIG_FILE" 2>/dev/null || true
    [[ -f "$USERS_FILE" ]] && chown root:root "$USERS_FILE" 2>/dev/null || true
    [[ -f "$USERS_FILE" ]] && chmod 600 "$USERS_FILE" 2>/dev/null || true
    [[ -f "$XRAY_USERS_FILE" ]] && chmod 600 "$XRAY_USERS_FILE" 2>/dev/null || true
    [[ -f "$XRAY_COMPAT_USERS_FILE" ]] && chmod 600 "$XRAY_COMPAT_USERS_FILE" 2>/dev/null || true

    if [[ -n "${DOMAIN:-}" && -f "$USERS_FILE" && "$(active_user_count)" -gt 0 ]]; then
        info "Перегенерирую Caddyfile по текущему режиму..."
        if rewrite_caddyfile_current; then
            changed=1
        else
            warn "Caddyfile не удалось перегенерировать"
        fi
    else
        warn "Caddyfile не генерирую: не задан DOMAIN или нет активных пользователей"
    fi

    if [[ -x "$CADDY_BIN" && -f "$CADDYFILE" ]]; then
        if "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1; then
            if systemctl is-active caddy >/dev/null 2>&1; then
                systemctl reload caddy >/dev/null 2>&1 || systemctl restart caddy >/dev/null 2>&1 || true
            else
                systemctl restart caddy >/dev/null 2>&1 || true
            fi
            ok "Caddy validate/start/reload выполнен"
        else
            err "Caddyfile всё ещё невалиден: caddy validate --config $CADDYFILE"
        fi
    else
        warn "Caddy binary или Caddyfile отсутствует. Если модуль forward_proxy пропал — запусти: sudo bash yurich-panel.sh update"
    fi

    if command -v ufw >/dev/null 2>&1; then
        setup_firewall || true
        [[ -n "${HYSTERIA_PORT:-}" ]] && ufw allow "${HYSTERIA_PORT}/udp" comment "Hysteria2 QUIC" >/dev/null 2>&1 || true
        apply_hysteria_port_hop || true
        if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
            apply_xray_reality_firewall
            cleanup_xray_legacy_transports
        fi
        ok "UFW правила проверены/обновлены"
    else
        apt-get update -qq && apt-get install -y -q ufw && setup_firewall || warn "Не удалось установить/настроить UFW"
    fi

    if [[ "${DEVICE_LIMIT_ENABLED:-0}" == "1" ]]; then
        write_device_cron
    fi

    if command -v fail2ban-client >/dev/null 2>&1; then
        systemctl restart fail2ban >/dev/null 2>&1 || true
    fi

    if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        if "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1; then
            systemctl restart xray >/dev/null 2>&1 || true
            ok "Xray config валиден, сервис перезапущен"
        else
            warn "Xray config невалиден. Попробуй: sudo bash yurich-panel.sh xray-install"
        fi
    fi

    if [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]] && command -v warp-cli >/dev/null 2>&1; then
        systemctl enable --now warp-svc >/dev/null 2>&1 || systemctl enable --now cloudflare-warp >/dev/null 2>&1 || true
        warp_cli connect >/dev/null 2>&1 || true
    fi

    systemctl daemon-reload >/dev/null 2>&1 || true
    ok "Автофикс завершён"
    [[ "$changed" -eq 1 ]] && info "После автофикса можно проверить: sudo bash yurich-panel.sh diagnose"
}

cmd_diagnose() {
    if [[ "${1:-}" == "--fix" || "${1:-}" == "fix" ]]; then
        cmd_diagnose_fix
        return
    fi

    load_config 2>/dev/null || true

    local pass=0 warn=0 fail=0
    local report=""

    # Хелперы вывода — используем pass+=1 вместо pass=$((pass+1)) из-за set -e
    _ok()   { echo -e "  ${GREEN}[OK] $1${RESET}";   report+="[OK] $1\n"; pass=$((pass+1)); }
    _warn() { echo -e "  ${YELLOW}[WARN] $1${RESET}"; report+="[WARN] $1\n"; warn=$((warn+1)); }
    _fail() { echo -e "  ${RED}[FAIL] $1${RESET}";    report+="[FAIL] $1\n"; fail=$((fail+1)); }
    _info() { echo -e "  ${CYAN}[INFO] $1${RESET}"; }
    _sep()  { echo -e "  ${DIM}──────────────────────────────────────${RESET}"; }

    hr
    echo -e "${BOLD}  [DIAG] Диагностика Yurich Panel v${VERSION}${RESET}"
    echo -e "  $(date '+%Y-%m-%d %H:%M:%S') · $(hostname)"
    hr
    echo

    # ── БЛОК 1: CADDY ─────────────────────────────────────────
    echo -e "  ${BOLD}[1/7] Caddy${RESET}"
    _sep

    # Caddy существует
    if [[ -f "${CADDY_BIN}" ]]; then
        local caddy_ver
        caddy_ver=$("${CADDY_BIN}" version 2>/dev/null | head -1 || echo "неизвестно")
        _ok "Caddy найден: ${caddy_ver}"
    else
        _fail "Caddy не найден: ${CADDY_BIN}"
    fi

    # Caddy запущен
    if systemctl is-active caddy &>/dev/null; then
        local uptime_caddy
        uptime_caddy=$(systemctl show caddy --property=ActiveEnterTimestamp             | cut -d= -f2 | xargs -I{} date -d "{}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "н/д")
        _ok "Caddy запущен (с ${uptime_caddy})"
    else
        _fail "Caddy НЕ запущен! Запусти: systemctl start caddy"
    fi

    # Naive padding в бинарнике
    if ! command -v strings &>/dev/null; then
        info "Устанавливаю binutils для проверки padding..."
        apt-get install -y -q binutils 2>/dev/null || true
    fi
    if command -v strings &>/dev/null && [[ -f "${CADDY_BIN}" ]]; then
        # Проверяем naive padding по нескольким признакам
        local _pad_count
        _pad_count=$(strings "${CADDY_BIN}" 2>/dev/null | grep -cE "^(Padding|SetPadding|WithPadding|writePadding|PaddingLength)$" || true)
        _pad_count="${_pad_count//[^0-9]/}"
        _pad_count="${_pad_count:-0}"
        if [[ "${_pad_count}" -ge 2 ]]; then
            _ok "Naive padding модуль подтверждён (${_pad_count} символов)"
        else
            _fail "Naive padding НЕ найден в Caddy — пересобери: sudo bash yurich-panel.sh update"
        fi
    else
        _warn "strings недоступен — установи: apt install binutils"
    fi

    # forward_proxy модуль
    if "${CADDY_BIN}" list-modules 2>/dev/null | grep "forward_proxy" >/dev/null; then
        _ok "Модуль forward_proxy загружен"
    else
        _fail "Модуль forward_proxy НЕ найден"
    fi

    echo

    # ── БЛОК 2: CADDYFILE ─────────────────────────────────────
    echo -e "  ${BOLD}[2/7] Конфигурация${RESET}"
    _sep

    if [[ -f "${CADDYFILE}" ]]; then
        _ok "Caddyfile найден: ${CADDYFILE}"

        # Naive CONNECT uses the target host in :authority, so the proxy block needs :443 catch-all.
        if grep -q "^:443," "${CADDYFILE}"; then
            _ok "Caddyfile: Naive forward proxy catch-all ':443, domain'"
        elif edge_routing_mode_is_haproxy && grep -q "^:${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}," "${CADDYFILE}"; then
            _ok "Caddyfile: HAProxy fallback port ${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
        elif grep -qE "^http://127\\.0\\.0\\.1:[0-9]+" "${CADDYFILE}"; then
            _ok "Caddyfile: Xray fallback mode"
        elif grep -qE "^[[:alnum:].-]+:443[[:space:]]*\\{" "${CADDYFILE}"; then
            _warn "Caddyfile: 'domain:443' может ломать Naive CONNECT — перегенерируй через safe-apply"
        else
            _warn "Caddyfile: не распознал site label"
        fi

        local hosts_overrides hosts_domains
        hosts_overrides=$(hosts_public_domain_overrides | head -5 || true)
        if [[ -n "$hosts_overrides" ]]; then
            hosts_domains=$(printf '%s\n' "$hosts_overrides" | format_hosts_override_domains)
            _warn "/etc/hosts подменяет публичные домены: ${hosts_domains}"
        else
            _ok "/etc/hosts не подменяет публичные домены"
        fi

        # order forward_proxy
        if grep -q "order forward_proxy before file_server" "${CADDYFILE}"; then
            _ok "Caddyfile: order forward_proxy — OK"
        else
            _warn "Caddyfile: отсутствует 'order forward_proxy before file_server'"
        fi

        # probe_resistance
        if grep -q "probe_resistance" "${CADDYFILE}"; then
            _ok "probe_resistance включён"
        else
            _warn "probe_resistance отключён — сервер видим для сканеров"
        fi

        # Пользователи
        local user_count=0
        [[ -f "${USERS_FILE}" ]] && user_count=$(get_users | wc -l)
        if [[ ${user_count} -gt 0 ]]; then
            _ok "Пользователей: ${user_count}"
        else
            _fail "Нет пользователей! Добавь: sudo bash yurich-panel.sh users"
        fi

        # Caddy validate
        if "${CADDY_BIN}" validate --config "${CADDYFILE}" &>/dev/null; then
            _ok "Caddyfile валиден (caddy validate passed)"
        else
            _fail "Ошибка в Caddyfile! Проверь: caddy validate --config ${CADDYFILE}"
        fi
    else
        _fail "Caddyfile не найден: ${CADDYFILE}"
    fi

    echo

    # ── БЛОК 3: TLS / СЕТЬ ────────────────────────────────────
    echo -e "  ${BOLD}[3/7] TLS и сеть${RESET}"
    _sep

    local domain="${DOMAIN:-}"

    if [[ -z "${domain}" ]]; then
        _warn "Домен не настроен — пропускаю сетевые проверки"
    else
        _info "Домен: ${domain}"

        # DNS → IP
        local dns_ip server_ip
        dns_ip=$(dig +short "${domain}" 2>/dev/null | grep -E '^[0-9]+\.' | head -1 || echo "")
        server_ip=$(curl -s4 --max-time 5 https://ifconfig.me 2>/dev/null                  || curl -s4 --max-time 5 https://api.ipify.org 2>/dev/null || echo "")

        if [[ -z "${dns_ip}" ]]; then
            _fail "DNS не резолвится для ${domain}"
        elif [[ "${dns_ip}" == "${server_ip}" ]]; then
            _ok "DNS: ${domain} → ${dns_ip} (совпадает с IP сервера)"
        else
            _fail "DNS: ${domain} → ${dns_ip} НЕ совпадает с IP сервера ${server_ip}"
        fi

        # Порт 80
        if ss -tlnp | grep -E ":80([[:space:]]|$)" >/dev/null; then
            _ok "Порт 80 слушается (ACME)"
        else
            _warn "Порт 80 не слушается — Let's Encrypt может не работать"
        fi

        # Порт 443
        if ss -tlnp | grep -E ":443([[:space:]]|$)" >/dev/null; then
            _ok "Порт 443 слушается"
        else
            _fail "Порт 443 не слушается!"
        fi

        # ALPN h2
        local alpn
        alpn=$(echo | timeout 8 openssl s_client \
            -connect "${domain}:443" \
            -alpn h2 \
            -servername "${domain}" \
            2>/dev/null | grep -a "ALPN protocol" | awk '{print $3}')
        alpn="${alpn//[^a-z0-9]/}"  # убираем лишние символы
        if [[ "${alpn}" == "h2" ]]; then
            _ok "ALPN: h2 ✓ (HTTP/2 работает)"
        else
            _warn "ALPN: не h2 (получено: '${alpn}') — возможно сервер за NAT или firewall"
        fi

        # TLS сертификат
        local cert_days=0
        local cert_info
        cert_info=$(echo | timeout 8 openssl s_client \
            -connect "${domain}:443" \
            -servername "${domain}" \
            2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "")
        if [[ -n "${cert_info}" ]]; then
            local not_after expire_ts now_ts
            not_after=$(echo "${cert_info}" | grep "notAfter" | cut -d= -f2)
            expire_ts=$(date -d "${not_after}" +%s 2>/dev/null || echo 0)
            now_ts=$(date +%s)
            cert_days=$(( (expire_ts - now_ts) / 86400 ))
            if [[ ${cert_days} -gt 30 ]]; then
                _ok "TLS сертификат действителен ещё ${cert_days} дней"
            elif [[ ${cert_days} -gt 7 ]]; then
                _warn "TLS сертификат истекает через ${cert_days} дней"
            else
                _fail "TLS сертификат истекает через ${cert_days} дней! Срочно!"
            fi
        else
            _fail "Не удалось получить TLS сертификат для ${domain}"
        fi
    fi

    echo

    # ── БЛОК 4: FIREWALL ──────────────────────────────────────
    echo -e "  ${BOLD}[4/7] Firewall${RESET}"
    _sep

    # UFW
    if command -v ufw &>/dev/null; then
        if ufw status | grep -q "Status: active"; then
            _ok "UFW активен"
            # Проверяем нужные порты
            for port in "80/tcp" "443/tcp" "443/udp"; do
                if ufw status | grep -q "${port}"; then
                    _ok "UFW: порт ${port} открыт"
                else
                    _warn "UFW: порт ${port} НЕ открыт"
                fi
            done
        else
            _fail "UFW неактивен! Включи: ufw enable"
        fi
    else
        _warn "UFW не установлен"
    fi

    # Fail2Ban
    if systemctl is-active fail2ban &>/dev/null; then
        local banned_count
        banned_count=$(fail2ban-client status sshd 2>/dev/null             | grep "Currently banned" | awk '{print $NF}' || echo "0")
        _ok "Fail2Ban активен (сейчас забанено SSH: ${banned_count})"
    else
        _warn "Fail2Ban не запущен — SSH не защищён от брутфорса"
    fi

    # DNS / Unbound
    if command -v unbound &>/dev/null; then
        if systemctl is-active --quiet unbound 2>/dev/null; then
            _ok "DNS (Unbound): $(unbound_mode_label), gateway=${UNBOUND_GATEWAY_IP:-127.0.0.1}, vpn=${UNBOUND_VPN_ENABLED:-0}"
        else
            _warn "DNS (Unbound) установлен, но сервис не активен"
        fi
        if [[ -f "${DNS_CONF:-/etc/unbound/unbound.conf.d/yurich-dns.conf}" ]] && unbound-checkconf "${DNS_CONF:-/etc/unbound/unbound.conf.d/yurich-dns.conf}" >/dev/null 2>&1; then
            _ok "Unbound config валиден"
        else
            _warn "Unbound config не найден или содержит ошибку"
        fi
        if command -v dig >/dev/null 2>&1 && dig "@127.0.0.1" google.com +short +time=2 +tries=1 2>/dev/null | grep -Eq '^[0-9a-fA-F:.]+$'; then
            _ok "DNS (Unbound) отвечает на 127.0.0.1:53"
        else
            _warn "DNS (Unbound) test не прошёл"
        fi
    else
        _info "DNS (Unbound) не установлен (меню → 17)"
    fi

    # WARP modes — proxy/full-tunnel
    if command -v warp-cli &>/dev/null; then
        local warp_port warp_trace warp_mode
        warp_port="${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
        warp_mode="${WARP_MODE:-off}"
        if [[ "$warp_mode" == "warp" || "$warp_mode" == "warp+doh" ]]; then
            warp_trace=$(curl -fsSL --connect-timeout 5 --max-time 12 \
                https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null || true)
            if echo "$warp_trace" | grep -q '^warp=on'; then
                _ok "WARP full tunnel: warp=on (${warp_mode}, ${WARP_PROTOCOL:-auto})"
            elif [[ -n "$warp_trace" ]]; then
                _warn "WARP full tunnel не подтвердил warp=on"
            else
                _warn "WARP full tunnel test не прошёл"
            fi
        else
            if ss -tlnp 2>/dev/null | grep -Eq "(127\.0\.0\.1|\*):${warp_port}[[:space:]]|:${warp_port}[[:space:]]"; then
                _ok "WARP proxy слушает локально: 127.0.0.1:${warp_port}"
            else
                _warn "WARP установлен, но локальный proxy порт ${warp_port} не слушается"
            fi

            warp_trace=$(curl -fsSL --connect-timeout 5 --max-time 9 -x "http://127.0.0.1:${warp_port}" \
                https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null || \
                curl -fsSL --connect-timeout 5 --max-time 9 --socks5-hostname "127.0.0.1:${warp_port}" \
                https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null || true)
            if echo "$warp_trace" | grep -q '^warp=on'; then
                _ok "WARP proxy test: warp=on"
            elif [[ -n "$warp_trace" ]]; then
                _warn "WARP proxy отвечает, но trace не показал warp=on — общий IP VPS в proxy mode не меняется"
            else
                _warn "WARP proxy test не прошёл"
            fi
        fi
    else
        _info "WARP не установлен (опционально: меню → 21)"
    fi

    if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
        if systemctl is-active xray &>/dev/null; then
            _ok "Xray: сервис активен"
        else
            _warn "Xray установлен, но сервис не активен"
        fi
        if [[ -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]] && "$XRAY_BIN" run -test -config "$XRAY_CONFIG" >/dev/null 2>&1; then
            _ok "Xray config валиден"
        else
            _warn "Xray config не проверен или содержит ошибку"
        fi
        if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
            if ss -tlnp 2>/dev/null | grep -E ":443([[:space:]]|$)" >/dev/null; then
                _ok "Xray fallback hub: порт 443 слушается"
            else
                _fail "Xray fallback hub включён, но порт 443 не слушается"
            fi
        fi
    else
        _info "Xray Modern не установлен (опционально: меню → 23)"
    fi

    echo

    # ── БЛОК 5: РЕСУРСЫ ───────────────────────────────────────
    echo -e "  ${BOLD}[5/7] Ресурсы системы${RESET}"
    _sep

    # RAM
    local ram_used ram_total ram_pct
    ram_used=$(free -m | awk '/Mem:/{print $3}')
    ram_total=$(free -m | awk '/Mem:/{print $2}')
    ram_pct=$(( ram_used * 100 / ram_total ))
    if [[ ${ram_pct} -lt 80 ]]; then
        _ok "RAM: ${ram_used}/${ram_total} MB (${ram_pct}%)"
    elif [[ ${ram_pct} -lt 95 ]]; then
        _warn "RAM: ${ram_used}/${ram_total} MB (${ram_pct}%) — высокое потребление"
    else
        _fail "RAM: ${ram_used}/${ram_total} MB (${ram_pct}%) — критически мало!"
    fi

    # Диск
    local disk_used disk_total disk_pct
    disk_pct=$(df / | awk 'NR==2{print $5}' | tr -d '%')
    disk_used=$(df -h / | awk 'NR==2{print $3}')
    disk_total=$(df -h / | awk 'NR==2{print $2}')
    if [[ ${disk_pct} -lt 80 ]]; then
        _ok "Диск: ${disk_used}/${disk_total} (${disk_pct}%)"
    elif [[ ${disk_pct} -lt 95 ]]; then
        _warn "Диск: ${disk_used}/${disk_total} (${disk_pct}%) — мало места"
    else
        _fail "Диск: ${disk_used}/${disk_total} (${disk_pct}%) — критически мало!"
    fi

    # Load average
    local load
    load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local cpus
    cpus=$(nproc)
    local load_pct
    load_pct=$(echo "${load} ${cpus}" | awk '{printf "%d", ($1/$2)*100}')
    if [[ ${load_pct} -lt 80 ]]; then
        _ok "Нагрузка CPU: ${load} (${load_pct}% от ${cpus} ядер)"
    else
        _warn "Нагрузка CPU: ${load} (${load_pct}%) — высокая"
    fi

    echo

    # ── БЛОК 6: ЛОГИ ──────────────────────────────────────────
    echo -e "  ${BOLD}[6/7] Анализ логов${RESET}"
    _sep

    local log_errors=0
    if [[ -f "${LOG_DIR}/access.log" ]]; then
        # Считаем ошибки за последние 100 строк
        log_errors=$(tail -100 "${LOG_DIR}/access.log" 2>/dev/null \
            | python3 -c "
import sys,json
errs=0
for line in sys.stdin:
    try:
        d=json.loads(line)
        if d.get('status',200) >= 500: errs+=1
    except: pass
print(errs)
" 2>/dev/null || true)
        log_errors="${log_errors//[^0-9]/}"
        log_errors="${log_errors:-0}"

        local connect_count
        connect_count=$(tail -100 "${LOG_DIR}/access.log" 2>/dev/null \
            | grep -c '"CONNECT"' 2>/dev/null || true)
        connect_count="${connect_count//[^0-9]/}"
        connect_count="${connect_count:-0}"

        if [[ ${log_errors} -eq 0 ]]; then
            _ok "Логи: нет серверных ошибок (последние 100 запросов)"
        else
            _warn "Логи: ${log_errors} ошибок в последних 100 запросах"
        fi
        _info "CONNECT туннелей в последних 100 записях: ${connect_count}"

        if [[ "${DEVICE_LIMIT_ENABLED:-0}" == "1" ]]; then
            local dev_report dev_over
            dev_report=$(mktemp)
            if device_usage_report "${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}" > "$dev_report"; then
                dev_over=$(awk -F'\t' -v limit="${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}" '$2+0 > limit {c++} END{print c+0}' "$dev_report")
                if [[ "$dev_over" -eq 0 ]]; then
                    _ok "Лимит устройств: превышений нет"
                else
                    _warn "Лимит устройств: пользователей с превышением: ${dev_over}"
                fi
            else
                _warn "Лимит устройств включён, но naive.log не найден"
            fi
            rm -f "$dev_report"
        else
            _info "Лимит устройств выключен (опционально: меню → 22)"
        fi
    else
        _warn "Лог файл не найден: ${LOG_DIR}/access.log"
    fi

    # Ошибки Caddy в journald
    local caddy_errors
    caddy_errors=$(journalctl -u caddy -n 50 --no-pager 2>/dev/null \
        | grep -ci "error\|panic\|fatal" 2>/dev/null || true)
    caddy_errors="${caddy_errors//[^0-9]/}"  # оставляем только цифры
    caddy_errors="${caddy_errors:-0}"
    if [[ "${caddy_errors}" -eq 0 ]]; then
        _ok "journald: нет критических ошибок Caddy"
    else
        _warn "journald: найдено ${caddy_errors} строк с ошибками — проверь: journalctl -u caddy -n 50"
    fi

    echo

    # ── БЛОК 7: ВЕРСИЯ И ОБНОВЛЕНИЯ ───────────────────────────
    echo -e "  ${BOLD}[7/7] Версия и обновления${RESET}"
    _sep

    _info "Текущая версия скрипта: v${VERSION}"

    local latest_ver
    latest_ver=$(curl -s --max-time 8 "${GITHUB_RAW}" 2>/dev/null         | grep '^VERSION=' | grep -oP '"\K[^"]+' || echo "")

    if [[ -n "${latest_ver}" ]]; then
        if [[ "${latest_ver}" == "${VERSION}" ]]; then
            _ok "Скрипт актуален: v${VERSION}"
        else
            _warn "Доступно обновление: v${VERSION} → v${latest_ver} (меню → 14)"
        fi
    else
        _warn "Не удалось проверить обновления"
    fi

    # SSH Hardening выполнен?
    if [[ -f "${SSH_HARDENING_DONE}" ]]; then
        local ssh_port_saved
        ssh_port_saved=$(grep SSH_PORT "${SSH_HARDENING_DONE}" 2>/dev/null | cut -d= -f2 || echo "н/д")
        _ok "SSH Hardening выполнен (порт: ${ssh_port_saved})"
    else
        _warn "SSH Hardening не выполнен — рекомендуется: меню → 12"
    fi

    # ── ИТОГ ──────────────────────────────────────────────────
    echo
    hr
    echo -e "  ${BOLD}[SUMMARY] ИТОГ ДИАГНОСТИКИ${RESET}"
    hr
    echo -e "  ${GREEN}[OK] Пройдено:  ${pass}${RESET}"
    echo -e "  ${YELLOW}[WARN] Внимание: ${warn}${RESET}"
    echo -e "  ${RED}[FAIL] Проблемы: ${fail}${RESET}"
    echo

    if [[ ${fail} -eq 0 && ${warn} -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}[OK] Всё работает отлично!${RESET}"
    elif [[ ${fail} -eq 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}[WARN] Есть предупреждения — рекомендуется проверить${RESET}"
    else
        echo -e "  ${RED}${BOLD}[FAIL] Найдены проблемы — требуется вмешательство${RESET}"
    fi

    hr

    # Отправляем отчёт в Telegram если настроен
    echo -ne "\n${YELLOW}Отправить отчёт в Telegram? [y/N]: ${RESET}"
    read -r ans
    if [[ "${ans,,}" == "y" ]]; then
        tg_send "🔍 <b>Диагностика Yurich Panel</b>
🖥 Сервер: <code>$(hostname)</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

${report}
✅ Пройдено: ${pass}  ⚠️ Внимание: ${warn}  ❌ Проблемы: ${fail}"
        ok "Отчёт отправлен в Telegram"
    fi
}


# ══════════════════════════════════════════════════════════════
#   TELEGRAM BOT — ИНТЕРАКТИВНОЕ УПРАВЛЕНИЕ
# ══════════════════════════════════════════════════════════════

# Проверка что пользователь является администратором
tg_is_admin() {
    local from_id="$1"
    # Валидация: from_id должен быть числом
    [[ ! "${from_id}" =~ ^[0-9]+$ ]] && return 1
    # Основной admin
    [[ -n "${TG_CHAT_ID:-}" && "${from_id}" == "${TG_CHAT_ID}" ]] && return 0
    # Дополнительные admins
    if [[ -n "${TG_ADMINS:-}" ]]; then
        local IFS=','
        for admin_id in ${TG_ADMINS}; do
            admin_id="${admin_id// /}"
            [[ "${from_id}" == "${admin_id}" ]] && return 0
        done
    fi
    return 1
}

tg_admin_ids() {
    local admin_id
    if [[ -n "${TG_CHAT_ID:-}" && "${TG_CHAT_ID}" =~ ^[0-9]+$ ]]; then
        printf '%s\n' "$TG_CHAT_ID"
    fi
    if [[ -n "${TG_ADMINS:-}" ]]; then
        local IFS=','
        for admin_id in ${TG_ADMINS}; do
            admin_id="${admin_id// /}"
            [[ "$admin_id" =~ ^[0-9]+$ ]] && printf '%s\n' "$admin_id"
        done
    fi
}

# Отправка сообщения конкретному chat_id
tg_reply() {
    local chat_id="$1"
    local message="$2"
    [[ -z "${TG_TOKEN:-}" ]] && return
    tg_api "sendMessage" -s --max-time 10         -X POST         --data-urlencode "chat_id=${chat_id}"         --data-urlencode "parse_mode=HTML"         --data-urlencode "text=${message}"         >/dev/null 2>&1 || true
}

tg_user_commands_json() {
    cat <<'EOF'
[
  {"command":"start","description":"Открыть пользовательское меню"},
  {"command":"help","description":"Как подключить уведомления"},
  {"command":"myid","description":"Показать мой Telegram ID"},
  {"command":"apps","description":"Скачать приложения"},
  {"command":"support","description":"Связаться с поддержкой"}
]
EOF
}

tg_bot_commands_json() {
    cat <<'EOF'
[
  {"command":"start","description":"Открыть меню"},
  {"command":"help","description":"Помощь и список команд"},
  {"command":"menu","description":"Показать кнопки управления"},
  {"command":"status","description":"Статус сервера"},
  {"command":"stats","description":"Статистика ресурсов и трафика"},
  {"command":"haproxy","description":"HAProxy SNI mux и маршруты"},
  {"command":"diagnose","description":"Диагностика системы"},
  {"command":"logs","description":"Последние логи Caddy"},
  {"command":"cert","description":"Статус TLS сертификата"},
  {"command":"users","description":"Список пользователей"},
  {"command":"adduser","description":"Добавить пользователя"},
  {"command":"deluser","description":"Удалить пользователя"},
  {"command":"qr","description":"QR и ссылка пользователя"},
  {"command":"sub","description":"Страница подписки"},
  {"command":"subreset","description":"Перевыпустить подписку"},
  {"command":"expiring","description":"Сроки подписок и Telegram ID"},
  {"command":"bindtg","description":"Привязать Telegram ID к пользователю"},
  {"command":"notifyrun","description":"Запустить проверку уведомлений"},
  {"command":"testnotify","description":"Тест уведомления пользователю"},
  {"command":"news_test","description":"Тест новости себе"},
  {"command":"news","description":"Разослать новость пользователям"},
  {"command":"devices","description":"Лимит устройств"},
  {"command":"lockuser","description":"Отключить пользователя"},
  {"command":"unlockuser","description":"Включить пользователя"},
  {"command":"xray","description":"Xray ссылки пользователя"},
  {"command":"xrayadduser","description":"Создать Xray пользователя"},
  {"command":"xraystatus","description":"Статус Xray"},
  {"command":"hysteria","description":"Статус Hysteria 2"},
  {"command":"warp","description":"Статус WARP"},
  {"command":"restart","description":"Перезапустить Caddy"},
  {"command":"update","description":"Обновить Caddy"},
  {"command":"selfupdate","description":"Обновить скрипт"},
  {"command":"diagfix","description":"Автофикс проблем"},
  {"command":"privatepage","description":"Личная фейковая страница"},
  {"command":"admins","description":"Список администраторов"},
  {"command":"addadmin","description":"Добавить администратора"},
  {"command":"deladmin","description":"Удалить администратора"},
  {"command":"donate","description":"Поддержать проект"}
]
EOF
}

tg_apply_bot_menu() {
    [[ -z "${TG_TOKEN:-}" ]] && { err "Telegram не настроен"; return 1; }

    local user_commands admin_commands menu_button resp_cmd resp_menu admin_id admin_scope admin_resp failed=0
    user_commands=$(tg_user_commands_json | tr -d '\n')
    admin_commands=$(tg_bot_commands_json | tr -d '\n')
    menu_button='{"type":"commands"}'

    resp_cmd=$(tg_api "setMyCommands" -s --max-time 15 \
        -X POST \
        --data-urlencode "commands=${user_commands}" \
        2>/dev/null || echo "{}")

    if ! echo "$resp_cmd" | grep -q '"ok":true'; then
        err "Не удалось установить пользовательское Telegram commands menu"
        echo "$resp_cmd"
        return 1
    fi

    while IFS= read -r admin_id; do
        [[ -z "$admin_id" ]] && continue
        admin_scope=$(printf '{"type":"chat","chat_id":%s}' "$admin_id")
        admin_resp=$(tg_api "setMyCommands" -s --max-time 15 \
            -X POST \
            --data-urlencode "commands=${admin_commands}" \
            --data-urlencode "scope=${admin_scope}" \
            2>/dev/null || echo "{}")
        if ! echo "$admin_resp" | grep -q '"ok":true'; then
            warn "Не удалось установить админское меню для Telegram ID ${admin_id}"
            failed=$((failed + 1))
        fi
    done < <(tg_admin_ids | sort -u)

    resp_menu=$(tg_api "setChatMenuButton" -s --max-time 15 \
        -X POST \
        --data-urlencode "menu_button=${menu_button}" \
        2>/dev/null || echo "{}")

    if echo "$resp_menu" | grep -q '"ok":true'; then
        ok "Telegram Menu button включён"
    else
        warn "Команды установлены, но Menu button не подтвердился"
        echo "$resp_menu"
    fi
    [[ "$failed" -eq 0 ]]
}

tg_apply_bot_menu_silent() {
    tg_apply_bot_menu >/dev/null 2>&1 || true
}

tg_main_menu_markup() {
    cat <<'EOF'
{"keyboard":[[{"text":"📊 Статус"},{"text":"👥 Пользователи"}],[{"text":"➕ Добавить пользователя"},{"text":"🗑 Удалить пользователя"}],[{"text":"📱 QR / ссылка"},{"text":"🔗 Подписка"}],[{"text":"📰 Новости"},{"text":"🔔 Уведомления"}],[{"text":"🧬 Xray"},{"text":"⚡ Hysteria"},{"text":"🌀 WARP"}],[{"text":"🔀 HAProxy"},{"text":"🔍 Диагностика"}],[{"text":"📄 Логи"},{"text":"♻️ Restart Caddy"}],[{"text":"🛠 Автофикс"},{"text":"💛 Донат"}],[{"text":"❓ Помощь"}]],"resize_keyboard":true,"one_time_keyboard":false,"is_persistent":true}
EOF
}

tg_user_menu_markup() {
    cat <<'EOF'
{"keyboard":[[{"text":"🆔 Мой Telegram ID"},{"text":"🔔 Уведомления"}],[{"text":"📱 Приложения"},{"text":"💬 Поддержка"}]],"resize_keyboard":true,"one_time_keyboard":false,"is_persistent":true}
EOF
}

tg_reply_menu() {
    local chat_id="$1"
    local message="$2"
    local menu_kind="${3:-admin}"
    local reply_markup
    [[ -z "${TG_TOKEN:-}" ]] && return
    if [[ "$menu_kind" == "user" ]]; then
        reply_markup=$(tg_user_menu_markup)
    else
        reply_markup=$(tg_main_menu_markup)
    fi
    tg_api "sendMessage" -s --max-time 10 \
        -X POST \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "text=${message}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        >/dev/null 2>&1 || true
}

tg_user_welcome_message() {
    local from_id="$1" safe_id safe_android safe_windows safe_support
    safe_id=$(html_escape_text "$from_id")
    safe_android=$(html_escape_text "$ANDROID_APP_RELEASES_URL")
    safe_windows=$(html_escape_text "$WINDOWS_APP_RELEASES_URL")
    safe_support=$(html_escape_text "$TELEGRAM_COMMUNITY_URL")
    cat <<EOF
👋 <b>Yurich Connect</b>

Это пользовательское меню уведомлений.

🆔 Твой Telegram ID: <code>${safe_id}</code>

Отправь этот ID Ивану Юрьевичу вместе с именем профиля, чтобы получать уведомления об окончании подписки, важные новости и сервисные сообщения.

📱 Android: ${safe_android}
🖥 Windows: ${safe_windows}
💬 Поддержка: ${safe_support}
EOF
}

# ─── SALES BOT: продажи и автовыдача подписок ────────────────
sales_tg_api() {
    [[ -n "${SALES_BOT_TOKEN:-}" ]] || return 1
    tg_api_with_token "$SALES_BOT_TOKEN" "$@"
}

sales_reply() {
    local chat_id="$1" message="$2"
    [[ -n "${SALES_BOT_TOKEN:-}" ]] || return 0
    sales_tg_api "sendMessage" -s --max-time 12 \
        -X POST \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true" \
        --data-urlencode "text=${message}" \
        >/dev/null 2>&1 || true
}

sales_menu_markup() {
    cat <<'EOF'
{"keyboard":[[{"text":"💎 Купить VPN"},{"text":"🟢 Моя подписка"}],[{"text":"📲 Приложения"},{"text":"🚀 Как подключить"}],[{"text":"📣 Канал"},{"text":"🛟 Поддержка"}]],"resize_keyboard":true,"one_time_keyboard":false,"is_persistent":true}
EOF
}

sales_admin_menu_markup() {
    cat <<'EOF'
{"keyboard":[[{"text":"🧾 Заявки"},{"text":"📊 Статус продаж"}],[{"text":"💎 Купить VPN"},{"text":"🟢 Моя подписка"}],[{"text":"📲 Приложения"},{"text":"📣 Канал"}],[{"text":"🛟 Поддержка"}]],"resize_keyboard":true,"one_time_keyboard":false,"is_persistent":true}
EOF
}

sales_reply_menu() {
    local chat_id="$1" message="$2" kind="${3:-user}" reply_markup
    [[ "$kind" == "admin" ]] && reply_markup=$(sales_admin_menu_markup) || reply_markup=$(sales_menu_markup)
    sales_tg_api "sendMessage" -s --max-time 12 \
        -X POST \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true" \
        --data-urlencode "text=${message}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        >/dev/null 2>&1 || true
}

sales_welcome_text() {
    cat <<'EOF'
🤖 <b>Yurich Connect VPN</b>

Быстрые VPN-подписки для телефона и компьютера.

✨ <b>Что внутри</b>
• стабильные профили HTTPS, Turbo и Reality;
• личная страница подписки;
• удобный импорт в Yurich Connect, Hiddify, NekoBox, v2rayNG и Streisand;
• уведомления о сроке подписки в Telegram.

Выбери тариф ниже, оплати по QR и отправь скрин платежа сюда в бот.
EOF
}

sales_send_welcome_visual() {
    local chat_id="$1" kind="${2:-user}" caption reply_markup animation_path image_path response
    caption=$(sales_welcome_text)
    [[ "$kind" == "admin" ]] && reply_markup=$(sales_admin_menu_markup) || reply_markup=$(sales_menu_markup)
    animation_path="${SALES_BOT_WELCOME_ANIMATION_PATH:-$SALES_BOT_WELCOME_ANIMATION_PATH_DEFAULT}"
    image_path="${SALES_BOT_WELCOME_IMAGE_PATH:-$SALES_BOT_WELCOME_IMAGE_PATH_DEFAULT}"
    if [[ -s "$animation_path" ]]; then
        response=$(sales_tg_api "sendAnimation" -s --max-time 45 \
            -X POST \
            --form-string "chat_id=${chat_id}" \
            --form-string "parse_mode=HTML" \
            --form-string "caption=${caption}" \
            --form-string "reply_markup=${reply_markup}" \
            -F "animation=@${animation_path};type=image/gif" \
            2>/dev/null || echo "{}")
        echo "$response" | grep -q '"ok":true' && return 0
    fi
    if [[ -s "$image_path" ]]; then
        response=$(sales_tg_api "sendPhoto" -s --max-time 30 \
            -X POST \
            --form-string "chat_id=${chat_id}" \
            --form-string "parse_mode=HTML" \
            --form-string "caption=${caption}" \
            --form-string "reply_markup=${reply_markup}" \
            -F "photo=@${image_path};type=image/jpeg" \
            2>/dev/null || echo "{}")
        echo "$response" | grep -q '"ok":true' && return 0
    fi
    return 1
}

sales_reply_start() {
    local chat_id="$1" kind="${2:-user}"
    if ! sales_send_welcome_visual "$chat_id" "$kind"; then
        sales_reply_menu "$chat_id" "$(sales_welcome_text)" "$kind"
    fi
    sales_reply_buy_menu "$chat_id" "$(sales_plans_text)"
}

sales_bot_commands_json() {
    cat <<'EOF'
[
  {"command":"start","description":"Открыть меню"},
  {"command":"plans","description":"Посмотреть тарифы"},
  {"command":"status","description":"Моя подписка"},
  {"command":"apps","description":"Скачать приложения"},
  {"command":"channel","description":"Канал Yurich Connect"},
  {"command":"support","description":"Поддержка"}
]
EOF
}

sales_bot_admin_commands_json() {
    cat <<'EOF'
[
  {"command":"start","description":"Открыть меню"},
  {"command":"sales_orders","description":"Новые заявки"},
  {"command":"approve","description":"Подтвердить заявку"},
  {"command":"reject","description":"Отклонить заявку"},
  {"command":"sales_status","description":"Статус продаж"},
  {"command":"plans","description":"Тарифы"},
  {"command":"status","description":"Моя подписка"},
  {"command":"apps","description":"Скачать приложения"},
  {"command":"channel","description":"Канал Yurich Connect"},
  {"command":"support","description":"Поддержка"}
]
EOF
}

sales_admin_ids() {
    local admin_id
    if [[ -n "${SALES_BOT_ADMIN_ID:-}" && "${SALES_BOT_ADMIN_ID}" =~ ^[0-9]+$ ]]; then
        printf '%s\n' "$SALES_BOT_ADMIN_ID"
    fi
    if [[ -n "${SALES_BOT_ADMINS:-}" ]]; then
        local IFS=','
        for admin_id in ${SALES_BOT_ADMINS}; do
            admin_id="${admin_id// /}"
            [[ "$admin_id" =~ ^[0-9]+$ ]] && printf '%s\n' "$admin_id"
        done
    fi
}

sales_is_admin() {
    local from_id="$1" admin_id
    while IFS= read -r admin_id; do
        [[ -n "$admin_id" && "$from_id" == "$admin_id" ]] && return 0
    done < <(sales_admin_ids | sort -u)
    return 1
}

sales_apply_bot_menu() {
    [[ -n "${SALES_BOT_TOKEN:-}" ]] || { err "Sales bot token не настроен"; return 1; }
    local user_commands admin_commands menu_button resp admin_id admin_scope admin_resp failed=0
    user_commands=$(sales_bot_commands_json | tr -d '\n')
    admin_commands=$(sales_bot_admin_commands_json | tr -d '\n')
    menu_button='{"type":"commands"}'

    sales_tg_api "setMyName" -s --max-time 15 \
        -X POST \
        --data-urlencode "name=Yurich Connect VPN" \
        >/dev/null 2>&1 || true
    sales_tg_api "setMyShortDescription" -s --max-time 15 \
        -X POST \
        --data-urlencode "short_description=VPN-подписки от 50 руб: оплата по QR, выдача после проверки." \
        >/dev/null 2>&1 || true
    sales_tg_api "setMyDescription" -s --max-time 15 \
        -X POST \
        --data-urlencode "description=Yurich Connect VPN: HTTPS, Turbo и Reality-профили для телефона и компьютера. Выберите тариф на 1 день, 1, 3, 6 или 12 месяцев, оплатите по QR и отправьте скрин платежа в бот. После проверки бот пришлёт страницу подписки. Канал: ${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}" \
        >/dev/null 2>&1 || true

    resp=$(sales_tg_api "setMyCommands" -s --max-time 15 \
        -X POST \
        --data-urlencode "commands=${user_commands}" \
        2>/dev/null || echo "{}")
    echo "$resp" | grep -q '"ok":true' || { err "Не удалось установить команды sales bot"; echo "$resp"; return 1; }

    while IFS= read -r admin_id; do
        [[ -z "$admin_id" ]] && continue
        admin_scope=$(printf '{"type":"chat","chat_id":%s}' "$admin_id")
        admin_resp=$(sales_tg_api "setMyCommands" -s --max-time 15 \
            -X POST \
            --data-urlencode "commands=${admin_commands}" \
            --data-urlencode "scope=${admin_scope}" \
            2>/dev/null || echo "{}")
        echo "$admin_resp" | grep -q '"ok":true' || failed=$((failed + 1))
    done < <(sales_admin_ids | sort -u)

    sales_tg_api "setChatMenuButton" -s --max-time 15 \
        -X POST \
        --data-urlencode "menu_button=${menu_button}" \
        >/dev/null 2>&1 || true
    [[ "$failed" -eq 0 ]]
}

sales_plan_price() {
    local term item key p normalized
    normalized=$(normalize_user_term "${1:-}" 2>/dev/null || true)
    [[ -n "$normalized" ]] || return 1
    IFS=',' read -ra _sales_plan_items <<< "${SALES_BOT_PLANS:-$SALES_BOT_PLANS_DEFAULT}"
    for item in "${_sales_plan_items[@]}"; do
        key="${item%%:*}"
        p="${item#*:}"
        [[ "$key" =~ ^[0-9]+$ ]] && key="${key}m"
        if [[ "$key" == "$normalized" && "$p" =~ ^[0-9]+$ ]]; then
            printf '%s\n' "$p"
            return 0
        fi
    done
    return 1
}

sales_plan_regular_price() {
    local term
    term=$(normalize_user_term "${1:-}" 2>/dev/null || true)
    case "$term" in
        1d) printf '50\n' ;;
        *m) printf '%s\n' $(( ${term%m} * 250 )) ;;
        *) return 1 ;;
    esac
}

sales_plans_text() {
    local item key term p regular discount pct per_month currency channel lines="" icon badge
    currency="${SALES_BOT_CURRENCY:-$SALES_BOT_CURRENCY_DEFAULT}"
    channel="${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}"
    IFS=',' read -ra _sales_plan_items <<< "${SALES_BOT_PLANS:-$SALES_BOT_PLANS_DEFAULT}"
    for item in "${_sales_plan_items[@]}"; do
        key="${item%%:*}"
        p="${item#*:}"
        [[ "$key" =~ ^[0-9]+$ ]] && key="${key}m"
        term=$(normalize_user_term "$key" 2>/dev/null || true)
        [[ -n "$term" && "$p" =~ ^[0-9]+$ ]] || continue
        case "$term" in
            1d) icon="⚡"; badge="тест на день" ;;
            1m) icon="🚀"; badge="стартовый" ;;
            3m) icon="⭐"; badge="выгоднее" ;;
            6m) icon="🔥"; badge="популярный" ;;
            12m) icon="👑"; badge="максимальная выгода" ;;
            *) icon="💎"; badge="тариф" ;;
        esac
        regular=$(sales_plan_regular_price "$term" 2>/dev/null || echo "$p")
        if [[ "$p" -lt "$regular" ]]; then
            discount=$((regular - p))
            pct=$(((discount * 100 + regular / 2) / regular))
            if [[ "$term" == *m ]]; then
                per_month=$((p / ${term%m}))
                lines="${lines}${icon} <b>$(user_term_label "$term")</b> — <code>${p} ${currency}</code>
   ${badge}: ~${per_month} руб/мес, экономия ${discount} руб / ${pct}%
"
            else
                lines="${lines}${icon} <b>$(user_term_label "$term")</b> — <code>${p} ${currency}</code>
   ${badge}: экономия ${discount} руб / ${pct}%
"
            fi
        else
            lines="${lines}${icon} <b>$(user_term_label "$term")</b> — <code>${p} ${currency}</code>
   ${badge}
"
        fi
    done
    cat <<EOF
💎 <b>Тарифы Yurich Connect VPN</b>

${lines}
💡 База: <b>250 руб / месяц</b>.
Чем больше срок, тем ниже цена за месяц.

✅ <b>Включено</b>
• телефон и компьютер;
• личная страница подписки;
• быстрый импорт в приложения;
• уведомления о сроке подписки.

🛡 <b>Профили</b>
• HTTPS = NaiveProxy;
• Turbo = Hysteria2;
• Reality = VLESS Reality на 443.

📣 <b>Канал Yurich Connect</b>
${channel}

👇 Чтобы оформить заявку, нажми нужный тариф или отправь:
<code>/buy day</code>, <code>/buy 1</code>, <code>/buy 3</code>, <code>/buy 6</code>, <code>/buy 12</code>
EOF
}

sales_buy_menu_markup() {
    local pd p1 p3 p6 p12 currency
    pd=$(sales_plan_price 1d 2>/dev/null || printf '50')
    p1=$(sales_plan_price 1m 2>/dev/null || printf '250')
    p3=$(sales_plan_price 3m 2>/dev/null || printf '700')
    p6=$(sales_plan_price 6m 2>/dev/null || printf '1300')
    p12=$(sales_plan_price 12m 2>/dev/null || printf '2400')
    currency="${SALES_BOT_CURRENCY:-$SALES_BOT_CURRENCY_DEFAULT}"
    cat <<EOF
{"keyboard":[[{"text":"⚡ 1 день - ${pd} ${currency}"},{"text":"🚀 1 месяц - ${p1} ${currency}"}],[{"text":"⭐ 3 месяца - ${p3} ${currency}"},{"text":"🔥 6 месяцев - ${p6} ${currency}"}],[{"text":"👑 12 месяцев - ${p12} ${currency}"}],[{"text":"🟢 Моя подписка"},{"text":"📲 Приложения"}],[{"text":"📣 Канал"},{"text":"🛟 Поддержка"}]],"resize_keyboard":true,"one_time_keyboard":false,"is_persistent":true}
EOF
}

sales_reply_buy_menu() {
    local chat_id="$1" message="$2" reply_markup
    reply_markup=$(sales_buy_menu_markup)
    sales_tg_api "sendMessage" -s --max-time 12 \
        -X POST \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true" \
        --data-urlencode "text=${message}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        >/dev/null 2>&1 || true
}

sales_months_from_text() {
    local text="${1,,}"
    if [[ "$text" =~ ^/buy[[:space:]]+(day|день|1d) ]]; then
        printf '1d\n'
        return 0
    fi
    if [[ "$text" =~ ^/buy[[:space:]]+([0-9]{1,2}) ]]; then
        printf '%sm\n' "${BASH_REMATCH[1]}"
        return 0
    fi
    if [[ "$text" == *"день"* || "$text" == *"50"* ]]; then
        printf '1d\n'
        return 0
    fi
    if [[ "$text" == *"250"* ]]; then
        printf '1m\n'
        return 0
    fi
    if [[ "$text" == *"700"* ]]; then
        printf '3m\n'
        return 0
    fi
    if [[ "$text" == *"1300"* ]]; then
        printf '6m\n'
        return 0
    fi
    if [[ "$text" == *"2400"* ]]; then
        printf '12m\n'
        return 0
    fi
    if [[ "$text" =~ (^|[[:space:]])(1|3|6|12)[[:space:]]*(мес|месяц|месяца|месяцев)? ]]; then
        printf '%sm\n' "${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

sales_order_valid_id() {
    [[ "${1:-}" =~ ^[0-9]{14}-[0-9]{5,20}-[0-9]{1,5}$ ]]
}

sales_user_for_chat() {
    local chat_id="$1"
    chat_id="${chat_id#-}"
    printf 'tg%s\n' "$chat_id"
}

sales_notify_admins() {
    local message="$1" admin_id
    while IFS= read -r admin_id; do
        [[ -n "$admin_id" ]] && sales_reply "$admin_id" "$message"
    done < <(sales_admin_ids | sort -u)
}

sales_safe_chat_key() {
    local chat_id="${1:-}"
    [[ "$chat_id" =~ ^-?[0-9]{1,20}$ ]] || return 1
    if [[ "$chat_id" == -* ]]; then
        printf 'm%s\n' "${chat_id#-}"
    else
        printf '%s\n' "$chat_id"
    fi
}

sales_captcha_ttl() {
    local ttl="${SALES_BOT_CAPTCHA_TTL_SECONDS:-$SALES_BOT_CAPTCHA_TTL_SECONDS_DEFAULT}"
    [[ "$ttl" =~ ^[0-9]+$ && "$ttl" -ge 300 ]] || ttl="$SALES_BOT_CAPTCHA_TTL_SECONDS_DEFAULT"
    printf '%s\n' "$ttl"
}

sales_captcha_file() {
    local key
    key=$(sales_safe_chat_key "$1") || return 1
    printf '%s/%s.env\n' "$SALES_BOT_CAPTCHA_DIR" "$key"
}

sales_verified_file() {
    local key
    key=$(sales_safe_chat_key "$1") || return 1
    printf '%s/%s.ok\n' "$SALES_BOT_VERIFIED_DIR" "$key"
}

sales_captcha_is_verified() {
    local chat_id="$1" file expires now
    file=$(sales_verified_file "$chat_id") || return 1
    [[ -f "$file" ]] || return 1
    expires=$(head -n 1 "$file" 2>/dev/null | tr -cd '0-9')
    [[ "$expires" =~ ^[0-9]+$ ]] || { rm -f "$file"; return 1; }
    now=$(date +%s)
    if [[ "$expires" -gt "$now" ]]; then
        return 0
    fi
    rm -f "$file"
    return 1
}

sales_captcha_has_pending() {
    local file
    file=$(sales_captcha_file "$1") || return 1
    [[ -f "$file" ]]
}

sales_captcha_generate() {
    local chat_id="$1" file tmp now a b answer
    file=$(sales_captcha_file "$chat_id") || return 1
    mkdir -p "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR"
    chmod 700 "$SALES_BOT_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR" 2>/dev/null || true
    now=$(date +%s)
    a=$((RANDOM % 8 + 2))
    b=$((RANDOM % 8 + 2))
    answer=$((a + b))
    tmp="${file}.tmp"
    {
        printf 'ANSWER=%q\n' "$answer"
        printf 'CREATED_AT=%q\n' "$now"
        printf 'TRIES=%q\n' "0"
    } > "$tmp"
    install -m 600 "$tmp" "$file"
    rm -f "$tmp"
    printf '%s + %s\n' "$a" "$b"
}

sales_captcha_prompt() {
    local chat_id="$1" question
    question=$(sales_captcha_generate "$chat_id") || {
        sales_reply "$chat_id" "Не удалось создать проверку безопасности. Напиши в поддержку."
        return 1
    }
    sales_reply "$chat_id" "<b>Проверка безопасности</b>

Чтобы защитить бот от спама, ответь одним числом:
<code>${question}</code>

После правильного ответа открою тарифы и оплату."
}

sales_captcha_check() {
    local chat_id="$1" text="$2" file now pending_ttl user_answer tries tmp ttl verified_file expires
    file=$(sales_captcha_file "$chat_id") || return 1
    if [[ ! -f "$file" ]]; then
        sales_captcha_prompt "$chat_id"
        return 0
    fi

    unset ANSWER CREATED_AT TRIES
    # shellcheck source=/dev/null
    source "$file" 2>/dev/null || true
    now=$(date +%s)
    pending_ttl=900
    if [[ ! "${ANSWER:-}" =~ ^[0-9]+$ || ! "${CREATED_AT:-}" =~ ^[0-9]+$ || $((now - CREATED_AT)) -gt "$pending_ttl" ]]; then
        sales_captcha_prompt "$chat_id"
        return 0
    fi

    user_answer=$(printf '%s' "$text" | tr -d '[:space:]')
    if [[ ! "$user_answer" =~ ^[0-9]{1,3}$ ]]; then
        sales_reply "$chat_id" "Напиши ответ на проверку только цифрами."
        return 0
    fi

    if [[ "$user_answer" == "$ANSWER" ]]; then
        ttl=$(sales_captcha_ttl)
        expires=$((now + ttl))
        verified_file=$(sales_verified_file "$chat_id") || return 1
        mkdir -p "$SALES_BOT_VERIFIED_DIR"
        tmp="${verified_file}.tmp"
        printf '%s\n' "$expires" > "$tmp"
        install -m 600 "$tmp" "$verified_file"
        rm -f "$tmp" "$file"
        sales_reply_buy_menu "$chat_id" "<b>Проверка пройдена</b>

Теперь можно выбрать тариф и оплатить подписку."
        return 0
    fi

    tries=$(( ${TRIES:-0} + 1 ))
    if [[ "$tries" -ge 3 ]]; then
        sales_captcha_prompt "$chat_id"
        sales_reply "$chat_id" "Слишком много неверных ответов. Я создал новый пример."
        return 0
    fi

    tmp="${file}.tmp"
    {
        printf 'ANSWER=%q\n' "$ANSWER"
        printf 'CREATED_AT=%q\n' "$CREATED_AT"
        printf 'TRIES=%q\n' "$tries"
    } > "$tmp"
    install -m 600 "$tmp" "$file"
    rm -f "$tmp"
    sales_reply "$chat_id" "Ответ неверный. Попробуй ещё раз."
}

sales_send_payment_qr() {
    local chat_id="$1" caption="$2" qr_path="${SALES_BOT_PAYMENT_QR_PATH:-$SALES_BOT_PAYMENT_QR_PATH_DEFAULT}" response safe_path mime_type
    safe_path=$(html_escape_text "$qr_path")
    [[ -n "${SALES_BOT_TOKEN:-}" ]] || return 1
    if [[ ! -s "$qr_path" ]]; then
        warn "Sales bot QR не найден или пустой: ${qr_path}"
        sales_reply "$chat_id" "QR-код для оплаты временно не найден на сервере. Реквизиты выше актуальны, после оплаты отправь скрин сюда в бот."
        sales_notify_admins "<b>Ошибка QR оплаты</b>

Файл QR не найден или пустой:
<code>${safe_path}</code>"
        return 1
    fi
    case "${qr_path,,}" in
        *.png) mime_type="image/png" ;;
        *.jpg|*.jpeg) mime_type="image/jpeg" ;;
        *) mime_type="application/octet-stream" ;;
    esac
    response=$(sales_tg_api "sendPhoto" -s --max-time 30 \
        -X POST \
        --form-string "chat_id=${chat_id}" \
        --form-string "parse_mode=HTML" \
        --form-string "caption=${caption}" \
        -F "photo=@${qr_path};type=${mime_type}" \
        2>/dev/null || echo "{}")
    if echo "$response" | grep -q '"ok":true'; then
        return 0
    fi
    warn "Telegram sendPhoto для QR вернул ошибку"
    sales_reply "$chat_id" "QR-код для оплаты не отправился автоматически. Реквизиты выше актуальны, после оплаты отправь скрин сюда в бот."
    sales_notify_admins "<b>Ошибка отправки QR оплаты</b>

Telegram не принял QR-файл:
<code>${safe_path}</code>

Проверь файл и логи:
<code>journalctl -u yurich-sales-bot -n 80 --no-pager</code>"
    return 1
}

sales_latest_pending_order_for_chat() {
    local chat_id="$1" file order_id status best_file="" best_order=""
    mkdir -p "$SALES_BOT_ORDERS_DIR"
    shopt -s nullglob
    for file in "$SALES_BOT_ORDERS_DIR"/*.env; do
        unset ORDER_ID STATUS CHAT_ID
        # shellcheck source=/dev/null
        source "$file" 2>/dev/null || continue
        [[ "${CHAT_ID:-}" == "$chat_id" ]] || continue
        [[ "${STATUS:-}" == "pending" ]] || continue
        order_id="${ORDER_ID:-$(basename "$file" .env)}"
        if [[ -z "$best_order" || "$order_id" > "$best_order" ]]; then
            best_order="$order_id"
            best_file="$file"
        fi
    done
    shopt -u nullglob
    [[ -n "$best_file" ]] || return 1
    printf '%s\n' "$best_file"
}

sales_handle_payment_proof() {
    local chat_id="$1" from_id="$2" username="$3" first_name="$4" message_id="$5" proof_kind="$6" order_file order_id safe_user safe_name admin_id
    if ! order_file=$(sales_latest_pending_order_for_chat "$chat_id" 2>/dev/null); then
        sales_reply "$chat_id" "Скрин оплаты получил, но активной заявки не нашёл. Сначала выбери тариф через /plans."
        return 0
    fi
    # shellcheck source=/dev/null
    source "$order_file"
    order_id="${ORDER_ID:-$(basename "$order_file" .env)}"
    safe_user=$(html_escape_text "${username:-без username}")
    safe_name=$(html_escape_text "${first_name:-без имени}")
    {
        grep -vE '^(PROOF_SENT_AT|PROOF_MESSAGE_ID|PROOF_KIND)=' "$order_file" 2>/dev/null || true
        printf 'PROOF_SENT_AT=%q\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'PROOF_MESSAGE_ID=%q\n' "$message_id"
        printf 'PROOF_KIND=%q\n' "$proof_kind"
    } > "${order_file}.tmp"
    install -m 600 "${order_file}.tmp" "$order_file"
    rm -f "${order_file}.tmp"

    while IFS= read -r admin_id; do
        [[ -z "$admin_id" ]] && continue
        sales_reply "$admin_id" "<b>Скрин оплаты по заявке</b>

ORDER: <code>${order_id}</code>
Клиент: <code>${chat_id}</code>
Username: <code>${safe_user}</code>
Имя: <code>${safe_name}</code>
Тип файла: <code>${proof_kind}</code>
Тариф: <b>$(user_term_label "${TERM:-${MONTHS:-?}}")</b>
Сумма: <code>${PRICE:-?} ${CURRENCY:-RUB}</code>

Подтвердить:
<code>/approve ${order_id}</code>

Отклонить:
<code>/reject ${order_id}</code>"
        sales_tg_api "forwardMessage" -s --max-time 20 \
            -X POST \
            --data-urlencode "chat_id=${admin_id}" \
            --data-urlencode "from_chat_id=${chat_id}" \
            --data-urlencode "message_id=${message_id}" \
            >/dev/null 2>&1 || true
    done < <(sales_admin_ids | sort -u)

    sales_reply "$chat_id" "Скрин оплаты получил и отправил администратору. После проверки тебе придёт ссылка на подписку."
}

sales_create_order() {
    local chat_id="$1" from_id="$2" username="$3" first_name="$4" term="$5" price order_id order_file created safe_user safe_name payment_text term_label
    term=$(normalize_user_term "$term" 2>/dev/null || true)
    price=$(sales_plan_price "$term") || { sales_reply "$chat_id" "Этот тариф не найден. Открой /plans."; return 1; }
    term_label=$(user_term_label "$term")
    mkdir -p "$SALES_BOT_ORDERS_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR"
    chmod 700 "$SALES_BOT_DIR" "$SALES_BOT_ORDERS_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR" 2>/dev/null || true
    created=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    order_id="$(date -u '+%Y%m%d%H%M%S')-${chat_id#-}-${RANDOM}"
    order_file="${SALES_BOT_ORDERS_DIR}/${order_id}.env"
    {
        printf 'ORDER_ID=%q\n' "$order_id"
        printf 'STATUS=%q\n' "pending"
        printf 'CHAT_ID=%q\n' "$chat_id"
        printf 'FROM_ID=%q\n' "$from_id"
        printf 'USERNAME=%q\n' "$username"
        printf 'FIRST_NAME=%q\n' "$first_name"
        printf 'TERM=%q\n' "$term"
        if [[ "$term" == *m ]]; then
            printf 'MONTHS=%q\n' "${term%m}"
        else
            printf 'MONTHS=%q\n' ""
        fi
        printf 'PRICE=%q\n' "$price"
        printf 'CURRENCY=%q\n' "${SALES_BOT_CURRENCY:-RUB}"
        printf 'CREATED_AT=%q\n' "$created"
    } > "$order_file"
    chmod 600 "$order_file"

    payment_text=$(html_escape_text "${SALES_BOT_PAYMENT_TEXT:-Оплата пока подтверждается вручную.}")
    sales_reply "$chat_id" "<b>Заявка создана</b>

Номер: <code>${order_id}</code>
Тариф: <b>Yurich Connect на ${term_label}</b>
Сумма: <code>${price} ${SALES_BOT_CURRENCY:-RUB}</code>

${payment_text}

После оплаты отправь скрин платежа сюда в бот. Я перешлю его администратору, и после проверки бот пришлёт ссылку на подписку."

    sales_send_payment_qr "$chat_id" "<b>QR-код для оплаты</b>

Заявка: <code>${order_id}</code>
Сумма: <code>${price} ${SALES_BOT_CURRENCY:-RUB}</code>

После оплаты отправь скрин платежа сюда в бот."

    safe_user=$(html_escape_text "${username:-без username}")
    safe_name=$(html_escape_text "${first_name:-без имени}")
    sales_notify_admins "<b>Новая заявка VPN</b>

ORDER: <code>${order_id}</code>
Клиент: <code>${chat_id}</code>
Username: <code>${safe_user}</code>
Имя: <code>${safe_name}</code>
Тариф: <b>${term_label}</b>
Сумма: <code>${price} ${SALES_BOT_CURRENCY:-RUB}</code>

Подтвердить:
<code>/approve ${order_id}</code>

Отклонить:
<code>/reject ${order_id}</code>"
}

sales_subscription_status_text() {
    local chat_id="$1" user sub_url expires channel
    user=$(sales_user_for_chat "$chat_id")
    if ! subscription_user_exists "$user"; then
        cat <<EOF
Подписка для твоего Telegram ID пока не найдена.

Открой тарифы: /plans
EOF
        return 0
    fi
    expires=$(user_expiry_label "$user")
    sub_url=$(generate_subscription_page "$user" 2>/dev/null || true)
    channel="${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}"
    cat <<EOF
<b>Твоя подписка Yurich Connect</b>

Профиль: <code>${user}</code>
Срок: <code>${expires}</code>

Страница подписки:
<code>${sub_url:-не удалось создать ссылку}</code>

Канал:
${channel}
EOF
}

sales_issue_subscription() {
    local chat_id="$1" term="$2" user pass users_backup created=0 sub_url sync_note=""
    user=$(sales_user_for_chat "$chat_id")
    term=$(normalize_user_term "$term" 2>/dev/null || true)
    if ! is_valid_user_term "$term"; then
        err "Некорректный срок sales-подписки"
        return 1
    fi
    if ! is_valid_proxy_user "$user"; then
        err "Некорректный auto-user: $user"
        return 1
    fi

    load_config
    load_users
    mkdir -p "$(dirname "$USERS_FILE")"
    touch "$USERS_FILE"
    chmod 600 "$USERS_FILE"

    pass=$(get_user_pass "$user" 2>/dev/null || true)
    users_backup=$(mktemp)
    cp "$USERS_FILE" "$users_backup"
    if [[ -z "$pass" ]]; then
        pass=$(random_safe_token 20)
        printf '%s:%s\n' "$user" "$pass" >> "$USERS_FILE"
        created=1
    fi
    set_user_expiry_extend_term "$user" "$term" || { mv "$users_backup" "$USERS_FILE"; return 1; }

    if ! rewrite_caddyfile_current >/dev/null 2>&1; then
        mv "$users_backup" "$USERS_FILE"
        cleanup_user_metadata "$user"
        return 1
    fi
    if ! systemctl reload caddy >/dev/null 2>&1 && ! systemctl restart caddy >/dev/null 2>&1; then
        mv "$users_backup" "$USERS_FILE"
        cleanup_user_metadata "$user"
        rewrite_caddyfile_current >/dev/null 2>&1 || true
        return 1
    fi
    rm -f "$users_backup"

    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        sync_hysteria_users_if_active >/dev/null 2>&1 || true
    fi
    if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        provision_xray_user "$user" >/dev/null 2>&1 || true
    fi

    cmd_notify_bind_tg "$user" "$chat_id" >/dev/null 2>&1 || true
    if [[ "$(nodes_count 2>/dev/null || echo 0)" -gt 0 ]]; then
        cmd_nodes_sync_users all >/dev/null 2>&1 || sync_note="Ноды синхронизируются с задержкой; основная подписка уже готова."
    fi
    cmd_nodes_rebuild_subscriptions >/dev/null 2>&1 || true
    sub_url=$(generate_subscription_page "$user" 2>/dev/null || true)
    [[ -n "$sub_url" ]] || return 1
    printf 'USER=%s\nPASS=%s\nCREATED=%s\nSUB_URL=%s\nSYNC_NOTE=%s\n' "$user" "$pass" "$created" "$sub_url" "$sync_note"
}

sales_approve_order() {
    local order_id="$1" admin_id="$2" order_file STATUS CHAT_ID FROM_ID USERNAME FIRST_NAME TERM MONTHS PRICE CURRENCY issue_tmp rc sub_url user sync_note term
    sales_order_valid_id "$order_id" || { sales_reply "$admin_id" "Неверный ORDER ID."; return 1; }
    order_file="${SALES_BOT_ORDERS_DIR}/${order_id}.env"
    [[ -f "$order_file" ]] || { sales_reply "$admin_id" "Заявка не найдена: <code>${order_id}</code>"; return 1; }
    # shellcheck source=/dev/null
    source "$order_file"
    [[ "${STATUS:-}" == "pending" ]] || { sales_reply "$admin_id" "Заявка уже обработана: <code>${STATUS:-unknown}</code>"; return 1; }

    issue_tmp=$(mktemp)
    term="${TERM:-${MONTHS:-}}"
    if sales_issue_subscription "$CHAT_ID" "$term" > "$issue_tmp" 2>&1; then
        rc=0
    else
        rc=$?
    fi
    if [[ "$rc" -ne 0 ]]; then
        sales_reply "$admin_id" "<b>Ошибка выдачи подписки</b>
ORDER: <code>${order_id}</code>
<pre>$(html_escape_text "$(tail -n 40 "$issue_tmp")")</pre>"
        rm -f "$issue_tmp"
        return 1
    fi
    user=$(awk -F= '$1=="USER"{print $2}' "$issue_tmp")
    sub_url=$(awk -F= '$1=="SUB_URL"{print $2}' "$issue_tmp")
    sync_note=$(awk -F= '$1=="SYNC_NOTE"{print $2}' "$issue_tmp")
    {
        grep -vE '^(STATUS|APPROVED_AT|APPROVED_BY|ISSUED_USER|SUB_URL)=' "$order_file" 2>/dev/null || true
        printf 'STATUS=%q\n' "approved"
        printf 'APPROVED_AT=%q\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'APPROVED_BY=%q\n' "$admin_id"
        printf 'ISSUED_USER=%q\n' "$user"
        printf 'SUB_URL=%q\n' "$sub_url"
    } > "${order_file}.tmp"
    install -m 600 "${order_file}.tmp" "$order_file"
    rm -f "${order_file}.tmp" "$issue_tmp"

    sales_reply "$CHAT_ID" "<b>Подписка активирована</b>

Срок: <code>$(user_expiry_label "$user")</code>

Страница подписки:
<code>${sub_url}</code>

Открой ссылку и импортируй подписку в Yurich Connect, Hiddify, NekoBox, v2rayNG или Streisand.

Android:
${ANDROID_APP_RELEASES_URL}

Windows:
${WINDOWS_APP_RELEASES_URL}

Канал:
${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}
${sync_note:+
${sync_note}}"
    sales_reply "$admin_id" "<b>Заявка подтверждена</b>
ORDER: <code>${order_id}</code>
Пользователь: <code>${user}</code>
Ссылка: <code>${sub_url}</code>"
}

sales_reject_order() {
    local order_id="$1" admin_id="$2" reason="${3:-}" order_file STATUS CHAT_ID
    sales_order_valid_id "$order_id" || { sales_reply "$admin_id" "Неверный ORDER ID."; return 1; }
    order_file="${SALES_BOT_ORDERS_DIR}/${order_id}.env"
    [[ -f "$order_file" ]] || { sales_reply "$admin_id" "Заявка не найдена: <code>${order_id}</code>"; return 1; }
    # shellcheck source=/dev/null
    source "$order_file"
    [[ "${STATUS:-}" == "pending" ]] || { sales_reply "$admin_id" "Заявка уже обработана: <code>${STATUS:-unknown}</code>"; return 1; }
    {
        grep -vE '^(STATUS|REJECTED_AT|REJECTED_BY|REJECT_REASON)=' "$order_file" 2>/dev/null || true
        printf 'STATUS=%q\n' "rejected"
        printf 'REJECTED_AT=%q\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'REJECTED_BY=%q\n' "$admin_id"
        printf 'REJECT_REASON=%q\n' "${reason:-manual reject}"
    } > "${order_file}.tmp"
    install -m 600 "${order_file}.tmp" "$order_file"
    rm -f "${order_file}.tmp"
    sales_reply "$CHAT_ID" "<b>Заявка отклонена</b>${reason:+

Причина: $(html_escape_text "$reason")}"
    sales_reply "$admin_id" "Заявка отклонена: <code>${order_id}</code>"
}

sales_orders_text() {
    mkdir -p "$SALES_BOT_ORDERS_DIR"
    local file count=0 out=""
    for file in "$SALES_BOT_ORDERS_DIR"/*.env; do
        [[ -f "$file" ]] || continue
        unset ORDER_ID STATUS CHAT_ID USERNAME TERM MONTHS PRICE CURRENCY CREATED_AT
        # shellcheck source=/dev/null
        source "$file"
        [[ "${STATUS:-}" == "pending" ]] || continue
        count=$((count + 1))
        out="${out}<b>${count}.</b> <code>${ORDER_ID}</code>
Клиент: <code>${CHAT_ID:-}</code> @$(html_escape_text "${USERNAME:-none}")
Тариф: $(user_term_label "${TERM:-${MONTHS:-?}}") / ${PRICE:-?} ${CURRENCY:-RUB}
Подтвердить: <code>/approve ${ORDER_ID}</code>
Отклонить: <code>/reject ${ORDER_ID}</code>

"
    done
    if [[ "$count" -eq 0 ]]; then
        printf 'Новых заявок нет.'
    else
        printf '%s' "$out"
    fi
}

sales_handle_command() {
    local chat_id="$1" from_id="$2" username="$3" first_name="$4" text="$5" is_admin=0 term order_id reason
    set +e
    sales_is_admin "$from_id" && is_admin=1

    if [[ "$is_admin" -ne 1 ]]; then
        if sales_captcha_has_pending "$chat_id"; then
            sales_captcha_check "$chat_id" "$text"
            return
        fi
        case "$text" in
            *"Купить VPN"*|*"Тарифы"*|/start|/menu|/plans|/buy|/buy*)
                if ! sales_captcha_is_verified "$chat_id"; then
                    sales_captcha_prompt "$chat_id"
                    return
                fi
                ;;
            *)
                term=$(sales_months_from_text "$text" 2>/dev/null || true)
                if [[ -n "$term" ]] && ! sales_captcha_is_verified "$chat_id"; then
                    sales_captcha_prompt "$chat_id"
                    return
                fi
                ;;
        esac
    fi

    case "$text" in
        /start|/menu)
            sales_reply_start "$chat_id" "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            ;;
        *"Купить VPN"*|*"Тарифы"*|/plans|/buy)
            sales_reply_buy_menu "$chat_id" "$(sales_plans_text)"
            ;;
        *"Моя подписка"*|/status|/sub|/subscription)
            sales_reply_menu "$chat_id" "$(sales_subscription_status_text "$chat_id")" "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            ;;
        *"Как подключить"*|/help)
            sales_reply_menu "$chat_id" "<b>Как подключить</b>

1. Выбери тариф на 1 день, 1, 3, 6 или 12 месяцев.
2. Оплати по QR-коду и отправь скрин платежа сюда в бот.
3. После подтверждения оплаты бот пришлёт страницу подписки.
4. Открой страницу в приложении или скопируй URL.

Android: Yurich Connect, Hiddify, NekoBox, v2rayNG.
iPhone: Streisand.
Windows: Yurich Connect Windows, v2rayN, Hiddify." "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            ;;
        *"Приложения"*|/apps)
            sales_reply_menu "$chat_id" "<b>Приложения</b>

Тариф включает телефон и компьютер.

Android:
${ANDROID_APP_RELEASES_URL}

Windows:
${WINDOWS_APP_RELEASES_URL}

iPhone:
${STREISAND_APP_URL}" "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            ;;
        *"Канал"*|/channel)
            sales_reply_menu "$chat_id" "<b>Канал Yurich Connect</b>

Новости, обновления приложения и важные сообщения:
${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}" "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            ;;
        *"Поддержка"*|/support)
            sales_reply_menu "$chat_id" "<b>Поддержка</b>

Telegram: ${TELEGRAM_COMMUNITY_URL}
Email: ${SUPPORT_EMAIL}" "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            ;;
        *"Заявки"*|/sales_orders)
            if [[ "$is_admin" -ne 1 ]]; then sales_reply "$chat_id" "Команда доступна только администратору."; return; fi
            sales_reply_menu "$chat_id" "$(sales_orders_text)" "admin"
            ;;
        *"Статус продаж"*|/sales_status)
            if [[ "$is_admin" -ne 1 ]]; then sales_reply "$chat_id" "Команда доступна только администратору."; return; fi
            sales_reply_menu "$chat_id" "<b>Бот продаж Yurich Connect</b>

Сервис: <code>yurich-sales-bot.service</code>
Тарифы: <code>${SALES_BOT_PLANS:-}</code>
Валюта: <code>${SALES_BOT_CURRENCY:-RUB}</code>
Канал: <code>${SALES_BOT_CHANNEL_URL:-$SALES_BOT_CHANNEL_URL_DEFAULT}</code>
Лимит устройств: <code>выключен</code>
Заявки: <code>${SALES_BOT_ORDERS_DIR}</code>" "admin"
            ;;
        /approve*)
            if [[ "$is_admin" -ne 1 ]]; then sales_reply "$chat_id" "Команда доступна только администратору."; return; fi
            order_id=$(printf '%s\n' "$text" | awk '{print $2}')
            sales_approve_order "$order_id" "$chat_id"
            ;;
        /reject*)
            if [[ "$is_admin" -ne 1 ]]; then sales_reply "$chat_id" "Команда доступна только администратору."; return; fi
            order_id=$(printf '%s\n' "$text" | awk '{print $2}')
            reason=$(printf '%s\n' "$text" | cut -d' ' -f3-)
            [[ "$reason" == "$text" ]] && reason=""
            sales_reject_order "$order_id" "$chat_id" "$reason"
            ;;
        *)
            term=$(sales_months_from_text "$text" 2>/dev/null || true)
            if [[ -n "$term" ]]; then
                sales_create_order "$chat_id" "$from_id" "$username" "$first_name" "$term"
            else
                sales_reply_menu "$chat_id" "Не понял команду. Открой меню или напиши /plans." "$([[ "$is_admin" -eq 1 ]] && echo admin || echo user)"
            fi
            ;;
    esac
}

cmd_sales_bot() {
    [[ -n "${SALES_BOT_TOKEN:-}" ]] || { err "Sales bot не настроен. Запусти: sudo bash ${SCRIPT_PATH} sales-bot-install TOKEN ADMIN_ID"; return 1; }
    sales_apply_bot_menu >/dev/null 2>&1 || true
    mkdir -p "$SALES_BOT_ORDERS_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR"
    chmod 700 "$SALES_BOT_DIR" "$SALES_BOT_ORDERS_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR" 2>/dev/null || true
    info "Запускаю Yurich Sales Bot..."
    local offset=0 response updates
    while true; do
        response=$(sales_tg_api "getUpdates?offset=${offset}&timeout=30&allowed_updates=%5B%22message%22%5D" -s --max-time 35 2>/dev/null || echo "")
        if [[ -z "$response" ]]; then
            sleep 5
            continue
        fi
        updates=$(echo "$response" | python3 -c "
import json, sys
try:
    data=json.load(sys.stdin)
    if not data.get('ok'): sys.exit(0)
    for u in data.get('result', []):
        uid=u.get('update_id',0)
        msg=u.get('message') or {}
        chat=msg.get('chat') or {}
        frm=msg.get('from') or {}
        text=str(msg.get('text') or '')
        kind='text'
        if not text:
            if msg.get('photo'):
                kind='photo'
                text='__PAYMENT_PROOF__'
            elif msg.get('document'):
                kind='document'
                text='__PAYMENT_PROOF__'
            else:
                continue
        def clean(v):
            return str(v or '').replace('|',' ').replace('\\r',' ').replace('\\n',' ')[:120]
        print('|'.join([str(uid), clean(chat.get('id')), clean(frm.get('id')), clean(frm.get('username')), clean(frm.get('first_name')), clean(msg.get('message_id')), clean(kind), clean(text)]))
except Exception:
    pass
" 2>/dev/null || echo "")
        while IFS='|' read -r update_id chat_id from_id username first_name message_id kind text; do
            [[ -z "${update_id:-}" ]] && continue
            if [[ "$update_id" =~ ^[0-9]+$ && "$update_id" -lt 2147483647 ]]; then
                offset=$(( update_id + 1 ))
            fi
            if [[ "${kind:-text}" == "photo" || "${kind:-text}" == "document" ]]; then
                sales_handle_payment_proof "$chat_id" "$from_id" "$username" "$first_name" "$message_id" "$kind"
            else
                sales_handle_command "$chat_id" "$from_id" "$username" "$first_name" "$text"
            fi
        done <<< "$updates"
        sleep 1
    done
}

install_sales_bot_service() {
    local token="${1:-}" admin_id="${2:-}" script_path="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}" response bot_name
    load_config 2>/dev/null || true
    if [[ -n "$token" ]]; then
        SALES_BOT_TOKEN="$token"
    fi
    if [[ -n "$admin_id" ]]; then
        SALES_BOT_ADMIN_ID="$admin_id"
    fi
    if [[ -z "${SALES_BOT_TOKEN:-}" ]]; then
        err "Передай token: sudo bash ${SCRIPT_PATH} sales-bot-install TOKEN ADMIN_ID"
        return 1
    fi
    if [[ ! "${SALES_BOT_TOKEN:-}" =~ ^[0-9]+:[A-Za-z0-9_-]{20,}$ ]]; then
        err "Sales bot token выглядит некорректно"
        return 1
    fi
    if ! is_valid_tg_chat_id "${SALES_BOT_ADMIN_ID:-}"; then
        err "Передай корректный Telegram admin ID"
        return 1
    fi

    response=$(tg_api_with_token "$SALES_BOT_TOKEN" "getMe" -s --max-time 15 2>/dev/null || echo "{}")
    if ! echo "$response" | grep -q '"ok":true'; then
        err "Telegram API не подтвердил sales bot token"
        echo "$response"
        return 1
    fi
    bot_name=$(echo "$response" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
    save_config
    mkdir -p "$SALES_BOT_ORDERS_DIR"
    chmod 700 "$SALES_BOT_DIR" "$SALES_BOT_ORDERS_DIR" 2>/dev/null || true
    install -m 755 "$script_path" "$script_path" 2>/dev/null || true

    cat > "$SALES_BOT_SERVICE" <<EOF
[Unit]
Description=Yurich VPN Sales Telegram Bot
After=network-online.target caddy.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/bin/bash ${script_path} sales-bot
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable yurich-sales-bot --quiet
    sales_apply_bot_menu || warn "Меню бота продаж применится при запуске сервиса"
    systemctl restart yurich-sales-bot
    sales_reply "${SALES_BOT_ADMIN_ID}" "<b>Бот продаж Yurich Connect запущен</b>

Бот: <code>@${bot_name:-unknown}</code>
Команды администратора:
<code>/sales_orders</code>
<code>/approve ORDER</code>
<code>/reject ORDER</code>"
    ok "Бот продаж установлен и запущен: yurich-sales-bot.service"
    [[ -n "$bot_name" ]] && ok "Bot: @${bot_name}"
}

cmd_sales_bot_apply_defaults() {
    local existing_sales_token=""
    if [[ -f "$CONFIG_FILE" ]]; then
        existing_sales_token=$(bash -c 'source "$1" >/dev/null 2>&1; printf "%s" "${SALES_BOT_TOKEN:-}"' _ "$CONFIG_FILE" 2>/dev/null || true)
    fi

    load_config 2>/dev/null || true
    if [[ -z "${SALES_BOT_TOKEN:-}" && -n "$existing_sales_token" ]]; then
        SALES_BOT_TOKEN="$existing_sales_token"
    fi

    SALES_BOT_PLANS="$SALES_BOT_PLANS_DEFAULT"
    SALES_BOT_CURRENCY="$SALES_BOT_CURRENCY_DEFAULT"
    SALES_BOT_CHANNEL_URL="$SALES_BOT_CHANNEL_URL_DEFAULT"
    SALES_BOT_PAYMENT_TEXT="$SALES_BOT_PAYMENT_TEXT_DEFAULT"
    SALES_BOT_PAYMENT_QR_PATH="${SALES_BOT_PAYMENT_QR_PATH:-$SALES_BOT_PAYMENT_QR_PATH_DEFAULT}"
    SALES_BOT_CAPTCHA_TTL_SECONDS="${SALES_BOT_CAPTCHA_TTL_SECONDS:-$SALES_BOT_CAPTCHA_TTL_SECONDS_DEFAULT}"

    DEVICE_LIMIT_ENABLED="0"
    DEVICE_LIMIT="5"
    DEVICE_WINDOW_HOURS="${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}"
    DEVICE_LIMIT_MODE="alert"

    save_config
    write_device_cron
    mkdir -p "$SALES_BOT_DIR" "$SALES_BOT_ORDERS_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR"
    chmod 700 "$SALES_BOT_DIR" "$SALES_BOT_ORDERS_DIR" "$SALES_BOT_CAPTCHA_DIR" "$SALES_BOT_VERIFIED_DIR" 2>/dev/null || true

    if [[ -n "${SALES_BOT_TOKEN:-}" ]]; then
        sales_apply_bot_menu || warn "Не удалось применить меню бота продаж через Telegram API"
        if systemctl list-unit-files yurich-sales-bot.service >/dev/null 2>&1; then
            systemctl restart yurich-sales-bot || warn "Не удалось перезапустить yurich-sales-bot.service"
        fi
    else
        warn "SALES_BOT_TOKEN не настроен, меню Telegram не применялось"
    fi

    ok "Настройки продаж применены: тарифы 1 день/1/3/6/12 месяцев, QR, канал, автобан выключен"
}

tg_reply_pre() {
    local chat_id="$1"
    local title="$2"
    local content="$3"
    content=$(printf '%s' "$content" | sed -r 's/\x1B\[[0-9;]*[mK]//g' | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | head -c 3400 || true)
    [[ -z "$content" ]] && content="нет вывода"
    tg_reply "$chat_id" "${title}
<pre>${content}</pre>"
}

tg_reply_file_tail() {
    local chat_id="$1"
    local title="$2"
    local file="$3"
    local lines="${4:-60}"
    local content
    if [[ -f "$file" ]]; then
        content=$(tail -n "$lines" "$file" 2>/dev/null || true)
    else
        content="файл не найден: ${file}"
    fi
    tg_reply_pre "$chat_id" "$title" "$content"
}

# Отправка фото (QR код)
tg_send_photo() {
    local chat_id="$1"
    local photo_path="$2"
    local caption="$3"
    [[ -z "${TG_TOKEN:-}" || ! -f "${photo_path}" ]] && return
    # Используем только -F для multipart (-F и --data-urlencode несовместимы)
    tg_api "sendPhoto" -s --max-time 30 \
        -X POST \
        -F "chat_id=${chat_id}" \
        -F "caption=${caption}" \
        -F "photo=@${photo_path}" \
        >/dev/null 2>&1 || true
}

tg_send_naive_qr() {
    local chat_id="$1"
    local user="$2"
    local uri="$3"

    if ! command -v qrencode &>/dev/null; then
        tg_reply "${chat_id}" "📦 Устанавливаю qrencode для QR..."
        apt-get install -y -q qrencode >/dev/null 2>&1 || true
    fi

    if command -v qrencode &>/dev/null; then
        local qr_file="/tmp/naiveproxy_qr_${user}_$$.png"
        if qrencode -o "${qr_file}" -s 8 "${uri}" 2>/dev/null && [[ -s "${qr_file}" ]]; then
            tg_send_photo "${chat_id}" "${qr_file}" "📱 Yurich Proxy QR для ${user}@${DOMAIN}"
            rm -f "${qr_file}"
            return 0
        fi
        rm -f "${qr_file}"
    fi

    return 1
}

tg_send_hysteria_qr() {
    local chat_id="$1"
    local user="$2"
    local uri="$3"

    if ! command -v qrencode &>/dev/null; then
        tg_reply "${chat_id}" "📦 Устанавливаю qrencode для Hysteria QR..."
        apt-get install -y -q qrencode >/dev/null 2>&1 || true
    fi

    if command -v qrencode &>/dev/null; then
        local qr_file="/tmp/hysteria_qr_${user}_$$.png"
        if qrencode -o "${qr_file}" -s 8 "${uri}" 2>/dev/null && [[ -s "${qr_file}" ]]; then
            tg_send_photo "${chat_id}" "${qr_file}" "⚡ Hysteria 2 QR для ${user}@${DOMAIN}"
            rm -f "${qr_file}"
            return 0
        fi
        rm -f "${qr_file}"
    fi

    return 1
}

# Обработка одной команды
tg_handle_command() {
    local chat_id="$1"
    local from_id="$2"
    local text="$3"

    # Отключаем строгий режим внутри обработчика — иначе любая ошибка ломает бот
    set +e

    load_config 2>/dev/null || true
    local is_admin=0
    tg_is_admin "${from_id}" && is_admin=1

    # Очищаем text от \r \n и невидимых символов
    text="${text//$'\r'/}"
    text="${text//$'\n'/}"

    # Русские кнопки Telegram reply keyboard -> существующие команды
    case "${text}" in
        "🆔 Мой Telegram ID") text="/myid" ;;
        "🔔 Уведомления") text="/help" ;;
        "📱 Приложения") text="/apps" ;;
        "💬 Поддержка") text="/support" ;;
        "📊 Статус") text="/status" ;;
        "👥 Пользователи") text="/users" ;;
        "➕ Добавить пользователя") text="/adduser" ;;
        "🗑 Удалить пользователя") text="/deluser" ;;
        "📱 QR / ссылка") text="/qr" ;;
        "🔗 Подписка") text="/sub" ;;
        "📰 Новости") text="/news" ;;
        "🧬 Xray") text="/xray" ;;
        "⚡ Hysteria") text="/hysteria" ;;
        "🌀 WARP") text="/warp" ;;
        "🔀 HAProxy") text="/haproxy" ;;
        "🔍 Диагностика") text="/diagnose" ;;
        "📄 Логи") text="/logs" ;;
        "♻️ Restart Caddy") text="/restart" ;;
        "🛠 Автофикс") text="/diagfix" ;;
        "💛 Донат") text="/donate" ;;
        "❓ Помощь") text="/menu" ;;
    esac

    # Лимит длины команды — защита от flood/injection, но новости могут быть длиннее обычных команд.
    if [[ ${#text} -gt 3500 ]]; then
        tg_reply "${chat_id}" "❌ Команда слишком длинная. Максимум 3500 символов."
        return
    fi

    # Парсим команду и аргументы
    local cmd args
    cmd=$(echo "${text}" | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | tr -d '\r\n[:cntrl:]')
    # args = всё после первого пробела
    if [[ "${text}" == *" "* ]]; then
        args="${text#* }"
        # Trim leading/trailing whitespace
        args="${args#"${args%%[![:space:]]*}"}"
        args="${args%"${args##*[![:space:]]}"}"
    else
        args=""
    fi
    # Убираем потенциально опасные символы из args (но оставляем безопасные)
    args=$(echo "${args}" | tr -d '`$();<>&|\\')

    if [[ "$is_admin" -ne 1 ]]; then
        case "${cmd}" in
            /start|/help|/menu)
                tg_reply_menu "${chat_id}" "$(tg_user_welcome_message "${from_id}")" "user"
                ;;
            /myid|/id)
                tg_reply_menu "${chat_id}" "🆔 Твой Telegram ID: <code>${from_id}</code>

Отправь его Ивану Юрьевичу вместе с именем профиля, чтобы подключить уведомления." "user"
                ;;
            /apps)
                tg_reply_menu "${chat_id}" "📱 <b>Приложения Yurich Connect</b>

Android: ${ANDROID_APP_RELEASES_URL}
Windows: ${WINDOWS_APP_RELEASES_URL}" "user"
                ;;
            /support)
                tg_reply_menu "${chat_id}" "💬 <b>Поддержка</b>

Напиши в поддержку: ${TELEGRAM_COMMUNITY_URL}

Не забудь отправить свой Telegram ID: <code>${from_id}</code>" "user"
                ;;
            *)
                tg_reply_menu "${chat_id}" "👋 Это пользовательское меню Yurich Connect.

Твой Telegram ID: <code>${from_id}</code>

Админские команды скрыты. Для уведомлений отправь этот ID Ивану Юрьевичу вместе с именем профиля." "user"
                ;;
        esac
        return
    fi

    case "${cmd}" in

        /start|/help|/menu)
            tg_reply_menu "${chat_id}" "🛡 <b>Yurich Panel v${VERSION}</b>
🖥 Сервер: <code>$(hostname)</code>

Русское меню включено. Кнопки ниже запускают основные действия, а команды руками тоже работают.

<b>Доступные команды:</b>

📊 <b>Информация</b>
/status — статус сервера и сертификата
/stats — статистика трафика и ресурсов
/haproxy — HAProxy SNI mux, маршруты Naive/Reality и SNI-лог
/diagnose — полная диагностика системы
/logs — последние 20 строк логов
/users — список пользователей
/cert — статус TLS сертификата

👥 <b>Пользователи</b>
/adduser логин [пароль] [1-12 мес] — добавить пользователя + QR + подписка
/deluser логин — удалить пользователя + страницу
/qr логин — QR код для подключения
/sub логин — страница подписки пользователя
/subreset логин — перевыпустить ссылку подписки
/expiring — сроки подписок и привязки Telegram
/bindtg логин telegram_id — включить напоминания
/notifyrun — проверить и отправить напоминания
/testnotify логин — тест напоминания
/news_test текст — тест новости себе
/news текст — рассылка новости всем с Telegram ID
/devices — отчёт по лимиту устройств
/lockuser логин — отключить пользователя
/unlockuser логин — вернуть пользователя

🧬 <b>Xray / Modern</b>
/xray логин — ссылки VLESS/Trojan/REALITY
/xrayadduser логин — создать Xray пользователя + подписка
/xraystatus — статус Xray
/hysteria — статус Hysteria 2
/warp — статус и тест WARP proxy

⚙️ <b>Управление</b>
/restart — перезапустить Caddy
/update — обновить Caddy
/selfupdate — обновить скрипт
/diagfix — автофикс диагностики
/privatepage — личная фейковая страница
/admins — список администраторов
/addadmin ID — добавить администратора
/deladmin ID — удалить администратора

💛 /donate — поддержать проект"
            ;;

        /status)
            local caddy_status="🔴 Остановлен"
            systemctl is-active caddy &>/dev/null && caddy_status="🟢 Работает"

            local cert_info=""
            if [[ -n "${DOMAIN:-}" ]]; then
                local not_after expire_ts now_ts cert_days
                not_after=$(echo | timeout 5 openssl s_client                     -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null                     | openssl x509 -noout -dates 2>/dev/null                     | grep "notAfter" | cut -d= -f2 || echo "")
                if [[ -n "${not_after}" ]]; then
                    expire_ts=$(date -d "${not_after}" +%s 2>/dev/null || echo 0)
                    now_ts=$(date +%s)
                    cert_days=$(( (expire_ts - now_ts) / 86400 ))
                    cert_info="
🔐 Сертификат: ${cert_days} дней"
                fi
            fi

            tg_reply "${chat_id}" "📡 <b>Статус Yurich Panel</b>
🖥 Сервер: <code>$(hostname)</code>
${caddy_status}
🌐 Домен: <code>${DOMAIN:-не настроен}</code>
👥 Пользователей: $(get_users | wc -l)
💾 RAM: $(free -h | awk '/Mem:/{print $3"/"$2}')
💿 Диск: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
🕐 $(date '+%Y-%m-%d %H:%M:%S')${cert_info}"
            ;;

        /stats)
            tg_send_stats_to "${chat_id}"
            ;;

        /diagnose)
            tg_reply "${chat_id}" "🔍 Запускаю диагностику, подожди..."
            local diag_result=""
            local pass=0 warn=0 fail=0

            # Caddy
            if systemctl is-active caddy &>/dev/null; then
                diag_result+="✅ Caddy запущен
"
                pass=$((pass+1))
            else
                diag_result+="❌ Caddy НЕ запущен
"
                fail=$((fail+1))
            fi

            # Padding
            local _p
            _p=$(strings /usr/local/bin/caddy 2>/dev/null | grep -cE "^(Padding|SetPadding|WithPadding)$" || true)
            _p="${_p//[^0-9]/}"; _p="${_p:-0}"
            if command -v strings &>/dev/null && [[ "${_p}" -ge 2 ]]; then
                diag_result+="✅ Naive padding OK
"
                pass=$((pass+1))
            else
                diag_result+="⚠️ Padding не проверен
"
                warn=$((warn+1))
            fi

            # Caddyfile
            if grep -qE "^:443,|^http://127\\.0\\.0\\.1:[0-9]+" "${CADDYFILE:-/etc/caddy/Caddyfile}" 2>/dev/null \
                || { edge_routing_mode_is_haproxy && grep -q "^:${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}," "${CADDYFILE:-/etc/caddy/Caddyfile}" 2>/dev/null; }; then
                diag_result+="✅ Caddyfile формат OK
"
                pass=$((pass+1))
            elif grep -qE "^[[:alnum:].-]+:443[[:space:]]*\\{" "${CADDYFILE:-/etc/caddy/Caddyfile}" 2>/dev/null; then
                diag_result+="⚠️ Caddyfile domain:443 ломает Naive CONNECT
"
                warn=$((warn+1))
            else
                diag_result+="❌ Caddyfile неправильный формат
"
                fail=$((fail+1))
            fi

            local hosts_overrides hosts_domains
            hosts_overrides=$(hosts_public_domain_overrides | head -5 || true)
            if [[ -n "$hosts_overrides" ]]; then
                hosts_domains=$(printf '%s\n' "$hosts_overrides" | format_hosts_override_domains)
                diag_result+="⚠️ /etc/hosts: ${hosts_domains}
"
                warn=$((warn+1))
            else
                diag_result+="✅ /etc/hosts clean
"
                pass=$((pass+1))
            fi

            # ALPN
            if [[ -n "${DOMAIN:-}" ]]; then
                local alpn
                alpn=$(echo | timeout 5 openssl s_client                     -connect "${DOMAIN}:443" -alpn h2 2>/dev/null                     | grep -a "ALPN protocol" | awk '{print $3}' || echo "")
                if [[ "${alpn}" == "h2" ]]; then
                    diag_result+="✅ ALPN h2 OK
"
                    pass=$((pass+1))
                else
                    diag_result+="❌ ALPN не h2
"
                    fail=$((fail+1))
                fi
            fi

            # UFW
            if ufw status 2>/dev/null | grep -q "Status: active"; then
                diag_result+="✅ UFW активен
"
                pass=$((pass+1))
            else
                diag_result+="⚠️ UFW неактивен
"
                warn=$((warn+1))
            fi

            # Fail2Ban
            if systemctl is-active fail2ban &>/dev/null; then
                diag_result+="✅ Fail2Ban активен
"
                pass=$((pass+1))
            else
                diag_result+="⚠️ Fail2Ban не запущен
"
                warn=$((warn+1))
            fi

            # RAM
            local ram_pct
            ram_pct=$(free | awk '/Mem:/{printf "%d", $3/$2*100}')
            if [[ ${ram_pct} -lt 90 ]]; then
                diag_result+="✅ RAM: ${ram_pct}%
"
                pass=$((pass+1))
            else
                diag_result+="❌ RAM критически: ${ram_pct}%
"
                fail=$((fail+1))
            fi

            tg_reply "${chat_id}" "🔍 <b>Диагностика Yurich Panel</b>

${diag_result}
✅ Пройдено: ${pass}  ⚠️ Внимание: ${warn}  ❌ Проблемы: ${fail}"
            ;;

        /logs)
            local log_lines
            log_lines=$(journalctl -u caddy -n 20 --no-pager 2>/dev/null                 | tail -20 | sed 's/</\&lt;/g; s/>/\&gt;/g' || echo "Логи недоступны")
            tg_reply "${chat_id}" "📋 <b>Логи Caddy (последние 20):</b>
<pre>${log_lines}</pre>"
            ;;

        /users)
            local user_list
            user_list=$(get_users | awk -F: '{print "• <code>"$1"</code>"}' | head -20 || echo "Нет пользователей")
            tg_reply "${chat_id}" "👥 <b>Пользователи ($(get_users | wc -l)):</b>
${user_list}"
            ;;

        /adduser)
            local new_user new_pass new_months arg2 arg3
            new_user=$(echo "${args}" | awk '{print $1}')
            arg2=$(echo "${args}" | awk '{print $2}')
            arg3=$(echo "${args}" | awk '{print $3}')
            new_months="${arg3:-12}"
            if [[ -n "$arg2" && -z "$arg3" && $(is_valid_user_months "$arg2"; echo $?) -eq 0 ]]; then
                new_pass=""
                new_months="$arg2"
            else
                new_pass="$arg2"
            fi

            if [[ -z "${new_user}" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /adduser логин [пароль] [месяцы 1-12]
Пароль можно не указывать — бот сгенерирует безопасный.
Примеры:
<code>/adduser alice 6</code>
<code>/adduser alice MyPass123 12</code>"
                return
            fi
            if ! is_valid_user_months "$new_months"; then
                tg_reply "${chat_id}" "❌ Срок должен быть от 1 до 12 месяцев"
                return
            fi

            # Валидация логина
            if ! is_valid_proxy_user "${new_user}"; then
                tg_reply "${chat_id}" "❌ Неверный логин <code>${new_user}</code>
Только буквы, цифры, _, - (2-32 символа)"
                return
            fi

            # Валидация пароля (если указан)
            if [[ -z "${new_pass}" ]]; then
                # Авто-генерация
                new_pass=$(random_safe_token 20)
                tg_reply "${chat_id}" "🔑 Пароль не указан, сгенерирован автоматически"
            elif ! is_valid_proxy_pass "${new_pass}"; then
                tg_reply "${chat_id}" "❌ Неверный пароль
Только буквы, цифры, _, - (8-64 символа)"
                return
            fi

            if get_user_pass "${new_user}" >/dev/null; then
                tg_reply "${chat_id}" "❌ Пользователь <code>${new_user}</code> уже существует"
                return
            fi

            # Создаём папку и файл если нет
            mkdir -p "$(dirname "${USERS_FILE}")"
            touch "${USERS_FILE}"
            chmod 600 "${USERS_FILE}"

            local users_backup
            users_backup=$(mktemp)
            cp "${USERS_FILE}" "$users_backup"
            printf '%s:%s\n' "${new_user}" "${new_pass}" >> "${USERS_FILE}"
            set_user_expiry_months "${new_user}" "${new_months}" || true

            if rewrite_caddyfile_current 2>/dev/null; then
                if ! systemctl reload caddy 2>/dev/null && ! systemctl restart caddy 2>/dev/null; then
                    mv "$users_backup" "${USERS_FILE}"
                    cleanup_user_metadata "${new_user}"
                    rewrite_caddyfile_current >/dev/null 2>&1 || true
                    tg_reply "${chat_id}" "❌ Caddy не перезагрузился. Пользователь <code>${new_user}</code> отменён."
                    return
                fi
                rm -f "$users_backup"
                local uri branded_uri sub_url sub_links xray_note xray_tmp xray_ok hy_note hy_uri hy_ok
                uri="naive+https://${new_user}:${new_pass}@${DOMAIN}:443"
                branded_uri=$(yurich_proxy_uri "${new_user}" "${new_pass}" "${new_user}-yurich")
                xray_note=""
                xray_ok=0
                hy_note=""
                hy_uri=""
                hy_ok=0
                if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
                    if sync_hysteria_users_if_active >/dev/null 2>&1; then
                        hy_ok=1
                        hy_uri=$(hysteria_uri_for_user "${new_user}" 2>/dev/null || true)
                        hy_note="⚡ Hysteria 2: создан персональный профиль"
                    else
                        hy_note="⚠️ Hysteria 2: пользователь создан, но конфиг не обновился"
                    fi
                fi
                if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
                    xray_tmp=$(mktemp)
                    if provision_xray_user "${new_user}" > "$xray_tmp" 2>&1; then
                        xray_ok=1
                        xray_note="🧬 Xray/VLESS: создан для этого же пользователя"
                    else
                        xray_note="⚠️ Xray/VLESS: Naive создан, но Xray профиль не применён"
                    fi
                fi
                sub_url=$(generate_subscription_page "${new_user}" 2>/dev/null || true)
                sub_links="${sub_url:+${sub_url}links.txt}"
                tg_reply "${chat_id}" "✅ <b>Пользователь добавлен</b>
👤 Логин: <code>${new_user}</code>
🔑 Пароль: <code>${new_pass}</code>
📅 Срок: <code>$(user_expiry_label "${new_user}")</code>
${hy_note}
${xray_note}
🌐 Yurich Proxy:
<code>${branded_uri}</code>

Совместимый URI:
<code>${uri}</code>

⚡ Hysteria 2:
<code>${hy_uri:-не создано}</code>

📄 Страница:
<code>${sub_url:-не создана автоматически}</code>

Raw links:
<code>${sub_links:-не создано}</code>"
                if ! tg_send_naive_qr "${chat_id}" "${new_user}" "${uri}"; then
                    tg_reply "${chat_id}" "⚠️ QR не удалось создать автоматически. URI выше рабочий."
                fi
                if [[ "$hy_ok" -eq 1 && -n "$hy_uri" ]]; then
                    tg_send_hysteria_qr "${chat_id}" "${new_user}" "$hy_uri" || true
                fi
                if [[ "$xray_ok" -eq 1 ]]; then
                    local x_links
                    x_links=$(print_xray_client_config "${new_user}" 2>&1)
                    tg_reply_pre "${chat_id}" "🧬 Xray ссылки для ${new_user}" "$x_links"
                elif [[ -n "${xray_tmp:-}" && -f "$xray_tmp" ]]; then
                    tg_reply_file_tail "${chat_id}" "⚠️ Xray профиль не применён" "$xray_tmp" 60
                fi
                [[ -n "${xray_tmp:-}" ]] && rm -f "$xray_tmp"
            else
                mv "$users_backup" "${USERS_FILE}"
                cleanup_user_metadata "${new_user}"
                tg_reply "${chat_id}" "❌ Caddyfile не обновлён. Пользователь <code>${new_user}</code> отменён."
            fi
            ;;

        /deluser)
            local del_user="${args%% *}"
            if [[ -z "${del_user}" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /deluser логин"
                return
            fi

            if ! is_valid_proxy_user "${del_user}" || ! subscription_user_exists "${del_user}"; then
                tg_reply "${chat_id}" "❌ Пользователь <code>${del_user}</code> не найден"
                return
            fi

            if ! delete_subscription_user_everywhere "${del_user}"; then
                tg_reply "${chat_id}" "❌ Не удалось полностью удалить <code>${del_user}</code>. Проверь логи панели."
                return
            fi

            tg_reply "${chat_id}" "🗑 Пользователь <code>${del_user}</code> полностью удалён
📄 Подписка, token и публичные ссылки тоже удалены"
            ;;

        /qr)
            local qr_user="${args%% *}"
            # Если args содержит ":" — значит это конкретный логин с двоеточием (не должно быть)
            if [[ -z "${qr_user}" ]]; then
                # QR для первого пользователя
                qr_user=$(get_users | head -1 | cut -d: -f1)
            fi

            if [[ -z "${qr_user}" ]]; then
                tg_reply "${chat_id}" "❌ Нет пользователей. Добавь: /adduser логин пароль"
                return
            fi

            local qr_pass
            qr_pass=$(get_user_pass "${qr_user}" || true)

            if [[ -z "${qr_pass}" ]]; then
                tg_reply "${chat_id}" "❌ Пользователь <code>${qr_user}</code> не найден
Список пользователей: /users"
                return
            fi

            if [[ -z "${DOMAIN:-}" ]]; then
                tg_reply "${chat_id}" "❌ Домен не настроен в конфиге"
                return
            fi

            local uri branded_uri
            uri="naive+https://${qr_user}:${qr_pass}@${DOMAIN}:443"
            branded_uri=$(yurich_proxy_uri "${qr_user}" "${qr_pass}" "${qr_user}-yurich")

            # Авто-установка qrencode если нет
            if ! command -v qrencode &>/dev/null; then
                tg_reply "${chat_id}" "📦 Устанавливаю qrencode..."
                apt-get install -y -q qrencode &>/dev/null
            fi

            if command -v qrencode &>/dev/null; then
                local qr_file="/tmp/naiveproxy_qr_${qr_user}_$$.png"
                if qrencode -o "${qr_file}" -s 8 "${uri}" 2>/dev/null && [[ -s "${qr_file}" ]]; then
                    tg_send_photo "${chat_id}" "${qr_file}" "📱 Yurich Proxy QR для ${qr_user}@${DOMAIN}"
                    # Дополнительно отправляем URI текстом
                    tg_reply "${chat_id}" "🔗 <b>Yurich Proxy:</b>
<code>${branded_uri}</code>

<b>Совместимый URI:</b>
<code>${uri}</code>"
                    rm -f "${qr_file}"
                else
                    tg_reply "${chat_id}" "⚠️ Ошибка генерации QR
Yurich Proxy: <code>${branded_uri}</code>
Совместимый URI: <code>${uri}</code>"
                fi
            else
                tg_reply "${chat_id}" "📱 <b>Yurich Proxy для ${qr_user}:</b>
<code>${branded_uri}</code>

<b>Совместимый URI:</b>
<code>${uri}</code>
(установи qrencode на сервере для QR картинки)"
            fi
            ;;

        /sub)
            local sub_user="${args%% *}"
            if [[ -z "${sub_user}" ]]; then
                sub_user=$(get_users | head -1 | cut -d: -f1)
                [[ -z "$sub_user" && -s "$XRAY_USERS_FILE" ]] && sub_user=$(head -1 "$XRAY_USERS_FILE" | cut -d: -f1)
            fi
            if [[ -z "$sub_user" ]]; then
                tg_reply "${chat_id}" "❌ Нет пользователей. Создай Naive или Xray пользователя."
                return
            fi
            local sub_out sub_rc
            sub_out=$(generate_subscription_page "$sub_user" 2>&1)
            sub_rc=$?
            if [[ "$sub_rc" -eq 0 ]]; then
                tg_reply "${chat_id}" "🔗 <b>Подписка для ${sub_user}</b>
<code>${sub_out}</code>

Raw links:
<code>${sub_out}links.txt</code>"
            else
                tg_reply_pre "${chat_id}" "❌ Ошибка создания подписки" "$sub_out"
            fi
            ;;

        /subreset)
            local reset_user="${args%% *}"
            if [[ -z "$reset_user" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /subreset логин"
                return
            fi
            local reset_out reset_rc
            reset_out=$(cmd_subscription_reset "$reset_user" 2>&1)
            reset_rc=$?
            if [[ "$reset_rc" -eq 0 ]]; then
                tg_reply_pre "${chat_id}" "✅ Подписка перевыпущена" "$reset_out"
            else
                tg_reply_pre "${chat_id}" "❌ Ошибка перевыпуска подписки" "$reset_out"
            fi
            ;;

        /expiring|/expires|/notifylist)
            local exp_tmp
            exp_tmp=$(mktemp)
            cmd_notify_expiry_list > "$exp_tmp" 2>&1
            tg_reply_file_tail "${chat_id}" "📅 <b>Сроки подписок</b>" "$exp_tmp" 120
            rm -f "$exp_tmp"
            ;;

        /bindtg|/tgbind)
            local bind_user bind_chat bind_tmp bind_rc
            bind_user=$(echo "${args}" | awk '{print $1}')
            bind_chat=$(echo "${args}" | awk '{print $2}')
            if [[ -z "$bind_user" || -z "$bind_chat" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /bindtg логин telegram_id"
                return
            fi
            bind_tmp=$(mktemp)
            cmd_notify_bind_tg "$bind_user" "$bind_chat" > "$bind_tmp" 2>&1
            bind_rc=$?
            if [[ "$bind_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Telegram ID привязан</b>" "$bind_tmp" 40
            else
                tg_reply_file_tail "${chat_id}" "❌ <b>Telegram ID не привязан</b>" "$bind_tmp" 40
            fi
            rm -f "$bind_tmp"
            ;;

        /untg|/unbindtg)
            local unbind_user unbind_tmp unbind_rc
            unbind_user="${args%% *}"
            if [[ -z "$unbind_user" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /untg логин"
                return
            fi
            unbind_tmp=$(mktemp)
            cmd_notify_unbind_tg "$unbind_user" > "$unbind_tmp" 2>&1
            unbind_rc=$?
            if [[ "$unbind_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Telegram уведомления отключены</b>" "$unbind_tmp" 40
            else
                tg_reply_file_tail "${chat_id}" "❌ <b>Не удалось отключить Telegram</b>" "$unbind_tmp" 40
            fi
            rm -f "$unbind_tmp"
            ;;

        /notifyrun|/notifynow)
            local notify_tmp notify_rc
            notify_tmp=$(mktemp)
            cmd_notify_expiry_run > "$notify_tmp" 2>&1
            notify_rc=$?
            if [[ "$notify_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "🔔 <b>Проверка уведомлений выполнена</b>" "$notify_tmp" 40
            else
                tg_reply_file_tail "${chat_id}" "⚠️ <b>Проверка уведомлений с ошибками</b>" "$notify_tmp" 40
            fi
            rm -f "$notify_tmp"
            ;;

        /testnotify)
            local test_user test_tmp test_rc
            test_user="${args%% *}"
            if [[ -z "$test_user" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /testnotify логин"
                return
            fi
            test_tmp=$(mktemp)
            cmd_notify_expiry_test "$test_user" > "$test_tmp" 2>&1
            test_rc=$?
            if [[ "$test_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Тест отправлен</b>" "$test_tmp" 40
            else
                tg_reply_file_tail "${chat_id}" "❌ <b>Тест не отправлен</b>" "$test_tmp" 40
            fi
            rm -f "$test_tmp"
            ;;

        /news_test|/newstest|/broadcast_test|/broadcasttest)
            local news_test_tmp news_test_rc
            if [[ -z "$args" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /news_test текст новости

Пример:
<code>/news_test Обновили профили и улучшили стабильность подключения.</code>"
                return
            fi
            news_test_tmp=$(mktemp)
            cmd_notify_news_test "$args" "$chat_id" > "$news_test_tmp" 2>&1
            news_test_rc=$?
            if [[ "$news_test_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Тест новости отправлен</b>" "$news_test_tmp" 40
            else
                tg_reply_file_tail "${chat_id}" "❌ <b>Тест новости не отправлен</b>" "$news_test_tmp" 40
            fi
            rm -f "$news_test_tmp"
            ;;

        /news|/broadcast)
            local news_tmp news_rc
            if [[ -z "$args" ]]; then
                tg_reply "${chat_id}" "📰 <b>Рассылка новостей Yurich Connect</b>

Сначала проверь внешний вид:
<code>/news_test текст новости</code>

Потом отправь всем пользователям с привязанным Telegram ID:
<code>/news текст новости</code>"
                return
            fi
            news_tmp=$(mktemp)
            cmd_notify_news_broadcast "$args" > "$news_tmp" 2>&1
            news_rc=$?
            if [[ "$news_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Новость разослана</b>" "$news_tmp" 40
            else
                tg_reply_file_tail "${chat_id}" "⚠️ <b>Рассылка завершилась с проблемами</b>" "$news_tmp" 40
            fi
            rm -f "$news_tmp"
            ;;

        /devices)
            local dev_tmp dev_rc
            dev_tmp=$(mktemp)
            cmd_devices_scan > "$dev_tmp" 2>&1
            dev_rc=$?
            if [[ "$dev_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "📱 <b>Лимит устройств</b>" "$dev_tmp" 80
            else
                tg_reply_file_tail "${chat_id}" "⚠️ <b>Лимит устройств</b>" "$dev_tmp" 80
            fi
            rm -f "$dev_tmp"
            ;;

        /lockuser)
            local lock_user="${args%% *}"
            if [[ -z "$lock_user" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /lockuser логин"
                return
            fi
            local lock_out lock_rc
            lock_out=$(device_disable_user "$lock_user" 2>&1)
            lock_rc=$?
            if [[ "$lock_rc" -eq 0 ]]; then
                tg_reply_pre "${chat_id}" "🔒 Пользователь отключён" "$lock_out"
            else
                tg_reply_pre "${chat_id}" "❌ Не удалось отключить пользователя" "$lock_out"
            fi
            ;;

        /unlockuser)
            local unlock_user="${args%% *}"
            if [[ -z "$unlock_user" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /unlockuser логин"
                return
            fi
            local unlock_out unlock_rc
            unlock_out=$(device_enable_user "$unlock_user" 2>&1)
            unlock_rc=$?
            if [[ "$unlock_rc" -eq 0 ]]; then
                tg_reply_pre "${chat_id}" "🔓 Пользователь возвращён" "$unlock_out"
            else
                tg_reply_pre "${chat_id}" "❌ Не удалось вернуть пользователя" "$unlock_out"
            fi
            ;;

        /xray)
            local x_user="${args%% *}"
            if [[ ! -s "$XRAY_USERS_FILE" ]]; then
                tg_reply "${chat_id}" "❌ Xray пользователи не найдены. Сначала настрой Xray: sudo bash yurich-panel.sh xray-install"
                return
            fi
            [[ -z "$x_user" ]] && x_user=$(head -1 "$XRAY_USERS_FILE" | cut -d: -f1)
            local x_out x_rc
            x_out=$(print_xray_client_config "$x_user" 2>&1)
            x_rc=$?
            if [[ "$x_rc" -eq 0 ]]; then
                tg_reply_pre "${chat_id}" "🧬 Xray ссылки для ${x_user}" "$x_out"
            else
                tg_reply_pre "${chat_id}" "❌ Xray config недоступен" "$x_out"
            fi
            ;;

        /xrayadduser|/xrayuser)
            local x_new x_months
            x_new=$(echo "${args}" | awk '{print $1}')
            x_months=$(echo "${args}" | awk '{print $2}')
            x_months="${x_months:-12}"
            if [[ -z "$x_new" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /xrayadduser логин [месяцы 1-12]"
                return
            fi
            if ! is_valid_user_months "$x_months"; then
                tg_reply "${chat_id}" "❌ Срок должен быть от 1 до 12 месяцев"
                return
            fi
            local xa_tmp xa_rc
            xa_tmp=$(mktemp)
            cmd_xray_add_user "$x_new" "$x_months" > "$xa_tmp" 2>&1
            xa_rc=$?
            if [[ "$xa_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Xray пользователь создан</b>" "$xa_tmp" 100
            else
                tg_reply_file_tail "${chat_id}" "❌ <b>Xray пользователь не создан</b>" "$xa_tmp" 100
            fi
            rm -f "$xa_tmp"
            ;;

        /xraystatus)
            local xs_tmp
            xs_tmp=$(mktemp)
            cmd_xray_status > "$xs_tmp" 2>&1
            tg_reply_file_tail "${chat_id}" "🧬 <b>Xray статус</b>" "$xs_tmp" 80
            rm -f "$xs_tmp"
            ;;

        /hysteria|/hy2|/hysteriastatus|/hy2status)
            local hy_tmp
            hy_tmp=$(mktemp)
            cmd_hysteria_status > "$hy_tmp" 2>&1
            tg_reply_file_tail "${chat_id}" "⚡ <b>Hysteria 2 статус</b>" "$hy_tmp" 80
            rm -f "$hy_tmp"
            ;;

        /warp|/warpstatus)
            local warp_tmp
            warp_tmp=$(mktemp)
            cmd_warp_status > "$warp_tmp" 2>&1
            echo >> "$warp_tmp"
            cmd_warp_test >> "$warp_tmp" 2>&1 || true
            tg_reply_file_tail "${chat_id}" "🌀 <b>WARP proxy статус</b>" "$warp_tmp" 100
            rm -f "$warp_tmp"
            ;;

        /haproxy|/sni|/sni_mux)
            local hap_tmp
            hap_tmp=$(mktemp)
            cmd_haproxy_status > "$hap_tmp" 2>&1
            tg_reply_file_tail "${chat_id}" "🔀 <b>HAProxy SNI mux</b>" "$hap_tmp" 120
            rm -f "$hap_tmp"
            ;;

        /diagfix)
            local fix_tmp fix_rc
            fix_tmp=$(mktemp)
            tg_reply "${chat_id}" "🛠 Запускаю автофикс, подожди..."
            cmd_diagnose_fix > "$fix_tmp" 2>&1
            fix_rc=$?
            if [[ "$fix_rc" -eq 0 ]]; then
                tg_reply_file_tail "${chat_id}" "✅ <b>Автофикс завершён</b>" "$fix_tmp" 80
            else
                tg_reply_file_tail "${chat_id}" "⚠️ <b>Автофикс завершился с ошибкой</b>" "$fix_tmp" 80
            fi
            rm -f "$fix_tmp"
            ;;

        /privatepage)
            local private_out private_rc
            private_out=$(install_private_camouflage_page 2>&1)
            private_rc=$?
            if [[ "$private_rc" -eq 0 ]]; then
                tg_reply_pre "${chat_id}" "🎭 Личная фейковая страница" "$private_out"
            else
                tg_reply_pre "${chat_id}" "❌ Ошибка личной страницы" "$private_out"
            fi
            ;;

        /donate)
            local donate_link donate_label
            donate_link="${PROJECT_DONATION_URL:-$PROJECT_GITHUB_URL}"
            donate_label="$([[ -n "${PROJECT_DONATION_URL:-}" ]] && printf 'Поддержать проект' || printf 'GitHub проекта')"
            tg_reply "${chat_id}" "💛 <b>Поддержать проект</b>

Если Yurich Panel помог тебе — поддержи разработку!

👉 <a href=\"$(html_escape_text "$donate_link")\">$(html_escape_text "$donate_label")</a>

<b>Что даст твой донат:</b>
🚀 Больше времени на разработку
🐛 Быстрые фиксы багов
✨ Новые фичи каждый месяц
📚 Документация и поддержка

<b>Спасибо за поддержку! 🙏</b>"
            ;;

        /cert)
            if [[ -z "${DOMAIN:-}" ]]; then
                tg_reply "${chat_id}" "❌ Домен не настроен"
                return
            fi
            local cert_out
            cert_out=$(echo | timeout 5 openssl s_client                 -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null                 | openssl x509 -noout -dates -issuer 2>/dev/null || echo "")
            if [[ -z "${cert_out}" ]]; then
                tg_reply "${chat_id}" "❌ Не удалось получить сертификат для ${DOMAIN}"
                return
            fi
            local not_after issuer cert_days
            not_after=$(echo "${cert_out}" | grep "notAfter" | cut -d= -f2)
            issuer=$(echo "${cert_out}" | grep "issuer" | grep -oP 'O=\K[^,]+' || echo "н/д")
            expire_ts=$(date -d "${not_after}" +%s 2>/dev/null || echo 0)
            cert_days=$(( ($(date +%s) - expire_ts) / -86400 ))
            local cert_icon="🟢"
            [[ ${cert_days} -lt 30 ]] && cert_icon="🟡"
            [[ ${cert_days} -lt 7 ]] && cert_icon="🔴"
            tg_reply "${chat_id}" "${cert_icon} <b>TLS Сертификат</b>
🌐 Домен: <code>${DOMAIN}</code>
📅 Истекает: ${not_after}
⏳ Осталось: <b>${cert_days} дней</b>
🏢 Выдан: ${issuer}"
            ;;

        /restart)
            tg_reply "${chat_id}" "🔄 Перезапускаю Caddy..."
            if systemctl restart caddy 2>/dev/null; then
                sleep 2
                tg_reply "${chat_id}" "✅ Caddy перезапущен"
            else
                tg_reply "${chat_id}" "❌ Ошибка перезапуска. Проверь: journalctl -u caddy -n 20"
            fi
            ;;

        /update)
            tg_reply "${chat_id}" "🔄 Обновляю Caddy, подожди 5-15 минут..."
            local _script
            _script="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}"
            if [[ ! -f "${_script}" ]]; then
                tg_reply "${chat_id}" "❌ Скрипт не найден: ${_script}"
                return
            fi
            if bash "${_script}" update >/dev/null 2>&1; then
                tg_reply "${chat_id}" "✅ Caddy обновлён"
            else
                tg_reply "${chat_id}" "❌ Ошибка обновления Caddy"
            fi
            ;;

        /selfupdate)
            tg_reply "${chat_id}" "⬆️ Проверяю обновления скрипта..."
            local latest_ver
            latest_ver=$(curl -s --max-time 8 "${GITHUB_RAW}" 2>/dev/null                 | grep '^VERSION=' | grep -oP '"\K[^"]+' || echo "")
            if [[ -z "${latest_ver}" ]]; then
                tg_reply "${chat_id}" "❌ Не удалось проверить обновления"
            elif [[ "${latest_ver}" == "${VERSION}" ]]; then
                tg_reply "${chat_id}" "✅ Скрипт актуален: v${VERSION}"
            else
                tg_reply "${chat_id}" "⬆️ Доступно обновление v${VERSION} → v${latest_ver}
Запусти на сервере: sudo bash yurich-panel.sh self-update"
            fi
            ;;

        /admins)
            local admin_list="• Главный: <code>${TG_CHAT_ID}</code>"
            if [[ -n "${TG_ADMINS:-}" ]]; then
                local IFS=','
                for aid in ${TG_ADMINS}; do
                    aid="${aid// /}"
                    admin_list+="
• <code>${aid}</code>"
                done
            fi
            tg_reply "${chat_id}" "👮 <b>Администраторы:</b>
${admin_list}"
            ;;

        /addadmin)
            local new_admin="${args%% *}"
            # Защита: только числа, разумная длина
            if [[ -z "${new_admin}" || ! "${new_admin}" =~ ^[0-9]{5,15}$ ]]; then
                tg_reply "${chat_id}" "❌ Использование: /addadmin 123456789"
                return
            fi
            if [[ -z "${TG_ADMINS}" ]]; then
                TG_ADMINS="${new_admin}"
            else
                TG_ADMINS="${TG_ADMINS},${new_admin}"
            fi
            save_config
            tg_reply "${chat_id}" "✅ Администратор <code>${new_admin}</code> добавлен"
            ;;

        /deladmin)
            local del_admin="${args%% *}"
            if [[ -z "${del_admin}" || ! "${del_admin}" =~ ^[0-9]{5,15}$ ]]; then
                tg_reply "${chat_id}" "❌ Использование: /deladmin 123456789"
                return
            fi
            TG_ADMINS=$(echo "${TG_ADMINS}" | tr ',' '
'                 | grep -Fvx "${del_admin}" | tr '
' ',' | sed 's/,$//')
            save_config
            tg_reply "${chat_id}" "🗑 Администратор <code>${del_admin}</code> удалён"
            ;;

        *)
            tg_reply_menu "${chat_id}" "❓ Неизвестная команда. Используй /help или кнопки меню."
            ;;
    esac
}

# Основной цикл бота (long polling)
cmd_bot() {
    [[ -z "${TG_TOKEN:-}" ]] && err "Telegram не настроен. Запусти: sudo bash yurich-panel.sh" && return 1

    tg_apply_bot_menu_silent
    info "Запускаю Telegram бот..."
    info "Бот работает. Нажми Menu или напиши /menu в Telegram."
    info "Для остановки: Ctrl+C"
    echo

    local offset=0

    while true; do
        # Получаем обновления
        local response
        response=$(tg_api "getUpdates?offset=${offset}&timeout=30&allowed_updates=%5B%22message%22%5D" -s --max-time 35 \
            2>/dev/null || echo "")

        if [[ -z "${response}" ]]; then
            sleep 5
            continue
        fi

        # Парсим обновления через python3
        local updates
        updates=$(echo "${response}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if not data.get('ok'): sys.exit(0)
    for u in data.get('result', []):
        uid = u.get('update_id', 0)
        msg = u.get('message', {})
        chat_id = msg.get('chat', {}).get('id', '')
        from_id = msg.get('from', {}).get('id', '')
        text = str(msg.get('text') or '')
        if text:
            text = text.replace('|', ' ').replace('\\r', ' ').replace('\\n', ' ')
            print(f'{uid}|{chat_id}|{from_id}|{text}')
except: pass
" 2>/dev/null || echo "")

        while IFS='|' read -r update_id chat_id from_id text; do
            [[ -z "${update_id}" ]] && continue
            # Защита от переполнения
            if [[ "${update_id}" =~ ^[0-9]+$ ]] && [[ ${update_id} -lt 2147483647 ]]; then
                offset=$(( update_id + 1 ))
            fi
            tg_handle_command "${chat_id}" "${from_id}" "${text}"
        done <<< "${updates}"

        sleep 1
    done
}

# Запуск бота как systemd сервиса
install_bot_service() {
    local script_path="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}"
    local running_script

    running_script=$(realpath "$0" 2>/dev/null || echo "")
    mkdir -p "$(dirname "$script_path")"
    if [[ -n "$running_script" && -f "$running_script" && "$running_script" != /dev/fd/* && "$running_script" != /proc/* ]]; then
        if bash -n "$running_script" 2>/dev/null; then
            install -m 755 "$running_script" "$script_path" 2>/dev/null || true
        fi
    fi

    if [[ ! -f "$script_path" ]]; then
        err "Не найден ${script_path}. Сначала обнови скрипт: sudo bash yurich-panel.sh self-update"
        return 1
    fi
    chmod +x "$script_path" 2>/dev/null || true
    if [[ -n "${LEGACY_SCRIPT_PATH:-}" && "$script_path" != "$LEGACY_SCRIPT_PATH" ]]; then
        install -m 755 "$script_path" "$LEGACY_SCRIPT_PATH" 2>/dev/null || true
    fi

    cat > /etc/systemd/system/naiveproxy-bot.service << EOF
[Unit]
Description=Yurich Panel Telegram Bot
After=network-online.target caddy.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/bin/bash ${script_path} bot
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable naiveproxy-bot --quiet
    tg_apply_bot_menu || warn "Команды Telegram Menu можно применить позже: sudo bash yurich-panel.sh bot-menu"
    systemctl restart naiveproxy-bot
    ok "Telegram бот установлен как системный сервис"
    ok "Статус: systemctl status naiveproxy-bot"
}

# Обёртка tg_send_stats_to для отправки конкретному chat_id
tg_send_stats_to() {
    local target_chat="$1"
    local caddy_ver
    caddy_ver=$(/usr/local/bin/caddy version 2>/dev/null | head -1 | awk '{print $1}' || echo "н/д")

    local caddy_status="🔴 Остановлен"
    systemctl is-active caddy &>/dev/null && caddy_status="🟢 Работает"

    local cert_days="н/д"
    if [[ -n "${DOMAIN:-}" ]]; then
        local not_after expire_ts
        not_after=$(echo | timeout 5 openssl s_client             -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null             | openssl x509 -noout -dates 2>/dev/null             | grep "notAfter" | cut -d= -f2 || echo "")
        if [[ -n "${not_after}" ]]; then
            expire_ts=$(date -d "${not_after}" +%s 2>/dev/null || echo 0)
            cert_days=$(( (expire_ts - $(date +%s)) / 86400 ))
        fi
    fi

    local haproxy_raw="" haproxy_block=""
    if edge_routing_mode_is_haproxy; then
        haproxy_raw=$(haproxy_stats_text 2>/dev/null | head -n 18 || true)
        if [[ -n "$haproxy_raw" ]]; then
            haproxy_block=$'\n\n🔀 <b>HAProxy SNI mux</b>\n<pre>'"$(html_escape_text "$haproxy_raw")"$'</pre>'
        fi
    fi

    tg_reply "${target_chat}" "📊 <b>Статистика Yurich Panel</b>

🌐 Домен: <code>${DOMAIN:-н/д}</code>
📡 Статус: ${caddy_status}
📦 Caddy: <code>${caddy_ver}</code>
👥 Пользователей: $(get_users | wc -l)

🖥 Сервер: <code>$(hostname)</code>
💾 RAM: $(free -h | awk '/Mem:/{print $3"/"$2}')
💿 Диск: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
⚡ CPU: $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')

🔐 Сертификат: ${cert_days} дней
🕐 $(date '+%Y-%m-%d %H:%M:%S')${haproxy_block}"
}


# ══════════════════════════════════════════════════════════════
#   YURICH DNS (Unbound recursive resolver for VPN clients)
# ══════════════════════════════════════════════════════════════

DNS_CONF="/etc/unbound/unbound.conf.d/yurich-dns.conf"
DNS_BLOCKLIST_CONF="/etc/unbound/unbound.conf.d/yurich-dns-blocklist.conf"
DNS_ALLOWLIST_FILE="/etc/naiveproxy/dns-allowlist.txt"
DNS_FILTER_STATE_FILE="/etc/naiveproxy/dns-filter.state"
DNS_FILTER_CRON="/etc/cron.d/yurich-dns-filter"
DNS_FILTER_MONITOR_CRON="/etc/cron.d/yurich-dns-monitor"
DNS_FILTER_LOG="/var/log/yurich-dns-filter.log"
DNS_FILTER_MONITOR_LOG="/var/log/yurich-dns-monitor.log"
DNS_FILTER_URLS_DEFAULT="https://urlhaus.abuse.ch/downloads/hostfile/ https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif.mini.txt"
DNS_FILTER_MAX_DOMAINS_DEFAULT="200000"
DNS_LEGACY_OLD_DNS_CONF="/etc/unbound/unbound.conf.d/aurum-vpn.conf"
DNS_LEGACY_CONF="/etc/unbound/unbound.conf.d/naiveproxy-dns.conf"
DNS_LEGACY_BLOCKLIST="/etc/unbound/blocklist.conf"
DNS_LEGACY_WHITELIST="/etc/unbound/whitelist.txt"
DNS_RESOLVED_NO_STUB="/etc/systemd/resolved.conf.d/no-stub.conf"
DNS_GATEWAY_SERVICE="/etc/systemd/system/yurich-dns-gateway.service"
DNS_LEGACY_GATEWAY_SERVICE="/etc/systemd/system/aurum-dns-gateway.service"
DNS_DEFAULT_GATEWAY_IP="10.0.0.1"
DNS_DEFAULT_VPN_CIDRS="10.0.0.0/24"
DNS_STATS_FILE="/etc/naiveproxy/dns_stats"

is_valid_ipv4() {
    local ip="$1" part
    local -a oct
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS='.' read -r -a oct <<< "$ip"
    for part in "${oct[@]}"; do
        [[ "$part" =~ ^[0-9]+$ && "$part" -ge 0 && "$part" -le 255 ]] || return 1
    done
}

is_valid_cidr4() {
    local cidr="$1" ip part
    local -a oct
    [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]] || return 1
    ip="${cidr%/*}"
    IFS='.' read -r -a oct <<< "$ip"
    for part in "${oct[@]}"; do
        [[ "$part" =~ ^[0-9]+$ && "$part" -ge 0 && "$part" -le 255 ]] || return 1
    done
}

normalize_cidr_list() {
    local raw="$1" item out=""
    local -a cidrs
    raw="${raw// /}"
    IFS=',' read -ra cidrs <<< "$raw"
    for item in "${cidrs[@]}"; do
        [[ -z "$item" ]] && continue
        if ! is_valid_cidr4 "$item"; then
            err "Некорректная VPN CIDR подсеть: $item"
            return 1
        fi
        if [[ "${item#*/}" == "0" ]]; then
            err "Open resolver запрещён: маска /0 использовать нельзя"
            return 1
        fi
        out="${out},${item}"
    done
    if [[ -z "$out" ]]; then
        err "Нужна хотя бы одна VPN CIDR подсеть"
        return 1
    fi
    printf '%s\n' "${out#,}"
}

unbound_mode_label() {
    echo "Yurich recursive DNSSEC"
}

dns_config_backup() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    cp -a "$file" "${file}.bak.$(date '+%Y%m%d-%H%M%S')" 2>/dev/null || true
}

get_unbound_vpn_bind_ips() {
    command -v ip >/dev/null 2>&1 || return 0
    ip -o -4 addr show scope global up 2>/dev/null \
        | awk '{split($4, a, "/"); if (a[1] != "" && a[1] !~ /^127\./ && a[1] !~ /^169\.254\./) print a[1]}' \
        | sort -u
}

ip_is_on_server() {
    local ip_addr="$1"
    [[ "$ip_addr" == "127.0.0.1" ]] && return 0
    get_unbound_vpn_bind_ips | grep -Fxq "$ip_addr"
}

ensure_managed_dns_gateway() {
    local gateway_ip="$1"
    local ip_bin
    is_valid_ipv4 "$gateway_ip" || return 1
    ip_bin=$(command -v ip || echo "/usr/sbin/ip")

    cat > "$DNS_GATEWAY_SERVICE" <<EOF
[Unit]
Description=DNS (Unbound) local gateway IP (${gateway_ip})
Before=unbound.service
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c '${ip_bin} addr replace ${gateway_ip}/32 dev lo && ${ip_bin} link set lo up'
ExecStop=/bin/sh -c '${ip_bin} addr del ${gateway_ip}/32 dev lo 2>/dev/null || true'

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now "$(basename "$DNS_GATEWAY_SERVICE")" >/dev/null 2>&1 || {
        err "Не смог запустить $(basename "$DNS_GATEWAY_SERVICE")"
        journalctl -u "$(basename "$DNS_GATEWAY_SERVICE")" -n 20 --no-pager || true
        return 1
    }
    ip addr show dev lo | grep -q "${gateway_ip}/32" || {
        err "Gateway IP ${gateway_ip} не появился на lo"
        return 1
    }
    ok "Локальный DNS gateway поднят: ${gateway_ip}/32 на lo"
}

remove_managed_dns_gateway() {
    systemctl disable --now "$(basename "$DNS_GATEWAY_SERVICE")" >/dev/null 2>&1 || true
    systemctl disable --now "$(basename "$DNS_LEGACY_GATEWAY_SERVICE")" >/dev/null 2>&1 || true
    rm -f "$DNS_GATEWAY_SERVICE" "$DNS_LEGACY_GATEWAY_SERVICE" 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
}

prepare_unbound_gateway_ip() {
    local gateway_ip="$1"
    local ans

    if ip_is_on_server "$gateway_ip"; then
        UNBOUND_MANAGED_GATEWAY="0"
        return 0
    fi

    warn "IP ${gateway_ip} не найден на интерфейсах сервера."
    echo -e "${CYAN}Могу создать безопасный локальный DNS gateway ${gateway_ip}/32 на lo.${RESET}"
    echo -e "${DIM}Это нужно, чтобы Unbound мог слушать DNS для клиентских TUN/VPN конфигов. Наружу DNS всё равно не открывается.${RESET}"
    if [[ -t 0 ]]; then
        echo -ne "${YELLOW}Создать автоматически? [Y/n]: ${RESET}"
        read -r ans
    else
        ans="y"
    fi
    if [[ "${ans,,}" == "n" ]]; then
        err "Gateway не создан. Сначала подними VPN-интерфейс с IP ${gateway_ip} или разреши авто-gateway."
        return 1
    fi

    ensure_managed_dns_gateway "$gateway_ip" || return 1
    UNBOUND_MANAGED_GATEWAY="1"
}

detect_private_dns_gateway() {
    get_unbound_vpn_bind_ips \
        | awk '/^10\./ || /^192\.168\./ || /^172\.(1[6-9]|2[0-9]|3[0-1])\./ { print; exit }'
}

disable_resolved_stub_if_needed() {
    if ! command -v systemctl >/dev/null 2>&1 || ! systemctl cat systemd-resolved.service >/dev/null 2>&1; then
        return 0
    fi
    if port53_listeners | grep -qi 'systemd-resolve'; then
        info "Порт 53 занят systemd-resolved stub, отключаю DNSStubListener..."
        mkdir -p "$(dirname "$DNS_RESOLVED_NO_STUB")"
        dns_config_backup "$DNS_RESOLVED_NO_STUB"
        cat > "$DNS_RESOLVED_NO_STUB" <<'EOF'
[Resolve]
DNSStubListener=no
EOF
        systemctl restart systemd-resolved 2>/dev/null || true
        sleep 1
        ok "systemd-resolved DNSStubListener отключён без изменения /etc/resolv.conf"
    fi
}

port53_listeners() {
    ss -H -lntup 2>/dev/null | awk '$5 ~ /:53$/ || $5 ~ /:53%/ {print}'
}

check_port53_for_yurich_dns() {
    local conflicts
    conflicts=$(port53_listeners | grep -Ev 'unbound|systemd-resolve|systemd-resolved' || true)
    if [[ -n "$conflicts" ]]; then
        err "Порт 53 занят другим сервисом. DNS (Unbound) не будет ломать его автоматически:"
        echo "$conflicts"
        return 1
    fi
}

cleanup_legacy_dns_files() {
    local file
    for file in "$DNS_LEGACY_OLD_DNS_CONF" "$DNS_LEGACY_CONF" "$DNS_LEGACY_BLOCKLIST" "$DNS_LEGACY_WHITELIST"; do
        if [[ -f "$file" ]]; then
            dns_config_backup "$file"
            rm -f "$file"
        fi
    done
}

ensure_dns_allowlist_file() {
    mkdir -p "$(dirname "$DNS_ALLOWLIST_FILE")"
    if [[ ! -f "$DNS_ALLOWLIST_FILE" ]]; then
        cat > "$DNS_ALLOWLIST_FILE" <<'EOF'
# Yurich DNS allowlist.
# Один домен на строку. Пример:
# example.com
EOF
        chmod 600 "$DNS_ALLOWLIST_FILE" 2>/dev/null || true
    fi
}

write_dns_blocklist_disabled() {
    mkdir -p "$(dirname "$DNS_BLOCKLIST_CONF")"
    cat > "$DNS_BLOCKLIST_CONF" <<'EOF'
# Yurich DNS filtering disabled.
server:
EOF
    chmod 644 "$DNS_BLOCKLIST_CONF" 2>/dev/null || true
}

dns_filter_state_set() {
    local status="$1" count="${2:-0}" message="${3:-}"
    mkdir -p "$(dirname "$DNS_FILTER_STATE_FILE")"
    {
        printf 'STATUS=%q\n' "$status"
        printf 'COUNT=%q\n' "$count"
        printf 'UPDATED_AT=%q\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'MESSAGE=%q\n' "$message"
    } > "$DNS_FILTER_STATE_FILE"
    chmod 600 "$DNS_FILTER_STATE_FILE" 2>/dev/null || true
}

dns_filter_state_value() {
    local key="$1"
    [[ -f "$DNS_FILTER_STATE_FILE" ]] || return 1
    awk -F= -v k="$key" '$1 == k {print substr($0, index($0, "=") + 1); exit}' "$DNS_FILTER_STATE_FILE" \
        | sed "s/^'//; s/'$//"
}

generate_dns_blocklist_conf() {
    local out_file="$1" max_domains="${UNBOUND_FILTER_MAX_DOMAINS:-$DNS_FILTER_MAX_DOMAINS_DEFAULT}" urls="${UNBOUND_FILTER_URLS:-$DNS_FILTER_URLS_DEFAULT}"
    local workdir source_file idx=0 url
    [[ "$max_domains" =~ ^[0-9]+$ ]] || max_domains="$DNS_FILTER_MAX_DOMAINS_DEFAULT"
    (( max_domains < 1000 )) && max_domains=1000
    (( max_domains > 500000 )) && max_domains=500000
    workdir=$(mktemp -d /tmp/yurich-dns-filter-XXXXXX)
    ensure_dns_allowlist_file
    for url in $urls; do
        idx=$((idx + 1))
        source_file="${workdir}/source-${idx}.txt"
        if ! curl -fsSL --connect-timeout 10 --max-time 45 "$url" -o "$source_file"; then
            warn "DNS filter source недоступен: $url"
            rm -f "$source_file"
        fi
    done
    if ! ls "${workdir}"/source-*.txt >/dev/null 2>&1; then
        rm -rf "$workdir"
        err "Не удалось скачать ни один DNS blocklist source"
        return 1
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        rm -rf "$workdir"
        err "python3 не найден, не могу безопасно собрать DNS blocklist"
        return 1
    fi
    python3 - "$out_file" "$DNS_ALLOWLIST_FILE" "$max_domains" "${workdir}"/source-*.txt <<'PY'
import ipaddress
import re
import sys
from pathlib import Path

out_path = Path(sys.argv[1])
allow_path = Path(sys.argv[2])
limit = int(sys.argv[3])
sources = [Path(p) for p in sys.argv[4:]]

domain_re = re.compile(r"^(?=.{1,253}$)([a-z0-9_](?:[a-z0-9_-]{0,61}[a-z0-9_])?\.)+[a-z0-9_](?:[a-z0-9_-]{0,61}[a-z0-9_])?$")

def clean_token(token: str) -> str:
    token = token.strip().lower()
    if not token:
        return ""
    token = token.split("#", 1)[0].strip()
    token = token.strip('"').strip("'").strip()
    token = token.removeprefix("address=/").split("/", 1)[0] if token.startswith("address=/") else token
    token = token.removeprefix("server=/").split("/", 1)[0] if token.startswith("server=/") else token
    token = token.removeprefix("||")
    token = token.removeprefix("|")
    token = token.removeprefix("*.")
    token = token.removeprefix(".")
    token = token.replace("\\.", ".")
    token = token.split("^", 1)[0]
    token = token.split("/", 1)[0]
    token = token.rstrip(".")
    if token.startswith("www."):
        token = token[4:]
    return token

def is_ip(token: str) -> bool:
    try:
        ipaddress.ip_address(token)
        return True
    except ValueError:
        return False

def valid_domain(token: str) -> bool:
    if not token or " " in token or ":" in token or token in {"localhost", "local", "broadcasthost"}:
        return False
    if is_ip(token):
        return False
    if not domain_re.match(token):
        return False
    tld = token.rsplit(".", 1)[-1]
    return not tld.isdigit()

def extract_domains(line: str):
    original = line.strip()
    if not original or original.startswith(("#", "!", ";")):
        return []
    if "local-zone:" in original:
        match = re.search(r'local-zone:\s*"([^"]+)"', original)
        return [clean_token(match.group(1))] if match else []
    line = original.replace("\t", " ")
    parts = [p for p in line.split(" ") if p]
    if len(parts) >= 2:
        first = clean_token(parts[0])
        second = clean_token(parts[1])
        if is_ip(first):
            return [second]
        if is_ip(second):
            return [first]
    return [clean_token(parts[0])]

allow = set()
if allow_path.exists():
    for line in allow_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        value = clean_token(line)
        if valid_domain(value):
            allow.add(value)

def allowed(domain: str) -> bool:
    return any(domain == item or domain.endswith("." + item) for item in allow)

domains = set()
for source in sources:
    try:
        lines = source.read_text(encoding="utf-8", errors="ignore").splitlines()
    except OSError:
        continue
    for line in lines:
        for domain in extract_domains(line):
            if valid_domain(domain) and not allowed(domain):
                domains.add(domain)
                if len(domains) >= limit:
                    break
        if len(domains) >= limit:
            break
    if len(domains) >= limit:
        break

if len(domains) < 100:
    raise SystemExit(f"too few domains parsed: {len(domains)}")

with out_path.open("w", encoding="utf-8") as out:
    out.write("# Yurich DNS security blocklist. Generated automatically.\n")
    out.write("# Sources are configured in UNBOUND_FILTER_URLS.\n")
    out.write("server:\n")
    for domain in sorted(domains):
        out.write(f'    local-zone: "{domain}" always_nxdomain\n')
print(len(domains))
PY
    local rc=$?
    rm -rf "$workdir"
    return "$rc"
}

cmd_dns_update() {
    load_config
    hr
    echo -e "${BOLD}  [DNS] Обновление DNS security filter${RESET}"
    hr
    if [[ "${UNBOUND_FILTER_ENABLED:-1}" != "1" ]]; then
        write_dns_blocklist_disabled
        dns_filter_state_set "disabled" "0" "filter disabled"
        restart_unbound_checked || return 1
        ok "DNS filter выключен"
        return 0
    fi
    if ! command -v unbound >/dev/null 2>&1; then
        err "unbound не установлен"
        return 1
    fi
    mkdir -p "$(dirname "$DNS_BLOCKLIST_CONF")"
    local tmp_conf backup_conf count old_count
    tmp_conf=$(mktemp /tmp/yurich-dns-blocklist-XXXXXX.conf)
    if ! count=$(generate_dns_blocklist_conf "$tmp_conf"); then
        rm -f "$tmp_conf"
        dns_filter_state_set "failed" "0" "download or parse failed"
        return 1
    fi
    backup_conf=""
    if [[ -f "$DNS_BLOCKLIST_CONF" ]]; then
        backup_conf="${DNS_BLOCKLIST_CONF}.bak.$(date '+%Y%m%d-%H%M%S')"
        cp -a "$DNS_BLOCKLIST_CONF" "$backup_conf" 2>/dev/null || true
    fi
    install -m 644 "$tmp_conf" "$DNS_BLOCKLIST_CONF"
    rm -f "$tmp_conf"
    if ! unbound-checkconf >/tmp/yurich-dns-filter-check.out 2>&1; then
        [[ -n "$backup_conf" && -f "$backup_conf" ]] && cp -a "$backup_conf" "$DNS_BLOCKLIST_CONF"
        err "Новый DNS blocklist не прошёл unbound-checkconf, откатил"
        cat /tmp/yurich-dns-filter-check.out 2>/dev/null || true
        rm -f /tmp/yurich-dns-filter-check.out
        dns_filter_state_set "failed" "$count" "unbound-checkconf failed"
        return 1
    fi
    rm -f /tmp/yurich-dns-filter-check.out
    restart_unbound_checked || {
        [[ -n "$backup_conf" && -f "$backup_conf" ]] && cp -a "$backup_conf" "$DNS_BLOCKLIST_CONF" && systemctl restart unbound 2>/dev/null || true
        dns_filter_state_set "failed" "$count" "unbound restart failed"
        return 1
    }
    old_count=$(dns_filter_state_value COUNT 2>/dev/null || true)
    dns_filter_state_set "ok" "$count" "security filter updated"
    UNBOUND_FILTER_ENABLED="1"
    UNBOUND_ADBLOCK="0"
    save_config
    ok "DNS security filter обновлён: ${count} доменов"
    [[ -n "$old_count" && "$old_count" != "$count" ]] && info "Предыдущий размер: ${old_count}"
    return 0
}

cmd_dns_filter_install() {
    load_config
    UNBOUND_FILTER_ENABLED="1"
    UNBOUND_FILTER_URLS="${UNBOUND_FILTER_URLS:-$DNS_FILTER_URLS_DEFAULT}"
    UNBOUND_FILTER_MAX_DOMAINS="${UNBOUND_FILTER_MAX_DOMAINS:-$DNS_FILTER_MAX_DOMAINS_DEFAULT}"
    save_config
    cmd_dns_update || return 1
    cat > "$DNS_FILTER_CRON" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
17 4 * * * root /bin/bash ${SCRIPT_PATH} dns-update >> ${DNS_FILTER_LOG} 2>&1
EOF
    chmod 644 "$DNS_FILTER_CRON"
    touch "$DNS_FILTER_LOG"
    chmod 600 "$DNS_FILTER_LOG"
    ok "DNS filter cron включён: $DNS_FILTER_CRON"
}

dns_monitor_resolve_ok() {
    local domain="${1:-cloudflare.com}" server="${2:-127.0.0.1}" attempt
    for attempt in 1 2 3; do
        dig @"$server" "$domain" A +time=3 +tries=1 >/dev/null 2>&1 && return 0
        sleep 2
    done
    return 1
}

dns_monitor_resolve_tcp_ok() {
    local domain="${1:-cloudflare.com}" server="${2:-127.0.0.1}" attempt
    for attempt in 1 2 3; do
        dig @"$server" "$domain" A +tcp +time=3 +tries=1 >/dev/null 2>&1 && return 0
        sleep 2
    done
    return 1
}

dns_monitor_query_time_ms() {
    local domain="${1:-cloudflare.com}" server="${2:-127.0.0.1}" out
    out=$(dig @"$server" "$domain" A +stats +time=3 +tries=1 2>/dev/null) || return 1
    awk '/Query time:/ {print $4; exit}' <<<"$out"
}

dns_monitor_block_ok() {
    local domain="$1" attempt
    [[ -n "$domain" ]] || return 1
    for attempt in 1 2 3; do
        if dig @127.0.0.1 "$domain" A +time=3 +tries=1 2>/dev/null | grep -q "status: NXDOMAIN"; then
            return 0
        fi
        sleep 2
    done
    return 1
}

cmd_dns_monitor() {
    load_config
    local failed=0 status count updated_at message public_53 first_blocked gateway_ip gateway_re fail_details=""
    local domain ms latency_warn=0 latency_warn_details="" dns_latency_warn_ms="${DNS_MONITOR_LATENCY_WARN_MS:-250}" dns_latency_fail_ms="${DNS_MONITOR_LATENCY_FAIL_MS:-1500}"
    [[ "$dns_latency_warn_ms" =~ ^[0-9]+$ ]] || dns_latency_warn_ms=250
    [[ "$dns_latency_fail_ms" =~ ^[0-9]+$ ]] || dns_latency_fail_ms=1500
    if systemctl is-active --quiet unbound 2>/dev/null; then
        ok "Unbound active"
    else
        err "Unbound не active"
        failed=$((failed + 1))
        fail_details+=$'- Unbound service is not active\n'
    fi
    if dns_monitor_resolve_ok cloudflare.com; then
        ok "DNS resolve OK"
    else
        err "DNS resolve failed"
        failed=$((failed + 1))
        fail_details+=$'- Local DNS resolve failed on 127.0.0.1\n'
    fi
    for domain in cloudflare.com google.com telegram.org github.com; do
        if ms=$(dns_monitor_query_time_ms "$domain"); then
            if [[ "$ms" =~ ^[0-9]+$ ]]; then
                if (( ms >= dns_latency_fail_ms )); then
                    err "DNS latency failed: ${domain} ${ms}ms"
                    failed=$((failed + 1))
                    fail_details+="- Local DNS latency is critical: ${domain} ${ms}ms"$'\n'
                elif (( ms >= dns_latency_warn_ms )); then
                    warn "DNS latency slow: ${domain} ${ms}ms"
                    latency_warn=1
                    latency_warn_details+="- ${domain}: ${ms}ms"$'\n'
                else
                    ok "DNS latency OK: ${domain} ${ms}ms"
                fi
            else
                warn "DNS latency unknown: ${domain}"
                latency_warn=1
                latency_warn_details+="- ${domain}: unknown"$'\n'
            fi
        else
            err "DNS latency query failed: ${domain}"
            failed=$((failed + 1))
            fail_details+="- Local DNS latency query failed: ${domain}"$'\n'
        fi
    done
    public_53=$(ss -H -lntup 2>/dev/null | awk -v gw="${UNBOUND_GATEWAY_IP:-${DNS_DEFAULT_GATEWAY_IP:-10.0.0.1}}" '
        $5 ~ /:53$/ {
            endpoint=$5
            if (endpoint ~ /127\.0\.0\.1:53$/) next
            if (gw != "" && endpoint == (gw ":53")) next
            print
        }' || true)
    if [[ -n "$public_53" ]]; then
        err "Порт 53 слушает не только loopback/VPN gateway:"
        echo "$public_53"
        failed=$((failed + 1))
        fail_details+=$'- Port 53 has unexpected public listener\n'
    else
        ok "DNS не выглядит публично открытым"
    fi
    if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" ]]; then
        gateway_ip="${UNBOUND_GATEWAY_IP:-}"
        if [[ -z "$gateway_ip" ]]; then
            err "VPN DNS включён, но UNBOUND_GATEWAY_IP не задан"
            failed=$((failed + 1))
            fail_details+=$'- VPN DNS is enabled but UNBOUND_GATEWAY_IP is empty\n'
        else
            gateway_re=${gateway_ip//./\\.}
            if ip -br addr 2>/dev/null | grep -Eq "(^|[[:space:]])${gateway_re}/"; then
                ok "VPN DNS gateway IP есть на интерфейсе: $gateway_ip"
            else
                warn "VPN DNS gateway IP не найден на интерфейсах: $gateway_ip"
            fi
            if dns_monitor_resolve_ok cloudflare.com "$gateway_ip"; then
                ok "VPN DNS gateway UDP resolve OK: $gateway_ip"
            else
                err "VPN DNS gateway UDP resolve failed: $gateway_ip"
                failed=$((failed + 1))
                fail_details+="- VPN DNS gateway UDP resolve failed: ${gateway_ip}"$'\n'
            fi
            if dns_monitor_resolve_tcp_ok cloudflare.com "$gateway_ip"; then
                ok "VPN DNS gateway TCP resolve OK: $gateway_ip"
            else
                err "VPN DNS gateway TCP resolve failed: $gateway_ip"
                failed=$((failed + 1))
                fail_details+="- VPN DNS gateway TCP resolve failed: ${gateway_ip}"$'\n'
            fi
        fi
    fi
    if [[ -f "$DNS_FILTER_STATE_FILE" ]]; then
        status=$(dns_filter_state_value STATUS 2>/dev/null || true)
        count=$(dns_filter_state_value COUNT 2>/dev/null || true)
        updated_at=$(dns_filter_state_value UPDATED_AT 2>/dev/null || true)
        message=$(dns_filter_state_value MESSAGE 2>/dev/null || true)
        [[ "$status" == "ok" ]] && ok "DNS filter OK: ${count:-0} доменов, ${updated_at:-unknown}" || { warn "DNS filter state: ${status:-unknown} ${message:-}"; failed=$((failed + 1)); fail_details+="- DNS filter state is ${status:-unknown}: ${message:-empty message}"$'\n'; }
    else
        warn "DNS filter state отсутствует"
        failed=$((failed + 1))
        fail_details+=$'- DNS filter state file is missing\n'
    fi
    first_blocked=$(awk -F'"' '/local-zone:/ {print $2; exit}' "$DNS_BLOCKLIST_CONF" 2>/dev/null || true)
    if [[ -n "$first_blocked" ]]; then
        if dns_monitor_block_ok "$first_blocked"; then
            ok "Blocklist test OK: $first_blocked"
        else
            warn "Blocklist test не подтвердил NXDOMAIN: $first_blocked"
            failed=$((failed + 1))
            fail_details+="- Blocklist NXDOMAIN test failed: ${first_blocked}"$'\n'
        fi
    fi
    if [[ "$latency_warn" -ne 0 && "$failed" -eq 0 ]]; then
        warn "DNS latency warning threshold=${dns_latency_warn_ms}ms"
        printf '%s' "$latency_warn_details"
    fi
    if [[ "$failed" -ne 0 ]]; then
        tg_send "⚠️ <b>Yurich DNS monitor</b>
📡 Сервер: <code>$(hostname)</code>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<pre>DNS monitor failed=${failed}
${fail_details:-details unavailable}
filter=${status:-unknown} count=${count:-0} updated=${updated_at:-unknown}
${message:-}</pre>"
        return 1
    fi
}

cmd_dns_monitor_install() {
    cat > "$DNS_FILTER_MONITOR_CRON" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/15 * * * * root /bin/bash ${SCRIPT_PATH} dns-monitor >> ${DNS_FILTER_MONITOR_LOG} 2>&1
EOF
    chmod 644 "$DNS_FILTER_MONITOR_CRON"
    touch "$DNS_FILTER_MONITOR_LOG"
    chmod 600 "$DNS_FILTER_MONITOR_LOG"
    ok "DNS monitor cron включён: $DNS_FILTER_MONITOR_CRON"
}

write_unbound_config() {
    mkdir -p "$(dirname "$DNS_CONF")" /var/lib/unbound
    dns_config_backup "$DNS_CONF"

    local vpn_enabled="${UNBOUND_VPN_ENABLED:-0}"
    local vpn_cidrs="${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}"
    local gateway_ip="${UNBOUND_GATEWAY_IP:-}"
    local cidr
    local -a cidrs

    cat > "$DNS_CONF" <<EOF
server:
    # DNS (Unbound): local recursive resolver.
    # Never bind 0.0.0.0. VPN access is bound to the gateway IP only.
    interface: 127.0.0.1
EOF

    if [[ "$vpn_enabled" == "1" && -n "$gateway_ip" ]]; then
        printf '    interface: %s\n' "$gateway_ip" >> "$DNS_CONF"
    fi

    cat >> "$DNS_CONF" <<'EOF'

    port: 53
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes

    # Never become an open resolver.
    access-control: 0.0.0.0/0 refuse
    access-control: 127.0.0.0/8 allow
EOF

    if [[ "$vpn_enabled" == "1" ]]; then
        IFS=',' read -ra cidrs <<< "$vpn_cidrs"
        for cidr in "${cidrs[@]}"; do
            [[ -n "$cidr" ]] && printf '    access-control: %s allow\n' "$cidr" >> "$DNS_CONF"
        done
    fi

    cat >> "$DNS_CONF" <<'EOF'

    # Privacy and hardening.
    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    harden-large-queries: yes
    harden-short-bufsize: yes
    qname-minimisation: yes
    aggressive-nsec: yes
    val-clean-additional: yes

    # DNSSEC root trust anchor is managed by Ubuntu's Unbound package.
    # Do not repeat auto-trust-anchor-file here, or Unbound can fail with:
    # "trust anchor presented twice".
    root-hints: "/usr/share/dns/root.hints"

    # Cache and speed.
    prefetch: yes
    prefetch-key: yes
    num-threads: 2
    so-rcvbuf: 256k
    msg-cache-size: 64m
    rrset-cache-size: 128m
    cache-min-ttl: 300
    cache-max-ttl: 86400

    # Logs are off by default to preserve privacy.
    log-queries: no
    statistics-interval: 0
    verbosity: 1

    # Recursive mode: no Google/Cloudflare forwarders here.
    # Unbound queries root and authoritative DNS servers directly.
EOF

    chown -R unbound:unbound /var/lib/unbound 2>/dev/null || true
}

restart_unbound_checked() {
    if ! unbound-checkconf "$DNS_CONF" >/dev/null 2>&1; then
        err "Ошибка конфига Unbound:"
        unbound-checkconf "$DNS_CONF" || true
        return 1
    fi
    systemctl enable unbound --quiet
    systemctl reset-failed unbound 2>/dev/null || true
    systemctl restart unbound
    sleep 2
    if ! systemctl is-active --quiet unbound; then
        err "Unbound не запустился!"
        journalctl -u unbound -n 20 --no-pager
        return 1
    fi
}

install_yurich_dns_cli_commands() {
    local script_path="${SCRIPT_PATH:-/usr/local/bin/yurich-panel.sh}"
    cat > /usr/local/bin/yurich-dns-status <<EOF
#!/bin/sh
exec /bin/bash "$script_path" unbound-status
EOF
    cat > /usr/local/bin/yurich-dns-test <<EOF
#!/bin/sh
exec /bin/bash "$script_path" unbound-test
EOF
    cat > /usr/local/bin/yurich-dns-restart <<EOF
#!/bin/sh
exec /bin/bash "$script_path" unbound-restart
EOF
    chmod +x /usr/local/bin/yurich-dns-status /usr/local/bin/yurich-dns-test /usr/local/bin/yurich-dns-restart

    # Legacy aliases keep already installed servers and old automation working.
    ln -sf /usr/local/bin/yurich-dns-status /usr/local/bin/aurum-dns-status 2>/dev/null || true
    ln -sf /usr/local/bin/yurich-dns-test /usr/local/bin/aurum-dns-test 2>/dev/null || true
    ln -sf /usr/local/bin/yurich-dns-restart /usr/local/bin/aurum-dns-restart 2>/dev/null || true
}

apply_unbound_ufw_rules() {
    local cidr
    local -a cidrs
    command -v ufw >/dev/null 2>&1 || return 0
    if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" ]]; then
        remove_unbound_ufw_rules
        IFS=',' read -ra cidrs <<< "${UNBOUND_VPN_CIDRS:-}"
        for cidr in "${cidrs[@]}"; do
            [[ -z "$cidr" ]] && continue
            ufw allow from "$cidr" to any port 53 proto udp comment "Unbound DNS VPN" >/dev/null 2>&1 || true
            ufw allow from "$cidr" to any port 53 proto tcp comment "Unbound DNS VPN" >/dev/null 2>&1 || true
        done
        ok "UFW: DNS открыт только для VPN CIDR: ${UNBOUND_VPN_CIDRS}"
    fi
}

remove_unbound_ufw_rules() {
    local cidr candidates extra_cidrs="${1:-}"
    local -a cidrs
    command -v ufw >/dev/null 2>&1 || return 0
    candidates="${extra_cidrs},${UNBOUND_VPN_CIDRS:-},10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
    IFS=',' read -ra cidrs <<< "$candidates"
    for cidr in "${cidrs[@]}"; do
        [[ -z "$cidr" ]] && continue
        ufw delete allow from "$cidr" to any port 53 proto udp >/dev/null 2>&1 || true
        ufw delete allow from "$cidr" to any port 53 proto tcp >/dev/null 2>&1 || true
    done
}

cmd_dns_install() {
    hr
    echo -e "${BOLD}  [DNS] Установка Yurich DNS (Unbound)${RESET}"
    hr

    info "Обновляю apt cache и устанавливаю зависимости..."
    apt-get update -qq
    apt-get install -y -q unbound unbound-anchor dnsutils dns-root-data ca-certificates curl

    cleanup_legacy_dns_files
    disable_resolved_stub_if_needed
    check_port53_for_yurich_dns || return 1
    mkdir -p /var/lib/unbound "$(dirname "$DNS_CONF")"
    unbound-anchor -a /var/lib/unbound/root.key >/dev/null 2>&1 || true

    echo
    echo -e "${CYAN}DNS (Unbound) работает как recursive DNSSEC resolver.${RESET}"
    echo -e "${DIM}Security-фильтр malware/phishing/scam включается отдельным безопасным include-файлом.${RESET}"
    echo -e "${DIM}Если нужен DNS для VPN-клиентов, укажи IP gateway на VPN-интерфейсе, например 10.0.0.1.${RESET}"
    local detected_gateway gateway_input vpn_cidrs
    detected_gateway=$(detect_private_dns_gateway || true)
    echo -ne "${CYAN}VPN gateway IP [${detected_gateway:-$DNS_DEFAULT_GATEWAY_IP}, 0 = только локально]: ${RESET}"
    read -r gateway_input
    gateway_input="${gateway_input:-${detected_gateway:-$DNS_DEFAULT_GATEWAY_IP}}"

    UNBOUND_MODE="recursive"
    UNBOUND_ADBLOCK="0"
    if [[ "$gateway_input" =~ ^(0|local|none|нет)$ ]]; then
        UNBOUND_GATEWAY_IP=""
        UNBOUND_MANAGED_GATEWAY="0"
        UNBOUND_VPN_ENABLED="0"
        UNBOUND_VPN_CIDRS="${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}"
    elif [[ -n "$gateway_input" ]]; then
        if ! is_valid_ipv4 "$gateway_input"; then
            err "Некорректный IPv4: $gateway_input"
            return 1
        fi
        prepare_unbound_gateway_ip "$gateway_input" || return 1
        UNBOUND_GATEWAY_IP="$gateway_input"
        UNBOUND_VPN_ENABLED="1"
        echo -ne "${CYAN}VPN CIDR через запятую [${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}]: ${RESET}"
        read -r vpn_cidrs
        UNBOUND_VPN_CIDRS=$(normalize_cidr_list "${vpn_cidrs:-${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}}") || return 1
        if [[ "$UNBOUND_VPN_CIDRS" == *"0.0.0.0/0"* ]]; then
            err "Open resolver запрещён: 0.0.0.0/0 использовать нельзя"
            return 1
        fi
    else
        UNBOUND_GATEWAY_IP=""
        UNBOUND_MANAGED_GATEWAY="0"
        UNBOUND_VPN_ENABLED="0"
        UNBOUND_VPN_CIDRS="${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}"
    fi

    write_unbound_config
    restart_unbound_checked || return 1
    apply_unbound_ufw_rules
    install_yurich_dns_cli_commands

    # Статистика
    mkdir -p "$(dirname "${DNS_STATS_FILE}")"
    echo "0" > "${DNS_STATS_FILE}"
    UNBOUND_ENABLED="1"
    save_config
    cmd_dns_filter_install || warn "DNS security filter не включился, базовый Unbound продолжает работать"

    ok "Yurich DNS (Unbound) установлен!"
    tg_send "🛡️ <b>Yurich DNS (Unbound) установлен</b>
🖥 Сервер: <code>$(hostname)</code>
🔒 Режим: recursive DNSSEC, gateway=${UNBOUND_GATEWAY_IP:-127.0.0.1}, VPN=${UNBOUND_VPN_ENABLED:-0}
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
}

cmd_dns_restart() {
    load_config
    hr
    echo -e "${BOLD}  [DNS] Restart DNS (Unbound)${RESET}"
    hr
    if ! command -v unbound &>/dev/null; then
        err "unbound не установлен"
        return 1
    fi
    if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" && "${UNBOUND_MANAGED_GATEWAY:-0}" == "1" && -n "${UNBOUND_GATEWAY_IP:-}" ]]; then
        ensure_managed_dns_gateway "$UNBOUND_GATEWAY_IP" || return 1
    fi
    write_unbound_config
    restart_unbound_checked || return 1
    ok "DNS (Unbound) перезапущен"
}

# Статус и тест DNS (Unbound)
cmd_dns_status() {
    load_config
    hr
    echo -e "${BOLD}  [DNS] Yurich DNS (Unbound)${RESET}"
    hr

    if ! command -v unbound &>/dev/null; then
        warn "unbound не установлен"
        return
    fi

    if systemctl is-active unbound &>/dev/null; then
        ok "unbound: запущен"
    else
        err "unbound: остановлен"
    fi

    echo -e "  Режим: ${CYAN}$(unbound_mode_label)${RESET}"
    echo -e "  Local DNS: ${CYAN}127.0.0.1:53${RESET}"
    if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" ]]; then
        echo -e "  VPN DNS: ${CYAN}${UNBOUND_GATEWAY_IP:-не задан}:53${RESET} только для ${CYAN}${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}${RESET}"
        echo -e "  Gateway mode: ${CYAN}$([[ "${UNBOUND_MANAGED_GATEWAY:-0}" == "1" ]] && echo "auto lo /32" || echo "server interface")${RESET}"
    else
        echo -e "  VPN DNS: ${YELLOW}выключен${RESET}"
    fi
    if [[ "${UNBOUND_FILTER_ENABLED:-1}" == "1" ]]; then
        local filter_status filter_count filter_updated
        filter_status=$(dns_filter_state_value STATUS 2>/dev/null || echo "unknown")
        filter_count=$(dns_filter_state_value COUNT 2>/dev/null || echo "0")
        filter_updated=$(dns_filter_state_value UPDATED_AT 2>/dev/null || echo "unknown")
        echo -e "  Security filter: ${CYAN}${filter_status}${RESET}, доменов: ${CYAN}${filter_count}${RESET}, обновлено: ${CYAN}${filter_updated}${RESET}"
    else
        echo -e "  Security filter: ${YELLOW}выключен${RESET}"
    fi
    [[ -f "$DNS_CONF" ]] && unbound-checkconf "$DNS_CONF" >/dev/null 2>&1 && ok "Конфиг Unbound валиден" || warn "Конфиг Unbound не прошёл проверку"

    echo
    info "Порт 53:"
    port53_listeners || true

    echo
    info "Тест DNS-запросов..."
    local ok_domains=("google.com" "cloudflare.com")
    for domain in "${ok_domains[@]}"; do
        local result
        result=$(dig "@127.0.0.1" "${domain}" +short +time=3 +tries=1 2>/dev/null | head -1)
        if [[ -n "${result}" ]]; then
            echo -e "  ${GREEN}[OK] ${domain} → ${result}${RESET}"
        else
            echo -e "  ${RED}[FAIL] ${domain} — не резолвится!${RESET}"
        fi
    done

    echo
    info "DNSSEC test..."
    if dig "@127.0.0.1" sigok.verteiltesysteme.net A +time=4 +tries=1 2>/dev/null | grep -q "status: NOERROR"; then
        echo -e "  ${GREEN}[OK] DNSSEC valid domain: OK${RESET}"
    else
        echo -e "  ${YELLOW}[WARN] DNSSEC valid test не дал NOERROR${RESET}"
    fi
    if dig "@127.0.0.1" dnssec-failed.org A +time=4 +tries=1 2>/dev/null | grep -q "status: SERVFAIL"; then
        echo -e "  ${GREEN}[OK] DNSSEC invalid domain отклонён${RESET}"
    else
        echo -e "  ${YELLOW}[WARN] DNSSEC invalid test не подтвердил SERVFAIL${RESET}"
    fi
    echo
    info "Последние логи Unbound:"
    journalctl -u unbound -n 20 --no-pager 2>/dev/null || true
    hr
}

cmd_dns_set_mode() {
    load_config
    hr
    echo -e "${BOLD}  [DNS] DNS (Unbound) mode${RESET}"
    hr
    warn "Forward/adblock режимы не используются. DNS работает как recursive resolver, security-фильтр включается отдельно."
    UNBOUND_MODE="recursive"
    UNBOUND_ADBLOCK="0"
    UNBOUND_ENABLED="1"
    save_config
    if command -v unbound &>/dev/null; then
        write_unbound_config
        restart_unbound_checked || return 1
        ok "Режим применён: $(unbound_mode_label)"
    else
        info "Unbound ещё не установлен. Запусти меню 17 → 1."
    fi
}

cmd_dns_vpn_access() {
    load_config
    local old_unbound_vpn_cidrs="${UNBOUND_VPN_CIDRS:-}"
    local old_unbound_gateway="${UNBOUND_GATEWAY_IP:-}"
    local old_unbound_managed="${UNBOUND_MANAGED_GATEWAY:-0}"
    hr
    echo -e "${BOLD}  🔐 DNS доступ для VPN-клиентов${RESET}"
    hr
    echo -e "  Сейчас: VPN=${CYAN}${UNBOUND_VPN_ENABLED:-0}${RESET}, gateway=${CYAN}${UNBOUND_GATEWAY_IP:-нет}${RESET}, CIDR=${CYAN}${UNBOUND_VPN_CIDRS:-нет}${RESET}"
    echo
    warn "Не включай DNS для 0.0.0.0/0. Скрипт откажется делать open resolver."
    echo -e "  ${BOLD}1)${RESET} Включить / изменить VPN DNS"
    echo -e "  ${BOLD}2)${RESET} Выключить VPN DNS"
    echo -e "  ${BOLD}0)${RESET} Назад"
    echo -ne "${CYAN}Выбор: ${RESET}"
    read -r choice
    case "$choice" in
        1)
            local cidrs gateway_input detected_gateway
            detected_gateway=$(detect_private_dns_gateway || true)
            echo -ne "${CYAN}VPN gateway IP [${UNBOUND_GATEWAY_IP:-${detected_gateway:-$DNS_DEFAULT_GATEWAY_IP}}]: ${RESET}"
            read -r gateway_input
            gateway_input="${gateway_input:-${UNBOUND_GATEWAY_IP:-${detected_gateway:-$DNS_DEFAULT_GATEWAY_IP}}}"
            if ! is_valid_ipv4 "$gateway_input"; then
                err "Некорректный IPv4: $gateway_input"
                return 1
            fi
            if [[ "$old_unbound_managed" == "1" && -n "$old_unbound_gateway" && "$old_unbound_gateway" != "$gateway_input" ]]; then
                remove_managed_dns_gateway
            fi
            prepare_unbound_gateway_ip "$gateway_input" || return 1
            echo -ne "${CYAN}VPN CIDR через запятую [${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}]: ${RESET}"
            read -r cidrs
            UNBOUND_VPN_CIDRS=$(normalize_cidr_list "${cidrs:-${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}}") || return 1
            if [[ "$UNBOUND_VPN_CIDRS" == *"0.0.0.0/0"* ]]; then
                err "Open resolver запрещён: 0.0.0.0/0 использовать нельзя"
                return 1
            fi
            UNBOUND_GATEWAY_IP="$gateway_input"
            UNBOUND_VPN_ENABLED="1"
            ;;
        2)
            UNBOUND_VPN_ENABLED="0"
            UNBOUND_GATEWAY_IP=""
            UNBOUND_MANAGED_GATEWAY="0"
            remove_unbound_ufw_rules "$old_unbound_vpn_cidrs"
            [[ "$old_unbound_managed" == "1" ]] && remove_managed_dns_gateway
            ;;
        0) return 0 ;;
        *) err "Неверный выбор"; return 1 ;;
    esac

    UNBOUND_MODE="recursive"
    UNBOUND_ADBLOCK="0"
    write_unbound_config
    restart_unbound_checked || return 1
    remove_unbound_ufw_rules "$old_unbound_vpn_cidrs"
    apply_unbound_ufw_rules
    save_config
    [[ "$old_unbound_gateway" != "${UNBOUND_GATEWAY_IP:-}" ]] && info "Gateway изменён: ${old_unbound_gateway:-нет} → ${UNBOUND_GATEWAY_IP:-нет}"
    ok "VPN DNS настройки применены"
}

# Совместимость со старым пунктом whitelist.
cmd_dns_whitelist() {
    hr
    echo -e "${BOLD}  [DNS] Allowlist security filter${RESET}"
    hr
    ensure_dns_allowlist_file
    echo -e "Файл allowlist: ${CYAN}${DNS_ALLOWLIST_FILE}${RESET}"
    echo -e "${DIM}Добавь домен по одному на строку, затем запусти: sudo yurich-panel.sh dns-update${RESET}"
    sed -n '1,80p' "$DNS_ALLOWLIST_FILE" 2>/dev/null || true
}

# Удалить DNS (Unbound)
cmd_dns_remove() {
    echo -ne "${YELLOW}Удалить DNS (Unbound) конфиг и команды? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" != "y" ]] && return

    systemctl stop unbound 2>/dev/null || true
    systemctl disable unbound 2>/dev/null || true
    remove_unbound_ufw_rules
    [[ "${UNBOUND_MANAGED_GATEWAY:-0}" == "1" || -f "$DNS_GATEWAY_SERVICE" ]] && remove_managed_dns_gateway
    cleanup_legacy_dns_files
    dns_config_backup "$DNS_CONF"
    dns_config_backup "$DNS_BLOCKLIST_CONF"
    rm -f "$DNS_CONF" "$DNS_BLOCKLIST_CONF" "$DNS_LEGACY_OLD_DNS_CONF"
    rm -f "$DNS_FILTER_CRON" "$DNS_FILTER_MONITOR_CRON" "$DNS_FILTER_STATE_FILE" 2>/dev/null || true
    rm -f /usr/local/bin/yurich-dns-status /usr/local/bin/yurich-dns-test /usr/local/bin/yurich-dns-restart 2>/dev/null || true
    rm -f /usr/local/bin/aurum-dns-status /usr/local/bin/aurum-dns-test /usr/local/bin/aurum-dns-restart 2>/dev/null || true
    if [[ -f "$DNS_RESOLVED_NO_STUB" ]]; then
        dns_config_backup "$DNS_RESOLVED_NO_STUB"
        rm -f "$DNS_RESOLVED_NO_STUB"
        systemctl restart systemd-resolved 2>/dev/null || true
    fi
    UNBOUND_ENABLED="0"
    UNBOUND_GATEWAY_IP=""
    UNBOUND_MANAGED_GATEWAY="0"
    UNBOUND_VPN_ENABLED="0"
    UNBOUND_ADBLOCK="0"
    UNBOUND_FILTER_ENABLED="0"
    save_config
    systemctl daemon-reload 2>/dev/null || true

    ok "Yurich DNS (Unbound) удалён. Пакеты unbound/dnsutils не удалял."
}

# ─── Донат ─────────────────────────────────────────────────────
cmd_donate() {
    local support_url="${PROJECT_DONATION_URL:-$PROJECT_GITHUB_URL}"
    clear 2>/dev/null || true
    echo
    echo -e "${BOLD}${GOLD}  ╔════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${GOLD}  ║     ПОДДЕРЖАТЬ ПРОЕКТ                      ║${RESET}"
    echo -e "${BOLD}${GOLD}  ╚════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "  ${CYAN}Если Yurich Panel помог тебе —${RESET}"
    echo -e "  ${CYAN}поддержи разработку! Это очень мотивирует.${RESET}"
    echo
    if [[ -n "${PROJECT_DONATION_URL:-}" ]]; then
        echo -e "  ${BOLD}Ссылка на поддержку:${RESET}"
        echo -e "  ${BOLD}${GOLD}👉 ${PROJECT_DONATION_URL}${RESET}"
    else
        echo -e "  ${BOLD}Поддержать проект можно через GitHub:${RESET}"
        echo -e "  ${BOLD}${GOLD}👉 ${PROJECT_GITHUB_URL}${RESET}"
    fi
    echo
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${BOLD}Что даст твой донат:${RESET}"
    echo -e "  ${GREEN}-${RESET} Больше времени на разработку"
    echo -e "  ${GREEN}🐛${RESET} Быстрые фиксы багов"
    echo -e "  ${GREEN}✨${RESET} Новые фичи каждый месяц"
    echo -e "  ${GREEN}📚${RESET} Документация и поддержка"
    echo -e "  ${GREEN}🆕${RESET} Эксклюзив для донатеров в Telegram"
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${BOLD}Другие способы поддержки:${RESET}"
    echo -e "  ${CYAN}⭐${RESET} Поставь звезду:  ${PROJECT_GITHUB_SHORT}"
    [[ -n "${TELEGRAM_COMMUNITY_URL:-}" ]] && echo -e "  ${CYAN}[TG]${RESET} Telegram канал:  ${TELEGRAM_COMMUNITY_URL}"
    [[ -n "${PROJECT_WEBSITE_URL:-}" ]] && echo -e "  ${CYAN}[WEB]${RESET} Сайт:            ${PROJECT_WEBSITE_URL}"
    echo -e "  ${CYAN}📢${RESET} Расскажи друзьям!"
    echo
    echo -e "  ${BOLD}${GOLD}Спасибо за поддержку! 🙏${RESET}"
    echo

    if command -v qrencode &>/dev/null; then
        echo -e "  ${DIM}QR код:${RESET}"
        qrencode -t ANSIUTF8 "$support_url" 2>/dev/null | sed 's/^/    /'
        echo
    fi

    echo -ne "  ${YELLOW}Enter для возврата в меню...${RESET}"
    read -r
}

# Меню DNS (Unbound)
cmd_dns_menu() {
    while true; do
        load_config
        hr
        echo -e "${BOLD}  [DNS] Yurich DNS (Unbound)${RESET}"
        hr

        local dns_status="${RED}не установлен${RESET}"
        if command -v unbound &>/dev/null; then
            dns_status="${YELLOW}установлен, не запущен${RESET}"
            systemctl is-active --quiet unbound 2>/dev/null && dns_status="${GREEN}активен${RESET}"
        fi

        echo -e "  Статус: ${dns_status}"
        echo -e "  Режим: ${CYAN}$(unbound_mode_label)${RESET}"
        echo -e "  VPN DNS: ${CYAN}${UNBOUND_VPN_ENABLED:-0}${RESET} | Gateway: ${CYAN}${UNBOUND_GATEWAY_IP:-нет}${RESET} | CIDR: ${CYAN}${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}${RESET}"
        echo -e "  Security filter: ${CYAN}${UNBOUND_FILTER_ENABLED:-1}${RESET} | Domains: ${CYAN}$(dns_filter_state_value COUNT 2>/dev/null || echo 0)${RESET}"
        [[ "${UNBOUND_MANAGED_GATEWAY:-0}" == "1" ]] && echo -e "  Gateway mode: ${CYAN}auto lo /32${RESET}"
        echo
        echo -e "  ${BOLD}1)${RESET} Установить / переустановить DNS (Unbound)"
        echo -e "  ${BOLD}2)${RESET} Настроить DNS для VPN-клиентов"
        echo -e "  ${BOLD}3)${RESET} Статус, порт 53, DNSSEC и тесты"
        echo -e "  ${BOLD}4)${RESET} Перезапустить DNS (Unbound)"
        echo -e "  ${BOLD}5)${RESET} Обновить security-фильтр"
        echo -e "  ${BOLD}6)${RESET} Allowlist security-фильтра"
        echo -e "  ${BOLD}7)${RESET} Включить DNS monitor"
        echo -e "  ${BOLD}8)${RESET} Удалить DNS (Unbound)"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice

        case "${choice}" in
            1) cmd_dns_install ;;
            2) cmd_dns_vpn_access ;;
            3) cmd_dns_status ;;
            4) cmd_dns_restart ;;
            5) cmd_dns_filter_install ;;
            6) cmd_dns_whitelist ;;
            7) cmd_dns_monitor_install ;;
            8) cmd_dns_remove ;;
            0) break ;;
            *) warn "Неверный выбор" ;;
        esac

        echo -ne "${YELLOW}Enter для продолжения...${RESET}"; read -r
    done
}

cmd_unbound_plugin() {
    cmd_dns_menu
}

# ─── СТАТУС ──────────────────────────────────────────────────
cmd_status() {
    hr
    echo -e "${BOLD}  Статус Yurich Panel${RESET}"
    hr

    systemctl is-active --quiet caddy 2>/dev/null \
        && ok "Caddy: ${GREEN}работает${RESET}" \
        || err "Caddy: ${RED}не работает${RESET}"
    systemctl is-enabled --quiet caddy 2>/dev/null \
        && ok "Автозапуск: включён" \
        || warn "Автозапуск: выключен"

    load_config
    [[ -n "${DOMAIN:-}" ]] && echo -e "\n  Домен:   $DOMAIN"
    echo -e "  Юзеров: $(get_users | wc -l)"
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        systemctl is-active --quiet hysteria 2>/dev/null \
            && ok "Hysteria 2: работает на UDP/${HYSTERIA_PORT:-8443}" \
            || warn "Hysteria 2: установлен, но не работает"
    fi
    if command -v warp-cli &>/dev/null; then
        ok "WARP proxy: установлен, порт ${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    fi
    if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
        systemctl is-active --quiet xray 2>/dev/null \
            && ok "Xray: работает (fallback 443: ${XRAY_FALLBACK_ENABLED:-0})" \
            || warn "Xray: установлен, но не работает"
    fi
    if [[ "${DEVICE_LIMIT_ENABLED:-0}" == "1" ]]; then
        ok "Лимит устройств: ${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT} IP / ${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT} ч (${DEVICE_LIMIT_MODE:-alert})"
    else
        warn "Лимит устройств: выключен"
    fi
    if command -v unbound &>/dev/null; then
        systemctl is-active --quiet unbound 2>/dev/null \
            && ok "DNS (Unbound): $(unbound_mode_label), gateway=${UNBOUND_GATEWAY_IP:-127.0.0.1}, vpn=${UNBOUND_VPN_ENABLED:-0}" \
            || warn "DNS (Unbound): установлен, но не работает"
    fi
    check_cert "${DOMAIN:-}"
    echo
    info "Последние 10 строк лога:"
    journalctl -u caddy -n 10 --no-pager 2>/dev/null || true
    hr
}

# ─── ПЕРЕЗАПУСК ──────────────────────────────────────────────
cmd_restart() {
    info "Перезапускаю Caddy..."
    systemctl restart caddy
    sleep 2
    if systemctl is-active --quiet caddy; then
        ok "Caddy перезапущен"
        load_config; tg_alert_up
    else
        err "Caddy не запустился:"
        journalctl -u caddy -n 20 --no-pager
    fi
}

cmd_reload() {
    info "Проверяю Caddyfile перед reload..."
    if ! "$CADDY_BIN" validate --config "$CADDYFILE" >/dev/null 2>&1; then
        err "Caddyfile содержит ошибку. Reload отменён."
        "$CADDY_BIN" validate --config "$CADDYFILE" || true
        return 1
    fi

    "$CADDY_BIN" fmt --overwrite "$CADDYFILE" >/dev/null 2>&1 || true
    info "Применяю конфиг без полного перезапуска Caddy..."
    if systemctl reload caddy; then
        ok "Caddy reload выполнен без разрыва активных соединений"
        load_config; tg_alert_up
    else
        err "Reload не удался. Caddy не перезапускал, смотри лог:"
        journalctl -u caddy -n 20 --no-pager
        return 1
    fi
}

# ─── ОБНОВЛЕНИЕ ──────────────────────────────────────────────
cmd_update() {
    hr
    echo -e "${BOLD}  Обновление Caddy${RESET}"
    hr

    check_installed || { err "Yurich Panel не установлен"; return 1; }

    local old_ver
    old_ver=$("$CADDY_BIN" version 2>/dev/null | head -1 || echo "unknown")
    info "Текущая версия: $old_ver"

    backup_config

    local tmp_caddy_dir tmp_caddy
    tmp_caddy_dir=$(mktemp -d /tmp/naiveproxy_caddy_XXXXXX)
    tmp_caddy="${tmp_caddy_dir}/caddy"
    trap 'rm -rf "${tmp_caddy_dir:-}" 2>/dev/null' RETURN

    build_caddy "$tmp_caddy"
    install -m 755 "$tmp_caddy" "$CADDY_BIN"
    systemctl restart caddy

    local new_ver
    new_ver=$("$CADDY_BIN" version 2>/dev/null | head -1 || echo "unknown")
    ok "Обновлено: $old_ver → $new_ver"
    load_config; tg_alert_updated "$old_ver" "$new_ver"
}

# ─── УДАЛЕНИЕ ────────────────────────────────────────────────
cmd_remove() {
    hr
    echo -e "${BOLD}${RED}  Удаление Yurich Panel${RESET}"
    hr
    echo -ne "${RED}Удалить всё? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] || return

    systemctl stop caddy    2>/dev/null || true
    systemctl disable caddy 2>/dev/null || true
    systemctl stop hysteria 2>/dev/null || true
    systemctl disable hysteria 2>/dev/null || true
    systemctl stop xray 2>/dev/null || true
    systemctl disable xray 2>/dev/null || true
    systemctl stop warp-svc cloudflare-warp >/dev/null 2>&1 || true
    rm -f "$CADDY_SERVICE" "$CADDY_BIN" "$CADDYFILE" "$HYSTERIA_SERVICE" "$HYSTERIA_BIN" "$HYSTERIA_CONFIG" "$XRAY_SERVICE" "$XRAY_BIN" "$XRAY_CONFIG" "$DEVICE_CRON"
    [[ -n "${CONFIG_DIR:-}" && "$CONFIG_DIR" != "/" ]] && rm -rf "$CONFIG_DIR"
    systemctl daemon-reload

    ufw delete allow 80/tcp  >/dev/null 2>&1 || true
    ufw delete allow 443/tcp >/dev/null 2>&1 || true
    ufw delete allow 443/udp >/dev/null 2>&1 || true
    ufw delete allow "${HYSTERIA_PORT:-8443}/udp" >/dev/null 2>&1 || true
    ufw delete allow "${XRAY_REALITY_PORT:-8444}/tcp" >/dev/null 2>&1 || true
    ufw delete allow "${XRAY_MKCP_PORT:-8446}/udp" >/dev/null 2>&1 || true
    ufw delete allow 8447/tcp >/dev/null 2>&1 || true
    ufw delete allow "${XRAY_XHTTP_PORT:-8448}/tcp" >/dev/null 2>&1 || true

    ( crontab -l 2>/dev/null | grep -v "naiveproxy\|monitor\.sh" || true ) | crontab -

    ok "Yurich Panel удалён"
}

# ─── ЛОГИ ────────────────────────────────────────────────────
cmd_logs() {
    echo -e "${BOLD}Лог Caddy (Ctrl+C для выхода):${RESET}"
    journalctl -u caddy -n 50 -f
}

cmd_language() {
    load_config 2>/dev/null || true
    hr
    echo -e "${BOLD}  $(t "Язык SSH-панели" "SSH panel language")${RESET}"
    hr
    echo -e "  $(t "Текущий язык" "Current language"): ${CYAN}${LANG_UI:-ru}${RESET}"
    echo
    echo -e "  ${BOLD}1)${RESET} Русский"
    echo -e "  ${BOLD}2)${RESET} English"
    echo -e "  ${BOLD}0)${RESET} $(t "Назад" "Back")"
    hr
    echo -ne "${CYAN}$(t "Выбор" "Choice") [0-2]: ${RESET}"
    read -r lang_choice
    case "${lang_choice,,}" in
        1|ru|rus|russian|русский)
            LANG_UI="ru"
            save_config
            ok "Язык панели: Русский"
            ;;
        2|en|eng|english)
            LANG_UI="en"
            save_config
            ok "Panel language: English"
            ;;
        0|"")
            return 0
            ;;
        *)
            warn "$(t "Неверный выбор" "Invalid choice")"
            return 1
            ;;
    esac
}

# ─── МЕНЮ ────────────────────────────────────────────────────
show_menu() {
    clear
    load_config

    local status_str="${YELLOW}● $(t "не установлен" "not installed")${RESET}"
    if check_installed; then
        systemctl is-active --quiet caddy 2>/dev/null \
            && status_str="${GREEN}● $(t "работает" "running")${RESET}" \
            || status_str="${RED}● $(t "остановлен" "stopped")${RESET}"
    fi

    local tg_str="${RED}$(t "не настроен" "not configured")${RESET}"
    [[ -n "${TG_TOKEN:-}" ]] && tg_str="${GREEN}$(t "подключён" "connected")${RESET}"

    hr
    echo -e "${BOLD}${CYAN}   Yurich Panel v${VERSION}${RESET}  ${DIM}[$(t "РУС" "ENG")]${RESET}"
    echo -e "   $(t "Статус" "Status"): ${status_str}  |  $(t "Домен" "Domain"): ${CYAN}${DOMAIN:-$(t "не задан" "not set")}${RESET}"
    local ssh_str="${YELLOW}$(t "не настроен" "not configured")${RESET}"
    [[ -f "$SSH_HARDENING_DONE" ]] && ssh_str="${GREEN}$(grep SSH_PORT "$SSH_HARDENING_DONE" 2>/dev/null | cut -d= -f2)${RESET}"
    echo -e "   Telegram: ${tg_str}  |  $(t "Юзеров" "Users"): $(get_users | wc -l)  |  $(t "SSH порт" "SSH port"): ${ssh_str}"
    local hysteria_str="${YELLOW}$(t "не установлен" "not installed")${RESET}"
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        systemctl is-active --quiet hysteria 2>/dev/null \
            && hysteria_str="${GREEN}UDP/${HYSTERIA_PORT:-8443}${RESET}" \
            || hysteria_str="${RED}$(t "остановлен" "stopped")${RESET}"
    fi
    echo -e "   Hysteria 2: ${hysteria_str}"
    local warp_str="${YELLOW}$(t "не установлен" "not installed")${RESET}"
    if command -v warp-cli &>/dev/null; then
        case "${WARP_MODE:-off}" in
            proxy) warp_str="${GREEN}proxy 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}${RESET}" ;;
            warp|warp+doh) warp_str="${GREEN}full ${WARP_MODE}${RESET}" ;;
            *) warp_str="${YELLOW}$(t "установлен" "installed")${RESET}" ;;
        esac
    fi
    echo -e "   WARP: ${warp_str}"
    local xray_str="${YELLOW}$(t "не установлен" "not installed")${RESET}"
    if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
        systemctl is-active --quiet xray 2>/dev/null \
            && xray_str="${GREEN}active${RESET}" \
            || xray_str="${RED}$(t "остановлен" "stopped")${RESET}"
        [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]] && xray_str="${xray_str} ${CYAN}443-fallback${RESET}"
    fi
    echo -e "   Xray Modern: ${xray_str}"
    local unbound_str="${YELLOW}$(t "не установлен" "not installed")${RESET}"
    if command -v unbound &>/dev/null; then
        if systemctl is-active --quiet unbound 2>/dev/null; then
            unbound_str="${GREEN}active${RESET} ${CYAN}${UNBOUND_GATEWAY_IP:-127.0.0.1}${RESET}"
        else
            unbound_str="${RED}$(t "остановлен" "stopped")${RESET}"
        fi
    fi
    echo -e "   DNS (Unbound): ${unbound_str}"
    local device_str="${YELLOW}$(t "выкл" "off")${RESET}"
    if [[ "${DEVICE_LIMIT_ENABLED:-0}" == "1" ]]; then
        device_str="${GREEN}${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}/${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}ч ${DEVICE_LIMIT_MODE:-alert}${RESET}"
    fi
    echo -e "   $(t "Лимит устройств" "Device limit"): ${device_str}"
    local nodes_str="${YELLOW}0${RESET}"
    if [[ -f "$NODES_FILE" ]]; then
        nodes_str="${GREEN}$(nodes_count)${RESET}"
    fi
    echo -e "   Multi-server nodes: ${nodes_str}"
    echo -e "   Режим 443: ${GREEN}$(edge_routing_mode_label)${RESET}"
    hr
    echo -e "   ${BOLD}1)${RESET}  $(t "Установить Yurich Panel" "Install Yurich Panel")"
    echo -e "   ${BOLD}2)${RESET}  $(t "Статус" "Status")"
    echo -e "   ${BOLD}3)${RESET}  $(t "Клиентский конфиг" "Client config")"
    echo -e "   ${BOLD}4)${RESET}  $(t "Управление пользователями" "User management")"
    echo -e "   ${BOLD}5)${RESET}  [DOM] $(t "Управление доменами" "Domain management")"
    echo -e "   ${BOLD}6)${RESET}  $(t "Мониторинг и статистика" "Monitoring and stats")"
    echo -e "   ${BOLD}7)${RESET}  $(t "Настройка Telegram + Бот" "Telegram + Bot setup")"
    echo -e "   ${BOLD}8)${RESET}  $(t "Перезапустить Caddy" "Restart Caddy")"
    echo -e "   ${BOLD}9)${RESET}  $(t "Обновить Caddy" "Update Caddy")"
    echo -e "   ${BOLD}10)${RESET} $(t "Логи" "Logs")"
    echo -e "   ${BOLD}11)${RESET} $(t "Удалить Yurich Panel" "Remove Yurich Panel")"
    echo -e "   ${BOLD}16)${RESET} [DIAG] $(t "Диагностика системы" "System diagnostics")"
    echo -e "   ${BOLD}17)${RESET} [DNS] Yurich DNS (Unbound)"
    echo -e "   ${BOLD}18)${RESET} [DONATE] $(t "Поддержать проект (донат)" "Support project (donation)")"
    echo -e "   ──────────────────────────"
    echo -e "   ${BOLD}12)${RESET} [SSH] SSH Hardening"
    echo -e "   ${BOLD}13)${RESET} [SYS] $(t "Обновить систему" "Update system")"
    echo -e "   ${BOLD}14)${RESET} [UPD] $(t "Обновить скрипт" "Update script")"
    echo -e "   ${BOLD}15)${RESET} [CAMO] $(t "Обновить камуфляж" "Update camouflage")"
    echo -e "   ${BOLD}19)${RESET} [RLD] $(t "Reload Caddy без разрыва" "Reload Caddy without restart")"
    echo -e "   ${BOLD}20)${RESET} [HY2] Hysteria 2 ($(t "UDP порт на выбор" "custom UDP port"))"
    echo -e "   ${BOLD}21)${RESET} [WARP] WARP modes (proxy/full tunnel)"
    echo -e "   ${BOLD}22)${RESET} [DEV] $(t "Лимит устройств / анти-шаринг" "Device limit / anti-sharing")"
    echo -e "   ${BOLD}23)${RESET} [XRAY] Xray VLESS/Trojan/REALITY fallback"
    echo -e "   ${BOLD}24)${RESET} [FIX] Diagnose --fix"
    echo -e "   ${BOLD}25)${RESET} [SUB] $(t "Страница подписки пользователя" "User subscription page")"
    echo -e "   ${BOLD}26)${RESET} [PAGE] $(t "Личная фейковая страница" "Private camouflage page")"
    echo -e "   ${BOLD}27)${RESET} [PROD] Production tools / Bridge"
    echo -e "   ${BOLD}28)${RESET} [LANG] $(t "Язык панели RU/EN" "Panel language RU/EN")"
    echo -e "   ${BOLD}29)${RESET} [NODES] Multi-server management"
    echo -e "   ${BOLD}30)${RESET} [EDGE] Routing mode / HAProxy"
    echo -e "   ${BOLD}31)${RESET} [SALES] VPN sales Telegram bot"
    echo -e "   ${BOLD}0)${RESET}  $(t "Выход" "Exit")"
    hr
    echo -ne "${CYAN}$(t "Выбор" "Choice") [0-31]: ${RESET}"
}

# ─── MAIN ────────────────────────────────────────────────────
main() {
    if [[ $# -gt 0 ]]; then
        case "$1" in
            version|--version|-v)
                echo "Yurich Panel v${VERSION}"
                [[ -n "${TELEGRAM_COMMUNITY_URL:-}" ]] && echo "Telegram: ${TELEGRAM_COMMUNITY_URL}"
                [[ -n "${PROJECT_WEBSITE_URL:-}" ]] && echo "Website:  ${PROJECT_WEBSITE_URL}"
                echo "GitHub:   ${PROJECT_GITHUB_SHORT}"
                return 0
                ;;
            help|--help|-h)
                echo "Yurich Panel v${VERSION}"
                echo "Usage: sudo bash yurich-panel.sh [command]"
                echo "Commands: install status config [user] reload restart update remove logs monitor routing-mode haproxy-status haproxy-apply haproxy-logs haproxy-tg users hysteria hy2 hysteria-sync hysteria-port hysteria-warp-enable hysteria-warp-disable hysteria-hop-enable hysteria-hop-disable warp warp-proxy warp-full warp-health warp-protocol warp-ssh-allow xray xray-target xray-add-user [user] xray-rebuild vless-tune egress-ipv4 egress-dualstack pingtunnel-install pingtunnel-status pingtunnel-config pingtunnel-rotate pingtunnel-remove xray-zapret devices subscription subscription-clean private-page protocol-health protocol-validate protocol-benchmark protocol-benchmark-monitor protocol-benchmark-install protocol-benchmark-history protocol-monitor protocol-monitor-install security-audit notify-expiry-list notify-bind-tg notify-expiry-run notify-news notify-news-test expiry-enforce notify-expiry-install tg-stats bot-menu health safe-apply backup export import bridge nodes fail2ban language ssh-hardening ssh-rescue sysupdate cert domains dns unbound yurich-dns yurich-dns-status yurich-dns-restart self-update version camouflage"
                return 0
                ;;
        esac
    fi

    check_root
    check_os

    if [[ $# -gt 0 ]]; then
        load_config; load_users
        case "$1" in
            install)   cmd_install ;;
            status)    cmd_status ;;
            config)    print_client_config "${2:-}" ;;
            reload)    cmd_reload ;;
            restart)   cmd_restart ;;
            update)    cmd_update ;;
            remove)    cmd_remove ;;
            logs)      cmd_logs ;;
            monitor)   cmd_monitor ;;
            routing-mode|edge-mode|frontend-mode) cmd_edge_routing_mode "${2:-}" ;;
            haproxy-status|haproxy) cmd_haproxy_status ;;
            haproxy-apply|haproxy-sni-apply) cmd_haproxy_apply ;;
            haproxy-logs|sni-logs) cmd_haproxy_logs ;;
            haproxy-tg|haproxy-telegram) cmd_haproxy_tg ;;
            users)     cmd_users ;;
            hysteria|hy2) cmd_hysteria_menu ;;
            hysteria-install|hy2-install) cmd_hysteria_install ;;
            hysteria-config|hy2-config) print_hysteria_client_config "${2:-}" ;;
            hysteria-status|hy2-status) cmd_hysteria_status ;;
            hysteria-logs|hy2-logs) cmd_hysteria_logs ;;
            hysteria-sync|hy2-sync) cmd_hysteria_sync_cli ;;
            hysteria-port|hy2-port) cmd_hysteria_change_port "${2:-}" ;;
            hysteria-warp-enable|hy2-warp-enable|turbo-warp-enable) cmd_hysteria_warp_enable ;;
            hysteria-warp-disable|hy2-warp-disable|turbo-warp-disable) cmd_hysteria_warp_disable ;;
            hysteria-hop-enable|hy2-hop-enable) cmd_hysteria_hop_enable "${2:-}" ;;
            hysteria-hop-disable|hy2-hop-disable) cmd_hysteria_hop_disable ;;
            hysteria-remove|hy2-remove) cmd_hysteria_remove ;;
            warp) cmd_warp_menu ;;
            warp-install|warp-proxy) cmd_warp_install ;;
            warp-full|warp-full-install) cmd_warp_full_install ;;
            warp-config) print_warp_proxy_config ;;
            warp-status) cmd_warp_status ;;
            warp-test) cmd_warp_test ;;
            warp-full-test) cmd_warp_test_full ;;
            warp-health) cmd_warp_health ;;
            warp-protocol) cmd_warp_protocol ;;
            warp-ssh-allow|warp-ssh|warp-allow) cmd_warp_ssh_allow ;;
            warp-logs) cmd_warp_logs ;;
            warp-disable) cmd_warp_disable ;;
            warp-remove) cmd_warp_remove ;;
            xray) cmd_xray_menu ;;
            xray-install) cmd_xray_install ;;
            xray-target|xray-reality-target) cmd_xray_reality_target ;;
            xray-add-user|xray-user) cmd_xray_add_user "${2:-}" "${3:-}" ;;
            xray-compat-user|xray-reality-compat) cmd_xray_add_compat_user "${2:-}" ;;
            xray-rebuild) cmd_xray_rebuild ;;
            vless-tune|xray-tune|reality-tune) cmd_vless_tune ;;
            egress-ipv4|egress-prefer-ipv4|location-ipv4) cmd_egress_prefer_ipv4 ;;
            egress-dualstack|egress-ipv6-restore|location-dualstack) cmd_egress_dualstack ;;
            pingtunnel-install|icmp-install) cmd_pingtunnel_install ;;
            pingtunnel-status|icmp-status) cmd_pingtunnel_status ;;
            pingtunnel-config|icmp-config) cmd_pingtunnel_config "${2:-}" ;;
            pingtunnel-rotate|icmp-rotate) cmd_pingtunnel_rotate ;;
            pingtunnel-remove|icmp-remove) cmd_pingtunnel_remove ;;
            xray-zapret) cmd_xray_zapret "${2:-enable}" ;;
            xray-config) print_xray_client_config "${2:-}" ;;
            xray-status) cmd_xray_status ;;
            xray-logs) cmd_xray_logs ;;
            xray-remove) cmd_xray_remove ;;
            devices) cmd_devices_menu ;;
            devices-scan) cmd_devices_scan ;;
            devices-config) cmd_devices_config ;;
            devices-disable) cmd_devices_disable ;;
            devices-lock) device_disable_user "${2:-}" ;;
            devices-unlock) device_enable_user "${2:-}" ;;
            devices-unlock-all) cmd_devices_unlock_all ;;
            subscription|sub) cmd_subscription_user "${2:-}" ;;
            subscription-reset|sub-reset) cmd_subscription_reset "${2:-}" ;;
            subscription-clean|subscriptions-clean|subscription-rebuild-clean) cmd_subscription_rebuild_clean "${2:-}" ;;
            protocol-validate|protocols-validate) cmd_protocol_validate ;;
            protocol-benchmark|protocols-benchmark|benchmark) cmd_protocol_benchmark "${2:-}" "${3:-1}" ;;
            protocol-benchmark-monitor|protocols-benchmark-monitor|benchmark-monitor) cmd_protocol_benchmark_monitor "${2:-}" "${3:-}" ;;
            protocol-benchmark-install|protocols-benchmark-install|benchmark-install) cmd_protocol_benchmark_install "${2:-}" "${3:-}" ;;
            protocol-benchmark-history|protocols-benchmark-history|benchmark-history) cmd_protocol_benchmark_history "${2:-30}" ;;
            protocol-health|protocols-health) cmd_protocol_health ;;
            protocol-monitor|protocols-monitor) cmd_protocol_monitor ;;
            protocol-monitor-install|protocols-monitor-install) cmd_protocol_monitor_install ;;
            private-page) install_private_camouflage_page "${2:-}" ;;
            notify-bind-tg|bind-tg) cmd_notify_bind_tg "${2:-}" "${3:-}" ;;
            notify-unbind-tg|unbind-tg) cmd_notify_unbind_tg "${2:-}" ;;
            notify-expiry-list|notify-list|expiring) cmd_notify_expiry_list ;;
            notify-expiry-run|notify-run) cmd_notify_expiry_run ;;
            expiry-enforce|notify-expiry-enforce) cmd_enforce_expired_users ;;
            notify-expiry-test|notify-test|test-notify) cmd_notify_expiry_test "${2:-}" ;;
            notify-news-test|news-test|broadcast-test) shift; cmd_notify_news_test "$*" ;;
            notify-news|news|broadcast) shift; cmd_notify_news_broadcast "$*" ;;
            notify-expiry-install|notify-install) cmd_notify_expiry_install ;;
            tg-stats)      tg_send_stats; ok "Отправлено" ;;
            security-audit|audit-security) cmd_security_audit ;;
            ssh-hardening) cmd_ssh_hardening ;;
            ssh-rescue)    cmd_ssh_rescue ;;
            sysupdate)     cmd_sysupdate ;;
            cert)        load_config; check_cert "${DOMAIN:-}" ;;
            domains)     load_config; cmd_domains ;;
            qr)          load_config; print_client_config ;;
            ssh-key)     cat "${CONFIG_DIR}/ssh_private_key" 2>/dev/null || err "Ключ не найден: ${CONFIG_DIR}/ssh_private_key" ;;
            diagnose)    cmd_diagnose "${2:-}" ;;
            dns|unbound|yurich-dns|aurum-dns)                         cmd_unbound_plugin ;;
            dns-install|unbound-install|yurich-dns-install|aurum-dns-install) cmd_dns_install ;;
            dns-mode|unbound-mode)                         cmd_dns_set_mode ;;
            dns-vpn|unbound-vpn|yurich-dns-vpn|aurum-dns-vpn)             cmd_dns_vpn_access ;;
            dns-update|unbound-update)                     cmd_dns_update ;;
            dns-filter-install|unbound-filter-install)      cmd_dns_filter_install ;;
            dns-monitor|unbound-monitor)                   cmd_dns_monitor ;;
            dns-monitor-install|unbound-monitor-install)    cmd_dns_monitor_install ;;
            dns-allowlist|unbound-allowlist|dns-whitelist|unbound-whitelist) cmd_dns_whitelist ;;
            dns-status|unbound-status|unbound-test|yurich-dns-status|yurich-dns-test|aurum-dns-status|aurum-dns-test) cmd_dns_status ;;
            dns-restart|unbound-restart|yurich-dns-restart|aurum-dns-restart) cmd_dns_restart ;;
            dns-remove|unbound-remove|yurich-dns-remove|aurum-dns-remove)     cmd_dns_remove ;;
            bot)         load_config; cmd_bot ;;
            bot-install) load_config; install_bot_service ;;
            bot-menu)    load_config; tg_apply_bot_menu ;;
            sales-bot)   load_config; cmd_sales_bot ;;
            sales-bot-install|sales-install) load_config; install_sales_bot_service "${2:-}" "${3:-}" ;;
            sales-bot-menu|sales-menu) load_config; sales_apply_bot_menu ;;
            sales-bot-defaults|sales-defaults|sales-config) load_config; cmd_sales_bot_apply_defaults ;;
            sales-orders) load_config; sales_orders_text ;;
            health|health-check) cmd_health_check ;;
            safe-apply)   cmd_safe_apply ;;
            backup|backup-encrypted) cmd_backup_encrypted ;;
            export|export-state) cmd_export_state ;;
            import|import-state) cmd_import_state "${2:-}" ;;
            bridge)       cmd_bridge_menu ;;
            bridge-show)  cmd_bridge_show ;;
            bridge-remove) cmd_bridge_remove ;;
            nodes|node|multi-server) cmd_nodes_menu ;;
            nodes-list|node-list) cmd_nodes_list ;;
            nodes-add|node-add) cmd_nodes_add ;;
            nodes-test|node-test) cmd_nodes_test "${2:-all}" ;;
            nodes-deploy|node-deploy) cmd_nodes_deploy_script "${2:-}" ;;
            nodes-sync|node-sync) cmd_nodes_sync_users "${2:-all}" ;;
            nodes-subscriptions|nodes-rebuild-subscriptions) cmd_nodes_rebuild_subscriptions ;;
            nodes-remove|node-remove) cmd_nodes_remove "${2:-}" ;;
            fail2ban|f2b|security) setup_fail2ban "$(current_ssh_port)" ;;
            language|lang) cmd_language ;;
            self-update)  load_config; cmd_self_update ;;
            camouflage)   install_camouflage_page ;;
            version)
                echo "Yurich Panel v${VERSION}"
                [[ -n "${TELEGRAM_COMMUNITY_URL:-}" ]] && echo "Telegram: ${TELEGRAM_COMMUNITY_URL}"
                [[ -n "${PROJECT_WEBSITE_URL:-}" ]] && echo "Website:  ${PROJECT_WEBSITE_URL}"
                echo "GitHub:   ${PROJECT_GITHUB_SHORT}"
                ;;
            *) err "Неизвестная команда: $1"
               echo "Доступные: install status config [user] reload restart update remove logs monitor routing-mode haproxy-status haproxy-apply haproxy-logs haproxy-tg users hysteria hy2 hysteria-sync hysteria-port hysteria-warp-enable hysteria-warp-disable hysteria-hop-enable hysteria-hop-disable warp warp-proxy warp-full warp-health warp-protocol warp-ssh-allow xray xray-target xray-add-user [user] xray-compat-user [user] xray-rebuild vless-tune egress-ipv4 egress-dualstack pingtunnel-install pingtunnel-status pingtunnel-config pingtunnel-rotate pingtunnel-remove xray-zapret devices subscription subscription-clean private-page protocol-health protocol-validate protocol-benchmark protocol-benchmark-monitor protocol-benchmark-install protocol-benchmark-history protocol-monitor protocol-monitor-install security-audit notify-expiry-list notify-bind-tg notify-expiry-run notify-news notify-news-test expiry-enforce notify-expiry-install tg-stats bot-menu health safe-apply backup export import bridge nodes fail2ban language ssh-hardening ssh-rescue sysupdate cert domains dns unbound yurich-dns yurich-dns-status yurich-dns-restart self-update version camouflage"
               exit 1 ;;
        esac
        exit 0
    fi

    # Тихая проверка обновлений в фоне
    check_update_available

    while true; do
        show_menu
        read -r choice; echo
        load_config; load_users
        case "$choice" in
            1)  cmd_install ;;
            2)  cmd_status ;;
            3)  print_client_config ;;
            4)  cmd_users ;;
            5)  cmd_domains ;;
            6)  cmd_monitor ;;
            7)  setup_telegram ;;
            8)  cmd_restart ;;
            9)  cmd_update ;;
            10) cmd_logs ;;
            11) cmd_remove ;;
            12) cmd_ssh_hardening ;;
            13) cmd_sysupdate ;;
            14) cmd_self_update ;;
            15) install_camouflage_page && ok "Камуфляж обновлён" ;;
            16) cmd_diagnose ;;
            17) cmd_dns_menu ;;
            18) cmd_donate ;;
            19) cmd_reload ;;
            20) cmd_hysteria_menu ;;
            21) cmd_warp_menu ;;
            22) cmd_devices_menu ;;
            23) cmd_xray_menu ;;
            24) cmd_diagnose_fix ;;
            25) cmd_subscription_user ;;
            26) install_private_camouflage_page ;;
            27) cmd_production_tools_menu ;;
            28) cmd_language ;;
            29) cmd_nodes_menu ;;
            30) cmd_haproxy_menu ;;
            31) install_sales_bot_service ;;
            0)  echo -e "${GREEN}$(t "Пока!" "Bye!")${RESET}"; exit 0 ;;
            *)  warn "$(t "Неверный выбор" "Invalid choice")" ;;
        esac
        echo
        echo -ne "${YELLOW}$(t "Нажми Enter чтобы вернуться в меню..." "Press Enter to return to menu...")${RESET}"
        read -r
    done
}

main "$@"
