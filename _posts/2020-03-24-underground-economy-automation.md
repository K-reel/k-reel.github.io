---
title: "Combating the Underground Economy's Automation Revolution"
date: 2020-03-24 12:00:00 +0000
author: insikt_group
categories: [Threat Intelligence]
tags: [Dark Web, Cybercrime, Underground Economy, SOAR, Credential Stuffing, Brute Force, Exploit Kit, Phishing, Keylogger, Botnet, Infostealer, E-Commerce]
canonical_url: https://www.recordedfuture.com/research/underground-economy-automation
source: Recorded Future
image:
  path: /assets/img/posts/underground-economy-automation/cover.png
  alt: "Combating the Underground Economy's Automation Revolution"
description: "Recent Insikt Group research explores the tools and services used by threat actors to automate tasks associated with malicious campaigns."
toc: true
---

Automation has become an essential part of nearly every industry, and nowhere is this more true than in cybersecurity. But unfortunately, the benefits of automation are equally available to criminal enterprises and defenders alike. So while the criminal underground has created an ecosystem of tools and resources to operationalize and monetize campaigns, SOARs can be used to tip the balance back in a defender's favor by automating defensive intelligence feeds and combining them with automated detection and prevention.

Research by Recorded Future's Insikt Group explored the tools and services used by threat actors to automate tasks associated with malicious campaigns and the mitigation strategies available through SOAR and threat intelligence solutions.

## 1. Compromised Credentials and Data Breaches

![Breaches and Sale of Databases](/assets/img/posts/underground-economy-automation/section-1.gif)

Compromised credentials are obtained through unauthorized network access and sold on underground forums. Attackers use these credentials for privilege escalation and ransomware attacks.

**Mitigations:**

- Keep software updated
- Deploy email filtering
- Maintain offline backups
- Compartmentalize data
- Enforce role-based access controls
- Encrypt sensitive data

## 2. Checkers and Brute Forcers

![Checkers and Brute Forcers](/assets/img/posts/underground-economy-automation/section-2.gif)

Attackers with credentials obtained from data breaches then leverage checkers and brute forcers to direct large-scale automated login requests against websites to determine the validity of victim accounts and gain unauthorized access.

**Mitigations:**

- Use unique passwords with password managers
- Implement CAPTCHAs
- Enforce multi-factor authentication (MFA)
- Deploy web application firewalls
- Apply rate limiting
- Remove unused logins
- Baseline traffic patterns

## 3. Loaders and Crypters

![Loaders and Crypters](/assets/img/posts/underground-economy-automation/section-3.gif)

Loaders and crypters are used to elude endpoint security and execute malicious payloads on victim systems.

**Mitigations:**

- Regularly update antivirus solutions
- Deploy additional detection controls
- Conduct phishing awareness training

## 4. Stealers and Keyloggers

![Stealers and Keyloggers](/assets/img/posts/underground-economy-automation/section-4.gif)

Stealers and keyloggers exfiltrate credentials, personally identifiable information (PII), and payment card information. They also install secondary payloads.

**Mitigations:**

- Implement patch posture reporting solutions
- Deploy network defense alerting mechanisms
- Monitor for suspicious file and registry changes

## 5. Banking Injects

![Banking Injects](/assets/img/posts/underground-economy-automation/section-5.gif)

Fake overlays or modules are used with banking trojans to inject HTML or JavaScript code to collect sensitive information from victims.

**Mitigations:**

- Keep software updated
- Deploy antivirus solutions
- Enforce MFA via SMS or authenticator apps
- Use HTTPS-only connections
- Conduct employee training
- Deploy spam and web filters
- Require encryption
- Convert HTML emails to plain text

## 6. Exploit Kits

![Exploit Kits](/assets/img/posts/underground-economy-automation/section-6.gif)

Exploit kits are used to automate the exploitation of web browser vulnerabilities to maximize the delivery of successful infections, including trojans and ransomware.

**Mitigations:**

- Prioritize patching Microsoft products
- Disable Adobe Flash
- Conduct phishing awareness training

## 7. Spamming and Phishing Services

![Spamming and Phishing Services](/assets/img/posts/underground-economy-automation/section-7.gif)

Email campaigns reach hundreds of thousands of targets for credential theft and malware deployment.

**Mitigations:**

- Avoid publishing email addresses publicly
- Deploy spam filtering tools
- Avoid using personal or business emails for website registration
- Enforce password security policies
- Require encryption
- Conduct employee training

## 8. Proxy and Bulletproof Hosting Services

![Proxy and Bulletproof Hosting Services](/assets/img/posts/underground-economy-automation/section-8.gif)

Proxy and bulletproof hosting services (BPHS) obfuscate criminal activities and provide anonymity, making it difficult for law enforcement and security researchers to trace malicious operations.

**Mitigations:**

- Leverage threat intelligence platforms
- Blacklist known-malicious servers

## 9. Sniffers

![Sniffers](/assets/img/posts/underground-economy-automation/section-9.gif)

Sniffers are a type of malware written in JavaScript that are designed to infiltrate and steal card-not-present (CNP) data from the checkout pages of e-commerce websites.

**Mitigations:**

- Conduct regular website audits for suspicious scripts
- Prevent external script loading on checkout pages
- Evaluate third-party plugins for security

## 10. Underground Marketplaces

![Underground Marketplaces](/assets/img/posts/underground-economy-automation/section-10.gif)

Underground marketplaces are where stolen data is monetized through the sale of compromised credentials, payment card data, and account access.

**Mitigations:**

- Monitor underground shops for enterprise accounts
- Track spikes in account availability
- Monitor non-public domain credentials
- Enable MFA across all accounts

---

For more information on the 10 types of tools and services currently used by threat actors to automate tasks, and suggested mitigations for defenders to implement, check out the full report by Recorded Future's Insikt Group, "Automation and Commoditization in the Underground Economy."

---

This research originally appeared on [Recorded Future website](https://www.recordedfuture.com/research/underground-economy-automation).

<script>
document.querySelectorAll('.content a[href^="http"]').forEach(function(a) {
  a.setAttribute('target', '_blank');
  a.setAttribute('rel', 'noopener noreferrer');
});
</script>
