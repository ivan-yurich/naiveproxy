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

### 🚀 Professional private proxy server manager

**One script. Bare VPS → secure proxy with ad blocking in 10 minutes.**

Caddy 2 · NaiveProxy · Telegram Bot · DNS Ad Blocking · Diagnostics · SSH Hardening

---

[![Version](https://img.shields.io/badge/version-4.2.3-D4A017?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ivanstudiya-cpu/naiveproxy/releases)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-3FB950?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.shellcheck.net)
[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![License](https://img.shields.io/badge/License-GPL--3.0-58A6FF?style=for-the-badge)](LICENSE)

---

### 💛 Support the project

[![Donate](https://img.shields.io/badge/💛_Donate-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Telegram](https://img.shields.io/badge/Telegram-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+XVSkY6blCTY0ZDU6)
[![Website](https://img.shields.io/badge/Website-ivan--it.net-D4A017?style=for-the-badge&logo=googlechrome&logoColor=white)](https://ivan-it.net)

**🔔 Updates released once a month**

</div>

---

<div align="center">

[**⚡ Quick Start**](#-quick-start) • [**✨ Features**](#-features) • [**🤖 Bot**](#-telegram-bot) • [**🚫 DNS Block**](#-dns-ad-blocking) • [**🔍 Diagnostics**](#-diagnostics) • [**❓ FAQ**](#-faq) • [**💛 Donate**](#-support-the-project-1)

</div>

---

## 🎉 What's new in v4.2.3

<table>
<tr>
<td width="50%" valign="top">

### 🐛 Bug fixes

✅ `/qr` command — curl conflict fix
✅ `/adduser` — login and password validation
✅ Bot commands — `\r\n` cleanup
✅ `set +e` — error doesn't break the bot
✅ Diagnostics — `pass=$((pass+1))` counters
✅ ALPN — `-servername` + `-a` for binary output
✅ SSH port on Ubuntu 22.04+ via `sshd_config.d/`
✅ Protection against deleting last domain
✅ `apt update` before Fail2Ban
✅ Auto-restart Caddy and bot on failure

</td>
<td width="50%" valign="top">

### ⚡ New features

🤖 **16 bot commands** + multi-admin
🚫 **DNS blocking** ~1.5M domains + DoT
🔍 **Diagnostics** — 7 blocks, 18+ checks
🔒 **SSH Hardening** — ED25519, `ssh.socket` fix
🛡️ **Fail2Ban** 3 levels (iptables-multiport)
♻️ **Auto-recovery** — `Restart=on-failure`
🎨 **ASCII banner** + branding
💛 **Donate** via DonationAlerts

</td>
</tr>
</table>

[👉 Full Changelog](#-changelog)

---

## 🤔 What is this

**NaiveProxy** disguises traffic as Chrome browser using the real Chromium network stack. DPI systems and censors see legitimate HTTPS/2 — and let it through.

**NaiveProxy Manager** — a single bash script that turns a bare VPS into a fully protected proxy server with ad blocking and Telegram management.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────────────┐     ┌──────────┐
│  Your       │     │  Censor/DPI  │     │   Your VPS                │     │          │
│  phone      │────▶│              │────▶│   Caddy + NaiveProxy      │────▶│ Internet │
│  laptop     │     │  Sees Chrome │     │   unbound DNS blocking    │     │          │
└─────────────┘     │  HTTPS/2 ✓   │     │   probe_resistance        │     └──────────┘
 naive-client        └──────────────┘     └───────────────────────────┘
 Chromium stack       Passes through       ads blocked 🚫
```

---

## ⚡ Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh)
```

---

## ✨ Features

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Security
- SSH Hardening ED25519 + `sshd_config.d/`
- SSH key auto-save
- Fail2Ban 3 levels (iptables-multiport)
- UFW deny all + scanner blocking
- probe_resistance — looks like a website
- DevStack camouflage page
- Last domain protection

### 📡 Proxy
- Auto TLS — Let's Encrypt
- HTTP/2 + HTTP/3
- QR code — one-scan phone connection
- Multi-user without restart
- Multiple domains
- TCP BBR
- `Restart=on-failure`

</td>
<td width="50%" valign="top">

### 🚫 DNS Blocking
- ~1.5M ad domains
- unbound + DNS-over-TLS
- 3 blocklist sources
- Whitelist
- Auto-update

### 🤖 Telegram Bot
- 16 commands
- Multi-admin
- QR code as image
- Auto-install dependencies
- 24/7 system service

### 🔍 Diagnostics
- 7 blocks, 18+ checks
- Color report
- Send to Telegram

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

---

## 🤖 Telegram Bot

```bash
sudo bash naiveproxy.sh bot-install    # Auto-start
```

| Command | Action |
|---------|--------|
| `/help` `/status` `/stats` | Information |
| `/diagnose` `/cert` `/logs` | Diagnostics |
| `/users` `/adduser` `/deluser` `/qr` | Users |
| `/restart` `/update` `/selfupdate` | Management |
| `/admins` `/addadmin` `/deladmin` | Administration |

---

## 🚫 DNS Ad Blocking

```bash
sudo bash naiveproxy.sh dns-install
```

| Source | Blocks |
|--------|--------|
| StevenBlack/hosts | Ads + malware |
| AdAway | Mobile ads |
| Hagezi Pro | Aggressive blocking |

---

## 🔍 Diagnostics

```bash
sudo bash naiveproxy.sh diagnose
```

```
[1/7] Caddy          ✅ running · ✅ naive padding · ✅ module
[2/7] Configuration  ✅ :443,domain · ✅ users
[3/7] TLS & Network  ✅ DNS · ✅ ports · ✅ ALPN h2 · ✅ cert
[4/7] Firewall       ✅ UFW · ✅ Fail2Ban active
[5/7] Resources      ✅ RAM 40% · ✅ Disk 37%
[6/7] Logs           ✅ no errors
[7/7] Version        ✅ up to date

📊 RESULT: ✅ 18  ⚠️ 0  ❌ 0
```

---

## ⚠️ Caddyfile — critical

```
{
    order forward_proxy before file_server
    servers :443 {
        protocols h1 h2 h3
    }
}

:443, your-domain.com {
  tls your@email.com
  forward_proxy {
    basic_auth USER PASS
    hide_ip
    hide_via
    probe_resistance
  }
  file_server { root /var/www/html }
}
```

---

## 📱 Clients

```
URI: naive+https://USERNAME:PASSWORD@YOUR_DOMAIN:443
```

| Client | Platform |
|--------|----------|
| [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) | Android |
| [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) | iPhone ($2.99) |
| [Hiddify](https://github.com/hiddify/hiddify-next/releases) | Windows / macOS |

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
- **Linode** — reliable, multiple regions
- **OVH** — Europe, cheap options

⚠️ Avoid hosters in countries with internet restrictions.

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
- **Porkbun** — cheap, good interface

**Important — set up A-record:**
```
your-domain.com → YOUR_SERVER_IP
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
sudo bash /usr/local/bin/naiveproxy.sh install
```

</details>

<details>
<summary><b>How to update script to latest version</b></summary>

```bash
# Method 1 — from menu
sudo bash /usr/local/bin/naiveproxy.sh
# → Option 14) Update script

# Method 2 — one command
curl -fsSL https://raw.githubusercontent.com/ivanstudiya-cpu/naiveproxy/main/naiveproxy.sh \
  -o /usr/local/bin/naiveproxy.sh && chmod +x /usr/local/bin/naiveproxy.sh
```

</details>

---

### 🔌 Client connection

<details>
<summary><b>Client won't connect — what to do?</b></summary>

**Step-by-step diagnostics:**

```bash
# 1. Run full system diagnostics
sudo bash naiveproxy.sh diagnose

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
<summary><b>Best app for Android?</b></summary>

**Top 3 for Android:**

1. **NekoBox** ⭐ — best, open source, no ads
   - [github.com/MatsuriDayo/NekoBoxForAndroid](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases)

2. **Hiddify** — simple, for beginners
   - [github.com/hiddify/hiddify-next](https://github.com/hiddify/hiddify-next/releases)

3. **Husi** — NekoBox fork with improvements
   - [github.com/dyhkwong/Exclave](https://github.com/dyhkwong/Exclave/releases)

⚠️ **v2rayNG doesn't work** with NaiveProxy!

</details>

<details>
<summary><b>Free iPhone app?</b></summary>

**Free options:**

1. **Hiddify** ⭐ — best free, in App Store
2. **FoXray** — free, partial support
3. **Streisand** — free, not in some App Stores

**Paid (for comparison):**
- **Shadowrocket** ($2.99) — best support
- **Quantumult X** ($7.99) — for advanced users

**How to connect:**
1. Copy URI: `naive+https://user:pass@domain:443`
2. Open Hiddify → Import from clipboard

</details>

<details>
<summary><b>App for Windows / Mac?</b></summary>

**Windows:**
- **Hiddify Next** — UI client, easy to setup
- **naive.exe** — official CLI from klzgrad
- **NekoRay** — advanced GUI

**macOS:**
- **Hiddify Next** — recommended
- **V2BoX** — in App Store
- **ClashX Pro** — for advanced users

**Linux:**
- **NekoRay** — Qt GUI
- **naive** CLI — for servers

</details>

<details>
<summary><b>How to quickly import URI?</b></summary>

**Method 1 — QR code (phone):**
```bash
sudo bash naiveproxy.sh qr
# Just scan with camera in the app
```

**Method 2 — via Telegram bot:**
```
In bot: /qr username
```

**Method 3 — copy URI:**
```bash
sudo bash naiveproxy.sh config
# Copy URI → "Import from clipboard" in app
```

</details>

---

### 🚫 DNS Ad Blocking

<details>
<summary><b>DNS blocking broke a website — how to fix</b></summary>

```bash
# Method 1 — add to whitelist
sudo bash naiveproxy.sh dns
# → 4) Allow domain → enter domain

# Method 2 — temporarily disable
sudo systemctl stop unbound

# Method 3 — completely remove
sudo bash naiveproxy.sh dns
# → 5) Remove blocker
```

</details>

<details>
<summary><b>YouTube ads not fully blocked</b></summary>

This is **normal**! YouTube embeds ads in the video stream from the same domain (`googlevideo.com`) as the video itself. Blocking only the ad is impossible — blocking the domain would kill the video too.

**What works:**
- ✅ YouTube banners (on homepage)
- ✅ Pre-roll ads (sometimes)
- ❌ Ads inside videos — not blocked

**Solutions for YouTube:** YouTube Premium or apps like NewPipe (Android), YouTube Vanced.

</details>

<details>
<summary><b>How to update blocklists manually</b></summary>

```bash
sudo bash naiveproxy.sh dns-update
```

Or via menu:
```bash
sudo bash naiveproxy.sh dns
# → 2) Update blocklists
```

</details>

---

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
sudo bash naiveproxy.sh bot-install
```

</details>

<details>
<summary><b>How to get Telegram bot token?</b></summary>

1. Open [@BotFather](https://t.me/BotFather) in Telegram
2. Send `/newbot`
3. Enter bot name (any)
4. Enter bot username (must end with `bot`)
5. Copy token like `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`

Enter token in script:
```bash
sudo bash naiveproxy.sh
# → 7) Telegram + Bot setup
```

</details>

<details>
<summary><b>How to find my Telegram Chat ID?</b></summary>

**Method 1 — via bot:**
1. Send any message to your bot
2. Open in browser: `https://api.telegram.org/botYOUR_TOKEN/getUpdates`
3. Find `"chat":{"id":12345}` — that's your ID

**Method 2 — via @userinfobot:**
1. Message [@userinfobot](https://t.me/userinfobot)
2. It will show your ID

</details>

<details>
<summary><b>/qr command doesn't send picture</b></summary>

```bash
# Install qrencode
apt install -y qrencode

# Restart bot
systemctl restart naiveproxy-bot

# Try /qr in bot
```

</details>

<details>
<summary><b>How to add second administrator?</b></summary>

In Telegram bot send:
```
/addadmin 123456789
```
(where 123456789 — Chat ID of second admin)

View list:
```
/admins
```

</details>

---

### 🔒 SSH Hardening and security

<details>
<summary><b>How to download SSH key to my computer</b></summary>

```bash
# Download key via scp
scp root@YOUR_IP:/etc/naiveproxy/ssh_private_key ~/.ssh/id_naiveproxy

# Set correct permissions
chmod 600 ~/.ssh/id_naiveproxy

# Connect with key
ssh -i ~/.ssh/id_naiveproxy -p NEW_PORT user@YOUR_IP

# Or show key in console
sudo bash naiveproxy.sh ssh-key
```

</details>

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

**If SSH port changed but you forgot which:**
```bash
grep -E "^Port " /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
```

</details>

<details>
<summary><b>Fail2Ban banned me — how to unban</b></summary>

```bash
# View who's banned
fail2ban-client status sshd

# Unban your IP
fail2ban-client unban YOUR_IP

# Unban all IPs
fail2ban-client unban --all

# Add your IP to whitelist (permanent)
echo "ignoreip = 127.0.0.1/8 ::1 YOUR_IP" >> /etc/fail2ban/jail.local
systemctl restart fail2ban
```

</details>

<details>
<summary><b>How to change SSH port again?</b></summary>

```bash
sudo bash naiveproxy.sh ssh-hardening
# Script will ask for new port and apply all settings
```

</details>

---

### 🔧 Server management

<details>
<summary><b>Caddy won't start — what to do</b></summary>

```bash
# 1. Validate config
caddy validate --config /etc/caddy/Caddyfile

# 2. View logs
journalctl -u caddy -n 50 --no-pager

# 3. Run in foreground for debugging
caddy run --config /etc/caddy/Caddyfile

# 4. Common causes:
# - Ports 80/443 occupied (apache2, nginx)
# - No permissions on /var/log/caddy
# - DNS not configured (no A-record)
```

</details>

<details>
<summary><b>How to change user password</b></summary>

```bash
sudo bash naiveproxy.sh users
# → 3) Change password
```

Or via Telegram bot:
```
/deluser username
/adduser username newpassword
```

</details>

<details>
<summary><b>How to add second domain to same server</b></summary>

```bash
# 1. Create A-record for new domain → same IP
# 2. Add domain:
sudo bash naiveproxy.sh domains
# → 1) Add domain
# 3. Caddy will automatically get certificate for new domain
```

</details>

<details>
<summary><b>Certificate fails — Let's Encrypt error</b></summary>

**Common causes:**

```bash
# 1. DNS not configured — check
dig +short your-domain.com

# 2. Port 80 blocked — open it
ufw allow 80/tcp

# 3. Rate limit exceeded (5 failures per hour)
# Wait 1 hour and try again

# 4. CAA record blocks Let's Encrypt
# Check with registrar — should be empty or letsencrypt.org
```

</details>

<details>
<summary><b>How to backup and restore</b></summary>

```bash
# Create backup
tar -czf naiveproxy-backup-$(date +%Y%m%d).tar.gz \
  /etc/caddy/Caddyfile \
  /etc/naiveproxy/ \
  /var/www/html/index.html

# Download to your computer
scp root@YOUR_IP:~/naiveproxy-backup-*.tar.gz ~/Downloads/

# Restore on new server
sudo bash naiveproxy.sh install  # install first
tar -xzf naiveproxy-backup.tar.gz -C /
systemctl restart caddy
```

</details>

<details>
<summary><b>How to completely remove NaiveProxy</b></summary>

```bash
sudo bash naiveproxy.sh remove
# Removes: Caddy, configs, logs, systemd services

# Additionally clean up:
apt remove --purge -y caddy fail2ban unbound
rm -rf /etc/caddy /etc/naiveproxy /etc/unbound /var/log/caddy
```

</details>

---

### 📊 Monitoring and logs

<details>
<summary><b>Where to find logs</b></summary>

```bash
# Caddy logs (access)
tail -f /var/log/caddy/access.log

# NaiveProxy logs (CONNECT tunnels)
tail -f /var/log/caddy/naive.log

# Systemd logs
journalctl -u caddy -f
journalctl -u naiveproxy-bot -f

# All logs via script
sudo bash naiveproxy.sh logs
```

</details>

<details>
<summary><b>How to view traffic statistics</b></summary>

```bash
sudo bash naiveproxy.sh monitor
```

Shows:
- Daily/monthly traffic
- Active users
- Connection count
- Top domains

</details>

<details>
<summary><b>Server is slow — how to find cause</b></summary>

```bash
# Run diagnostics
sudo bash naiveproxy.sh diagnose

# Top CPU processes
top -bn1 | head -20

# Memory usage
free -h

# Active connections
ss -ant | wc -l

# Log size (can fill disk)
du -sh /var/log/*
```

</details>

---

### 💛 Project support

<details>
<summary><b>How to support development</b></summary>

**Ways to support:**

1. 💛 **Donate** on DonationAlerts:
   👉 [donationalerts.com/r/ivan_yurievich](https://www.donationalerts.com/r/ivan_yurievich)

2. ⭐ **Give a star** on GitHub

3. 📢 **Tell friends** — share the link

4. 🐛 **Report bugs** — open Issue on GitHub

5. 💡 **Suggest ideas** — in Telegram channel

Thanks for your support! 🙏

</details>

<details>
<summary><b>Where to ask questions?</b></summary>

**Contact info:**

- 📱 **Telegram channel** — [t.me/+XVSkY6blCTY0ZDU6](https://t.me/+XVSkY6blCTY0ZDU6)
- 🌐 **Website** — [ivan-it.net](https://ivan-it.net)
- 💻 **GitHub Issues** — for bugs and suggestions

⏱️ Usually respond within 24 hours.

</details>

---

## 💛 Support the Project

<div align="center">

### If this script helped you — support development! 🙏

[![Donate](https://img.shields.io/badge/💛_DonationAlerts-Any_amount-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)

**👉 https://www.donationalerts.com/r/ivan_yurievich**

</div>

### What your donation will fund:
- 🚀 **More time** on development
- 🐛 **Quick bug fixes**
- ✨ **New features** every month
- 📚 **Documentation** and support
- 🆕 **Exclusive** content for donors in Telegram

### All ways to support:

| Way | Link |
|-----|------|
| 💛 **Donate** | [donationalerts.com/r/ivan_yurievich](https://www.donationalerts.com/r/ivan_yurievich) |
| ⭐ **GitHub Star** | [Give a star](https://github.com/ivanstudiya-cpu/naiveproxy) |
| 📱 **Telegram channel** | [t.me/+XVSkY6blCTY0ZDU6](https://t.me/+XVSkY6blCTY0ZDU6) |
| 🌐 **Website** | [ivan-it.net](https://ivan-it.net) |
| 📢 **Share** | Tell your friends |

**Thanks for your support! Every donation motivates me to make the project even better 💛**

---

## 📜 Changelog

<details>
<summary><b>v4.2.3</b> — ALPN Fix ← CURRENT</summary>

- 🐛 Fixed `grep: binary file matches` — added `-a` flag
- ✅ Diagnostics correctly shows `ALPN: h2` on all servers

</details>

<details>
<summary><b>v4.2.2</b> — Security Audit (10 fixes)</summary>

**Critical:**
- 🔒 SSH `sshd_config.d/` + `ssh.socket` disable
- 🛡️ Protection against deleting last domain
- 📦 `apt update` before Fail2Ban
- 🔧 `PasswordAuthentication`/`PermitRootLogin` add if missing

**Security:**
- ⚡ Fail2Ban `iptables-multiport`
- 🌐 UFW `allow 80/tcp` (ACME)
- 🔑 Passwords 20 chars `[a-zA-Z0-9_-]`
- ♻️ Caddy `Restart=on-failure`

**Bot:**
- ✅ `/qr` curl fix
- ✅ `/adduser` validation
- ✅ `\r\n` cleanup
- ✅ `set +e` in handler

**Diagnostics:**
- 🐛 `pass=$((pass+1))` counters
- 🐛 ALPN `-servername`
- 🐛 Naive padding multi-criteria

</details>

<details>
<summary><b>v4.2.1</b> — Banner & Branding</summary>

- ✨ ASCII banner + Telegram channel + website
- 🐛 `DIM`, `BLUE` variables

</details>

<details>
<summary><b>v4.2.0</b> — DNS Ad Blocker</summary>

- ✨ unbound + ~1.5M domains
- ✨ DNS-over-TLS
- 🆕 `dns`, `dns-install`, `dns-update`

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

GPL-3.0 © **Ivan Yurievich (Иван Юрьевич)**  
Commercial use without author permission is prohibited.  
📞 Contact: [Telegram](https://t.me/+XVSkY6blCTY0ZDU6) · [ivan-it.net](https://ivan-it.net)

---

<div align="center">

### 💛 Liked it? Support the project!

[![Donate](https://img.shields.io/badge/💛_Support-DonationAlerts-FF5E3A?style=for-the-badge)](https://www.donationalerts.com/r/ivan_yurievich)
[![Star](https://img.shields.io/github/stars/ivanstudiya-cpu/naiveproxy?style=for-the-badge&color=D4A017)](https://github.com/ivanstudiya-cpu/naiveproxy/stargazers)

📱 [Telegram](https://t.me/+XVSkY6blCTY0ZDU6) · 🌐 [ivan-it.net](https://ivan-it.net) · 💻 [GitHub](https://github.com/ivanstudiya-cpu/naiveproxy)

*NaiveProxy Manager · by Ivan Yurievich · Updates once a month*

</div>
