---
title: "2025 Blockchain and Cryptocurrency Threat Report: Malware in the Open Source Supply Chain"
short_title: "2025 Blockchain and Cryptocurrency Threat Report"
date: 2025-06-12 12:00:00 +0000
categories: [Threat Reports]
tags: [Infostealer, Crypto Drainer, Cryptojacker, Clipper, Cryptocurrency, npm, PyPI, Python, Contagious Interview, BeaverTail, InvisibleFerret, Typosquatting]
canonical_url: https://socket.dev/blog/2025-blockchain-and-cryptocurrency-threat-report
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/d5eeee442b3b411a6926a1ca1815bee969ca3fe1-1024x1024.webp
  alt: "2025 Blockchain and Cryptocurrency Threat Report"
description: "An in-depth analysis of credential stealers, crypto drainers, cryptojackers, and clipboard hijackers abusing open source package registries to compromise blockchain and cryptocurrency development environments."
---

Over the past year, the Socket Threat Research Team has documented a significant escalation in malware targeting the cryptocurrency and blockchain development ecosystem. These campaigns primarily leverage malicious open source packages published to trusted registries like npm and PyPI. This report provides insights from ongoing monitoring and reverse engineering, analyzing how financially motivated threat actors, including some nation-states groups, are evolving their toolkits to exploit developer environments and software supply chains.

In the past year, approximately 75% of the malicious blockchain-related packages tracked by the Socket Threat Research Team were hosted on npm, 20% on PyPI, and the remainder distributed across registries such as RubyGems, Go Modules, and others. While Ethereum and Solana continue to be the primary targets, recent campaigns have expanded to include TRON and TON, indicating growing threat actor interest in a wider range of wallet formats and alternative layer-1 blockchain platforms.

Blockchain developers, particularly those building decentralized applications (dApps), wallets, and supporting infrastructure, face distinct software supply chain risks. Their reliance on open source dependencies, combined with CI/CD pipelines that often lack strict dependency validation or isolation, creates a broad and exploitable attack surface.

## Four Recurring Threat Classes Dominate the Landscape

Our investigation has identified four threat classes that are consistently recurring across real-world supply chain attacks in 2025.

- **Credential Stealers** — These malicious packages extract cryptowallet secrets, browser-stored credentials, and keystore artifacts from both local developer machines and CI environments. They leverage file system access, browser data scraping, and runtime hooks to locate and exfiltrate sensitive data immediately upon installation or execution.

- **Crypto Drainers** — Unlike stealers that exfiltrate credentials for later use, drainers immediately initiate on-chain transactions to siphon funds once wallet access is gained. They often rely on public RPC endpoints, implement multi-hop transfers to obscure the money trail, and use probabilistic logic to selectively divert transactions, minimizing detection and maximizing stealth.

- **Cryptojackers** — These packages covertly exploit system resources to mine cryptocurrency. Threat actors embed mining logic into widely used tools, particularly those integrated into CI pipelines, to hijack CPU or GPU cycles for profit while avoiding detection through obfuscation, conditional execution, and silent background operation.

- **Clipboard Hijackers (Clippers)** — Clippers monitor the system clipboard for cryptocurrency wallet addresses and replace them with threat actor-controlled alternatives. Their simplicity, low privilege requirements, and ability to silently redirect funds make them a persistent and effective tactic observed across malicious npm and PyPI packages.

This list is neither exhaustive nor ranked by prevalence or impact, but rather highlights the patterns our team has repeatedly tracked, reverse-engineered, and documented across major open source registries. We report all confirmed malicious packages to the appropriate registry maintainers to support broader ecosystem defense and transparency.

