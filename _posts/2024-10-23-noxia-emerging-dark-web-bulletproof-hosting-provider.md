---
title: "Noxia: Emerging Dark Web Hosting Provider Targets Python, Node.js, Go, and Rust Ecosystems"
short_title: "Noxia: Dark Web Hosting Targets Open Source Ecosystems"
date: 2024-10-23 12:00:00 +0000
categories: [Threat Intelligence]
tags: [Bulletproof Hosting, Dark Web, Python, PyPI, JavaScript, npm, Go, Go Modules, Rust, crates.io, T1195.002, T1583.003, T1587.001, T1059.006, T1059.007]
canonical_url: https://socket.dev/blog/noxia-emerging-dark-web-bulletproof-hosting-provider
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/0faa917baac40dc71419103945832f2ef1041ae7-1024x1024.webp
  alt: "Noxia dark web bulletproof hosting provider advertisement on BreachForums"
description: "Noxia, a new dark web bulletproof host, offers dirt cheap servers for Python, Node.js, Go, and Rust, enabling cybercriminals to distribute malware and conduct supply chain attacks."
---

Evidence uncovered as part of an investigation by Socket's Threat Research Team strongly suggests that a new dark web bulletproof hosting provider, Noxia, is enabling cybercriminals to distribute malicious code and conduct software supply chain attacks by offering low-cost servers for hosting Python, Node.js, Go, and Rust applications.

On October 10, 2024, "noxia", a member of the dark web forum "BreachForums", posted an advertisement for Noxia (noxia[.]cloud) – a bulletproof hosting provider. The term "bulletproof" alludes to the fact that these infrastructure and services are provided to other threat actors for ostensibly malicious purposes, and operate outside of the purview of legitimate activity.

While bulletproof hosting advertisements are common among the criminal underground, and bulletproof hosting provides a range of services, Noxia claims the ability to host Python, Node.js, Go, and Rust applications. By acting as a platform for these applications, Noxia may be used as a malware distribution vector as it relates to software supply chains. Socket actively monitors, detects, and blocks supply chain attacks. When coupled with our Threat Research Team's analysis, we are able to identify emergent threats like Noxia's bulletproof hosting.

