---
title: "Mini Shai-Hulud Hits @antv Ecosystem, 639 Compromised npm Package Versions"
short_title: "Mini Shai-Hulud Hits @antv Ecosystem"
date: 2026-05-18 12:00:00 +0000
categories: [Malware, Supply Chain]
tags: [Shai-Hulud, npm, JavaScript, Infostealer, Obfuscation, Developer Compromise, Worm, Composer, Packagist, PHP, PyPI, Python]
author: socket_research_team
canonical_url: https://socket.dev/blog/antv-packages-compromised
source: Socket
image:
  path: https://miro.medium.com/v2/resize:fit:1358/1*SisrybOjmFigMw9lg5r3NA.jpeg
  alt: "Mini Shai-Hulud Hits @antv Ecosystem, 639 Compromised npm Package Versions"
description: "Active npm supply chain attack compromises @antv packages in a fast-moving malicious publish wave tied to Mini Shai-Hulud."
---

Socket's Threat Research team is investigating an active npm supply chain attack involving compromised packages in the `@antv` ecosystem.

The attack affects packages tied to the npm maintainer account atool, including `echarts-for-react`, a widely used React wrapper for Apache ECharts with roughly 1.1 million weekly downloads. Socket quickly detected the malicious publish wave and classified the affected versions as known malware.

Socket's internal review identified hundreds of unique packages. The pattern matches Mini Shai-Hulud, a high-volume npm compromise pattern involving coordinated malicious publishes across packages tied to a compromised maintainer account.

The affected package set includes widely used @antv packages such as @antv/g2, @antv/g6, @antv/x6, @antv/l7, @antv/s2, @antv/f2, @antv/g, @antv/g2plot, @antv/graphin, and @antv/data-set, along with related packages outside the @antv namespace, including echarts-for-react, timeago.js, size-sensor, canvas-nest.js, and others.

The potential blast radius is significant because the affected publishing account is connected to widely used packages across data visualization, graphing, mapping, charting, and React component ecosystems. Even if only a subset of those packages received malicious updates, the popularity of the package ecosystem creates meaningful downstream exposure for organizations that automatically pull new dependency versions.

That scale makes this one of the larger npm supply chain incidents Socket has investigated recently.

This is a developing story. Socket is continuing to investigate the full scope of the compromise and will update this post as additional affected packages, versions, and payload details are confirmed.

## 5/19 Mini-Shai-Hulud Wave

Socket identified 639 compromised package versions across 323 unique packages in tonight's Mini Shai-Hulud wave. All of the newly observed activity tonight was in the npm ecosystem, with the bulk of the activity concentrated in @antv packages. The affected set also included unscoped npm packages and packages under `@lint-md`, `@openclaw-cn`, and `@starmind`.

The malicious publish activity tonight began around 01:56 UTC and continued until roughly 02:56 UTC, with Socket detections appearing between about 02:02 UTC and 03:09 UTC. Across the 639 compromised package versions published tonight, Socket detected most of the activity within ~6 to 12 minutes of publication, with a median detection time of about 6.7 minutes.

Across the full Mini Shai-Hulud campaign we have tracked 1,055 versions across 502 unique packages. The campaign spans npm, PyPI, and Composer, with npm representing the overwhelming majority of the activity: 1,048 npm versions across 498 unique npm packages, plus 6 PyPI entries across 3 packages and 1 Composer package-version entry.

## Technical Analysis: Malicious Payload

Our review of compromised `@antv` artifacts identified an install-time payload consistent with the Mini Shai-Hulud supply-chain malware family. A root-level `index.js` payload modifies `package.json` to execute it during installation:

```javascript
"preinstall":"bun run index.js"
```

The injected `index.js` file is heavily obfuscated. It uses a large string-array lookup table, runtime string decoding, and a custom decryptor exposed through `globalThis` as `fc2edea72`. Decoded strings reveal the primary exfiltration endpoint, GitHub API usage, npm registry API usage, lock-file paths, and internal execution markers. This obfuscation is designed to hide sensitive strings from simple static inspection and is consistent with prior Mini Shai-Hulud variants observed across npm supply-chain compromises.

The payload establishes a hardcoded HTTPS exfiltration path: `https://t[.]m-kosche[.]com:443/api/public/otel/v1/traces`.

Collected data is serialized, compressed with gzip, encrypted with AES-256-GCM, and the AES key is wrapped using RSA-OAEP with SHA-256 before transmission. This prevents defenders from easily recovering stolen plaintext from network telemetry.

The payload targets developer and CI/CD environments. It searches for GitHub tokens, npm tokens, AWS credentials, Kubernetes service-account material, Vault tokens, SSH/private keys, Docker authentication files, database connection strings, and other high-value development secrets. It also contains logic for common CI/CD platforms, including GitHub Actions, GitLab CI, Travis CI, CircleCI, Jenkins, Azure DevOps, AWS CodeBuild, Buildkite, AppVeyor, Bitbucket Pipelines, Drone, Semaphore, TeamCity, Bamboo, Bitrise, Vercel, Netlify, and Cloudflare Pages.

### GitHub Fallback Exfiltration

In addition to the direct HTTPS endpoint, the payload includes a GitHub-based fallback exfiltration mechanism. If it obtains a usable GitHub token, it can create a repository under the victim's account and commit stolen data into files under a `results/` directory, using paths that follow this pattern:

```javascript
results/results-<timestamp>-<counter>.json
```

