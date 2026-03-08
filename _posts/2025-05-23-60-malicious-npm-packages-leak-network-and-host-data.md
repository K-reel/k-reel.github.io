---
title: "60 Malicious npm Packages Leak Network and Host Data in Active Malware Campaign"
short_title: "60 Malicious npm Packages Leak Network and Host Data"
date: 2025-05-23 12:00:00 +0000
categories: [Malware, npm]
tags: [Reconnaissance, Discord, Sandbox Evasion, npm, T1195.002, T1059.007, T1567.004, T1590, T1590.002, T1590.005, T1497]
canonical_url: https://socket.dev/blog/60-malicious-npm-packages-leak-network-and-host-data
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/c4a967be54f79f8bc54b5f52abed0d3aec391421-745x746.png
  alt: "60 Malicious npm Packages Leak Network and Host Data in Active Malware Campaign"
description: "Socket's Threat Research Team has uncovered 60 npm packages using post-install scripts to silently exfiltrate hostnames, IP addresses, DNS servers, and user directories to a Discord webhook."
---

Socket's Threat Research Team has uncovered an active campaign in the npm ecosystem that now spans 60 packages published under three npm accounts. Each package carries a small install‑time script that, when triggered during `npm install`, collects hostnames, internal and external IP addresses, DNS server lists, and user directory paths, then exfiltrates the data to a Discord webhook under the threat actor's control.

The first package emerged eleven days ago and the most recent appeared only hours before this publication, confirming the operation is still under way. The script targets Windows, macOS or Linux systems, and includes basic sandbox‑evasion checks, making every infected workstation or continuous‑integration node a potential source of valuable reconnaissance. Combined downloads now exceed 3,000, giving the threat actor a growing map of developer and enterprise networks that can guide future intrusions. As of this writing, all packages remain live on npm. We have petitioned for their removal.

