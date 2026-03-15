---
title: "Combating the Underground Economy's Automation Revolution"
date: 2020-03-24 12:00:00 +0000
author: insikt_group
categories: [Threat Intelligence]
tags: [Dark Web, Cybercrime, Underground Economy, Brute Force, Exploit Kit, Phishing, Keylogger, Botnet, Infostealer]
canonical_url: https://www.recordedfuture.com/research/underground-economy-automation
source: Recorded Future
image:
  path: /assets/img/posts/underground-economy-automation/cover.jpg
  alt: "Combating the Underground Economy's Automation Revolution"
description: "Recent Insikt Group research explores the tools and services used by threat actors to automate tasks associated with malicious campaigns."
toc: true
---

Automation has become an essential part of nearly every industry, and nowhere is this more true than in cybersecurity. But unfortunately, the benefits of automation are equally available to criminal enterprises and defenders alike. So while the criminal underground has created an ecosystem of tools and resources to operationalize and monetize campaigns, SOARs can be used to tip the balance back in a defender's favor by automating defensive intelligence feeds and combining them with automated detection and prevention.

Research by Recorded Future's Insikt Group explored the tools and services used by threat actors to automate tasks associated with malicious campaigns and the mitigation strategies available through SOAR and threat intelligence solutions.

## 1. Compromised Credentials and Data Breaches

![Breaches and Sale of Databases](/assets/img/posts/underground-economy-automation/section-1.gif)

Cyberattacks frequently start with a compromised network or a database of credentials as a result of threat actors obtaining unauthorized access to a network, who then sell credentials on underground forums. This access can be used for privilege escalation within the network, business email compromise, ransomware, and other types of attacks.

**Mitigations:**

- Keeping all software and applications up to date
- Filtering emails for spam and scrutinizing links and attachments
- Making regular backups of systems, and storing them offline
- Compartmentalizing company-sensitive data
- Instituting role-based access
- Applying data encryption standards

## 2. Checkers and Brute Forcers

![Checkers and Brute Forcers](/assets/img/posts/underground-economy-automation/section-2.gif)

Attackers with credentials obtained by data breaches then leverage checkers and brute-forcers to direct large-scale automated login requests to determine the validity of victims or gain unauthorized access through a credential stuffing attack for thousands of accounts.

**Mitigations:**

- Using unique passwords for accounts, in addition to a password manager
- Requiring additional details for login (e.g., CAPTCHA) or require multi-factor authentication (MFA)
- Establishing customized web application firewalls
- Slowing date or rate limit login traffic
- Removing unused public-facing logins
- Baselining traffic and network requests to monitor for unexpected traffic

## 3. Loaders and Crypters

![Loaders and Crypters](/assets/img/posts/underground-economy-automation/section-3.gif)

Threat actors will also apply loaders and crypters to elude detection by endpoint security products, such as antivirus, and then download and execute one or more malicious payloads, such as malware.

**Mitigations:**

- Updating antivirus software regularly
- Implementing additional response and detection controls beyond antivirus to detect malicious payloads
- Training and educating individuals on phishing and associated risks

## 4. Stealers and Keyloggers

![Stealers and Keyloggers](/assets/img/posts/underground-economy-automation/section-4.gif)

Stealers and keyloggers are used to exfiltrate sensitive information from victims, including credentials, PII, and payment card information, and install secondary payloads onto victims' systems.

**Mitigations:**

- Investing in solutions offering patch posture reporting
- Configuring network defense mechanisms to alert of malicious activity on devices
- Monitoring for suspicious changes to file drives and registries

## 5. Banking Injects

![Banking Injects](/assets/img/posts/underground-economy-automation/section-5.gif)

Automating the process by not having to write their own script, threat actors can easily obtain banking injects, which are widely published, popular, and powerful tools for performing fraud. Fake overlays or modules are used with banking trojans to inject HTML or JavaScript code to collect sensitive information before redirecting to a legitimate website.

**Mitigations:**

- Keeping software and applications up to date
- Installing antivirus solutions, scheduling updates, and monitoring the antivirus status on all equipment
- Enabling MFA via SMS authenticator applications
- Solely using HTTPS connection
- Educating employees and conducting training sessions
- Deploying spam and web filters
- Encrypting all sensitive company information
- Disabling HTML or converting HTML email into text-only email

## 6. Exploit Kits

![Exploit Kits](/assets/img/posts/underground-economy-automation/section-6.gif)

Used to automate the exploitation of web browser vulnerabilities to maximize the delivery of successful infections, exploit kits deliver malicious payloads such as trojans, loaders, ransomware, and other malicious software.

**Mitigations:**

- Prioritizing the patching of Microsoft products and older vulnerabilities in the technology stack
- Ensuring that Adobe Flash Player is automatically disabled in browser settings
- Conducting and maintaining phishing security awareness

## 7. Spamming and Phishing Services

![Spamming and Phishing Services](/assets/img/posts/underground-economy-automation/section-7.gif)

Threat actors leverage spamming and phishing services to conduct email campaigns that give them access to hundreds of thousands of victims to deploy malware or gain further access into a network.

**Mitigations:**

- Refraining from publishing your email address online or replying to spam messages
- Downloading additional spam filtering tools and antivirus software
- Avoiding using personal or business email addresses when registering online
- Developing a password security policy
- Requiring encryption for all employees
- Educating employees and conduct training sessions

## 8. Bulletproof Hosting Services

![Bulletproof Hosting Services](/assets/img/posts/underground-economy-automation/section-8.gif)

To extend the longevity of their criminal actions, threat actors leverage proxy and bulletproof hosting services (BPHS) to obfuscate their activities. BPHS provide secure hosting for malicious content and activity, and anonymity by relying on a model that promises not to comply with legal requests.

**Mitigations:**

- Leveraging threat intelligence platforms, like Recorded Future, to assist in the monitoring of malicious service providers
- Blacklisting servers affiliated with known-malicious BPHS's

## 9. Sniffers

![Sniffers](/assets/img/posts/underground-economy-automation/section-9.gif)

In the underground economy, sniffers refer to a type of malware written in JavaScript that are designed to infiltrate and steal card-not-present (CNP) data from the checkout pages of e-commerce websites.

**Mitigations:**

- Performing regular audits of a website to identify suspicious scripts or network behavior
- Preventing non-essential, externally loaded scripts from loading on checkout pages
- Evaluating third-party plugins on an e-commerce website and monitoring for changes in their code or behavior

## 10. Underground Marketplaces

![Underground Marketplaces](/assets/img/posts/underground-economy-automation/section-10.gif)

In order to monetize the content that threat actors have acquired, they sell stolen data in online credit card shops, account shops, and marketplaces. Money is made through the buying and selling of credentials for bank accounts, cell phone accounts, online store accounts, dating accounts, and even digital fingerprints.

**Mitigations:**

- Monitoring shops and marketplaces for accounts relevant to your enterprise
- Acting on spikes in the number of accounts available in shops
- Paying attention to credentials for non-public facing domains
- Enabling MFA via SMS authenticator applications

---

For more information on the 10 types of tools and services currently used by threat actors to automate tasks, and suggested mitigations for defenders to implement, check out the [full report](https://docslib.org/doc/11895972/automation-and-commoditization-in-the-underground-economy-by-insikt-group%C2%AE) by Recorded Future's Insikt Group, "Automation and Commoditization in the Underground Economy."

<script>
document.querySelectorAll('.content a[href^="http"]').forEach(function(a) {
  a.setAttribute('target', '_blank');
  a.setAttribute('rel', 'noopener noreferrer');
});
</script>
