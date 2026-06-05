#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/unbound/unbound.conf.d/aurum-vpn.conf"
ENV_DIR="/etc/aurum-dns"
ENV_FILE="${ENV_DIR}/aurum-dns.env"
NO_STUB="/etc/systemd/resolved.conf.d/no-stub.conf"
GATEWAY_SERVICE="/etc/systemd/system/aurum-dns-gateway.service"
DEFAULT_GATEWAY="10.0.0.1"
DEFAULT_CIDRS="10.0.0.0/24"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '[i] %s\n' "$*"; }
ok() { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die() { printf '[ERR] %s\n' "$*" >&2; exit 1; }

require_root() {
    [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo bash install-dns.sh"
}

backup_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    cp -a "$file" "${file}.bak.$(date '+%Y%m%d-%H%M%S')"
}

is_ipv4() {
    local ip="$1" part
    local -a parts
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS='.' read -r -a parts <<< "$ip"
    for part in "${parts[@]}"; do
        [[ "$part" =~ ^[0-9]+$ && "$part" -ge 0 && "$part" -le 255 ]] || return 1
    done
}

is_cidr4() {
    local cidr="$1" ip mask
    [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]] || return 1
    ip="${cidr%/*}"
    mask="${cidr#*/}"
    is_ipv4 "$ip" && [[ "$mask" -ge 0 && "$mask" -le 32 ]]
}

normalize_cidrs() {
    local raw="$1" item out=""
    local -a items
    raw="${raw// /}"
    IFS=',' read -r -a items <<< "$raw"
    for item in "${items[@]}"; do
        [[ -z "$item" ]] && continue
        is_cidr4 "$item" || die "Invalid CIDR: $item"
        [[ "${item#*/}" == "0" ]] && die "Open resolver is forbidden: /0"
        out="${out},${item}"
    done
    [[ -n "$out" ]] || die "At least one VPN CIDR is required"
    printf '%s\n' "${out#,}"
}

server_ipv4s() {
    ip -o -4 addr show scope global up 2>/dev/null \
        | awk '{split($4, a, "/"); if (a[1] != "" && a[1] !~ /^127\./ && a[1] !~ /^169\.254\./) print a[1]}' \
        | sort -u
}

detect_gateway() {
    server_ipv4s | awk '/^10\./ || /^192\.168\./ || /^172\.(1[6-9]|2[0-9]|3[0-1])\./ {print; exit}'
}

ip_on_server() {
    local gateway="$1"
    [[ "$gateway" == "127.0.0.1" ]] && return 0
    server_ipv4s | grep -Fxq "$gateway"
}

ensure_managed_gateway() {
    local gateway="$1" ip_bin
    is_ipv4 "$gateway" || die "Invalid gateway IP: $gateway"
    ip_bin=$(command -v ip || echo "/usr/sbin/ip")
    cat > "$GATEWAY_SERVICE" <<EOF
[Unit]
Description=Yurich DNS local gateway IP (${gateway})
Before=unbound.service
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c '${ip_bin} addr replace ${gateway}/32 dev lo && ${ip_bin} link set lo up'
ExecStop=/bin/sh -c '${ip_bin} addr del ${gateway}/32 dev lo 2>/dev/null || true'

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now aurum-dns-gateway.service >/dev/null 2>&1
}

prepare_gateway() {
    local gateway="$1" ans
    if ip_on_server "$gateway"; then
        return 0
    fi
    warn "Gateway IP $gateway is not assigned to this server."
    if [[ -t 0 ]]; then
        printf 'Create local gateway %s/32 on lo automatically? [Y/n]: ' "$gateway"
        read -r ans
    else
        ans="y"
    fi
    [[ "${ans,,}" == "n" ]] && die "Gateway is required for VPN DNS"
    ensure_managed_gateway "$gateway"
}

port53_listeners() {
    ss -H -lntup 2>/dev/null | awk '$5 ~ /:53$/ || $5 ~ /:53%/ {print}'
}

disable_resolved_stub_if_needed() {
    if ! systemctl cat systemd-resolved.service >/dev/null 2>&1; then
        return 0
    fi

    if port53_listeners | grep -qi 'systemd-resolve'; then
        log "systemd-resolved DNS stub uses port 53, disabling DNSStubListener"
        mkdir -p "$(dirname "$NO_STUB")"
        backup_file "$NO_STUB"
        cat > "$NO_STUB" <<'EOF'
[Resolve]
DNSStubListener=no
EOF
        systemctl restart systemd-resolved || true
        sleep 1
    fi
}

check_port53() {
    local conflicts
    conflicts=$(port53_listeners | grep -Ev 'unbound|systemd-resolve|systemd-resolved' || true)
    if [[ -n "$conflicts" ]]; then
        printf '%s\n' "$conflicts"
        die "Port 53 is busy by another service. Stop it manually, then rerun."
    fi
}

