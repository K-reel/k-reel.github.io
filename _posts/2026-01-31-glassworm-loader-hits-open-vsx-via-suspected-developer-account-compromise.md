---
title: "GlassWorm Loader Hits Open VSX via Developer Account Compromise"
short_title: "GlassWorm Loader Hits Open VSX via Account Compromise"
date: 2026-01-31 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [VS Code, Open VSX, Threat Intelligence, Supply Chain Security, Malware, Credential Theft, macOS]
canonical_url: https://socket.dev/blog/glassworm-loader-hits-open-vsx-via-suspected-developer-account-compromise
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/7425d0fe3788ee2c9a20b402de736d326c0da724-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: GlassWorm Open VSX loader artwork
description: "Threat actors compromised four oorzc Open VSX extensions with more than 22,000 downloads, pushing malicious versions that install a staged loader, evade Russian-locale systems, pull C2 from Solana memos, and steal macOS credentials and wallets."
---
<div class="prose" dir="ltr">
<p>Socket’s Threat Research team identified a developer-compromise supply chain attack distributed via the Open VSX Registry, specifically a compromise of the developer’s publishing credentials. The Open VSX security team assessed the activity as consistent with a leaked token or other unauthorized access.</p>
<p>On January 30, 2026, four established Open VSX extensions published by the <code>oorzc</code> author had malicious versions published to Open VSX that embed the GlassWorm malware loader. These extensions had previously presented as legitimate developer utilities (some first published more than two years ago) and collectively accumulated over 22,000 Open VSX downloads prior to the malicious releases.</p>
<p>The four impacted extensions are:</p>
<ol><li>FTP/SFTP/SSH Sync Tool (<a href="https://socket.dev/openvsx/package/oorzc.ssh-tools/overview/0.5.1?platform=universal"><code>oorzc.ssh-tools</code></a> — v0.5.1)</li><li>I18n Tools (<a href="https://socket.dev/openvsx/package/oorzc.i18n-tools-plus/overview/1.6.8?platform=universal"><code>oorzc.i18n-tools-plus</code></a> — v1.6.8)</li><li>vscode mindmap (<a href="https://socket.dev/openvsx/package/oorzc.mind-map/overview/1.0.61"><code>oorzc.mind-map</code></a> — v1.0.61)</li><li>scss to css (<a href="https://socket.dev/openvsx/package/oorzc.scss-to-css-compile/overview/1.3.4"><code>oorzc.scss-to-css-compile</code></a> — v1.3.4)</li></ol>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/825ddc03ed108cb065daeb925e724df4b227d692-1356x539.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em><em>Screenshot of Open VSX Registry showing the </em><em><code>oorzc</code></em><em> namespace with four published extensions: </em><em><code>FTP/SFTP/SSH Sync Tool </code></em><em>(17K downloads), </em><em><code>I18n Tools</code></em><em> (3.6K), </em><em><code>vscode mindmap</code></em><em> (3.2K), and </em><em><code>scss to css</code></em><em> (1.3K). Open VSX rounds the download counts on the UI (the “K” figures), so the totals can look higher in screenshots. When we sum the actual download numbers, the combined total is over 22K.</em></em></p></figcaption></figure>
<p>We reached out to the <code>oorzc</code> maintainer to flag that recent Open VSX releases of these extensions were compromised and set to distribute a GlassWorm loader, consistent with a developer publishing-credential compromise, such as a leaked publishing token or other unauthorized access to the release path.</p>
<p>Across all four extensions, the malicious update introduces staged loaders that decrypt and execute embedded code at runtime, includes Russian-locale avoidance, resolves command and control (C2) pointers from Solana transaction memos, and then executes additional remote code.</p>
<p>This tradecraft aligns with the recent GlassWorm cluster we have been tracking internally since December 2025. In that work, we identified and reported earlier malicious Open VSX extensions tied to the same staging and blockchain-resolved infrastructure patterns, which reduce reliance on static indicators and enable rapid server-side updates.</p>
<p>Downstream payloads collected in this investigation show macOS-focused information stealing and persistence. The payload harvests and exfiltrates browser cookies, history, and login databases, including wallet-extension data such as MetaMask, and it targets multiple browser families, including Mozilla Firefox and Chromium-based browsers. It also collects desktop cryptocurrency wallet files (Electrum, Exodus, Atomic, Ledger Live, Trezor Suite, Binance, TonKeeper), the user’s login keychain database, Apple Notes databases, Safari cookies, targeted user documents from Desktop, Documents, and Downloads, and FortiClient VPN configuration files. Crucially, it also targets developer credentials and configuration, including <code>~/.aws</code> (credentials and config) and <code>~/.ssh</code> (private keys, <code>known_hosts</code>, and related configuration), which raises the risk of cloud account compromise and lateral movement in developer and enterprise environments. The payload includes routines to locate and extract authentication material used in common workflows, including inspecting npm configuration for <code>_authToken</code> and referencing GitHub authentication artifacts, which can provide access to private repositories, CI secrets, and release automation.</p>
<p>This incident also differs materially from GlassWorm activity previously documented. Earlier waves largely relied on typosquatting and brandjacking, cloning or mimicking popular developer tools and attempting to appear trustworthy by artificially inflating download counts.</p>
<p>By contrast, these four extensions were published under an established publisher account with a multi-extension history and meaningful adoption signals across ecosystems. The same publisher also maintains Visual Studio Marketplace listings with substantial install counts (as displayed on the listings at the time of review): <code>vscode mindmap</code> (7,696 installs), <code>scss to css</code> (3,810 installs), <code>FTP/SFTP/SSH Sync Tool</code> (4,948 installs), and <code>I18n Tools</code> (1,570 installs). This observation is provided to illustrate the publisher’s apparent legitimacy and reach, not to suggest the Visual Studio Marketplace listings were compromised. Our findings in this report concern the Open VSX extensions.</p>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/04adda57955f3bc4229931f773d23162fad25cd3-780x543.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em><em>Publisher profile for </em><em><code>oorzc</code></em><em> on Visual Studio Marketplace (Visual Studio Code) listing four extensions: </em><em><code>vscode mindmap</code></em><em>, </em><em><code>FTP/SFTP/SSH Sync Tool</code></em><em>, </em><em><code>scss to css</code></em><em>, and </em><em><code>I18n Tools</code></em><em>.</em></em></p></figcaption></figure>
<p>Following our January 30, 2026 report, the Eclipse Foundation / Open VSX Registry security team reviewed the affected extensions, concluded the activity was consistent with leaked tokens or other unauthorized publishing access, and deactivated the publisher’s two Open VSX tokens. They removed the malicious releases and, because multiple recent <code>oorzc.ssh-tools</code> versions scanned as malware and many versions were published, they removed all <code>oorzc.ssh-tools</code> versions and added it to the Open VSX malware list, while leaving earlier clean versions available for the other three extensions. Based on our prior reporting of 13 earlier malicious Open VSX extensions associated with the recent GlassWorm cluster, we have consistently seen the Open VSX security team respond quickly and take decisive action to protect the community, and we appreciate their rapid engagement and clear coordination; security is a team sport.</p>
<h2>Not Glass, Not a Worm, Still Dangerous</h2>
<p>GlassWorm has been abusing the Open VSX Registry supply chain since at least October 2025, when researchers first <a href="https://www.koi.ai/blog/glassworm-first-self-propagating-worm-using-invisible-code-hits-openvsx-marketplace">reported</a> malicious extensions using concealed logic to steal developer credentials, and it has continued resurfacing in repeated waves through late 2025 and into early 2026.</p>
<p>The name is also increasingly misleading. The “glass” aspect originally pointed to invisible character tricks, but recent iterations rely more on encrypted, staged loaders than on being visually undetectable. The “worm” label is similarly imperfect, and the Open VSX maintainers have publicly <a href="https://blogs.eclipse.org/post/mika%C3%ABl-barbero/open-vsx-security-update-october-2025">clarified</a> that it was not self-replicating in the traditional sense, instead it extended reach by stealing credentials and abusing publishing access.</p>
<p>On January 30, 2026, this escalation became clear. The threat actor published poisoned updates through an established publisher identity, and the Open VSX security team assessed the incident as consistent with leaked tokens or other unauthorized publishing access.</p>
<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/d9c14c5d41c6816f96d5b6269436df566fbd1d96-624x673.png?w=1600&q=95&fit=max&auto=format" alt="" loading="lazy"><figcaption><p><em><em>Socket AI Scanner flags </em><em><code>oorzc.ssh-tools@0.5.1</code></em><em> as malware, describing a staged loader that decrypts and runs an embedded blob at activation time (hardcoded AES material and </em><em><code>eval()</code></em><em>), suppresses execution on Russian-language or Russia-adjacent systems, uses Solana transaction memos as a dead drop for next-stage configuration, and then fetches and executes a follow-on payload in memory.</em></em></p></figcaption></figure>
<h2>Staged Execution Chain</h2>
<h3>Stage 0: A Small Loader That Decrypts and Executes Code</h3>
<p>All four <code>.vsix</code> files contained a near-identical loader inside <a href="https://socket.dev/openvsx/package/oorzc.ssh-tools/files/0.5.1/extension/dist/extension.js?platform=universal"><code>extension.js</code></a>. The loader uses AES-256-CBC to decrypt a long hex string, converts the result to UTF-8, and immediately executes it with <code>eval</code>.</p>
<p>Below is an excerpt from the loader with the encrypted blob truncated for readability and with our added comments.</p>
<pre><code lang="javascript">const crypto = require(&quot;crypto&quot;);

