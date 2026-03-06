---
title: "131 Spamware Extensions Targeting WhatsApp Flood Chrome Web Store"
short_title: "131 Spamware Extensions Targeting WhatsApp"
date: 2025-10-18 12:00:00 +0000
categories: [Threat Intelligence, Browser Extensions]
tags: [Chrome, Extensions, Spam, Brazil, T1176.001, T1204, T1059.007, T1217, T1005]
description: "The Socket Threat Research Team uncovered a coordinated campaign that floods the Chrome Web Store with 131 rebranded clones of a WhatsApp Web automation extension to spam Brazilian users."
toc: true
canonical_url: https://socket.dev/blog/131-spamware-extensions-targeting-whatsapp-flood-chrome-web-store
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/c394305b7a4adb7bd3e8f475e9b37e94f63c697d-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: 131 spamware Chrome extensions targeting WhatsApp artwork
---

This cluster of Chrome extensions comprises 131 rebrands of a single tool, all sharing the same codebase, design patterns, and infrastructure. They are not classic malware, but they function as high-risk spam automation that abuses platform rules.

The code injects directly into the WhatsApp Web page, running alongside WhatsApp's own scripts, automates bulk outreach and scheduling in ways that aim to bypass WhatsApp anti-spam enforcement. Listings and marketing sites claim that their Chrome Web Store presence implies a rigorous audit and full privacy compliance. That claim is inaccurate and conflicts with Chrome and WhatsApp policies. At the supply chain level, this is policy abuse that enables spam at scale. Across listings with visible counts, these extensions account for at least 20,905 active users.

