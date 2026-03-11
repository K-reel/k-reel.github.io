---
icon: fas fa-book-open
order: 1
hide_title: true
---

![Publications Banner](/assets/img/banner.jpg)

<style>
  /* Make banner stretch to the panel divider */
  .content > p:first-child a { display: block; }
  .content > p:first-child img {
    width: 100vw;
    max-width: none;
    display: block;
    position: relative;
    left: 50%;
    transform: translateX(-50%);
  }
  @media (min-width: 1200px) {
    .content > p:first-child img {
      /* On xl: stretch from left edge of content to the panel divider */
      width: calc(100% + 5rem);
      left: -1.75rem;
      transform: none;
    }
  }
  .content details summary { font-size: 1.2rem; }
  .content details ul { margin-top: 0.25rem; }
  #toggle-all {
    border: none;
    background: #fff;
    color: #000;
    padding: 0.45rem 1.1rem;
    border-radius: 0.5rem;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
    letter-spacing: 0.02em;
    transition: opacity 0.2s;
  }
  #toggle-all:hover {
    opacity: 0.85;
  }
</style>

<button id="toggle-all" onclick="(function(){
  var details = document.querySelectorAll('.content details');
  var anyOpen = Array.from(details).some(function(d){ return d.open; });
  details.forEach(function(d){ d.open = !anyOpen; });
  document.getElementById('toggle-all').textContent = anyOpen ? 'Expand All' : 'Collapse All';
})()">Expand All</button>

<details>
<summary>🇰🇵 <strong>North Korea — Contagious Interview</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/north-korea-contagious-interview-npm-attacks/">Inside the GitHub Infrastructure Powering North Korea's Contagious Interview npm Attacks</a>
  </li>
  <li class="px-md-3">
    <a href="/north-korea-contagious-interview-campaign-338-malicious-npm-packages/">North Korea's Contagious Interview Campaign Escalates: 338 Malicious npm Packages, 50,000 Downloads</a>
  </li>
  <li class="px-md-3">
    <a href="/contagious-interview-campaign-escalates-67-malicious-npm-packages/">Contagious Interview Campaign Escalates With 67 Malicious npm Packages and New Malware Loader</a>
  </li>
  <li class="px-md-3">
    <a href="/north-korean-contagious-interview-campaign-drops-35-new-malicious-npm-packages/">Another Wave: North Korean Contagious Interview Campaign Drops 35 New Malicious npm Packages</a>
  </li>
  <li class="px-md-3">
    <a href="/lazarus-expands-malicious-npm-campaign-11-new-packages-add-malware-loaders-and-bitbucket/">Lazarus Expands Malicious npm Campaign: 11 New Packages Add Malware Loaders and Bitbucket Payloads</a>
  </li>
  <li class="px-md-3">
    <a href="/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages/">Lazarus Strikes npm Again with New Wave of Malicious Packages</a>
  </li>
  <li class="px-md-3">
    <a href="/north-korean-apt-lazarus-targets-developers-with-malicious-npm-package/">North Korean APT Lazarus Targets Developers with Malicious npm Package</a>
  </li>
</ul>
</details>

<details>
<summary>🧯 <strong>Supply Chain Incidents</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/sandworm-mode-npm-worm-ai-toolchain-poisoning/">SANDWORM_MODE: Shai-Hulud-Style npm Worm Hijacks CI Workflows and Poisons AI Toolchains</a>
  </li>
  <li class="px-md-3">
    <a href="/shai-hulud-strikes-again-v2/">Shai Hulud Strikes Again (v2)</a>
  </li>
  <li class="px-md-3">
    <a href="/tinycolor-supply-chain-attack-affects-40-packages/">Popular Tinycolor npm Package Compromised in Supply Chain Attack Affecting 40+ Packages</a>
  </li>
  <li class="px-md-3">
    <a href="/npm-is-package-hijacked-in-expanding-supply-chain-attack/">npm 'is' Package Hijacked in Expanding Supply Chain Attack</a>
  </li>
  <li class="px-md-3">
    <a href="/massive-npm-malware-campaign-leverages-ethereum-smart-contracts/">Massive npm Malware Campaign Leverages Ethereum Smart Contracts To Evade Detection and Maintain Control</a>
  </li>
</ul>
</details>

