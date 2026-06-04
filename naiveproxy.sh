#!/bin/bash
# ============================================================
#   NaiveProxy Manager v5.5.13 — by Иван Юрьевич
#   Стек: Caddy 2 + klzgrad/forwardproxy@naive + Hysteria 2 + WARP + Xray Modern
#   ОС: Ubuntu 20.04 / 22.04 / 24.04
#
#   Copyright (C) 2026 Иван Юрьевич (Ivan Yurievich)
#   License: GPL-3.0 — see LICENSE file
#   Commercial use without author permission is prohibited.
#
#   Telegram: https://t.me/ivan_it_net
#   Сайт:     https://ivan-it.net
#   GitHub:   https://github.com/ivan-yurich/naiveproxy
#   Донат:    https://www.donationalerts.com/r/ivan_yurievich
# ============================================================

set -euo pipefail

VERSION="5.5.13"
LANG_UI="${NAIVEPROXY_LANG:-ru}"  # ru или en — export NAIVEPROXY_LANG=en
GITHUB_RAW="https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/naiveproxy.sh"
GITHUB_API="https://api.github.com/repos/ivan-yurich/naiveproxy/releases/latest"
SCRIPT_PATH="/usr/local/bin/naiveproxy.sh"

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
    echo -e "  ${BOLD}  NaiveProxy Manager${RESET} ${DIM}v${VERSION}${RESET}  ${DIM}·${RESET}  ${CYAN}by Иван Юрьевич${RESET}"
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${YELLOW}🔔 Обновления выходят раз в месяц${RESET}"
    echo -e "  ${CYAN}📱 Telegram:${RESET} https://t.me/ivan_it_net"
    echo -e "  ${CYAN}🌐 Сайт:${RESET}     https://ivan-it.net"
    echo -e "  ${CYAN}💻 GitHub:${RESET}   github.com/ivan-yurich/naiveproxy"
    echo -e "  ${BOLD}${GOLD}💛 Донат:${RESET}    donationalerts.com/r/ivan_yurievich"
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
XRAY_BIN="/usr/local/bin/xray"
XRAY_SERVICE="/etc/systemd/system/xray.service"
XRAY_CONFIG_DIR="/etc/xray"
XRAY_CONFIG="/etc/xray/config.json"
WARP_PROXY_PORT_DEFAULT="40000"
WEBROOT="/var/www/html"
CONFIG_FILE="/etc/naiveproxy/naive.conf"
CONFIG_DIR="/etc/naiveproxy"
USERS_FILE="/etc/naiveproxy/users.conf"
DISABLED_USERS_FILE="/etc/naiveproxy/users.disabled"
XRAY_USERS_FILE="/etc/naiveproxy/xray-users.conf"
XRAY_DISABLED_USERS_FILE="/etc/naiveproxy/xray-users.disabled"
SUBS_DIR="/etc/naiveproxy/subscriptions"
SUBS_WEB_DIR="${WEBROOT}/s"
PRIVATE_PAGE_TOKEN_FILE="/etc/naiveproxy/private_page.token"
PRIVATE_WEB_DIR="${WEBROOT}/p"
LOG_DIR="/var/log/caddy"
BACKUP_DIR="/etc/naiveproxy/backups"
MONITOR_SCRIPT="/etc/naiveproxy/monitor.sh"
SSH_HARDENING_DONE="/etc/naiveproxy/.ssh_hardened"
SYSUPDATE_DONE="/etc/naiveproxy/.sysupdate_done"
DEVICE_LIMIT_DEFAULT="5"
DEVICE_WINDOW_HOURS_DEFAULT="24"
DEVICE_CRON="/etc/cron.d/naiveproxy-device-limit"
XRAY_REALITY_PORT_DEFAULT="8444"
XRAY_MKCP_PORT_DEFAULT="8446"
XRAY_GRPC_PORT_DEFAULT="8447"
XRAY_CADDY_FALLBACK_PORT_DEFAULT="7443"


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
                if ! ss -tlnp | grep -q ":${new_ssh_port} "; then
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

    # Fail2Ban
    apt-get update -qq 2>/dev/null || true
    apt-get install -y -q fail2ban

    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
# Глобальные настройки
bantime   = 86400    # Бан 24 часа
findtime  = 600      # Окно поиска 10 минут
maxretry  = 3        # Максимум попыток
backend   = systemd
banaction = iptables-multiport

[sshd]
enabled   = true
port      = ${new_ssh_port}
logpath   = %(sshd_log)s
maxretry  = 3
bantime   = 604800   # Бан 7 дней за брутфорс SSH

[sshd-ddos]
enabled   = true
port      = ${new_ssh_port}
logpath   = %(sshd_log)s
maxretry  = 10
findtime  = 60       # 10 попыток за 1 минуту = DDoS бан
bantime   = 604800

[recidive]
enabled   = true
logpath   = /var/log/fail2ban.log
banaction = ufw
bantime   = 2592000  # Рецидивисты — бан на 30 дней
findtime  = 86400
maxretry  = 3
EOF

    # Настройка action для UFW
    cat > /etc/fail2ban/action.d/ufw.conf << 'UEOF'
[Definition]
actionstart =
actionstop  =
actioncheck =
actionban   = ufw insert 1 deny from <ip> to any
actionunban = ufw delete deny from <ip> to any
UEOF

    systemctl enable fail2ban --quiet
    systemctl restart fail2ban
    ok "Fail2Ban настроен:"
    ok "  SSH брутфорс: 3 попытки → бан 7 дней"
    ok "  SSH DDoS: 10 попыток за 1 мин → бан 7 дней"
    ok "  Рецидивисты: → бан 30 дней"

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
    ufw allow 80/tcp comment "NaiveProxy ACME" >/dev/null 2>&1 || true
    ufw allow 443/tcp comment "NaiveProxy HTTPS" >/dev/null 2>&1 || true
    ufw allow 443/udp comment "NaiveProxy HTTP3" >/dev/null 2>&1 || true
    systemctl stop fail2ban >/dev/null 2>&1 || true

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
        else
            warn "CONFIG_FILE принадлежит не root — пропускаю source"
        fi
    fi
}

