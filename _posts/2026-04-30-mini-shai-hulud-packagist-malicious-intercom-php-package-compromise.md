---
title: "Mini Shai-Hulud Spreads to Packagist: Malicious Intercom PHP Package Follows npm Compromise"
short_title: "Mini Shai-Hulud Spreads to Packagist via Intercom PHP"
date: 2026-04-30 12:00:00 +0000
categories: [Malware, Supply Chain]
tags: [Shai-Hulud, TeamPCP, Packagist, PHP, Composer, Infostealer, Obfuscation, Developer Compromise, npm, JavaScript, PyPI, Python]
author: socket_research_team
canonical_url: https://socket.dev/blog/mini-shai-hulud-packagist-malicious-intercom-php-package-compromise
source: Socket
image:
  path: https://image-archive.developerhub.io/image/upload/5969/zqyhywd6ogykwn2xrrau/1539432578.png
  alt: "Mini Shai-Hulud Spreads to Packagist: Malicious Intercom PHP Package Follows npm Compromise"
description: "Socket found a malicious Intercom PHP package on Packagist using Composer plugin execution to steal credentials and spread across ecosystems."
---

A malicious [`intercom/intercom-php`](https://socket.dev/composer/package/intercom/intercom-php/overview?version=5.0.2) package artifact uses Composer plugin execution to download Bun and run the same style of obfuscated credential-stealing payload [observed](https://socket.dev/blog/intercom-s-npm-package-compromised-in-supply-chain-attack) in the ongoing [Mini Shai-Hulud campaign](https://socket.dev/supply-chain-attacks/mini-shai-hulud).

`intercom/intercom-php` is a widely used PHP package, with more than 20.7 million lifetime installs, roughly 285,000 installs in the last 30 days, and an estimated 12,700 daily installs across versions (~700 for version `5.0.2`), meaning the compromised `5.0.2` artifact could have reached high-value developer and CI/CD environments quickly. We reported the malicious artifact to Packagist, which quickly removed.

**Update** (April 30**,** 19:46:2)**:** Intercom has confirmed to Socket that the root cause of the compromise was a local install of `pyannote-audio`, which introduced the compromised `lightning` package as a transitive dependency. That finding connects the attack chain across three ecosystems: the PyPI `lightning` compromise led to the npm `intercom-client` compromise, which was then followed by the malicious Packagist artifact for `intercom/intercom-php`. Intercom confirmed the `pyannote-audio` package was installed directly by a user locally and was not related to other repositories.

![](https://cdn.sanity.io/images/cgdhsj6q/production/8b4b6c513a115c801adb11e7c226a5d15ccc73ca-620x650.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flags [`intercom/intercom-php@5.0.2`](https://socket.dev/composer/package/intercom/intercom-php/overview?version=5.0.2) as known malware, identifying [`router_runtime.js`](https://socket.dev/composer/package/intercom/intercom-php/files?version=5.0.2&path=intercom-intercom-php-e69bf4b%2Frouter_runtime.js) as a credential theft and supply chain propagation payload that harvests CI/CD and cloud secrets, abuses GitHub repositories for staged exfiltration, and uses daemonized execution to evade normal process visibility._

We identified a malicious Packagist package artifact for `intercom/intercom-php@5.0.2`, indicating that the Mini Shai-Hulud supply chain attack affecting Intercom has expanded beyond npm and into the PHP ecosystem. The threat actor first changed `intercom/intercom-php@5.0.2` to point to commit `e8a812c5ea7d8c7ed642b0d82754ced6a99025b0` at 2026-04-30 20:51:09 UTC, then changed it again at 20:53:12 UTC to point to commit `e69bf4b3e84e7951a7b4ded8fee8822c57630cf8`. Socket’s AI scanner detected the malicious code 14 minutes after release.

This is possible because Packagist versions are not inherently immutable. Packagist mirrors tags from upstream Git repositories, and Git tags can be force-updated to point to a different commit. As a result, an attacker who can modify the repository can effectively replace the contents of an existing version without changing its version number.

![](https://cdn.sanity.io/images/cgdhsj6q/production/89ee5dc2dbf41851d32c1d0102d53812a3ddebf7-1190x993.png?w=1600&q=95&fit=max&auto=format)

This follows Socket’s [report](https://socket.dev/blog/intercom-s-npm-package-compromised-in-supply-chain-attack) earlier today that `intercom-client@7.0.4`, Intercom’s npm package for its Node.js client, was compromised with a malicious `preinstall` hook, a Bun downloader, and an obfuscated `router_runtime.js` payload designed to steal developer and CI/CD secrets. The npm compromise affected systems at install time, even if the package was never imported in application code.

The newly analyzed PHP package shows the same operational pattern, adapted for Packagist. The package presents itself as `intercom/intercom-php`, but its `composer.json` changes the package type to `composer-plugin`, adds `composer-plugin-api`, and registers `Intercom\\\\ComposerPlugin` as the plugin entry point. Packagist currently lists `intercom/intercom-php@5.0.2` with `composer-plugin-api` as a requirement, while the upstream GitHub `composer.json` on `master` does not declare the package as a Packagist plugin and does not include the malicious plugin execution path.

![](https://cdn.sanity.io/images/cgdhsj6q/production/fc602bd9a349a456659bb0360c2cbcd42a72053e-1178x928.png?w=1600&q=95&fit=max&auto=format)
_Packagist metadata for `intercom/intercom-php@5.0.2` shows an anomalous `composer-plugin-api` requirement, indicating the PHP client was converted into a Composer plugin capable of install/update-time execution._

## Composer Plugin Abuse Enables Install-Time Execution

The malicious PHP artifact adds a Composer plugin class at:

```php
src/composerPlugin.php
```

That plugin subscribes to:

```php
post-install-cmd
post-update-cmd
```

When triggered, it resolves the installed `intercom/intercom-php` package path and executes:

```php
setup-intercom.sh
```

The shell script downloads Bun `1.3.13` from GitHub Releases, selects the correct Linux or macOS binary for the host architecture, extracts it, and executes:

```php
router_runtime.js
```

This is not normal behavior for a PHP SDK. A legitimate Intercom PHP API client has no reason to become a Composer plugin, run a shell script during install/update, download a JavaScript runtime, and execute an 11.7 MB obfuscated JavaScript payload.

## Same Malware Pattern, New Ecosystem

The PHP payload mirrors the broader Mini Shai-Hulud tradecraft observed across recent npm and PyPI compromises: install-time execution, Bun-based payload launch, heavily obfuscated JavaScript, credential harvesting from developer and CI/CD environments, and encrypted exfiltration.

Socket’s earlier Intercom npm report documented that `intercom-client@7.0.4` introduced `setup.mjs` and `router_runtime.js`, downloaded Bun without integrity checks, and used an obfuscated payload to collect Kubernetes and Vault credentials, with stolen secrets encrypted and exfiltrated through GitHub infrastructure.

The PHP artifact uses a Composer-specific entry point instead of npm’s `preinstall`, but the objective is the same: execute malware during dependency installation, before developers or CI systems ever use the library.

## What the PHP Payload Does

Static analysis of the uploaded Composer artifact shows that `router_runtime.js` is a credential and secret stealer with propagation capabilities.

The payload targets:

```php
GitHub CLI tokens
npm tokens
SSH private keys
AWS credentials
Azure credentials
GCP credentials
Docker credentials
Kubernetes configuration and service account tokens
HashiCorp Vault tokens
.env files
.pypirc
.npmrc
Git credentials
shell history
application configuration files such as wp-config.php
```

It also contains collectors for cloud and secret-management services, including:

```php
AWS SSM Parameter Store
AWS Secrets Manager
AWS STS
Azure Key Vault
GCP Secret Manager
Kubernetes Secrets
HashiCorp Vault
```

The malware encrypts stolen data using AES-256-GCM and wraps the AES key with RSA-OAEP/SHA-256 before exfiltration.

The primary hardcoded exfiltration endpoint in the PHP artifact is (defang by Socket for safety):

```php
https://zero[.]masscan[.]cloud:443/v1/telemetry
```

If direct exfiltration fails, the payload can fall back to GitHub-based exfiltration using stolen GitHub credentials. The same theme appeared in the npm compromise, where suspicious GitHub activity included repositories with the description `A Mini Shai-Hulud has Appeared` and repository changes consistent with Shai-Hulud-style propagation.

## Propagation Risk

The payload includes logic consistent with supply chain propagation. The PHP payload can abuse discovered npm tokens to modify and republish packages, inject install-time scripts, and publish modified tarballs. It also contains GitHub repository modification logic that writes payload files into paths such as:

```php
.claude/router_runtime.js
.claude/setup.mjs
.claude/settings.json
.vscode/setup.mjs
.vscode/tasks.json
```

The commit metadata is designed to blend into normal developer workflows, using messages such as:

```php
chore: update dependencies
```

and spoofed-looking author metadata such as:

```php
claude <claude@users.noreply.github.com>
```

This makes the PHP artifact part of the same broader operational model: steal credentials, use those credentials to reach more repositories and packages, and propagate through trusted developer workflows.

## The Most Important Shift is Ecosystem Expansion.

Mini Shai-Hulud is no longer only an npm concern in the Intercom case. The same attack chain has now appeared in a Packagist package artifact for Intercom’s PHP SDK, using Composer’s plugin system as the install-time execution mechanism.

That means PHP projects, Laravel applications, backend services, and CI/CD pipelines that installed or updated `intercom/intercom-php@5.0.2` may need to treat the host as potentially exposed, especially if Composer plugin execution was allowed.

Because the payload executes during install or update, exposure does not require the application to import or call the Intercom PHP client.

## Recommended Actions

Impacted organizations should immediately:

1. Audit all environments for installation of `intercom/intercom-php@5.0.2`.
1. Review Composer logs for execution of `setup-intercom.sh` or messages such as `Running Intercom setup script`.
1. Check whether Composer plugin execution was allowed for `intercom/intercom-php`.
1. Remove the malicious artifact and reinstall only from a known-good source.
1. Rotate credentials that may have been present on affected developer machines or CI runners, prioritizing:
- GitHub tokens
- npm tokens
- SSH keys
- AWS, Azure, and GCP credentials
- Kubernetes tokens
- Vault tokens
- Docker registry credentials
- application secrets in `.env` files
1. Review GitHub repositories for unauthorized commits, new workflow files, `.claude/` or `.vscode/` payload files, and suspicious public repositories.
1. Review npm packages controlled by affected maintainers for unauthorized releases or install-time script changes.

## Indicators of Compromise

### Malicious Packagist / PHP Artifact

- [`intercom/intercom-php v.5.0.2`](https://socket.dev/composer/package/intercom/intercom-php/overview?version=5.0.2)

### Files

- `composer.json`
- `setup-intercom.sh`
- `router_runtime.js`
- `src/composerPlugin.php`

### SHA256

- intercom-intercom-php-5.0.2.zip: `66664a49edbcee0ed0d8365839707916e92d3aa06e7f26f33c9dcc58e5fc1ef3`
- composer.json: `907aec5b1288057a3e0885226918b6930a62a0f348ce23de026a683238c7903e`
- router_runtime.js: `50212a875643520353df158196b9b3be4595094125ad8d2d2c48bdd9cb04ce1f`
- [setup-intercom.sh](http://setup-intercom.sh): `832a976d1a8d54e296e8479aedbd89fa24baa02b8409a78bf06d4d03340881bd`
- src/composerPlugin.php: `b084743bd16043461e68b604dde80a8b386b405eae6f66c1103fb4fd6831d4a7`

### Network (defanged)

- `zero[.]masscan[.]cloud`
- `https://zero[.]masscan[.]cloud:443/v1/telemetry`

### Strings for Threat Hunting

- `Running Intercom setup script...`
- `Intercom setup complete.`
- `Intercom\\\\ComposerPlugin`
- `router_runtime.js`
- `setup-intercom.sh`
- `A Mini Shai-Hulud has Appeared`
- `EveryBoiWeBuildIsAWormyBoi`
- `Exiting as russian language detected!`
- `chore: update dependencies`
- `claude@users.noreply.github.com`
- `package-updated.tgz`

### Suspicious Paths

- `/tmp/tmp.987654321.lock`
- `.claude/router_runtime.js`
- `.claude/setup.mjs`
- `.claude/settings.json`
- `.vscode/setup.mjs`
- `.vscode/tasks.json`
- `results/results-*.json`
- `package-updated.tgz`

## Developing Story

Socket is continuing to track Mini Shai-Hulud activity across ecosystems. The Intercom compromise now shows clear cross-ecosystem spread, moving from npm into Packagist while preserving the same core malware architecture: install-time execution, Bun-based payload delivery, obfuscated credential harvesting, encrypted exfiltration, and supply chain propagation.

Developers and security teams should treat any affected environment as potentially compromised and rotate exposed credentials immediately.