This behavior aligns with the broader Mini Shai-Hulud pattern of abusing trusted developer platforms as exfiltration and staging infrastructure. Socket previously documented GitHub repository creation in Mini Shai-Hulud-linked campaigns, including repository names following a `<word>-<word>-<3 digits>` pattern and repository descriptions used as campaign markers.

Public GitHub search results for the reversed phrase `niaga og ew ereh :duluh-iahs` currently show roughly 1.9k repositories using the marker `niagA oG eW ereH :duluH-iahS`, which reverses to `Shai-Hulud: Here We Go Again`. The visible repositories use Dune-themed names such as `sayyadina-stillsuit-852`, `atreides-ornithopter-112`, `harkonnen-phibian-552`, `fremen-fedaykin-225`, and `kanly-lasgun-874`.

One observed repository, `Zaynex/sayyadina-stillsuit-852`, contains a `results` directory and a README containing the same reversed marker. This matches the payload's GitHub repository exfiltration logic and suggests the GitHub fallback path is operational.

![GitHub search reveals a rapidly updating cluster of threat actor-created repositories using a reversed Shai-Hulud campaign marker and Dune-themed naming.](https://cdn.sanity.io/images/cgdhsj6q/production/167eb3610681dfc0d26046cc933afa9dac0c7304-2048x1596.png?w=1600&q=95&fit=max&auto=format)
_GitHub search reveals a rapidly updating cluster of threat actor-created repositories using a reversed Shai-Hulud campaign marker and Dune-themed naming, supporting the assessment that the malware's GitHub fallback exfiltration path is active at scale._

### npm Propagation Logic

The payload also contains npm registry abuse logic. It can validate npm tokens through npm registry APIs, enumerate packages maintainable by the token owner, download package tarballs, inject the malicious payload, add a `preinstall` hook, bump package versions, and republish modified packages under the compromised maintainer's identity.

The injected package modification follows this general pattern:

```javascript
{
  "scripts": {
    "preinstall":"bun run index.js"
  },
  "optionalDependencies": {
    "@antv/setup":"github:antvis/G2#1916faa365f2788b6e193514872d51a242876569"
  }
}
```

The added `@antv/setup` GitHub dependency mirrors a technique previously observed in Mini Shai-Hulud activity, where a malicious git-based dependency provides another lifecycle execution path during installation. Prior Socket reporting on the TanStack wave documented a similar suspicious setup dependency, `@tanstack/setup`, resolving to a standalone GitHub commit with a `prepare` hook that executed a Bun payload.

The payload contains explicit worm-like functionality intended to use stolen npm credentials to modify and republish additional packages.

### Relationship to Prior Mini Shai-Hulud Variants

The AntV payloads differ from earlier Mini Shai-Hulud artifacts such as TanStack's `router_init.js` and Intercom-related `router_runtime.js` payloads. The AntV sample uses a root-level `index.js`, a different primary C2 endpoint, and a smaller payload body. However, the core operational model is consistent:

- Install-time execution through package lifecycle scripts
- Bun-based payload execution
- Heavy JavaScript obfuscation
- Developer and CI/CD secret harvesting
- GitHub API abuse
- Encrypted exfiltration
- npm package reinfection and republishing logic
- GitHub repositories used as exfiltration or staging infrastructure

These overlaps support treating the AntV compromise as a Mini Shai-Hulud variant rather than an unrelated package compromise.

## Indicators of Compromise

### Network Indicators

- `t[.]m-kosche[.]com`
- `https://t[.]m-kosche[.]com:443/api/public/otel/v1/traces`

### Detection Opportunities

The following endpoints are legitimate npm and Sigstore services. They are not threat actor-controlled infrastructure and should not be blocked by default. They are included as detection opportunities because unexpected access to these endpoints from package lifecycle scripts, dependency installation, or non-publishing CI jobs may indicate credential validation, package enumeration, or provenance/signing abuse.

- `https://registry.npmjs.org/-/npm/v1/tokens`
- `https://registry.npmjs.org/-/whoami`
- `https://registry.npmjs.org/-/v1/search?text=maintainer:<user>&size=250`
- `https://fulcio.sigstore.dev/api/v2/signingCert`
- `https://rekor.sigstore.dev/api/v1/log/entries`

### GitHub Repository Markers

- `niagA oG eW ereH :duluH-iahS`
- `niaga og ew ereh :duluh-iahs`
- `Shai-Hulud: Here We Go Again`
- `results/results-*.json`

### Example Repository Naming Pattern

- `<dune-word>-<dune-word>-<digits>`
- `sayyadina-stillsuit-852`
- `atreides-ornithopter-112`
- `harkonnen-phibian-552`
- `fremen-fedaykin-225`
- `kanly-lasgun-874`

### Secret Targets

- `GITHUB_TOKEN`
- `ACTIONS_ID_TOKEN_REQUEST_URL`
- `ACTIONS_ID_TOKEN_REQUEST_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_SHARED_CREDENTIALS_FILE`
- `AWS_CONFIG_FILE`
- `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`
- `AWS_CONTAINER_CREDENTIALS_FULL_URI`
- `AWS_WEB_IDENTITY_TOKEN_FILE`
- `AWS_ROLE_ARN`
- `AWS_ROLE_SESSION_NAME`
- `KUBECONFIG`
- `KUBERNETES_SERVICE_HOST`
- `VAULT_ADDR`
- `VAULT_TOKEN`
- `VAULT_AUTH_TOKEN`
- `VAULT_API_TOKEN`