save_config() {
    mkdir -p "$CONFIG_DIR"
    {
        printf 'DOMAIN=%q\n' "${DOMAIN:-}"
        printf 'DOMAINS=%q\n' "${DOMAINS:-${DOMAIN:-}}"
        printf 'EMAIL=%q\n' "${EMAIL:-}"
        printf 'TG_TOKEN=%q\n' "${TG_TOKEN:-}"
        printf 'TG_CHAT_ID=%q\n' "${TG_CHAT_ID:-}"
        printf '# Доп. администраторы через запятую: id1,id2,id3\n'
        printf 'TG_ADMINS=%q\n' "${TG_ADMINS:-}"
        printf 'HYSTERIA_PORT=%q\n' "${HYSTERIA_PORT:-8443}"
        printf 'HYSTERIA_PASSWORD=%q\n' "${HYSTERIA_PASSWORD:-}"
        printf 'HYSTERIA_OBFS_PASSWORD=%q\n' "${HYSTERIA_OBFS_PASSWORD:-}"
        printf 'UNBOUND_ENABLED=%q\n' "${UNBOUND_ENABLED:-0}"
        printf 'UNBOUND_MODE=%q\n' "${UNBOUND_MODE:-recursive}"
        printf 'UNBOUND_ADBLOCK=%q\n' "${UNBOUND_ADBLOCK:-0}"
        printf 'UNBOUND_GATEWAY_IP=%q\n' "${UNBOUND_GATEWAY_IP:-}"
        printf 'UNBOUND_MANAGED_GATEWAY=%q\n' "${UNBOUND_MANAGED_GATEWAY:-0}"
        printf 'UNBOUND_VPN_ENABLED=%q\n' "${UNBOUND_VPN_ENABLED:-0}"
        printf 'UNBOUND_VPN_CIDRS=%q\n' "${UNBOUND_VPN_CIDRS:-10.0.0.0/24}"
        printf 'WARP_PROXY_PORT=%q\n' "${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
        printf 'WARP_PROXY_ENABLED=%q\n' "${WARP_PROXY_ENABLED:-0}"
        printf 'WARP_MODE=%q\n' "${WARP_MODE:-off}"
        printf 'WARP_PROTOCOL=%q\n' "${WARP_PROTOCOL:-auto}"
        printf 'DEVICE_LIMIT_ENABLED=%q\n' "${DEVICE_LIMIT_ENABLED:-0}"
        printf 'DEVICE_LIMIT=%q\n' "${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}"
        printf 'DEVICE_WINDOW_HOURS=%q\n' "${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}"
        printf 'DEVICE_LIMIT_MODE=%q\n' "${DEVICE_LIMIT_MODE:-alert}"
        printf 'XRAY_ENABLED=%q\n' "${XRAY_ENABLED:-0}"
        printf 'XRAY_FALLBACK_ENABLED=%q\n' "${XRAY_FALLBACK_ENABLED:-0}"
        printf 'XRAY_REALITY_PORT=%q\n' "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
        printf 'XRAY_MKCP_PORT=%q\n' "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}"
        printf 'XRAY_GRPC_PORT=%q\n' "${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}"
        printf 'XRAY_CADDY_FALLBACK_PORT=%q\n' "${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
        printf 'XRAY_REALITY_TARGET=%q\n' "${XRAY_REALITY_TARGET:-www.microsoft.com:443}"
        printf 'XRAY_REALITY_SERVER_NAME=%q\n' "${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}"
        printf 'XRAY_REALITY_PRIVATE_KEY=%q\n' "${XRAY_REALITY_PRIVATE_KEY:-}"
        printf 'XRAY_REALITY_PUBLIC_KEY=%q\n' "${XRAY_REALITY_PUBLIC_KEY:-}"
        printf 'XRAY_REALITY_SHORT_ID=%q\n' "${XRAY_REALITY_SHORT_ID:-}"
        printf 'XRAY_TROJAN_PASSWORD=%q\n' "${XRAY_TROJAN_PASSWORD:-}"
        printf 'INSTALLED_AT=%q\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    } > "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
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

get_user_pass() {
    local lookup_user="$1"
    while IFS=: read -r user pass; do
        [[ "$user" == "$lookup_user" ]] && { printf '%s\n' "$pass"; return 0; }
    done < <(get_users)
    return 1
}

active_user_count() {
    get_users | wc -l
}

# ─── Telegram ────────────────────────────────────────────────
tg_send() {
    local message="$1"
    [[ -z "${TG_TOKEN:-}" || -z "${TG_CHAT_ID:-}" ]] && return 0
    # Используем --data-urlencode для безопасной передачи спецсимволов
    curl -s --max-time 10 --retry 2 --retry-delay 3 \
        -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${TG_CHAT_ID}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "text=${message}" \
        >/dev/null 2>&1 || true
}

tg_alert_up() {
    tg_send "✅ <b>NaiveProxy запущен</b>
🌐 Домен: <code>${DOMAIN:-unknown}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')
📡 Сервер: $(hostname)"
}

tg_alert_down() {
    tg_send "🔴 <b>NaiveProxy упал!</b>
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
        tg_send "❌ NaiveProxy не установлен"
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

    tg_send "📊 <b>Статистика NaiveProxy</b>

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
    echo "❓ Недоступен"
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
    response=$(curl -s "https://api.telegram.org/bot${input_token}/getMe" 2>/dev/null || echo "{}")
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
    tg_apply_bot_menu || warn "Команды Telegram Menu можно применить позже: sudo bash naiveproxy.sh bot-menu"

    tg_send "🤖 <b>NaiveProxy Manager подключён!</b>
✅ Telegram-уведомления настроены
📡 Сервер: <code>$(hostname)</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')

<b>Доступные команды в скрипте:</b>
• статус — bash naiveproxy.sh tg-stats
• мониторинг — каждые 5 минут автоматически"
    ok "Тестовое сообщение отправлено"
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

tg_send() {
    local msg="$1"
    [[ -z "${TG_TOKEN:-}" || -z "${TG_CHAT_ID:-}" ]] && return
    curl -s --max-time 10 --retry 2 \
        -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{"chat_id":"${TG_CHAT_ID}","parse_mode":"HTML","text":"${msg}"}" \
        >/dev/null 2>&1 || true
}

FLAG="/run/naiveproxy_was_down"

if ! systemctl is-active --quiet caddy 2>/dev/null; then
    if [[ ! -f "$FLAG" ]]; then
        touch "$FLAG"
        tg_send "🔴 <b>NaiveProxy упал!</b>
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
        script_path="/usr/local/bin/naiveproxy.sh"
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

    local server_ip domain_ip
    server_ip=$(curl -s4 --max-time 5 https://ifconfig.me 2>/dev/null         || curl -s4 --max-time 5 https://api.ipify.org 2>/dev/null         || curl -s4 --max-time 5 https://checkip.amazonaws.com 2>/dev/null         || echo "")
    domain_ip=$(getent hosts "$domain" 2>/dev/null | awk '{print $1}' | head -1 || echo "")

    if [[ -z "$domain_ip" ]]; then
        err "Домен $domain не резолвится. Проверь DNS."
        exit 1
    fi

    if [[ "$server_ip" != "$domain_ip" ]]; then
        warn "IP сервера: $server_ip  |  IP домена: $domain_ip"
        warn "Не совпадают! Let's Encrypt может отказать в сертификате."
        echo -ne "${YELLOW}Продолжить всё равно? [y/N]: ${RESET}"
        read -r ans
        [[ "${ans,,}" == "y" ]] || exit 1
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
        local expected_sha
        [[ "$arch" == "arm64" ]] && expected_sha="$go_sha256_arm64" || expected_sha="$go_sha256_amd64"

        wget -q "$go_url" -O /tmp/go.tar.gz
        local actual_sha
        actual_sha=$(sha256sum /tmp/go.tar.gz | awk '{print $1}')
        if [[ "$actual_sha" != "$expected_sha" ]]; then
            err "SHA256 Go не совпадает! Возможная атака на цепочку поставок. Прерываю."
            rm -f /tmp/go.tar.gz
            exit 1
        fi
        ok "SHA256 Go подтверждён"
        rm -rf /usr/local/go
        tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
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

    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

    # Клонируем naive ветку напрямую — единственный надёжный способ
    local fp_dir
    fp_dir=$(mktemp -d /tmp/naiveproxy_forwardproxy_XXXXXX)
    trap 'rm -rf "${fp_dir:-}" 2>/dev/null' RETURN
    info "Клонирую klzgrad/forwardproxy@naive..."
    if ! git clone -b naive --depth 1         https://github.com/klzgrad/forwardproxy.git "$fp_dir" 2>/dev/null; then
        err "Не удалось клонировать forwardproxy. Проверь интернет."
        exit 1
    fi

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
    done < <(get_users)
    if [[ "$auth_count" -lt 1 ]]; then
        err "Нет активных пользователей. Caddyfile не обновляю, чтобы не открыть прокси без auth."
        return 1
    fi

    # Глобальный блок
    cat > "$CADDYFILE" <<EOF
{
  order forward_proxy before file_server
  servers :443 {
      protocols h1 h2 h3
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
${auth_blocks}    hide_ip
    hide_via
    probe_resistance
  }

  header /s/* {
    X-Robots-Tag "noindex, nofollow, noarchive"
    Cache-Control "no-store"
  }

  header /p/* {
    X-Robots-Tag "noindex, nofollow, noarchive"
    Cache-Control "no-store"
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
    ok "Caddyfile обновлён (доменов: ${dom_count}, пользователей: $(get_users | wc -l))"
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
<meta name="description" content="DevStack — Technical notes on Linux, networking, security and open source infrastructure.">
<title>DevStack — Linux & Infrastructure Notes</title>
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
        <div class="about-name">Ivan Yu.</div>
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
    <div class="footer-left"><span>&gt;_ DevStack</span> · Built with Caddy · © 2026</div>
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
    done < <(get_users)
    if [[ "$auth_count" -lt 1 ]]; then
        err "Нет активных пользователей. Caddyfile не обновляю, чтобы не открыть прокси без auth."
        return 1
    fi

    local site_label=":443, ${DOMAIN}"
    local tls_line="  tls ${EMAIL}"
    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        site_label="http://127.0.0.1:${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
        tls_line=""
        info "Caddy переключён в Xray fallback mode: ${site_label}"
    fi

    cat > "$CADDYFILE" <<EOF
{
    order forward_proxy before file_server
    servers :443 {
        protocols h1 h2 h3
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
${auth_blocks}        hide_ip
        hide_via
        probe_resistance
    }

    header /s/* {
        X-Robots-Tag "noindex, nofollow, noarchive"
        Cache-Control "no-store"
    }

    header /p/* {
        X-Robots-Tag "noindex, nofollow, noarchive"
        Cache-Control "no-store"
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
    ok "Caddyfile обновлён (пользователей: $(get_users | wc -l))"
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
Description=Caddy NaiveProxy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

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
StartLimitBurst=5
StartLimitIntervalSec=60

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

    # Базовые порты NaiveProxy
    ufw allow 80/tcp  comment "NaiveProxy ACME"  >/dev/null 2>&1 || true
    ufw allow 443/tcp comment "NaiveProxy HTTPS" >/dev/null 2>&1 || true
    ufw allow 443/udp comment "NaiveProxy HTTP3" >/dev/null 2>&1 || true

    # Лимит подключений — защита от DDoS и сканирования
    ufw allow 80/tcp  >/dev/null 2>&1 || true

    # Блокируем типичные порты для сканеров
    for port in 3306 5432 6379 27017 8080 8888 9200; do
        ufw deny "${port}/tcp" comment "Block scanners" >/dev/null 2>&1 || true
    done

    ok "UFW: открыт SSH порт ${ssh_port}/tcp"
    ok "UFW: открыты 80, 443/tcp, 443/udp"
    ok "UFW: заблокированы порты БД и типичные цели сканеров"
    ok "UFW: лимит на 80/tcp для защиты от DDoS"
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

# ─── Клиентский конфиг ───────────────────────────────────────
aurum_dns_client_ip() {
    if [[ "${UNBOUND_VPN_ENABLED:-0}" == "1" && -n "${UNBOUND_GATEWAY_IP:-}" ]]; then
        printf '%s\n' "$UNBOUND_GATEWAY_IP"
    fi
}

singbox_naive_tun_json() {
    local user="$1" pass="$2" dns_ip
    dns_ip=$(aurum_dns_client_ip)
    if [[ -n "$dns_ip" ]]; then
        cat <<EOF
{
  "dns": {
    "servers": [
      {
        "tag": "aurum-dns",
        "address": "tcp://${dns_ip}:53",
        "detour": "naiveproxy-out"
      }
    ],
    "final": "aurum-dns",
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
    echo -e "${BOLD}${GREEN}  Клиентский конфиг NaiveProxy${RESET}"
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
    echo -e "  Caddy 2 + klzgrad/forwardproxy@naive"
    echo
    echo -e "${YELLOW}  Важно для приложений:${RESET}"
    echo -e "  Выбирай тип ${BOLD}NaiveProxy / naive${RESET}, а не VLESS/Trojan/Shadowsocks."
    echo -e "  Если в приложении нет NaiveProxy, используй HTTPS proxy fallback ниже."
    echo -e "  Для телефона включай VPN/TUN mode, иначе не весь трафик пойдёт через прокси."
    echo
    echo -e "${CYAN}  URI (NaiveProxy):${RESET}"
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
    echo -e "${CYAN}  JSON (sing-box outbound, native NaiveProxy):${RESET}"
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
    if [[ -n "$(aurum_dns_client_ip)" ]]; then
        echo -e "${GREEN}  Aurum DNS включён:${RESET} DNS в этом примере идёт через ${CYAN}tcp://$(aurum_dns_client_ip):53${RESET}"
    else
        echo -e "${YELLOW}  Aurum DNS для клиентов выключен:${RESET} меню 17 → 2 включит DNS в этот пример."
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
            echo -e "  👤 ${BOLD}$u${RESET} : naive+https://${u}:${p}@${DOMAIN}:443"
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
    ok "Отсканируй QR в NekoBox / Shadowrocket"
    hr
}

# ─── HYSTERIA 2 ───────────────────────────────────────────────
install_hysteria_bin() {
    local arch asset url tmp_bin tmp_hash expected actual
    arch=$(detect_hysteria_arch) || return 1
    asset="hysteria-linux-${arch}"
    url="https://github.com/apernet/hysteria/releases/latest/download/${asset}"
    tmp_bin=$(mktemp /tmp/hysteria_XXXXXX)
    tmp_hash=$(mktemp /tmp/hysteria_hashes_XXXXXX)
    trap 'rm -f "${tmp_bin:-}" "${tmp_hash:-}" 2>/dev/null; trap - RETURN' RETURN

    info "Скачиваю Hysteria 2 (${asset})..."
    if ! curl -fsSL --retry 3 --connect-timeout 15 --max-time 180 "$url" -o "$tmp_bin"; then
        err "Не удалось скачать Hysteria 2: $url"
        return 1
    fi

    if curl -fsSL --connect-timeout 10 --max-time 30 \
        "https://github.com/apernet/hysteria/releases/latest/download/hashes.txt" -o "$tmp_hash" 2>/dev/null; then
        expected=$(grep -F "$asset" "$tmp_hash" | awk '{for(i=1;i<=NF;i++) if($i ~ /^[a-f0-9]{64}$/){print $i; exit}}' | head -1)
        if [[ -n "$expected" ]]; then
            actual=$(sha256sum "$tmp_bin" | awk '{print $1}')
            if [[ "$actual" != "$expected" ]]; then
                err "SHA256 Hysteria 2 не совпадает. Установка остановлена."
                return 1
            fi
            ok "SHA256 Hysteria 2 подтверждён"
        else
            warn "Не нашёл SHA256 для ${asset} в hashes.txt, продолжаю после HTTPS-загрузки"
        fi
    else
        warn "Не удалось скачать hashes.txt, продолжаю после HTTPS-загрузки"
    fi

    install -m 755 "$tmp_bin" "$HYSTERIA_BIN"
    ok "Hysteria 2 установлен: $("$HYSTERIA_BIN" version 2>/dev/null | head -1 || echo "$HYSTERIA_BIN")"
}

write_hysteria_config() {
    load_config
    load_users
    local cert_file key_file users_for_hysteria
    ensure_hysteria_secrets || return 1
    cert_file=$(find_caddy_cert "${DOMAIN:-}" || true)
    key_file=$(find_caddy_key "${DOMAIN:-}" || true)
    users_for_hysteria=$(get_users 2>/dev/null || true)

    if [[ -z "$cert_file" || -z "$key_file" ]]; then
        err "Не нашёл TLS сертификат Caddy для ${DOMAIN:-не задан}"
        err "Сначала запусти NaiveProxy и дождись TLS: sudo bash naiveproxy.sh install"
        return 1
    fi

    mkdir -p "$CONFIG_DIR"
    cat > "$HYSTERIA_CONFIG" <<EOF
# Hysteria 2 работает отдельно от Caddy:
# TCP/443 -> Caddy NaiveProxy, UDP/${HYSTERIA_PORT:-8443} -> Hysteria 2
listen: :${HYSTERIA_PORT:-8443}

tls:
  cert: ${cert_file}
  key: ${key_file}

auth:
EOF
    if [[ -n "$users_for_hysteria" ]]; then
        cat >> "$HYSTERIA_CONFIG" <<EOF
  type: userpass
  userpass:
EOF
        while IFS=: read -r h_user h_pass; do
            [[ -z "$h_user" || -z "$h_pass" ]] && continue
            printf '    "%s": "%s"\n' "$h_user" "$h_pass" >> "$HYSTERIA_CONFIG"
        done <<< "$users_for_hysteria"
    else
        cat >> "$HYSTERIA_CONFIG" <<EOF
  type: password
  password: "${HYSTERIA_PASSWORD}"
EOF
    fi

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
EOF
    chmod 600 "$HYSTERIA_CONFIG"

    ok "Hysteria 2 конфиг записан: $HYSTERIA_CONFIG"
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
        if ! is_valid_proxy_user "$selected_user" || ! selected_pass=$(get_user_pass "$selected_user" 2>/dev/null); then
            err "Пользователь $selected_user не найден для Hysteria"
            return 1
        fi
        printf '%s:%s\n' "$selected_user" "$selected_pass"
        return 0
    fi

    first_user=$(get_users | head -1 | cut -d: -f1)
    first_pass=$(get_users | head -1 | cut -d: -f2)
    if [[ -n "$first_user" && -n "$first_pass" ]]; then
        printf '%s:%s\n' "$first_user" "$first_pass"
        return 0
    fi

    printf '%s\n' "${HYSTERIA_PASSWORD:-}"
}

hysteria_uri_for_user() {
    local selected_user="${1:-}" auth
    auth=$(hysteria_user_auth "$selected_user") || return 1
    [[ -z "$auth" ]] && return 1
    printf 'hy2://%s@%s:%s/?sni=%s&obfs=salamander&obfs-password=%s' \
        "$auth" "${DOMAIN}" "${HYSTERIA_PORT:-8443}" "${DOMAIN}" "${HYSTERIA_OBFS_PASSWORD}"
    if [[ -n "$selected_user" ]]; then
        printf '#%s-hy2' "$selected_user"
    fi
    printf '\n'
}

sync_hysteria_users_if_active() {
    load_config
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        info "Обновляю Hysteria 2 userpass по текущим пользователям..."
        if write_hysteria_config && systemctl restart hysteria 2>/dev/null; then
            ok "Hysteria 2 обновлён для пользователей"
            return 0
        fi
        warn "Hysteria 2 не удалось обновить автоматически. Проверь: sudo bash naiveproxy.sh hysteria-status"
        return 1
    fi
    return 0
}

print_hysteria_client_config() {
    load_config
    local selected_user="${1:-}"
    if [[ -z "${DOMAIN:-}" || -z "${HYSTERIA_OBFS_PASSWORD:-}" ]]; then
        warn "Hysteria 2 ещё не настроен. Запусти: sudo bash naiveproxy.sh hysteria"
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
    if [[ -n "$(aurum_dns_client_ip)" ]]; then
        echo
        echo -e "${CYAN}  Aurum DNS для full TUN/sing-box:${RESET}"
        echo -e "  DNS server: ${GREEN}tcp://$(aurum_dns_client_ip):53${RESET}"
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
    local current_port="${HYSTERIA_PORT:-8443}" choice custom_port next_port ans

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

    if [[ "$next_port" != "$current_port" ]] && ss -ulpn 2>/dev/null | grep -q ":${next_port} "; then
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
        err "Домен не настроен. Сначала установи NaiveProxy."
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

    install_hysteria_bin || return 1
    write_hysteria_config || return 1
    write_hysteria_service || return 1
    ufw allow "${HYSTERIA_PORT}/udp" comment "Hysteria2 QUIC" >/dev/null 2>&1 || true
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
    local old_port="${HYSTERIA_PORT:-8443}"
    hr
    echo -e "${BOLD}  Смена UDP порта Hysteria 2${RESET}"
    hr
    echo -e "  Текущий порт: ${CYAN}UDP/${old_port}${RESET}"
    echo

    choose_hysteria_port || return 1
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
        if systemctl restart hysteria && sleep 2 && systemctl is-active --quiet hysteria; then
            ok "Hysteria 2 перезапущен на UDP/${HYSTERIA_PORT}"
        else
            err "Hysteria 2 не запустился после смены порта. Лог:"
            journalctl -u hysteria -n 30 --no-pager
            return 1
        fi
    fi
}

cmd_hysteria_status() {
    load_config
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
    fi
    systemctl is-active --quiet hysteria 2>/dev/null && ok "Сервис: работает" || warn "Сервис: не работает"
    ss -ulpn 2>/dev/null | grep ":${HYSTERIA_PORT:-8443} " || warn "UDP/${HYSTERIA_PORT:-8443} не слушается"
    ufw status 2>/dev/null | grep -E "${HYSTERIA_PORT:-8443}/udp|Status" || true
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
    rm -f "$HYSTERIA_SERVICE" "$HYSTERIA_BIN" "$HYSTERIA_CONFIG"
    ufw delete allow "${HYSTERIA_PORT:-8443}/udp" >/dev/null 2>&1 || true
    HYSTERIA_PORT=""
    HYSTERIA_PASSWORD=""
    HYSTERIA_OBFS_PASSWORD=""
    save_config
    systemctl daemon-reload
    ok "Hysteria 2 удалён"
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
            0) return ;;
            *) err "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
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

    local arch url tmp zip_dir
    arch=$(detect_xray_arch) || return 1
    url="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${arch}.zip"
    tmp=$(mktemp /tmp/xray_XXXXXX.zip)
    zip_dir=$(mktemp -d /tmp/xray_unzip_XXXXXX)
    trap 'rm -f "${tmp:-}" 2>/dev/null; rm -rf "${zip_dir:-}" 2>/dev/null; trap - RETURN' RETURN

    info "Скачиваю Xray-core (${arch})..."
    if ! curl -fsSL --retry 3 --connect-timeout 15 --max-time 180 "$url" -o "$tmp"; then
        err "Не удалось скачать Xray: $url"
        return 1
    fi

    command -v unzip &>/dev/null || apt-get install -y -q unzip
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

xray_active_user_count() {
    grep -v '^#\|^[[:space:]]*$' "$XRAY_USERS_FILE" 2>/dev/null | wc -l
}

xray_clients_json() {
    local first=1 user uuid
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" ]] && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s", "flow": "xtls-rprx-vision" }' "$uuid" "$user"
    done < "$XRAY_USERS_FILE"
}

xray_clients_json_no_flow() {
    local first=1 user uuid
    while IFS=: read -r user uuid; do
        [[ -z "$user" || -z "$uuid" ]] && continue
        if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
        first=0
        printf '          { "id": "%s", "email": "%s" }' "$uuid" "$user"
    done < "$XRAY_USERS_FILE"
}

ensure_xray_reality_keys() {
    XRAY_REALITY_SHORT_ID="${XRAY_REALITY_SHORT_ID:-$(openssl rand -hex 8)}"
    if [[ -z "${XRAY_REALITY_PRIVATE_KEY:-}" || -z "${XRAY_REALITY_PUBLIC_KEY:-}" ]]; then
        local key_out
        key_out=$("$XRAY_BIN" x25519 2>&1 || true)
        XRAY_REALITY_PRIVATE_KEY=$(printf '%s\n' "$key_out" | awk -F':' '
            {
                label=tolower($1);
                if (label ~ /private/) {
                    value=$0;
                    sub(/^[^:]*:[[:space:]]*/, "", value);
                    gsub(/[[:space:]]+$/, "", value);
                    print value;
                    exit;
                }
            }
        ')
        XRAY_REALITY_PUBLIC_KEY=$(printf '%s\n' "$key_out" | awk -F':' '
            {
                label=tolower($1);
                if (label ~ /public/ || label ~ /password/) {
                    value=$0;
                    sub(/^[^:]*:[[:space:]]*/, "", value);
                    gsub(/[[:space:]]+$/, "", value);
                    print value;
                    exit;
                }
            }
        ')
    fi
    if [[ -z "${XRAY_REALITY_PRIVATE_KEY:-}" || -z "${XRAY_REALITY_PUBLIC_KEY:-}" ]]; then
        err "Не смог сгенерировать REALITY ключи: xray x25519"
        warn "Проверь вручную: ${XRAY_BIN} x25519"
        return 1
    fi
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
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable xray --quiet
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

    local cert key fallback_enabled fallback_port reality_port mkcp_port grpc_port trojan_pass reality_target reality_sni
    fallback_enabled="${XRAY_FALLBACK_ENABLED:-0}"
    fallback_port="${XRAY_CADDY_FALLBACK_PORT:-$XRAY_CADDY_FALLBACK_PORT_DEFAULT}"
    reality_port="${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}"
    mkcp_port="${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}"
    grpc_port="${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}"
    trojan_pass="${XRAY_TROJAN_PASSWORD:-$(random_safe_token 24)}"
    XRAY_TROJAN_PASSWORD="$trojan_pass"
    reality_target="${XRAY_REALITY_TARGET:-www.microsoft.com:443}"
    reality_sni="${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}"

    cert=$(find_caddy_cert "${DOMAIN:-}") || true
    key=$(find_caddy_key "${DOMAIN:-}") || true
    if [[ -z "$cert" || -z "$key" ]]; then
        err "Для Xray TLS/gRPC/fallback нужен TLS сертификат Caddy. Сначала запусти NaiveProxy и дождись сертификата."
        return 1
    fi

    mkdir -p "$XRAY_CONFIG_DIR" /var/log/xray
    cat > "$XRAY_CONFIG" <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
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
          { "path": "/vless-ws", "dest": "127.0.0.1:10001" },
          { "path": "/vless-hu", "dest": "127.0.0.1:10002" },
          { "path": "/vless-xhttp", "dest": "127.0.0.1:10003" },
          { "path": "/trojan-ws", "dest": "127.0.0.1:10004" },
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
    {
      "tag": "vless-ws-local",
      "listen": "127.0.0.1",
      "port": 10001,
      "protocol": "vless",
      "settings": { "clients": [$(xray_clients_json_no_flow)], "decryption": "none" },
      "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "path": "/vless-ws" } }
    },
    {
      "tag": "vless-httpupgrade-local",
      "listen": "127.0.0.1",
      "port": 10002,
      "protocol": "vless",
      "settings": { "clients": [$(xray_clients_json_no_flow)], "decryption": "none" },
      "streamSettings": { "network": "httpupgrade", "security": "none", "httpupgradeSettings": { "path": "/vless-hu" } }
    },
    {
      "tag": "vless-xhttp-local",
      "listen": "127.0.0.1",
      "port": 10003,
      "protocol": "vless",
      "settings": { "clients": [$(xray_clients_json_no_flow)], "decryption": "none" },
      "streamSettings": { "network": "xhttp", "security": "none", "xhttpSettings": { "path": "/vless-xhttp" } }
    },
    {
      "tag": "trojan-ws-local",
      "listen": "127.0.0.1",
      "port": 10004,
      "protocol": "trojan",
      "settings": { "clients": [{ "password": "${trojan_pass}", "email": "trojan-ws" }] },
      "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "path": "/trojan-ws" } }
    },
EOF
    fi

    cat >> "$XRAY_CONFIG" <<EOF
    {
      "tag": "vless-reality",
      "listen": "0.0.0.0",
      "port": ${reality_port},
      "protocol": "vless",
      "settings": {
        "clients": [
$(xray_clients_json)
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "target": "${reality_target}",
          "serverNames": ["${reality_sni}"],
          "privateKey": "${XRAY_REALITY_PRIVATE_KEY}",
          "shortIds": ["${XRAY_REALITY_SHORT_ID}"]
        }
      }
    },
    {
      "tag": "vless-mkcp",
      "listen": "0.0.0.0",
      "port": ${mkcp_port},
      "protocol": "vless",
      "settings": { "clients": [$(xray_clients_json_no_flow)], "decryption": "none" },
      "streamSettings": {
        "network": "mkcp",
        "security": "none",
        "kcpSettings": {
          "mtu": 1350,
          "tti": 50,
          "uplinkCapacity": 5,
          "downlinkCapacity": 20,
          "congestion": false,
          "readBufferSize": 1,
          "writeBufferSize": 1
        }
      }
    },
    {
      "tag": "vless-grpc-tls",
      "listen": "0.0.0.0",
      "port": ${grpc_port},
      "protocol": "vless",
      "settings": { "clients": [$(xray_clients_json_no_flow)], "decryption": "none" },
      "streamSettings": {
        "network": "grpc",
        "security": "tls",
        "tlsSettings": {
          "serverName": "${DOMAIN}",
          "alpn": ["h2"],
          "certificates": [
            { "certificateFile": "${cert:-}", "keyFile": "${key:-}" }
          ]
        },
        "grpcSettings": { "serviceName": "vless-grpc" }
      }
    }
  ],
  "outbounds": [
EOF

    if [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]]; then
        cat >> "$XRAY_CONFIG" <<EOF
    {
      "protocol": "http",
      "tag": "warp-proxy",
      "settings": {
        "servers": [
          { "address": "127.0.0.1", "port": ${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT} }
        ]
      }
    },
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
EOF
    else
        cat >> "$XRAY_CONFIG" <<EOF
    { "protocol": "freedom", "tag": "direct" },
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
        return 1
    fi
    save_config
    ok "Xray config создан: $XRAY_CONFIG"
    if [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]]; then
        ok "Xray outbound направлен через WARP proxy: 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}"
    fi
}