write_env() {
    local gateway="$1" cidrs="$2"
    mkdir -p "$ENV_DIR"
    cat > "$ENV_FILE" <<EOF
AURUM_DNS_GATEWAY='${gateway}'
AURUM_DNS_CIDRS='${cidrs}'
EOF
    chmod 600 "$ENV_FILE"
}

write_unbound_config() {
    local gateway="$1" cidrs="$2" cidr
    local -a cidr_list
    mkdir -p "$(dirname "$CONF")" /var/lib/unbound
    backup_file "$CONF"

    cat > "$CONF" <<EOF
server:
    # Yurich DNS: private recursive resolver for VPN clients.
    # Security rule: never bind 0.0.0.0 here.
    interface: 127.0.0.1
EOF

    if [[ -n "$gateway" ]]; then
        printf '    interface: %s\n' "$gateway" >> "$CONF"
    fi

    cat >> "$CONF" <<'EOF'
    port: 53

    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes

    access-control: 0.0.0.0/0 refuse
    access-control: 127.0.0.0/8 allow
EOF

    IFS=',' read -r -a cidr_list <<< "$cidrs"
    for cidr in "${cidr_list[@]}"; do
        [[ -n "$cidr" ]] && printf '    access-control: %s allow\n' "$cidr" >> "$CONF"
    done

    cat >> "$CONF" <<'EOF'

    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    harden-large-queries: yes
    harden-short-bufsize: yes
    qname-minimisation: yes
    aggressive-nsec: yes
    val-clean-additional: yes

    # DNSSEC trust anchor is managed by Ubuntu's Unbound package.
    # Do not duplicate auto-trust-anchor-file here.
    root-hints: "/usr/share/dns/root.hints"

    prefetch: yes
    prefetch-key: yes
    cache-min-ttl: 300
    cache-max-ttl: 86400
    rrset-cache-size: 128m
    msg-cache-size: 64m
    so-rcvbuf: 256k

    log-queries: no
    statistics-interval: 0
    verbosity: 1
EOF
}

apply_ufw() {
    local cidrs="$1" cidr
    local -a cidr_list
    command -v ufw >/dev/null 2>&1 || return 0
    IFS=',' read -r -a cidr_list <<< "$cidrs"
    for cidr in "${cidr_list[@]}"; do
        [[ -z "$cidr" ]] && continue
        ufw allow from "$cidr" to any port 53 proto udp comment "Yurich DNS VPN" >/dev/null 2>&1 || true
        ufw allow from "$cidr" to any port 53 proto tcp comment "Yurich DNS VPN" >/dev/null 2>&1 || true
    done
}

install_commands() {
    install -m 755 "${SCRIPT_DIR}/scripts/aurum-dns-status" /usr/local/bin/aurum-dns-status
    install -m 755 "${SCRIPT_DIR}/scripts/aurum-dns-test" /usr/local/bin/aurum-dns-test
    install -m 755 "${SCRIPT_DIR}/scripts/aurum-dns-restart" /usr/local/bin/aurum-dns-restart
}

run_tests() {
    unbound-checkconf "$CONF"
    systemctl enable unbound --quiet
    systemctl reset-failed unbound 2>/dev/null || true
    systemctl restart unbound
    systemctl status unbound --no-pager || true
    dig @127.0.0.1 google.com +time=3 +tries=1
    dig @127.0.0.1 cloudflare.com +time=3 +tries=1
    dig @127.0.0.1 sigok.verteiltesysteme.net A +time=4 +tries=1 | grep -q 'status: NOERROR' \
        && ok "DNSSEC valid test passed" || warn "DNSSEC valid test was inconclusive"
}

main() {
    require_root
    apt-get update -qq
    apt-get install -y -q unbound unbound-anchor dnsutils dns-root-data curl ca-certificates

    local gateway="${AURUM_DNS_GATEWAY:-}" cidrs="${AURUM_DNS_CIDRS:-}"
    local detected
    detected=$(detect_gateway || true)

    if [[ -t 0 && -z "$gateway" ]]; then
        printf 'VPN gateway IP [%s, 0 = local only]: ' "${detected:-$DEFAULT_GATEWAY}"
        read -r gateway
        gateway="${gateway:-${detected:-$DEFAULT_GATEWAY}}"
    fi

    if [[ "$gateway" =~ ^(0|local|none)$ ]]; then
        gateway=""
    elif [[ -n "$gateway" ]]; then
        is_ipv4 "$gateway" || die "Invalid gateway IP: $gateway"
        prepare_gateway "$gateway"
    fi

    if [[ -t 0 && -z "$cidrs" ]]; then
        printf 'VPN CIDR [%s]: ' "$DEFAULT_CIDRS"
        read -r cidrs
    fi
    cidrs=$(normalize_cidrs "${cidrs:-$DEFAULT_CIDRS}")

    disable_resolved_stub_if_needed
    check_port53
    write_env "$gateway" "$cidrs"
    write_unbound_config "$gateway" "$cidrs"
    apply_ufw "$cidrs"
    install_commands
    run_tests
    ok "Yurich DNS installed. Commands: aurum-dns-status, aurum-dns-test, aurum-dns-restart"
}

main "$@"