<details>
<summary>📊 <strong>Threat Landscape &amp; Cross-Ecosystem Research</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/surveillance-malware-hidden-in-npm-and-pypi-packages/">Surveillance Malware Hidden in npm and PyPI Packages Targets Developers with Keyloggers, Webcam Capture, and Credential Theft</a>
  </li>
  <li class="px-md-3">
    <a href="/fraudulent-engineering-candidates-investigation/">Identifying and Preventing Fraudulent Engineering Candidates: An Investigation into 80 Confirmed Cases</a>
  </li>
  <li class="px-md-3">
    <a href="/2025-blockchain-and-cryptocurrency-threat-report/">2025 Blockchain and Cryptocurrency Threat Report: Malware in the Open Source Supply Chain</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-open-source-packages-2025-mid-year-threat-report/">The Landscape of Malicious Open Source Packages: 2025 Mid‑Year Threat Report</a>
  </li>
  <li class="px-md-3">
    <a href="/weaponizing-oast-how-malicious-packages-exploit-npm-pypi-and-rubygems/">Weaponizing OAST: How Malicious Packages Exploit npm, PyPI, and RubyGems for Data Exfiltration and Recon</a>
  </li>
</ul>
</details>

<details>
<summary>📦 <strong>npm / JavaScript / TypeScript</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/spearphishing-campaign-abuses-npm-registry/">Spearphishing Campaign Abuses npm Registry to Target U.S. and Allied Manufacturing and Healthcare Organizations</a>
  </li>
  <li class="px-md-3">
    <a href="/wallet-draining-npm-package-impersonates-nodemailer/">Wallet-Draining npm Package Impersonates Nodemailer to Hijack Crypto Transactions</a>
  </li>
  <li class="px-md-3">
    <a href="/60-malicious-npm-packages-leak-network-and-host-data/">60 Malicious npm Packages Leak Network and Host Data in Active Malware Campaign</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-koishi-chatbot-plugin/">Malicious Koishi Chatbot Plugin Exfiltrates Messages Triggered by 8-Character Hex Strings</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-npm-packages-hijack-cursor-editor-on-macos/">Backdooring the IDE: Malicious npm Packages Hijack Cursor Editor on macOS</a>
  </li>
  <li class="px-md-3">
    <a href="/black-basta-dependency-confusion-ambitions-and-ransomware-in-open-source-ecosystems/">Black Basta's Dependency Confusion Ambitions and Ransomware in Open Source Ecosystems</a>
  </li>
  <li class="px-md-3">
    <a href="/gmail-for-exfiltration-malicious-npm-packages-target-solana-private-keys-and-drain-victim-s/">Gmail For Exfiltration: Malicious npm Packages Target Solana Private Keys and Drain Victims' Wallets</a>
  </li>
  <li class="px-md-3">
    <a href="/quasar-rat-disguised-as-an-npm-package/">Quasar RAT Disguised as an npm Package for Detecting Vulnerabilities in Ethereum Smart Contracts</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-npm-packages-threaten-crypto-developers/">Typosquatting Cryptographic Libraries: Malicious npm Packages Threaten Crypto Developers with Keylogging and Wallet Theft</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-npm-packages-inject-ssh-backdoors-via-typosquatted-libraries/">Malicious npm Packages Inject SSH Backdoors via Typosquatted Libraries</a>
  </li>
  <li class="px-md-3">
    <a href="/skuld-infostealer-returns-to-npm/">Skuld Infostealer Returns to npm with Fake Windows Utilities and Malicious Solara Development Packages</a>
  </li>
  <li class="px-md-3">
    <a href="/roblox-developers-targeted-with-npm-packages-infected-with-infostealers/">Roblox Developers Targeted with npm Packages Infected with Skuld Infostealer and Blank Grabber</a>
  </li>
  <li class="px-md-3">
    <a href="/author-typosquatting-on-npm/">Author Typosquatting on npm: Attackers Impersonate Sindre Sorhus with Malicious 'chalk-node' Package</a>
  </li>
</ul>
</details>

<details>
<summary>🐍 <strong>PyPI / Python</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/pypi-package-impersonates-sympy-to-deliver-cryptomining-malware/">PyPI Package Impersonates SymPy to Deliver Cryptomining Malware</a>
  </li>
  <li class="px-md-3">
    <a href="/monkey-patched-pypi-packages-steal-solana-private-keys/">Monkey-Patched PyPI Packages Use Transitive Dependencies to Steal Solana Private Keys</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-npm-and-pypi-packages-steal-wallet-credentials/">The Bad Seeds: Malicious npm and PyPI Packages Pose as Developer Tools to Steal Wallet Credentials</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-pypi-package-exploits-deezer-api-for-coordinated-music-piracy/">Malicious PyPI Package Exploits Deezer API for Coordinated Music Piracy</a>
  </li>
  <li class="px-md-3">
    <a href="/typosquatting-on-pypi-malicious-package-mimics-popular-browser-cookie-library/">Typosquatting on PyPI: Malicious Package Mimics Popular 'browser-cookie3' Library to Steal Sensitive Data</a>
  </li>
</ul>
</details>