print_xray_client_config() {
    load_config
    [[ -s "$XRAY_USERS_FILE" ]] || load_xray_users "xray"
    local user="${1:-}"
    local uuid
    if [[ -z "$user" ]]; then
        user=$(head -1 "$XRAY_USERS_FILE" | cut -d: -f1)
    fi
    uuid=$(awk -F: -v u="$user" '$1 == u {print $2; exit}' "$XRAY_USERS_FILE")
    [[ -z "$uuid" ]] && { err "Xray пользователь $user не найден"; return 1; }

    hr
    echo -e "${BOLD}${GREEN}  Xray Modern client config${RESET}"
    hr
    echo -e "  User: ${BOLD}${user}${RESET}"
    echo
    echo -e "${CYAN}  VLESS REALITY TCP:${RESET}"
    echo "  vless://${uuid}@${DOMAIN}:${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}?security=reality&type=tcp&flow=xtls-rprx-vision&sni=${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}#${user}-reality"
    echo
    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        echo -e "${CYAN}  VLESS TCP TLS XTLS Vision (443 fallback hub):${RESET}"
        echo "  vless://${uuid}@${DOMAIN}:443?security=tls&type=tcp&flow=xtls-rprx-vision&sni=${DOMAIN}&fp=chrome#${user}-vless-vision"
        echo
        echo -e "${CYAN}  VLESS WebSocket TLS:${RESET}"
        echo "  vless://${uuid}@${DOMAIN}:443?security=tls&type=ws&host=${DOMAIN}&path=%2Fvless-ws&sni=${DOMAIN}&fp=chrome#${user}-vless-ws"
        echo
        echo -e "${CYAN}  VLESS HTTPUpgrade TLS:${RESET}"
        echo "  vless://${uuid}@${DOMAIN}:443?security=tls&type=httpupgrade&host=${DOMAIN}&path=%2Fvless-hu&sni=${DOMAIN}&fp=chrome#${user}-vless-httpupgrade"
        echo
        echo -e "${CYAN}  VLESS XHTTP TLS:${RESET}"
        echo "  vless://${uuid}@${DOMAIN}:443?security=tls&type=xhttp&host=${DOMAIN}&path=%2Fvless-xhttp&sni=${DOMAIN}&fp=chrome#${user}-vless-xhttp"
        echo
        echo -e "${CYAN}  Trojan WebSocket TLS:${RESET}"
        echo "  trojan://${XRAY_TROJAN_PASSWORD:-PASSWORD}@${DOMAIN}:443?security=tls&type=ws&host=${DOMAIN}&path=%2Ftrojan-ws&sni=${DOMAIN}&fp=chrome#trojan-ws"
    fi
    echo
    echo -e "${CYAN}  VLESS mKCP:${RESET}"
    echo "  vless://${uuid}@${DOMAIN}:${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}?security=none&type=mkcp#${user}-mkcp"
    echo
    echo -e "${CYAN}  VLESS gRPC TLS:${RESET}"
    echo "  vless://${uuid}@${DOMAIN}:${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}?security=tls&type=grpc&serviceName=vless-grpc&sni=${DOMAIN}&fp=chrome#${user}-grpc"
    if [[ -n "$(aurum_dns_client_ip)" ]]; then
        echo
        echo -e "${CYAN}  Aurum DNS для full TUN/sing-box:${RESET}"
        echo -e "  DNS server: ${GREEN}tcp://$(aurum_dns_client_ip):53${RESET}"
        echo -e "  detour: ${GREEN}xray-out${RESET} (или тег твоего Xray outbound в клиенте)"
    fi
    hr
}