All 131 extensions were live in the Chrome Web Store at the time of writing. We have filed takedown requests with the Chrome security team and requested suspension of the related publisher accounts for [policy](https://developer.chrome.com/docs/webstore/program-policies/policies#spam_and_abuse) violating spamware.

![](https://cdn.sanity.io/images/cgdhsj6q/production/5c4b07e1fb1314f0c34e66c33bc1284029e9d8b9-620x564.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flags the Chrome extension [mnbdaobmkdglnmiagimcniebbgebabek](https://socket.dev/chrome/package/mnbdaobmkdglnmiagimcniebbgebabek) (Organize-C) as malware due to spamware behavior: it injects code into the WhatsApp Web page to automate bulk messaging and scheduling, violates Chrome Web Store and WhatsApp policies._

## Gaming the Store

Based on Chrome Web Store timestamps and our captures of the 131 unique listings (see IOCs), the operation has run for at least nine months. Rebrands and updates landed in regular waves throughout 2025, with new uploads and version bumps observed as recently as October 14, 2025.

![](https://cdn.sanity.io/images/cgdhsj6q/production/83178b504c86f85bdf55a3f8e5e1f56ffc4708f4-1226x901.png?w=1600&q=95&fit=max&auto=format)

![](https://cdn.sanity.io/images/cgdhsj6q/production/316994ef1695f6f3cb0e3c0cf1a7105e5dac2d86-1226x904.png?w=1600&q=95&fit=max&auto=format)

![](https://cdn.sanity.io/images/cgdhsj6q/production/fac14345d4fbf69ebf88f67e48c1426c43ee5d92-1227x905.png?w=1600&q=95&fit=max&auto=format)

> *Chrome Web Store listings, top to bottom: [`YouSeller`](https://socket.dev/chrome/package/mkbjflhgpickfellipdmpcnhkmmdcojl) (10,000 users), [`performancemais`](https://socket.dev/chrome/package/mppgfleddoodfifpkjjjdbngnkcfcnde) (239 users), and [`Botflow`](https://socket.dev/chrome/package/ehdekncpobdjejklgpgnjgddjdnblmei) (38 users). Each shows the same WhatsApp Web automation interface, consistent with a spamware clone cluster that reuses design, imagery, descriptions, and codebase. Note: the "users" metric reflects active users, not total installs.*

Extensions use different names, logos, and glossy landing pages, but the code and infrastructure are the same. The dominant publisher label is `WL Extensão` and its variant `WLExtensao`, which appears on 83 listings. Despite the varied branding, the entire cluster was published through only two developer accounts: `suporte@grupoopt.com[.]br` and `kaio.feitosa@grupoopt.com[.]br`. The features look business facing, but the operational goal is aggressive outbound messaging that aims to evade WhatsApp rate limits and anti-spam controls.

## Marketing Strategy

It is akin to a franchise model: the operator and affiliated sellers publish dozens of near identical copies under new names and logos, then promote them with lookalike sites that sell monthly plans and pitch investment benefits in Portuguese to Brazilian small businesses. Many of these sites claim that Chrome Web Store inclusion means a rigorous audit and code review that guarantees privacy and safety. Chrome's process is a policy compliance review, not a certification, and presenting it as an audit misleads buyers and creates a false sense of security.

For clarity, screenshots in this post include translations from Portuguese to English.

![](https://cdn.sanity.io/images/cgdhsj6q/production/e18e19125ef914c138dca28bf40094d4caf14bdc-971x456.png?w=1600&q=95&fit=max&auto=format)
_[ZapVende](https://socket.dev/chrome/package/oohihogmmfbinbkgaiglgeabloiehlkk), one of the extensions in this cluster, is marketed at zapvende[.]com, which asserts the extension is safe simply because it is listed in the Chrome Web Store._

`DBX Tecnologia` (DBX Technology Group), the operator of the original extension that spawned 131 clones, markets a reseller program. `DBX Tecnologia` and `Grupo OPT`, which operates the `grupoopt.com[.]br` domain, are effectively two arms of the same business under the same founder, not unrelated companies. Both [describe](https://blog.optbot.com.br/conheca-o-grupo-opt/#:~:text=Atualmente%2C%20trabalhamos%20com%203%20solu%C3%A7%C3%B5es%2C,s%C3%A3o%20elas) their work as an ecosystem that builds WhatsApp-based solutions, among other products.

![](https://cdn.sanity.io/images/cgdhsj6q/production/0a0b9a0cfedfa8ad6c1225803ea5fc87a7af213a-933x411.png?w=1600&q=95&fit=max&auto=format)
_DBX Tecnologia reseller white-label program: invest R$12,000 (~USD $2,180) to rebrand and sell its WhatsApp Web extension under your own name, with promised 30 to 70 percent margins and R$30,000 to R$84,000 (~USD $5,450 to ~USD $15,270) in recurring revenue, illustrating the "franchise model" behind the 131 clone flood._

Based on the `DBX Tecnologia` YouTube [pitch](https://youtu.be/rw4HWAb-LSM?list=TLGG_oDyN6rAb7UxNzEwMjAyNQ), a "white-label partnership" means that:

- DBX supplies the product, the partner supplies the brand. The partner pays an upfront fee to license the WhatsApp Web automation extension, DBX swaps in the partner's logo, name, some design features, and provides marketing assets and tutorials.
- The partner publishes and sells it as if it were their own tool.
- DBX maintains the core code and backend. The partner's branded build still communicates with DBX-controlled services when features are used, and receives updates from the same codebase.
- Revenue flows to the partner minus DBX program fees or revenue share. DBX advertises high margins and recurring income because partners resell subscriptions to end customers.

Practical caveats: if listed as a publisher, the partner carries policy and reputational risk. Bulk messaging with spam scheduling collide with WhatsApp's opt-in rules and Chrome Web Store spam and duplication policies, so partners and their customers face takedowns and account bans. If features route media to vendor infrastructure, the partner must disclose that data flow and provide a privacy policy.

## Distribution Infrastructure

[`Lobo Vendedor`](https://socket.dev/chrome/package/nhmcfloglkbnliknncnfnlhideepfpfi) is marketed at `lobovendedor[.]com[.]br`, one of at least 23 near-identical sites we found that promote individually branded clones of the same extension. Many of the extensions are also backed by matching YouTube, LinkedIn, Instagram, and TikTok accounts that funnel buyers into subscriptions.

The pitch centers on aggressive outreach at scale on WhatsApp, with automation, templates, and scheduling that maximize reach. This reseller strategy multiplies distribution, and it steers customers toward conduct that violates Chrome Web Store rules on duplicate and spammy extensions and WhatsApp's requirement for recipient opt-in. The impact lands on ordinary users, who receive unsolicited promotional messages at volume, and the burden of defense shifts to recipients who must block numbers and report abuse after the fact.

![](https://cdn.sanity.io/images/cgdhsj6q/production/b074b441f4f89018ddf88b23294a5169eb1ad5e8-1217x932.png?w=1600&q=95&fit=max&auto=format)
_Lobo Vendedor marketing page (lobovendedor[.]com[.]br) promotes a rebranded clone of the WhatsApp Web automation extension, resold to agencies and SMBs for bulk outreach. The site illustrates the reseller model driving this clone cluster and pushes mass messaging that conflicts with WhatsApp's opt-in rules._

## Chrome Web Store Policy in Context

Google's Chrome Web Store Spam and Abuse [policy](https://developer.chrome.com/docs/webstore/program-policies/spam-and-abuse) bans developers and their affiliates from submitting multiple extensions that provide duplicate experiences. It also prohibits manipulating placement through ratings or installs, blocks extensions that send spam or unwanted messages, and forbids sending messages on a user's behalf without giving the user a chance to confirm the content and recipients. These rules map directly to our findings: the cluster consists of near identical copies spread across publisher accounts, is marketed for bulk unsolicited outreach, and automates message sending inside `web.whatsapp.com` without user confirmation.

![](https://cdn.sanity.io/images/cgdhsj6q/production/349b506596bbbfeab1aaaa96a039b31d15501b80-2048x1178.png?w=1600&q=95&fit=max&auto=format)
_Chrome Web Store Spam and Abuse [policy](https://developer.chrome.com/docs/webstore/program-policies/spam-and-abuse), which the clone cluster violates by publishing duplicate experiences and by enabling spam and automated messaging on a user's behalf._

## WhatsApp Business Policy in Context

WhatsApp's Business Messaging [policy](https://business.whatsapp.com/policy) requires explicit opt-in before a business contacts a person, places the burden of proving that opt-in on the sender, and mandates fast honoring of block and opt-out requests. It also instructs businesses not to deceive, mislead, or spam and to comply with applicable laws. The extensions in this cluster are marketed for bulk outreach and ban evasion, not consent-driven conversations.

![](https://cdn.sanity.io/images/cgdhsj6q/production/990357219dcd718f4652184158701f38cd788e0b-2048x806.png?w=1600&q=95&fit=max&auto=format)
_WhatsApp Business Messaging policy requires opt-in and forbids spam or surprise messaging._

Contrary to WhatsApp's Business Messaging policy, the operators publish tutorials that teach circumvention rather than consent-based use. In a YouTube [video](https://youtu.be/eIkNI6oFAhU?si=5i4sGrYXQ1QNLqMr) by `DBX Tecnologia`, the author describes how to avoid bans by shaping traffic, for example tuning send intervals, pauses, and batch sizes, and by using templates that vary message text to reduce detection.

The goal is to keep bulk campaigns running while evading anti-spam systems. This marketing aligns with what we verified in code: document-start injection into WhatsApp Web, use of `window.WPP.*` helpers for message dispatch, and scheduled send logic via a Manifest V3 service worker. Together, the video and extension UI corroborate our assessment that the product is built to automate bulk messaging and to tune sending patterns in ways that aim to avoid WhatsApp anti-spam enforcement.

![](https://cdn.sanity.io/images/cgdhsj6q/production/7ee434a7e667e3d0cbe3b2b679d874ee00db8e97-1920x1080.png?w=1600&q=95&fit=max&auto=format)
_In a YouTube [tutorial](https://youtu.be/eIkNI6oFAhU?si=5i4sGrYXQ1QNLqMr), the author demonstrates the extension's bulk-send screen, showing controls for send intervals, pauses, and batch size, and explicitly explains how to use it to bypass WhatsApp's anti-spam algorithms._

## Outlook and Recommendations

This campaign demonstrates policy abuse at scale that looks and behaves like a software supply chain, a single codebase cloned, lightly rebranded, and resold through affiliates. The commercial wrapper, storefronts, social channels, and tutorials, normalizes spamming that violates Chrome Web Store and WhatsApp rules. The result is wide reach, continuous re-uploads, and durability against takedowns.

Socket can turn these findings into detection and control. Use Socket's [Chrome extension protection](https://socket.dev/blog/socket-now-protects-the-chrome-extension-ecosystem) to inventory every extension in use, surface permissions and host access, and block risky updates before they land on endpoints. The same analysis engine that flags supply chain risk in open source packages now scans hundreds of thousands of extensions and alerts on behaviors such as excessive permissions, unexpected page access, and data exfiltration.

Fold Socket into existing guardrails. Enforce allowlists in Chrome Enterprise, restrict installs to approved extension IDs, and track permission creep over time. Pair Socket's visibility with network policy for egress control, then watch for lookalike domains as operators rotate infrastructure.

## MITRE ATT&CK

- T1176.001 — Software Extensions: Browser Extensions
- T1204 — User Execution
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1217 — Browser Information Discovery
- T1005 — Data from Local System

## Indicators of Compromise (IOCs)

### Email Addresses

- `suporte@grupoopt.com[.]br`
- `kaio.feitosa@grupoopt.com[.]br`

### Chrome Extensions and Active Users

1. [`gioekliddhmaanejaaigfokghoakbaco`](https://socket.dev/chrome/package/gioekliddhmaanejaaigfokghoakbaco) (WaveZap CRM) — 112 users
2. [`ephcniiibhpjpfpopmajlmbbijfjpdde`](https://socket.dev/chrome/package/ephcniiibhpjpfpopmajlmbbijfjpdde) (WaCelery) — users not shown
3. [`fbkpechbcdilkoadejmhhamidddhdehc`](https://socket.dev/chrome/package/fbkpechbcdilkoadejmhhamidddhdehc/) (Top System) — 18 users
4. [`ehdekncpobdjejklgpgnjgddjdnblmei`](https://socket.dev/chrome/package/ehdekncpobdjejklgpgnjgddjdnblmei) (Botflow) — 35 users
5. [`mnbdaobmkdglnmiagimcniebbgebabek`](https://socket.dev/chrome/package/mnbdaobmkdglnmiagimcniebbgebabek) (Organize-C) — 5,000 users
6. [`jelgokpkjcplgcckfiaddlfaaepohfdi`](https://socket.dev/chrome/package/jelgokpkjcplgcckfiaddlfaaepohfdi) (FQ Sales CRM) — 30 users
7. [`pmnkmmlmbnalnbgidejbcaigahodcppn`](https://socket.dev/chrome/package/pmnkmmlmbnalnbgidejbcaigahodcppn/) (Nexus CRM) — 23 users
8. [`ipaoladdllekkdokdnemkpjfllbgplek`](https://socket.dev/chrome/package/ipaoladdllekkdokdnemkpjfllbgplek/) (FLEXZAP) — 71 users
9. [`gmdnikelbimgeamkdhpdblmeekpojeei`](https://socket.dev/chrome/package/gmdnikelbimgeamkdhpdblmeekpojeei) (BoostChat) — 6 users
10. [`lbnhlbjmibbmogaefkppniejgaadimdb`](https://socket.dev/chrome/package/lbnhlbjmibbmogaefkppniejgaadimdb/) (WaZap) — 104 users
11. [`gmmcjjpciafncfbggmjhglocogcaomjb`](https://socket.dev/chrome/package/gmmcjjpciafncfbggmjhglocogcaomjb) (Convverso CRM) — 44 users
12. [`hjlpccojkgfkamonoaoakgjjlejonefo`](https://socket.dev/chrome/package/hjlpccojkgfkamonoaoakgjjlejonefo) (JuriMind CRM) — 24 users
13. [`chkaiafjmlfakkibkhbfgfklfaachmnc`](https://socket.dev/chrome/package/chkaiafjmlfakkibkhbfgfklfaachmnc) (ZapKan) — 31 users
14. [`oohihogmmfbinbkgaiglgeabloiehlkk`](https://socket.dev/chrome/package/oohihogmmfbinbkgaiglgeabloiehlkk) (Zap Vende) — 30 users
15. [`jgfaobieaananaaahonfomlibhchkndb`](https://socket.dev/chrome/package/jgfaobieaananaaahonfomlibhchkndb/) (AngoSeller) — 13 users
16. [`jhfdppbgfmmaecdgmboadmkaoifjnfmm`](https://socket.dev/chrome/package/jhfdppbgfmmaecdgmboadmkaoifjnfmm/) (Vou Falar) — 4 users
17. [`phamkmfigepogfnbkelfmknehfcjjklm`](https://socket.dev/chrome/package/phamkmfigepogfnbkelfmknehfcjjklm/) (Chatty Seller) — 23 users
18. [`jheebhheaomejiiilhgkambdgagmhfhe`](https://socket.dev/chrome/package/jheebhheaomejiiilhgkambdgagmhfhe/) (GFlow Chat) — 33 users
19. [`foedfcdeffihcmjibkbaffddbjdmkphi`](https://socket.dev/chrome/package/foedfcdeffihcmjibkbaffddbjdmkphi) (CNW ZAP) — 25 users
20. [`jhiknfikchccfkhjbfgiolgjofbnmgkd`](https://socket.dev/chrome/package/jhiknfikchccfkhjbfgiolgjofbnmgkd/) (66seller) — users not shown
21. [`cbhhipokgmechdbhebbalpckddlnfggm`](https://socket.dev/chrome/package/cbhhipokgmechdbhebbalpckddlnfggm/) (Doris CRM) — 19 users
22. [`cjdcglineikacjboikmchenneanfegoo`](https://socket.dev/chrome/package/cjdcglineikacjboikmchenneanfegoo) (ZappSeller) — 296 users
23. [`jmnajdcdmikociadheoaelpejbmoklpm`](https://socket.dev/chrome/package/jmnajdcdmikociadheoaelpejbmoklpm) (CliQ+) — users not shown
24. [`jpfpmealiajnfjmiljnmpiifccfkaimj`](https://socket.dev/chrome/package/jpfpmealiajnfjmiljnmpiifccfkaimj) (À Venda - CRM) — 118 users
25. [`mcabhobmhiljmdbdigdkkhmhjieecmne`](https://socket.dev/chrome/package/mcabhobmhiljmdbdigdkkhmhjieecmne) (MkZap) — 19 users
26. [`pedngakkndckkgfpbdmfmokokdepekho`](https://socket.dev/chrome/package/pedngakkndckkgfpbdmfmokokdepekho) (WhatSmart CRM) — 208 users
27. [`lefiaoknofkoecahieockfmhhklkigng`](https://socket.dev/chrome/package/lefiaoknofkoecahieockfmhhklkigng/) (Sanzap) — 32 users
28. [`mcjdknfjmchailcpcolfjcogggkjfeij`](https://socket.dev/chrome/package/mcjdknfjmchailcpcolfjcogggkjfeij) (WaGpro) — 112 users
29. [`mecaooaegbmnneijdhegohdpcepdbbmk`](https://socket.dev/chrome/package/mecaooaegbmnneijdhegohdpcepdbbmk) (Lexchatbot) — users not shown
30. [`mppgfleddoodfifpkjjjdbngnkcfcnde`](https://socket.dev/chrome/package/mppgfleddoodfifpkjjjdbngnkcfcnde) (performancemais) — 241 users
31. [`igmalhleeaoclfmfdlepdmfnbipkfdfi`](https://socket.dev/chrome/package/igmalhleeaoclfmfdlepdmfnbipkfdfi) (Merlix) — 3 users
32. [`eomlbgjohomgjjigponmbnedpgoegegl`](https://socket.dev/chrome/package/eomlbgjohomgjjigponmbnedpgoegegl) (ChatScript) — 6 users
33. [`mgpdpmifcljbddedpajabokdebnaemon`](https://socket.dev/chrome/package/mgpdpmifcljbddedpajabokdebnaemon) (BC ZAP) — 44 users
34. [`ofmhnbjohiadaagpeibjlncncllelaoo`](https://socket.dev/chrome/package/ofmhnbjohiadaagpeibjlncncllelaoo) (Speedsflow CRM) — 5 users
35. [`ofmoeicegmlaleajnpcbddiaomnfmfkp`](https://socket.dev/chrome/package/ofmoeicegmlaleajnpcbddiaomnfmfkp) (DBX Whats) — 1,000 users
36. [`hnimkbcgbhlllkcnphhhnbilkjngpphh`](https://socket.dev/chrome/package/hnimkbcgbhlllkcnphhhnbilkjngpphh) (HGTX Intelligence Starter) — users not shown
37. [`chdaaapnpinagdkdmkkoandalpdgikdh`](https://socket.dev/chrome/package/chdaaapnpinagdkdmkkoandalpdgikdh) (Wabin) — 17 users
38. [`cijeamgoejpplpdnjhejeeahgkbdndni`](https://socket.dev/chrome/package/cijeamgoejpplpdnjhejeeahgkbdndni/) (Zaplyd - CRM) — 449 users
39. [`pilfkgcokfmoblofkghajplgdpmejjph`](https://socket.dev/chrome/package/pilfkgcokfmoblofkghajplgdpmejjph) (FleboLeads) — 24 users
40. [`pfhinnfbeephmihjjegokhbkaeckdldp`](https://socket.dev/chrome/package/pfhinnfbeephmihjjegokhbkaeckdldp/) (Monchat) — 5 users
41. [`hpopdnbfeddglbokfbainoglnhhoccpb`](https://socket.dev/chrome/package/hpopdnbfeddglbokfbainoglnhhoccpb) (Zappower) — 29 users
42. [`gclllmamoegojkehkkohcfcjdmgikldc`](https://socket.dev/chrome/package/gclllmamoegojkehkkohcfcjdmgikldc) (Converzap) — 7 users
43. [`hnnbkomgboilfohfkpfgnlcpalcnangb`](https://socket.dev/chrome/package/hnnbkomgboilfohfkpfgnlcpalcnangb) (Bot Imobiliário) — 50 users
44. [`hocidiaogjnnibkadkedncomnglnehjg`](https://socket.dev/chrome/package/hocidiaogjnnibkadkedncomnglnehjg) (Lucra Zap) — users not shown
45. [`niimbdmbkndibiabpoolngcjipgndijh`](https://www.notion.so/131-Spamware-Extensions-Targeting-WhatsApp-Flood-Chrome-Web-Store-28c4cb3adfeb80759c4fdfe2cb05e24c?pvs=21) (Donna CRM) — users not shown
46. [`okdhkkpmmhinmjipggbfpjbdlckkaemb`](https://socket.dev/chrome/package/okdhkkpmmhinmjipggbfpjbdlckkaemb) (Zaplyn) — users not shown
47. [`mjailbbfmgaoojmjfcacffkdjoccggcf`](https://socket.dev/chrome/package/mjailbbfmgaoojmjfcacffkdjoccggcf) (FácilCRM) — 174 users
48. [`aippcgffdfgfkihejnjkmkbjoidpemcl`](https://socket.dev/chrome/package/aippcgffdfgfkihejnjkmkbjoidpemcl) (IV-CHAT) — users not shown
49. [`bajadmkhmpjaiibgakhdgpgllgnhdocc`](https://socket.dev/chrome/package/bajadmkhmpjaiibgakhdgpgllgnhdocc/) (Talk Zap CRM) — 33 users
50. [`bmcliihacfhpicjacebpnhliojphelck`](https://socket.dev/chrome/package/bmcliihacfhpicjacebpnhliojphelck) (Sellerwork) — 15 users
51. [`mjhdkfgdfcehianhcmjpgpicelgehbbe`](https://socket.dev/chrome/package/mjhdkfgdfcehianhcmjpgpicelgehbbe) (Wazapy) — 4 users
52. [`mhcnngbhhpmlahekicpkpammjibamlip`](https://socket.dev/chrome/package/mhcnngbhhpmlahekicpkpammjibamlip) (SALES WHATS) — 213 users
53. [`jfcekpbabbijmfpcgnnoaekodnagbffd`](https://socket.dev/chrome/package/jfcekpbabbijmfpcgnnoaekodnagbffd/) (Super Chat Boom) — users not shown
54. [`ahpcdagejgoffjpnbkhemojogbocbahe`](https://socket.dev/chrome/package/ahpcdagejgoffjpnbkhemojogbocbahe) (ChatAds) — 122 users
55. [`mkbjflhgpickfellipdmpcnhkmmdcojl`](https://socket.dev/chrome/package/mkbjflhgpickfellipdmpcnhkmmdcojl/) (YouSeller) — 10,000 users
56. [`nmnflpdnbpnoojmpmhkkiagmegimlnmm`](https://socket.dev/chrome/package/nmnflpdnbpnoojmpmhkkiagmegimlnmm/) (FLOW 5.0) — users not shown
57. [`nnmbiaaomdknpkgpklfcekneilkimoal`](https://socket.dev/chrome/package/nnmbiaaomdknpkgpklfcekneilkimoal/) (TELEFON CONECTA) — 13 users
58. [`bjbdjeijmkjcphbmbiifoeaikbmmgcjp`](https://socket.dev/chrome/package/bjbdjeijmkjcphbmbiifoeaikbmmgcjp/) (WA FLASH) — 104 users
59. [`kekglidebofmckpkojgbogajflnmhega`](https://socket.dev/chrome/package/kekglidebofmckpkojgbogajflnmhega) (MovvaSe) — users not shown
60. [`kfopgoafhfkcpnkiemaldlplpbnengjf`](https://socket.dev/chrome/package/kfopgoafhfkcpnkiemaldlplpbnengjf) (Power Chat) — 25 users
61. [`nmimioepofbhnidpmebigbahpckjfmbm`](https://socket.dev/chrome/package/nmimioepofbhnidpmebigbahpckjfmbm) (Chatfunel) — 54 users
62. [`clpedhieolcgejlfdnlfadojpaiahlfm`](https://socket.dev/chrome/package/clpedhieolcgejlfdnlfadojpaiahlfm/) (VicChat) — users not shown
63. [`pmdahofhcbcejdodnmijkhahahegenhi`](https://socket.dev/chrome/package/pmdahofhcbcejdodnmijkhahahegenhi) (INWISE CRM) — 13 users
64. [`hhlbnnfmjdoeegpoihgandmppnmfpeib`](https://socket.dev/chrome/package/hhlbnnfmjdoeegpoihgandmppnmfpeib) (ZapForce) — 8 users
65. [`jleilnojaafdekbbpighcjlcbmfnifim`](https://socket.dev/chrome/package/jleilnojaafdekbbpighcjlcbmfnifim) (ZapWild - CRM) — users not shown
66. [`maopdiomoidladgapokmfggnccpolbol`](https://socket.dev/chrome/package/maopdiomoidladgapokmfggnccpolbol/) (WhatsTool) — 27 users
67. [`cgcckeanlanlpaflhipplbhichjejgpk`](https://socket.dev/chrome/package/cgcckeanlanlpaflhipplbhichjejgpk/) (Lever CRM) — 81 users
68. [`kleicpolamoebhoajpbhcbmcihbcfobm`](https://socket.dev/chrome/package/kleicpolamoebhoajpbhcbmcihbcfobm) (Opendoor Solucoes) — users not shown
69. [`kmhlbkgpafhoojblcfhnljaaighbejfk`](https://socket.dev/chrome/package/kmhlbkgpafhoojblcfhnljaaighbejfk) (Yconecta Latam) — 9 users
70. [`ifhkkkfghpgbelajdcmkbahibfieffkl`](https://socket.dev/chrome/package/ifhkkkfghpgbelajdcmkbahibfieffkl/) (Pipe Loom) — users not shown
71. [`blpopmcoebhlkolmkjjmplbmlgdhggkk`](https://socket.dev/chrome/package/blpopmcoebhlkolmkjjmplbmlgdhggkk) (Connect Castle Solution) — users not shown
72. [`begphlgbbimlphmfbigfjcadjgplglcg`](https://socket.dev/chrome/package/begphlgbbimlphmfbigfjcadjgplglcg) (ATENDO DO ZAP) — 34 users
73. [`bmeleciepnphilegegcbfjkoolldigid`](https://socket.dev/chrome/package/bmeleciepnphilegegcbfjkoolldigid) (SYS.AO) — 23 users
74. [`ebmbbmldkfhfambpnegomegconmhcioe`](https://www.notion.so/Eng-Standup-Threat-Analysis-28d4cb3adfeb8097a7b4fd68d02f8196?pvs=21) (Evoluwa) — users not shown
75. [`ddmhkpkipjnhlppmcepckfgjbmljmphm`](https://socket.dev/chrome/package/ddmhkpkipjnhlppmcepckfgjbmljmphm/) (Maiq) — 7 users
76. [`jjopcmgbpnfdehgmbioibahegdmmfipm`](https://socket.dev/chrome/package/jjopcmgbpnfdehgmbioibahegdmmfipm) (Zap4u) — users not shown
77. [`hdonddbodcfamjgmdolkgfgidjfmijmj`](https://socket.dev/chrome/package/hdonddbodcfamjgmdolkgfgidjfmijmj/) (Evan's Atende) — 33 users
78. [`anoghcdepimhncglcecmgnbchpjfkonp`](https://socket.dev/chrome/package/anoghcdepimhncglcecmgnbchpjfkonp) (MestreZap) — users not shown
79. [`oiekdjliebhjpjknfojajhjebgeedhag`](https://socket.dev/chrome/package/oiekdjliebhjpjknfojajhjebgeedhag) (Salesly) — 7 users
80. [`ohekppieeepibkebnlilabljmnkffmof`](https://socket.dev/chrome/package/ohekppieeepibkebnlilabljmnkffmof/) (ZapLead) — 25 users
81. [`ohojiglgbgnhaddfhdbkoclekhghncih`](https://socket.dev/chrome/package/ohojiglgbgnhaddfhdbkoclekhghncih) (Chat Power) — users not shown
82. [`ekigeoglcndojhecmojcchlhjkbghnmg`](https://socket.dev/chrome/package/ekigeoglcndojhecmojcchlhjkbghnmg) (FarChat) — 28 users
83. [`mlladklbipjfnjgjjbkofonboojklnpo`](https://socket.dev/chrome/package/mlladklbipjfnjgjjbkofonboojklnpo) (idk Converte) — 6 users
84. [`edgokehfaihammibdolojeljlccobihi`](https://socket.dev/chrome/package/edgokehfaihammibdolojeljlccobihi/) (VEXA INOVAÇÃO) — 2 users
85. [`eecbjpnghjlfeanpabnebopncfldgkej`](https://socket.dev/chrome/package/eecbjpnghjlfeanpabnebopncfldgkej/) (Polo Lucrativo) — 6 users
86. [`namibohbbclnmgbnhegongpbkphhelji`](https://socket.dev/chrome/package/namibohbbclnmgbnhegongpbkphhelji) (Sell Swift) — 5 users
87. [`ndilbmjmeggijafdloohkniglleeekff`](https://socket.dev/chrome/package/ndilbmjmeggijafdloohkniglleeekff) (Red Chat) — 12 users
88. [`bpinnifebepjjedmficfllcnalhcfgin`](https://socket.dev/chrome/package/bpinnifebepjjedmficfllcnalhcfgin/) (Hizi Chat) — users not shown
89. [`fkcbkncgbolfiijohpipeobfbopidhlg`](https://socket.dev/chrome/package/fkcbkncgbolfiijohpipeobfbopidhlg/) (HBS CONNECT) — users not shown
90. [`bcabbcjlfhhffnjjfebenghlgfpfobdg`](https://socket.dev/chrome/package/bcabbcjlfhhffnjjfebenghlgfpfobdg/) (EAI MAIS) — users not shown
91. [`nfoenldfhfooabacoilpappaoggfmdio`](https://socket.dev/chrome/package/nfoenldfhfooabacoilpappaoggfmdio/) (ifteczap CRM) — users not shown
92. [`bmfeoaglddjefdcdmnaohgjlanmmddog`](https://socket.dev/chrome/package/bmfeoaglddjefdcdmnaohgjlanmmddog) (ByteZap) — 21 users
93. [`mpcajkogkmebocmcflglhmdekfglallb`](https://socket.dev/chrome/package/mpcajkogkmebocmcflglhmdekfglallb) (Cresça & Apareça CRM) — 4 users
94. [`ghlcmioojimlkcljjjepehacmgodjfdk`](https://socket.dev/chrome/package/ghlcmioojimlkcljjjepehacmgodjfdk) (WHATSATLANTIC) — 87 users
95. [`poemcanhdcddpkjmdgegfiopikiheppd`](https://socket.dev/chrome/package/poemcanhdcddpkjmdgegfiopikiheppd/) (Alô IA) — 6 users
96. [`pmpcobjbffgoalkbilglngiomdbpmffd`](https://socket.dev/chrome/package/pmpcobjbffgoalkbilglngiomdbpmffd) (ZapyPrime) — 16 users
97. [`lpbhcehpljligfjkcjpfklackjfoomao`](https://socket.dev/chrome/package/lpbhcehpljligfjkcjpfklackjfoomao/) (WhizzChat) — 28 users
98. [`lmoncmhkblbcbekgefgpkohplhjkfgbm`](https://socket.dev/chrome/package/lmoncmhkblbcbekgefgpkohplhjkfgbm/) (RoboZapp) — 68 users
99. [`cbgbkbafakhpmmdmbaafniijhifoikei`](https://socket.dev/chrome/package/cbgbkbafakhpmmdmbaafniijhifoikei) (ARX Tecnologia) — 2 users
100. [`odlgfgmgiinbkobmfhgmphbpfpmofppf`](https://socket.dev/chrome/package/odlgfgmgiinbkobmfhgmphbpfpmofppf) (Tryno CRM) — 23 users
101. [`aekhfllepcmekghgdhgbceojklhhioba`](https://socket.dev/chrome/package/aekhfllepcmekghgdhgbceojklhhioba) (Zaptree) — 8 users
102. [`ilahhiccjmanljjhebdpoilbfhjgpckp`](https://socket.dev/chrome/package/ilahhiccjmanljjhebdpoilbfhjgpckp) (360° Management CRM) — 22 users
103. [`agmdligmnfaciogcnokodiaoppflebla`](https://socket.dev/chrome/package/agmdligmnfaciogcnokodiaoppflebla) (Biz Sale Chat & CRM) — users not shown
104. [`ahejniinncebcikkjhggpghpjlkgjoab`](https://socket.dev/chrome/package/ahejniinncebcikkjhggpghpjlkgjoab) (Wavenda) — 44 users
105. [`kajbnhbibimhcmkpeokmgdpnhddjncka`](https://socket.dev/chrome/package/kajbnhbibimhcmkpeokmgdpnhddjncka) (GMD-ON) — 20 users
106. [`kahaenfigldjkcjpnblmhbbkkgfjkhhl`](https://socket.dev/chrome/package/kahaenfigldjkcjpnblmhbbkkgfjkhhl) (ZapCORR Suite) — 12 users
107. [`gfkedhmelaeoklidjhdbgpbnjdcacced`](https://socket.dev/chrome/package/gfkedhmelaeoklidjhdbgpbnjdcacced) (Zap Gestor CRM) — 12 users
108. [`gfplcnpcmgddenkggdapkcokgnkgncfe`](https://socket.dev/chrome/package/gfplcnpcmgddenkggdapkcokgnkgncfe) (Myboot) — users not shown
109. [`mdchifijocjccoidjcaamcebbehehlgo`](https://socket.dev/chrome/package/mdchifijocjccoidjcaamcebbehehlgo) (Sales Whats Brasil) — 7 users
110. [`ebjpepgmlmbfgjdefdhobjfnhpgepibd`](https://socket.dev/chrome/package/ebjpepgmlmbfgjdefdhobjfnhpgepibd) (IMPAR CRM) — 4 users
111. [`fkkjcbogndlaeofafjjdlckkodpnlafb`](https://socket.dev/chrome/package/fkkjcbogndlaeofafjjdlckkodpnlafb) (Oh Mago CRM para Whatsapp) — users not shown
112. [`cdjijomcoohechfbkipcibpcakldfceo`](https://socket.dev/chrome/package/cdjijomcoohechfbkipcibpcakldfceo/) (DataZap: Automação, CRM) — 30 users
113. [`egebdiofdkgfhheopdaecggogdeaaepj`](https://socket.dev/chrome/package/egebdiofdkgfhheopdaecggogdeaaepj/) (TekZap Conversas) — 46 users
114. [`nhmcfloglkbnliknncnfnlhideepfpfi`](https://socket.dev/chrome/package/nhmcfloglkbnliknncnfnlhideepfpfi/) (Lobo Vendedor) — users not shown
115. [`fdofhoefhcjllmgcgpdplndaeebfnica`](https://socket.dev/chrome/package/fdofhoefhcjllmgcgpdplndaeebfnica/) (Gana Digital) — users not shown
116. [`iflolbkfpmpjobjhkamajiekpmepcban`](https://socket.dev/chrome/package/iflolbkfpmpjobjhkamajiekpmepcban/) (WHATZIP) — 19 users
117. [`dcgdocmggapfdocodbimagkloacnkbjf`](https://socket.dev/chrome/package/dcgdocmggapfdocodbimagkloacnkbjf/) (STUDIO ZAP) — 37 users
118. [`llijmcnalgidmchdckmpimhhffehfbbg`](https://socket.dev/chrome/package/llijmcnalgidmchdckmpimhhffehfbbg/) (Novo Envio Extensão: CRM) — 110 users
119. [`eaeiigegpmgegjhcbohmhddjgaldbknn`](https://socket.dev/chrome/package/eaeiigegpmgegjhcbohmhddjgaldbknn/) (FortChat) — users not shown
120. [`fibommgfjfckaingpopkdohoegidkmng`](https://socket.dev/chrome/package/fibommgfjfckaingpopkdohoegidkmng/) (Cash Zapp) — 17 users
121. [`fgfbklebnaaimlcgmfohnlnkihahlagk`](https://socket.dev/chrome/package/fgfbklebnaaimlcgmfohnlnkihahlagk/) (ChatBlink) — 786 users
122. [`cjiedabijhhefgeonkdodnpaiimfdlpd`](https://socket.dev/chrome/package/cjiedabijhhefgeonkdodnpaiimfdlpd/) (Projeta Zap) — 49 users
123. [`lhngnpihljickmbkflaiobcblmhchpab`](https://socket.dev/chrome/package/lhngnpihljickmbkflaiobcblmhchpab/) (Conectadus CRM) — 13 users
124. [`jpioocoiojejijkbnpljcoonohmechha`](https://socket.dev/chrome/package/jpioocoiojejijkbnpljcoonohmechha) (Zap4Biz) — users not shown
125. [`haieolmfmmepgdimacfanclfemodnmep`](https://socket.dev/chrome/package/haieolmfmmepgdimacfanclfemodnmep) (BYS Convert) — users not shown
126. [`fjfpgmaghnjnjndiapfmehebankomkmc`](https://socket.dev/chrome/package/fjfpgmaghnjnjndiapfmehebankomkmc) (Fluxo de Vendas) — 10 users
127. [`clkibjppajhlbhofckbilehgfjjmljnj`](https://socket.dev/chrome/package/clkibjppajhlbhofckbilehgfjjmljnj/) (Evento Prime) — users not shown
128. [`jbkmdabbenlckohhpccihkingphnoaom`](https://socket.dev/chrome/package/jbkmdabbenlckohhpccihkingphnoaom/) (WizeChat) — users not shown
129. [`oikahlogkilifeoehlepbljmnjohannb`](https://socket.dev/chrome/package/oikahlogkilifeoehlepbljmnjohannb/) (MyZapCRM) — 1 user
130. [`aogcmjgadbnlpjjcppfcjndmnffbeiid`](https://socket.dev/chrome/package/aogcmjgadbnlpjjcppfcjndmnffbeiid/) (Vozco Scale) — 10 users
131. [`dknafkoneldddpgcomhckilhhfodcnkk`](https://socket.dev/chrome/package/dknafkoneldddpgcomhckilhhfodcnkk) (Atendi Light) — users not shown

### Marketing Websites

1. `organize-c[.]com` — Organize-C
2. `zapvende[.]com` — Zap Vende
3. `chattyseller[.]com` — Chatty Seller
4. `zappseller[.]com[.]br` — ZappSeller
5. `mkzap[.]com[.]br` — MkZap
6. `www[.]bcmarketing[.]com[.]br/lp` — BC ZAP
7. `dbx[.]global/whats/` — DBX Whats
8. `zappower[.]com[.]br` — Zappower
9. `lucrazap[.]com[.]br` — Lucra Zap
10. `facilcrm[.]com[.]br` — FácilCRM
11. `youseller[.]com[.]br` — YouSeller
12. `powerchat[.]in` — Power Chat
13. `chatfunnel[.]com[.]br` — Chatfunel
14. `zapforce[.]app[.]br` — ZapForce
15. `whatstool[.]in` — WhatsTool
16. `curiosidademinha[.]com[.]br/atendodozap` — ATENDO DO ZAP
17. `zap4u[.]com[.]br` — Zap4u
18. `mestrezap[.]online` — MestreZap
19. `chatpowerpro[.]com[.]br` — Chat Power
20. `chat[.]bizsale[.]com[.]br` — Biz Sale Chat & CRM
21. `lobovendedor[.]com[.]br` — Lobo Vendedor
22. `ganadigital[.]com[.]br` — Gana Digital
23. `wizechat[.]com[.]br` — WizeChat