<details>
<summary>🐹 <strong>Go Modules / Golang</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/malicious-go-crypto-module-steals-passwords/">Malicious Go "crypto" Module Steals Passwords and Deploys Rekoobe Backdoor</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-go-packages-impersonate-googles-uuid-library-and-exfiltrate-data/">Malicious Go Packages Impersonate Google's UUID Library and Exfiltrate Data</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-go-module-disguised-as-ssh-brute-forcer-exfiltrates-credentials/">Malicious Go Module Disguised as SSH Brute Forcer Exfiltrates Credentials via Telegram</a>
  </li>
  <li class="px-md-3">
    <a href="/typosquatted-go-packages-deliver-malware-loader/">Typosquatted Go Packages Deliver Malware Loader Targeting Linux and macOS Systems</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-package-exploits-go-module-proxy-caching-for-persistence/">Go Supply Chain Attack: Malicious Package Exploits Go Module Proxy Caching for Persistence</a>
  </li>
</ul>
</details>

<details>
<summary>☕ <strong>Maven Central / Java</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/malicious-maven-package-impersonating-xz-for-java-library/">Malicious Maven Package Impersonating 'XZ for Java' Library Introduces Backdoor Allowing Remote Code Execution</a>
  </li>
</ul>
</details>

<details>
<summary>♦️ <strong>RubyGems / Ruby</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/60-malicious-ruby-gems-used-in-targeted-credential-theft-campaign/">60 Malicious Ruby Gems Used in Targeted Credential Theft Campaign</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-ruby-gems-exfiltrate-telegram-tokens-and-messages-following-vietnam-ban/">Malicious Ruby Gems Exfiltrate Telegram Tokens and Messages Following Vietnam Ban</a>
  </li>
</ul>
</details>

<details>
<summary>⚙️ <strong>NuGet / .NET</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/malicious-nuget-package-typosquats-popular-net-tracing-library/">Malicious NuGet Package Typosquats Popular .NET Tracing Library to Steal Wallet Passwords</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-nuget-packages-typosquat-nethereum-to-exfiltrate-wallet-keys/">Malicious NuGet Packages Typosquat Nethereum to Exfiltrate Wallet Keys</a>
  </li>
</ul>
</details>

<details>
<summary>🦀 <strong>Rust / Crates</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/5-malicious-rust-crates-posed-as-time-utilities-to-exfiltrate-env-files/">5 Malicious Rust Crates Posed as Time Utilities to Exfiltrate .env Files</a>
  </li>
  <li class="px-md-3">
    <a href="/two-malicious-rust-crates-impersonate-popular-logger-to-steal-wallet-keys/">Two Malicious Rust Crates Impersonate Popular Logger to Steal Wallet Keys</a>
  </li>
</ul>
</details>

<details>
<summary>🧩 <strong>Extensions / Chrome / VS Code / OpenVSX</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/fake-imtoken-chrome-extension-steals-seed-phrases-via-phishing-redirects/">Fake imToken Chrome Extension Steals Seed Phrases via Phishing Redirects</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-chrome-extension-steals-meta-business-manager-exports-and-totp-2fa-seeds/">Malicious Chrome Extension Steals Meta Business Manager Exports and TOTP 2FA Seeds</a>
  </li>
  <li class="px-md-3">
    <a href="/glassworm-loader-hits-open-vsx-via-suspected-developer-account-compromise/">GlassWorm Loader Hits Open VSX via Developer Account Compromise</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-chrome-extension-steals-mexc-api-keys/">Malicious Chrome Extension Steals MEXC API Keys for Account Takeover</a>
  </li>
  <li class="px-md-3">
    <a href="/malicious-chrome-extension-exfiltrates-seed-phrases/">Malicious Chrome Extension Exfiltrates Seed Phrases, Enabling Wallet Takeover</a>
  </li>
  <li class="px-md-3">
    <a href="/131-spamware-extensions-targeting-whatsapp-flood-chrome-web-store/">131 Spamware Extensions Targeting WhatsApp Flood Chrome Web Store</a>
  </li>
</ul>
</details>

<details>
<summary>🕵️ <strong>Cybercrime, Underground Economy &amp; Influence Research</strong></summary>
<ul class="content ps-0">
  <li class="px-md-3">
    <a href="/exploiting-npm-to-build-a-blockchain-powered-botnet/">Threat Actor Exposes Playbook for Exploiting npm to Build Blockchain-Powered Botnets</a>
  </li>
  <li class="px-md-3">
    <a href="/noxia-emerging-dark-web-bulletproof-hosting-provider/">Noxia: Emerging Dark Web Hosting Provider Targets Python, Node.js, Go, and Rust Ecosystems</a>
  </li>
  <li class="px-md-3">
    <a href="/current-trends-in-the-turkish-language-dark-web/">Current Trends in the Turkish-Language Dark Web</a>
  </li>
  <li class="px-md-3">
    <a href="/combating-human-trafficking-with-threat-intelligence-prosecution/">Combating Human Trafficking With Threat Intelligence — Prosecution</a>
  </li>
</ul>
</details>
