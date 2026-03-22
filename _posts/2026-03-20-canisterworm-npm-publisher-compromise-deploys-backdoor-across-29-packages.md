---
title: "CanisterWorm: npm Publisher Compromise Deploys Backdoor Across 29+ Packages"
short_title: "CanisterWorm: npm Publisher Compromise Deploys Backdoor"
date: 2026-03-20 12:00:00 +0000
categories: [Supply Chain]
tags: [npm, JavaScript, Backdoor, Developer Compromise, Python, Worm]
author: socket_research_team
canonical_url: https://socket.dev/blog/canisterworm-npm-publisher-compromise-deploys-backdoor-across-29-packages
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/da6d60559014afb322830e20836c380518eaa6dd-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: "CanisterWorm: npm Publisher Compromise Deploys Backdoor Across 29+ Packages"
description: "The worm-enabled campaign hit @emilgroup and @teale.io, then used an ICP canister to deliver follow-on payloads."
---

> *As of March 21, 2026, the CanisterWorm supply chain attack has expanded to 135 malicious package artifacts spanning more than 64 unique packages. We are tracking the incident on Socket's dedicated CanisterWorm supply chain attack page: [https://socket.dev/supply-chain-attacks/canisterworm](https://socket.dev/supply-chain-attacks/canisterworm){:target="_blank"}.*
>
> *According to the Wiz investigation [report](https://www.wiz.io/blog/trivy-compromised-teampcp-supply-chain-attack){:target="_blank"} released on March 20, 2026, the attack is attributed to "TeamPCP", a threat actor behind the earlier Aqua Security's Trivy attacks [[1](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension){:target="_blank"} and [2](https://socket.dev/blog/trivy-under-attack-again-github-actions-compromise){:target="_blank"}].*
>
> *We continue to monitor the incident closely. As of this update, the pace of newly affected packages appears to have slowed, likely due to intervention by the npm registry security team.*
{: .prompt-info }

Socket's Threat Research Team independently identified a worm-enabled npm supply chain attack affecting legitimate publisher namespaces, including a broad cluster of compromised packages under `@emilgroup` and the package `@teale.io/eslint-config`. In the observed activity, the threat actor appears to have obtained one or more npm publishing tokens, or equivalent CI/CD publishing access, and used that access to replace legitimate package contents with malicious code, then republish the payload across additional packages reachable by the compromised credentials.

For naming consistency with overlapping public reporting, we refer to this campaign as CanisterWorm. The name fits a distinctive technical trait of the malware: in its weaponized form, the implanted Python backdoor polls an Internet Computer Protocol (ICP) canister that acts as a dead-drop command and control (C2) channel, retrieves a URL for a follow-on binary, downloads that binary to `/tmp/pglog`, and tracks prior downloads in `/tmp/.pg_state`. That design lets the threat actor rotate second-stage payloads without modifying the implant already persisted on infected systems.

Our investigation shows that the attack evolved in phases. In the earliest observed malicious stage, compromised packages acted as a staging framework: a `postinstall` hook wrote a Python payload supplied through environment or package configuration, installed it as a `systemd --user` service, and started it. In later releases, the threat actor embedded a hardcoded Python dropper, standardized persistence under the service name `pgmon`, and refined the worm to publish compromised releases as `latest` to maximize the chances of downstream installation. Public reporting from Aikido's security researcher Charlie Eriksen [described](https://www.aikido.dev/blog/teampcp-deploys-worm-npm-trivy-compromise) an additional mutation in `@teale.io/eslint-config` that harvested npm tokens from `.npmrc`, environment variables, and npm configuration to make propagation more autonomous.

At this stage, we assess with high confidence that this was a compromise of legitimate npm publisher space involving worm-like propagation and Linux-focused host persistence. We are not making a firm threat actor attribution at this time. Our current analysis independently supports the malware mechanics, victim scope, and propagation model, but not a conclusive threat actor attribution.

![CanisterWorm attack workflow diagram](https://cdn.sanity.io/images/cgdhsj6q/production/9023a8c246eac3a7459d4f61ee21e4171330edaa-1800x1050.png?w=1600&q=95&fit=max&auto=format)
_CanisterWorm chains dependency installation, user-level Linux persistence, and remote payload delivery into a single workflow. After a compromised npm release triggers `postinstall`, the loader persists through `systemd --user` and hands execution to a Python implant that treats the ICP canister as a rotatable dead drop, allowing the threat actor to change second-stage payloads without republishing the package._

## Worm-Enabled npm Supply Chain Attack

This incident began as a cluster of suspicious patch releases under the legitimate `@emilgroup` npm scope. Those packages were real, long-standing SDK packages associated with Emil Group and maintained through the `cover42devs` publisher identity. The malicious versions retained trust cues such as package names and, in many cases, original READMEs, but the actual SDK functionality had been removed and replaced with a compact malware kit built around a `postinstall` backdoor and a separate propagation script named `deploy.js`.

According to our investigation this was a legitimate publisher compromise rather than a typosquat or a one-off malicious upload. The affected `@emilgroup` packages had years of prior version history, normal OpenAPI-generated client structure, and no suspicious install-time behavior in their clean baselines. The malicious releases instead showed abrupt patch bumps, stripped functionality, generic metadata, and byte-identical malware components across multiple packages. In the initial cluster we investigated, all three sample packages shared the same `index.js` backdoor installer, the same `deploy.js` propagation tool, and the same pattern of preserving original README content as camouflage.

The propagation logic is what elevates this beyond a typical package compromise. According to our analysis, `deploy.js` accepts one or more npm tokens from the environment, resolves the associated usernames through npm's `/-/whoami` endpoint, enumerates the packages each token can publish, bumps the patch version for each target, copies the original README when available, and republishes the malicious content under the legitimate package name. In later observed variants, the script explicitly publishes with `--tag latest`, increasing the likelihood that ordinary `npm install` activity resolves to the compromised release by default.

The likely victims are developers, CI runners, and build systems that installed the compromised releases, especially Linux hosts where `systemd --user` is available. The likely publisher-side victims are Emil Group through `cover42devs`, and possibly the maintainer associated with `@teale.io/eslint-config`, although the exact relationship between those namespaces still needs to be confirmed. The evidence currently supports a broad `@emilgroup` compromise and a related `@teale.io` compromise consistent with the same malware family and propagation chain.

![Socket AI Scanner analysis](https://cdn.sanity.io/images/cgdhsj6q/production/33c3c96d0a876054816c483f3ffabb4b3425643e-567x492.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious `@emilgroup/account-sdk@1.41.2` package identifies `index.js` as the install-time execution point for a persistent user-level implant that decodes an embedded payload and then functions as a repeatable remote downloader, allowing attacker-controlled code to run after installation and on subsequent fetch cycles._

## How the Attack Works

Our analysis supports a phased progression from staging to weaponization. In the clean baseline, legitimate versions of `@emilgroup/tenant-sdk`, `@emilgroup/translation-sdk-node`, and `@teale.io/eslint-config` contained normal SDK or configuration logic with no suspicious install hooks. In the first malicious phase, the threat actor gutted the Emil Group packages and replaced them with a minimal framework composed of a slim `package.json`, an `index.js` loader, and `scripts/deploy.js`. The added `postinstall` hook invoked `node index.js`, while the loader derived a dynamic service name from the package name and read a base64 payload from `process.env.PAYLOAD` or package configuration. If no payload was present, it exited silently. That behavior strongly suggests a staging or dry-run phase rather than the final armed implant.

In the next observed phase, the threat actor weaponized the packages. The service name changed from a dynamic value to the hardcoded `pgmon`, and the base64 payload changed from an external input to an embedded Python dropper. Once decoded and written to disk, that Python script slept for 300 seconds, then entered an endless loop that polled `https://tdtqy-oyaaa-aaaae-af2dq-cai[.]raw[.]icp0[.]io/` every 3,000 seconds. When the canister returned a URL, the script downloaded a binary to `/tmp/pglog`, marked it executable, ran it in a detached process, and wrote the URL to `/tmp/.pg_state` to avoid re-downloading the same payload. The code also ignored URLs containing `youtube.com`, which appears to function as a dormant or disarmed state for the implant.

Persistence is established through `systemd --user`. The Node loader writes the Python script to `~/.local/share/pgmon/service.py`, creates `~/.config/systemd/user/pgmon.service`, reloads the user daemon, enables the service, and starts it immediately. Because the service is configured with `Restart=always`, the implant is designed to survive normal user sessions and recover from crashes without requiring root privileges.

The worm component ran in parallel with that host-level implant. `deploy.js` was not triggered by `npm install`; it was the threat actor's republishing tool. In the earlier observed form, it used `npm publish --access public`. In the later refined form, it used `npm publish --access public --tag latest`, an apparently small but operationally important change that increased the probability that downstream installs would resolve to the malicious package versions by default. Our findings also show that `@teale.io/eslint-config` skipped the observed staging phase and appeared directly in a weaponized state, which is consistent with either cross-namespace propagation through the worm or multiple compromised publisher tokens from the outset.

We continue to investigate this incident, and this remains a developing story. We will publish updates as new findings come to light through our ongoing research and analysis.

> Socket users can check for impact under Threat Intel → Campaigns. We are tracking this campaign on our public [CanisterWorm](https://socket.dev/supply-chain-attacks/canisterworm) campaign page.

## Indicators of Compromise (IOCs)

### Affected npm Packages and Versions

1. [`@emilgroup/account-sdk@1.41.1`](https://socket.dev/npm/package/@emilgroup/account-sdk)
1. [`@emilgroup/account-sdk@1.41.2`](https://socket.dev/npm/package/@emilgroup/account-sdk)
1. [`@emilgroup/account-sdk-node@1.40.1`](https://socket.dev/npm/package/@emilgroup/account-sdk-node)
1. [`@emilgroup/account-sdk-node@1.40.2`](https://socket.dev/npm/package/@emilgroup/account-sdk-node)
1. [`@emilgroup/accounting-sdk-node@1.26.1`](https://socket.dev/npm/package/@emilgroup/accounting-sdk-node)
1. [`@emilgroup/accounting-sdk-node@1.26.2`](https://socket.dev/npm/package/@emilgroup/accounting-sdk-node)
1. [`@emilgroup/api-documentation@1.19.1`](https://socket.dev/npm/package/@emilgroup/api-documentation)
1. [`@emilgroup/api-documentation@1.19.2`](https://socket.dev/npm/package/@emilgroup/api-documentation)
1. [`@emilgroup/auth-sdk@1.25.1`](https://socket.dev/npm/package/@emilgroup/auth-sdk)
1. [`@emilgroup/auth-sdk@1.25.2`](https://socket.dev/npm/package/@emilgroup/auth-sdk)
1. [`@emilgroup/auth-sdk-node@1.21.1`](https://socket.dev/npm/package/@emilgroup/auth-sdk-node)
1. [`@emilgroup/auth-sdk-node@1.21.2`](https://socket.dev/npm/package/@emilgroup/auth-sdk-node)
1. [`@emilgroup/billing-sdk@1.56.1`](https://socket.dev/npm/package/@emilgroup/billing-sdk)
1. [`@emilgroup/billing-sdk@1.56.2`](https://socket.dev/npm/package/@emilgroup/billing-sdk)
1. [`@emilgroup/billing-sdk-node@1.57.1`](https://socket.dev/npm/package/@emilgroup/billing-sdk-node)
1. [`@emilgroup/billing-sdk-node@1.57.2`](https://socket.dev/npm/package/@emilgroup/billing-sdk-node)
1. [`@emilgroup/claim-sdk@1.41.1`](https://socket.dev/npm/package/@emilgroup/claim-sdk)
1. [`@emilgroup/claim-sdk@1.41.2`](https://socket.dev/npm/package/@emilgroup/claim-sdk)
1. [`@emilgroup/claim-sdk-node@1.39.1`](https://socket.dev/npm/package/@emilgroup/claim-sdk-node)
1. [`@emilgroup/claim-sdk-node@1.39.2`](https://socket.dev/npm/package/@emilgroup/claim-sdk-node)
1. [`@emilgroup/customer-sdk@1.54.1`](https://socket.dev/npm/package/@emilgroup/customer-sdk)
1. [`@emilgroup/customer-sdk@1.54.2`](https://socket.dev/npm/package/@emilgroup/customer-sdk)
1. [`@emilgroup/customer-sdk-node@1.55.1`](https://socket.dev/npm/package/@emilgroup/customer-sdk-node)
1. [`@emilgroup/customer-sdk-node@1.55.2`](https://socket.dev/npm/package/@emilgroup/customer-sdk-node)
1. [`@emilgroup/document-sdk@1.45.1`](https://socket.dev/npm/package/@emilgroup/document-sdk)
1. [`@emilgroup/document-sdk@1.45.2`](https://socket.dev/npm/package/@emilgroup/document-sdk)
1. [`@emilgroup/document-sdk-node@1.43.1`](https://socket.dev/npm/package/@emilgroup/document-sdk-node)
1. [`@emilgroup/document-sdk-node@1.43.2`](https://socket.dev/npm/package/@emilgroup/document-sdk-node)
1. [`@emilgroup/gdv-sdk@2.6.1`](https://socket.dev/npm/package/@emilgroup/gdv-sdk)
1. [`@emilgroup/gdv-sdk@2.6.2`](https://socket.dev/npm/package/@emilgroup/gdv-sdk)
1. [`@emilgroup/insurance-sdk@1.97.1`](https://socket.dev/npm/package/@emilgroup/insurance-sdk)
1. [`@emilgroup/insurance-sdk@1.97.2`](https://socket.dev/npm/package/@emilgroup/insurance-sdk)
1. [`@emilgroup/insurance-sdk-node@1.95.1`](https://socket.dev/npm/package/@emilgroup/insurance-sdk-node)
1. [`@emilgroup/insurance-sdk-node@1.95.2`](https://socket.dev/npm/package/@emilgroup/insurance-sdk-node)
1. [`@emilgroup/notification-sdk-node@1.4.1`](https://socket.dev/npm/package/@emilgroup/notification-sdk-node)
1. [`@emilgroup/notification-sdk-node@1.4.2`](https://socket.dev/npm/package/@emilgroup/notification-sdk-node)
1. [`@emilgroup/partner-portal-sdk-node@1.1.1`](https://socket.dev/npm/package/@emilgroup/partner-portal-sdk-node)
1. [`@emilgroup/partner-portal-sdk-node@1.1.2`](https://socket.dev/npm/package/@emilgroup/partner-portal-sdk-node)
1. [`@emilgroup/partner-sdk-node@1.19.1`](https://socket.dev/npm/package/@emilgroup/partner-sdk-node)
1. [`@emilgroup/partner-sdk-node@1.19.2`](https://socket.dev/npm/package/@emilgroup/partner-sdk-node)
1. [`@emilgroup/payment-sdk@1.15.1`](https://socket.dev/npm/package/@emilgroup/payment-sdk)
1. [`@emilgroup/payment-sdk@1.15.2`](https://socket.dev/npm/package/@emilgroup/payment-sdk)
1. [`@emilgroup/payment-sdk-node@1.23.1`](https://socket.dev/npm/package/@emilgroup/payment-sdk-node)
1. [`@emilgroup/payment-sdk-node@1.23.2`](https://socket.dev/npm/package/@emilgroup/payment-sdk-node)
1. [`@emilgroup/process-manager-sdk-node@1.13.1`](https://socket.dev/npm/package/@emilgroup/process-manager-sdk-node)
1. [`@emilgroup/process-manager-sdk-node@1.13.2`](https://socket.dev/npm/package/@emilgroup/process-manager-sdk-node)
1. [`@emilgroup/public-api-sdk@1.33.1`](https://socket.dev/npm/package/@emilgroup/public-api-sdk)
1. [`@emilgroup/public-api-sdk@1.33.2`](https://socket.dev/npm/package/@emilgroup/public-api-sdk)
1. [`@emilgroup/public-api-sdk-node@1.35.1`](https://socket.dev/npm/package/@emilgroup/public-api-sdk-node)
1. [`@emilgroup/public-api-sdk-node@1.35.2`](https://socket.dev/npm/package/@emilgroup/public-api-sdk-node)
1. [`@emilgroup/tenant-sdk@1.34.1`](https://socket.dev/npm/package/@emilgroup/tenant-sdk)
1. [`@emilgroup/tenant-sdk@1.34.2`](https://socket.dev/npm/package/@emilgroup/tenant-sdk)
1. [`@emilgroup/tenant-sdk-node@1.33.1`](https://socket.dev/npm/package/@emilgroup/tenant-sdk-node)
1. [`@emilgroup/tenant-sdk-node@1.33.2`](https://socket.dev/npm/package/@emilgroup/tenant-sdk-node)
1. [`@emilgroup/translation-sdk-node@1.1.1`](https://socket.dev/npm/package/@emilgroup/translation-sdk-node)
1. [`@emilgroup/translation-sdk-node@1.1.2`](https://socket.dev/npm/package/@emilgroup/translation-sdk-node)
1. [`@teale.io/eslint-config@1.8.9`](https://socket.dev/npm/package/@teale.io/eslint-config)
1. [`@teale.io/eslint-config@1.8.10`](https://socket.dev/npm/package/@teale.io/eslint-config)

### Network / C2

- **C2 URL:** `https://tdtqy-oyaaa-aaaae-af2dq-cai.raw.icp0.io/`
- **ICP canister ID:** `tdtqy-oyaaa-aaaae-af2dq-cai`