![First malicious packages under bbbb335656](https://cdn.sanity.io/images/cgdhsj6q/production/38e8b37f4afe773c9e3958ac485b5dd64ab9ab9c-913x377.png)

![First malicious packages under cdsfdfafd1232436437](https://cdn.sanity.io/images/cgdhsj6q/production/0eb5533241bdf0169132368365d5767673c27b5a-915x361.png)

![First malicious packages under sdsds656565](https://cdn.sanity.io/images/cgdhsj6q/production/910f9215ef0d201e243cc0ede1fc4a0f8653b8b7-921x374.png)

*First three malicious packages released under the npm accounts **`bbbb335656`**, **`cdsfdfafd1232436437`**, and **`sdsds656565`**. Each account went on to publish twenty malicious packages in total.*

## Inside the Code

The script performs reconnaissance with the sole purpose of fingerprinting each machine that builds or installs the package. By collecting both internal and external network identifiers, it links private developer environments to their public‑facing infrastructure — ideal for follow‑on targeting. The selective sandbox escapes indicate the threat actor wants real victims, not sandboxes or research VMs.

The annotated [code](https://socket.dev/npm/package/seatable/files/11.8.1/package/index.js) snippets below demonstrate the malicious logic inside the [`seatable`](https://socket.dev/npm/package/seatable/overview/11.8.1) package. This payload is identical across all 60 packages published by the threat actor.

The script gathers enough information to connect an organization's internal network to its outward‑facing presence. By harvesting internal and external IP addresses, DNS servers, usernames, and project paths, it enables a threat actor to chart the network and identify high‑value targets for future campaigns.

On continuous‑integration servers, the leak can reveal internal package registry URLs and build paths, intelligence that speeds up subsequent supply chain attacks. While the current payload is limited to reconnaissance, it creates a strategic risk by laying the foundation for deeper intrusions.

## 60 Packages at a Glance

The accounts `bbbb335656` (registration email `npm9960+1@gmail[.]com`), `sdsds656565` (registration email `npm9960+2@gmail[.]com`), and `cdsfdfafd1232436437` (registration email `npm9960+3@gmail[.]com`), each show twenty packages published within an eleven‑day span. All 60 packages carry the same host‑fingerprinting code that exfiltrates data to the same Discord webhook. For instance, [`seatable`](https://socket.dev/npm/package/seatable/overview/11.8.1) (from `bbbb335656`), [`datamart`](https://socket.dev/npm/package/datamart) (from `sdsds656565`), and [`seamless-sppmy`](https://socket.dev/npm/package/seamless-sppmy/overview/10.6.9) (from `cdsfdfafd1232436437`) embed the identical malicious payload shown below.

![Socket AI Scanner analysis of seatable](https://cdn.sanity.io/images/cgdhsj6q/production/45a850a83a3c4d2220a84380b713a05d15004ca0-621x788.png)
_Socket AI Scanner's analysis, including contextual details about the malicious [`seatable`](https://socket.dev/npm/package/seatable/overview/11.8.1) package._

## Outlook and Recommendations

The campaign remains active. Unless the npm registry removes the malicious packages and suspends the related accounts, more releases are likely. The threat actor can easily clone the script, track download telemetry in real time, and publish again. More than 3,000 installs without removal demonstrate that quiet reconnaissance is an effective foothold technique on npm and one that others may emulate.

Because the registry offers no guardrails for post‑install hooks, expect new throwaway accounts, fresh packages, alternative exfiltration endpoints, and perhaps larger payloads once a target list is complete. Defenders should assume the threat actor will continue publishing, refine evasion checks, and pivot to follow‑on intrusions that exploit the mapping already collected.

Defenders should adopt dependency‑scanning tools that surface post‑install hooks, hardcoded URLs, and unusually small tarballs. They should also strengthen the development pipeline with automated checks. The free [Socket GitHub app](https://socket.dev/features/github) and [CLI](https://socket.dev/features/cli) flag suspicious patterns in pull requests and during package installs, while the [Socket browser extension](https://socket.dev/features/web-extension) shows risk scores as you browse online. Together, these layers of scrutiny reduce the likelihood that a malicious package enters your codebase.

## Indicators of Compromise (IOCs)

### Malicious Packages by Account

`bbbb335656` (registration email `npm9960+1@gmail[.]com`) – 20 packages

1. e-learning-garena
1. inhouse-root
1. event-sharing-demo
1. hermes-inspector-msggen
1. template-vite
1. flipper-plugins
1. appium-rn-id
1. bkwebportal
1. gop_status_frontend
1. index_patterns_test_plugin
1. seatable
1. zdauth
1. mix-hub-web
1. chromastore
1. performance-appraisal
1. choosetreasure
1. rapper-wish
1. 12octsportsday
1. credit-risk
1. raffle-node

`sdsds656565` (registration email `npm9960+2@gmail[.]com`) – 20 packages

1. coral-web-be
1. garena-react-template-redux
1. sellyourvault
1. admin-id
1. seacloud-database
1. react-xterm2
1. bkeat-pytest
1. mysteryicons
1. mshop2
1. xlog-admin-portal
1. datamart
1. garena-admin
1. estatement-fe
1. kyutai-client
1. tgi-fe
1. gacha-box
1. tenslots
1. refreshrewards
1. codeword
1. sps

`cdsfdfafd1232436437` (registration email `npm9960+3@gmail[.]com`) – 20 packages

1. seatalk-rn-leave-calendar
1. netvis
1. input_control_vis
1. env-platform
1. web-ssar
1. hideoutpd
1. arcademinigame
1. customer-center
1. team-portal
1. dof-ff
1. seamless-sppmy
1. accumulate-win
1. sfc-demo
1. osd_tp_custom_visualizations
1. routing-config
1. gunbazaar
1. mbm-dgacha
1. wsticket
1. all-star-2019
1. data-portal-dwh-apps-fe

### Exfiltration Endpoint

- `hxxps://discord[.]com/api/webhooks/1330015051482005555/5fll497pcjzKBiY3b_oa9YRh-r5Lr69vRyqccawXuWE_horIlhwOYzp23JWm-iSXuPfQ`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1567.004 — Exfiltration Over Web Service: Exfiltration Over Webhook
- T1590 — Gather Victim Network Information
- T1590.002 — Gather Victim Network Information: DNS
- T1590.005 — Gather Victim Network Information: IP Addresses
- T1497 — Virtualization/Sandbox Evasion