![Credential Stealers icon](https://cdn.sanity.io/images/cgdhsj6q/production/0ed59564506b0738a5b2849c3f53a3996de47de9-165x164.png)

## Cryptowallet-Credential Stealers

Threat actors increasingly publish open source packages designed to extract seed phrases, private keys, keystore files, authentication tokens, and browser-stored credentials from developer machines and CI environments. We tracked multiple [waves](https://socket.dev/blog/malicious-npm-and-pypi-packages-steal-wallet-credentials) of credential-stealing packages in npm and PyPI, many embedding exfiltration logic via Telegram bots, Discord webhooks, Gmail SMTP, or blockchain RPC memo fields to bypass traditional detection mechanisms. Notable examples include [monkey-patched PyPI libraries](https://socket.dev/blog/monkey-patched-pypi-packages-steal-solana-private-keys) that steal Solana `id.json` files, npm packages that [exfiltrate credentials via Gmail](https://socket.dev/blog/gmail-for-exfiltration-malicious-npm-packages-target-solana-private-keys-and-drain-victim-s), and trojanized versions of `solana-web3.js` [engineered to capture private keys](https://socket.dev/blog/supply-chain-attack-solana-web3-js-library) from unsuspecting developers.

### How Cryptowallet-Credential Stealers Operate

### Direct File-System Scraping

Stealer packages scan known wallet directories, such as `~/.config/solana/id.json`, and `~/Library/Application Support/Exodus/exodus.wallet`, and exfiltrate unmodified wallet files. In a separate [monkey-patched PyPI campaign](https://socket.dev/blog/monkey-patched-pypi-packages-steal-solana-private-keys), the malware intercepted keypair generation by modifying Solana library methods at runtime, without altering the original source files, to capture secrets during creation rather than from the filesystem. On each keypair creation, it captured the private key, encrypted it with a hardcoded RSA-2048 public key, encoded it in Base64, and embedded the result in a `spl.memo` transaction sent to Solana Devnet, allowing the threat actor to retrieve and decrypt the stolen keys remotely.

Many stealers also abuse package lifecycle hooks (`postinstall` in npm, `setup.py` in PyPI) to trigger credential theft immediately upon installation, even if the package is not imported.

### Browser and Extension Harvesting

Stealer packages routinely crawl Chrome, Brave, and Firefox profile directories, extracting login data, extension storage, and wallet credentials. [`express-dompurify`](https://socket.dev/blog/malicious-express-dompurify-npm-package-steals-sensitive-data) targets browser profiles, Electrum wallets, and macOS keychains, exfiltrating data to a hardcoded C2 server. [`pumptoolforvolumeandcomment`](https://socket.dev/blog/malicious-npm-packages-use-telegram-to-exfiltrate-bullx-credentials) scrapes wallet keys and BullX trading data from Linux/macOS paths, transmitting it via Telegram bot API. [`@ton/crypto-core`](https://socket.dev/blog/ton-wallet-security-threat-malicious-npm-package-steals-cryptocurrency-wallet-keys) specifically targets TON wallet keys and leaks them to attacker infrastructure.

Across [multiple campaigns](https://socket.dev/blog/malicious-npm-packages-threaten-crypto-developers), including nation-state intrusions, threat actors use hardcoded browser extension IDs (MetaMask, Phantom, Binance Wallet, Coinbase Wallet) to locate and exfiltrate extension directories, aiming to capture private keys and session tokens tied to digital assets.

### Nation-State Supply Chain Intrusions

North Korea's [Contagious Interview](https://socket.dev/blog/north-korean-apt-lazarus-targets-developers-with-malicious-npm-package) campaign remains one of the most advanced credential theft operations, leveraging supply chain attacks to silently breach Web3 development pipelines. These attacks weaponize trusted developer tools (such as linters, validators, and post-processing libraries) to deliver credential stealers and backdoors.

We [track](https://socket.dev/blog/lazarus-expands-malicious-npm-campaign-11-new-packages-add-malware-loaders-and-bitbucket) North Korea-linked, state-sponsored npm campaigns that exploit the implicit trust placed in open source packages. Once installed, these packages compromise the entire downstream dApp stack, bypassing MFA, hardware wallets, and endpoint defenses.

The malware payloads (BeaverTail and InvisibleFerret) run on Windows, macOS, and Linux. BeaverTail scans for Solana `id.json`, browser profiles (Chrome, Brave, Firefox), and crypto extension folders (MetaMask, Phantom, Binance Wallet, Coinbase Wallet), exfiltrating credentials via silent HTTP POST. The malware also establishes persistence and enables long-term access. In one [high-profile breach](https://socket.dev/blog/bybit-hack-crypto-losses), North Korean threat actors used this approach to extract private keys and steal millions in cryptocurrency from Bybit within hours.

![Contagious Interview attack chain diagram](https://cdn.sanity.io/images/cgdhsj6q/production/bc2843a41579d71893f9e3531dc2bd0e40709740-2048x1333.png)
_Diagram that visually depicts the Contagious Interview attack chain for infiltrating Web3 development environments through malicious open source packages._

The attack begins with **reconnaissance and target** phase, where threat actors identify widely used developer tools in Web3 environments as high-trust injection points. As part of the lure, they impersonate recruiters and initiate staged interview processes to socially engineer targets into installing a malicious npm package disguised as a coding challenge or evaluation task.

They gain **initial access** by [publishing](https://socket.dev/blog/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages) typosquatted packages to open source registries, tricking developers into voluntary installation.

Upon installation, the package **executes** obfuscated JavaScript [tailored](https://socket.dev/blog/north-korean-apt-lazarus-targets-developers-with-malicious-npm-package) for Windows, macOS, and Linux. It [deploys](https://socket.dev/blog/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages) BeaverTail and InvisibleFerret, which initiate **credential harvesting** by scanning browser profiles (Chrome, Brave, Firefox), Solana wallet directories (`id.json`), and extension folders tied to MetaMask, Phantom, Binance Wallet, and Coinbase Wallet. The malware targets these sources to extract private keys and authentication tokens for digital assets.

The malware silently **exfiltrates** data via HTTP POST to C2 infrastructure. **Persistence** is established via scheduled tasks or startup entries, ensuring recurring access. In the **monetization** phase, the threat actors use stolen credentials to transfer assets directly into DPRK-controlled wallets, often within hours of compromise.

**Defensive Recommendations:** Monitor for suspicious package behavior, enforce dependency pinning and provenance verification, and inspect developer tooling dependencies for signs of credential access. Avoid installing low-reputation packages, especially those mimicking popular tooling. Deploy runtime monitoring for unauthorized keystore access and track outbound traffic to unusual endpoints.

![Crypto Drainers icon](https://cdn.sanity.io/images/cgdhsj6q/production/d9a9f1335e678f8158d3f48142060921d1863153-164x163.png)

## Crypto Drainers

Threat actors continue to publish open source packages built to directly siphon cryptocurrency from victim wallets. Unlike stealers that exfiltrate credentials for later use, crypto drainers extract or derive private keys and immediately initiate on-chain transfers. Most drainers send a fixed percentage of the wallet balance, often leaving a small remainder to avoid detection or preserve transaction fee margins.

### How Crypto Drainers Operate

Crypto drainers trigger immediate and irreversible fund loss by executing on-chain transfers as soon as they obtain or derive a private key. They often skip external C2s, minimizing detection and eliminating recovery opportunities once transactions are confirmed.

### Balance Probing and Fixed-Percentage Drains

Obfuscated code typically queries the wallet balance, multiplies it by a fixed ratio (e.g., 0.85), and crafts a `sendTransaction` or Solana SPL `transfer`. This partial-drain strategy reduces suspicion by leaving a small balance.

![Balance probing and fixed-percentage drains example](https://cdn.sanity.io/images/cgdhsj6q/production/9a7a872cad81edced52338d618e4c88a7d991de7-615x629.png)
_In June 2025, we [uncovered](https://socket.dev/blog/malicious-npm-packages-target-bsc-and-ethereum) a campaign involving [`env-process`](https://socket.dev/npm/package/env-process/overview/1.0.2) and related packages ([`ethereum-smart-contract`](https://socket.dev/npm/package/ethereum-smart-contract), [`pancake_uniswap_validators_utils_snipe`](https://socket.dev/npm/package/pancake_uniswap_validators_utils_snipe/overview/1.0.0), and [`pancakeswap-oracle-prediction`](https://socket.dev/npm/package/pancakeswap-oracle-prediction)) that siphoned 85% of ETH or BSC wallet balances. Obfuscated JavaScript retrieved balances via public RPC (`bsc-dataseed1.defibit.io`) and transferred funds to the threat actor-controlled addresses._

### Transfer Manipulation and Fund Diversion

Some drainers use probabilistic logic to skim funds quietly, hijacking only a small [fraction of transactions](https://socket.dev/blog/malicious-npm-package-targets-solana-developers-and-hijacks-funds) to evade detection. The [`solana-systemprogram-utils`](https://socket.dev/npm/package/solana-systemprogram-utils/overview/1.0.0) package, for example, reroutes 2% of outgoing Solana transfers to a hardcoded wallet using `Math.random() < 0.02`. In the remaining 98%, transactions complete normally (`props.toPubkey`), masking malicious behavior during casual use. This tactic enables slow, stealthy theft while preserving apparent functionality.

### Multi-Hop Transfers to Evade Detection

Advanced crypto drainers on networks like Solana use multi-hop transfers to obscure theft and frustrate forensic tracing. The [`bs58js`](https://socket.dev/npm/package/bs58js/overview/1.6.10) package demonstrates this: it decodes a Base58-encoded private key into a `Keypair`, drains the victim's wallet to the threat actor-controlled intermediary, then forwards funds to a final hardcoded wallet. Transactions are crafted to fully deplete the wallet, subtracting only fees.

The malware uses public RPC endpoints (e.g., `api.devnet.solana.com`) and requires no external C2, making the attack stealthy, irreversible, and hard to investigate.

**Defensive Recommendations:** Audit dependencies, particularly those accessing private keys or invoking on-chain transactions, for obfuscated code, probabilistic triggers, or unauthorized transfer routines. Prefer widely adopted, community-vetted packages with transparent maintainers. Integrate telemetry and auto-quarantine features to prevent known drainers from entering build pipelines or production deployments.

![Cryptojackers icon](https://cdn.sanity.io/images/cgdhsj6q/production/6bbc151ae421559a179ed0a1a54b4c7c74b4d444-163x160.png)

## Cryptojackers

Over the past year, we tracked a persistent stream of cryptojacking packages — malicious open source libraries that covertly hijack CPU or GPU resources to mine cryptocurrency. Cryptojacking packages typically trigger during `postinstall` (npm), `setup.py` (PyPI), or embedded shell commands, with no user interaction or visibility.

Among the most impactful cases was the temporary compromise of [`@rspack/core`](https://socket.dev/npm/package/@rspack/core/overview/1.1.7) and [`@rspack/cli`](https://socket.dev/npm/package/@rspack/cli/overview/1.1.7) (v1.1.7), during which threat actors inserted XMRig miner logic that deployed across [tens of thousands of CI runners](https://socket.dev/blog/rspack-supply-chain-attack). The malicious versions were quickly removed, and the maintainers have since restored the packages to a clean state. This incident underscored how cryptojackers can rapidly scale when injected into trusted build tooling, even briefly.

Other examples include the [`klow`](https://socket.dev/npm/package/klow/overview/0.7.29) package, which geofences execution by resolving the host's IP address and conditionally downloading XMRig from a suspicious CDN if the machine is outside specific countries, an evasion tactic designed to limit detection and maintain operational longevity.

![Socket AI Scanner analysis of klow package](https://cdn.sanity.io/images/cgdhsj6q/production/9b5d4f256b45e84f6113c3da004a01dad8a838af-621x669.png)
_Socket AI Scanner's analysis of [`klow@0.7.29`](https://socket.dev/npm/package/klow/overview/0.7.29), a known cryptojacking package that uses geolocation checks to geofence execution, downloads an XMRig binary from a remote server, and mines Monero in the background without user consent._

Multiple versions of the [`ultralytics`](https://socket.dev/pypi/package/ultralytics/overview/8.3.41) package (v8.3.41, 8.3.42, 8.3.45, 8.3.46) were temporary [compromised](https://socket.dev/blog/ultralytics-pypi-package-compromised-through-github-actions-cache-poisoning) via GitHub Actions [cache poisoning](https://socket.dev/blog/pypi-on-ultralytics-breach-no-security-flaws-in-pypi-exploited), resulting in cryptomining payloads being shipped under the guise of machine learning enhancements. The maintainers have since remediated the issue and restored integrity to the package. Similarly, the [`kersa`](https://socket.dev/pypi/package/kersa/overview/0.1/tar-gz) package on PyPI fetched and launched a cryptominer headlessly via shell commands.

![Cryptojacking malware execution flow](https://cdn.sanity.io/images/cgdhsj6q/production/783067842886a4cc51c8f3124a84c8c24e71982b-2048x1095.png)
_Execution flow of cryptojacking malware in open source packages, illustrating four distinct stages: obfuscated installation, remote cryptominer retrieval, covert background execution, and conditional evasion logic such as geofencing or log cleanup._

Cryptojackers may not steal credentials or wallet keys, but they exploit infrastructure for profit, and often as a smokescreen for deeper intrusions. They burden cloud runners with inflated compute costs and slow local development environments. If shipped in production, they can also damage user trust and project credibility. Any illicit cryptominer should be treated as a high-confidence indicator of a software supply chain compromise.

**Defensive Recommendations:** Enforce dependency controls and monitor infrastructure behavior. Disable lifecycle scripts like `postinstall` and `setup.py` by default in CI/CD pipelines to block common infection paths, while monitoring for abnormal CPU/GPU usage during builds to detect stealthy cryptominers. Inspect outbound traffic for signs of cryptominer downloads or connections to mining pools, and enforce dependency hash pinning with provenance checks to catch unauthorized changes — such as those seen in the compromised `@rspack/core` package.

![Clipboard Hijackers icon](https://cdn.sanity.io/images/cgdhsj6q/production/0d681b3b5b732d3990cdfcf0e9c0a06fc8c79e11-165x163.png)

## Clipboard Hijackers ("Clippers")

Clipboard hijackers, or "clippers", are lightweight malware modules that monitor the system clipboard for cryptocurrency wallet strings, replace them with threat actor-controlled addresses, and silently wait for the victim to authorize the payment. We identified a steady flow of these clippers in npm and PyPI ecosystems tuned for developer workstations and CI runners.

![Socket AI Scanner analysis of raydium-sdk-liquidity-init](https://cdn.sanity.io/images/cgdhsj6q/production/68ae8fe0ec033b5b1585a1f1404d8b501f9e18e5-1436x578.png)
_Socket AI Scanner providing context for the malicious npm package [`raydium-sdk-liquidity-init@1.0.2`](https://socket.dev/npm/package/raydium-sdk-liquidity-init/overview/1.0.2) contains obfuscated JavaScript flagged as known malware. It continuously monitors the system clipboard for Solana private keys, validates them, and exfiltrates the data to a remote Redis server using hardcoded credentials._

### How Clippers Work

Clippers represent a deceptively simple but highly effective form of credential and cryptocurrency theft, exploiting clipboard access to intercept and replace sensitive data in real time. These threats typically install via `postinstall` scripts, `setup.py`, or runtime `require()` hooks, ensuring that malicious logic activates immediately, even if the package is never imported or used.

Once active, the malware continuously polls the system clipboard, applying regex patterns to identify wallet address formats, such as `0x[a-fA-F0-9]{40}` for Ethereum or `^[1-9A-H-J-N-P-Z]{32,44}$` for Solana. When a match is found, the clippers silently substitute the captured address with a threat actor-controlled address, which may be hardcoded or dynamically retrieved from a smart contract. Some variants also beacon the original clipboard contents or host fingerprints to remote C2 endpoints for exfiltration or success analytics.

Multiple packages in the npm and PyPI ecosystems illustrate the evolving reach of this threat class. The PyPI package [`lsjglsjdv`](https://socket.dev/pypi/package/lsjglsjdv) uses platform-specific system commands (`xclip`, `pbpaste`, `Get-Clipboard`) to read the clipboard and POST its contents to `https://cl1p[.]net/{url_id}`, effectively enabling real-time exfiltration of passwords, tokens, or wallet addresses without user awareness.

Another example, PyPI's [`asyncaiosignal`](https://socket.dev/pypi/package/asyncaiosignal), pairs clipboard hijacking with broader infostealer capabilities — it logs keystrokes via `pynput`, extracts data from browsers and messaging apps, and sends the stolen information to a Telegram bot using hardcoded credentials.

On npm side, besides above-mentioned [`raydium-sdk-liquidity-init@1.0.2`](https://socket.dev/npm/package/raydium-sdk-liquidity-init/overview/1.0.2), the package [`multicogs`](https://socket.dev/npm/package/multicogs) creates a PowerShell loop that runs every three seconds, scanning clipboard contents for a wide range of cryptocurrency patterns (BTC, ETH, LTC, DOGE, XMR, ADA, XRP, and more). If a match is found and differs from the threat actor's preloaded address map, the package replaces the clipboard contents with the malicious substitute, diverting user funds to the threat actor's wallet silently.

Because clippers rely on clipboard APIs and regex logic rather than external C2s or high-privilege exploits, they often evade basic static analysis and runtime detection. Their simplicity, cross-platform reach, and ability to directly hijack user transactions make them a favored tool for opportunistic financial theft, particularly in blockchain environments where clipboard-based address copying is common and errors are irreversible.

**Defensive Recommendations:** Block clipboard APIs in production builds unless explicitly needed, and statically scan dependencies for wallet regexes paired with `clipboardy`, `electron.clipboard`, or `pyperclip` calls. Alert when background clipboard monitors run, and pin dependencies with provenance checks so a stealth update cannot insert clipper logic into your pipeline.

## Outlook and Recommendations

As Web3 development converges with mainstream software engineering, the attack surface for blockchain-focused projects is expanding in both scale and complexity. Our analysis confirms that financially motivated threat actors and state-sponsored groups are rapidly evolving their tactics to exploit systemic weaknesses in the software supply chain. They embed stealers, crypto drainers, cryptojackers, and clippers into popular open source packages to compromise development environments. These campaigns are iterative, persistent, and increasingly tailored to high-value targets.

In the near term, defenders should expect continued reuse of modular malware components, particularly stealer kits bundled with clipboard hijackers or drainers, and an expansion in targeting beyond Ethereum and Solana to include TRON, TON, and emerging Layer-1 ecosystems. We also anticipate increased abuse of CI/CD infrastructure as a scalable delivery vector, leveraging `postinstall` scripts and `setup` routines to propagate malicious packages across build pipelines and developer environments.

To mitigate these evolving threats, development teams and organizations must strengthen software supply chain hygiene. This includes enforcing strict provenance validation for all dependencies, disabling unnecessary lifecycle hooks (e.g., `postinstall`, `setup.py`) within CI/CD pipelines, and auditing for clipboard access, file system scraping, and other suspicious behaviors. Security tooling should incorporate telemetry capable of detecting obfuscated code and wallet-aware logic. Both static and dynamic analysis must advance to uncover multi-stage payloads and low-privilege data exfiltration techniques that routinely evade traditional scanners.

Socket's free tools are purpose-built for this threat landscape. The [**Socket GitHub App**](https://socket.dev/features/github) blocks pull requests that introduce suspicious packages, the [**Socket CLI**](https://socket.dev/features/cli) flags risky behavior during installation, and the [**Socket browser extension**](https://socket.dev/features/web-extension) provides real-time alerts about malware and typosquats directly on package pages. Socket's tools offer proactive defenses against the persistent threat of supply chain attacks.
