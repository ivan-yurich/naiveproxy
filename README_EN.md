<div align="center">

🌐 **Language / Язык:** [🇷🇺 Русский](README.md) · [🇬🇧 English](README_EN.md) · [Release notes](RELEASE_NOTES_RU.md)

</div>

<div align="center">

# 🛡️ Yurich Panel

```
███╗   ██╗ █████╗ ██╗██╗   ██╗███████╗    ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
████╗  ██║██╔══██╗██║██║   ██║██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██╔██╗ ██║███████║██║██║   ██║█████╗      ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██║╚██╗██║██╔══██║██║╚██╗ ██╔╝██╔══╝      ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║ ╚████║██║  ██║██║ ╚████╔╝ ███████╗    ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
                                                                            MANAGER
```

### 🚀 Professional secure proxy server manager

**One script. Bare VPS → secure proxy, private DNS and diagnostics in 10 minutes.**

*Caddy 2 · Yurich Proxy · Telegram Bot · DNS (Unbound) · Diagnostics · SSH Hardening*

---

[![Version](https://img.shields.io/badge/version-5.6.49-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivan-yurich/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/bash--n-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![License](https://img.shields.io/badge/License-PolyForm%20Noncommercial%20%2B%20Commercial-58A6FF?style=for-the-badge)](LICENSE)

[![Stars](https://img.shields.io/github/stars/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=D4A017)](https://github.com/ivan-yurich/naiveproxy/stargazers)
[![Forks](https://img.shields.io/github/forks/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=58A6FF)](https://github.com/ivan-yurich/naiveproxy/network)
[![Issues](https://img.shields.io/github/issues/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=F85149)](https://github.com/ivan-yurich/naiveproxy/issues)
[![Last commit](https://img.shields.io/github/last-commit/ivan-yurich/naiveproxy?style=for-the-badge&logo=github&color=3FB950)](https://github.com/ivan-yurich/naiveproxy/commits/main)

---

### 💛 Support development

[![Donate](https://img.shields.io/badge/💛_Support_project-Donation page-FF5E3A?style=for-the-badge)](https://example.com/donate)
[![Telegram](https://img.shields.io/badge/📱_Telegram_channel-@your__channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/your_channel)
[![Website](https://img.shields.io/badge/🌐_Website-example.com-D4A017?style=for-the-badge&logo=googlechrome&logoColor=white)](https://example.com)

**🔔 Updates released once a month**

</div>

---

<div align="center">

### 🎯 Navigation

[**⚡ Quick Start**](#-quick-start) ·
[**✨ Features**](#-features) ·
[**🤖 Telegram Bot**](#-telegram-bot) ·
[**🛡️ DNS (Unbound)**](#-dns-unbound) ·
[**🌀 WARP**](#-cloudflare-warp-modes) ·
[**🔍 Diagnostics**](#-diagnostics) ·
[**📌 Release Notes**](RELEASE_NOTES_RU.md) ·
[**🧩 Multi-server**](MULTISERVER_GUIDE_RU.md) ·
[**❓ FAQ**](#-faq) ·
[**💛 Donate**](#-support-the-project)

</div>

---

## 🌟 Why this is the best choice?

<table>
<tr>
<td align="center" width="33%">

### 🚀 Speed
**10 minutes**
from bare VPS to working proxy with auto TLS, bans and private DNS

</td>
<td align="center" width="33%">

### 🛡️ Security
**DPI protection**
Yurich Proxy uses a Naive-compatible Chrome-like transport

</td>
<td align="center" width="33%">

### 🤖 Convenience
**Telegram control**
25+ commands + multi-admin + QR, subscriptions and Xray in chat

</td>
</tr>
</table>

---

## 🎉 What's new in the current 5.6.x branch

> v5.6.49 is the GitHub-ready public release: personal domains, IP addresses, Telegram IDs, tokens, local paths and private payment/support data were removed or replaced with placeholders. The release also adds `SECURITY.md`, repository hygiene files, expanded multi-server documentation and clearer protocol validation/benchmark notes.

<table>
<tr>
<td width="50%" valign="top">

### 🐛 Bug fixes

✅ New `29) [NODES] Multi-server management` menu
✅ Root-only node registry: `/etc/naiveproxy/nodes.conf`
✅ Node SSH/status checks for hostname, uptime, services and active ports
✅ Deploy the current `yurich-panel.sh` / `naiveproxy.sh` to a selected node
✅ Sync users and metadata to one node or all enabled nodes
✅ Remote backup before applying synced users
✅ Remote `safe-apply`, `hysteria-sync` and `xray-rebuild`
✅ Subscription `links.txt` can include additional `naive+https` links for enabled node domains
✅ CLI commands: `nodes`, `nodes-add`, `nodes-test`, `nodes-deploy`, `nodes-sync`, `nodes-subscriptions`
✅ Subscription pages include Yurich Connect Android and Windows release links
✅ Project contacts are shown on subscription pages: Telegram, VK and email
✅ Windows/Android setup cards link to the official client releases
✅ REALITY target presets for RU/Global candidate domains
✅ Live TLS/SNI check before applying the selected target
✅ New Xray menu action: `REALITY target presets / test`
✅ New CLI command: `xray-target`
✅ VLESS XHTTP TLS now works as a standalone inbound on `8448/tcp`
✅ XHTTP no longer requires the 443 fallback hub
✅ Subscription pages and `links.txt` include the XHTTP standalone link automatically
✅ UFW/status/diagnostics/uninstall now handle the XHTTP port
✅ Installer no longer appears to hang after generating the first user password
✅ The subscription term prompt is now printed directly to the terminal
✅ `prompt_user_term_months` works safely inside command substitution
✅ Terminal SSH panel no longer depends on emoji fonts
✅ Main menu icons changed to ASCII labels like `[DNS]`, `[WARP]`, `[XRAY]`
✅ Diagnostics now use `[OK]`, `[WARN]`, `[FAIL]` in terminal output
✅ DNS and donate terminal screens are emoji-safe
✅ WARP proxy mode now regenerates Caddy with `forward_proxy upstream socks5://127.0.0.1:40000`
✅ Hysteria 2 server config now gets a WARP SOCKS5 `outbounds` block
✅ Xray WARP outbound now uses SOCKS plus explicit routing
✅ WARP mode changes refresh Caddy, Xray and Hysteria automatically
✅ New `warp-ssh-allow` command for full-tunnel SSH safety
✅ Full-tunnel WARP asks for extra SSH IP/CIDR before enabling
✅ More robust parser for Xray REALITY key output formats
✅ Yurich Panel branding refresh
✅ Public transport brand added: `Yurich Proxy`
✅ Branded `yurich://proxy?...` alias added for future Yurich clients
✅ Compatible `naive+https://` URI is kept unchanged for current clients
✅ Main script renamed to `yurich-panel.sh`, with `naiveproxy.sh` kept as a compatibility alias
✅ Public UI, Telegram messages, subscription pages and DNS docs aligned with Yurich Panel
✅ Technical protocol names stay intact where they refer to real components
✅ Self-update remains compatible with older releases
✅ Self-update SHA256 verification via `yurich-panel.sh.sha256`
✅ SSH panel language selector: Russian / English
✅ `language` CLI command and menu item 28
✅ Main SSH panel labels and statuses translated
✅ Pinned defaults for `xcaddy v0.4.6`, `forwardproxy d62c80d`, `Xray v26.3.27` and `Hysteria app/v2.9.2`
✅ One-shot `health` report for Caddy, DNS (Unbound), Telegram bot, WARP, Xray and Hysteria
✅ `safe-apply` validates enabled configs and rolls Caddyfile back on failure
✅ Encrypted `/etc/naiveproxy` backup via OpenSSL
✅ Export/import users, subscription tokens and user metadata
✅ User expiration terms from 1 to 12 months
✅ Subscription pages show expiration, URI labels include expiry tags
✅ Production tools menu with backup, export/import and bridge builder
✅ Bridge profile builder for mobile → first VPS → second VPS scenarios
✅ Fail2Ban can now be installed/refreshed without SSH Hardening
✅ New `yurich-caddy-auth` jail for Caddy `401/407` JSON access log events
✅ ACME port `80/tcp` now uses a real `ufw limit` rule
✅ Health-check verifies UFW rules for SSH, 80/443, Hysteria, Xray and DNS
✅ CLI alias: `fail2ban`, `f2b` or `security`

✅ User deletion now removes the subscription token and web page
✅ Hysteria 2 empty or short `obfs.salamander.password`
✅ Xray mKCP config for newer Xray-core builds without legacy `header`/`seed`
✅ Hysteria 2 password generation under `set -euo pipefail`
✅ WARP proxy verification now requires `warp=on`
✅ Xray REALITY key parsing for newer `xray x25519` output
✅ Unbound crash with duplicate DNSSEC trust anchor
✅ Port 53 conflict with systemd-resolved stub listener
✅ Telegram Menu button did not show the command list automatically
✅ Telegram bot `/menu` polling failed because `allowed_updates` was not sent as a JSON array
✅ VPN DNS CIDR `/0` variants could be accepted outside the exact `0.0.0.0/0` string
✅ Watchdog Telegram sender now uses safe `--data-urlencode` payloads
✅ `((var++))` → `var=$((var+1))` (set -e safety)
✅ `/qr` command — curl conflict fix
✅ `/adduser` — login/password validation
✅ Bot commands — `\r\n` cleanup
✅ `set +e` — error doesn't break bot
✅ Diagnostics — counter fixes
✅ ALPN — `-servername` + `-a` flag
✅ SSH port on Ubuntu 22.04+ (`sshd_config.d/`)
✅ Protection against deleting last domain
✅ Auto-restart Caddy and bot on failure

</td>
<td width="50%" valign="top">

### ⚡ New features

🧭 **DNS (Unbound)** — production-ready Unbound resolver for VPN clients
🔐 **DNSSEC validation** — recursive DNS with `sigok` / `dnssec-failed` tests
🔒 **VPN-only DNS access** — port 53 is allowed only from configured VPN CIDRs
🛠️ **Port 53 fix** — safely disables only the systemd-resolved stub listener when needed
🌉 **Auto DNS gateway** — can create `10.0.0.1/32` on `lo` for client TUN configs
🧩 **Standalone project** — `yurich-dns/` with install, uninstall, examples and CLI tools
♻️ **Idempotent installer** — backups before changes and safe repeated runs
📱 **Client configs** — sing-box Android VPN/TUN examples include DNS (Unbound) automatically
🧭 **Telegram Menu** — Bot API `setMyCommands` + `setChatMenuButton`
🤖 **Bot service helper** — Telegram setup can install and start `naiveproxy-bot.service` immediately
🔐 **DNS (Unbound) env guard** — standalone status/uninstall scripts trust only root-owned env files
🧩 **Bot install sync** — service install syncs the currently running valid script into `/usr/local/bin`
🛠️ **bot-menu CLI** — refresh the Telegram command menu manually
⚡ **Per-user Hysteria 2** — Hysteria server config now uses `auth.type: userpass` for Yurich Proxy users
⚙️ **Hysteria port selector** — choose the default UDP/8443 or enter a custom UDP port
🔗 **Hysteria in subscriptions** — personal pages now include Yurich Proxy + Hysteria 2 + Xray links when available
🛟 **WARP SSH-safe full tunnel** — full tunnel adds split-tunnel excludes for the current SSH IP and arms rollback
🌀 **WARP full tunnel** — route all outgoing VPS traffic through Cloudflare WARP with `warp` / `warp+doh`
🧭 **WARP protocol picker** — `auto`, `MASQUE`, or `WireGuard`; auto tries MASQUE first, then WireGuard
🔌 **WARP local proxy mode** — still available on `127.0.0.1:40000` for apps that support SOCKS5/HTTP proxy
🔍 **Separate WARP diagnostics** — local proxy test and full tunnel test are checked independently
⏱ **Local Proxy limitation note** — local proxy mode is not ideal for long-running connections
🧬 **Xray user creation in menu 23** — add a VLESS/REALITY user without reinstalling Xray
🔗 **Unified subscription page** — Yurich Proxy + Xray links are generated together for the same user
🛠 **xray-add-user USER** — direct CLI provisioning with config rebuild and subscription page
🤖 **Russian Telegram menu** — persistent reply keyboard for the main admin actions
🧭 **/menu command** — reopen the Telegram button menu at any time
⚡ **Hysteria/WARP buttons** — quick status and WARP proxy test from chat
📱 **Auto QR on add user** — terminal and Telegram creation now generate QR immediately
🔗 **Auto subscription page** — `/s/<token>/` is created when a Naive or Xray user is created
🌀 **Xray via WARP** — when WARP is enabled, Xray uses local WARP HTTP proxy as outbound
🔐 **Safe token generator** — shared random password generator for install, users, Hysteria and bot
🔗 **User subscription pages** — per-user `/s/<token>/` secret URL
🎭 **Private camouflage page** — personal `/p/<token>/` secret URL
🤖 **Telegram bot v2** — `/sub`, `/devices`, `/xray`, `/diagfix`, `/privatepage`
🌀 **Cloudflare WARP proxy mode** — local `127.0.0.1:40000`
🧬 **Xray Modern** — VLESS/Trojan/REALITY + 443 fallback hub
📱 **Device limit** — Yurich Proxy + Xray, up to 5 IPs per user
🛠 **Diagnose --fix** — terminal auto-fix for common issues
⚡ **Hysteria 2** — separate UDP/8443 without conflicting with Caddy
📱 **hy2:// configs** + QR for mobile clients
🤖 **25+ bot commands** + multi-admin
🛡️ **DNS (Unbound)** private recursive Unbound + DNSSEC
🔍 **Diagnostics** — 7 blocks, 18+ checks
🔒 **SSH Hardening** — ED25519, `ssh.socket` fix
🛡️ **Fail2Ban** 3 levels (iptables-multiport)
♻️ **Auto-recovery** — `Restart=on-failure`
🎨 **ASCII banner** + branding
💛 **Donate** via Donation page
🌐 **Private DNS** — no Google/Cloudflare upstream dependency
📦 **Auto-install** dependencies

</td>
</tr>
</table>

[👉 Full Changelog below](#-changelog)

---

## 🤔 What is this and how does it work?

**Yurich Proxy** is the branded proxy transport in Yurich Panel. Today it uses a Naive-compatible transport, so existing clients keep using the standard `naive+https://` URI while Yurich pages can also show a branded `yurich://proxy?...` alias for future Yurich apps.

**Yurich Panel** — a single bash script that turns a bare VPS into a protected proxy server with private DNS and Telegram management.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────────────┐     ┌──────────┐
│   Your      │     │  Censor/DPI  │     │      Your VPS             │     │          │
│   phone     │────▶│              │────▶│  Caddy + Yurich Proxy     │────▶│ Internet │
│   laptop    │     │ Sees Chrome  │     │  DNS / Unbound            │     │          │
└─────────────┘     │  HTTPS/2 ✓   │     │  probe_resistance         │     └──────────┘
  compatible client   └──────────────┘     └───────────────────────────┘
  naive transport       TLS/HTTP stack        DNSSEC + cache
```

### 🎯 Who needs this:

- 🌐 **Bypass blocks** — access to restricted resources
- 🔒 **Privacy** — no one sees your traffic
- 🚫 **Ad-free** — on all devices at once
- 👨‍👩‍👧 **For family** — multiple users, different passwords
- 💼 **For team** — multi-admin, diagnostics, monitoring

---

## ⚡ Quick Start

### 🎬 One command — all set:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/yurich-panel.sh)
```

### 📊 Installation process:

```
[1/5] 🔄  System update                                   ~1 min
         apt upgrade + unattended-upgrades
         → skip: press n

[2/5] 🔒  SSH Hardening                                   ~2 min  [OPTIONAL]
         ED25519 key · auto-save · new user · Fail2Ban
         → skip if SSH already configured: press n

[3/5] 📦  Building Caddy                                  ~5-15 min
         git clone klzgrad/forwardproxy@naive
         xcaddy build with auto version detection

[4/5] ⚙️   Configuration                                   ~1 min
         Caddyfile (:443, domain) · systemd · UFW · BBR · Telegram

[5/5] ✅  Done!
         URI + JSON configs + QR code for phone
```

---

## ✨ Features

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Security

🛡️ **SSH Hardening**
ED25519 key + `sshd_config.d/` support for Ubuntu 22.04+

🔑 **SSH key auto-save**
In `/etc/naiveproxy/ssh_private_key` — download via `scp`

🚫 **Fail2Ban 3 levels**
Bruteforce (7d) · DDoS (7d) · Recidivist (30d)
Uses `iptables-multiport` — faster than UFW

🔥 **UFW + scanner protection**
`deny all incoming` + blocking common scanners

👻 **probe_resistance**
Without login+password looks like a regular website

🎭 **Camouflage page**
Technical blog — for random visitors

🛡️ **Last domain deletion protection**
Script won't let you accidentally kill the server

### 📡 Proxy

🔒 **Auto TLS** — Let's Encrypt via Caddy
🌐 **HTTP/2 + HTTP/3** — explicitly enabled
📱 **QR code** — one scan from phone
👥 **Multi-user** — without restart
🌍 **Multiple domains** — on one server
⚡ **TCP BBR** — optional acceleration
♻️ **Auto-restart** — `Restart=on-failure`

</td>
<td width="50%" valign="top">

### 🛡️ DNS (Unbound)

🧭 **Own recursive resolver**
No Google/Cloudflare upstream dependency

🔐 **DNSSEC validation**
Root hints + package-managed trust anchor

🔒 **VPN-only access**
Localhost and configured VPN CIDRs only

🧯 **No open resolver**
No `0.0.0.0` bind and no public port 53 rule

🧰 **CLI tools**
`yurich-dns-status`, `yurich-dns-test`, `yurich-dns-restart`

### 🤖 Telegram Bot

⚙️ **25+ commands** — full control
👥 **Multi-admin** — multiple administrators
📱 **QR code as image** — right in chat
👤 **User management** — `/adduser`, `/deluser`
🔍 **Diagnostics** — `/diagnose` from chat
📦 **Auto-install** — qrencode, binutils
🚀 **Systemd service** — 24/7 operation

### 🔍 System Diagnostics

🎯 **7 check blocks:**
1. Caddy (status + naive padding)
2. Configuration (Caddyfile)
3. TLS and network (DNS, ports, ALPN)
4. Firewall (UFW, Fail2Ban)
5. Resources (RAM, disk, CPU)
6. Logs (error analysis)
7. Version and updates

✅ **18+ checks** — each marked ✅/⚠️/❌
📱 **Report to Telegram** — one click

</td>
</tr>
</table>

---

## 📋 Requirements

| Parameter | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Ubuntu 20.04 | Ubuntu 22.04 / 24.04 |
| **Rights** | root | root |
| **Domain** | A-record → IP | + Cloudflare DNS |
| **Ports** | 80 + 443 (tcp/udp) | + SSH port |
| **RAM** | 512 MB | 1 GB+ |
| **Disk** | 1 GB | 5 GB+ |
| **CPU** | 1 vCPU | 1 vCPU |
| **Traffic** | from 100 GB/month | unlimited |

---

## 🎮 Main Menu

```
──────────────────────────────────────────────────────
Yurich Panel v5.6.49  [ENG]
   Status: ● running  │  Domain: proxy.example.com
   Telegram: connected  │  Users: 3  │  SSH: 52847
──────────────────────────────────────────────────────
   1)  📦 Install Yurich Proxy      10) 📄 Logs
   2)  📊 Status + certificate      11) 🗑  Remove Yurich Proxy
   3)  📱 Client config + QR        16) 🔍 Diagnostics
   4)  👥 Users                     17) 🛡️ DNS (Unbound)
   5)  🌍 Domains                   18) 💛 Support project
   6)  📈 Monitoring + stats        ──────────────────
   7)  🤖 Telegram + Bot setup      12) 🔒 SSH Hardening
   8)  🔄 Restart Caddy             13) 🔄 Update system
   9)  ⬆️  Update Caddy              14) ⬆️  Update script
                                    15) 🎭 Update camouflage
──────────────────────────────────────────────────────
```

### 📟 All CLI commands:

<details>
<summary><b>Click to see full list (32+ commands)</b></summary>

```bash
# === Main ===
sudo bash yurich-panel.sh install        # Full installation
sudo bash yurich-panel.sh status         # Status + certificate
sudo bash yurich-panel.sh config         # Config + QR code
sudo bash yurich-panel.sh config ivan    # Unique user link
sudo bash yurich-panel.sh qr             # QR code only
sudo bash yurich-panel.sh cert           # Certificate only
sudo bash yurich-panel.sh users          # User management
sudo bash yurich-panel.sh domains        # Domain management
sudo bash yurich-panel.sh monitor        # Monitoring
sudo bash yurich-panel.sh restart        # Restart Caddy
sudo bash yurich-panel.sh update         # Update Caddy
sudo bash yurich-panel.sh logs           # Logs

# === Device limit ===
sudo bash yurich-panel.sh devices        # Anti-sharing menu
sudo bash yurich-panel.sh devices-scan   # Check violations now

# === Xray Modern ===
sudo bash yurich-panel.sh xray           # Xray menu
sudo bash yurich-panel.sh xray-install   # VLESS/Trojan/REALITY + fallback
sudo bash yurich-panel.sh xray-add-user USER 12
sudo bash yurich-panel.sh xray-config    # Show Xray links
sudo bash yurich-panel.sh xray-status    # Xray status
sudo bash yurich-panel.sh xray-remove    # Remove Xray / return Caddy

# === Hysteria 2 ===
sudo bash yurich-panel.sh hysteria       # Hysteria menu
sudo bash yurich-panel.sh hysteria-install
sudo bash yurich-panel.sh hysteria-config USER
sudo bash yurich-panel.sh hysteria-port  # Default UDP/8443 or custom UDP port
sudo bash yurich-panel.sh hysteria-status
sudo bash yurich-panel.sh hysteria-remove

# === Subscriptions and pages ===
sudo bash yurich-panel.sh subscription ivan       # User subscription page
sudo bash yurich-panel.sh subscription-reset ivan # Rotate secret URL
sudo bash yurich-panel.sh private-page            # Private camouflage page
sudo bash yurich-panel.sh private-page reset      # Rotate page secret URL

# === Telegram ===
sudo bash yurich-panel.sh tg-stats       # Stats to Telegram
sudo bash yurich-panel.sh bot            # Run Telegram bot
sudo bash yurich-panel.sh bot-install    # Bot as system service
sudo bash yurich-panel.sh bot-menu       # Refresh Telegram Menu button

# === DNS / Unbound ===
sudo bash yurich-panel.sh dns            # DNS (Unbound) menu
sudo bash yurich-panel.sh dns-install    # Install private recursive DNS
sudo bash yurich-panel.sh dns-vpn        # Configure VPN client access
sudo bash yurich-panel.sh dns-status     # Status, port 53 and DNSSEC tests
sudo bash yurich-panel.sh dns-restart    # Restart Unbound
sudo bash yurich-panel.sh yurich-dns      # Alias for DNS menu
sudo bash yurich-panel.sh yurich-dns-test # Alias for DNS status/test

# === Cloudflare WARP modes ===
sudo bash yurich-panel.sh warp           # WARP menu
sudo bash yurich-panel.sh warp-proxy     # Local proxy mode: 127.0.0.1:40000
sudo bash yurich-panel.sh warp-full      # Full tunnel for all outgoing VPS traffic
sudo bash yurich-panel.sh warp-protocol  # Select auto / MASQUE / WireGuard
sudo bash yurich-panel.sh warp-test      # Test local proxy mode
sudo bash yurich-panel.sh warp-full-test # Test full tunnel mode
sudo bash yurich-panel.sh warp-disable   # Disconnect WARP

# === Diagnostics ===
sudo bash yurich-panel.sh diagnose       # 7-block diagnostics
sudo bash yurich-panel.sh diagnose --fix # Auto-fix common issues

# === SSH ===
sudo bash yurich-panel.sh ssh-hardening  # SSH Hardening
sudo bash yurich-panel.sh ssh-key        # Show SSH key

# === Management ===
sudo bash yurich-panel.sh sysupdate      # Update system
sudo bash yurich-panel.sh self-update    # Update script
sudo bash yurich-panel.sh language       # Switch SSH panel language
sudo bash yurich-panel.sh health         # Full stack health-check
sudo bash yurich-panel.sh safe-apply     # Validate configs and apply safely
sudo bash yurich-panel.sh backup         # Encrypted backup
sudo bash yurich-panel.sh export         # Export users/subscriptions
sudo bash yurich-panel.sh import FILE    # Import users/subscriptions
sudo bash yurich-panel.sh bridge         # Bridge profile builder
sudo bash yurich-panel.sh camouflage     # Reinstall camouflage
sudo bash yurich-panel.sh version        # Version
sudo bash yurich-panel.sh remove         # Remove everything
```

</details>

---

## 🤖 Telegram Bot

Full server management directly from Telegram. Runs 24/7 as system service.

### 🚀 Start:

```bash
# Install as system service (auto-start):
sudo bash yurich-panel.sh bot-install

# Stop:
systemctl stop naiveproxy-bot

# Logs:
journalctl -u naiveproxy-bot -f
```

### 📋 All 25+ commands:

The bot also shows a persistent Russian reply keyboard after `/start`, `/help` or `/menu`: status, users, QR, subscription, Xray, Hysteria, WARP, diagnostics, logs, Caddy restart and auto-fix.

The Telegram `Menu` button is configured automatically through Bot API. If it does not appear immediately, run:

```bash
sudo bash yurich-panel.sh bot-menu
systemctl restart naiveproxy-bot
```

<table>
<tr>
<th width="33%">📊 Information</th>
<th width="33%">👥 Management</th>
<th width="33%">⚙️ Administration</th>
</tr>
<tr>
<td valign="top">

`/help`, `/menu` — List commands + show buttons
`/status` — Status + RAM
`/stats` — Full statistics
`/diagnose` — 7-block diagnostics
`/diagfix` — Auto-fix issues
`/logs` — Last 20 logs
`/cert` — TLS status 🟢/🟡/🔴
`/xraystatus` — Xray status
`/hysteria` — Hysteria 2 status
`/warp` — WARP proxy status + test

</td>
<td valign="top">

`/users` — List users
`/adduser login pass` — Add
`/deluser login` — Remove
`/qr login` — QR code image
`/sub login` — Subscription page
`/subreset login` — Rotate secret URL
`/devices` — Device report
`/lockuser login` — Disable
`/unlockuser login` — Restore
`/xray login` — Xray links
`/xrayadduser login` — Create Xray user + subscription
`/restart` — Restart Caddy
`/update` — Update Caddy

</td>
<td valign="top">

`/admins` — List admins
`/addadmin ID` — Add admin
`/deladmin ID` — Remove admin
`/selfupdate` — Update script
`/privatepage` — Private camouflage page
`/donate` — Support project

</td>
</tr>
</table>

### 🔗 User subscriptions:

```bash
# Create/show user subscription page:
sudo bash yurich-panel.sh subscription ivan

# If the link leaks, rotate the token:
sudo bash yurich-panel.sh subscription-reset ivan
```

The page is created under a secret URL like `https://domain/s/<token>/`, with raw import links available as `links.txt`.
It includes a Yurich Proxy alias, compatible `naive+https://` URI, naive-client JSON, Xray/VLESS/Trojan links and setup hints for Windows, Android, iOS/macOS and Linux.

### 🔐 Multi-admin:

```
/addadmin 987654321   ← add second admin
/admins               ← view list
```

All commands protected — outsiders get `⛔ Access denied`.

---

## 🛡️ DNS (Unbound)

DNS (Unbound) is a private Unbound resolver for VPN clients. It resolves domains recursively on your server, validates DNSSEC and does not depend on Google DNS or Cloudflare DNS.

It is designed to be safe by default:

- listens on `127.0.0.1` and an optional VPN gateway IP only
- never binds to `0.0.0.0`
- allows DNS only from localhost and configured VPN CIDRs
- opens UFW port `53` only for those CIDRs
- can create a local `10.0.0.1/32` gateway on `lo` when the IP does not exist yet
- does not log every DNS request by default
- does not use adblock blocklists in the main manager anymore

### ⚡ Install:

```bash
sudo bash yurich-panel.sh dns-install
```

### 🔍 How it works:

```
VPN client → VPN tunnel → 10.0.0.1:53 → Unbound
                                      │
                                      ├─ recursive DNS lookup
                                      ├─ DNSSEC validation
                                      └─ cached answers
```

### 🛠️ Commands:

```bash
sudo bash yurich-panel.sh dns-install    # Install / reinstall DNS (Unbound)
sudo bash yurich-panel.sh dns-vpn        # Configure DNS for VPN clients
sudo bash yurich-panel.sh dns-status     # Status, port 53 and DNSSEC tests
sudo bash yurich-panel.sh dns-restart    # Restart Unbound
sudo bash yurich-panel.sh dns-remove     # Remove created DNS config and commands
```

The standalone project is also included in [`yurich-dns/`](yurich-dns/):

```bash
sudo bash yurich-dns/install-dns.sh
yurich-dns-status
yurich-dns-test
sudo yurich-dns-restart
```

### 🔒 Open resolver protection:

Do not enter any `/0` network as a VPN CIDR. The installer rejects it. Use only your real tunnel network, for example `10.0.0.0/24`.

If port `53` is busy by `systemd-resolved`, the installer disables only the local stub listener through `/etc/systemd/resolved.conf.d/no-stub.conf`. It does not rewrite `/etc/resolv.conf` unless Ubuntu already manages it.

Full sing-box Android VPN/TUN examples generated by the manager automatically include DNS (Unbound) when VPN DNS is enabled.

---

## 🌀 Cloudflare WARP Modes

Menu `21` now supports two WARP modes:

| Mode | Best for | Notes |
|------|----------|-------|
| `proxy` | Specific apps that can use SOCKS5/HTTP proxy | Listens on `127.0.0.1:40000`; best for explicitly configured apps, not long-running server-wide traffic |
| `warp` / `warp+doh` | All outgoing VPS traffic | Full tunnel mode; useful when apps cannot be configured with a proxy manually |

### Commands:

```bash
sudo bash yurich-panel.sh warp           # WARP menu
sudo bash yurich-panel.sh warp-proxy     # Local proxy mode
sudo bash yurich-panel.sh warp-full      # Full tunnel mode
sudo bash yurich-panel.sh warp-protocol  # auto / MASQUE / WireGuard
sudo bash yurich-panel.sh warp-full-test # Verify full tunnel output
sudo bash yurich-panel.sh warp-disable   # Rollback / disconnect
```

In proxy mode Xray can use `127.0.0.1:40000` as outbound. In full tunnel mode Xray and regular server processes use the system route automatically. For Russia and unstable networks, `auto` tries MASQUE first, then WireGuard.

---

## 🔍 Diagnostics

```bash
sudo bash yurich-panel.sh diagnose
```

### 📊 Example output:

```
┌─────────────────────────────────────────────────────────┐
│  🔍 Diagnostics Yurich Panel v5.6.49              │
│  2026-05-23 14:32:18 · proxy.example.com               │
└─────────────────────────────────────────────────────────┘

[1/7] Caddy
  ✅ Caddy found: v2.8.4
  ✅ Caddy running (since 2026-05-22 03:15)
  ✅ Naive padding module confirmed (5 symbols)
  ✅ forward_proxy module loaded

[2/7] Configuration
  ✅ Caddyfile found: /etc/caddy/Caddyfile
  ✅ Correct format ':443, domain'
  ✅ order forward_proxy — OK
  ✅ probe_resistance enabled
  ✅ Users: 4
  ✅ Caddyfile valid

[3/7] TLS and network
  ✅ DNS: proxy.example.com → 78.17.134.110
  ✅ Port 80 listening (ACME)
  ✅ Port 443 listening
  ✅ ALPN: h2 ✓ (HTTP/2 working)
  ✅ TLS certificate valid for 83 more days

[4/7] Firewall
  ✅ UFW active (12 rules)
  ✅ Fail2Ban running (47 bans)

[5/7] System resources
  ✅ RAM: 367/1967 MB (18%)
  ✅ Disk: 5.8G/15G (42%)
  ✅ CPU: 0.19 (19% of 1 core)

[6/7] Log analysis
  ✅ No server errors (last 100 requests)
  ℹ️  CONNECT tunnels: 96
  ✅ journald: no critical errors

[7/7] Version and updates
✅ Script up to date: v5.6.49
  ✅ SSH Hardening done

══════════════════════════════════════════════════════════
  📊 DIAGNOSTICS SUMMARY
══════════════════════════════════════════════════════════
  ✅ Passed:   18
  ⚠️  Warnings: 0
  ❌ Problems: 0

  🎉 Everything works great!
══════════════════════════════════════════════════════════
```

---

## ⚠️ Caddyfile — critical

```bash
# ❌ WRONG — clients won't connect:
your-domain.com:443 { ... }

# ✅ CORRECT — :443 + servers block required:
{
    order forward_proxy before file_server
    servers :443 {
        protocols h1 h2 h3
    }
}

:443, your-domain.com {
    tls your@email.com
    forward_proxy {
        basic_auth USERNAME PASSWORD
        hide_ip
        hide_via
        probe_resistance
    }
    file_server { root /var/www/html }
}
```

---

## 🔒 SSH Hardening

```bash
sudo bash yurich-panel.sh ssh-hardening
```

> 💡 **Can be skipped** by pressing `n` during installation.

### 🛡️ 5 protection steps:

1. **New sudo user** — root isolated
2. **ED25519 key** — modern cryptography + auto-save
3. **SSH port change** — protection from automatic bots
4. **sshd_config + sshd_config.d/** — Ubuntu 22.04+ support
5. **UFW + Fail2Ban** — bruteforce protection

### 🔑 Download SSH key:

```bash
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy
chmod 600 ~/.ssh/id_naiveproxy
ssh -i ~/.ssh/id_naiveproxy -p NEW_PORT user@YOUR_IP
```

### 🚨 Fail2Ban 3 levels:

| Level | Trigger | Ban | Uses |
|-------|---------|-----|------|
| 🔴 **Bruteforce** | 3 wrong passwords | **7 days** | iptables-multiport |
| 🟡 **DDoS** | 10 attempts in 1 min | **7 days** | iptables-multiport |
| ⚫ **Recidivist** | Repeated violations | **30 days** | recidive jail |

---

## 📱 Client Apps

### 🔗 Yurich Proxy alias for future Yurich clients:

```
yurich://proxy?transport=naive&server=YOUR_DOMAIN&port=443&username=USERNAME&password=PASSWORD
```

### 🔗 Compatible URI for current clients:

```
naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

### 📋 JSON for naive-client:

```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://USERNAME:PASSWORD@YOUR_DOMAIN:443",
  "log": "naive.log"
}
```

### 📲 Best clients:

<table>
<tr>
<th>📱 Platform</th>
<th>🥇 Recommended</th>
<th>🥈 Alternative</th>
</tr>
<tr>
<td><strong>Android</strong></td>
<td>

[**NekoBox**](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) ⭐
Free · Open Source

</td>
<td>

[Hiddify](https://github.com/hiddify/hiddify-next/releases)
Easier for beginners

</td>
</tr>
<tr>
<td><strong>iOS / iPhone</strong></td>
<td>

[**Hiddify**](https://apps.apple.com/app/hiddify-proxy-vpn/id6596777532) ⭐
Free in App Store

</td>
<td>

[Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) ($2.99)
Paid, but top tier

</td>
</tr>
<tr>
<td><strong>Windows</strong></td>
<td>

[**Hiddify Next**](https://github.com/hiddify/hiddify-next/releases) ⭐
GUI, easy to setup

</td>
<td>

[NekoRay](https://github.com/MatsuriDayo/nekoray/releases)
Advanced GUI

</td>
</tr>
<tr>
<td><strong>macOS</strong></td>
<td>

[**Hiddify Next**](https://github.com/hiddify/hiddify-next/releases) ⭐
Free

</td>
<td>

[V2BoX](https://apps.apple.com/app/v2box-v2ray-client/id6446814690)
In App Store

</td>
</tr>
<tr>
<td><strong>Linux</strong></td>
<td>

[**NekoRay**](https://github.com/MatsuriDayo/nekoray/releases) ⭐
Qt GUI

</td>
<td>

[naive](https://github.com/klzgrad/naiveproxy/releases) CLI
For servers

</td>
</tr>
</table>

> ⚠️ **v2rayNG does not support Yurich Proxy/native naive transport.** Use NekoBox or Hiddify.

---

## 📁 File Structure

<details>
<summary><b>Click to see full structure</b></summary>

```
/usr/local/bin/caddy                           ← Caddy binary with naive
/etc/caddy/Caddyfile                           (chmod 600)
/etc/naiveproxy/
├── naive.conf                                 ← Main config (chmod 600)
├── users.conf                                 ← Users (chmod 600)
├── ssh_private_key                            ← SSH key ED25519
├── ssh_public_key
├── monitor.sh
├── .ssh_hardened                              ← SSH hardening marker
├── .sysupdate_done
└── backups/                                   ← Config backups

/etc/unbound/
└── unbound.conf.d/yurich-dns.conf              ← DNS (Unbound) config

/usr/local/bin/
├── yurich-dns-status                           ← DNS status and logs
├── yurich-dns-test                             ← DNSSEC and resolve tests
└── yurich-dns-restart                          ← Safe Unbound restart

/etc/fail2ban/jail.local                       ← Fail2Ban rules

/etc/systemd/system/
├── caddy.service                              ← Caddy with Restart=on-failure
└── naiveproxy-bot.service                     ← Telegram bot 24/7

/var/www/html/index.html                       ← Camouflage page

/var/log/caddy/
├── access.log                                 ← All requests
└── naive.log                                  ← CONNECT tunnels

/usr/local/bin/yurich-panel.sh                   ← The script itself
```

</details>

---

## ❓ FAQ

### 🚀 Installation and basic setup

<details>
<summary><b>Which VPS to buy? Minimum requirements</b></summary>

**Minimum for operation:**
- 512 MB RAM, 1 vCPU, 10 GB disk
- Any provider with Ubuntu 20.04+

**Recommended providers:**
- **Hetzner** — Germany, very fast (from €4/month)
- **DigitalOcean** — Netherlands, USA (from $4/month)
- **Vultr** — many locations (from $2.50/month)
- **Linode** — reliable

</details>

<details>
<summary><b>Which domain to buy and where?</b></summary>

**Any domain works:**
- `.com`, `.net`, `.org` — standard
- `.io`, `.dev`, `.tech` — trendy
- `.xyz`, `.online`, `.site` — cheap

**Where to buy:**
- **Namecheap** — `.com` from $10/year
- **Cloudflare Registrar** — at cost
- **Porkbun** — cheap

**Important — set up A-record:**
```
your-domain.com → SERVER_IP
```

</details>

<details>
<summary><b>Installation fails at Caddy build stage</b></summary>

```bash
# Check free RAM (need 512 MB+)
free -h

# If low — add swap
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Run install again
sudo bash /usr/local/bin/yurich-panel.sh install
```

</details>

<details>
<summary><b>How to update script to latest version</b></summary>

```bash
# Method 1 — from menu
sudo bash /usr/local/bin/yurich-panel.sh
# → Option 14) Update script

# Method 2 — one command
curl -fsSL https://raw.githubusercontent.com/ivan-yurich/naiveproxy/main/yurich-panel.sh \
  -o /usr/local/bin/yurich-panel.sh && chmod +x /usr/local/bin/yurich-panel.sh
```

</details>

### 🔌 Client connection

<details>
<summary><b>Client won't connect — what to do?</b></summary>

**Step-by-step diagnostics:**

```bash
# 1. Run full diagnostics
sudo bash yurich-panel.sh diagnose

# 2. Check Caddyfile
cat /etc/caddy/Caddyfile | grep ":443"
# Should be: :443, your-domain.com {

# 3. Check ALPN (should be h2)
echo | openssl s_client -connect YOUR_DOMAIN:443 -alpn h2 -servername YOUR_DOMAIN 2>/dev/null | grep -a "ALPN protocol"

# 4. Check port is open
ss -tlnp | grep :443

# 5. Check logs
journalctl -u caddy -n 30 --no-pager
```

</details>

<details>
<summary><b>Free iPhone app?</b></summary>

**Free options:**

1. **Hiddify** ⭐ — best free, in App Store
2. **FoXray** — free, partial support
3. **Streisand** — free

**How to connect:**
1. Copy the compatible URI: `naive+https://user:pass@domain:443`
2. Open Hiddify → Import from clipboard

</details>

<details>
<summary><b>App for Windows / Mac?</b></summary>

**Windows:**
- **Hiddify Next** — UI client, easy setup
- **NekoRay** — advanced GUI

**macOS:**
- **Hiddify Next** — recommended
- **V2BoX** — in App Store

**Linux:**
- **NekoRay** — Qt GUI
- **naive** CLI — for servers

</details>

### 🤖 Telegram Bot

<details>
<summary><b>Telegram bot doesn't respond to commands</b></summary>

```bash
# 1. Check status
systemctl status naiveproxy-bot

# 2. View logs
journalctl -u naiveproxy-bot -n 30 --no-pager

# 3. Restart
systemctl restart naiveproxy-bot

# 4. If doesn't help — reinstall
sudo bash yurich-panel.sh bot-install
```

</details>

<details>
<summary><b>How to get Telegram bot token?</b></summary>

1. Open [@BotFather](https://t.me/BotFather) in Telegram
2. Send `/newbot`
3. Enter bot name
4. Enter username (must end with `bot`)
5. Copy token like `123456789:ABCdefGHIjkl`

Enter token in script:
```bash
sudo bash yurich-panel.sh
# → 7) Telegram + Bot setup
```

</details>

<details>
<summary><b>How to find my Telegram Chat ID?</b></summary>

**Method 1 — via bot:**
1. Send any message to your bot
2. Open: `https://api.telegram.org/botYOUR_TOKEN/getUpdates`
3. Find `"chat":{"id":12345}` — that's your ID

**Method 2 — via @userinfobot:**
1. Message [@userinfobot](https://t.me/userinfobot)
2. It will show your ID

</details>

### 🛡️ DNS (Unbound)

<details>
<summary><b>DNS does not answer for VPN clients — how to check</b></summary>

```bash
# Check Unbound, port 53 and DNSSEC
sudo bash yurich-panel.sh dns-status
yurich-dns-test

# Reconfigure VPN client access
sudo bash yurich-panel.sh dns-vpn

# Restart safely
sudo bash yurich-panel.sh dns-restart
```

Make sure the configured gateway IP exists on the server interface and the VPN CIDR matches your real tunnel network.

</details>

<details>
<summary><b>Can DNS (Unbound) block ads?</b></summary>

The main manager no longer ships DNS adblock lists. DNS (Unbound) is focused on a safe private recursive resolver for VPN clients.

This avoids the previous startup problems caused by legacy blocklist/trust-anchor combinations and keeps the DNS role clean.

</details>

### 🔒 SSH Hardening

<details>
<summary><b>Locked myself out after SSH hardening</b></summary>

**Access only via hosting VNC/KVM console:**

```bash
# 1. Open VNC/KVM in hoster panel
# 2. Execute:
ufw allow 22/tcp
systemctl restart sshd

# 3. Now login via SSH on standard port 22
```

</details>

<details>
<summary><b>Fail2Ban banned me — how to unban</b></summary>

```bash
# View who's banned
fail2ban-client status sshd

# Unban your IP
fail2ban-client unban YOUR_IP

# Unban all
fail2ban-client unban --all
```

</details>

### 🔧 Server management

<details>
<summary><b>Caddy won't start — what to do</b></summary>

```bash
# 1. Validate config
caddy validate --config /etc/caddy/Caddyfile

# 2. View logs
journalctl -u caddy -n 50 --no-pager

# 3. Common causes:
# - Ports 80/443 occupied (apache2, nginx)
# - No permissions on /var/log/caddy
# - DNS not configured
```

</details>

<details>
<summary><b>How to backup and restore</b></summary>

```bash
# Create backup
tar -czf naiveproxy-backup-$(date +%Y%m%d).tar.gz \
  /etc/caddy/Caddyfile \
  /etc/naiveproxy/

# Download
scp root@YOUR_IP:~/naiveproxy-backup-*.tar.gz ~/Downloads/

# Restore
sudo bash yurich-panel.sh install
tar -xzf naiveproxy-backup.tar.gz -C /
systemctl restart caddy
```

</details>

<details>
<summary><b>How to completely remove Yurich Proxy</b></summary>

```bash
sudo bash yurich-panel.sh remove
# Removes: Caddy, configs, logs, systemd services

# Additional cleanup:
apt remove --purge -y caddy fail2ban unbound
rm -rf /etc/caddy /etc/naiveproxy /etc/unbound
```

</details>

---

## 📊 Comparison with alternatives

<table>
<tr>
<th>Feature</th>
<th align="center">🥇 Yurich Panel</th>
<th align="center">x-ui / 3x-ui</th>
<th align="center">Marzban</th>
</tr>
<tr><td>No Docker</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>SSH Hardening + sshd_config.d/</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>SSH key auto-save</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>QR code</td><td align="center">✅</td><td align="center">❌</td><td align="center">⚠️</td></tr>
<tr><td><strong>Private Unbound DNS</strong></td><td align="center">✅ DNSSEC</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td><strong>Telegram bot with commands</strong></td><td align="center">✅ 25+ cmds</td><td align="center">⚠️ basic</td><td align="center">⚠️ basic</td></tr>
<tr><td>System diagnostics (7 blocks)</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Fail2Ban 3 levels</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Camouflage page</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Self-Update</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Last domain protection</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Auto-restart on failure</td><td align="center">✅</td><td align="center">❌</td><td align="center">❌</td></tr>
<tr><td>Correct Caddyfile</td><td align="center">✅</td><td align="center">—</td><td align="center">—</td></tr>
<tr><td>ShellCheck passing</td><td align="center">✅</td><td align="center">—</td><td align="center">—</td></tr>
</table>

---

## 💛 Support the Project

<div align="center">

### If this script helped you — support development! 🙏

[![Donate](https://img.shields.io/badge/💛_Donation page-Any_amount-FF5E3A?style=for-the-badge&logoColor=white)](https://example.com/donate)

**👉 https://example.com/donate**

</div>

### 🎯 What your donation will fund:

<table>
<tr>
<td align="center" width="20%">

🚀
**More time**
on development

</td>
<td align="center" width="20%">

🐛
**Quick fixes**
for bugs

</td>
<td align="center" width="20%">

✨
**New features**
every month

</td>
<td align="center" width="20%">

📚
**Documentation**
and support

</td>
<td align="center" width="20%">

🆕
**Exclusive**
for donors

</td>
</tr>
</table>

### 🤝 All ways to support:

| Way | Link | What it gives |
|-----|------|---------------|
| 💛 **Donate** | [Donation page](https://example.com/donate) | Financial support |
| ⭐ **GitHub Star** | [Give a star](https://github.com/ivan-yurich/naiveproxy) | Project visibility |
| 📱 **Telegram channel** | [@your_channel](https://t.me/your_channel) | Subscribe for updates |
| 🌐 **Website** | [example.com](https://example.com) | Visit |
| 📢 **Share** | — | Tell your friends |
| 🐛 **Report bug** | [Issues](https://github.com/ivan-yurich/naiveproxy/issues) | Help improve |
| 💡 **Suggest idea** | [Telegram](https://t.me/your_channel) | Grow the project |

**Thanks for your support! Every donation motivates me to make the project even better 💛**

---

## 📜 Changelog

<details open>
<summary><b>v5.6.49</b> — GitHub-ready public release ← CURRENT</summary>

**Repository preparation:**
- Removed or replaced personal domains, IP addresses, Telegram IDs, tokens, private links, local paths and private support/payment data
- Added `SECURITY.md`, `.gitignore`, `.gitattributes` and detailed release notes
- Expanded `MULTISERVER_GUIDE_RU.md` with production rollout, HAProxy/SNI mux, WARP, node updates, profile checks and node removal notes
- Documented `protocol-validate`, `protocol-benchmark` and `protocol-benchmark-monitor`
- Clarified slow benchmark detection: median/p95/slow_count instead of a single noisy measurement
- Kept compatibility: `yurich-panel.sh` is the main script and `naiveproxy.sh` remains a compatible alias

</details>

<details>
<summary><b>v5.6.34</b> — Multi-server node management</summary>

**Multi-server nodes:**
- Added `29) [NODES] Multi-server management`
- Added root-only `/etc/naiveproxy/nodes.conf`
- Added node SSH/status checks
- Added script deploy to node
- Added user sync to one node or all enabled nodes
- Added remote backup + `safe-apply`
- Added `hysteria-sync` and `xray-rebuild`
- Subscription pages can include extra node links

</details>

<details>
<summary><b>v5.6.12</b> — Subscription app links and contacts</summary>

**Subscription pages:**
- Added Yurich Connect Android release link
- Added Yurich Connect Windows release link
- Added Telegram, VK and email contact buttons
- Windows/Android setup cards now point to official client releases

</details>

<details>
<summary><b>v5.6.11</b> — REALITY target presets and TLS check</summary>

**Xray REALITY:**
- Added RU/Global candidate list for REALITY target selection
- The selected target is checked through TLS/SNI from the server before applying
- Added Xray menu action: `REALITY target presets / test`
- Added CLI command: `xray-target`
- The current REALITY target is now visible in the Xray menu

</details>

<details>
<summary><b>v5.6.10</b> — XHTTP standalone transport</summary>

**Xray Modern:**
- Added VLESS XHTTP TLS standalone inbound on `8448/tcp`
- XHTTP now works without enabling the 443 fallback hub
- Subscription pages and `links.txt` include XHTTP automatically
- UFW, status, diagnostics and uninstall now handle `8448/tcp`
- XHTTP on `443` remains available when fallback hub is enabled

</details>

<details>
<summary><b>v5.6.9</b> — Installer subscription prompt hotfix</summary>

**Installer:**
- Fixed the apparent install hang right after `Generated password`
- The `1-12 months` subscription term prompt is now printed to `/dev/tty`
- Error messages from the term prompt are sent to stderr instead of being captured by command substitution
- On old `v5.6.8`, pressing `Enter` at the blank cursor continues with the default `12` months

</details>

<details>
<summary><b>v5.6.8</b> — Terminal-safe SSH panel</summary>

**Terminal UI:**
- Replaced emoji icons in the SSH panel with ASCII labels
- Main menu now uses labels such as `[DNS]`, `[WARP]`, `[XRAY]`, `[DIAG]`
- Diagnostics now use `[OK]`, `[WARN]`, `[FAIL]`
- DNS and donate terminal screens no longer depend on emoji fonts

**🌀 WARP routing:**

**🌀 WARP routing:**
- WARP proxy mode now regenerates Caddy with `forward_proxy upstream socks5://127.0.0.1:40000`
- Hysteria 2 can now exit through WARP local proxy using server `outbounds`
- Xray WARP outbound now uses SOCKS instead of HTTP and has an explicit routing rule
- Caddy, Xray and Hysteria are refreshed automatically after WARP mode changes
- Added `warp-ssh-allow` to store extra home/mobile SSH CIDR exclusions
- Full-tunnel WARP asks for extra SSH IP/CIDR before enabling
- Xray REALITY key parsing is more robust across `xray x25519` output variants

**🛡️ Firewall and bans:**
- Fail2Ban can now be configured without running SSH Hardening
- The installer offers SSH + Caddy/Yurich Proxy auth protection during normal setup
- Added `yurich-caddy-auth` jail for Caddy JSON access logs with `401/407` responses
- Added `fail2ban` CLI command and a Production tools action to refresh Fail2Ban
- `80/tcp` now uses a real `ufw limit` rule instead of a duplicate `allow`
- `health` now checks UFW, SSH/80/443, Hysteria, Xray, DNS 53, and Fail2Ban jails

</details>

<details>
<summary><b>v5.6.5</b> — Yurich DNS branding and compatibility</summary>

**🛡️ Yurich DNS branding:**
- Renamed the DNS module to `Yurich DNS`
- Renamed the standalone project to `yurich-dns/`
- Primary DNS commands are now `yurich-dns-status`, `yurich-dns-test`, `yurich-dns-restart`
- Unbound config is now written to `/etc/unbound/unbound.conf.d/yurich-dns.conf`
- Old DNS command aliases are kept only for compatibility

**🧭 Yurich Proxy branding:**
- Added public transport brand `Yurich Proxy`
- Kept the technical `naive+https://` URI unchanged for compatibility with current clients
- Added branded `yurich://proxy?...` alias in CLI output, Telegram `/adduser`/`/qr`, and subscription pages
- Kept `links.txt` as a clean compatible import file without the experimental `yurich://` alias
- Subscription pages now show a dedicated `Yurich Proxy` card

</details>

<details>
<summary><b>v5.6.3</b> — Yurich Panel branding</summary>

**🧭 Brand refresh:**
- Simplified the public product name to `Yurich Panel`
- Renamed the main script to `yurich-panel.sh`
- Kept `naiveproxy.sh` in the repository and on installed servers as a compatibility alias
- Self-update now downloads `yurich-panel.sh` and verifies `yurich-panel.sh.sha256`
- Removed the separate sub-brand architecture from the README
- Kept terminal UI, Telegram messages, subscription pages, DNS module text and documentation aligned with `Yurich Panel`
- Kept technical names like `NaiveProxy`, `Xray`, `Hysteria 2`, `Caddy` and `Unbound` where they describe actual protocols/components
- Kept self-update compatibility for older releases

**🌐 SSH panel language:**
- Added Russian / English language selector for the terminal panel
- Added `language` CLI command and menu item `28`
- Selected language is stored in `/etc/naiveproxy/naive.conf`
- Main SSH panel labels, statuses and menu items are translated
- Project license changed to `PolyForm Noncommercial 1.0.0 + Commercial License`

</details>

<details>
<summary><b>v5.6.0</b> — Production tools, safe apply and expiring subscriptions</summary>

**🧰 Production operations:**
- Added SHA256 verification for `self-update` through `yurich-panel.sh.sha256`
- Added pinned defaults for `xcaddy`, `forwardproxy`, Xray and Hysteria releases
- Added `health` for one-shot Caddy + DNS + Telegram bot + WARP + Xray + Hysteria checks
- Added `safe-apply` with config validation and Caddyfile rollback
- Added encrypted backup, export/import for users and subscriptions
- Added user terms from 1 to 12 months and expiration labels on subscription pages
- Added production menu and bridge profile builder

</details>

<details>
<summary><b>v5.5.15</b> — DNS safety and watchdog hardening</summary>

**🛡️ Hardening fixes:**
- Rejects every VPN DNS CIDR with mask `/0`, not only the literal `0.0.0.0/0`
- Standalone DNS (Unbound) status/uninstall scripts source env only when it is root-owned and locked down
- Generated watchdog Telegram sender now uses `--data-urlencode`
- `bot-install` syncs the current valid script into `/usr/local/bin/yurich-panel.sh`

</details>

<details>
<summary><b>v5.5.14</b> — Telegram bot polling and service startup</summary>

**🤖 Telegram bot runtime:**
- Fixed Telegram long polling: `allowed_updates` is now sent as a JSON array
- Telegram setup can install and start `naiveproxy-bot.service` immediately
- `bot-install` checks `/usr/local/bin/yurich-panel.sh` and restores it before writing the systemd unit
- `/start`, `/help` and `/menu` are now documented as requiring the running bot service

</details>

<details>
<summary><b>v5.5.13</b> — Telegram Menu button commands</summary>

**🧭 Telegram bot UX:**
- Added Bot API `setMyCommands` for the Telegram `Menu` command list
- Added `setChatMenuButton` so Telegram shows the command menu button
- Added `bot-menu` CLI command to refresh the menu manually
- Bot applies the command menu during `bot-install` and service startup
- `/start`, `/help` and `/menu` still show the persistent Russian quick-action keyboard

</details>

<details>
<summary><b>v5.5.12</b> — DNS (Unbound) auto gateway for VPN clients</summary>

**🌉 Client DNS gateway:**
- Added `yurich-dns-gateway.service` for a safe local `10.0.0.1/32` gateway on `lo`
- Menu `17 → 2` can now create the gateway automatically when the IP is missing
- Full sing-box Android VPN/TUN examples include DNS (Unbound) through `tcp://10.0.0.1:53`
- Personal subscription pages now show the ready sing-box TUN config with DNS (Unbound)

</details>

<details>
<summary><b>v5.5.11</b> — DNS (Unbound) without legacy adblock</summary>

**🛡️ DNS (Unbound):**
- Replaced the old DNS adblock module with a safer private Unbound resolver
- Added standalone `yurich-dns/` project with install, uninstall, examples and CLI tools
- Removed blocklist/whitelist generation from the main manager
- Fixed duplicate DNSSEC trust-anchor startup failures on Ubuntu packages
- Added safe `systemd-resolved` stub handling through `resolved.conf.d/no-stub.conf`
- Port 53 is opened only for configured VPN CIDRs, never for the public internet
- Added `dns-restart`, `yurich-dns`, `yurich-dns-test` aliases
- Added `yurich-dns-gateway.service` to create a safe local client DNS gateway when needed

</details>

<details>
<summary><b>v5.5.10</b> — Unbound VPN DNS bind fix</summary>

**🛠️ DNS bind fix:**
- Fixed Unbound startup when VPN DNS access is enabled
- Removed `0.0.0.0:53` bind to avoid conflicts with `systemd-resolved`
- VPN DNS now binds concrete server/VPN IPv4 interface addresses only
- DNS menu now shows `installed, not running` when the package exists but the service failed
- Unbound restart now runs `systemctl reset-failed` to recover from the previous start-limit state
- Reduced `so-rcvbuf` to avoid noisy warnings on stock Ubuntu kernels

</details>

<details>
<summary><b>v5.5.9</b> — Recursive Unbound DNS + VPN DNS Access</summary>

**🧭 DNS resolver modes:**
- Added recursive Unbound mode without Google/Cloudflare upstreams
- Added mode selection: recursive/forward DoT with adblock on/off
- Added DNSSEC trust anchor and status test
- Added VPN-only DNS access through CIDR allowlist
- Added `unbound-mode` and `unbound-vpn` CLI commands
- Unbound now listens locally on `127.0.0.1:53` and `127.0.0.1:5335`

</details>

<details>
<summary><b>v5.5.8</b> — Unbound Plugin + Per-user Hysteria + SSH-safe WARP</summary>

**🧩 Modules and safety:**
- Added `unbound`, `unbound-install`, `unbound-status`, `unbound-update` aliases
- Hysteria 2 now uses `userpass` auth for Yurich Proxy users
- Hysteria 2 install now lets you choose default UDP/8443 or a custom UDP port
- New users automatically get personal Hysteria 2 links and QR when Hysteria is installed
- Subscription pages now include Hysteria 2 URI and sing-box outbound
- WARP full tunnel now adds SSH split-tunnel exclusions and a rollback timer before connecting

</details>

<details>
<summary><b>v5.5.7</b> — WARP Full Tunnel Modes</summary>

**🌀 Cloudflare WARP modes:**
- Added full tunnel mode for all outgoing VPS traffic: `warp` / `warp+doh`
- Added `warp-full`, `warp-protocol` and `warp-full-test` CLI commands
- Menu 21 now separates local proxy mode and full tunnel mode
- Added protocol selection: `auto`, `MASQUE`, `WireGuard`
- Diagnostics now checks proxy mode and full tunnel mode separately
- Documented Cloudflare Local Proxy limitations for long-running connections

</details>

<details>
<summary><b>v5.5.6</b> — Xray User Provisioning</summary>

**🧬 Xray users and subscriptions:**
- Added menu 23 option to create an Xray user without reinstalling Xray
- Added `xray-add-user USER` CLI command
- Adding a Yurich Proxy user can also create the matching Xray/VLESS profile
- Personal `/s/<token>/` pages now combine Naive and Xray links for the same user
- Telegram `/adduser` can provision Xray too when Xray is active
- Added Telegram `/xrayadduser USER`

</details>

<details>
<summary><b>v5.5.5</b> — Russian Telegram Button Menu</summary>

**🤖 Telegram UX:**
- Added a persistent Russian reply keyboard for common admin actions
- Added `/menu` to reopen the keyboard
- Bot now accepts button text messages, not only slash commands
- Added Telegram `/hysteria` and `/warp` quick status commands
- Unknown commands return the keyboard menu

</details>

<details>
<summary><b>v5.5.4</b> — Auto QR + Subscription Pages</summary>

**📱 User provisioning:**
- Adding a Yurich Proxy user now prints URI, JSON and QR immediately
- A `/s/<token>/` subscription page is created automatically for new Naive and Xray users
- Telegram `/adduser` sends URI, QR image and the subscription page URL
- Telegram `/deluser` removes the user and cleans the subscription page
- User deletion removes the subscription token file and static web directory

</details>

<details>
<summary><b>v5.5.3</b> — Hysteria PSK + Xray mKCP Compatibility</summary>

**⚡ Hysteria 2 and Xray mKCP:**
- Added Hysteria password and obfs password validation before writing `hysteria.yaml`
- Empty or too short `obfs.salamander.password` is regenerated automatically
- Hysteria passwords are written as quoted YAML strings
- Xray mKCP no longer uses removed legacy `header` / `seed` fields
- mKCP client links now use `type=mkcp` without `headerType`

</details>

<details>
<summary><b>v5.5.2</b> — Hysteria Passwords + WARP Verification</summary>

**⚡ Hysteria 2 and WARP:**
- Fixed Hysteria 2 random password generation under `set -euo pipefail`
- Added a shared safe token generator for auto-created passwords
- WARP verification now tries HTTP proxy first, then SOCKS5 fallback
- WARP install now requires confirmed `warp=on`
- Xray uses the local WARP HTTP proxy as outbound when WARP is enabled

</details>

<details>
<summary><b>v5.5.1</b> — Xray REALITY Key Parsing</summary>

**🧬 Xray REALITY:**
- Fixed REALITY key parsing for newer Xray builds
- `xray x25519` output now supports both `Public key` and `Password`
- Added a manual check hint when key generation fails

</details>

<details>
<summary><b>v5.5.0</b> — Telegram v2 + User Subscriptions</summary>

**🔗 Subscriptions and Telegram:**
- Per-user subscription page: `subscription USER`
- Secret URL `/s/<token>/`, not a plain login-based path
- `links.txt` for client import and HTML setup page for Windows/Android/iOS/macOS/Linux
- Token rotation: `subscription-reset USER`
- Private camouflage page under `/p/<token>/`
- Telegram commands: `/sub`, `/subreset`, `/devices`, `/lockuser`, `/unlockuser`, `/xray`, `/xraystatus`, `/diagfix`, `/privatepage`
- `diagnose --fix` restores privacy files for `/s/` and `/p/`

</details>

<details>
<summary><b>v5.4.0</b> — Device Limit + Diagnose Fix</summary>

**📱 Device limit and auto-fix:**
- Device limit now reads both Caddy/Naive and Xray access logs
- `lock-user` disables the user in Naive and Xray when the login exists in both
- `devices-unlock` restores the user in both subsystems
- Added `diagnose --fix` for terminal auto-fix of common issues
- Auto-fix repairs config permissions, Caddyfile, services, UFW ports, device-limit cron and Xray restart

</details>

<details>
<summary><b>v5.3.0</b> — Xray Modern Transports</summary>

**🧬 Xray VLESS/Trojan/REALITY:**
- Added a dedicated Xray-core module
- VLESS TCP TLS + XTLS Vision support
- VLESS REALITY TCP support
- mKCP, WebSocket, gRPC, HTTPUpgrade and XHTTP support
- Trojan WebSocket through fallback
- Optional `443` fallback hub: Xray listens on 443 while Caddy/Yurich Proxy moves to a local fallback port
- `xray-remove` returns Caddy back to 443

</details>

<details>
<summary><b>v5.2.0</b> — Device Limit / Anti-sharing</summary>

**📱 Unique links and device limit:**
- Client config can be printed for a specific user: `config USER`
- Added a unique-IP limit per user over a time window
- Default policy is designed around `5` IPs over `24` hours
- Modes: `alert` and `lock-user`
- Automatic scan via cron every 15 minutes
- Open-proxy protection: Caddyfile generation refuses zero active users

</details>

<details>
<summary><b>v5.1.0</b> — WARP Proxy Mode</summary>

**🌀 Cloudflare WARP in safe proxy mode:**
- WARP runs as a local proxy on `127.0.0.1:40000`
- The VPS default route is not changed, so SSH should stay reachable
- Added install, status, `warp=on` test, logs, disable and removal actions
- Diagnostics now checks WARP when it is installed
- Added a local proxy note: use it only with apps that support SOCKS5/HTTP proxy
- Config saving now uses safer shell escaping through `printf %q`

</details>

<details>
<summary><b>v5.0.0</b> — Hysteria 2 + Yurich Proxy</summary>

**⚡ Hysteria 2 added without conflicting with Yurich Proxy:**
- Yurich Proxy stays on `TCP/443` through Caddy
- Hysteria 2 runs separately on `UDP/8443`
- Added install, status, logs, removal and client `hy2://` config
- Hysteria 2 reuses the Caddy TLS certificate for the current domain
- A dedicated `Hysteria 2` menu entry is available

</details>

<details>
<summary><b>v4.2.7</b> — Client Config Fix</summary>

**📱 Client config output fixed:**
- The server stack is shown explicitly: `Caddy 2 + klzgrad/forwardproxy@naive`
- sing-box now uses `type: naive` as the primary outbound
- Added a complete sing-box Android VPN/TUN example
- HTTPS proxy is kept as a fallback for clients without native naive transport

</details>

<details>
<summary><b>v4.2.6</b> — SSH Firewall Fix</summary>

**🔴 Critical SSH fix:**
- UFW now opens the current SSH port before enabling `default deny incoming`
- SSH stays reachable even when SSH Hardening is skipped during install
- Install output explicitly shows the opened SSH port

</details>

<details>
<summary><b>v4.2.5</b> — SSH/Caddy Safety</summary>

**🛡️ Safer install and Caddy handling:**
- SSH Hardening no longer runs by default during install
- New `ssh-rescue` mode to restore SSH: port 22, root/password temporarily allowed
- Generated Caddyfile is formatted and validated with `caddy validate`
- Caddy update builds the new binary before restarting the service
- User deletion now matches the exact login, avoiding regex/substring mistakes
- Telegram `/adduser`, `/deluser`, `/qr`, `/deladmin` use safer validation

</details>

<details>
<summary><b>v4.2.4</b> — Audit Fixes</summary>

**🐛 Final security audit:**
- 🔴 Fixed broken quotes `""${var}""` in DNS whitelist (real bug!)
- 🟡 `((var++))` → `var=$((var+1))` in 3 places (set -e exit safety)
- 🟢 Literal `\n` in printf → `\\n`
- ✅ ShellCheck: 0 errors, 2 harmless warnings
- ✨ `/donate` command in Telegram bot
- ✨ Menu item 18 — donation + QR code

</details>

<details>
<summary><b>v4.2.3</b> — ALPN Fix</summary>

- 🐛 Fixed `grep: binary file matches` — `-a` flag
- ✅ Diagnostics correctly shows `ALPN: h2`

</details>

<details>
<summary><b>v4.2.2</b> — Security Audit (10 fixes)</summary>

- 🔒 SSH `sshd_config.d/` + `ssh.socket` disable
- 🛡️ Last domain deletion protection
- 📦 `apt update` before Fail2Ban
- ⚡ Fail2Ban `iptables-multiport`
- 🌐 UFW `allow 80/tcp` (ACME)
- 🔑 Passwords 20 chars `[a-zA-Z0-9_-]`
- ♻️ Caddy `Restart=on-failure`
- ✅ `/qr` curl fix
- ✅ `/adduser` validation
- 🐛 Diagnostics counters

</details>

<details>
<summary><b>v4.2.1</b> — Banner & Branding</summary>

- ✨ ASCII banner at startup
- ✨ Telegram channel + website in banner

</details>

<details>
<summary><b>v4.2.0</b> — DNS Ad Blocker</summary>

- ✨ unbound + ~1.5M domains
- ✨ DNS-over-TLS (Cloudflare + Google)
- 🆕 CLI: `dns`, `dns-install`, `dns-update`

</details>

<details>
<summary><b>v4.1.0</b> — Security Audit</summary>

- 🔒 Bot validation + args sanitization

</details>

<details>
<summary><b>v4.0.0</b> — Telegram Bot</summary>

- ✨ 16 commands + multi-admin + QR image

</details>

<details>
<summary><b>v3.9.0</b> — Diagnostics</summary>

- ✨ 7 blocks, 18+ checks

</details>

<details>
<summary><b>v3.8.0</b> — Security & UX</summary>

- ✨ SSH key + QR + Fail2Ban 3 levels

</details>

<details>
<summary><b>v3.7.0</b> — Critical Caddyfile Fix</summary>

- 🔴 `:443, domain` instead of `domain:443`

</details>

---

## 📄 License

**PolyForm Noncommercial 1.0.0 + Commercial License** © **Yurich Panel contributors**

Personal, educational, research and other noncommercial use is allowed under the PolyForm Noncommercial License.

Commercial use, resale, paid panels, SaaS, hosting, VPN/proxy services, managed services and corporate products require a separate written commercial license from the author.

📞 Licensing contact: use the repository contact channel or configured project support contact

Full license text: [LICENSE](LICENSE)

---

<div align="center">

### 💛 Liked it? Support the project!

[![Donate](https://img.shields.io/badge/💛_Support-Donation page-FF5E3A?style=for-the-badge)](https://example.com/donate)
[![Star](https://img.shields.io/github/stars/ivan-yurich/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivan-yurich/naiveproxy/stargazers)
[![Fork](https://img.shields.io/github/forks/ivan-yurich/naiveproxy?style=for-the-badge&color=58A6FF)](https://github.com/ivan-yurich/naiveproxy/network)

---

📱 [**Telegram**](https://t.me/your_channel) · 🌐 [**Website**](https://example.com) · 💻 [**GitHub**](https://github.com/ivan-yurich/naiveproxy) · 💛 [**Donate**](https://example.com/donate)

**Yurich Panel · by Yurich Panel contributors**

*Professional secure proxy server manager*
*Updates released once a month · Made with 💛 in Russia*

</div>