![](https://cdn.sanity.io/images/cgdhsj6q/production/d69e2dceda853fb20dcccb49598abd3f35b8bf41-1698x651.png)

_**Figure 1**: Noxia advertisement on BreachForums_

## Noxia's Service Offerings

Bulletproof hosting providers, as evidence suggests Noxia is, specifically advertise their services on dark web forums, enabling crime, and are a vital part of the underground economy. Bulletproof hosting providers are known to facilitate cybercrime, including ransomware attacks, and are often a target of law enforcement [investigations](https://www.justice.gov/opa/pr/administrator-bulletproof-webhosting-domain-charged-connection-facilitation-netwalker) and [research](https://krebsonsecurity.com/2019/07/meet-the-worlds-biggest-bulletproof-hoster/) by the information security community.

Noxia is renting servers configured for Python, Node.js, and Go for as little as £0.25 GBP ($0.32 USD) per month for the "basic" configuration. This low-cost subscription offers disposable infrastructure to threat actors who can cheaply create and discard multiple servers, making it harder for law enforcement and researchers to track their activities. Noxia's website (noxia[.]cloud) has a seemingly legitimate appearance, and its service has not been widely reported on by the security community, which may allow traffic from their servers to bypass organizations' security filters.

![](https://cdn.sanity.io/images/cgdhsj6q/production/0b84cc6421f724ec611967510d1761b3268c34f3-1054x745.png)

_**Figure 2**: Noxia's configurable server options for Python, Node.js, and Go_

Additionally, threat actors can use Noxia's servers for command and control (C2) servers, phishing, managing botnets, and hosting malicious software updates, which can lead to system compromise, if downloaded unknowingly.

## Malicious Campaigns

Despite being new dark web bulletproof hosting provider on the block, Noxia is already participating in malicious campaigns, hosting malware at hxxp://uk1[.]noxia[.]cloud:10022/downloadFilesFrom[.]txt (filename "[octane.exe](https://any.run/report/cb800cc9a220ac17e8f222b8c33f4afcc92b6d17b5453e19be99705806c32dc2/57d4d076-a32d-4164-a105-bcae9ed9a7a5)"; SHA256: cb800cc9a220ac17e8f222b8c33f4afcc92b6d17b5453e19be99705806c32dc2) and hxxp://uk1[.]noxia[.]cloud:10022/version (filename "[octane.exe](https://www.hybrid-analysis.com/sample/cc16da3e9a5d56c8a0ac96e1211acb8b728bf66dbaad24f15ad8190f7bedce72/66ad5fdcba4fa51b680f6de3)"; SHA256: cc16da3e9a5d56c8a0ac96e1211acb8b728bf66dbaad24f15ad8190f7bedce72). Both files are flagged as "malicious" by [36 out of 72](https://www.virustotal.com/gui/file/cb800cc9a220ac17e8f222b8c33f4afcc92b6d17b5453e19be99705806c32dc2) and [6 out of 94](https://www.virustotal.com/gui/file/cc16da3e9a5d56c8a0ac96e1211acb8b728bf66dbaad24f15ad8190f7bedce72) security vendors on VirusTotal respectively.

An additional analysis of these malware samples [indicates](https://search.censys.io/hosts/149.40.3.138?resource=hosts&sort=RELEVANCE&per_page=25&virtual_hosts=EXCLUDE&q=noxia.cloud&at_time=2024-10-15T14%3A55%3A49.080Z) a link between Noxia and the octane malware via the IP address 149.40.3[.]138 through their forward DNS [records](https://www.virustotal.com/gui/ip-address/149.40.3.138/relations). A list of Noxia's domains, subdomains, and associated IP addresses is included in the indicators of compromise (IOCs) section below.

Both octane.exe files contain a URL string pointing to octane[.]lol, which serves dozens of malicious files, [according](https://www.virustotal.com/gui/domain/octane.lol/relations) to VirusTotal. The octane[.]lol site is designed similarly to noxia[.]cloud and features an advertisement banner for Noxia.

![](https://cdn.sanity.io/images/cgdhsj6q/production/22dbfbb7fea612e45c0091f4fab796c17fc2501a-462x58.png)

_**Figure 3**: Noxia's banner on octane[.]lol_

## Recommended Mitigations

To protect themselves from attacks that use bulletproof hosting services like Noxia, developers should adopt a comprehensive security strategy focusing on supply chain security, dependency management, and proactive monitoring. Here's how developers can safeguard their applications:

- Use trusted sources from official repositories and only download packages from reputable sources, such as PyPI, npm, Go and Cargo
- Verify package maintainers for the package credibility
- Monitor network traffic and access logs for signs of malicious activity originating from or targeting your applications
- Deploy IDS/IPS to detect anomalous network activities
- Use dependency scanning tools to monitor for vulnerabilities and malicious code patterns.

### Install Socket's Free GitHub App

Socket offers robust solutions to enhance application security against software supply chain attacks through the use of:

- Behavioral analysis: Socket analyzes package behavior to detect suspicious activity like the use of risky APIs, obfuscated code, or unexpected network requests
- Real-time alerts: Socket provides immediate notifications about potential threats in your dependencies before they become part of your codebase
- Integration: Socket integrates with your development workflow, including package managers and CI/CD pipelines
- Protection against advanced attacks: Socket helps guard against dependency confusion, typosquatting, and compromised packages
- Detection: By incorporating Socket into their security strategy, organizations enhance the ability to detect and prevent attacks that can originate from compromised or malicious packages hosted on services like Noxia.

[Install the free Socket for GitHub app](https://socket.dev/features/github) in two clicks to protect your repositories from vulnerable and malicious dependencies.

### Indicators of Compromise (IOCs):

Noxia associated domains, subdomains, IP addresses:

- billing[.]noxia[.]cloud
- panel[.]noxia[.]cloud
- uk1[.]noxia[.]cloud
- exd[.]noxia[.]cloud
- 149.40.3[.]138
- demo-h1[.]noxia[.]cloud
- han[.]noxia[.]cloud
- 54.84.236[.]175
- status[.]noxia[.]cloud
- 142.132.140[.]101
- www[.]noxia[.]cloud
- 35.169.59[.]174
- erad[.]noxia[.]cloud
- 172.67.214[.]207
- octane[.]lol
- 3.70.101[.]28
- 3.72.140[.]173

## MITRE ATT&CK:

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1583.003 — Acquire Infrastructure: Virtual Private Server
- T1587.001 — Develop Capabilities: Malware
- T1059.006 — Command and Scripting Interpreter: Python
- T1059.007 — Command and Scripting Interpreter: JavaScript
