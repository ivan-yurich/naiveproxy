#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/unbound/unbound.conf.d/yurich-dns.conf"
LEGACY_CONF="/etc/unbound/unbound.conf.d/aurum-vpn.conf"
LEGACY_NAIVE_CONF="/etc/unbound/unbound.conf.d/naiveproxy-dns.conf"
LEGACY_BLOCKLIST="/etc/unbound/blocklist.conf"
LEGACY_WHITELIST="/etc/unbound/whitelist.txt"
ENV_FILE="/etc/yurich-dns/yurich-dns.env"
LEGACY_ENV_FILE="/etc/aurum-dns/aurum-dns.env"
NO_STUB="/etc/systemd/resolved.conf.d/no-stub.conf"
GATEWAY_SERVICE="/etc/systemd/system/yurich-dns-gateway.service"
LEGACY_GATEWAY_SERVICE="/etc/systemd/system/aurum-dns-gateway.service"

log() { printf '[i] %s\n' "$*"; }
ok() { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die() { printf '[ERR] %s\n' "$*" >&2; exit 1; }

require_root() {
    [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo bash uninstall-dns.sh"
}

backup_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    cp -a "$file" "${file}.bak.$(date '+%Y%m%d-%H%M%S')" || true
}

source_env_if_safe() {
    local env_file="$ENV_FILE"
    [[ -f "$env_file" ]] || env_file="$LEGACY_ENV_FILE"
    [[ -f "$env_file" ]] || return 0

    local owner perms
    owner=$(stat -c '%U' "$env_file" 2>/dev/null || echo "unknown")
    perms=$(stat -c '%a' "$env_file" 2>/dev/null || echo "000")
    if [[ "$owner" != "root" ]]; then
        warn "Skip unsafe env file owner: $env_file belongs to $owner"
        return 0
    fi
    if [[ "$perms" != "600" ]]; then
        chmod 600 "$env_file" 2>/dev/null || true
    fi

    # shellcheck disable=SC1090
    source "$env_file"
}

remove_ufw_rules() {
    local cidr cidrs="${YURICH_DNS_CIDRS:-10.0.0.0/24}"
    local -a cidr_list
    command -v ufw >/dev/null 2>&1 || return 0
    IFS=',' read -r -a cidr_list <<< "$cidrs"
    for cidr in "${cidr_list[@]}"; do
        [[ -z "$cidr" ]] && continue
        ufw delete allow from "$cidr" to any port 53 proto udp >/dev/null 2>&1 || true
        ufw delete allow from "$cidr" to any port 53 proto tcp >/dev/null 2>&1 || true
    done
}

main() {
    require_root

    source_env_if_safe

    systemctl stop unbound 2>/dev/null || true
    systemctl disable unbound 2>/dev/null || true
    systemctl disable --now "$(basename "$GATEWAY_SERVICE")" 2>/dev/null || true
    systemctl disable --now "$(basename "$LEGACY_GATEWAY_SERVICE")" 2>/dev/null || true
    rm -f "$GATEWAY_SERVICE" "$LEGACY_GATEWAY_SERVICE"
    remove_ufw_rules

    backup_file "$CONF"
    backup_file "$LEGACY_CONF"
    backup_file "$LEGACY_NAIVE_CONF"
    backup_file "$LEGACY_BLOCKLIST"
    backup_file "$LEGACY_WHITELIST"
    rm -f "$CONF" "$LEGACY_CONF" "$LEGACY_NAIVE_CONF" "$LEGACY_BLOCKLIST" "$LEGACY_WHITELIST"
    rm -f /usr/local/bin/yurich-dns-status /usr/local/bin/yurich-dns-test /usr/local/bin/yurich-dns-restart
    rm -f /usr/local/bin/aurum-dns-status /usr/local/bin/aurum-dns-test /usr/local/bin/aurum-dns-restart

    if [[ -f "$NO_STUB" ]]; then
        backup_file "$NO_STUB"
        rm -f "$NO_STUB"
        systemctl restart systemd-resolved 2>/dev/null || true
    fi

    rm -f "$ENV_FILE" "$LEGACY_ENV_FILE"
    rmdir /etc/yurich-dns 2>/dev/null || true
    rmdir /etc/aurum-dns 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true

    ok "DNS (Unbound) config removed. VPN config was not touched."
    if [[ -t 0 ]]; then
        printf 'Remove packages unbound/dnsutils too? [y/N]: '
        read -r ans
        if [[ "${ans,,}" == "y" ]]; then
            apt-get remove -y unbound dnsutils || true
            ok "Packages removed"
        else
            log "Packages kept"
        fi
    else
        log "Packages kept. Remove manually if needed: apt-get remove unbound dnsutils"
    fi
}

main "$@"
