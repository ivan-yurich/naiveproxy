# Security Policy

## Reporting Security Issues

Please do not open a public issue with secrets, private server addresses,
subscription URLs, bot tokens, SSH keys, or production configuration files.

For a security report, use the repository owner contact channel configured in
the project profile, or create a minimal public issue that says a private
security report is needed without including sensitive details.

## Do Not Publish

Never attach or paste:

- `/etc/naiveproxy/naive.conf`
- `/etc/naiveproxy/users.conf`
- `/etc/naiveproxy/users.d/*`
- `/etc/naiveproxy/subscriptions/*`
- `/etc/naiveproxy/nodes.conf`
- Telegram bot tokens
- Cloudflare/WARP credentials
- SSH private keys
- real customer subscription URLs

## If a Secret Leaks

Rotate the affected credential immediately:

- Telegram bot token: revoke it in BotFather and install a new token.
- Subscription URL: run `subscription-reset USER`.
- SSH key: remove the public key from servers and issue a new key.
- Server user password: rotate the user password and rebuild subscriptions.

## Hardening Baseline

Production servers should use:

- SSH key-only login
- root login disabled
- UFW deny-by-default
- Fail2Ban or CrowdSec
- automatic security updates
- least-open ports
- encrypted backups with restore checks