# ─── ПОДПИСКИ И ПЕРСОНАЛЬНЫЕ WEB-СТРАНИЦЫ ─────────────────────
html_escape_text() {
    printf '%s' "${1:-}" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
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
    if ! is_valid_domain "${DOMAIN:-}"; then
        err "Домен не настроен или некорректен"
        return 1
    fi

    ensure_web_privacy_files

    local token token_file page_dir links_file naive_pass naive_uri naive_json naive_singbox_tun_json hy2_uri hy2_json
    token_file="${SUBS_DIR}/${user}.token"
    token=$(get_or_create_token_file "$token_file")
    page_dir="${SUBS_WEB_DIR}/${token}"
    links_file="${page_dir}/links.txt"
    mkdir -p "$page_dir"
    chmod 755 "$page_dir"

    naive_pass=$(get_user_pass "$user" 2>/dev/null || true)
    naive_uri=""
    naive_json=""
    naive_singbox_tun_json=""
    if [[ -n "$naive_pass" ]]; then
        naive_uri="naive+https://${user}:${naive_pass}@${DOMAIN}:443"
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

    local uuid reality_link vision_link ws_link hu_link xhttp_link trojan_link mkcp_link grpc_link
    uuid=$(get_xray_user_uuid "$user" 2>/dev/null || true)
    reality_link=""
    vision_link=""
    ws_link=""
    hu_link=""
    xhttp_link=""
    trojan_link=""
    mkcp_link=""
    grpc_link=""
    if [[ -n "$uuid" ]]; then
        reality_link="vless://${uuid}@${DOMAIN}:${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}?security=reality&type=tcp&flow=xtls-rprx-vision&sni=${XRAY_REALITY_SERVER_NAME:-www.microsoft.com}&fp=chrome&pbk=${XRAY_REALITY_PUBLIC_KEY:-PUBLIC_KEY}&sid=${XRAY_REALITY_SHORT_ID:-SHORT_ID}#${user}-reality"
        mkcp_link="vless://${uuid}@${DOMAIN}:${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}?security=none&type=mkcp#${user}-mkcp"
        grpc_link="vless://${uuid}@${DOMAIN}:${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}?security=tls&type=grpc&serviceName=vless-grpc&sni=${DOMAIN}&fp=chrome#${user}-grpc"
        if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
            vision_link="vless://${uuid}@${DOMAIN}:443?security=tls&type=tcp&flow=xtls-rprx-vision&sni=${DOMAIN}&fp=chrome#${user}-vless-vision"
            ws_link="vless://${uuid}@${DOMAIN}:443?security=tls&type=ws&host=${DOMAIN}&path=%2Fvless-ws&sni=${DOMAIN}&fp=chrome#${user}-vless-ws"
            hu_link="vless://${uuid}@${DOMAIN}:443?security=tls&type=httpupgrade&host=${DOMAIN}&path=%2Fvless-hu&sni=${DOMAIN}&fp=chrome#${user}-vless-httpupgrade"
            xhttp_link="vless://${uuid}@${DOMAIN}:443?security=tls&type=xhttp&host=${DOMAIN}&path=%2Fvless-xhttp&sni=${DOMAIN}&fp=chrome#${user}-vless-xhttp"
            trojan_link="trojan://${XRAY_TROJAN_PASSWORD:-PASSWORD}@${DOMAIN}:443?security=tls&type=ws&host=${DOMAIN}&path=%2Ftrojan-ws&sni=${DOMAIN}&fp=chrome#trojan-ws"
        fi
    fi

    {
        [[ -n "$naive_uri" ]] && printf '%s\n' "$naive_uri"
        [[ -n "$hy2_uri" ]] && printf '%s\n' "$hy2_uri"
        [[ -n "$reality_link" ]] && printf '%s\n' "$reality_link"
        [[ -n "$vision_link" ]] && printf '%s\n' "$vision_link"
        [[ -n "$ws_link" ]] && printf '%s\n' "$ws_link"
        [[ -n "$hu_link" ]] && printf '%s\n' "$hu_link"
        [[ -n "$xhttp_link" ]] && printf '%s\n' "$xhttp_link"
        [[ -n "$trojan_link" ]] && printf '%s\n' "$trojan_link"
        [[ -n "$mkcp_link" ]] && printf '%s\n' "$mkcp_link"
        [[ -n "$grpc_link" ]] && printf '%s\n' "$grpc_link"
    } > "$links_file"
    chmod 644 "$links_file"

    local sub_url links_url title safe_user safe_domain safe_naive_uri safe_naive_json safe_naive_singbox_tun_json safe_hy2_uri safe_hy2_json
    sub_url="https://${DOMAIN}/s/${token}/"
    links_url="${sub_url}links.txt"
    title="Subscription for ${user}"
    safe_user=$(html_escape_text "$user")
    safe_domain=$(html_escape_text "$DOMAIN")
    safe_naive_uri=$(html_escape_text "$naive_uri")
    safe_naive_json=$(html_escape_text "$naive_json")
    safe_naive_singbox_tun_json=$(html_escape_text "$naive_singbox_tun_json")
    safe_hy2_uri=$(html_escape_text "$hy2_uri")
    safe_hy2_json=$(html_escape_text "$hy2_json")

    local safe_reality safe_vision safe_ws safe_hu safe_xhttp safe_trojan safe_mkcp safe_grpc safe_links_url
    safe_reality=$(html_escape_text "$reality_link")
    safe_vision=$(html_escape_text "$vision_link")
    safe_ws=$(html_escape_text "$ws_link")
    safe_hu=$(html_escape_text "$hu_link")
    safe_xhttp=$(html_escape_text "$xhttp_link")
    safe_trojan=$(html_escape_text "$trojan_link")
    safe_mkcp=$(html_escape_text "$mkcp_link")
    safe_grpc=$(html_escape_text "$grpc_link")
    safe_links_url=$(html_escape_text "$links_url")

    cat > "${page_dir}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>${title}</title>
<style>
:root{--bg:#0b0f14;--panel:#121922;--panel2:#17202b;--line:#263241;--text:#e8eef5;--muted:#9aa8b7;--accent:#4fd1c5;--blue:#60a5fa;--ok:#7ddc83;--warn:#f6c86f}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font-family:Inter,Arial,sans-serif;line-height:1.55}.wrap{max-width:1040px;margin:0 auto;padding:28px 18px 48px}.top{display:flex;justify-content:space-between;gap:18px;align-items:flex-start;border-bottom:1px solid var(--line);padding-bottom:18px}.brand{font-size:13px;color:var(--accent);letter-spacing:.08em;text-transform:uppercase}.h1{font-size:30px;font-weight:800;margin:6px 0}.muted{color:var(--muted)}.pill{border:1px solid var(--line);border-radius:8px;padding:8px 12px;color:var(--muted);white-space:nowrap}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px;margin-top:20px}.card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:16px}.card h2{font-size:16px;margin:0 0 10px}.card h3{font-size:14px;margin:16px 0 8px;color:var(--accent)}pre{white-space:pre-wrap;word-break:break-all;background:#080b10;border:1px solid var(--line);border-radius:7px;padding:12px;color:#d8dee9;overflow:auto}.btn{display:inline-flex;align-items:center;gap:8px;background:var(--panel2);border:1px solid var(--line);color:var(--text);border-radius:7px;padding:9px 12px;text-decoration:none;font-weight:700;margin:4px 6px 4px 0}.btn:hover{border-color:var(--accent)}.copy{cursor:pointer}.ok{color:var(--ok)}.warn{color:var(--warn)}.os{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-top:14px}.os div{background:var(--panel2);border:1px solid var(--line);border-radius:8px;padding:12px}.foot{margin-top:22px;border-top:1px solid var(--line);padding-top:14px;color:var(--muted);font-size:13px}@media(max-width:760px){.top{display:block}.grid,.os{grid-template-columns:1fr}.pill{display:inline-block;margin-top:10px}.h1{font-size:24px}}
</style>
</head>
<body>
<main class="wrap">
  <section class="top">
    <div>
      <div class="brand">NaiveProxy Manager</div>
      <div class="h1">Подписка пользователя ${safe_user}</div>
      <div class="muted">Домен: <b>${safe_domain}</b>. Страница скрыта от индексации, но доступна всем, у кого есть этот секретный URL.</div>
    </div>
    <div class="pill">Обновлено: $(date '+%Y-%m-%d %H:%M')</div>
  </section>

  <section class="card">
    <h2>Быстрый импорт</h2>
    <a class="btn" href="${safe_links_url}">links.txt</a>
    <button class="btn copy" data-copy="${safe_links_url}">Скопировать URL подписки</button>
    <p class="muted">Импортируй ссылку подписки в Hiddify, NekoBox, v2rayN, Streisand или другой клиент с поддержкой URI.</p>
  </section>

  <section class="grid">
    <div class="card">
      <h2>NaiveProxy</h2>
      <p class="muted">Подходит для официального naive-client и клиентов с поддержкой naive URI.</p>
      <pre>${safe_naive_uri:-Naive пользователь не найден}</pre>
      <h3>naive-client JSON</h3>
      <pre>${safe_naive_json:-Naive конфиг недоступен}</pre>
      <h3>sing-box Android VPN/TUN + Aurum DNS</h3>
      <pre>${safe_naive_singbox_tun_json:-sing-box TUN конфиг недоступен}</pre>
      <h2>Hysteria 2</h2>
      <p class="muted">Персональный UDP/QUIC профиль для этого же пользователя, если Hysteria 2 установлен.</p>
      <pre>${safe_hy2_uri:-Hysteria 2 не установлен или пользователь недоступен}</pre>
      <h3>sing-box outbound</h3>
      <pre>${safe_hy2_json:-Hysteria 2 outbound недоступен}</pre>
    </div>
    <div class="card">
      <h2>Xray Modern</h2>
      <p class="muted">VLESS/Trojan ссылки, если Xray установлен и пользователь создан.</p>
      <pre>${safe_reality:-Xray пользователь не найден}</pre>
      <pre>${safe_vision:-Fallback 443 выключен или недоступен}</pre>
      <pre>${safe_ws:-WebSocket недоступен без fallback hub}</pre>
      <pre>${safe_hu:-HTTPUpgrade недоступен без fallback hub}</pre>
      <pre>${safe_xhttp:-XHTTP недоступен без fallback hub}</pre>
      <pre>${safe_trojan:-Trojan WS недоступен без fallback hub}</pre>
      <pre>${safe_mkcp:-mKCP недоступен}</pre>
      <pre>${safe_grpc:-gRPC недоступен}</pre>
    </div>
  </section>

  <section class="card">
    <h2>Настройки под системы</h2>
    <div class="os">
      <div><b>Windows</b><br><span class="muted">v2rayN, NekoRay или Hiddify. Импортируй links.txt или вставь нужную URI.</span></div>
      <div><b>Android</b><br><span class="muted">Hiddify, NekoBox, v2rayNG. Для Naive лучше Hiddify/NekoBox с поддержкой naive.</span></div>
      <div><b>iOS/macOS</b><br><span class="muted">Streisand, FoXray, Shadowrocket. Импортируй подписку или отдельную ссылку.</span></div>
      <div><b>Linux</b><br><span class="muted">naive-client JSON для SOCKS 127.0.0.1:1080 или sing-box/v2rayN GUI.</span></div>
    </div>
  </section>

  <div class="foot">Если этот URL утёк, перевыпусти токен: <code>sudo bash naiveproxy.sh subscription-reset ${safe_user}</code>.</div>
</main>
<script>
document.querySelectorAll('.copy').forEach(function(btn){
  btn.addEventListener('click', function(){
    navigator.clipboard.writeText(btn.getAttribute('data-copy') || '');
    btn.textContent='Скопировано';
    setTimeout(function(){btn.textContent='Скопировать URL подписки'}, 1600);
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
<title>Ivan IT Lab</title>
<style>
:root{--bg:#0a0e13;--panel:#111923;--line:#263241;--text:#edf2f7;--muted:#9ca9b7;--accent:#d4a017;--blue:#58a6ff;--green:#4ade80}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font-family:Inter,Arial,sans-serif}.wrap{max-width:980px;margin:0 auto;padding:34px 18px}.top{border-bottom:1px solid var(--line);padding-bottom:22px}.eyebrow{color:var(--accent);font-size:12px;text-transform:uppercase;letter-spacing:.12em}.h1{font-size:36px;font-weight:850;margin:8px 0}.muted{color:var(--muted);line-height:1.65}.grid{display:grid;grid-template-columns:2fr 1fr;gap:14px;margin-top:20px}.card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:18px}.row{display:flex;justify-content:space-between;border-bottom:1px solid var(--line);padding:10px 0}.row:last-child{border-bottom:0}.ok{color:var(--green)}code{color:var(--blue)}@media(max-width:760px){.grid{grid-template-columns:1fr}.h1{font-size:28px}}
</style>
</head>
<body>
<main class="wrap">
  <section class="top">
    <div class="eyebrow">Private technical notebook</div>
    <div class="h1">Ivan IT Lab</div>
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

cmd_xray_install() {
    load_config
    check_installed || { err "Сначала установи NaiveProxy и получи TLS сертификат"; return 1; }
    hr
    echo -e "${BOLD}  Xray Modern transports${RESET}"
    hr
    warn "443 fallback hub переключит внешний порт 443 с Caddy на Xray."
    warn "NaiveProxy останется доступен на ${DOMAIN}:443 через fallback в Caddy local."
    echo -ne "${YELLOW}Включить Xray fallback hub на 443? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" == "y" ]] && XRAY_FALLBACK_ENABLED="1" || XRAY_FALLBACK_ENABLED="0"

    echo -ne "${CYAN}Xray пользователь [xray]: ${RESET}"
    read -r xuser
    xuser="${xuser:-xray}"
    if ! is_valid_proxy_user "$xuser"; then
        err "Логин: 2-32 символа, только A-Z a-z 0-9 _ -"
        return 1
    fi

    echo -ne "${CYAN}REALITY target [${XRAY_REALITY_TARGET:-www.microsoft.com:443}]: ${RESET}"
    read -r ans
    XRAY_REALITY_TARGET="${ans:-${XRAY_REALITY_TARGET:-www.microsoft.com:443}}"
    XRAY_REALITY_SERVER_NAME="${XRAY_REALITY_TARGET%%:*}"

    install_xray_bin || return 1
    write_xray_config "$xuser" || return 1
    write_xray_service

    if [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]]; then
        rewrite_caddyfile_current || return 1
        systemctl restart caddy
    fi

    ufw allow "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" comment "Xray REALITY" >/dev/null 2>&1 || true
    ufw allow "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}/udp" comment "Xray mKCP" >/dev/null 2>&1 || true
    ufw allow "${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}/tcp" comment "Xray gRPC" >/dev/null 2>&1 || true
    systemctl restart xray
    XRAY_ENABLED="1"
    save_config
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
    ufw allow "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" comment "Xray REALITY" >/dev/null 2>&1 || true
    ufw allow "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}/udp" comment "Xray mKCP" >/dev/null 2>&1 || true
    ufw allow "${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}/tcp" comment "Xray gRPC" >/dev/null 2>&1 || true
    systemctl restart xray || return 1
    XRAY_ENABLED="1"
    save_config
}

cmd_xray_add_user() {
    load_config
    local xuser="${1:-}"
    if [[ -z "$xuser" ]]; then
        echo -ne "${CYAN}Новый Xray пользователь: ${RESET}"
        read -r xuser
    fi
    if ! provision_xray_user "$xuser"; then
        return 1
    fi

    local sub_url
    sub_url=$(generate_subscription_page "$xuser" 2>/dev/null || true)
    if [[ -n "$sub_url" ]]; then
        ok "Личная страница подписки создана:"
        echo "  ${sub_url}"
        echo "  links.txt: ${sub_url}links.txt"
    else
        warn "Страница подписки не создана автоматически. Проверь: sudo bash naiveproxy.sh subscription ${xuser}"
    fi

    print_xray_client_config "$xuser"
}

cmd_xray_status() {
    load_config
    hr
    echo -e "${BOLD}  Xray статус${RESET}"
    hr
    [[ -x "$XRAY_BIN" ]] && "$XRAY_BIN" version | head -1 || warn "Xray не установлен"
    systemctl status xray --no-pager -l 2>/dev/null || true
    ss -tulpn | grep -E ":(443|${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}|${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}|${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT})\b" || true
    [[ -f "$XRAY_CONFIG" ]] && "$XRAY_BIN" run -test -config "$XRAY_CONFIG" || true
    hr
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
    ufw delete allow "${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}/tcp" >/dev/null 2>&1 || true
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
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -e "  Fallback 443: ${CYAN}${XRAY_FALLBACK_ENABLED:-0}${RESET} | REALITY: ${CYAN}${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}${RESET}"
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
    warn "Если SSH отвалится, используй консоль провайдера: sudo bash naiveproxy.sh warp-disable"
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
        warn "Если нужен выход через WARP для Xray, включи WARP и пересобери Xray config; NaiveProxy/Caddy не умеет chain-upstream через этот local proxy."
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

    if ss -tlnp 2>/dev/null | grep -q "127.0.0.1:${WARP_PROXY_PORT} "; then
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

    if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        info "Обновляю Xray config, чтобы Xray выходил через WARP proxy..."
        if write_xray_config && systemctl restart xray; then
            ok "Xray перезапущен с WARP outbound"
        else
            warn "WARP работает, но Xray не удалось пересобрать автоматически. Запусти: sudo bash naiveproxy.sh xray-install"
        fi
    fi

    cmd_warp_status
}

cmd_warp_full_install() {
    load_config
    hr
    echo -e "${BOLD}  Cloudflare WARP full tunnel${RESET}"
    hr
    warn "Full tunnel меняет исходящий маршрут всего VPS через WARP."
    warn "Входящие порты Caddy/SSH обычно остаются входящими, но на VPS проверяй через консоль провайдера."
    warn "Если что-то пошло не так: sudo bash naiveproxy.sh warp-disable"
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
        return 1
    fi
    save_config

    if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        info "Пересобираю Xray config: full-tunnel использует системный маршрут WARP, без local proxy outbound..."
        if write_xray_config && systemctl restart xray; then
            ok "Xray перезапущен под full-tunnel WARP"
        else
            warn "WARP full tunnel работает, но Xray не удалось пересобрать автоматически"
        fi
    fi
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
    echo -e "          В proxy mode NaiveProxy/Caddy не меняет upstream через WARP автоматически."
    echo -e "          Xray после пересборки использует WARP outbound, если WARP включён."
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
    if [[ "${XRAY_ENABLED:-0}" == "1" && -x "$XRAY_BIN" && -f "$XRAY_CONFIG" ]]; then
        write_xray_config >/dev/null 2>&1 && systemctl restart xray 2>/dev/null || true
    fi
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
            0) return ;;
            *) warn "Неверный выбор" ;;
        esac
        echo -ne "${DIM}Enter для продолжения...${RESET}"; read -r _
    done
}

# ─── Ввод параметров ─────────────────────────────────────────
prompt_params() {
    echo
    echo -e "${BOLD}Настройка NaiveProxy:${RESET}"
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

    load_users
    echo "${first_user}:${first_pass}" > "$USERS_FILE"
    chmod 600 "$USERS_FILE"
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
                    err "❌ Нельзя удалить последний домен!"
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
                    echo -e "  ${count}. ${BOLD}${u}${RESET} : $p"
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
                printf '%s:%s\n' "${new_user}" "${new_pass}" >> "$USERS_FILE"
                backup_config
                rewrite_caddyfile_current
                systemctl reload caddy 2>/dev/null || systemctl restart caddy
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
                    warn "Страница подписки не создана автоматически. Проверь: sudo bash naiveproxy.sh subscription ${new_user}"
                fi
                print_client_config "$new_user"
                if [[ "$hy_added" -eq 1 ]]; then
                    print_hysteria_client_config "$new_user"
                fi
                if [[ "$xray_added" -eq 1 ]]; then
                    print_xray_client_config "$new_user"
                fi
                tg_send "👤 <b>Новый пользователь NaiveProxy</b>
🔑 Логин: <code>${new_user}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
                ;;
            3)
                echo -ne "${CYAN}Логин для удаления: ${RESET}"; read -r del_user
                if ! is_valid_proxy_user "$del_user" || ! get_user_pass "$del_user" >/dev/null; then
                    err "Пользователь $del_user не найден"
                    continue
                fi
                if [[ "$(active_user_count)" -le 1 ]]; then
                    err "Нельзя удалить последнего активного пользователя — иначе прокси может остаться без auth."
                    continue
                fi
                backup_config
                cleanup_subscription_page "$del_user"
                awk -F: -v user="${del_user}" '$1 != user' "$USERS_FILE" > "${USERS_FILE}.tmp" && mv "${USERS_FILE}.tmp" "$USERS_FILE" || true
                rewrite_caddyfile_current
                systemctl reload caddy 2>/dev/null || systemctl restart caddy
                sync_hysteria_users_if_active >/dev/null 2>&1 || true
                ok "Пользователь $del_user удалён"
                ok "Страница подписки $del_user удалена"
                tg_send "🗑 <b>Пользователь удалён: ${del_user}</b>
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
        warn "Логи NaiveProxy не найдены: ${LOG_DIR}/naive.log"
        return 1
    fi

    hr
    echo -e "${BOLD}  Лимит устройств NaiveProxy${RESET}"
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
            tg_send "⚠️ <b>NaiveProxy: превышен лимит устройств</b>
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
        echo -e "  ⬆ Исходящий: $(numfmt --to=iec "$tx" 2>/dev/null || echo $tx)"
    fi

    echo
    echo -e "  ${BOLD}Ресурсы:${RESET}"
    echo -e "  RAM:    $(free -h | awk '/Mem:/{print $3" / "$2}')"
    echo -e "  Диск:   $(df -h / | awk 'NR==2{print $3" / "$2" ("$5")"}')"
    echo -e "  Uptime: $(uptime -p)"

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
    echo -e "${BOLD}  Установка NaiveProxy v${VERSION}${RESET}"
    hr

    if check_installed; then
        warn "NaiveProxy уже установлен."
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
    check_domain "$DOMAIN"
    install_deps
    build_caddy
    write_caddyfile
    write_service
    setup_firewall
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

    print_client_config
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
    echo -e "${BOLD}  Обновление скрипта NaiveProxy Manager${RESET}"
    hr

    info "Текущая версия: ${BOLD}v${VERSION}${RESET}"
    info "Проверяю последнюю версию на GitHub..."

    # Получаем последнюю версию через GitHub API
    local latest_ver
    latest_ver=$(curl -s --max-time 10 "$GITHUB_API" 2>/dev/null         | grep '"tag_name"'         | grep -oP '"\K[^"]+'         | head -1         | tr -d 'v' || echo "")

    if [[ -z "$latest_ver" ]]; then
        # Fallback: читаем VERSION из raw скрипта
        latest_ver=$(curl -s --max-time 10 "$GITHUB_RAW" 2>/dev/null             | grep '^VERSION='             | grep -oP '"\K[^"]+' || echo "")
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
    local tmp_script
    tmp_script=$(mktemp /tmp/naiveproxy_update_XXXXXX.sh)
    # Cleanup при любом выходе из функции
    trap 'rm -f "${tmp_script:-}" 2>/dev/null' RETURN

    info "Скачиваю v${latest_ver}..."
    if ! curl -fsSL --max-time 60 "$GITHUB_RAW" -o "$tmp_script" 2>/dev/null; then
        err "Ошибка загрузки скрипта"
        rm -f "$tmp_script"
        return 1
    fi

    # Проверяем что скачали валидный bash скрипт
    if ! bash -n "$tmp_script" 2>/dev/null; then
        err "Скачанный скрипт содержит ошибки синтаксиса! Отменяю обновление."
        rm -f "$tmp_script"
        return 1
    fi

    # Проверяем что это действительно наш скрипт
    if ! grep -q "NaiveProxy Manager" "$tmp_script" 2>/dev/null; then
        err "Скачанный файл не является NaiveProxy Manager. Отменяю."
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

    # Обновляем в /usr/local/bin если там другое место
    if [[ "$current_script" != "$SCRIPT_PATH" ]]; then
        cp "$current_script" "$SCRIPT_PATH" 2>/dev/null || true
        chmod +x "$SCRIPT_PATH" 2>/dev/null || true
    fi

    ok "Скрипт обновлён: v${VERSION} → v${latest_ver}"
    tg_send "🔄 <b>NaiveProxy Manager обновлён</b>
📦 Было: <code>v${VERSION}</code>
📦 Стало: <code>v${latest_ver}</code>
🕐 $(date '+%Y-%m-%d %H:%M:%S')"

    echo
    info "Перезапускаю обновлённый скрипт..."
    sleep 1
    exec bash "$current_script"
}

# ── Тихая проверка обновлений при запуске ─────────────────────
check_update_available() {
    # Запускаем в фоне чтобы не тормозить старт
    (
        local latest_ver
        latest_ver=$(curl -s --max-time 5 "$GITHUB_RAW" 2>/dev/null             | grep '^VERSION='             | grep -oP '"\K[^"]+' || echo "")
        if [[ -n "$latest_ver" && "$latest_ver" != "$VERSION" ]]; then
            echo -e "\n  ${YELLOW}⬆  Доступно обновление скрипта: v${VERSION} → v${latest_ver}${RESET}"
            echo -e "  ${YELLOW}   Меню → 14) Обновить скрипт${RESET}\n"
        fi
    ) &
}


# ─── ДИАГНОСТИКА СИСТЕМЫ ──────────────────────────────────────
cmd_diagnose_fix() {
    load_config 2>/dev/null || true
    load_users 2>/dev/null || true
    hr
    echo -e "${BOLD}  🛠 Автофикс NaiveProxy Manager${RESET}"
    hr

    local changed=0

    mkdir -p "$CONFIG_DIR" "$CADDY_DIR" "$LOG_DIR" "$WEBROOT" 2>/dev/null || true
    ensure_web_privacy_files 2>/dev/null || true
    [[ -f "$CONFIG_FILE" ]] && chown root:root "$CONFIG_FILE" 2>/dev/null || true
    [[ -f "$CONFIG_FILE" ]] && chmod 600 "$CONFIG_FILE" 2>/dev/null || true
    [[ -f "$USERS_FILE" ]] && chown root:root "$USERS_FILE" 2>/dev/null || true
    [[ -f "$USERS_FILE" ]] && chmod 600 "$USERS_FILE" 2>/dev/null || true
    [[ -f "$XRAY_USERS_FILE" ]] && chmod 600 "$XRAY_USERS_FILE" 2>/dev/null || true

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
        warn "Caddy binary или Caddyfile отсутствует. Если модуль forward_proxy пропал — запусти: sudo bash naiveproxy.sh update"
    fi

    if command -v ufw >/dev/null 2>&1; then
        setup_firewall || true
        [[ -n "${HYSTERIA_PORT:-}" ]] && ufw allow "${HYSTERIA_PORT}/udp" comment "Hysteria2 QUIC" >/dev/null 2>&1 || true
        if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
            ufw allow "${XRAY_REALITY_PORT:-$XRAY_REALITY_PORT_DEFAULT}/tcp" comment "Xray REALITY" >/dev/null 2>&1 || true
            ufw allow "${XRAY_MKCP_PORT:-$XRAY_MKCP_PORT_DEFAULT}/udp" comment "Xray mKCP" >/dev/null 2>&1 || true
            ufw allow "${XRAY_GRPC_PORT:-$XRAY_GRPC_PORT_DEFAULT}/tcp" comment "Xray gRPC" >/dev/null 2>&1 || true
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
            warn "Xray config невалиден. Попробуй: sudo bash naiveproxy.sh xray-install"
        fi
    fi

    if [[ "${WARP_PROXY_ENABLED:-0}" == "1" ]] && command -v warp-cli >/dev/null 2>&1; then
        systemctl enable --now warp-svc >/dev/null 2>&1 || systemctl enable --now cloudflare-warp >/dev/null 2>&1 || true
        warp_cli connect >/dev/null 2>&1 || true
    fi

    systemctl daemon-reload >/dev/null 2>&1 || true
    ok "Автофикс завершён"
    [[ "$changed" -eq 1 ]] && info "После автофикса можно проверить: sudo bash naiveproxy.sh diagnose"
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
    _ok()   { echo -e "  ${GREEN}✅ $1${RESET}";   report+="✅ $1\n"; pass=$((pass+1)); }
    _warn() { echo -e "  ${YELLOW}⚠️  $1${RESET}"; report+="⚠️  $1\n"; warn=$((warn+1)); }
    _fail() { echo -e "  ${RED}❌ $1${RESET}";    report+="❌ $1\n"; fail=$((fail+1)); }
    _info() { echo -e "  ${CYAN}ℹ️  $1${RESET}"; }
    _sep()  { echo -e "  ${DIM}──────────────────────────────────────${RESET}"; }

    hr
    echo -e "${BOLD}  🔍 Диагностика NaiveProxy Manager v${VERSION}${RESET}"
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
            _fail "Naive padding НЕ найден в Caddy — пересобери: sudo bash naiveproxy.sh update"
        fi
    else
        _warn "strings недоступен — установи: apt install binutils"
    fi

    # forward_proxy модуль
    if "${CADDY_BIN}" list-modules 2>/dev/null | grep -q "forward_proxy"; then
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

        # Правильный порядок :443, domain
        if grep -q "^:443," "${CADDYFILE}"; then
            _ok "Caddyfile: правильный формат ':443, domain'"
        elif grep -qE "^\S+:443" "${CADDYFILE}"; then
            _fail "Caddyfile: НЕПРАВИЛЬНЫЙ формат 'domain:443' — исправь на ':443, domain'"
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
            _fail "Нет пользователей! Добавь: sudo bash naiveproxy.sh users"
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
        if ss -tlnp | grep -q ":80 "; then
            _ok "Порт 80 слушается (ACME)"
        else
            _warn "Порт 80 не слушается — Let's Encrypt может не работать"
        fi

        # Порт 443
        if ss -tlnp | grep -q ":443 "; then
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

    # Aurum DNS / Unbound
    if command -v unbound &>/dev/null; then
        if systemctl is-active --quiet unbound 2>/dev/null; then
            _ok "Aurum DNS: $(unbound_mode_label), gateway=${UNBOUND_GATEWAY_IP:-127.0.0.1}, vpn=${UNBOUND_VPN_ENABLED:-0}"
        else
            _warn "Aurum DNS установлен, но сервис не активен"
        fi
        if [[ -f "${DNS_CONF:-/etc/unbound/unbound.conf.d/aurum-vpn.conf}" ]] && unbound-checkconf "${DNS_CONF:-/etc/unbound/unbound.conf.d/aurum-vpn.conf}" >/dev/null 2>&1; then
            _ok "Unbound config валиден"
        else
            _warn "Unbound config не найден или содержит ошибку"
        fi
        if command -v dig >/dev/null 2>&1 && dig "@127.0.0.1" google.com +short +time=2 +tries=1 2>/dev/null | grep -Eq '^[0-9a-fA-F:.]+$'; then
            _ok "Aurum DNS отвечает на 127.0.0.1:53"
        else
            _warn "Aurum DNS test не прошёл"
        fi
    else
        _info "Aurum DNS не установлен (меню → 17)"
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
            if ss -tlnp 2>/dev/null | grep -q ":443 "; then
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
    echo -e "  ${BOLD}📊 ИТОГ ДИАГНОСТИКИ${RESET}"
    hr
    echo -e "  ${GREEN}✅ Пройдено:  ${pass}${RESET}"
    echo -e "  ${YELLOW}⚠️  Внимание: ${warn}${RESET}"
    echo -e "  ${RED}❌ Проблемы: ${fail}${RESET}"
    echo

    if [[ ${fail} -eq 0 && ${warn} -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}🎉 Всё работает отлично!${RESET}"
    elif [[ ${fail} -eq 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}⚠️  Есть предупреждения — рекомендуется проверить${RESET}"
    else
        echo -e "  ${RED}${BOLD}❌ Найдены проблемы — требуется вмешательство${RESET}"
    fi

    hr

    # Отправляем отчёт в Telegram если настроен
    echo -ne "\n${YELLOW}Отправить отчёт в Telegram? [y/N]: ${RESET}"
    read -r ans
    if [[ "${ans,,}" == "y" ]]; then
        tg_send "🔍 <b>Диагностика NaiveProxy</b>
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
    [[ "${from_id}" == "${TG_CHAT_ID}" ]] && return 0
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

# Отправка сообщения конкретному chat_id
tg_reply() {
    local chat_id="$1"
    local message="$2"
    [[ -z "${TG_TOKEN:-}" ]] && return
    curl -s --max-time 10         -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"         --data-urlencode "chat_id=${chat_id}"         --data-urlencode "parse_mode=HTML"         --data-urlencode "text=${message}"         >/dev/null 2>&1 || true
}

tg_bot_commands_json() {
    cat <<'EOF'
[
  {"command":"start","description":"Открыть меню"},
  {"command":"help","description":"Помощь и список команд"},
  {"command":"menu","description":"Показать кнопки управления"},
  {"command":"status","description":"Статус сервера"},
  {"command":"stats","description":"Статистика ресурсов и трафика"},
  {"command":"diagnose","description":"Диагностика системы"},
  {"command":"logs","description":"Последние логи Caddy"},
  {"command":"users","description":"Список пользователей"},
  {"command":"adduser","description":"Добавить пользователя"},
  {"command":"deluser","description":"Удалить пользователя"},
  {"command":"qr","description":"QR и ссылка пользователя"},
  {"command":"sub","description":"Страница подписки"},
  {"command":"subreset","description":"Перевыпустить подписку"},
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

    local commands menu_button resp_cmd resp_menu
    commands=$(tg_bot_commands_json | tr -d '\n')
    menu_button='{"type":"commands"}'

    resp_cmd=$(curl -s --max-time 15 \
        -X POST "https://api.telegram.org/bot${TG_TOKEN}/setMyCommands" \
        --data-urlencode "commands=${commands}" \
        2>/dev/null || echo "{}")

    if ! echo "$resp_cmd" | grep -q '"ok":true'; then
        err "Не удалось установить Telegram commands menu"
        echo "$resp_cmd"
        return 1
    fi

    resp_menu=$(curl -s --max-time 15 \
        -X POST "https://api.telegram.org/bot${TG_TOKEN}/setChatMenuButton" \
        --data-urlencode "menu_button=${menu_button}" \
        2>/dev/null || echo "{}")

    if echo "$resp_menu" | grep -q '"ok":true'; then
        ok "Telegram Menu button включён"
    else
        warn "Команды установлены, но Menu button не подтвердился"
        echo "$resp_menu"
    fi
}

tg_apply_bot_menu_silent() {
    tg_apply_bot_menu >/dev/null 2>&1 || true
}

tg_main_menu_markup() {
    cat <<'EOF'
{"keyboard":[[{"text":"📊 Статус"},{"text":"👥 Пользователи"}],[{"text":"➕ Добавить пользователя"},{"text":"🗑 Удалить пользователя"}],[{"text":"📱 QR / ссылка"},{"text":"🔗 Подписка"}],[{"text":"🧬 Xray"},{"text":"⚡ Hysteria"},{"text":"🌀 WARP"}],[{"text":"🔍 Диагностика"},{"text":"📄 Логи"}],[{"text":"♻️ Restart Caddy"},{"text":"🛠 Автофикс"}],[{"text":"💛 Донат"},{"text":"❓ Помощь"}]],"resize_keyboard":true,"one_time_keyboard":false,"is_persistent":true}
EOF
}

tg_reply_menu() {
    local chat_id="$1"
    local message="$2"
    local reply_markup
    [[ -z "${TG_TOKEN:-}" ]] && return
    reply_markup=$(tg_main_menu_markup)
    curl -s --max-time 10 \
        -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "text=${message}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        >/dev/null 2>&1 || true
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
    curl -s --max-time 30 \
        -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendPhoto" \
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
            tg_send_photo "${chat_id}" "${qr_file}" "📱 QR для ${user}@${DOMAIN}"
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

    # Проверка прав
    if ! tg_is_admin "${from_id}"; then
        tg_reply "${chat_id}" "⛔ <b>Доступ запрещён</b>
Ваш ID: <code>${from_id}</code>
Обратитесь к администратору."
        return
    fi

    load_config 2>/dev/null || true

    # Очищаем text от \r \n и невидимых символов
    text="${text//$'\r'/}"
    text="${text//$'\n'/}"

    # Русские кнопки Telegram reply keyboard -> существующие команды
    case "${text}" in
        "📊 Статус") text="/status" ;;
        "👥 Пользователи") text="/users" ;;
        "➕ Добавить пользователя") text="/adduser" ;;
        "🗑 Удалить пользователя") text="/deluser" ;;
        "📱 QR / ссылка") text="/qr" ;;
        "🔗 Подписка") text="/sub" ;;
        "🧬 Xray") text="/xray" ;;
        "⚡ Hysteria") text="/hysteria" ;;
        "🌀 WARP") text="/warp" ;;
        "🔍 Диагностика") text="/diagnose" ;;
        "📄 Логи") text="/logs" ;;
        "♻️ Restart Caddy") text="/restart" ;;
        "🛠 Автофикс") text="/diagfix" ;;
        "💛 Донат") text="/donate" ;;
        "❓ Помощь") text="/menu" ;;
    esac

    # Лимит длины команды — защита от flood/injection
    if [[ ${#text} -gt 256 ]]; then
        tg_reply "${chat_id}" "❌ Команда слишком длинная"
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

    case "${cmd}" in

        /start|/help|/menu)
            tg_reply_menu "${chat_id}" "🛡 <b>NaiveProxy Manager v${VERSION}</b>
🖥 Сервер: <code>$(hostname)</code>

Русское меню включено. Кнопки ниже запускают основные действия, а команды руками тоже работают.

<b>Доступные команды:</b>

📊 <b>Информация</b>
/status — статус сервера и сертификата
/stats — статистика трафика и ресурсов
/diagnose — полная диагностика системы
/logs — последние 20 строк логов
/users — список пользователей
/cert — статус TLS сертификата

👥 <b>Пользователи</b>
/adduser логин [пароль] — добавить пользователя + QR + подписка
/deluser логин — удалить пользователя + страницу
/qr логин — QR код для подключения
/sub логин — страница подписки пользователя
/subreset логин — перевыпустить ссылку подписки
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

            tg_reply "${chat_id}" "📡 <b>Статус NaiveProxy</b>
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
            if grep -q "^:443," "${CADDYFILE:-/etc/caddy/Caddyfile}" 2>/dev/null; then
                diag_result+="✅ Caddyfile формат OK
"
                pass=$((pass+1))
            else
                diag_result+="❌ Caddyfile неправильный формат
"
                fail=$((fail+1))
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

            tg_reply "${chat_id}" "🔍 <b>Диагностика NaiveProxy</b>

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
            local new_user new_pass
            new_user=$(echo "${args}" | awk '{print $1}')
            new_pass=$(echo "${args}" | awk '{print $2}')

            if [[ -z "${new_user}" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /adduser логин [пароль]
Пароль можно не указывать — бот сгенерирует безопасный.
Пример: /adduser alice MyPass123"
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

            printf '%s:%s\n' "${new_user}" "${new_pass}" >> "${USERS_FILE}"

            if rewrite_caddyfile_current 2>/dev/null; then
                systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null
                local uri="naive+https://${new_user}:${new_pass}@${DOMAIN}:443"
                local sub_url sub_links xray_note xray_tmp xray_ok hy_note hy_uri hy_ok
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
${hy_note}
${xray_note}
🌐 URI:
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
                tg_reply "${chat_id}" "⚠️ Пользователь добавлен но Caddyfile не обновлён"
            fi
            ;;

        /deluser)
            local del_user="${args%% *}"
            if [[ -z "${del_user}" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /deluser логин"
                return
            fi

            if ! is_valid_proxy_user "${del_user}" || ! get_user_pass "${del_user}" >/dev/null; then
                tg_reply "${chat_id}" "❌ Пользователь <code>${del_user}</code> не найден"
                return
            fi

            if [[ "$(active_user_count)" -le 1 ]]; then
                tg_reply "${chat_id}" "❌ Нельзя удалить последнего активного пользователя"
                return
            fi
            cleanup_subscription_page "${del_user}"
            awk -F: -v user="${del_user}" '$1 != user' "${USERS_FILE}" > "${USERS_FILE}.tmp"                 && mv "${USERS_FILE}.tmp" "${USERS_FILE}"
            rewrite_caddyfile_current
            systemctl reload caddy 2>/dev/null || systemctl restart caddy
            sync_hysteria_users_if_active >/dev/null 2>&1 || true

            tg_reply "${chat_id}" "🗑 Пользователь <code>${del_user}</code> удалён
📄 Страница подписки тоже удалена"
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

            local uri="naive+https://${qr_user}:${qr_pass}@${DOMAIN}:443"

            # Авто-установка qrencode если нет
            if ! command -v qrencode &>/dev/null; then
                tg_reply "${chat_id}" "📦 Устанавливаю qrencode..."
                apt-get install -y -q qrencode &>/dev/null
            fi

            if command -v qrencode &>/dev/null; then
                local qr_file="/tmp/naiveproxy_qr_${qr_user}_$$.png"
                if qrencode -o "${qr_file}" -s 8 "${uri}" 2>/dev/null && [[ -s "${qr_file}" ]]; then
                    tg_send_photo "${chat_id}" "${qr_file}" "📱 QR для ${qr_user}@${DOMAIN}"
                    # Дополнительно отправляем URI текстом
                    tg_reply "${chat_id}" "🔗 <b>URI:</b>
<code>${uri}</code>"
                    rm -f "${qr_file}"
                else
                    tg_reply "${chat_id}" "⚠️ Ошибка генерации QR
🔗 URI: <code>${uri}</code>"
                fi
            else
                tg_reply "${chat_id}" "📱 <b>URI для ${qr_user}:</b>
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
                tg_reply "${chat_id}" "❌ Xray пользователи не найдены. Сначала настрой Xray: sudo bash naiveproxy.sh xray-install"
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
            local x_new="${args%% *}"
            if [[ -z "$x_new" ]]; then
                tg_reply "${chat_id}" "❌ Использование: /xrayadduser логин"
                return
            fi
            local xa_tmp xa_rc
            xa_tmp=$(mktemp)
            cmd_xray_add_user "$x_new" > "$xa_tmp" 2>&1
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
            tg_reply "${chat_id}" "💛 <b>Поддержать проект</b>

Если NaiveProxy Manager помог тебе — поддержи разработку!

👉 <a href=\"https://www.donationalerts.com/r/ivan_yurievich\">DonationAlerts</a>

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
            _script="${SCRIPT_PATH:-/usr/local/bin/naiveproxy.sh}"
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
Запусти на сервере: sudo bash naiveproxy.sh self-update"
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
    [[ -z "${TG_TOKEN:-}" ]] && err "Telegram не настроен. Запусти: sudo bash naiveproxy.sh" && return 1

    tg_apply_bot_menu_silent
    info "Запускаю Telegram бот..."
    info "Бот работает. Нажми Menu или напиши /menu в Telegram."
    info "Для остановки: Ctrl+C"
    echo

    local offset=0

    while true; do
        # Получаем обновления
        local response
        response=$(curl -s --max-time 35             "https://api.telegram.org/bot${TG_TOKEN}/getUpdates?offset=${offset}&timeout=30&allowed_updates=message"             2>/dev/null || echo "")

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
    local script_path="${SCRIPT_PATH:-/usr/local/bin/naiveproxy.sh}"

    cat > /etc/systemd/system/naiveproxy-bot.service << EOF
[Unit]
Description=NaiveProxy Telegram Bot
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
    tg_apply_bot_menu || warn "Команды Telegram Menu можно применить позже: sudo bash naiveproxy.sh bot-menu"
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

    tg_reply "${target_chat}" "📊 <b>Статистика NaiveProxy</b>

🌐 Домен: <code>${DOMAIN:-н/д}</code>
📡 Статус: ${caddy_status}
📦 Caddy: <code>${caddy_ver}</code>
👥 Пользователей: $(get_users | wc -l)

🖥 Сервер: <code>$(hostname)</code>
💾 RAM: $(free -h | awk '/Mem:/{print $3"/"$2}')
💿 Диск: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
⚡ CPU: $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')

🔐 Сертификат: ${cert_days} дней
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
}


# ══════════════════════════════════════════════════════════════
#   AURUM DNS (Unbound recursive resolver for VPN clients)
# ══════════════════════════════════════════════════════════════

DNS_CONF="/etc/unbound/unbound.conf.d/aurum-vpn.conf"
DNS_LEGACY_CONF="/etc/unbound/unbound.conf.d/naiveproxy-dns.conf"
DNS_LEGACY_BLOCKLIST="/etc/unbound/blocklist.conf"
DNS_LEGACY_WHITELIST="/etc/unbound/whitelist.txt"
DNS_RESOLVED_NO_STUB="/etc/systemd/resolved.conf.d/no-stub.conf"
DNS_GATEWAY_SERVICE="/etc/systemd/system/aurum-dns-gateway.service"
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
        out="${out},${item}"
    done
    printf '%s\n' "${out#,}"
}

unbound_mode_label() {
    echo "Aurum recursive DNSSEC"
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
Description=Aurum DNS local gateway IP (${gateway_ip})
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
    systemctl enable --now aurum-dns-gateway.service >/dev/null 2>&1 || {
        err "Не смог запустить aurum-dns-gateway.service"
        journalctl -u aurum-dns-gateway -n 20 --no-pager || true
        return 1
    }
    ip addr show dev lo | grep -q "${gateway_ip}/32" || {
        err "Gateway IP ${gateway_ip} не появился на lo"
        return 1
    }
    ok "Локальный DNS gateway поднят: ${gateway_ip}/32 на lo"
}

remove_managed_dns_gateway() {
    systemctl disable --now aurum-dns-gateway.service >/dev/null 2>&1 || true
    rm -f "$DNS_GATEWAY_SERVICE" 2>/dev/null || true
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

check_port53_for_aurum_dns() {
    local conflicts
    conflicts=$(port53_listeners | grep -Ev 'unbound|systemd-resolve|systemd-resolved' || true)
    if [[ -n "$conflicts" ]]; then
        err "Порт 53 занят другим сервисом. Aurum DNS не будет ломать его автоматически:"
        echo "$conflicts"
        return 1
    fi
}

cleanup_legacy_dns_files() {
    local file
    for file in "$DNS_LEGACY_CONF" "$DNS_LEGACY_BLOCKLIST" "$DNS_LEGACY_WHITELIST"; do
        if [[ -f "$file" ]]; then
            dns_config_backup "$file"
            rm -f "$file"
        fi
    done
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
    # Aurum VPN DNS: local recursive resolver.
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

install_aurum_dns_cli_commands() {
    local script_path="${SCRIPT_PATH:-/usr/local/bin/naiveproxy.sh}"
    cat > /usr/local/bin/aurum-dns-status <<EOF
#!/bin/sh
exec /bin/bash "$script_path" unbound-status
EOF
    cat > /usr/local/bin/aurum-dns-test <<EOF
#!/bin/sh
exec /bin/bash "$script_path" unbound-test
EOF
    cat > /usr/local/bin/aurum-dns-restart <<EOF
#!/bin/sh
exec /bin/bash "$script_path" unbound-restart
EOF
    chmod +x /usr/local/bin/aurum-dns-status /usr/local/bin/aurum-dns-test /usr/local/bin/aurum-dns-restart
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
    echo -e "${BOLD}  🛡️ Установка Aurum DNS (Unbound)${RESET}"
    hr

    info "Обновляю apt cache и устанавливаю зависимости..."
    apt-get update -qq
    apt-get install -y -q unbound unbound-anchor dnsutils dns-root-data ca-certificates curl

    cleanup_legacy_dns_files
    disable_resolved_stub_if_needed
    check_port53_for_aurum_dns || return 1
    mkdir -p /var/lib/unbound "$(dirname "$DNS_CONF")"
    unbound-anchor -a /var/lib/unbound/root.key >/dev/null 2>&1 || true

    echo
    echo -e "${CYAN}Aurum DNS работает как recursive Unbound без рекламных blocklists.${RESET}"
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
    install_aurum_dns_cli_commands

    # Статистика
    mkdir -p "$(dirname "${DNS_STATS_FILE}")"
    echo "0" > "${DNS_STATS_FILE}"
    UNBOUND_ENABLED="1"
    save_config

    ok "Aurum DNS установлен!"
    tg_send "🛡️ <b>Aurum DNS установлен</b>
🖥 Сервер: <code>$(hostname)</code>
🔒 Режим: recursive DNSSEC, gateway=${UNBOUND_GATEWAY_IP:-127.0.0.1}, VPN=${UNBOUND_VPN_ENABLED:-0}
🕐 $(date '+%Y-%m-%d %H:%M:%S')"
}

# Старый adblock/blocklists режим удалён: Aurum DNS теперь только безопасный resolver.
cmd_dns_update() {
    hr
    echo -e "${BOLD}  🛡️ Aurum DNS${RESET}"
    hr
    warn "Блокировка рекламы временно удалена из скрипта."
    info "Aurum DNS не скачивает blocklists и не логирует DNS-запросы."
    info "Для проверки используй: меню 17 → 3 или команду unbound-test"
}

cmd_dns_restart() {
    load_config
    hr
    echo -e "${BOLD}  🔄 Restart Aurum DNS${RESET}"
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
    ok "Aurum DNS перезапущен"
}

# Статус и тест Aurum DNS
cmd_dns_status() {
    load_config
    hr
    echo -e "${BOLD}  🛡️ Aurum DNS (Unbound)${RESET}"
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
            echo -e "  ${GREEN}✅ ${domain} → ${result}${RESET}"
        else
            echo -e "  ${RED}❌ ${domain} — не резолвится!${RESET}"
        fi
    done

    echo
    info "DNSSEC test..."
    if dig "@127.0.0.1" sigok.verteiltesysteme.net A +time=4 +tries=1 2>/dev/null | grep -q "status: NOERROR"; then
        echo -e "  ${GREEN}✅ DNSSEC valid domain: OK${RESET}"
    else
        echo -e "  ${YELLOW}⚠️ DNSSEC valid test не дал NOERROR${RESET}"
    fi
    if dig "@127.0.0.1" dnssec-failed.org A +time=4 +tries=1 2>/dev/null | grep -q "status: SERVFAIL"; then
        echo -e "  ${GREEN}✅ DNSSEC invalid domain отклонён${RESET}"
    else
        echo -e "  ${YELLOW}⚠️ DNSSEC invalid test не подтвердил SERVFAIL${RESET}"
    fi
    echo
    info "Последние логи Unbound:"
    journalctl -u unbound -n 20 --no-pager 2>/dev/null || true
    hr
}

cmd_dns_set_mode() {
    load_config
    hr
    echo -e "${BOLD}  🛡️ Aurum DNS mode${RESET}"
    hr
    warn "Forward/adblock режимы удалены. Aurum DNS работает только как безопасный recursive resolver."
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
    echo -e "${BOLD}  🛡️ Aurum DNS${RESET}"
    hr
    warn "Whitelist больше не нужен: блокировка рекламы удалена."
    info "Aurum DNS только резолвит DNS для сервера/VPN и не блокирует домены."
}

# Удалить Aurum DNS
cmd_dns_remove() {
    echo -ne "${YELLOW}Удалить Aurum DNS конфиг и команды? [y/N]: ${RESET}"
    read -r ans
    [[ "${ans,,}" != "y" ]] && return

    systemctl stop unbound 2>/dev/null || true
    systemctl disable unbound 2>/dev/null || true
    remove_unbound_ufw_rules
    [[ "${UNBOUND_MANAGED_GATEWAY:-0}" == "1" || -f "$DNS_GATEWAY_SERVICE" ]] && remove_managed_dns_gateway
    cleanup_legacy_dns_files
    dns_config_backup "$DNS_CONF"
    rm -f "$DNS_CONF"
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
    save_config
    systemctl daemon-reload 2>/dev/null || true

    ok "Aurum DNS удалён. Пакеты unbound/dnsutils не удалял."
}

# ─── Донат ─────────────────────────────────────────────────────
cmd_donate() {
    clear 2>/dev/null || true
    echo
    echo -e "${BOLD}${GOLD}  ╔════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${GOLD}  ║     💛 ПОДДЕРЖАТЬ ПРОЕКТ                   ║${RESET}"
    echo -e "${BOLD}${GOLD}  ╚════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "  ${CYAN}Если NaiveProxy Manager помог тебе —${RESET}"
    echo -e "  ${CYAN}поддержи разработку! Это очень мотивирует.${RESET}"
    echo
    echo -e "  ${BOLD}🎁 Ссылка на донат:${RESET}"
    echo -e "  ${BOLD}${GOLD}👉 https://www.donationalerts.com/r/ivan_yurievich${RESET}"
    echo
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${BOLD}Что даст твой донат:${RESET}"
    echo -e "  ${GREEN}🚀${RESET} Больше времени на разработку"
    echo -e "  ${GREEN}🐛${RESET} Быстрые фиксы багов"
    echo -e "  ${GREEN}✨${RESET} Новые фичи каждый месяц"
    echo -e "  ${GREEN}📚${RESET} Документация и поддержка"
    echo -e "  ${GREEN}🆕${RESET} Эксклюзив для донатеров в Telegram"
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${BOLD}Другие способы поддержки:${RESET}"
    echo -e "  ${CYAN}⭐${RESET} Поставь звезду:  github.com/ivan-yurich/naiveproxy"
    echo -e "  ${CYAN}📱${RESET} Telegram канал:  t.me/ivan_it_net"
    echo -e "  ${CYAN}🌐${RESET} Сайт:            ivan-it.net"
    echo -e "  ${CYAN}📢${RESET} Расскажи друзьям!"
    echo
    echo -e "  ${BOLD}${GOLD}Спасибо за поддержку! 🙏${RESET}"
    echo

    # Если есть qrencode — покажем QR код доната
    if command -v qrencode &>/dev/null; then
        echo -e "  ${DIM}QR код для доната:${RESET}"
        qrencode -t ANSIUTF8 "https://www.donationalerts.com/r/ivan_yurievich" 2>/dev/null | sed 's/^/    /'
        echo
    fi

    echo -ne "  ${YELLOW}Enter для возврата в меню...${RESET}"
    read -r
}

# Меню Aurum DNS
cmd_dns_menu() {
    while true; do
        load_config
        hr
        echo -e "${BOLD}  🛡️ Aurum DNS (Unbound)${RESET}"
        hr

        local dns_status="${RED}не установлен${RESET}"
        if command -v unbound &>/dev/null; then
            dns_status="${YELLOW}установлен, не запущен${RESET}"
            systemctl is-active --quiet unbound 2>/dev/null && dns_status="${GREEN}активен${RESET}"
        fi

        echo -e "  Статус: ${dns_status}"
        echo -e "  Режим: ${CYAN}$(unbound_mode_label)${RESET}"
        echo -e "  VPN DNS: ${CYAN}${UNBOUND_VPN_ENABLED:-0}${RESET} | Gateway: ${CYAN}${UNBOUND_GATEWAY_IP:-нет}${RESET} | CIDR: ${CYAN}${UNBOUND_VPN_CIDRS:-$DNS_DEFAULT_VPN_CIDRS}${RESET}"
        [[ "${UNBOUND_MANAGED_GATEWAY:-0}" == "1" ]] && echo -e "  Gateway mode: ${CYAN}auto lo /32${RESET}"
        echo
        echo -e "  ${BOLD}1)${RESET} Установить / переустановить Aurum DNS"
        echo -e "  ${BOLD}2)${RESET} Настроить DNS для VPN-клиентов"
        echo -e "  ${BOLD}3)${RESET} Статус, порт 53, DNSSEC и тесты"
        echo -e "  ${BOLD}4)${RESET} Перезапустить Aurum DNS"
        echo -e "  ${BOLD}5)${RESET} Удалить Aurum DNS"
        echo -e "  ${BOLD}0)${RESET} Назад"
        hr
        echo -ne "${CYAN}Выбор: ${RESET}"
        read -r choice

        case "${choice}" in
            1) cmd_dns_install ;;
            2) cmd_dns_vpn_access ;;
            3) cmd_dns_status ;;
            4) cmd_dns_restart ;;
            5) cmd_dns_remove ;;
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
    echo -e "${BOLD}  Статус NaiveProxy${RESET}"
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
            && ok "Aurum DNS: $(unbound_mode_label), gateway=${UNBOUND_GATEWAY_IP:-127.0.0.1}, vpn=${UNBOUND_VPN_ENABLED:-0}" \
            || warn "Aurum DNS: установлен, но не работает"
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

    check_installed || { err "NaiveProxy не установлен"; return 1; }

    local old_ver
    old_ver=$("$CADDY_BIN" version 2>/dev/null | head -1 || echo "unknown")
    info "Текущая версия: $old_ver"

    backup_config

    local tmp_caddy
    tmp_caddy=$(mktemp /tmp/naiveproxy_caddy_XXXXXX)
    rm -f "$tmp_caddy"
    trap 'rm -f "${tmp_caddy:-}" 2>/dev/null' RETURN

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
    echo -e "${BOLD}${RED}  Удаление NaiveProxy${RESET}"
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
    ufw delete allow "${XRAY_GRPC_PORT:-8447}/tcp" >/dev/null 2>&1 || true

    ( crontab -l 2>/dev/null | grep -v "naiveproxy\|monitor\.sh" || true ) | crontab -

    ok "NaiveProxy удалён"
}