// AES parameters embedded in the extension
let d = crypto.createDecipheriv(
  &quot;aes-256-cbc&quot;,
  &quot;wDO6YyTm6DL0T0zJ0SXhUql5Mo0pdlSz&quot;,                    // 32-byte key
  Buffer.from(&quot;dfc1fefb224b2a757b7d3d97a93a1db9&quot;, &quot;hex&quot;) // 16-byte IV
);

// Encrypted payload is a long hex string (truncated here)
let b = d.update(
  &quot;d4f0f5c6b7c5...&lt;hex omitted&gt;...9f2a&quot;,
  &quot;hex&quot;,
  &quot;utf8&quot;
);

b += d.final(&quot;utf8&quot;);

// Executes the decrypted Stage 1 code
eval(b);</code></pre>
<h3>Stage 1: Environment Checks, Then a Blockchain Dead Drop</h3>
<p>Once decrypted, Stage 1 performs host profiling and gating. The most notable logic checks for Russian language settings and Russia-adjacent time zones, then exits early if the system matches. That is classic criminal OPSEC, and it lines up with the old Russian underworld saying, “Кто работает по ру, к тому приходит по утру”, roughly, “If you operate in RU, someone shows up at your door in the morning”.</p>
<p>An excerpt from the Stage 1 geofencing logic is shown below. This is taken directly from the decrypted Stage 1.</p>
<pre><code lang="javascript">function _isRussianSystem(){
  let russianIndicators = [
    &quot;ru_RU&quot;,
    &quot;ru-RU&quot;,
    &quot;ru&quot;,
    &quot;Russian&quot;,
    process.env.LANG,
    process.env.LANGUAGE,
    process.env.LC_ALL,
    process.env.LC_MESSAGES
  ];
  let isRussianLanguage = russianIndicators.some(indicator =&gt;
    indicator &amp;&amp; indicator.toLowerCase().includes(&quot;ru&quot;)
  );

  let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  let isMoscowTimeZone = timeZone &amp;&amp; timeZone.includes(&quot;Europe/Moscow&quot;);

  let utcOffset = (new Date).getTimezoneOffset() / -60;
  let isRussiaAdjacentTimezone = utcOffset &gt;= 2 &amp;&amp; utcOffset &lt;= 12;

  return isRussianLanguage || isMoscowTimeZone || isRussiaAdjacentTimezone;
}</code></pre>
<p>If the host passes those checks, Stage 1 retrieves its next instruction from a transaction memo on Solana. Practically, this works like a dead drop. The extension does not need a hardcoded C2 URL, because the threat actor can rotate the next-stage link by writing a new memo on-chain. That design also pushes the “where do I fetch next” decision out of the extension and into threat actor-controlled infrastructure.</p>
<p>Stage 1 then focuses its next steps on macOS systems. The decrypted code explicitly checks the OS before continuing the chain, which aligns with what we later observed in the Stage 2 payload.</p>
<pre><code lang="javascript">if (os.platform() == &quot;darwin&quot;) {
  // macOS-specific Stage 2 path follows
}</code></pre>
<h3>Stage 2: What the macOS Payload Does Once Executed</h3>
<p>Stage 2 is a Node.js JavaScript payload that functions as a macOS-focused data theft and persistence implant. It stages collected files, compresses them into an archive, and exfiltrates the results to threat actor-controlled infrastructure.</p>
<h4>Staging and collection</h4>
<p>The payload creates a working directory at <code>/tmp/ijewf</code>, collects a broad set of artifacts from the host, then compresses the staged data into <code>/tmp/out.zip</code> in preparation for exfiltration.</p>
<p>In practice, the collection scope is broad and explicitly geared toward credential theft, session theft, and wallet theft. The payload copies browser cookies, form history, and login databases across Firefox-family and Chromium-based browsers, including wallet-extension artifacts (for example, MetaMask storage). It also targets desktop cryptocurrency wallet data (including Electrum, Exodus, Atomic, Ledger Live, Trezor Suite, Binance, and TonKeeper), macOS keychain material (the user’s <code>login.keychain-db</code>), Apple Notes databases, Safari cookies, and FortiClient VPN configuration. Finally, it performs targeted document collection from Desktop, Documents, and Downloads, filtering by file extension and enforcing a total size limit, then stages everything for exfiltration as a single archive.</p>
<pre><code lang="javascript">// Stage 2 data-theft targets (selected examples observed in payload)

