<div align="center">

🌐 **Language:** [🇷🇺 Русский](README.md) | [🇬🇧 English](README_EN.md)

</div>

<div align="center">

```
███╗   ██╗ █████╗ ██╗██╗   ██╗███████╗    ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
████╗  ██║██╔══██╗██║██║   ██║██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██╔██╗ ██║███████║██║██║   ██║█████╗      ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██║╚██╗██║██╔══██║██║╚██╗ ██╔╝██╔══╝      ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║ ╚████║██║  ██║██║ ╚████╔╝ ███████╗    ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
                                                                         MANAGER
```

**Professional private proxy server manager**
Caddy 2 · NaiveProxy · Let's Encrypt · Telegram · SSH Hardening · Diagnostics

---

[![Version](https://img.shields.io/badge/version-3.9.0-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivanstudiya-cpu/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.shellcheck.net)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Caddy](https://img.shields.io/badge/Caddy-auto-00ADD8?style=for-the-badge&logo=caddy&logoColor=white)](https://caddyserver.com)
[![License](https://img.shields.io/badge/License-MIT-58A6FF?style=for-the-badge)](LICENSE)

---

[**Quick Start**](#-quick-start) • [**Features**](#-features) • [**Diagnostics**](#-diagnostics) • [**SSH Hardening**](#-ssh-hardening) • [**Clients**](#-client-apps) • [**FAQ**](#-faq)

</div>

---

## 🤔 What is this

**NaiveProxy** disguises traffic as Chrome browser using the real Chromium network stack. DPI systems and censors see legitimate HTTPS/2 — and let it through.

**NaiveProxy Manager** — a single bash script that turns a bare VPS into a fully protected proxy server. No Docker, no GUI panels, no extra dependencies.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────┐     ┌──────────────┐
│  Your       │     │  Censor/DPI  │     │   Your VPS        │     │              │
│  phone      │────▶│              │────▶│   Caddy +         │────▶│  Internet    │
│  laptop     │     │  Sees Chrome │     │   forwardproxy    │     │              │
└─────────────┘     │  HTTPS/2 ✓   │     │   probe_resist.   │     └──────────────┘
 naive-client        └──────────────┘     └───────────────────┘
 Chromium stack       Passes through       TLS from Let's Encrypt
```

---

## ⚡ Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh)
```

### Installation steps:

```
[1/5] 🔄  System Update
         apt upgrade + unattended-upgrades
         → skip if already updated: press n

[2/5] 🔒  SSH Hardening                              [OPTIONAL]
         ED25519 key · auto-save · new user · Fail2Ban
         → skip if SSH already configured: press n

[3/5] 📦  Building Caddy
         git clone klzgrad/forwardproxy@naive
         xcaddy build with auto version detection  ~5-15 min

[4/5] ⚙️   Configuration
         Caddyfile (:443, domain) · systemd · UFW · BBR · Telegram

[5/5] ✅  Done
         URI + JSON configs + QR code for phone
```

---

## ✨ Features

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Security
- **SSH Hardening** — ED25519 key, port change, root block
- **SSH key auto-save** — to `/etc/naiveproxy/ssh_private_key`
- **Fail2Ban 3 levels** — bruteforce(7d) / DDoS(7d) / recidive(30d)
- **UFW** — deny all incoming + scanner port blocking
- **probe_resistance** — looks like a normal website
- **Camouflage page** — DevStack IT blog

### 📡 Proxy
- **Automatic TLS** — Let's Encrypt via Caddy
- **HTTP/2 + HTTP/3** — explicitly enabled
- **QR code** — one-scan phone connection
- **Multi-user** — add users without restart
- **Multiple domains** — on one server
- **TCP BBR** — optional speed boost

</td>
<td width="50%" valign="top">

### 🔍 Diagnostics
- **7 check blocks** — Caddy, config, TLS, network, firewall, resources, logs
- **Color report** — ✅ / ⚠️ / ❌ per check
- **Log analysis** — errors, CONNECT tunnels
- **Send to Telegram** — full report in one click

### 🤖 Automation
- **Telegram bot** — alerts + stats on demand
- **Watchdog** — cron every 5 min, auto-restart
- **Self-update** — script update from GitHub
- **Certificate check** — alert when < 7 days

</td>
</tr>
</table>

---

## 📋 Requirements

| | |
|--|--|
| **OS** | Ubuntu 20.04 / 22.04 / 24.04 |
| **Rights** | root |
| **Domain** | A-record → server IP |
| **Ports** | 80/tcp · 443/tcp · 443/udp |
| **RAM** | 512 MB+ |
| **Disk** | 1 GB+ |

---

## 🎮 Menu

```
──────────────────────────────────────────────────────
   NaiveProxy Manager v3.9.0
   Status: ● running  │  Domain: proxy.example.com
   Telegram: connected  │  Users: 3  │  SSH: 52847
──────────────────────────────────────────────────────
   1)  Install NaiveProxy          10) Logs
   2)  Status + certificate        11) Remove NaiveProxy
   3)  Client config + QR          16) 🔍 Diagnostics
   4)  Users                       ──────────────────
   5)  Domains                     12) 🔒 SSH Hardening
   6)  Monitoring + stats          13) 🔄 Update system
   7)  Telegram setup              14) ⬆️  Update script
   8)  Restart Caddy               15) 🎭 Update camouflage
   9)  Update Caddy
──────────────────────────────────────────────────────
```

### CLI commands:

```bash
sudo bash naiveproxy.sh install        # Full installation
sudo bash naiveproxy.sh diagnose       # System diagnostics
sudo bash naiveproxy.sh status         # Status + TLS certificate
sudo bash naiveproxy.sh config         # Config + QR code
sudo bash naiveproxy.sh qr             # QR code only
sudo bash naiveproxy.sh cert           # Certificate only
sudo bash naiveproxy.sh users          # User management
sudo bash naiveproxy.sh domains        # Domain management
sudo bash naiveproxy.sh monitor        # Monitoring + stats
sudo bash naiveproxy.sh restart        # Restart Caddy
sudo bash naiveproxy.sh update         # Update Caddy
sudo bash naiveproxy.sh logs           # Live logs
sudo bash naiveproxy.sh tg-stats       # Stats to Telegram
sudo bash naiveproxy.sh ssh-hardening  # SSH Hardening
sudo bash naiveproxy.sh ssh-key        # Show SSH private key
sudo bash naiveproxy.sh sysupdate      # System update
sudo bash naiveproxy.sh self-update    # Update script from GitHub
sudo bash naiveproxy.sh camouflage     # Reinstall camouflage page
sudo bash naiveproxy.sh version        # Show version
sudo bash naiveproxy.sh remove         # Remove everything
```

---

## 🔍 Diagnostics

```bash
sudo bash naiveproxy.sh diagnose
```

Checks **7 blocks** and shows a color report:

```
[1/7] Caddy          — found · running · naive padding · module
[2/7] Configuration  — Caddyfile · :443,domain format · users
[3/7] TLS & Network  — DNS · ports · ALPN h2 · certificate
[4/7] Firewall       — UFW · Fail2Ban · blocked ports
[5/7] Resources      — RAM · disk · CPU load
[6/7] Logs           — errors · CONNECT tunnels
[7/7] Version        — up to date · SSH hardening done

📊 RESULT: ✅ 18  ⚠️ 0  ❌ 0
🎉 Everything is working great!
```

Results can be sent to Telegram with one click.

---

## ⚠️ Critical — Caddyfile

```bash
# ❌ WRONG — clients won't connect:
your-domain.com:443 { ... }

# ✅ CORRECT — :443 must be FIRST:
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

The script generates the correct config automatically since v3.7.0.

---

## 🔒 SSH Hardening

```bash
sudo bash naiveproxy.sh ssh-hardening
```

> 💡 **Can be skipped** if SSH is already configured. Press `n` during installation.

**5 steps:** new sudo user → ED25519 key (auto-save) → port change → sshd_config → UFW + Fail2Ban

```bash
# Download SSH key to your computer:
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy
chmod 600 ~/.ssh/id_naiveproxy
ssh -i ~/.ssh/id_naiveproxy -p NEW_PORT user@YOUR_IP

# Show key anytime:
sudo bash naiveproxy.sh ssh-key
```

### Fail2Ban — 3 levels:

| Level | Trigger | Ban |
|-------|---------|-----|
| Bruteforce | 3 wrong passwords | **7 days** |
| DDoS | 10 attempts in 1 min | **7 days** |
| Recidivist | Repeated violations | **30 days** |

---

## 🤖 Telegram Bot

1. [@BotFather](https://t.me/BotFather) → `/newbot` → token
2. [@userinfobot](https://t.me/userinfobot) → chat_id
3. Menu → **7) Telegram setup**

| Event | Message |
|-------|---------|
| Installation done | ✅ NaiveProxy started |
| Caddy crashed | 🔴 Down → auto-restart |
| SSH Hardening | 🔒 Port: 52847 |
| Certificate < 7 days | ⚠️ 5 days left! |
| Diagnostics | 🔍 Full report |
| Stats | 📊 Traffic · RAM · Disk |

---

## 📱 Client Apps

### URI (paste into any client):
```
naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

### JSON (naive-client Windows/Linux):
```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://USERNAME:PASSWORD@YOUR_DOMAIN:443",
  "log": "naive.log"
}
```

### Recommended clients:

| Client | Platform | How to add |
|--------|----------|------------|
| [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) | Android | QR / URI |
| [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) | iPhone | URI |
| [Hiddify](https://github.com/hiddify/hiddify-next/releases) | Windows / macOS | URI |
| [naive](https://github.com/klzgrad/naiveproxy/releases) | Windows / Linux | config.json |
| [sing-box](https://github.com/SagerNet/sing-box) | All platforms | JSON config |

> ⚠️ **v2rayNG does NOT support NaiveProxy.** Use NekoBox or Hiddify.

---

## ❓ FAQ

<details>
<summary><b>Client won't connect</b></summary>

Run diagnostics first:
```bash
sudo bash naiveproxy.sh diagnose
```

Or check manually:
```bash
# Caddyfile should be: :443, domain {
cat /etc/caddy/Caddyfile | grep ":443"

# ALPN must be h2:
openssl s_client -connect YOUR_DOMAIN:443 -alpn h2 2>/dev/null | grep "ALPN protocol"
```

</details>

<details>
<summary><b>How to download SSH key</b></summary>

```bash
# Linux/macOS:
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy
chmod 600 ~/.ssh/id_naiveproxy

# Windows PowerShell:
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key $HOME\.ssh\id_naiveproxy
```

</details>

<details>
<summary><b>Locked out after SSH hardening</b></summary>

Access via hosting console (VNC/KVM):
```bash
ufw allow 22/tcp && systemctl restart sshd
```

</details>

<details>
<summary><b>Caddy can't get TLS certificate</b></summary>

```bash
dig +short YOUR_DOMAIN        # must return server IP
ss -tlnp | grep :80           # port 80 must be listening
journalctl -u caddy -n 50 | grep -i "acme\|error\|cert"
```

</details>

---

## 📊 Comparison

| Feature | **NaiveProxy Manager** | x-ui / 3x-ui | Marzban |
|---------|:---:|:---:|:---:|
| No Docker | ✅ | ❌ | ❌ |
| SSH Hardening | ✅ | ❌ | ❌ |
| SSH key auto-save | ✅ | ❌ | ❌ |
| QR code | ✅ | ❌ | ❌ |
| System diagnostics | ✅ | ❌ | ❌ |
| Fail2Ban 3 levels | ✅ | ❌ | ❌ |
| Camouflage page | ✅ | ❌ | ❌ |
| Self-update | ✅ | ❌ | ❌ |
| Certificate check | ✅ | ❌ | ❌ |
| Correct Caddyfile | ✅ v3.7+ | — | — |
| Telegram alerts | ✅ | ✅ | ✅ |
| ShellCheck passing | ✅ | — | — |

---

## 📜 Changelog

<details>
<summary><b>v3.9.0</b> — System Diagnostics ← CURRENT</summary>

- ✨ Full system diagnostics — 7 blocks, 18+ checks
- ✨ Color report ✅/⚠️/❌ with recommendations
- ✨ Caddy log analysis for errors
- ✨ Send diagnostics report to Telegram
- 🆕 CLI: `diagnose`
- 🆕 Menu item 16

</details>

<details>
<summary><b>v3.8.0</b> — Security & UX</summary>

- ✨ SSH key auto-save + scp command output
- ✨ QR code in terminal
- 🛡️ UFW deny all + scanner port blocking
- 🛡️ Fail2Ban 3 protection levels

</details>

<details>
<summary><b>v3.7.0</b> — Critical Caddyfile Fix</summary>

- 🔴 Critical fix: `:443, domain` instead of `domain:443`
- ✅ Confirmed: NekoBox Android + naive.exe Windows working

</details>

<details>
<summary><b>v3.6.0</b> — Critical Build Fix</summary>

- 🔴 build_caddy: direct git clone of `klzgrad/forwardproxy@naive`
- 🔴 Auto-detect Caddy version from go.mod

</details>

<details>
<summary><b>v3.0–3.5</b> — Core Features</summary>

- System update, SSH Hardening, Self-update, Domains, Camouflage, Security Audit

</details>

---

## 📄 License

MIT © [ivanstudiya-cpu](https://github.com/ivanstudiya-cpu)

---

<div align="center">

**If this helped — leave a ⭐ star**

[![GitHub stars](https://img.shields.io/github/stars/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivanstudiya-cpu/naiveproxy/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=58A6FF)](https://github.com/ivanstudiya-cpu/naiveproxy/network)

*NaiveProxy Manager · Caddy 2 · klzgrad/forwardproxy@naive · Ubuntu*

</div>