# ─── ЛОГИ ────────────────────────────────────────────────────
cmd_logs() {
    echo -e "${BOLD}Лог Caddy (Ctrl+C для выхода):${RESET}"
    journalctl -u caddy -n 50 -f
}

# ─── МЕНЮ ────────────────────────────────────────────────────
show_menu() {
    clear
    load_config

    local status_str="${YELLOW}● не установлен${RESET}"
    if check_installed; then
        systemctl is-active --quiet caddy 2>/dev/null \
            && status_str="${GREEN}● работает${RESET}" \
            || status_str="${RED}● остановлен${RESET}"
    fi

    local tg_str="${RED}не настроен${RESET}"
    [[ -n "${TG_TOKEN:-}" ]] && tg_str="${GREEN}подключён${RESET}"

    hr
    echo -e "${BOLD}${CYAN}   NaiveProxy Manager v${VERSION}${RESET}  ${DIM}[$(t "РУС" "ENG")]${RESET}"
    echo -e "   Статус: ${status_str}  |  Домен: ${CYAN}${DOMAIN:-не задан}${RESET}"
    local ssh_str="${YELLOW}не настроен${RESET}"
    [[ -f "$SSH_HARDENING_DONE" ]] && ssh_str="${GREEN}$(grep SSH_PORT "$SSH_HARDENING_DONE" 2>/dev/null | cut -d= -f2)${RESET}"
    echo -e "   Telegram: ${tg_str}  |  Юзеров: $(get_users | wc -l)  |  SSH порт: ${ssh_str}"
    local hysteria_str="${YELLOW}не установлен${RESET}"
    if [[ -f "$HYSTERIA_CONFIG" || -x "$HYSTERIA_BIN" ]]; then
        systemctl is-active --quiet hysteria 2>/dev/null \
            && hysteria_str="${GREEN}UDP/${HYSTERIA_PORT:-8443}${RESET}" \
            || hysteria_str="${RED}остановлен${RESET}"
    fi
    echo -e "   Hysteria 2: ${hysteria_str}"
    local warp_str="${YELLOW}не установлен${RESET}"
    if command -v warp-cli &>/dev/null; then
        case "${WARP_MODE:-off}" in
            proxy) warp_str="${GREEN}proxy 127.0.0.1:${WARP_PROXY_PORT:-$WARP_PROXY_PORT_DEFAULT}${RESET}" ;;
            warp|warp+doh) warp_str="${GREEN}full ${WARP_MODE}${RESET}" ;;
            *) warp_str="${YELLOW}установлен${RESET}" ;;
        esac
    fi
    echo -e "   WARP: ${warp_str}"
    local xray_str="${YELLOW}не установлен${RESET}"
    if [[ -x "$XRAY_BIN" || -f "$XRAY_CONFIG" ]]; then
        systemctl is-active --quiet xray 2>/dev/null \
            && xray_str="${GREEN}active${RESET}" \
            || xray_str="${RED}остановлен${RESET}"
        [[ "${XRAY_FALLBACK_ENABLED:-0}" == "1" ]] && xray_str="${xray_str} ${CYAN}443-fallback${RESET}"
    fi
    echo -e "   Xray Modern: ${xray_str}"
    local unbound_str="${YELLOW}не установлен${RESET}"
    if command -v unbound &>/dev/null; then
        if systemctl is-active --quiet unbound 2>/dev/null; then
            unbound_str="${GREEN}active${RESET} ${CYAN}${UNBOUND_GATEWAY_IP:-127.0.0.1}${RESET}"
        else
            unbound_str="${RED}остановлен${RESET}"
        fi
    fi
    echo -e "   Aurum DNS: ${unbound_str}"
    local device_str="${YELLOW}выкл${RESET}"
    if [[ "${DEVICE_LIMIT_ENABLED:-0}" == "1" ]]; then
        device_str="${GREEN}${DEVICE_LIMIT:-$DEVICE_LIMIT_DEFAULT}/${DEVICE_WINDOW_HOURS:-$DEVICE_WINDOW_HOURS_DEFAULT}ч ${DEVICE_LIMIT_MODE:-alert}${RESET}"
    fi
    echo -e "   Лимит устройств: ${device_str}"
    hr
    echo -e "   ${BOLD}1)${RESET}  Установить NaiveProxy"
    echo -e "   ${BOLD}2)${RESET}  Статус"
    echo -e "   ${BOLD}3)${RESET}  Клиентский конфиг"
    echo -e "   ${BOLD}4)${RESET}  Управление пользователями"
    echo -e "   ${BOLD}5)${RESET}  🌐 Управление доменами"
    echo -e "   ${BOLD}6)${RESET}  Мониторинг и статистика"
    echo -e "   ${BOLD}7)${RESET}  Настройка Telegram + Бот"
    echo -e "   ${BOLD}8)${RESET}  Перезапустить Caddy"
    echo -e "   ${BOLD}9)${RESET}  Обновить Caddy"
    echo -e "   ${BOLD}10)${RESET} Логи"
    echo -e "   ${BOLD}11)${RESET} Удалить NaiveProxy"
    echo -e "   ${BOLD}16)${RESET} 🔍 Диагностика системы"
    echo -e "   ${BOLD}17)${RESET} 🛡️ Aurum DNS (Unbound)"
    echo -e "   ${BOLD}18)${RESET} 💛 Поддержать проект (донат)"
    echo -e "   ──────────────────────────"
    echo -e "   ${BOLD}12)${RESET} 🔒 SSH Hardening"
    echo -e "   ${BOLD}13)${RESET} 🔄 Обновить систему"
    echo -e "   ${BOLD}14)${RESET} ⬆️  Обновить скрипт"
    echo -e "   ${BOLD}15)${RESET} 🎭 Обновить камуфляж"
    echo -e "   ${BOLD}19)${RESET} ♻️  Reload Caddy без разрыва"
    echo -e "   ${BOLD}20)${RESET} ⚡ Hysteria 2 (UDP порт на выбор)"
    echo -e "   ${BOLD}21)${RESET} 🌀 WARP modes (proxy/full tunnel)"
    echo -e "   ${BOLD}22)${RESET} 📱 Лимит устройств / анти-шаринг"
    echo -e "   ${BOLD}23)${RESET} 🧬 Xray VLESS/Trojan/REALITY fallback"
    echo -e "   ${BOLD}24)${RESET} 🛠 Diagnose --fix"
    echo -e "   ${BOLD}25)${RESET} 🔗 Страница подписки пользователя"
    echo -e "   ${BOLD}26)${RESET} 🎭 Личная фейковая страница"
    echo -e "   ${BOLD}0)${RESET}  Выход"
    hr
    echo -ne "${CYAN}Выбор [0-26]: ${RESET}"
}