const targets = [
  // macOS credential store
  &quot;~/Library/Keychains/login.keychain-db&quot;,

  // Apple Notes databases (often contain sensitive data)
  &quot;~/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite&quot;,
  &quot;~/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite-wal&quot;,
  &quot;~/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite-shm&quot;,

  // Safari session material
  &quot;~/Library/Containers/com.apple.Safari/Data/Library/Cookies/Cookies.binarycookies&quot;,

  // FortiClient VPN configuration
  &quot;/Library/Application Support/Fortinet/FortiClient/conf/vpn.plist&quot;,

  // Developer secrets and access material
  &quot;~/.aws&quot;, // credentials and config
  &quot;~/.ssh&quot;  // private keys, known_hosts, config
];

// The payload stages copies of these artifacts under /tmp/ijewf,
// compresses them to /tmp/out.zip, then exfiltrates the archive.</code></pre>
<pre><code lang="javascript">// Browser + wallet focus (high-level):
// * Chromium: Cookies, Login Data, Web Data across multiple browser profiles
// * Firefox-family: cookies.sqlite, formhistory.sqlite, key4.db, logins.json
// * Wallets: Electrum, Exodus, Atomic, Ledger Live, Trezor Suite, Binance, TonKeeper
// * Wallet extensions: MetaMask storage artifacts</code></pre>
<p>It explicitly targets developer credentials and configuration, including AWS and SSH material, which raises the risk of cloud account compromise and lateral movement in developer and enterprise environments. Examples include <code>~/.aws</code> (credentials and config) and <code>~/.ssh</code> (private keys, <code>known_hosts</code>, and related configuration). It also collects additional high-value local sources, including macOS keychain data and application storage paths that commonly contain credentials and session material.</p>
<h3>Token and Secret Access</h3>
<p>The payload includes logic to locate and extract authentication material used in common developer workflows. For example, it inspects npm configuration for <code>_authToken</code> and interacts with the npm registry, consistent with npm token discovery and validation behavior. It also contains logic that references GitHub authentication artifacts, which is particularly high impact because GitHub tokens often provide access to private repositories, CI secrets, and release automation.</p>
<h3>Exfiltration</h3>
<p>After collecting and compressing data, the payload exfiltrates the archive using <code>curl</code> to hardcoded IP-based endpoints. In the sample we analyzed, it POSTs to paths such as <code>/p2p</code> and <code>/2p2</code> on <code>45[.]32[.]150[.]251</code>.</p>
<h3>Persistence</h3>
<p>Stage 2 establishes persistence on macOS via a LaunchAgent. It writes a plist under <code>~/Library/LaunchAgents</code> (e.g., <code>com.user.nodestart.plist</code>) and uses it to start a bundled or downloaded Node runtime that executes the payload at login. This makes the impact persistent, unless defenders remove the LaunchAgent and any associated runtime and staging artifacts.</p>
<h2>Outlook and Recommendations</h2>
<p>This campaign shows a clear escalation in Open VSX supply chain abuse. The threat actor blends into normal developer workflows, hides execution behind encrypted, runtime-decrypted loaders, and uses Solana memos as a dynamic dead drop to rotate staging infrastructure without republishing extensions. These design choices reduce the value of static indicators and shift defender advantage toward behavioral detection and rapid response.</p>
<p>The immediate risk is credential and token theft from developer endpoints. Stolen AWS and SSH material can enable direct cloud compromise and lateral movement. Stolen GitHub and npm tokens can enable repository takeover, poisoned commits, package publication abuse, and access to CI secrets. Even if the extensions run only on workstations, the downstream blast radius can extend to build pipelines and end users if compromised credentials are reused to ship tampered releases.</p>
<p>If you installed any extension listed in the IOC section, treat it as a credential exposure event. Remove the extension and delete its on-disk artifacts. On macOS, check for persistence under <code>~/Library/LaunchAgents</code>, including unfamiliar plists such as <code>com.user.nodestart.plist</code>, and investigate suspicious runtime paths that reference <code>/tmp/ijewf</code> or <code>/tmp/out.zip</code>.</p>
<p>Rotate credentials. Revoke and reissue GitHub tokens first, then npm tokens, then AWS keys, then any SSH keys that can reach production or CI systems. Audit recent GitHub activity for new tokens, unexpected workflow changes, and suspicious commits. Validate your CI configuration and release jobs for unauthorized modifications.</p>
<p>Add supply chain controls and use the <a href="https://socket.dev/features/github"><strong>Socket GitHub app</strong></a> to gate dependency changes in pull requests, use the <a href="https://socket.dev/features/cli"><strong>Socket CLI</strong></a> in install workflows, and use the <a href="https://www.notion.so/GlassWorm-Loader-Hits-Open-VSX-via-Developer-Account-Compromise-2f84cb3adfeb8003985fffdbf5740c29?pvs=21"><strong>Socket browser extension</strong></a> to surface registry risk signals during discovery and installation.</p>
<h2>Indicators of Compromise (IOCs)</h2>
<h3>Malicious Open VSX Extensions (Suspected Developer Account <code>oorzc</code> Compromise)</h3>
<ol><li><a href="https://socket.dev/openvsx/package/oorzc.ssh-tools/overview/0.5.1?platform=universal"><code>oorzc.ssh-tools</code></a> — v0.5.1</li><li><a href="https://socket.dev/openvsx/package/oorzc.i18n-tools-plus/overview/1.6.8?platform=universal"><code>oorzc.i18n-tools-plus</code></a> — v1.6.8</li><li><a href="https://socket.dev/openvsx/package/oorzc.mind-map/overview/1.0.61"><code>oorzc.mind-map</code></a> — v1.0.61</li><li><a href="https://www.notion.so/GlassWorm-Loader-Hits-Open-VSX-via-Developer-Account-Compromise-2f84cb3adfeb8003985fffdbf5740c29?pvs=21"><code>oorzc.scss-to-css-compile</code></a> — v1.3.4</li></ol>
<h3>Malicious Open VSX Extensions (December 2025 — January 2026 Cluster)</h3>
<ol><li><a href="https://socket.dev/openvsx/package/Angular-studio.ng-angular-extension/overview"><code>Angular-studio.ng-angular-extension</code></a></li><li><a href="https://socket.dev/openvsx/package/awesome-codebase.codebase-dart-pro/overview"><code>awesome-codebase.codebase-dart-pro</code></a></li><li><a href="https://socket.dev/openvsx/package/cudra-production.vsce-prettier-pro/overview"><code>cudra-production.vsce-prettier-pro</code></a></li><li><a href="https://socket.dev/openvsx/package/dev-studio-sense.php-comp-tools-vscode/overview"><code>dev-studio-sense.php-comp-tools-vscode</code></a></li><li><a href="https://socket.dev/openvsx/package/ko-zu-gun-studio.synchronization-settings-vscode/overview"><code>ko-zu-gun-studio.synchronization-settings-vscode</code></a></li><li><a href="https://socket.dev/openvsx/package/littensy-studio.magical-icons/overview"><code>littensy-studio.magical-icons</code></a></li><li><a href="https://socket.dev/openvsx/package/pretty-studio-advisor.prettyxml-formatter/overview"><code>pretty-studio-advisor.prettyxml-formatter</code></a></li><li><a href="https://socket.dev/openvsx/package/sol-studio.solidity-extension/overview"><code>sol-studio.solidity-extension</code></a></li><li><a href="https://socket.dev/openvsx/package/studio-jjalaire-team.professional-quarto-extension/overview"><code>studio-jjalaire-team.professional-quarto-extension</code></a></li><li><a href="https://socket.dev/openvsx/package/studio-velte-distributor.pro-svelte-extension/overview"><code>studio-velte-distributor.pro-svelte-extension</code></a></li><li><a href="https://socket.dev/openvsx/package/sun-shine-studio.shiny-extension-for-vscode/overview"><code>sun-shine-studio.shiny-extension-for-vscode</code></a></li><li><a href="https://socket.dev/openvsx/package/tucyzirille-studio.angular-pro-tools-extension/overview"><code>tucyzirille-studio.angular-pro-tools-extension</code></a></li><li><a href="https://socket.dev/openvsx/package/vce-brendan-studio-eich.js-debuger-vscode/overview"><code>vce-brendan-studio-eich.js-debuger-vscode</code></a></li></ol>
<h3>Blockchain Indicators</h3>
<ul><li>Solana address: <code>BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC</code></li></ul>
<h3>Embedded Crypto Material</h3>
<ul><li>AES key: <code>wDO6YyTm6DL0T0zJ0SXhUql5Mo0pdlSz</code></li><li>AES IVs (hex): <code>c4b9a3773e9dced6015a670855fd32b</code></li></ul>
<h3>IP Address</h3>
<ul><li><code>45[.]32[.]150[.]251</code></li></ul>
</div>