# ─── MAIN ────────────────────────────────────────────────────
main() {
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
            users)     cmd_users ;;
            hysteria|hy2) cmd_hysteria_menu ;;
            hysteria-install|hy2-install) cmd_hysteria_install ;;
            hysteria-config|hy2-config) print_hysteria_client_config "${2:-}" ;;
            hysteria-status|hy2-status) cmd_hysteria_status ;;
            hysteria-logs|hy2-logs) cmd_hysteria_logs ;;
            hysteria-port|hy2-port) cmd_hysteria_change_port ;;
            hysteria-remove|hy2-remove) cmd_hysteria_remove ;;
            warp) cmd_warp_menu ;;
            warp-install|warp-proxy) cmd_warp_install ;;
            warp-full|warp-full-install) cmd_warp_full_install ;;
            warp-config) print_warp_proxy_config ;;
            warp-status) cmd_warp_status ;;
            warp-test) cmd_warp_test ;;
            warp-full-test) cmd_warp_test_full ;;
            warp-protocol) cmd_warp_protocol ;;
            warp-logs) cmd_warp_logs ;;
            warp-disable) cmd_warp_disable ;;
            warp-remove) cmd_warp_remove ;;
            xray) cmd_xray_menu ;;
            xray-install) cmd_xray_install ;;
            xray-add-user|xray-user) cmd_xray_add_user "${2:-}" ;;
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
            subscription|sub) cmd_subscription_user "${2:-}" ;;
            subscription-reset|sub-reset) cmd_subscription_reset "${2:-}" ;;
            private-page) install_private_camouflage_page "${2:-}" ;;
            tg-stats)      tg_send_stats; ok "Отправлено" ;;
            ssh-hardening) cmd_ssh_hardening ;;
            ssh-rescue)    cmd_ssh_rescue ;;
            sysupdate)     cmd_sysupdate ;;
            cert)        load_config; check_cert "${DOMAIN:-}" ;;
            domains)     load_config; cmd_domains ;;
            qr)          load_config; print_client_config ;;
            ssh-key)     cat "${CONFIG_DIR}/ssh_private_key" 2>/dev/null || err "Ключ не найден: ${CONFIG_DIR}/ssh_private_key" ;;
            diagnose)    cmd_diagnose "${2:-}" ;;
            dns|unbound|aurum-dns)                         cmd_unbound_plugin ;;
            dns-install|unbound-install|aurum-dns-install) cmd_dns_install ;;
            dns-mode|unbound-mode)                         cmd_dns_set_mode ;;
            dns-vpn|unbound-vpn|aurum-dns-vpn)             cmd_dns_vpn_access ;;
            dns-update|unbound-update)                     cmd_dns_update ;;
            dns-status|unbound-status|unbound-test|aurum-dns-status|aurum-dns-test) cmd_dns_status ;;
            dns-restart|unbound-restart|aurum-dns-restart) cmd_dns_restart ;;
            dns-remove|unbound-remove|aurum-dns-remove)     cmd_dns_remove ;;
            bot)         load_config; cmd_bot ;;
            bot-install) load_config; install_bot_service ;;
            bot-menu)    load_config; tg_apply_bot_menu ;;
            self-update)  load_config; cmd_self_update ;;
            camouflage)   install_camouflage_page ;;
            version)
                echo "NaiveProxy Manager v${VERSION}"
                echo "Telegram: https://t.me/ivan_it_net"
                echo "Сайт:     https://ivan-it.net"
                echo "GitHub:   github.com/ivan-yurich/naiveproxy"
                ;;
            *) err "Неизвестная команда: $1"
               echo "Доступные: install status config [user] reload restart update remove logs monitor users hysteria hy2 hysteria-port warp warp-proxy warp-full warp-protocol xray xray-add-user [user] devices subscription private-page tg-stats bot-menu ssh-hardening ssh-rescue sysupdate cert domains dns unbound aurum-dns aurum-dns-status aurum-dns-restart self-update version camouflage"
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
            0)  echo -e "${GREEN}Пока!${RESET}"; exit 0 ;;
            *)  warn "Неверный выбор" ;;
        esac
        echo
        echo -ne "${YELLOW}Нажми Enter чтобы вернуться в меню...${RESET}"
        read -r
    done
}

main "$@"
